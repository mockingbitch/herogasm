extends Node
## WorldEvolutionService (autoload) — đổi WorldState per-region theo OUTCOME boss/event của season.
## Đọc SeasonDef.world_evolution_rules, subscribe EventBus outcome, set flag, phát world_state_changed.
## STORY.md: World Boss sống → corruption; hạ → mở vùng mới. World scene P2 listen để đổi tint/NPC/shop.

var world_state: Dictionary = {}          # region -> {key: value}

func _ready() -> void:
	import_world(PlayerProfile.world_state())
	EventBus.world_boss_ended.connect(_on_world_boss_ended)
	EventBus.event_ended.connect(_on_event_ended)

func get_state(region: String, key: String, default_val = null) -> Variant:
	var r = world_state.get(region, {})
	return r.get(key, default_val) if typeof(r) == TYPE_DICTIONARY else default_val

func set_state(region: String, key: String, value) -> void:
	var r: Dictionary = world_state.get(region, {})
	if r.get(key) == value:
		return
	r[key] = value
	world_state[region] = r
	Telemetry.log_event("World", "world_state_changed", {"region": region, "key": key, "value": value})
	EventBus.world_state_changed.emit(region, key, value)

# --- outcome hooks ---------------------------------------------------------
func _on_world_boss_ended(boss_id: String, event_state: int) -> void:
	var trig := "boss_defeated" if event_state == Enums.BossEventState.WON else "boss_survived"
	_apply_rules(trig, {"boss_id": boss_id})

func _on_event_ended(event_id: String, success: bool) -> void:
	_apply_rules("event_success" if success else "event_fail", {"event_id": event_id})

## Áp mọi rule khớp trigger (và id nếu rule chỉ định) của season đang chạy.
func _apply_rules(trigger: String, ctx: Dictionary) -> void:
	if not has_node("/root/SeasonManager"):
		return
	var sdef: SeasonDef = SeasonManager.active_season()
	if sdef == null:
		return
	for rule in sdef.world_evolution_rules:
		if str(rule.get("trigger", "")) != trigger:
			continue
		var cond := str(rule.get("condition", ""))
		if cond != "" and cond != str(ctx.get("boss_id", "")) and cond != str(ctx.get("event_id", "")):
			continue
		set_state(str(rule.get("region", "")), str(rule.get("world_state_key", "")), rule.get("value", true))

# --- save bridge -----------------------------------------------------------
func export_world() -> Dictionary:
	return {"world_state": world_state}

func import_world(d: Dictionary) -> void:
	var ws = d.get("world_state", {})
	world_state = ws if typeof(ws) == TYPE_DICTIONARY else {}
