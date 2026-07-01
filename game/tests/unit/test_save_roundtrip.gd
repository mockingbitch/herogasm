extends RefCounted
## Unit — save round-trip (HeroInstance + PlayerProfile).

static func run(t) -> void:
	# HeroInstance round-trip
	var h := HeroInstance.new()
	h.hero_id = "hx"
	h.level = 3
	h.xp = 7
	h.talent_points = 2
	h.equipment["weapon"] = HeroInstance.make_instance("iron_sword", 2,
		[{"stat": "bonus_attack", "value": 3.0}])
	h.inventory.append(HeroInstance.make_instance("rusty_sword", 0))
	h.reset_hp()
	var atk_before := h.eff_attack()

	var h2 := HeroInstance.from_dict(h.to_dict())
	t.eq(h2.level, 3, "Hero_LevelRoundTrip")
	t.eq(h2.xp, 7, "Hero_XpRoundTrip")
	t.eq(h2.equipment["weapon"]["id"], "iron_sword", "Hero_WeaponIdRoundTrip")
	t.eq(h2.equipment["weapon"]["level"], 2, "Hero_WeaponLevelRoundTrip")
	t.eq(h2.inventory.size(), 1, "Hero_InventoryRoundTrip")
	t.eq(h2.eff_attack(), atk_before, "Hero_EffAttackIdentical")

	# PlayerProfile account round-trip
	PlayerProfile.reset_progress()
	PlayerProfile.add_gold(777)
	PlayerProfile.add_gems(5)
	var d := PlayerProfile.to_dict()
	PlayerProfile.gold = 0
	PlayerProfile.gems = 0
	PlayerProfile.from_dict(d)
	t.eq(PlayerProfile.gold, 777, "Account_GoldRoundTrip")
	t.eq(PlayerProfile.gems, 5, "Account_GemsRoundTrip")
	t.eq(PlayerProfile.hero_ids.size(), 1, "Account_HeroCountRoundTrip")
