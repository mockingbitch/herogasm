extends RefCounted
## Integration — Stage 3/3: thắng -> sao theo star_rules; first-clear reward 1 lần, repeat khác.

static func _boost_roster() -> void:
	PlayerProfile.reset_progress()
	for id in PlayerProfile.hero_ids:
		var h: HeroInstance = PlayerProfile.get_hero(id)
		for i in 40:
			h.gain_xp(h.xp_to_next())
		h.current_hp = h.eff_max_hp(); h.is_ko = false; h.fatigue = 0.0

static func run(t) -> void:
	_boost_roster()
	var out := StageBattleService.run("s_valoria_1", "balanced_3", 100)
	t.truthy(bool(out["ok"]), "Stage_Ran")
	t.truthy(bool(out["won"]), "Stage_StrongTeamWins")
	t.truthy(int(out["stars"]) >= 1, "Stage_AtLeastOneStar")
	t.truthy(bool(out["first_clear"]), "Stage_FirstClearReward")
	t.truthy(PlayerProfile.stage_star("s_valoria_1") >= 1, "Stage_StarsRecorded")

	# repeat: first_clear = false (không nhận first-clear lần 2)
	var gold_before := PlayerProfile.gold
	var out2 := StageBattleService.run("s_valoria_1", "balanced_3", 100)
	t.eq(bool(out2["first_clear"]), false, "Stage_NoDoubleFirstClear")
	t.truthy(PlayerProfile.gold >= gold_before, "Stage_RepeatStillRewards")

	# boss stage: chạy được + trả kết quả (thắng/thua tuỳ sức đội)
	var outb := StageBattleService.run("s_silverwood_boss", "balanced_3", 7)
	t.truthy(bool(outb["ok"]), "StageBoss_Ran")
	t.truthy(outb.has("duration"), "StageBoss_HasDuration")
