extends RefCounted
## Unit — BattleSim P4: tất định, pipeline damage (resist/weak-point/shield), CC/interrupt.

static func _hero(id: String, hp: int, atk: int, df: int = 0, cc: float = 0.0, interval: float = 1.0) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = id; c.team = 0; c.max_hp = hp; c.hp = hp; c.attack = atk; c.defense = df
	c.crit_chance = cc; c.crit_damage = 1.5; c.attack_interval = interval; c.source_hero_id = id
	c.add_skill(SkillFactory.basic_attack(interval))
	return c

static func _mob(id: String, hp: int, atk: int, df: int = 0, interval: float = 1.0) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = id; c.team = 1; c.max_hp = hp; c.hp = hp; c.attack = atk; c.defense = df
	c.crit_damage = 1.5; c.attack_interval = interval; c.source_enemy_id = "slime"
	c.add_skill(SkillFactory.basic_attack(interval))
	return c

static func run(t) -> void:
	# --- tất định: cùng seed -> cùng kết quả ---
	var s1 := BattleSim.new().simulate([_hero("h1", 150, 20, 2, 0.2)], [_mob("m1", 80, 8)], 999)
	var s2 := BattleSim.new().simulate([_hero("h1", 150, 20, 2, 0.2)], [_mob("m1", 80, 8)], 999)
	t.eq(s1.winner, s2.winner, "Determinism_Winner")
	t.eq(s1.total_damage, s2.total_damage, "Determinism_TotalDamage")
	t.eq(s1.timeline.size(), s2.timeline.size(), "Determinism_TimelineLen")

	# --- hero mạnh thắng, quái chết ---
	var mob := _mob("ms", 25, 3)
	var r := BattleSim.new().simulate([_hero("hs", 300, 50)], [mob], 7)
	t.eq(r.winner, 0, "StrongHero_Wins")
	t.eq(mob.hp, 0, "WeakMob_Dead")
	t.eq(r.dead_enemy_ids, ["slime"], "DeadEnemyTracked")

	# --- pipeline: resist giảm ~50% ---
	var src := _hero("src", 100, 100)
	var rng := RandomNumberGenerator.new()
	var basic := SkillFactory.basic_attack(1.0)
	var t0 := _mob("t0", 1000, 0, 0); t0.resist = 0.0
	rng.seed = 5
	var d_no := BattleSim.new().compute_hit(src, t0, basic, rng)
	var t50 := _mob("t50", 1000, 0, 0); t50.resist = 0.5
	rng.seed = 5
	var d_res := BattleSim.new().compute_hit(src, t50, basic, rng)
	t.approx(float(d_res["damage"]), float(d_no["damage"]) * 0.5, "Resist_HalvesDamage", 1.0)

	# --- pipeline: weak-point cộng bonus (abyss_dragon head +50%) ---
	var bdef: BossDef = Database.get_boss_def("abyss_dragon")
	var boss := BossController.make_combatant(bdef, Database.boss_phases(bdef), BossRuntimeState.new())
	var wp := SkillFactory.boss_skill("wp", "WeakHit", Enums.SkillType.DAMAGE, 1.0, 1.0)
	wp.weak_point_id = &"head"
	var plain := SkillFactory.boss_skill("pl", "Plain", Enums.SkillType.DAMAGE, 1.0, 1.0)
	rng.seed = 11
	var d_wp := BattleSim.new().compute_hit(src, boss, wp, rng)
	rng.seed = 11
	var d_pl := BattleSim.new().compute_hit(src, boss, plain, rng)
	t.approx(float(d_wp["damage"]), float(d_pl["damage"]) * 1.5, "WeakPoint_BonusDamage", 1.0)

	# --- shield hấp thụ trước HP (5 đòn x10, shield 25 -> hp 1000-25=975) ---
	var atkr := _hero("atk", 5000, 10, 0, 0.0, 0.1)
	var sh := _mob("sh", 1000, 0, 0, 0.1); sh.shield = 25
	var rs := BattleSim.new().simulate([atkr], [sh], 1, 5)
	t.eq(sh.shield, 0, "Shield_Drained")
	t.eq(int(rs.survivors_hp["sh"]), 975, "Shield_AbsorbsThenHp")

	# --- CC ngắt cast (interrupt) ---
	var caster := _mob("z_caster", 20000, 1, 0, 5.0)
	var bigcast := SkillFactory.boss_skill("bigcast", "Nổ Lớn", Enums.SkillType.DAMAGE, 5.0, 3.0,
		Enums.SkillTarget.SINGLE_LOWEST_HP, 2.0, 0.0)
	caster.add_skill(bigcast)
	var stunner := _hero("a_stun", 20000, 1, 0, 0.0, 5.0)
	var stun := SkillFactory.boss_skill("stun", "Choáng", Enums.SkillType.CC, 0.0, 1.0)
	stun.cc_type = Enums.CcType.STUN; stun.cc_duration_sec = 0.5
	stunner.add_skill(stun)
	var ri := BattleSim.new().simulate([stunner], [caster], 3, 30)
	t.truthy(ri.interrupts >= 1, "CC_InterruptsCast")
