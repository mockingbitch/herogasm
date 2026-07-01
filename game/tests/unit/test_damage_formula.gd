extends RefCounted
## Unit — DamageFormula. Given/When/Then, tất định (cc=0/1 để không phụ thuộc rng).

static func run(t) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1

	# atk 50, def 0, no crit -> 50*100/100 = 50
	var r1 := DamageFormula.compute(50, 0, 0.0, 1.5, rng, 100.0)
	t.eq(r1["damage"], 50, "Atk50Def0NoCrit_Damage50")
	t.eq(r1["crit"], false, "Atk50Def0NoCrit_NoCrit")

	# atk 100, def 100, no crit -> 100*100/200 = 50 (mềm hoá)
	t.eq(DamageFormula.compute(100, 100, 0.0, 1.5, rng, 100.0)["damage"], 50, "Atk100Def100_Softened50")

	# crit 100% -> base * cd
	var rc := DamageFormula.compute(50, 0, 1.0, 1.5, rng, 100.0)
	t.eq(rc["damage"], 75, "Crit100_TimesCd75")
	t.eq(rc["crit"], true, "Crit100_CritTrue")

	# def âm bị clamp về 0
	t.eq(DamageFormula.compute(50, -100, 0.0, 1.5, rng, 100.0)["damage"], 50, "NegDefClamped")

	# attack 0 -> 0
	t.eq(DamageFormula.compute(0, 50, 0.0, 1.5, rng, 100.0)["damage"], 0, "ZeroAttack")
