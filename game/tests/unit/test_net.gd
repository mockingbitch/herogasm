extends RefCounted
## Unit — Net (offline-first) + MockBackend: serialize roundtrip, idempotent (dedupe command_id),
## offline queue + reconnect replay, rate limit.

static func run(t) -> void:
	# --- command serialize roundtrip ---
	var c := GameCommand.new("lb-submit", {"score": 5, "seed": 9}, "x1")
	c.player_id = "p"; c.session_id = "s"; c.timestamp = 3
	var back := GameCommand.from_dict(c.to_dict())
	t.eq(str(back.type), "lb-submit", "Cmd_TypeRoundtrip")
	t.eq(back.payload, c.payload, "Cmd_PayloadRoundtrip")
	t.eq(back.command_id, "x1", "Cmd_IdRoundtrip")

	# --- idempotency: guild-boss-hit cùng command_id chỉ trừ HP 1 lần ---
	NetManager.backend = MockBackend.new()
	NetManager.go_online()
	PlayerProfile.account_id = "u_net"
	NetManager.send("guild-create", {"account_id": "u_net", "name": "NetGuild"})
	var gid := ""
	for k in NetManager.backend.guilds.keys():
		gid = k
	PlayerProfile.guild_id = gid
	var hp0 := int(NetManager.backend.guilds[gid]["boss_hp_current"])
	GuildService.boss_hit(500, "hit1")
	GuildService.boss_hit(500, "hit1")               # cùng command_id -> dedupe
	t.eq(int(NetManager.backend.guilds[gid]["boss_hp_current"]), hp0 - 500, "Idempotent_HitOnce")
	GuildService.boss_hit(500, "hit2")               # id khác -> áp tiếp
	t.eq(int(NetManager.backend.guilds[gid]["boss_hp_current"]), hp0 - 1000, "Idempotent_NewIdApplies")

	# --- offline queue + reconnect replay ---
	NetManager.go_offline()
	var hp1 := int(NetManager.backend.guilds[gid]["boss_hp_current"])
	var qr := GuildService.boss_hit(300, "hit3")
	t.eq(qr.code, CommandResult.Code.QUEUED, "Offline_Queued")
	t.eq(int(NetManager.backend.guilds[gid]["boss_hp_current"]), hp1, "Offline_NoServerChange")
	t.truthy(NetManager.queued_count() >= 1, "Offline_QueueHasCmd")
	NetManager.go_online()                            # reconnect -> replay
	t.eq(int(NetManager.backend.guilds[gid]["boss_hp_current"]), hp1 - 300, "Reconnect_ReplayApplied")
	t.eq(NetManager.queued_count(), 0, "Reconnect_QueueCleared")

	# --- rate limit ---
	NetManager.backend = MockBackend.new()
	NetManager.go_online()
	var last := CommandResult.new()
	for i in MockBackend.RATE_CAP + 1:
		last = NetManager.send("claim-reward", {"claim_id": "r%d" % i}, "rl_%d" % i)
	t.eq(last.code, CommandResult.Code.REJECTED_RATE, "RateLimit_Exceeded")
