extends RefCounted
## Unit — migration save v1 (phẳng) -> v2 (lồng). Không được ném data.

static func run(t) -> void:
	var v1 := {
		"gold": 500, "xp": 10, "level": 3, "talent_points": 1,
		"talents": {"power": 2},
		"equipment": {"weapon": {"id": "rusty_sword", "level": 1, "affixes": []}, "armor": null},
		"inventory": [], "consumables": {"health_potion": 3}, "materials": {},
		"save_version": 1,
	}
	var out := SaveManager._migrate(v1)
	t.eq(int(out["save_version"]), 3, "V1_MigratedToCurrent")   # chain v1->v2->v3
	t.eq(int(out["player"]["gold"]), 500, "V1_GoldPreserved")
	t.truthy((out["heroes"] as Dictionary).has("hero_0"), "V1_Hero0Created")
	t.eq(int(out["heroes"]["hero_0"]["level"]), 3, "V1_HeroLevelPreserved")
	t.eq(str(out["heroes"]["hero_0"]["equipment"]["weapon"]["id"]), "rusty_sword", "V1_WeaponPreserved")
	t.eq(out["hero_ids"], ["hero_0"], "V1_HeroIds")
	t.eq(int(out["player"]["consumables"]["health_potion"]), 3, "V1_ConsumablesPreserved")

	# thiếu field -> default, không crash
	var out2 := SaveManager._migrate({"save_version": 1})
	t.eq(int(out2["player"]["gold"]), 0, "V1Missing_GoldDefault0")
	t.truthy((out2["heroes"] as Dictionary).has("hero_0"), "V1Missing_Hero0Exists")

	# nạp save đã migrate vào PlayerProfile không crash
	PlayerProfile.from_dict(out)
	t.eq(PlayerProfile.gold, 500, "V1_LoadedIntoProfile")
	t.eq(PlayerProfile.hero_ids.size(), 1, "V1_ProfileHeroCount")
