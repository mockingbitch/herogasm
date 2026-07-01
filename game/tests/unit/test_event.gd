extends RefCounted
## Unit — EventManager (build-events required cases): lifecycle, modifier reversible, reward-once, festival mood.

static func _def(id: String, prio: int, dur: float, prep: float = 0.0) -> EventDef:
	var e := EventDef.new()
	e.id = StringName(id); e.priority = prio; e.duration_sec = dur; e.preparation_sec = prep
	Database.event_defs[id] = e
	return e

static func run(t) -> void:
	# --- lifecycle: prep -> active -> reward ---
	EventManager.import_world({})
	var pe := _def("t_prep", EventDef.PRIORITY_MINOR, 20.0, 10.0)
	EventManager.start_event("t_prep")
	var st := EventManager.get_state("t_prep")
	t.eq(st.phase, Enums.EventPhase.PREPARATION, "Event_StartsInPrep")
	EventManager.tick(11.0)
	t.eq(st.phase, Enums.EventPhase.ACTIVE, "Event_PrepEndsToActive")
	EventManager.tick(21.0)
	t.eq(st.phase, Enums.EventPhase.REWARD, "Event_DurationEndsToReward")

	# --- modifier reversible ---
	EventManager.import_world({})
	var me := _def("t_mod", EventDef.PRIORITY_MINOR, 10.0)
	me.modifiers = [{"target": "gold_rate", "value": 0.5}]
	EventManager.start_event("t_mod")
	t.approx(EventManager.modifier_multiplier("gold_rate"), 1.5, "Event_ModifierApplied")
	EventManager.tick(11.0)
	t.approx(EventManager.modifier_multiplier("gold_rate"), 1.0, "Event_ModifierRemovedAfterEnd")

	# --- reward chống trùng ---
	EventManager.import_world({})
	PlayerProfile.reset_progress()
	var re := _def("t_rew", EventDef.PRIORITY_MINOR, 5.0)
	re.rewards = [{"type": "gold", "amount": 100}]
	EventManager.start_event("t_rew")
	var g0 := PlayerProfile.gold
	t.truthy(bool(EventManager.claim_reward("t_rew")["ok"]), "Event_RewardClaimed")
	t.eq(PlayerProfile.gold, g0 + 100, "Event_RewardGranted")
	t.eq(bool(EventManager.claim_reward("t_rew")["ok"]), false, "Event_DoubleClaimRejected")

	# --- festival mood bonus ---
	EventManager.import_world({})
	PlayerProfile.reset_progress()
	var h: HeroInstance = PlayerProfile.primary_hero()
	h.set_mood(50.0)
	EventManager.start_event("frost_festival")     # modifier mood_bonus 15
	t.truthy(h.mood > 50.0, "Festival_MoodBonusApplied")

	# --- overlap: 2 medium max ---
	EventManager.import_world({})
	_def("m1", EventDef.PRIORITY_MEDIUM, 100.0)
	_def("m2", EventDef.PRIORITY_MEDIUM, 100.0)
	_def("m3", EventDef.PRIORITY_MEDIUM, 100.0)
	EventManager.start_event("m1"); EventManager.start_event("m2")
	t.eq(bool(EventManager.start_event("m3")["ok"]), false, "Event_MediumOverlapCapped")
