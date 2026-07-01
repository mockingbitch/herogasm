extends RefCounted
## Unit — talent respec + awaken + summon claim-protection (PlayerProfile điều phối).

static func _find_knight() -> String:
	for id in PlayerProfile.hero_ids:
		if PlayerProfile.get_hero(id).hero_def_id == "knight":
			return id
	return ""

static func run(t) -> void:
	PlayerProfile.reset_progress()
	var hid: String = PlayerProfile.hero_ids[0]
	var h: HeroInstance = PlayerProfile.get_hero(hid)
	h.talent_points = 5
	h.spend_talent("power"); h.spend_talent("power"); h.spend_talent("vitality")
	var before_atk := h.eff_attack()
	PlayerProfile.add_gold(1000)
	t.truthy(PlayerProfile.respec_hero_talents(hid), "Respec_Ok")
	t.eq(h.talents.size(), 0, "Respec_Cleared")
	t.eq(h.talent_points, 5, "Respec_Refunded")
	t.truthy(h.eff_attack() <= before_atk, "Respec_StatsLower")

	# awaken knight (shards đủ) -> rank1 + stat bonus, chỉ 1 lần
	var kid := _find_knight()
	t.truthy(kid != "", "KnightInRoster")
	var kh: HeroInstance = PlayerProfile.get_hero(kid)
	kh.shards = 100
	var atk0 := kh.eff_attack()
	t.truthy(PlayerProfile.awaken_hero(kid), "Awaken_Ok")
	t.eq(int(kh.awaken_state.get("rank", 0)), 1, "Awaken_Rank1")
	t.truthy(kh.eff_attack() > atk0, "Awaken_StatBonus")
	t.truthy(not PlayerProfile.awaken_hero(kid), "Awaken_OncePerRank")

	# summon claim-protection: cùng claim_id -> lần 2 bị chặn, không trừ gem
	PlayerProfile.reset_progress()
	var g0 := PlayerProfile.gems
	var r1 := PlayerProfile.summon("standard", 1, "cX")
	t.truthy(bool(r1["ok"]), "Summon_Ok")
	var g1 := PlayerProfile.gems
	t.truthy(g1 < g0, "Summon_SpentGems")
	var r2 := PlayerProfile.summon("standard", 1, "cX")
	t.eq(str(r2["reason"]), "duplicate_claim", "Summon_ClaimProtected")
	t.eq(PlayerProfile.gems, g1, "Summon_NoDoubleSpend")
