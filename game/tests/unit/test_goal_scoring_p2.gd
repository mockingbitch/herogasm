extends RefCounted
## Unit — 2 goal mới (heal_injury/train) + decision order (survival vẫn thắng).

static func _ctx() -> DecisionContext:
	var c := DecisionContext.new()
	c.hp_pct = 1.0; c.stamina01 = 1.0; c.durability01 = 1.0
	c.potion_count = 3; c.gold = 500; c.energy = 10
	c.fatigue01 = 0.0; c.fatigue_rest_threshold = 0.8
	return c

static func run(t) -> void:
	var ev := HeroGoalEvaluator.new()

	# Thương lv2 + có alchemy + đủ gold -> heal_injury thắng hunt
	var c := _ctx()
	c.injury_level = 2; c.has_alchemy_service = true; c.heal_cost = 60
	t.eq(ev.evaluate(c)["goal"], "heal_injury", "Injury2_HealWins")
	t.approx(ev.evaluate(c)["scores"]["hunt"], 0.0, "Injury2_HuntGated")

	# Kiệt sức (fatigue ≥0.95 -> hunt bị gate) -> rest thắng
	var c2 := _ctx()
	c2.fatigue01 = 0.97
	t.eq(ev.evaluate(c2)["goal"], "rest", "Exhausted_RestWins")

	# Gần lên cấp, mọi need ổn, có training -> train thắng hunt
	var c3 := _ctx()
	c3.xp_pct = 0.95; c3.has_training_service = true; c3.train_cost = 25; c3.train_threshold = 0.85
	t.eq(ev.evaluate(c3)["goal"], "train", "NearLevel_TrainBeatsHunt")

	# ...nhưng HP thấp -> Survival (rest) vượt Progression (train)
	var c4 := _ctx()
	c4.xp_pct = 0.95; c4.has_training_service = true; c4.train_cost = 25; c4.hp_pct = 0.15
	t.eq(ev.evaluate(c4)["goal"], "rest", "LowHp_RestBeatsTrain")

	# Điểm luôn trong [0,1]
	var res := ev.evaluate(_ctx())
	for g in res["scores"].keys():
		t.truthy(float(res["scores"][g]) >= 0.0 and float(res["scores"][g]) <= 1.0, "Score_%s_InRange" % g)
