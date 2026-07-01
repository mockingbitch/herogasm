extends RefCounted
## Unit — StatAggregator: tất định, flat-trước-percent, clamp gate.

static func run(t) -> void:
	var h := HeroInstance.new()   # level1, không def -> fallback CombatConstants
	var fs1 := StatAggregator.aggregate(h)
	var fs2 := StatAggregator.aggregate(h)
	t.approx(fs1.get_v("bonus_attack"), fs2.get_v("bonus_attack"), "Agg_Deterministic")
	t.approx(fs1.get_v("bonus_attack"), 10.0, "Agg_BaseAttackLvl1")

	# flat trước, percent nhân MỘT lần: equip main +50 attack, core rune +25% attack
	var eq := EquipmentInstance.new()
	eq.def_id = "warrior_sword"; eq.main_value = 50.0
	h.equipped[Enums.EquipSlot.WEAPON] = eq
	var core := RuneInstance.new()
	core.def_id = "berserker_core"; core.level = 1
	h.runes[0] = core
	h.mark_stats_dirty()
	var fs := StatAggregator.aggregate(h)
	t.approx(fs.get_v("bonus_attack"), (10.0 + 50.0) * 1.25, "Agg_FlatBeforePercent")  # 75

	# clamp crit ≤ 0.8 (base 0.05 + affix 0.9 = 0.95 -> 0.8)
	var ring := EquipmentInstance.new()
	ring.def_id = "crit_ring"; ring.main_value = 0.0
	ring.affixes = [{"stat": "crit_chance", "value": 0.9, "locked": false}]
	h.equipped[Enums.EquipSlot.RING] = ring
	h.mark_stats_dirty()
	t.approx(StatAggregator.aggregate(h).get_v("crit_chance"), 0.8, "Agg_CritClamp0p8")

	# cache dirty-flag: get_final_stats solo cache, mark_dirty invalidate
	var fa := h.get_final_stats()
	var fb := h.get_final_stats()
	t.truthy(fa == fb, "Cache_SameInstanceWhenClean")
	h.mark_stats_dirty()
	t.truthy(h.get_final_stats() != fb, "Cache_NewAfterDirty")
