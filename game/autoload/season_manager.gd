extends Node
## SeasonManager (autoload) — vòng đời Season (P5): start/rollover theo Game Time (offline-safe).
## Điều phối MetaRotation + BattlePass + SeasonalShop/Currency + RankReset + Events + WorldEvolution.
## Season = biến dị Abyss = story arc + seasonal boss + event + meta rotation + battle pass + rank reset.

var _active: SeasonDef = null
var _start_day: int = 0
var _meta := MetaRotationService.new()

func _ready() -> void:
	import_world(PlayerProfile.world_state())

func active_season() -> SeasonDef:
	return _active

func is_season_active() -> bool:
	return _active != null

func meta_rotation() -> MetaRotationService:
	return _meta

func get_season() -> Resource:
	return _active

# --- lifecycle -------------------------------------------------------------
## Bắt đầu season. Áp meta rotation (validate), init battle pass, khởi động event khớp overlap.
func start_season(season_id: String) -> bool:
	var def: SeasonDef = Database.get_season_def(season_id)
	if def == null:
		return false
	if not MetaRotationValidator.is_valid(def.meta_rotation):
		push_error("SeasonManager: meta_rotation không hợp lệ (%s)" % season_id)
		return false
	_active = def
	_start_day = TimeService.game_day()
	_meta.set_rotation(def.meta_rotation)
	var bp: BattlePassDef = Database.get_battle_pass_def(str(def.battle_pass_id))
	if bp != null:
		BattlePassService.ensure(bp)
	for eid in def.event_ids:
		EventManager.start_event(str(eid))       # overlap rule tự lọc; phần dư start sau
	Telemetry.log_event("Season", "season_started", {"season": season_id, "number": def.number})
	EventBus.season_started.emit(season_id)
	PlayerProfile.save()
	return true

func time_remaining_days() -> int:
	if _active == null:
		return 0
	return maxi(0, _active.duration_days - (TimeService.game_day() - _start_day))

func should_rollover() -> bool:
	return _active != null and time_remaining_days() <= 0

## Kết thúc season: purge seasonal currency, gỡ meta, reset rank, kết event, rollover season kế.
func rollover() -> void:
	if _active == null:
		return
	var ended_id := str(_active.id)
	if _active.seasonal_currency_id != &"":
		SeasonalShopService.expire_currency(str(_active.seasonal_currency_id))
	_meta.clear()
	EventManager.end_all()
	RankResetService.reset(_active.rank_reset_policy)
	Telemetry.log_event("Season", "season_ended", {"season": ended_id})
	EventBus.season_ended.emit(ended_id)
	var nxt := str(_active.next_season_id)
	_active = null
	if nxt != "" and Database.get_season_def(nxt) != null:
		start_season(nxt)
	else:
		PlayerProfile.save()

# --- save bridge -----------------------------------------------------------
func export_world() -> Dictionary:
	if _active == null:
		return {"season": {}}
	return {"season": {"season_id": str(_active.id), "start_day": _start_day}}

func import_world(d: Dictionary) -> void:
	var s = d.get("season", {})
	if typeof(s) != TYPE_DICTIONARY or s.is_empty():
		_active = null                            # world block rỗng (wipe) -> gỡ season + meta
		_meta.clear()
		return
	var def: SeasonDef = Database.get_season_def(str(s.get("season_id", "")))
	if def == null:
		return
	_active = def
	_start_day = int(s.get("start_day", TimeService.game_day()))
	if MetaRotationValidator.is_valid(def.meta_rotation):
		_meta.set_rotation(def.meta_rotation)
