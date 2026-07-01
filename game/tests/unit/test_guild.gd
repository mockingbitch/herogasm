extends RefCounted
## Integration — Guild: create/join/role, Guild Boss shared-HP server-side, Guild Shop (coin server-side).

static func run(t) -> void:
	NetManager.backend = MockBackend.new()
	NetManager.go_online()
	PlayerProfile.reset_progress()
	for id in PlayerProfile.hero_ids:                    # đủ level 20 để tạo guild
		var h: HeroInstance = PlayerProfile.get_hero(id)
		for i in 25:
			h.gain_xp(h.xp_to_next())
	PlayerProfile.account_id = "leader"

	# --- create + role Leader ---
	t.truthy(GuildService.can_create(), "Guild_CanCreate")
	var cr := GuildService.create("Dragons")
	t.eq(cr.code, CommandResult.Code.OK, "Guild_Created")
	var gid := PlayerProfile.guild_id
	t.truthy(gid != "", "Guild_IdSet")
	t.eq(str(NetManager.backend.guild_members[gid]["leader"]["role"]), "Leader", "Guild_LeaderRole")

	# --- tên trùng bị từ chối ---
	t.eq(GuildService.create("Dragons").code, CommandResult.Code.REJECTED_VERIFY, "Guild_DuplicateNameRejected")

	# --- join (account khác) -> role Member ---
	NetManager.send("guild-join", {"account_id": "member1", "guild_id": gid})
	t.eq(str(NetManager.backend.guild_members[gid]["member1"]["role"]), "Member", "Guild_JoinMemberRole")

	# --- Guild Boss shared-HP trừ SERVER-SIDE ---
	var hp0 := int(NetManager.backend.guilds[gid]["boss_hp_current"])
	GuildService.boss_hit(700, "gh1")
	t.eq(int(NetManager.backend.guilds[gid]["boss_hp_current"]), hp0 - 700, "GuildBoss_HpServerSide")
	t.eq(int(NetManager.backend.guild_members[gid]["leader"]["contribution"]), 700, "GuildBoss_ContributionTracked")

	# --- Guild Shop: coin trừ server-side + chặn thiếu coin ---
	NetManager.backend.grant_guild_coin(gid, 100)
	t.eq(GuildService.shop_buy(60).code, CommandResult.Code.OK, "GuildShop_BuyOk")
	t.eq(int(NetManager.backend.guilds[gid]["guild_coin"]), 40, "GuildShop_CoinDeducted")
	t.eq(GuildService.shop_buy(100).code, CommandResult.Code.REJECTED_VERIFY, "GuildShop_InsufficientRejected")
	PlayerProfile.account_id = ""
	PlayerProfile.guild_id = ""
