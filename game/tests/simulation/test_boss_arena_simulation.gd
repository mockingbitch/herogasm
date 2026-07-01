extends RefCounted
## Simulation (headless, seeded) — batch arena + world boss. Không crash, phân bố winrate hợp lý,
## boss tiến triển phase. Quy mô rút gọn để chạy nhanh trong CI (rules/simulation.md).

static func _team_from_bot(bot: Dictionary, team: int) -> Array:
	var out: Array = []
	for hb in bot.get("heroes", []):
		out.append(SimCombatant.from_snapshot_hero(hb, team))
	FormationService.apply(out, Database.get_formation_def(str(bot.get("formation_id", "balanced_3"))))
	return out

static func run(t) -> void:
	# --- batch arena: mọi cặp bot x vài seed, đo winrate ---
	var pool: Array = Database.arena_bot_pool
	var win_a := 0; var win_b := 0; var timeouts := 0; var matches := 0
	for i in pool.size():
		for j in pool.size():
			if i == j:
				continue
			for s in 3:
				var res := BattleSim.new().simulate(_team_from_bot(pool[i], 0), _team_from_bot(pool[j], 1), 1000 + s * 7 + i * 31 + j)
				matches += 1
				if res.timed_out: timeouts += 1
				if res.winner == 0: win_a += 1
				else: win_b += 1
				t.truthy(res.winner == 0 or res.winner == 1, "Sim_MatchHasWinner_%d_%d_%d" % [i, j, s])
	t.eq(win_a + win_b, matches, "Sim_AllMatchesDecided")
	t.truthy(win_a > 0 and win_b > 0, "Sim_BothSidesWinSometimes")   # không degenerate
	Debug.log("[Sim] arena matches=%d winA=%d winB=%d timeouts=%d" % [matches, win_a, win_b, timeouts])

	# --- world boss: raid party đủ sức -> boss mất HP + tiến triển phase 4 giai đoạn ---
	# Party tổng hợp (headless) mô phỏng raid endgame — kiểm tra cơ chế boss, không phụ thuộc roster.
	var bdef: BossDef = Database.get_boss_def("abyss_dragon")
	var st := BossRuntimeState.new(); st.boss_def_id = bdef.id
	var boss := BossController.make_combatant(bdef, Database.boss_phases(bdef), st)
	var team: Array = []
	for i in 8:
		var c := SimCombatant.new()
		c.id = "raid%d" % i; c.team = 0; c.max_hp = 5000; c.hp = 5000
		c.attack = 400; c.defense = 60; c.crit_chance = 0.2; c.crit_damage = 1.6
		c.attack_interval = 0.6; c.source_hero_id = "raid%d" % i
		c.add_skill(SkillFactory.basic_attack(0.6))
		team.append(c)
	var rb := BattleSim.new().simulate(team, [boss], 777, 9000)
	t.truthy(st.current_hp < st.max_hp, "Sim_BossTookDamage")
	t.truthy(rb.phases_entered.size() >= 2, "Sim_BossProgressedPhase")
	Debug.log("[Sim] world boss hp_left=%.0f%% phases=%s defeated=%s" % [st.hp_pct() * 100.0, str(rb.phases_entered), str(rb.boss_defeated)])
