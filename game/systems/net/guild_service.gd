class_name GuildService
extends RefCounted
## Guild online (P6, GUILD.md): create/join/role + Guild Boss shared-HP (damage trừ SERVER-SIDE) +
## Guild Shop (Guild Coin trừ server-side). Client KHÔNG tự trừ HP boss/coin (multiplayer.md Security).

const CREATE_LEVEL_REQ := 20

static func can_create() -> bool:
	return PlayerProfile.roster_max_level() >= CREATE_LEVEL_REQ

static func create(name: String) -> CommandResult:
	if not can_create():
		return CommandResult.rejected("level_too_low", CommandResult.Code.ERROR)
	var res := NetManager.send("guild-create", {"account_id": _acc(), "name": name})
	if res.code == CommandResult.Code.OK:
		PlayerProfile.guild_id = str(res.data.get("guild_id", ""))
		PlayerProfile.save()
		EventBus.guild_changed.emit(PlayerProfile.guild_id)
	return res

static func join(guild_id: String) -> CommandResult:
	var res := NetManager.send("guild-join", {"account_id": _acc(), "guild_id": guild_id})
	if res.code == CommandResult.Code.OK:
		PlayerProfile.guild_id = guild_id
		PlayerProfile.save()
		EventBus.guild_changed.emit(guild_id)
	return res

## Đánh Guild Boss: damage cộng vào shared-HP SERVER-SIDE (idempotent theo command_id).
static func boss_hit(damage: int, command_id: String = "") -> CommandResult:
	if PlayerProfile.guild_id == "":
		return CommandResult.rejected("no_guild", CommandResult.Code.ERROR)
	return NetManager.send("guild-boss-hit",
		{"account_id": _acc(), "guild_id": PlayerProfile.guild_id, "damage": maxi(0, damage)}, command_id)

static func shop_buy(cost: int) -> CommandResult:
	if PlayerProfile.guild_id == "":
		return CommandResult.rejected("no_guild", CommandResult.Code.ERROR)
	return NetManager.send("guild-shop-buy", {"account_id": _acc(), "guild_id": PlayerProfile.guild_id, "cost": cost})

static func _acc() -> String:
	return PlayerProfile.account_id if PlayerProfile.account_id != "" else "local"
