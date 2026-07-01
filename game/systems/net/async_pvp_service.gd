class_name AsyncPvpService
extends RefCounted
## Async PvP online (P6, PVP.md): lưu defense snapshot (server giữ), tấn công tải snapshot đối thủ,
## chạy BattleSim SEEDED local -> submit; server verify stat_hash (chống chỉnh) + chạy lại theo seed.
## Fair play: KHÔNG buff pay-to-win. Tái dùng ArenaSnapshot/BattleSim (P4).

## Đặt đội hình phòng thủ hiện tại lên server.
static func set_defense(formation_id: String = "balanced_3") -> CommandResult:
	var team := PlayerProfile.active_team(3)
	var snap := PvpDefenseSnapshot.from_team(_acc(), team, formation_id, TimeService.get_tick())
	return NetManager.send("pvp-defense-set",
		{"account_id": _acc(), "snapshot": snap.to_dict(), "stat_hash": snap.hero_stat_hash})

## Tấn công đối thủ (snapshot + hash lấy từ matchmaking). Trả CommandResult (attacker_won).
static func attack(defender_id: String, defender_stat_hash: String, seed_val: int,
		formation_a: String = "balanced_3", match_id: String = "") -> CommandResult:
	var team := PlayerProfile.active_team(3)
	var ctx := PlayerProfile.team_context()
	var blocks: Array = []
	for h in team:
		blocks.append(ArenaSnapshot.freeze_hero(h, ctx))
	var mid := match_id if match_id != "" else "m_%d" % TimeService.get_tick()
	return NetManager.send("pvp-submit", {
		"match_id": mid, "attacker_id": _acc(), "defender_id": defender_id,
		"defender_stat_hash": defender_stat_hash, "seed": seed_val,
		"attacker_team": blocks, "formation_a": formation_a}, mid)

static func _acc() -> String:
	return PlayerProfile.account_id if PlayerProfile.account_id != "" else "local"
