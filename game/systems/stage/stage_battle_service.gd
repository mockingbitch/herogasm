class_name StageBattleService
extends RefCounted
## Stage "3/3": chạy BattleSim HEADLESS SEEDED với đội hình cố định. Wave tuần tự (HP nối tiếp),
## wave cuối có thể là boss. Chấm sao theo StageDef.star_rules. First-clear/repeat reward 1 lần.
## KHÔNG mutate HeroInstance sống (stage dùng snapshot full-HP) — độc lập vòng đời living-world.

## Chạy stage. seed<0 -> derive từ stage_id (tái lập). Trả summary + đã cộng thưởng.
static func run(stage_id: String, formation_id: String = "balanced_3", seed_val: int = -1) -> Dictionary:
	var sdef: StageDef = Database.get_stage_def(stage_id)
	if sdef == null:
		return {"ok": false, "reason": "no_stage"}
	var team := PlayerProfile.active_team(sdef.team_size)
	if team.is_empty():
		return {"ok": false, "reason": "no_team"}
	var seed_used := seed_val if seed_val >= 0 else absi(str(stage_id).hash())
	var heroes := _build_team(team, formation_id)

	var won := true
	var total_ticks := 0
	var waves: Array = sdef.enemy_waves.duplicate(true)
	for wi in waves.size():
		var res := _run_wave(heroes, _enemy_wave(waves[wi], "%s_w%d" % [stage_id, wi]), seed_used + wi, false)
		total_ticks += res.duration_ticks
		if not res.player_won():
			won = false; break
	if won and sdef.boss_def_id != &"":
		var bres := _run_boss_wave(heroes, str(sdef.boss_def_id), seed_used + 100)
		total_ticks += bres.duration_ticks
		if not bres.player_won():
			won = false

	var any_ko := false
	for c in heroes:
		if c.hp <= 0:
			any_ko = true
	var duration := float(total_ticks) * BattleSim.DT
	var stars := sdef.score_stars(won, duration, any_ko)
	var summary := _reward(sdef, won, stars)
	summary["duration"] = duration
	summary["seed"] = seed_used
	Telemetry.log_event("Stage", "stage_cleared" if won else "stage_failed",
		{"stage": stage_id, "stars": stars, "ttk": duration})
	if won:
		EventBus.stage_cleared.emit(stage_id, stars)
	return summary

# --- build ----------------------------------------------------------------
static func _build_team(team: Array, formation_id: String) -> Array:
	var out: Array = []
	for h in team:
		(h as HeroInstance).team_context = PlayerProfile.team_context()
		var c := SimCombatant.from_hero(h, 0)
		c.hp = c.max_hp                       # stage: full HP snapshot (không rút HP sống)
		out.append(c)
	FormationService.apply(out, Database.get_formation_def(formation_id))
	return out

static func _enemy_wave(ids: Array, prefix: String) -> Array:
	var out: Array = []
	for i in ids.size():
		var ed: EnemyData = Database.get_enemy(str(ids[i]))
		if ed != null:
			out.append(SimCombatant.from_enemy(ed, 1, "%s_e%d" % [prefix, i]))
	return out

static func _run_wave(heroes: Array, enemies: Array, seed_val: int, _boss: bool) -> SimResult:
	for c in heroes:
		c.reset_combat_state()
	var sim := BattleSim.new()
	return sim.simulate(heroes, enemies, seed_val)

static func _run_boss_wave(heroes: Array, boss_def_id: String, seed_val: int) -> SimResult:
	for c in heroes:
		c.reset_combat_state()
	var bdef: BossDef = Database.get_boss_def(boss_def_id)
	var st := BossRuntimeState.new()
	st.boss_def_id = bdef.id
	var boss := BossController.make_combatant(bdef, Database.boss_phases(bdef), st)
	var sim := BattleSim.new()
	return sim.simulate(heroes, [boss], seed_val, 3000)

# --- reward (first-clear 1 lần vs repeat) ----------------------------------
static func _reward(sdef: StageDef, won: bool, stars: int) -> Dictionary:
	var out := {"ok": true, "won": won, "stars": stars, "first_clear": false, "gold": 0, "gems": 0, "xp": 0}
	if not won:
		return out
	var sid := str(sdef.id)
	var is_first := PlayerProfile.record_stage_result(sid, stars)
	if is_first and not PlayerProfile.is_stage_first_claimed(sid):
		PlayerProfile.mark_stage_claimed(sid)
		PlayerProfile.add_gold(sdef.first_clear_gold)
		PlayerProfile.add_gems(sdef.first_clear_gems)
		out["first_clear"] = true
		out["gold"] = sdef.first_clear_gold
		out["gems"] = sdef.first_clear_gems
	else:
		PlayerProfile.add_gold(sdef.repeat_gold)
		out["gold"] = sdef.repeat_gold
		out["xp"] = sdef.repeat_xp
	PlayerProfile.save()
	return out
