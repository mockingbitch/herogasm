extends RefCounted
## Unit — Rune: main theo level, level-unlock, resonance (≥4 element), slot validate.

static func _r(def_id: String, level: int = 1) -> RuneInstance:
	var r := RuneInstance.new()
	r.def_id = def_id; r.level = level
	return r

static func run(t) -> void:
	# main theo level
	t.approx(float(RuneService.rune_main(_r("fire_atk", 1)).get("bonus_attack", 0.0)), 8.0, "RuneMain_Lvl1")
	t.approx(float(RuneService.rune_main(_r("fire_atk", 10)).get("bonus_attack", 0.0)), 8.0 + 1.0 * 9.0, "RuneMain_Lvl10")

	# level unlock (5 -> crit, 10 -> attack pct); lvl1 chưa mở
	var eff := RuneService.unlocked_effects(_r("fire_atk", 10))
	t.truthy(eff.has("crit_chance"), "Unlock5_Crit")
	t.truthy(eff.has("bonus_attack"), "Unlock10_Attack")
	t.truthy(RuneService.unlocked_effects(_r("fire_atk", 1)).is_empty(), "NoUnlock_Lvl1")

	# resonance: 4 fire -> aura; 3 fire -> none
	var runes4: Array = [_r("fire_atk"), _r("fire_hp"), _r("fire_atk"), _r("fire_hp"), null]
	t.approx(float(RuneService.resonance(runes4).get("bonus_attack", 0.0)), 0.15, "Resonance_4Fire")
	var runes3: Array = [_r("fire_atk"), _r("fire_hp"), _r("fire_atk"), _r("ice_def"), null]
	t.truthy(not RuneService.resonance(runes3).has("bonus_attack"), "NoResonance_3Fire")

	# slot validate: core -> slot0; normal -> 1..4
	t.truthy(RuneService.can_slot_rune(_r("berserker_core"), 0), "Core_Slot0")
	t.truthy(not RuneService.can_slot_rune(_r("berserker_core"), 1), "Core_NotSlot1")
	t.truthy(not RuneService.can_slot_rune(_r("fire_atk"), 0), "Normal_NotCore")
	t.truthy(RuneService.can_slot_rune(_r("fire_atk"), 2), "Normal_Slot2")
