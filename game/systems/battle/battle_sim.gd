class_name BattleSim
extends RefCounted
## Engine chiến đấu P4: TẤT ĐỊNH (seeded, tick 10Hz), HEADLESS, tách SIM↔VIEW.
## Nâng cấp từ BattleEngine P1: skill/cast/CC/shield, boss đa phase, formation buff,
## aggro + contribution, replay record. BattleEngine P1 GIỮ nguyên cho expedition.
## Pipeline damage: Damage→Crit→Def→Resist→Shield→HP (COMBAT.md). Mọi RNG cục bộ seeded.

const DT := 0.1
const SIM_VERSION := 1
const DEFAULT_MAX_TICKS := 900          # 90s (arena). Boss dùng trần lớn hơn.

var result: SimResult
var _rng := RandomNumberGenerator.new()
var _units: Array[SimCombatant] = []
var _bosses: Array[SimCombatant] = []
var _boss_ctrl := BossController.new()
var _tick: int = 0
var _record: bool = false
var _pending_minions: Array = []        # spawn dàn nhiều tick (KHÔNG mass-spawn 1 frame)

## Chạy 1 trận. a, b: Array[SimCombatant]. Boss ở b đã set is_boss + boss_def/phases/state.
func simulate(a: Array, b: Array, seed_val: int, max_ticks: int = DEFAULT_MAX_TICKS, record: bool = false) -> SimResult:
	_rng.seed = seed_val
	_record = record
	result = SimResult.new()
	result.seed = seed_val
	_units.clear(); _bosses.clear()
	for u in a:
		u.team = 0; _units.append(u)
	for u in b:
		u.team = 1; _units.append(u)
		if u.is_boss:
			_bosses.append(u)
	_units.sort_custom(func(x, y): return x.id < y.id)   # thứ tự ỔN ĐỊNH -> tất định
	for boss in _bosses:
		_boss_ctrl.on_setup(self, boss)

	var t := 0.0
	for tick in max_ticks:
		_tick = tick
		if _team_alive(0) == 0 or _team_alive(1) == 0:
			break
		t = float(tick + 1) * DT
		_spawn_pending()
		for c in _units:
			if c.is_alive():
				for sk in c.skills:
					sk.tick_cd(DT)
		for boss in _bosses:
			if boss.is_alive():
				_boss_ctrl.pre_tick(self, boss, tick)
		for c in _units:
			if c.is_alive() and not c.is_stunned(tick):
				_act(c, tick)
		result.duration_ticks = tick + 1
	result.duration = t
	_finalize()
	return result

# --- hành động 1 combatant -------------------------------------------------
func _act(c: SimCombatant, tick: int) -> void:
	if c.is_casting():
		c.cast_remaining -= DT
		if c.cast_remaining <= 0.0:
			var sk := c.casting_skill
			var tid := c.cast_target_id
			c.clear_cast()
			_execute(c, sk, tid, tick)
		return
	var sk := _select_skill(c, tick)
	if sk == null:
		return
	var target := _pick_target(c, sk.def)
	if sk.def.needs_target() and target == null and sk.def.target_mode != Enums.SkillTarget.ALL_ENEMIES:
		return
	sk.trigger()
	var tid := target.id if target != null else ""
	if sk.def.cast_time_sec > 0.0:
		c.casting_skill = sk
		c.cast_remaining = sk.def.cast_time_sec
		c.cast_target_id = tid
		if sk.def.warning_sec > 0.0:
			_record_cmd(tick, c.id, "warn", tid, str(sk.def.id))
			on_boss_event("warning", c, {"skill": str(sk.def.id)})
		_record_cmd(tick, c.id, "cast", tid, str(sk.def.id))
	else:
		_execute(c, sk, tid, tick)

## Chọn skill: ưu tiên skill đặc biệt sẵn sàng (idx>=1, thứ tự ỔN ĐỊNH); còn lại basic-attack.
## Hero (from_hero) chỉ có basic; boss/định nghĩa riêng có thêm skill -> emergent behavior.
func _select_skill(c: SimCombatant, _tick: int) -> SkillRuntime:
	for i in range(1, c.skills.size()):
		if c.skills[i].ready_now():
			return c.skills[i]
	return c.skills[0] if c.skills.size() > 0 and c.skills[0].ready_now() else null

# --- thực thi skill --------------------------------------------------------
func _execute(src: SimCombatant, sk: SkillRuntime, target_id: String, tick: int) -> void:
	var def := sk.def
	_record_cmd(tick, src.id, "cast_done" if def.cast_time_sec > 0.0 else "use", target_id, str(def.id))
	match def.skill_type:
		Enums.SkillType.DAMAGE:
			if def.target_mode == Enums.SkillTarget.ALL_ENEMIES:
				for e in _enemies_of(src):
					_deal(src, e, def, tick)
			else:
				var tgt := _find(target_id)
				if tgt != null and tgt.is_alive():
					_deal(src, tgt, def, tick)
		Enums.SkillType.HEAL:
			var ally := _find(target_id)
			if ally == null:
				ally = src
			var amt := int(round(src.attack * def.power_mult + def.flat_amount))
			ally.hp = mini(ally.max_hp, ally.hp + amt)
			_track_heal(src, amt)
			_record_hit(tick, "heal", src.id, ally.id, amt, false, str(def.id))
		Enums.SkillType.SHIELD:
			var ally := _find(target_id)
			if ally == null:
				ally = src
			ally.shield += int(round(src.attack * def.power_mult + def.flat_amount))
			_record_hit(tick, "shield", src.id, ally.id, ally.shield, false, str(def.id))
		Enums.SkillType.CC:
			var tgt := _find(target_id)
			if tgt != null and tgt.is_alive():
				_apply_cc(src, tgt, def, tick)
		Enums.SkillType.SUMMON:
			if def.summon_group_id != &"":
				spawn_minions(src, str(def.summon_group_id))

func _deal(src: SimCombatant, tgt: SimCombatant, def: SkillDef, tick: int) -> void:
	var hit := compute_hit(src, tgt, def, _rng)
	var dmg: int = hit["damage"]
	# shield hấp thụ trước HP
	if tgt.shield > 0 and dmg > 0:
		var absorbed := mini(tgt.shield, dmg)
		tgt.shield -= absorbed
		dmg -= absorbed
	tgt.hp = maxi(0, tgt.hp - dmg)
	result.total_damage += dmg
	if src.lifesteal > 0.0 and dmg > 0:
		src.hp = mini(src.max_hp, src.hp + int(round(dmg * src.lifesteal)))
	_record_hit(tick, "hit", src.id, tgt.id, dmg, hit["crit"], str(def.id))
	if tgt.is_boss:
		_on_boss_hit(src, tgt, def, float(dmg), tick)
	if tgt.hp == 0:
		_record_hit(tick, "death", src.id, tgt.id, 0, false, str(def.id))
		if tgt.is_minion:
			tgt.boss_state = null
			for boss in _bosses:
				(boss.boss_state as BossRuntimeState).minions_alive.erase(tgt.id)
		if tgt.source_enemy_id != "" and tgt.source_enemy_id not in result.dead_enemy_ids:
			result.dead_enemy_ids.append(tgt.source_enemy_id)

## Pipeline damage Damage→Crit→Def→Resist→(weak-point)→(break-mult). PUBLIC để test.
func compute_hit(src: SimCombatant, tgt: SimCombatant, def: SkillDef, rng: RandomNumberGenerator) -> Dictionary:
	var atk := int(round(src.attack * def.power_mult))
	var base := DamageFormula.compute(atk, tgt.defense, src.crit_chance, src.crit_damage, rng)
	var dmg := float(base["damage"])
	dmg *= (1.0 - clampf(tgt.resist, 0.0, 0.9))                       # Resist
	if tgt.is_boss and def.weak_point_id != &"" and tgt.boss_def != null \
			and tgt.boss_def.has_weak_point(def.weak_point_id):       # weak-point
		dmg *= (1.0 + tgt.boss_def.weak_point_bonus(def.weak_point_id))
	dmg *= tgt.dmg_taken_mult                                          # break-stun nhận nhiều damage hơn
	return {"damage": maxi(1, int(round(dmg))), "crit": base["crit"]}

func _apply_cc(src: SimCombatant, tgt: SimCombatant, def: SkillDef, tick: int) -> void:
	if def.cc_type != Enums.CcType.STUN:
		return
	if tgt.is_casting() and tgt.casting_skill.def.interruptible:
		interrupt(tgt, tick)                                          # hard-CC ngắt cast
	if not tgt.stun_immune:
		tgt.stun_until = maxi(tgt.stun_until, tick + int(round(def.cc_duration_sec / DT)))
		_record_hit(tick, "stun", src.id, tgt.id, int(def.cc_duration_sec * 1000), false, str(def.id))

# --- boss hooks (gọi từ BossController / _deal) ----------------------------
func _on_boss_hit(src: SimCombatant, boss: SimCombatant, def: SkillDef, dmg: float, tick: int) -> void:
	var st: BossRuntimeState = boss.boss_state
	if st == null:
		return
	var hero_id := src.source_hero_id if src.source_hero_id != "" else src.id
	st.add_contribution(hero_id, dmg, 0.0, 0)
	st.add_threat(hero_id, dmg * def.threat_gen)
	if boss.boss_def.break_max > 0.0 and def.break_damage > 0.0:
		st.break_value += def.break_damage
		if st.break_value >= boss.boss_def.break_max:
			_boss_ctrl.trigger_break(self, boss, tick)

## Ngắt skill đang cast (break / hard-CC). Telemetry qua on_boss_event.
func interrupt(c: SimCombatant, tick: int) -> void:
	if not c.is_casting():
		return
	result.interrupts += 1
	_record_cmd(tick, c.id, "interrupt", c.cast_target_id, str(c.casting_skill.def.id))
	if c.is_boss:
		on_boss_event("interrupted", c, {"skill": str(c.casting_skill.def.id)})
	c.clear_cast()

## Sát thương hazard lên toàn phe hero (phase boss bật hazard).
func apply_hazard(dps: int, tick: int) -> void:
	for c in _units:
		if c.team == 0 and c.is_alive():
			c.hp = maxi(0, c.hp - dps)
			_record_hit(tick, "hazard", "boss", c.id, dps, false, "hazard")

## Xếp minion vào hàng chờ spawn (1 con/tick — KHÔNG mass-spawn 1 frame, build-boss Perf).
func spawn_minions(boss: SimCombatant, group_id: String) -> void:
	var group: Array = Database.get_boss_minion_group(group_id)
	var st: BossRuntimeState = boss.boss_state
	var base := "%s_m%d" % [group_id, _tick]
	for i in group.size():
		var ed: EnemyData = Database.get_enemy(str(group[i]))
		if ed != null:
			var uid := "%s_%d" % [base, i]
			_pending_minions.append({"enemy": ed, "uid": uid})
			if st != null:
				st.minions_alive.append(uid)
	if st != null:
		on_boss_event("minion_spawned", boss, {"group": group_id, "count": group.size()})

func _spawn_pending() -> void:
	if _pending_minions.is_empty():
		return
	var m: Dictionary = _pending_minions.pop_front()          # 1 con/tick
	var c := SimCombatant.from_enemy(m["enemy"], 1, m["uid"])
	c.is_minion = true
	_units.append(c)
	_units.sort_custom(func(x, y): return x.id < y.id)

# --- targeting -------------------------------------------------------------
func _pick_target(c: SimCombatant, def: SkillDef) -> SimCombatant:
	match def.target_mode:
		Enums.SkillTarget.SELF:
			return c
		Enums.SkillTarget.LOWEST_HP_ALLY:
			return _lowest_hp(_allies_of(c))
		Enums.SkillTarget.RANDOM_ENEMY:
			var es := _enemies_of(c)
			return es[_rng.randi() % es.size()] if es.size() > 0 else null
		Enums.SkillTarget.HIGHEST_THREAT:
			return _highest_threat_enemy(c)
		_:
			return _lowest_hp(_enemies_of(c))

## Enemy còn sống của c. Nếu c là phe hero và còn minion -> KHÔNG nhắm boss (giết minion trước).
func _enemies_of(c: SimCombatant) -> Array:
	var out: Array = []
	var has_minion := false
	if c.team == 0:
		for u in _units:
			if u.team == 1 and u.is_alive() and u.is_minion:
				has_minion = true; break
	for u in _units:
		if u.team != c.team and u.is_alive():
			if has_minion and u.is_boss:
				continue
			out.append(u)
	return out

func _allies_of(c: SimCombatant) -> Array:
	var out: Array = []
	for u in _units:
		if u.team == c.team and u.is_alive():
			out.append(u)
	return out

func _lowest_hp(arr: Array) -> SimCombatant:
	var best: SimCombatant = null
	for u in arr:
		if best == null or u.hp < best.hp or (u.hp == best.hp and u.id < best.id):
			best = u
	return best

func _highest_threat_enemy(c: SimCombatant) -> SimCombatant:
	if not c.is_boss or c.boss_state == null:
		return _lowest_hp(_enemies_of(c))
	var top := (c.boss_state as BossRuntimeState).top_threat_hero()
	if top != "":
		for u in _units:
			if u.team == 0 and u.is_alive() and (u.source_hero_id == top or u.id == top):
				return u
	return _lowest_hp(_enemies_of(c))

# --- helpers ---------------------------------------------------------------
func _find(id: String) -> SimCombatant:
	for u in _units:
		if u.id == id:
			return u
	return null

func _team_alive(team: int) -> int:
	var n := 0
	for u in _units:
		if u.team == team and u.is_alive():
			n += 1
	return n

func _team_hp(team: int) -> int:
	var s := 0
	for u in _units:
		if u.team == team:
			s += maxi(0, u.hp)
	return s

func _team_max_hp(team: int) -> int:
	var s := 0
	for u in _units:
		if u.team == team:
			s += u.max_hp
	return s

func _track_heal(src: SimCombatant, amt: int) -> void:
	if _bosses.is_empty() or amt <= 0:
		return
	var st: BossRuntimeState = _bosses[0].boss_state
	if st != null and src.source_hero_id != "":
		st.add_contribution(src.source_hero_id, 0.0, float(amt), 0)
		st.add_threat(src.source_hero_id, float(amt) * 0.5)   # heal cũng sinh threat (giảm)

func on_boss_event(kind: String, boss: SimCombatant, data: Dictionary) -> void:
	match kind:
		"enraged": result.enrage_activated = true
		"break": result.breaks += 1
	if _record:
		result.command_stream.append({"tick": _tick, "actor": boss.id, "cmd": "boss_" + kind, "data": data})

func _record_hit(tick: int, type: String, src: String, tgt: String, value: int, crit: bool, skill: String) -> void:
	result.timeline.append({"t": float(tick + 1) * DT, "type": type, "src": src, "tgt": tgt, "value": value, "crit": crit, "skill": skill})

func _record_cmd(tick: int, actor: String, cmd: String, target: String, skill: String) -> void:
	if _record:
		result.command_stream.append({"tick": tick, "actor": actor, "cmd": cmd, "target": target, "skill": skill})

func _finalize() -> void:
	var a0 := _team_alive(0)
	var a1 := _team_alive(1)
	if a1 == 0 and a0 > 0:
		result.winner = 0
	elif a0 == 0 and a1 > 0:
		result.winner = 1
	else:
		result.timed_out = true
		result.winner = 0 if _team_hp(0) >= _team_hp(1) else 1    # timeout -> nhiều HP hơn thắng (tie->hero)
	result.hp_left_pct[0] = float(_team_hp(0)) / float(maxi(1, _team_max_hp(0)))
	result.hp_left_pct[1] = float(_team_hp(1)) / float(maxi(1, _team_max_hp(1)))
	for u in _units:
		result.survivors_hp[u.id] = u.hp
		if u.source_hero_id != "":
			result.hero_hp_after[u.source_hero_id] = u.hp
	for boss in _bosses:
		var st: BossRuntimeState = boss.boss_state
		if st != null:
			st.current_hp = float(boss.hp)
			result.contribution = st.contribution.duplicate(true)
			result.boss_defeated = boss.hp == 0
