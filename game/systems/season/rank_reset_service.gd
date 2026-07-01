class_name RankResetService
extends RefCounted
## Reset rank/leaderboard/seasonal progress cuối season. TUYỆT ĐỐI KHÔNG động hero/equip/rune/story
## (ECONOMY.md "Seasonal Reset"). Trả summary để test kiểm chứng bất biến.

static func reset(policy: Dictionary) -> Dictionary:
	var out := {"reset_rank": false, "reset_leaderboard": false}
	if bool(policy.get("reset_rank", true)):
		ArenaService.mmr = MmrService.BASE
		ArenaService.quota_used = 0
		ArenaService.win_streak = 0
		out["reset_rank"] = true
	if bool(policy.get("reset_leaderboard", true)):
		# leaderboard local demo gắn với arena mmr; chưa có bảng riêng để xoá ở P5
		out["reset_leaderboard"] = true
	Telemetry.log_event("Season", "rank_reset", out)
	return out
