extends RefCounted
## Unit — save v4 migration (v3->v4) + equipped roundtrip + build ảnh hưởng combat.

static func run(t) -> void:
	# migration v3 -> v4
	var v3 := {"save_version": 3, "player": {"gold": 100}, "hero_ids": ["hero_0"],
		"heroes": {"hero_0": {"level": 2}}, "world": {}}
	var out := SaveManager._migrate(v3)
	t.eq(int(out["save_version"]), 4, "V3_To_V4")
	t.truthy((out["heroes"]["hero_0"] as Dictionary).has("equipped"), "Hero_EquippedAdded")
	t.truthy((out["player"] as Dictionary).has("owned_equipment"), "Player_OwnedAdded")

	# equipped roundtrip qua PlayerProfile save/load
	PlayerProfile.reset_progress()
	var hid: String = PlayerProfile.hero_ids[0]
	var h: HeroInstance = PlayerProfile.get_hero(hid)
	var eq := EquipmentInstance.new()
	eq.uid = "eq_test"; eq.def_id = "warrior_sword"; eq.main_value = 30.0; eq.enhance = 2
	h.equipped[Enums.EquipSlot.WEAPON] = eq
	var d := PlayerProfile.to_dict()
	PlayerProfile.from_dict(d)
	var h2: HeroInstance = PlayerProfile.get_hero(hid)
	t.truthy(h2.equipped[Enums.EquipSlot.WEAPON] != null, "Equip_Roundtrip")
	t.eq(str(h2.equipped[Enums.EquipSlot.WEAPON].def_id), "warrior_sword", "Equip_DefRoundtrip")
	t.eq(int(h2.equipped[Enums.EquipSlot.WEAPON].enhance), 2, "Equip_EnhanceRoundtrip")

	# build ảnh hưởng combat: equip nâng attack của BattleUnit
	var h3 := HeroInstance.new()
	var atk0 := BattleUnit.from_hero(h3, 0).attack
	var eq3 := EquipmentInstance.new()
	eq3.def_id = "warrior_sword"; eq3.main_value = 50.0
	h3.equipped[Enums.EquipSlot.WEAPON] = eq3
	h3.mark_stats_dirty()
	t.truthy(BattleUnit.from_hero(h3, 0).attack > atk0, "Equip_RaisesBattleAttack")
