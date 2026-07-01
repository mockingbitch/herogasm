extends Node
## WorldBossService (autoload) — boss-of-the-day theo TimeService.day_of_week (Game Time, KHÔNG OS
## time — multiplayer.md). Boss "owns state" (1 BossRuntimeState). Event machine ANNOUNCED→ACTIVE→
## WON/FAILED→COOLDOWN. Mỗi engage = 1 trận BattleSim tiếp nối HP; contribution cộng dồn cả tuần.
## Reward chia theo contribution 1 lần (BossReward). PlayerProfile là chủ save (export/import world).

const ENGAGE_TICKS := 5400               # trần 9 phút/engage (world boss 5-15 min, BOSS.md)

var current: BossRuntimeState = null
var _def: BossDef = null

func _ready() -> void:
	import_world(PlayerProfile.world_state())

func boss_of_day() -> String:
	return Database.world_boss_for_day(TimeService.day_of_week())

func is_active() -> bool:
	return current != null and current.event_state == Enums.BossEventState.ACTIVE

func active_def() -> BossDef:
	return _def

# --- event lifecycle ------------------------------------------------------
## Bắt đầu sự kiện world boss (mặc định boss-of-day). Reset state + cửa sổ tuần.
func start_event(boss_def_id: String = "") -> bool:
	var did := boss_def_id if boss_def_id != "" else boss_of_day()
	var bdef: BossDef = Database.get_boss_def(did)
	if bdef == null:
		return false
	_def = bdef
	var st := BossRuntimeState.new()
	st.boss_id = StringName("wb_%d" % TimeService.game_day())
	st.boss_def_id = bdef.id
	st.max_hp = float(bdef.max_hp)
	st.current_hp = float(bdef.max_hp)
	st.event_state = Enums.BossEventState.ACTIVE
	st.active_from_day = TimeService.game_day()
	st.active_to_day = st.active_from_day + 7
	st.spawn_tick = TimeService.get_tick()
	current = st
	Telemetry.log_event("Boss", "boss_spawned", {"boss": did, "hp": bdef.max_hp})
	EventBus.world_boss_spawned.emit(str(bdef.id))
	PlayerProfile.save()
	return true

## 1 lượt đánh boss (trận BattleSim tiếp nối HP). Trả summary + đã cộng dồn contribution.
func engage(seed_val: int = -1) -> Dictionary:
	if not is_active() or _def == null:
		return {"ok": false, "reason": "no_event"}
	var team := PlayerProfile.active_team(5)
	if team.is_empty():
		return {"ok": false, "reason": "no_team"}
	# transient per-engage (giữ HP + contribution; xoá minion/break/enrage của lượt trước)
	current.minions_alive.clear()
	current.break_value = 0.0
	current.enrage_active = false
	var seed_used := seed_val if seed_val >= 0 else RandomService.randi()

	var heroes: Array = []
	var ctx := PlayerProfile.team_context()
	for h in team:
		(h as HeroInstance).team_context = ctx
		var c := SimCombatant.from_hero(h, 0)
		c.hp = c.max_hp                       # raid instance — không rút HP sống
		heroes.append(c)
	var boss := BossController.make_combatant(_def, Database.boss_phases(_def), current)
	var sim := BattleSim.new()
	var res := sim.simulate(heroes, [boss], seed_used, ENGAGE_TICKS)
	# state đã cập nhật (current_hp, contribution) trong sim._finalize

	for pidx in res.phases_entered:
		EventBus.world_boss_phase_changed.emit(str(_def.id), int(pidx))
		Telemetry.log_event("Boss", "boss_phase_changed", {"boss": str(_def.id), "phase": pidx})
	if res.enrage_activated:
		Telemetry.log_event("Boss", "boss_enraged", {"boss": str(_def.id)})
	if res.interrupts > 0:
		Telemetry.log_event("Boss", "boss_interrupted", {"count": res.interrupts})
	if res.breaks > 0:
		Telemetry.log_event("Boss", "boss_break", {"count": res.breaks})

	var defeated := current.current_hp <= 0.0
	if defeated:
		current.event_state = Enums.BossEventState.WON
		Telemetry.log_event("Boss", "boss_defeated", {"boss": str(_def.id), "participants": current.contribution.size()})
		EventBus.world_boss_ended.emit(str(_def.id), Enums.BossEventState.WON)
	PlayerProfile.save()
	return {"ok": true, "defeated": defeated, "boss_hp_pct": current.hp_pct(),
		"phases": res.phases_entered, "enraged": res.enrage_activated,
		"breaks": res.breaks, "interrupts": res.interrupts, "result": res, "seed": seed_used}

## Kết thúc sự kiện thất bại (hết cửa sổ tuần chưa hạ boss). Hệ quả nhẹ: boss về mạnh hơn (story).
func fail_event() -> void:
	if current == null:
		return
	current.event_state = Enums.BossEventState.FAILED
	Telemetry.log_event("Boss", "boss_failed", {"boss": str(current.boss_def_id)})
	EventBus.world_boss_ended.emit(str(current.boss_def_id), Enums.BossEventState.FAILED)
	PlayerProfile.save()

# --- contribution board + reward-once -------------------------------------
func contribution_board() -> Array:
	return BossReward.board(current) if current != null else []

## Chia thưởng theo contribution 1 lần. Từ chối nếu chưa WON hoặc đã nhận.
func claim_rewards() -> Dictionary:
	if current == null or current.event_state != Enums.BossEventState.WON:
		return {"ok": false, "reason": "not_won"}
	var summary := BossReward.distribute(_def, current, PlayerProfile)
	if bool(summary.get("ok", false)):
		current.event_state = Enums.BossEventState.COOLDOWN
		Telemetry.log_event("Boss", "reward_claimed", {"boss": str(_def.id),
			"gold": summary.get("total_gold", 0), "honor": summary.get("total_honor", 0)})
		PlayerProfile.save()
	return summary

# --- save bridge ----------------------------------------------------------
func export_world() -> Dictionary:
	return {"world_boss": current.to_dict()} if current != null else {}

func import_world(d: Dictionary) -> void:
	var wb = d.get("world_boss", {})
	if typeof(wb) == TYPE_DICTIONARY and not wb.is_empty():
		current = BossRuntimeState.from_dict(wb)
		_def = Database.get_boss_def(str(current.boss_def_id))
	else:
		current = null                            # world block rỗng (wipe/không có boss) -> reset
		_def = null
