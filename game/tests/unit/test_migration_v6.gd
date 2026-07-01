extends RefCounted
## Regression — migration v5->v6 (story/season block) + event save/load giữ remaining_time & phase.

static func run(t) -> void:
	# --- migration v5 -> current ---
	var v5 := {"save_version": 5, "player": {"gold": 10}, "hero_ids": ["hero_0"],
		"heroes": {"hero_0": {"level": 1}}, "world": {}}
	var out := SaveManager._migrate(v5)
	t.eq(int(out["save_version"]), SaveManager.SAVE_VERSION, "V5_To_Current")
	t.truthy((out["player"] as Dictionary).has("story"), "Player_StoryAdded")
	t.truthy((out["player"] as Dictionary).has("battlepass"), "Player_BattlePassAdded")
	t.truthy((out["world"] as Dictionary).has("season"), "World_SeasonAdded")
	t.truthy((out["world"] as Dictionary).has("events"), "World_EventsAdded")

	# --- event save/load: remaining_time + phase khôi phục ---
	EventManager.import_world({})
	var ee := EventDef.new()
	ee.id = &"t_save"; ee.priority = EventDef.PRIORITY_MINOR; ee.duration_sec = 100.0
	Database.event_defs["t_save"] = ee
	EventManager.start_event("t_save")
	EventManager.tick(10.0)                              # remaining 90
	var w := EventManager.export_world()
	EventManager.import_world(w)
	var st := EventManager.get_state("t_save")
	t.truthy(st != null, "Event_Restored")
	t.approx(st.remaining_time, 90.0, "Event_RemainingRestored")
	t.eq(st.phase, Enums.EventPhase.ACTIVE, "Event_PhaseRestored")
	# reward chưa claim -> vẫn claim được sau reload; claim lần 2 bị chặn
	PlayerProfile.reset_progress()
	EventManager.import_world({})
	var re := EventDef.new(); re.id = &"t_reload_rew"; re.priority = EventDef.PRIORITY_MINOR
	re.duration_sec = 50.0; re.rewards = [{"type": "gems", "amount": 5}]
	Database.event_defs["t_reload_rew"] = re
	EventManager.start_event("t_reload_rew")
	var w2 := EventManager.export_world()
	EventManager.import_world(w2)                        # reload
	t.truthy(bool(EventManager.claim_reward("t_reload_rew")["ok"]), "Event_ClaimAfterReload")
	t.eq(bool(EventManager.claim_reward("t_reload_rew")["ok"]), false, "Event_NoDoubleClaimAfterReload")
