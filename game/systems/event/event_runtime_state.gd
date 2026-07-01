class_name EventRuntimeState
extends RefCounted
## Runtime state 1 event (build-events schema). Serialize vào save (KHÔNG Node/Timer/Signal/UI).
## Modifier áp khi ACTIVE, gỡ khi rời ACTIVE (reversible). reward_claimed idempotent.

var event_id: StringName = &""
var phase: int = Enums.EventPhase.SCHEDULED
var remaining_time: float = 0.0        # thời gian còn ở phase hiện tại (giây game)
var progress: float = 0.0
var participants: Array = []
var contribution: Dictionary = {}
var reward_claimed: bool = false
var cooldown_remaining: float = 0.0
var active_modifiers: Array = []        # [{target, value}] đang áp (gỡ khi end)

func to_dict() -> Dictionary:
	return {"event_id": str(event_id), "phase": phase, "remaining_time": remaining_time,
		"progress": progress, "participants": participants, "contribution": contribution,
		"reward_claimed": reward_claimed, "cooldown_remaining": cooldown_remaining,
		"active_modifiers": active_modifiers}

static func from_dict(d: Dictionary) -> EventRuntimeState:
	var s := EventRuntimeState.new()
	s.event_id = StringName(str(d.get("event_id", "")))
	s.phase = int(d.get("phase", Enums.EventPhase.SCHEDULED))
	s.remaining_time = float(d.get("remaining_time", 0.0))
	s.progress = float(d.get("progress", 0.0))
	s.participants = d.get("participants", []) if typeof(d.get("participants")) == TYPE_ARRAY else []
	s.contribution = d.get("contribution", {}) if typeof(d.get("contribution")) == TYPE_DICTIONARY else {}
	s.reward_claimed = bool(d.get("reward_claimed", false))
	s.cooldown_remaining = float(d.get("cooldown_remaining", 0.0))
	s.active_modifiers = d.get("active_modifiers", []) if typeof(d.get("active_modifiers")) == TYPE_ARRAY else []
	return s

func is_active() -> bool:
	return phase == Enums.EventPhase.ACTIVE
