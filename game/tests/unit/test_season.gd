extends RefCounted
## Unit — Season: meta validator (chống power-creep), meta apply, currency expire, rank reset bất biến.

static func run(t) -> void:
	# --- meta validator ---
	t.eq(MetaRotationValidator.is_valid({"hero_buffs": [{"stat": "bonus_attack", "mult": 1.0}]}), false, "Meta_RejectHeroBuff")
	t.eq(MetaRotationValidator.is_valid({"hero_base": {}}), false, "Meta_RejectHeroBase")
	t.truthy(MetaRotationValidator.is_valid(Database.get_season_def("season_of_frost").meta_rotation), "Meta_FrostValid")

	# --- meta buff CHỈ áp cho hero sở hữu rune, không đổi hero khác (chống power-creep) ---
	PlayerProfile.reset_progress()
	var h: HeroInstance = PlayerProfile.primary_hero()
	var r := RuneInstance.new(); r.def_id = "fire_atk"; r.level = 1
	h.runes[1] = r; h.mark_stats_dirty()
	var meta_ctx := {"meta": {"rune_buffs": [{"rune_id": "fire_atk", "stat": "bonus_attack", "mult": 0.5}]}}
	var base_atk := h.get_final_stats({}).get_v("bonus_attack")
	var meta_atk := h.get_final_stats(meta_ctx).get_v("bonus_attack")
	t.truthy(meta_atk > base_atk, "Meta_BuffsOwnedRune")

	var h2: HeroInstance = PlayerProfile.get_hero(PlayerProfile.hero_ids[1])
	h2.mark_stats_dirty()
	var b2 := h2.get_final_stats({}).get_v("bonus_attack")
	var m2 := h2.get_final_stats(meta_ctx).get_v("bonus_attack")
	t.approx(m2, b2, "Meta_NoBuffForNonOwner")

	# --- seasonal currency expire về 0 ---
	PlayerProfile.add_currency("frost_shard", 100)
	t.eq(PlayerProfile.currency_amount("frost_shard"), 100, "Currency_Added")
	SeasonalShopService.expire_currency("frost_shard")
	t.eq(PlayerProfile.currency_amount("frost_shard"), 0, "Currency_ExpiredToZero")

	# --- rank reset giữ nguyên hero/story (chỉ reset MMR) ---
	ArenaService.mmr = 1500
	var lvl := h.level
	StoryManager.complete_chapter("ch00_awakening")
	RankResetService.reset({"reset_rank": true, "reset_leaderboard": true})
	t.eq(ArenaService.mmr, MmrService.BASE, "Rank_MmrReset")
	t.eq(h.level, lvl, "Rank_KeepsHeroLevel")
	t.eq(StoryManager.is_chapter_completed("ch00_awakening"), true, "Rank_KeepsStory")

	# --- battle pass: claim once + level gate ---
	var bp: BattlePassDef = Database.get_battle_pass_def("frost_pass")
	BattlePassService.ensure(bp)
	t.eq(bool(BattlePassService.claim(bp, 5, false)["ok"]), false, "Bp_LockedLevel")
	BattlePassService.add_xp(bp, bp.xp_per_level)     # lên level 2
	t.truthy(BattlePassService.level() >= 2, "Bp_LeveledUp")
	t.truthy(bool(BattlePassService.claim(bp, 2, false)["ok"]), "Bp_ClaimFreeLevel2")
	t.eq(bool(BattlePassService.claim(bp, 2, false)["ok"]), false, "Bp_NoDoubleClaim")
