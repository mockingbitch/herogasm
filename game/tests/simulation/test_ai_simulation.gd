extends RefCounted
## Simulation (simulation.md) — chạy vòng lặp quyết định + battle thuần logic (không scene),
## seeded & tất định: mọi hero luôn có goal, không deadlock, không giá trị âm, không permadeath.

const VALID_GOALS := ["hunt", "rest", "buy_potion", "repair", "idle"]

static func _ctx(h: HeroInstance) -> DecisionContext:
	var c := DecisionContext.new()
	c.hp_pct = float(h.current_hp) / float(maxi(1, h.eff_max_hp()))
	c.stamina01 = h.stamina / 100.0
	c.durability01 = h.durability / 100.0
	c.potion_count = PlayerProfile.potion_count()
	c.gold = PlayerProfile.gold
	c.energy = PlayerProfile.energy
	c.is_ko = h.is_ko
	c.aggression = h.aggression()
	c.rest_threshold = h.rest_threshold()
	c.repair_threshold = h.repair_threshold()
	c.potion_price = 40
	c.repair_cost = 30
	return c

static func run(t) -> void:
	RandomService.seed_with(42)
	PlayerProfile.reset_progress()
	var roster := PlayerProfile.hero_ids.size()
	var ev := HeroGoalEvaluator.new()
	var enemies := [Database.get_enemy("slime"), Database.get_enemy("bat"), Database.get_enemy("skeleton")]

	var goal_counts := {}
	var neg_violation := false
	var invalid_goal := false
	var max_idle_streak := 0
	var idle_streak := 0

	for _i in 500:
		for id in PlayerProfile.hero_ids:
			var h: HeroInstance = PlayerProfile.get_hero(id)
			if h == null:
				continue
			var goal: String = ev.evaluate(_ctx(h), "")["goal"]
			if not VALID_GOALS.has(goal):
				invalid_goal = true
			goal_counts[goal] = int(goal_counts.get(goal, 0)) + 1
			match goal:
				"hunt":
					if PlayerProfile.spend_energy(1):
						var mob: EnemyData = enemies[RandomService.randi_range(0, enemies.size() - 1)]
						var res := BattleEngine.simulate(
							[BattleUnit.from_hero(h, 0)], [BattleUnit.from_enemy(mob, 1, "m")], RandomService.randi())
						h.current_hp = int(res.hero_hp_after.get(id, h.current_hp))
						h.stamina = maxf(0.0, h.stamina - 5.0)
						h.durability = maxf(0.0, h.durability - 3.0)
						if res.hero_won() and h.current_hp > 0:
							PlayerProfile.add_gold(mob.gold_drop_min)
							PlayerProfile.grant_xp(id, mob.xp_reward)
						else:
							h.current_hp = 0
							h.is_ko = true
				"rest":
					h.current_hp = h.eff_max_hp()
					h.stamina = 100.0
					h.is_ko = false
				"buy_potion":
					PlayerProfile.buy("health_potion")
				"repair":
					if PlayerProfile.gold >= 30:
						PlayerProfile.add_gold(-30)
					h.durability = 100.0
				_:
					idle_streak += 1
					max_idle_streak = maxi(max_idle_streak, idle_streak)
			if goal != "idle":
				idle_streak = 0
			if h.current_hp < 0 or PlayerProfile.gold < 0 or PlayerProfile.energy < 0:
				neg_violation = true
		PlayerProfile.add_energy(3)   # regen để vòng lặp tiếp diễn

	t.truthy(not invalid_goal, "Sim_AllGoalsValid")
	t.truthy(not neg_violation, "Sim_NoNegativeValues")
	t.truthy(int(goal_counts.get("hunt", 0)) > 50, "Sim_HeroesHuntedRepeatedly")
	t.eq(PlayerProfile.hero_ids.size(), roster, "Sim_NoPermadeath")
	t.truthy(PlayerProfile.gold > 0, "Sim_EconomyGrew")
	t.truthy(max_idle_streak < 50, "Sim_NoLongIdleDeadlock")
