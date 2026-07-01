extends RefCounted
## Unit — offline progression: có thưởng theo thời gian vắng + CLAMP trần (chống đổi giờ).

static func run(t) -> void:
	PlayerProfile.reset_progress()
	var g0 := PlayerProfile.gold

	# Vắng 1h -> có thưởng gold
	PlayerProfile.offline_ts = TimeService.now_unix() - 3600.0
	PlayerProfile._apply_offline_progress()
	t.truthy(PlayerProfile.gold > g0, "Offline_GrantedGoldAfter1h")

	# Vắng 100h -> bị clamp về MAX_OFFLINE_SEC (không thưởng vô hạn)
	var g1 := PlayerProfile.gold
	PlayerProfile.offline_ts = TimeService.now_unix() - 100.0 * 3600.0
	PlayerProfile._apply_offline_progress()
	var gained: int = PlayerProfile.gold - g1
	var cap: int = int(PlayerProfile.MAX_OFFLINE_SEC * PlayerProfile.OFFLINE_GOLD_PER_SEC * PlayerProfile.hero_ids.size()) + 2
	t.truthy(gained <= cap, "Offline_ClampedToCap")
	t.truthy(gained > 0, "Offline_ClampStillRewards")
