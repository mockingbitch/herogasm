extends RefCounted
## Unit — Boss engine P4: phase change, enrage-once, break, reward-once, contribution.

static func _hero(id: String, hp: int, atk: int, df: int, interval: float) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = id; c.team = 0; c.max_hp = hp; c.hp = hp; c.attack = atk; c.defense = df
	c.crit_damage = 1.5; c.attack_interval = interval; c.source_hero_id = id
	c.add_skill(SkillFactory.basic_attack(interval))
	return c

static func _party(n: int, atk: int, hp: int, interval: float) -> Array:
	var out: Array = []
	for i in n:
		out.append(_hero("p%d" % i, hp, atk, 20, interval))
	return out

static func run(t) -> void:
	var fg: BossDef = Database.get_boss_def("forest_guardian")

	# --- phase change khi HP < ngưỡng ---
	var boss1 := BossController.make_combatant(fg, Database.boss_phases(fg), BossRuntimeState.new())
	var r1 := BattleSim.new().simulate(_party(3, 300, 3000, 0.5), [boss1], 3, 400)
	t.truthy(1 in r1.phases_entered, "Boss_EntersPhase1BelowThreshold")

	# --- enrage kích hoạt 1 lần khi hết timer ---
	var bd := BossDef.new()
	bd.id = &"test_enrage"; bd.max_hp = 999999; bd.attack = 1; bd.defense = 0
	bd.attack_interval = 1.0; bd.enrage_timer_sec = 1.0
	var eboss := BossController.make_combatant(bd, [], BossRuntimeState.new())
	var re := BattleSim.new().simulate([_hero("weak", 10000, 1, 0, 1.0)], [eboss], 1, 30)
	t.truthy(re.enrage_activated, "Enrage_ActivatedAfterTimer")
	t.eq(eboss.attack, 2, "Enrage_AttackDoubled")   # base 1 -> x2 (không cộng dồn mỗi tick)

	# --- break gauge đầy -> stun boss ---
	var boss2 := BossController.make_combatant(fg, Database.boss_phases(fg), BossRuntimeState.new())
	var rb := BattleSim.new().simulate(_party(3, 100, 3000, 0.3), [boss2], 5, 400)
	t.truthy(rb.breaks >= 1, "Break_TriggeredByHits")

	# --- reward chia theo contribution + chống double-claim ---
	PlayerProfile.reset_progress()
	var st := BossRuntimeState.new()
	st.boss_def_id = fg.id
	st.add_contribution("hero_a", 1000.0, 0.0, 5)
	st.add_contribution("hero_b", 400.0, 200.0, 2)
	var g0 := PlayerProfile.gold
	var res := BossReward.distribute(fg, st, PlayerProfile)
	t.truthy(bool(res["ok"]), "Reward_Distributed")
	t.truthy(PlayerProfile.gold > g0, "Reward_GoldGranted")
	t.eq(str(res["mvp"]), "hero_a", "Reward_MvpTopContributor")
	t.truthy(st.reward_claimed, "Reward_ClaimedFlag")
	var res2 := BossReward.distribute(fg, st, PlayerProfile)
	t.eq(bool(res2["ok"]), false, "Reward_DoubleClaimRejected")

	# --- healer nhận credit đóng góp (healing có trọng số) ---
	var sh := BossRuntimeState.new()
	sh.add_contribution("healer", 0.0, 500.0, 0)
	var board := BossReward.board(sh)
	t.truthy(board.size() == 1 and str(board[0]["hero_id"]) == "healer" and float(board[0]["score"]) > 0.0, "Healer_HasContribution")
