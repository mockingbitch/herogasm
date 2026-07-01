extends RefCounted
## Unit/Integration — Arena: MMR-lite (đối xứng, clamp), timeout xử theo HP, fight + replay tất định.

static func _u(id: String, team: int, hp: int, atk: int, df: int) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = id; c.team = team; c.max_hp = hp; c.hp = hp; c.attack = atk; c.defense = df
	c.attack_interval = 1.0
	if team == 1: c.source_enemy_id = "slime"
	else: c.source_hero_id = id
	c.add_skill(SkillFactory.basic_attack(1.0))
	return c

static func run(t) -> void:
	# --- MMR-lite ---
	t.approx(MmrService.predict_win_chance(1000, 1000), 0.5, "Mmr_EqualIsHalf", 0.001)
	var win := MmrService.update(1000, 1000, true)
	var lose := MmrService.update(1000, 1000, false)
	t.truthy(win > 1000, "Mmr_WinGoesUp")
	t.truthy(lose < 1000, "Mmr_LoseGoesDown")
	t.eq(win - 1000, 1000 - lose, "Mmr_SymmetricDelta")
	t.truthy(MmrService.update(0, 3000, false) >= 0, "Mmr_ClampNonNegative")
	t.truthy(MmrService.update(2000, 1000, false) < 2000, "Mmr_FavoriteLosingDrops")

	# --- timeout: cả hai còn sống -> nhiều HP hơn thắng ---
	var rt := BattleSim.new().simulate([_u("A", 0, 1000, 1, 100)], [_u("B", 1, 500, 1, 100)], 1, 50)
	t.truthy(rt.timed_out, "Timeout_Reached")
	t.eq(rt.winner, 0, "Timeout_MoreHpWins")
	var rt2 := BattleSim.new().simulate([_u("A", 0, 300, 1, 100)], [_u("B", 1, 900, 1, 100)], 1, 50)
	t.eq(rt2.winner, 1, "Timeout_MoreHpWins_Other")

	# --- fight async + replay tất định ---
	PlayerProfile.reset_progress()
	ArenaService.mmr = 1000
	ArenaService.quota_used = 0
	ArenaService.quota_day = TimeService.game_day()
	var opps := ArenaService.find_opponents()
	t.truthy(opps.size() >= 1, "Arena_HasOpponents")
	var h0 := PlayerProfile.honor()
	var q0 := ArenaService.quota_used
	var out := ArenaService.fight(opps[0])
	t.truthy(bool(out["ok"]), "Arena_FightOk")
	var res: ArenaMatchResult = out["result"]
	t.truthy(res != null, "Arena_ResultReturned")
	t.eq(ArenaService.quota_used, q0 + 1, "Arena_QuotaConsumed")
	t.truthy(PlayerProfile.honor() > h0, "Arena_HonorGranted")
	# replay phát lại 2 lần cho cùng kết quả (tất định)
	var replay: ReplayData = out["replay"]
	t.truthy(ReplayPlayer.is_deterministic(replay), "Arena_ReplayDeterministic")
	var w1 := ReplayPlayer.play(replay)
	t.eq(w1.winner, replay.outcome, "Arena_ReplayMatchesOriginal")
