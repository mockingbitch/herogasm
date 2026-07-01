extends RefCounted
## Unit — Synergy: đếm race/class trong team -> aura percent (threshold).

static func _h(race: String, cls: String = "warrior") -> HeroInstance:
	var h := HeroInstance.new()
	h.race = race; h.class_role = cls
	return h

static func run(t) -> void:
	# 3 elf -> elf synergy (+0.10 crit_chance)
	var team := [_h("elf"), _h("elf"), _h("elf"), _h("human")]
	var out := SynergyService.compute(team)
	t.approx(float(out.get("crit_chance", 0.0)), 0.10, "Elf3_Synergy")

	# 2 elf -> chưa đủ threshold 3
	var team2 := [_h("elf"), _h("elf"), _h("human")]
	t.truthy(float(SynergyService.compute(team2).get("crit_chance", 0.0)) == 0.0, "Elf2_NoSynergy")

	# 3 human -> +0.10 max_hp; 5 human -> +0.15 (mốc cao hơn cộng dồn theo threshold <= n)
	var team3 := [_h("human"), _h("human"), _h("human")]
	t.approx(float(SynergyService.compute(team3).get("bonus_max_hp", 0.0)), 0.10, "Human3_HP")

	# 3 mage (class synergy) -> +0.10 attack
	var team4 := [_h("human", "mage"), _h("elf", "mage"), _h("human", "mage")]
	t.approx(float(SynergyService.compute(team4).get("bonus_attack", 0.0)), 0.10, "Mage3_ClassSynergy")
