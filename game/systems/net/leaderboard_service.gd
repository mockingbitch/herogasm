class_name LeaderboardService
extends RefCounted
## Leaderboard server-verified (P6). Client tính score bằng BattleSim seeded LOCAL rồi submit kèm seed;
## server chạy lại verify (chống điểm giả). Client CHỈ read bảng, KHÔNG insert trực tiếp (RLS).

## Submit điểm "boss damage" của đội trước 1 opponent chuẩn, seed cho trước. Trả CommandResult.
static func submit(season_key: String, team_blocks: Array, opponent_blocks: Array, seed_val: int,
		formation_a: String = "balanced_3", formation_b: String = "balanced_3") -> CommandResult:
	var score := _local_score(team_blocks, opponent_blocks, seed_val, formation_a, formation_b)
	var res := NetManager.send("lb-submit", {
		"season_key": season_key, "account_id": _acc(), "score": score, "seed": seed_val,
		"team": team_blocks, "opponent": opponent_blocks,
		"formation_a": formation_a, "formation_b": formation_b})
	if res.ok() and res.code == CommandResult.Code.OK:
		EventBus.leaderboard_updated.emit(season_key)
		Telemetry.track(&"leaderboard_submit", &"economy", {"season": season_key, "score": score})
	return res

static func top(season_key: String, n: int = 10) -> Array:
	var r = NetManager.query("lb-top", {"season_key": season_key, "n": n})
	return r if r is Array else []

## Điểm client-side = total_damage của trận seeded (server tính CÙNG công thức để verify).
static func _local_score(a: Array, b: Array, seed_val: int, fa: String, fb: String) -> int:
	var ta := _team(a, 0, fa)
	var tb := _team(b, 1, fb)
	return BattleSim.new().simulate(ta, tb, seed_val, 900).total_damage

static func _team(blocks: Array, team: int, formation_id: String) -> Array:
	var out: Array = []
	for hb in blocks:
		if typeof(hb) == TYPE_DICTIONARY:
			out.append(SimCombatant.from_snapshot_hero(hb, team))
	FormationService.apply(out, Database.get_formation_def(formation_id))
	return out

static func _acc() -> String:
	return PlayerProfile.account_id if PlayerProfile.account_id != "" else "local"
