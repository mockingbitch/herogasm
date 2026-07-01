extends Node
## EventManager (autoload) — nơi DUY NHẤT start/stop event (events.md). Lifecycle qua scheduler chung
## (KHÔNG _process polling). Modifier tạm & REVERSIBLE (gỡ sạch khi event rời ACTIVE). Reward chống trùng.
## Overlap: tối đa 1 major + 2 medium + nhiều minor (build-events). Save active events (remaining/progress).

const TICK_INTERVAL := 1.0                # scheduler tick 1s game-time
const REWARD_WINDOW_SEC := 8.0

var _active: Array[EventRuntimeState] = []

func _ready() -> void:
	import_world(PlayerProfile.world_state())
	TimeService.register_slice(func(): tick(TICK_INTERVAL), TICK_INTERVAL)

# --- start / overlap -------------------------------------------------------
## Bắt đầu event. Trả {ok, reason}. Enforce overlap rule theo priority.
func start_event(event_id: String, _manual: bool = true) -> Dictionary:
	var def: EventDef = Database.get_event_def(event_id)
	if def == null:
		return {"ok": false, "reason": "no_def"}
	if _find(event_id) != null:
		return {"ok": false, "reason": "already_running"}
	if def.is_major() and _count_priority(EventDef.PRIORITY_MAJOR) >= 1:
		return {"ok": false, "reason": "major_overlap"}
	if def.is_medium() and _count_priority(EventDef.PRIORITY_MEDIUM) >= 2:
		return {"ok": false, "reason": "medium_overlap"}
	var st := EventRuntimeState.new()
	st.event_id = def.id
	Telemetry.log_event("Event", "event_scheduled", {"event": event_id})
	EventBus.event_scheduled.emit(event_id)
	if def.preparation_sec > 0.0:
		st.phase = Enums.EventPhase.PREPARATION
		st.remaining_time = def.preparation_sec
	else:
		_enter_active(st, def)
	_active.append(st)
	return {"ok": true}

# --- scheduler tick --------------------------------------------------------
## Advance mọi event 1 nhịp dt (giây game). Test gọi trực tiếp để tua nhanh.
func tick(dt: float) -> void:
	for st in _active:
		st.remaining_time -= dt
		if st.remaining_time > 0.0:
			continue
		match st.phase:
			Enums.EventPhase.PREPARATION:
				_enter_active(st, Database.get_event_def(str(st.event_id)))
			Enums.EventPhase.ACTIVE:
				_exit_active(st, true)
			Enums.EventPhase.REWARD:
				st.phase = Enums.EventPhase.COOLDOWN
				st.remaining_time = Database.get_event_def(str(st.event_id)).cooldown_sec
			Enums.EventPhase.COOLDOWN:
				st.phase = Enums.EventPhase.DONE
	_active = _active.filter(func(e): return e.phase != Enums.EventPhase.DONE)

func _enter_active(st: EventRuntimeState, def: EventDef) -> void:
	st.phase = Enums.EventPhase.ACTIVE
	st.remaining_time = def.duration_sec
	st.active_modifiers = def.modifiers.duplicate(true)
	_apply_mood_bonus(st.active_modifiers)
	Telemetry.log_event("Event", "event_started", {"event": str(def.id), "category": str(def.category)})
	EventBus.event_started.emit(str(def.id))

func _exit_active(st: EventRuntimeState, success: bool) -> void:
	st.active_modifiers = []                     # gỡ modifier -> reversible
	st.phase = Enums.EventPhase.REWARD
	st.remaining_time = REWARD_WINDOW_SEC
	Telemetry.log_event("Event", "event_ended", {"event": str(st.event_id), "success": success})
	EventBus.event_ended.emit(str(st.event_id), success)

# --- modifiers (reversible aggregate) --------------------------------------
## Hệ số nhân cho 1 target (gold_rate/loot_rate/exp_rate/monster_spawn_rate...) = 1 + Σ value active.
func modifier_multiplier(target: String) -> float:
	var total := 0.0
	for st in _active:
		if st.phase != Enums.EventPhase.ACTIVE:
			continue
		for m in st.active_modifiers:
			if str(m.get("target", "")) == target:
				total += float(m.get("value", 0.0))
	return 1.0 + total

## Mood bonus festival áp 1 lần khi vào ACTIVE (mood tự phân rã sau — không cần gỡ).
func _apply_mood_bonus(modifiers: Array) -> void:
	var bonus := 0.0
	for m in modifiers:
		if str(m.get("target", "")) == "mood_bonus":
			bonus += float(m.get("value", 0.0))
	if bonus <= 0.0:
		return
	for id in PlayerProfile.hero_ids:
		var h: HeroInstance = PlayerProfile.get_hero(id)
		if h != null:
			h.set_mood(h.mood + bonus)

# --- reward (chống trùng) --------------------------------------------------
func claim_reward(event_id: String) -> Dictionary:
	var st := _find(event_id)
	if st == null:
		return {"ok": false, "reason": "not_found"}
	if st.reward_claimed:
		return {"ok": false, "reason": "claimed"}
	var def: EventDef = Database.get_event_def(event_id)
	for r in def.rewards:
		PlayerProfile.grant_reward(r)
	st.reward_claimed = true
	Telemetry.log_event("Event", "event_reward_claimed", {"event": event_id})
	EventBus.event_reward_claimed.emit(event_id)
	PlayerProfile.save()
	return {"ok": true, "rewards": def.rewards}

# --- queries ---------------------------------------------------------------
func active_event_ids() -> Array:
	var out: Array = []
	for st in _active:
		if st.phase == Enums.EventPhase.ACTIVE:
			out.append(str(st.event_id))
	return out

func get_state(event_id: String) -> EventRuntimeState:
	return _find(event_id)

func end_all() -> void:
	for st in _active:
		if st.phase == Enums.EventPhase.ACTIVE:
			_exit_active(st, false)

func _count_priority(prio: int) -> int:
	var n := 0
	for st in _active:
		if st.phase != Enums.EventPhase.ACTIVE and st.phase != Enums.EventPhase.PREPARATION:
			continue
		var def: EventDef = Database.get_event_def(str(st.event_id))
		if def == null:
			continue
		if prio == EventDef.PRIORITY_MAJOR and def.is_major():
			n += 1
		elif prio == EventDef.PRIORITY_MEDIUM and def.is_medium():
			n += 1
	return n

func _find(event_id: String) -> EventRuntimeState:
	for st in _active:
		if str(st.event_id) == event_id:
			return st
	return null

# --- save bridge -----------------------------------------------------------
func export_world() -> Dictionary:
	var arr: Array = []
	for st in _active:
		arr.append(st.to_dict())
	return {"events": arr}

func import_world(d: Dictionary) -> void:
	_active.clear()
	var arr = d.get("events", [])
	if typeof(arr) == TYPE_ARRAY:
		for x in arr:
			if typeof(x) == TYPE_DICTIONARY:
				_active.append(EventRuntimeState.from_dict(x))
