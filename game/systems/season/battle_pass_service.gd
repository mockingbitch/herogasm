class_name BattlePassService
extends RefCounted
## Battle Pass season (Free/Premium, cosmetic-first). Tiến trình ở PlayerProfile.battlepass.
## XP đến từ mission event/story (KHÔNG mua power). Claim reward chống double.

static func ensure(def: BattlePassDef) -> void:
	var bp: Dictionary = PlayerProfile.battlepass
	if str(bp.get("season_id", "")) != str(def.season_id):
		PlayerProfile.battlepass = {"season_id": str(def.season_id), "level": 1, "xp": 0,
			"premium": false, "claimed_free": {}, "claimed_premium": {}}

static func level() -> int:
	return int(PlayerProfile.battlepass.get("level", 1))

static func add_xp(def: BattlePassDef, n: int) -> void:
	ensure(def)
	var bp: Dictionary = PlayerProfile.battlepass
	bp["xp"] = int(bp["xp"]) + maxi(0, n)
	while int(bp["level"]) < def.max_level and int(bp["xp"]) >= def.xp_per_level:
		bp["xp"] = int(bp["xp"]) - def.xp_per_level
		bp["level"] = int(bp["level"]) + 1
		Telemetry.log_event("Season", "battlepass_level_up", {"level": bp["level"]})

static func set_premium(def: BattlePassDef, on: bool) -> void:
	ensure(def)
	PlayerProfile.battlepass["premium"] = on

## Nhận reward 1 bậc (free/premium). Chống double + gate theo level + gate premium.
static func claim(def: BattlePassDef, lvl: int, premium: bool) -> Dictionary:
	ensure(def)
	var bp: Dictionary = PlayerProfile.battlepass
	if lvl > int(bp["level"]):
		return {"ok": false, "reason": "locked"}
	if premium and not bool(bp.get("premium", false)):
		return {"ok": false, "reason": "no_premium"}
	var claimed: Dictionary = bp["claimed_premium"] if premium else bp["claimed_free"]
	if claimed.has(str(lvl)):
		return {"ok": false, "reason": "claimed"}
	var rewards := def.rewards_at(lvl, premium)
	for r in rewards:
		PlayerProfile.grant_reward(r)
	claimed[str(lvl)] = true
	PlayerProfile.save()
	return {"ok": true, "rewards": rewards}
