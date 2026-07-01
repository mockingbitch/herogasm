extends RefCounted
## Unit — HeroInstance stat math (port từ profile.gd). Cần Database autoload (iron_sword).

static func run(t) -> void:
	# base level 1, no gear
	var h := HeroInstance.new()
	t.eq(h.eff_attack(), 10, "Lvl1NoGear_AttackBase10")
	t.eq(h.eff_defense(), 0, "Lvl1NoGear_Defense0")
	t.eq(h.eff_max_hp(), 100, "Lvl1NoGear_HP100")

	# weapon iron_sword (bonus_attack 12), level 0 -> 10 + round(12*1.0) = 22
	var h2 := HeroInstance.new()
	h2.equipment["weapon"] = HeroInstance.make_instance("iron_sword", 0)
	t.eq(h2.eff_attack(), 22, "IronSwordLvl0_Attack22")
	# upgrade gear +1 -> 12*(1+0.4) = 16.8 round 17 -> 27
	h2.upgrade_gear("weapon")
	t.eq(h2.eff_attack(), 27, "IronSwordLvl1_Attack27")

	# talent power rank1 (+2 attack), no gear
	var h3 := HeroInstance.new()
	h3.talent_points = 1
	t.truthy(h3.spend_talent("power"), "SpendTalentPower_Ok")
	t.eq(h3.eff_attack(), 12, "TalentPowerRank1_Attack12")
	t.eq(h3.talent_points, 0, "TalentPointsSpent")

	# affix crit_chance clamp 0..1
	var h4 := HeroInstance.new()
	h4.equipment["weapon"] = HeroInstance.make_instance("iron_sword", 0,
		[{"stat": "crit_chance", "value": 0.5}])
	t.approx(h4.eff_crit_chance(), 0.55, "AffixCrit_0p55")   # 0.05 base + 0.5
	var h5 := HeroInstance.new()
	h5.equipment["weapon"] = HeroInstance.make_instance("iron_sword", 0,
		[{"stat": "crit_chance", "value": 5.0}])
	t.approx(h5.eff_crit_chance(), 1.0, "AffixCrit_ClampedTo1")

	# lifesteal clamp <= 0.8
	var h6 := HeroInstance.new()
	h6.equipment["weapon"] = HeroInstance.make_instance("iron_sword", 0,
		[{"stat": "lifesteal", "value": 1.0}])
	t.approx(h6.eff_lifesteal(), 0.8, "Lifesteal_ClampedTo0p8")

	# xp -> level up cấp talent point
	var h7 := HeroInstance.new()
	var gained := h7.gain_xp(h7.xp_to_next())
	t.eq(gained, 1, "GainXp_LevelUp1")
	t.eq(h7.level, 2, "GainXp_Level2")
	t.eq(h7.talent_points, 1, "GainXp_TalentPoint1")
