extends Node
## ArenaService (autoload) — Đấu Trường Bot async vs snapshot đã lưu. Trận 90s auto (900 tick@10Hz),
## timeout = nhiều HP% hơn thắng. MMR-lite + Honor (source/sink). Quota 10 lượt/game-day.
## P4: đối thủ = arena_bot_pool (Database). P6 chỉ thay nguồn snapshot bằng Net (ID-based sẵn).
## PlayerProfile là chủ save; service export/import qua world block.

const QUOTA_PER_DAY := 10
const MMR_BAND := 300
const MATCH_TICKS := 900
const HONOR_WIN := 30
const HONOR_LOSS := 8
const HONOR_STREAK_BONUS := 10           # +honor mỗi mốc streak (source đa dạng, PVP.md)

var mmr: int = MmrService.BASE
var quota_used: int = 0
var quota_day: int = -1
var win_streak: int = 0
var defense: ArenaSnapshot = null        # đội phòng thủ của người chơi (freeze)
var _replays: Dictionary = {}            # replay_id -> ReplayData
var _replay_seq: int = 0
var last_result: ArenaMatchResult = null

func _ready() -> void:
	import_world(PlayerProfile.world_state())
	_refresh_defense()

# --- matchmaking ----------------------------------------------------------
## Đối thủ MMR gần (±band), sắp theo độ chênh nhỏ nhất. Nới band nếu thiếu.
func find_opponents(limit: int = 5) -> Array:
	var pool: Array = Database.arena_bot_pool.duplicate()
	var band := MMR_BAND
	var out: Array = []
	while out.is_empty() and band <= 2000:
		out = pool.filter(func(s): return absi(int(s.get("mmr", 1000)) - mmr) <= band)
		band += 300
	out.sort_custom(func(a, b): return absi(int(a.get("mmr", 0)) - mmr) < absi(int(b.get("mmr", 0)) - mmr))
	return out.slice(0, limit)

func can_fight() -> bool:
	_roll_quota()
	return quota_used < QUOTA_PER_DAY

# --- fight (async vs snapshot) --------------------------------------------
## Đánh 1 trận với snapshot đối thủ (Dictionary). Trả {ok, reason, result, replay}.
func fight(opponent: Dictionary) -> Dictionary:
	_roll_quota()
	if quota_used >= QUOTA_PER_DAY:
		return {"ok": false, "reason": "no_quota"}
	var team := PlayerProfile.active_team(3)
	if team.is_empty():
		return {"ok": false, "reason": "no_team"}
	var atk_blocks := _freeze_attacker(team)
	var def_blocks: Array = opponent.get("heroes", [])
	var atk_form := "balanced_3"
	var def_form := str(opponent.get("formation_id", "balanced_3"))
	var seed_val := RandomService.randi()

	var res := _simulate(atk_blocks, atk_form, def_blocks, def_form, seed_val)
	var outcome := _outcome(res)
	var won := outcome == Enums.ArenaOutcome.WIN or outcome == Enums.ArenaOutcome.TIMEOUT_WIN

	var opp_mmr := int(opponent.get("mmr", 1000))
	var old_mmr := mmr
	mmr = MmrService.update(mmr, opp_mmr, won)
	win_streak = win_streak + 1 if won else 0
	var honor := _honor_for(won, win_streak)
	PlayerProfile.add_currency("honor", honor)

	var replay := _record_replay(atk_blocks, atk_form, def_blocks, def_form, seed_val, res.winner)
	var result := ArenaMatchResult.new()
	result.attacker_id = &"player"
	result.defender_snapshot_id = StringName(str(opponent.get("owner_profile_id", "")))
	result.outcome = outcome
	result.duration_ticks = res.duration_ticks
	result.attacker_hp_left_pct = res.team_hp_pct(0)
	result.defender_hp_left_pct = res.team_hp_pct(1)
	result.mmr_delta = mmr - old_mmr
	result.honor_gained = honor
	result.replay_id = StringName(replay.replay_id)
	last_result = result

	quota_used += 1
	Telemetry.log_event("Arena", "arena_match_finished", {"outcome": outcome, "duration": res.duration_ticks,
		"mmr_delta": result.mmr_delta, "honor": honor, "opp": str(result.defender_snapshot_id)})
	Telemetry.log_event("Arena", "honor_gained", {"amount": honor})
	if res.timed_out:
		Telemetry.log_event("Arena", "arena_timeout", {"a_hp": result.attacker_hp_left_pct, "d_hp": result.defender_hp_left_pct})
	EventBus.arena_match_finished.emit(result.to_dict())
	PlayerProfile.save()
	return {"ok": true, "result": result, "replay": replay}

func _simulate(atk_blocks: Array, atk_form: String, def_blocks: Array, def_form: String, seed_val: int) -> SimResult:
	var a := _build(atk_blocks, 0, atk_form)
	var b := _build(def_blocks, 1, def_form)
	var sim := BattleSim.new()
	return sim.simulate(a, b, seed_val, MATCH_TICKS)

func _build(blocks: Array, team: int, formation_id: String) -> Array:
	var out: Array = []
	for hb in blocks:
		if typeof(hb) == TYPE_DICTIONARY:
			out.append(SimCombatant.from_snapshot_hero(hb, team))
	FormationService.apply(out, Database.get_formation_def(formation_id))
	return out

func _freeze_attacker(team: Array) -> Array:
	var ctx := PlayerProfile.team_context()
	var out: Array = []
	for h in team:
		out.append(ArenaSnapshot.freeze_hero(h, ctx))
	return out

func _outcome(res: SimResult) -> int:
	if res.timed_out:
		return Enums.ArenaOutcome.TIMEOUT_WIN if res.winner == 0 else Enums.ArenaOutcome.TIMEOUT_LOSE
	return Enums.ArenaOutcome.WIN if res.winner == 0 else Enums.ArenaOutcome.LOSE

func _honor_for(won: bool, streak: int) -> int:
	var h := HONOR_WIN if won else HONOR_LOSS
	if won and streak > 0 and streak % 3 == 0:
		h += HONOR_STREAK_BONUS
	return h

# --- replay store ---------------------------------------------------------
func _record_replay(atk: Array, atk_form: String, def: Array, def_form: String, seed_val: int, winner: int) -> ReplayData:
	var r := ReplayData.new()
	r.replay_id = "rp_%d" % _replay_seq
	_replay_seq += 1
	r.seed = seed_val
	r.outcome = winner
	r.initial_state = {"team_a": atk, "team_b": def, "formation_a": atk_form,
		"formation_b": def_form, "max_ticks": MATCH_TICKS}
	_replays[r.replay_id] = r
	if _replays.size() > 20:                     # giữ 20 replay gần nhất (bounded)
		_replays.erase(_replays.keys()[0])
	Telemetry.log_event("Arena", "replay_saved", {"replay_id": r.replay_id})
	return r

func get_replay(replay_id: String) -> ReplayData:
	return _replays.get(replay_id)

## Xem lại trận (phát qua BattleSim) — VIEW đọc result.timeline.
func watch(replay_id: String) -> SimResult:
	var r: ReplayData = _replays.get(replay_id)
	return ReplayPlayer.play(r) if r != null else null

# --- honor sink -----------------------------------------------------------
## Tiêu Honor (shop material/rune/cosmetic). Trả true nếu đủ. Sink cân bằng nguồn (economy.md).
func spend_honor(amount: int) -> bool:
	if PlayerProfile.honor() < amount or amount <= 0:
		return false
	PlayerProfile.add_currency("honor", -amount)
	Telemetry.log_event("Arena", "honor_spent", {"amount": amount})
	PlayerProfile.save()
	return true

# --- quota (reset theo game-day) ------------------------------------------
func _roll_quota() -> void:
	var d := TimeService.game_day()
	if d != quota_day:
		quota_day = d
		quota_used = 0

func _refresh_defense() -> void:
	if defense == null:
		var team := PlayerProfile.active_team(3)
		if not team.is_empty():
			defense = ArenaSnapshot.capture("player", team, "balanced_3", mmr, TimeService.get_tick())

## Cập nhật lại đội phòng thủ (gọi sau khi chỉnh đội — freeze stat hiện tại).
func capture_defense() -> void:
	var team := PlayerProfile.active_team(3)
	if not team.is_empty():
		defense = ArenaSnapshot.capture("player", team, "balanced_3", mmr, TimeService.get_tick())
		PlayerProfile.save()

# --- save bridge ----------------------------------------------------------
func export_world() -> Dictionary:
	return {"arena": {"mmr": mmr, "quota_used": quota_used, "quota_day": quota_day,
		"win_streak": win_streak, "defense": defense.to_dict() if defense != null else {}}}

func import_world(d: Dictionary) -> void:
	var a = d.get("arena", {})
	if typeof(a) != TYPE_DICTIONARY:
		return
	mmr = maxi(0, int(a.get("mmr", MmrService.BASE)))
	quota_used = int(a.get("quota_used", 0))
	quota_day = int(a.get("quota_day", -1))
	win_streak = int(a.get("win_streak", 0))
	var dd = a.get("defense", {})
	if typeof(dd) == TYPE_DICTIONARY and not dd.is_empty():
		defense = ArenaSnapshot.from_dict(dd)
