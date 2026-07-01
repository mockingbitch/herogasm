class_name BossController
extends RefCounted
## Bộ não boss (composition) — điều phối phase/enrage/break/minion/hazard mỗi bước tick.
## THUẦN logic (không Node): BattleSim gọi pre_tick(). State ở BossRuntimeState + SimCombatant.
## rules/ai.md: boss đổi hành vi (AI/skill), KHÔNG chỉ tăng HP. Mỗi boss ≥1 cơ chế độc quyền.

## Dựng SimCombatant boss từ def + phases + state (hp nối tiếp nếu World Boss re-engage).
static func make_combatant(def: BossDef, phases: Array, state: BossRuntimeState) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = "boss_" + str(def.id)
	c.team = 1
	c.display_name = def.display_name
	c.is_boss = true
	c.max_hp = def.max_hp
	c.hp = int(state.current_hp) if state.current_hp > 0.0 else def.max_hp
	c.attack = def.attack
	c.defense = def.defense
	c.resist = def.resist
	c.attack_interval = def.attack_interval
	c.crit_chance = 0.0
	c.crit_damage = 1.5
	c.base_stats = {"attack": def.attack, "defense": def.defense, "attack_interval": def.attack_interval}
	c.boss_def = def
	c.boss_phases = phases
	c.boss_state = state
	c.add_skill(SkillFactory.basic_attack(def.attack_interval))   # phase rebuild sẽ thay; giữ nếu phase rỗng
	return c

## Gọi 1 lần khi setup: vào phase khởi đầu, ghi spawn_tick, bơm skills phase 0.
func on_setup(sim: BattleSim, boss: SimCombatant) -> void:
	var st: BossRuntimeState = boss.boss_state
	st.spawn_tick = 0
	st.max_hp = float(boss.max_hp)
	if st.current_hp <= 0.0:
		st.current_hp = float(boss.hp)
	st.current_phase_idx = 0
	st.enrage_active = boss.stun_immune  # (thường false)
	_apply_phase(sim, boss, 0)

## Mỗi tick trước khi boss hành động: enrage -> break reset -> phase check -> hazard -> tank_time.
func pre_tick(sim: BattleSim, boss: SimCombatant, tick: int) -> void:
	var st: BossRuntimeState = boss.boss_state
	st.current_hp = float(boss.hp)
	_check_enrage(sim, boss, tick)
	_check_break_reset(boss, tick)
	_check_phase(sim, boss, tick)
	_apply_hazard(sim, boss, tick)
	_track_tank_time(boss)

# --- enrage (hết giờ -> atk +100%, spd +50%, miễn stun) — BOSS.md -----------
func _check_enrage(sim: BattleSim, boss: SimCombatant, tick: int) -> void:
	var st: BossRuntimeState = boss.boss_state
	if st.enrage_active or boss.boss_def.enrage_timer_sec <= 0.0:
		return
	if float(tick - st.spawn_tick) * BattleSim.DT < boss.boss_def.enrage_timer_sec:
		return
	st.enrage_active = true
	boss.stun_immune = true
	boss.stun_until = -1                       # xoá stun đang chịu
	boss.attack = int(round(boss.attack * 2.0))
	boss.attack_interval = maxf(0.1, boss.attack_interval / 1.5)
	sim.on_boss_event("enraged", boss, {"tick": tick})

# --- break gauge (đầy -> stun boss + nhận nhiều damage; hết cửa sổ -> reset) --
func _check_break_reset(boss: SimCombatant, tick: int) -> void:
	if boss.dmg_taken_mult > 1.0 and tick > boss.stun_until:
		boss.dmg_taken_mult = 1.0
		boss.boss_state.break_value = 0.0

## BattleSim gọi khi break_value chạm ngưỡng (từ đòn đánh) -> kích hoạt break.
func trigger_break(sim: BattleSim, boss: SimCombatant, tick: int) -> void:
	if boss.dmg_taken_mult > 1.0:
		return                                  # đang trong cửa sổ break
	boss.stun_until = tick + int(round(boss.boss_def.break_stun_sec / BattleSim.DT))
	boss.dmg_taken_mult = boss.boss_def.break_dmg_taken_mult
	if boss.is_casting():
		sim.interrupt(boss, tick)               # break huỷ skill đang cast
	sim.on_boss_event("break", boss, {"tick": tick})

# --- phase transition ------------------------------------------------------
func _check_phase(sim: BattleSim, boss: SimCombatant, tick: int) -> void:
	var st: BossRuntimeState = boss.boss_state
	var target := st.current_phase_idx
	for idx in range(st.current_phase_idx + 1, boss.boss_phases.size()):
		if _trigger_met(boss, boss.boss_phases[idx], tick):
			target = idx                        # nhảy tới phase cao nhất thỏa (vượt nhiều ngưỡng 1 đòn)
	if target > st.current_phase_idx:
		_apply_phase(sim, boss, target)

func _trigger_met(boss: SimCombatant, phase: BossPhaseDef, tick: int) -> bool:
	var st: BossRuntimeState = boss.boss_state
	match phase.trigger_type:
		Enums.BossTrigger.HP_PCT:
			return boss.hp_pct_of() <= phase.trigger_value
		Enums.BossTrigger.TIME_ELAPSED:
			return float(tick - st.spawn_tick) * BattleSim.DT >= phase.trigger_value
		Enums.BossTrigger.MINION_COUNT:
			return st.minions_alive.size() <= int(phase.trigger_value)
		Enums.BossTrigger.BREAK_FULL:
			return st.break_value >= boss.boss_def.break_max and boss.boss_def.break_max > 0.0
	return false

func _apply_phase(sim: BattleSim, boss: SimCombatant, idx: int) -> void:
	var st: BossRuntimeState = boss.boss_state
	st.current_phase_idx = idx
	var phase: BossPhaseDef = boss.boss_phases[idx] if idx < boss.boss_phases.size() else null
	if phase == null:
		return
	# stat_mult tính theo BASE (không cộng dồn qua nhiều phase)
	boss.attack = int(round(float(boss.base_stats["attack"]) * float(phase.stat_mult.get("attack", 1.0))))
	boss.defense = int(round(float(boss.base_stats["defense"]) * float(phase.stat_mult.get("defense", 1.0))))
	boss.attack_interval = maxf(0.1, float(boss.base_stats["attack_interval"]) * float(phase.stat_mult.get("attack_interval", 1.0)))
	if st.enrage_active:                         # giữ enrage khi đổi phase
		boss.attack = int(round(boss.attack * 2.0))
		boss.attack_interval = maxf(0.1, boss.attack_interval / 1.5)
	# rebuild skills: basic-attack + skill pool của phase
	boss.skills.clear()
	boss.add_skill(SkillFactory.basic_attack(boss.attack_interval))
	for sid in phase.skill_ids:
		var sd: SkillDef = Database.get_skill_def(str(sid))
		if sd != null:
			boss.add_skill(sd)
	boss.clear_cast()
	if phase.summon_group_id != &"":
		sim.spawn_minions(boss, str(phase.summon_group_id))
	if idx > 0:
		if idx not in sim.result.phases_entered:
			sim.result.phases_entered.append(idx)
		sim.on_boss_event("phase", boss, {"phase": idx})

# --- hazard (dmg/giây lên toàn phe hero khi phase bật hazard) ---------------
func _apply_hazard(sim: BattleSim, boss: SimCombatant, tick: int) -> void:
	var st: BossRuntimeState = boss.boss_state
	var phase: BossPhaseDef = boss.boss_phases[st.current_phase_idx] if st.current_phase_idx < boss.boss_phases.size() else null
	if phase == null or phase.hazard_dps <= 0.0:
		return
	if tick % 10 != 0:                           # 1 lần/giây (10 tick)
		return
	sim.apply_hazard(int(round(phase.hazard_dps)), tick)

# --- tank_time: hero đang bị boss nhắm (top threat) được cộng thời gian tank --
func _track_tank_time(boss: SimCombatant) -> void:
	var st: BossRuntimeState = boss.boss_state
	var top := st.top_threat_hero()
	if top != "":
		st.add_contribution(top, 0.0, 0.0, 1)
