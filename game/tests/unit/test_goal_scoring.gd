extends RefCounted
## Unit — Utility AI goal scoring (test-case chuẩn build-ai.md).

static func _ctx() -> DecisionContext:
	var c := DecisionContext.new()
	c.hp_pct = 1.0; c.stamina01 = 1.0; c.durability01 = 1.0
	c.potion_count = 3; c.gold = 500; c.energy = 10; c.inventory_count = 0
	return c

static func run(t) -> void:
	var ev := HeroGoalEvaluator.new()

	# Khoẻ mạnh, đủ potion/energy -> Hunt thắng
	var healthy := _ctx()
	t.eq(ev.evaluate(healthy)["goal"], "hunt", "Healthy_HuntWins")

	# HP thấp -> Rest thắng (Survival)
	var low_hp := _ctx()
	low_hp.hp_pct = 0.15
	t.eq(ev.evaluate(low_hp)["goal"], "rest", "LowHp_RestWins")

	# Gear hỏng + đủ gold -> Repair thắng (không săn với đồ hỏng)
	var broken := _ctx()
	broken.durability01 = 0.05
	broken.repair_cost = 50
	t.eq(ev.evaluate(broken)["goal"], "repair", "BrokenGear_RepairWins")

	# Hết potion + đủ gold -> BuyPotion thắng hunt
	var no_pot := _ctx()
	no_pot.potion_count = 0
	no_pot.potion_price = 40
	t.eq(ev.evaluate(no_pot)["goal"], "buy_potion", "NoPotion_BuyWins")

	# Hết energy -> không Hunt (fallback idle/rest)
	var no_energy := _ctx()
	no_energy.energy = 0
	t.truthy(ev.evaluate(no_energy)["goal"] != "hunt", "NoEnergy_NoHunt")

	# Điểm luôn trong [0,1]
	var res := ev.evaluate(healthy)
	for g in res["scores"].keys():
		var s: float = res["scores"][g]
		t.truthy(s >= 0.0 and s <= 1.0, "Score_%s_InRange" % g)

	# Hysteresis: giữ goal hiện tại khi sát điểm (không đổi lung tung)
	var tie := _ctx()
	tie.hp_pct = 0.5
	var keep := ev.evaluate(tie, "hunt")
	t.eq(keep["goal"], "hunt", "Hysteresis_KeepsCurrent")
