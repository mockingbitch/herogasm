extends RefCounted
## Unit — Battle Engine: tất định (seed) + kết quả hợp lý.

static func _unit(id: String, team: int, hp: int, atk: int, df: int, cc: float) -> BattleUnit:
	var u := BattleUnit.new()
	u.id = id; u.team = team; u.max_hp = hp; u.hp = hp
	u.attack = atk; u.defense = df; u.crit_chance = cc; u.crit_damage = 1.5
	u.attack_interval = 1.0
	if team == 1:
		u.source_enemy_id = "slime"
	else:
		u.source_hero_id = id
	return u

static func _sim(seed_val: int) -> BattleResult:
	return BattleEngine.simulate([_unit("h1", 0, 150, 20, 2, 0.2)], [_unit("m1", 1, 80, 8, 0, 0.0)], seed_val)

static func run(t) -> void:
	# Tất định: cùng seed -> cùng kết quả qua nhiều lần chạy
	var r1 := _sim(999)
	var r2 := _sim(999)
	t.eq(r1.winner, r2.winner, "Determinism_SameWinner")
	t.eq(r1.timeline.size(), r2.timeline.size(), "Determinism_SameTimelineLen")
	t.eq(r1.total_damage, r2.total_damage, "Determinism_SameTotalDamage")
	# seed khác thường cho timeline khác (ít nhất không giống hệt về damage do crit)
	t.truthy(r1.duration > 0.0, "Battle_HasDuration")

	# Hero mạnh thắng quái yếu, quái chết, loot id ghi nhận
	var hero := _unit("hs", 0, 300, 50, 5, 0.0)
	var mob := _unit("ms", 1, 25, 3, 0, 0.0)
	var r := BattleEngine.simulate([hero], [mob], 7)
	t.eq(r.winner, 0, "StrongHero_Wins")
	t.eq(mob.hp, 0, "WeakMonster_Dead")
	t.eq(r.dead_enemy_ids, ["slime"], "DeadEnemyTracked")
	t.eq(int(r.hero_hp_after["hs"]), hero.hp, "HeroHpAfterRecorded")

	# Quái mạnh hạ hero yếu -> hero thua (hp 0), winner 1
	var weak := _unit("hw", 0, 20, 2, 0, 0.0)
	var boss := _unit("mb", 1, 500, 40, 10, 0.0)
	var r3 := BattleEngine.simulate([weak], [boss], 3)
	t.eq(r3.winner, 1, "WeakHero_Loses")
	t.eq(int(r3.hero_hp_after["hw"]), 0, "LoserHeroHpZero")
