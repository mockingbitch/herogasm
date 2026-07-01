extends RefCounted
## Integration — Async PvP + Leaderboard server-verify: tamper reject, seed-deterministic, forged score reject.

static func run(t) -> void:
	NetManager.backend = MockBackend.new()
	NetManager.go_online()
	PlayerProfile.reset_progress()

	# --- defender đặt defense; attacker tấn công với hash đúng -> OK ---
	PlayerProfile.account_id = "defender"
	t.eq(AsyncPvpService.set_defense().code, CommandResult.Code.OK, "Pvp_DefenseSet")
	var real_hash := str(NetManager.backend.pvp_defenses["defender"]["stat_hash"])
	PlayerProfile.account_id = "attacker"
	var atk := AsyncPvpService.attack("defender", real_hash, 777, "balanced_3", "match1")
	t.eq(atk.code, CommandResult.Code.OK, "Pvp_AttackVerified")
	t.truthy(atk.data.has("winner"), "Pvp_HasWinner")

	# --- snapshot tampered -> server rejects ---
	var bad := AsyncPvpService.attack("defender", "TAMPERED_HASH", 777, "balanced_3", "match2")
	t.eq(bad.code, CommandResult.Code.REJECTED_VERIFY, "Pvp_TamperedRejected")

	# --- seed-deterministic: match ghi winner theo seed, dedupe theo match_id ---
	var recorded := int(NetManager.backend.pvp_matches["match1"]["winner"])
	t.eq(recorded, int(atk.data.get("winner")), "Pvp_MatchRecordedDeterministic")

	# --- leaderboard: điểm thật OK, điểm giả bị từ chối ---
	var team: Array = Database.arena_bot_pool[0]["heroes"]
	var opp: Array = Database.arena_bot_pool[1]["heroes"]
	PlayerProfile.account_id = "lb_player"
	var honest := LeaderboardService.submit("s0", team, opp, 42)
	t.eq(honest.code, CommandResult.Code.OK, "Lb_HonestAccepted")
	var forged := NetManager.send("lb-submit", {"season_key": "s0", "account_id": "cheater",
		"score": 99999999, "seed": 42, "team": team, "opponent": opp,
		"formation_a": "balanced_3", "formation_b": "balanced_3"})
	t.eq(forged.code, CommandResult.Code.REJECTED_VERIFY, "Lb_ForgedRejected")
	t.truthy(LeaderboardService.top("s0", 10).size() >= 1, "Lb_TopReadable")
	PlayerProfile.account_id = ""
