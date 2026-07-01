extends RefCounted
## Unit — Equipment: affix determinism, rarity count, enhance base-only, equip validate, set bonus.

static func _mk(def_id: String) -> EquipmentInstance:
	var e := EquipmentInstance.new()
	e.def_id = def_id
	return e

static func run(t) -> void:
	# affix determinism (cùng seed -> cùng affix)
	RandomService.seed_with(42)
	var i1 := EquipmentService.roll_equipment("mage_staff")   # RARE -> 3 secondary
	RandomService.seed_with(42)
	var i2 := EquipmentService.roll_equipment("mage_staff")
	t.eq(i1.affixes.size(), 3, "RareEquip_3Affix")
	t.eq(i1.affixes, i2.affixes, "Affix_Determinism")

	# rarity -> secondary count
	t.eq(EquipmentService.secondary_count(ItemData.Rarity.COMMON), 1, "Cnt_Common1")
	t.eq(EquipmentService.secondary_count(ItemData.Rarity.LEGENDARY), 4, "Cnt_Legend4")

	# enhance chỉ tăng base, không đổi affix
	var c := CombatConstants.new()
	var e := EquipmentInstance.new()
	e.main_value = 100.0
	e.affixes = [{"stat": "bonus_attack", "value": 3.0, "locked": false}]
	EquipmentService.enhance(e); EquipmentService.enhance(e); EquipmentService.enhance(e)
	t.eq(e.enhance, 3, "Enhance3")
	t.approx(EquipmentService.effective_main(e, c), 100.0 * (1.0 + 0.4 * 3.0), "Enhance_BaseOnly")  # 220
	t.eq(e.affixes.size(), 1, "Enhance_AffixUnchanged")
	for _i in 30:
		EquipmentService.enhance(e)
	t.eq(e.enhance, 20, "Enhance_ClampAt20")

	# equip validate theo class
	var mage := HeroInstance.new(); mage.class_role = "mage"
	t.truthy(EquipmentService.can_equip(mage, _mk("mage_staff")), "Mage_CanStaff")
	t.truthy(not EquipmentService.can_equip(mage, _mk("warrior_sword")), "Mage_CannotWarriorSword")

	# set bonus 2/4
	var eqp: Array = [null, null, null, null, null, null, null, null]
	eqp[Enums.EquipSlot.ARMOR] = _mk("guardian_armor")
	eqp[Enums.EquipSlot.HELMET] = _mk("guardian_helm")
	var sb2 := EquipmentService.set_bonus(eqp)
	t.approx(float(sb2.get("bonus_defense", 0.0)), 0.10, "Set2pc_Defense")
	t.truthy(not sb2.has("bonus_max_hp"), "Set_No4pcYet")
