class_name ContentP4
extends RefCounted
## Content P4 (data-driven, code-built như ZoneDef/BuildingDef — tách khỏi Database để <300 dòng).
## 2 boss mẫu: forest_guardian (Region 2-phase, cơ chế BREAK) + abyss_dragon (World 4-phase:
## Shield→Summon→ArenaBreak→Enrage, có weak-point + interrupt + summon). Formation, stage, arena bot.

static func build(db) -> void:
	_skills(db)
	_bosses(db)
	_formations(db)
	_stages(db)
	db.boss_minion_groups["abyss_adds"] = ["skeleton", "skeleton"]
	# Rotation tuần: 2 boss xoay 7 ngày (BOSS.md muốn 7 boss riêng — demo tái dùng).
	db.world_boss_rotation = ["abyss_dragon", "forest_guardian", "abyss_dragon",
		"forest_guardian", "abyss_dragon", "forest_guardian", "abyss_dragon"]
	_arena_bots(db)

# --- skills (SkillDef dùng chung; boss field set qua SkillFactory.boss_skill) ---
static func _skills(db) -> void:
	_add(db, SkillFactory.boss_skill("fg_slam", "Nện Đất", Enums.SkillType.DAMAGE, 1.8, 3.0))
	_add(db, SkillFactory.boss_skill("fg_quake", "Địa Chấn", Enums.SkillType.DAMAGE, 1.1,
		6.0, Enums.SkillTarget.ALL_ENEMIES, 1.0, 1.0))
	var roots := SkillFactory.boss_skill("fg_roots", "Rễ Trói", Enums.SkillType.CC, 0.0,
		8.0, Enums.SkillTarget.SINGLE_LOWEST_HP, 0.5, 0.5)
	roots.cc_type = Enums.CcType.STUN
	roots.cc_duration_sec = 1.5
	_add(db, roots)
	_add(db, SkillFactory.boss_skill("ad_bite", "Ngoạm Hư Không", Enums.SkillType.DAMAGE, 2.0, 2.5))
	_add(db, SkillFactory.boss_skill("ad_claw", "Vuốt Truy Sát", Enums.SkillType.DAMAGE, 1.6,
		3.0, Enums.SkillTarget.HIGHEST_THREAT))
	var shield := SkillFactory.boss_skill("ad_shield", "Vảy Rồng", Enums.SkillType.SHIELD, 0.0,
		999.0, Enums.SkillTarget.SELF)
	shield.flat_amount = 3000.0
	_add(db, shield)
	_add(db, SkillFactory.boss_skill("ad_meteor", "Thiên Thạch", Enums.SkillType.DAMAGE, 2.2,
		10.0, Enums.SkillTarget.ALL_ENEMIES, 2.0, 2.0))

static func _add(db, s: SkillDef) -> void:
	db.skill_defs[str(s.id)] = s

# --- bosses + phases -------------------------------------------------------
static func _bosses(db) -> void:
	# Forest Guardian — Region boss 2-phase, cơ chế độc quyền = BREAK gauge.
	var fg := BossDef.new()
	fg.id = &"forest_guardian"; fg.display_name = "Thủ Hộ Rừng"; fg.boss_type = Enums.BossType.REGION
	fg.region_id = &"silverwood"; fg.level = 10
	fg.max_hp = 8000; fg.attack = 60; fg.defense = 15; fg.attack_interval = 1.2
	fg.phase_ids = [&"fg_p0", &"fg_p1"]
	fg.break_max = 40.0; fg.break_stun_sec = 3.0; fg.break_dmg_taken_mult = 1.5
	fg.sprite_set = &"ogre"
	db.boss_defs["forest_guardian"] = fg
	db.boss_phase_defs["fg_p0"] = _phase("fg_p0", Enums.BossTrigger.HP_PCT, 1.0, [&"fg_slam"], {})
	db.boss_phase_defs["fg_p1"] = _phase("fg_p1", Enums.BossTrigger.HP_PCT, 0.5,
		[&"fg_slam", &"fg_quake", &"fg_roots"], {"attack": 1.3, "attack_interval": 0.9})

	# Abyss Dragon — World boss 4-phase: Shield→Summon→ArenaBreak→Enrage.
	var ad := BossDef.new()
	ad.id = &"abyss_dragon"; ad.display_name = "Hắc Long Vực Sâu"; ad.boss_type = Enums.BossType.WORLD
	ad.region_id = &"iron_mountain"; ad.level = 30
	ad.max_hp = 60000; ad.attack = 120; ad.defense = 30; ad.resist = 0.1; ad.attack_interval = 1.0
	ad.phase_ids = [&"ad_p0", &"ad_p1_shield", &"ad_p2_summon", &"ad_p3_break"]
	ad.enrage_timer_sec = 300.0
	ad.break_max = 120.0; ad.break_stun_sec = 4.0; ad.break_dmg_taken_mult = 1.6
	ad.weak_points = [{"part_id": "head", "bonus_dmg_pct": 0.5, "on_break_effect": ""}]
	ad.sprite_set = &"big_demon"
	db.boss_defs["abyss_dragon"] = ad
	db.boss_phase_defs["ad_p0"] = _phase("ad_p0", Enums.BossTrigger.HP_PCT, 1.0, [&"ad_bite", &"ad_claw"], {})
	db.boss_phase_defs["ad_p1_shield"] = _phase("ad_p1_shield", Enums.BossTrigger.HP_PCT, 0.75,
		[&"ad_bite", &"ad_shield"], {})
	var p2 := _phase("ad_p2_summon", Enums.BossTrigger.HP_PCT, 0.5, [&"ad_bite", &"ad_claw"], {"attack": 1.1})
	p2.summon_group_id = &"abyss_adds"
	db.boss_phase_defs["ad_p2_summon"] = p2
	var p3 := _phase("ad_p3_break", Enums.BossTrigger.HP_PCT, 0.25, [&"ad_bite", &"ad_meteor"],
		{"attack": 1.4, "attack_interval": 0.85})
	p3.arena_hazard_id = &"void"; p3.hazard_dps = 15.0; p3.loot_bonus_pct = 0.2
	db.boss_phase_defs["ad_p3_break"] = p3

static func _phase(id: String, trig: int, val: float, skills: Array, mult: Dictionary) -> BossPhaseDef:
	var p := BossPhaseDef.new()
	p.id = StringName(id); p.trigger_type = trig; p.trigger_value = val
	p.skill_ids.assign(skills); p.stat_mult = mult
	return p

# --- formation -------------------------------------------------------------
static func _formations(db) -> void:
	var bal := FormationDef.new()
	bal.id = &"balanced_3"; bal.display_name = "Cân Bằng"
	bal.slots = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
	bal.front_buff = {"defense": 0.25}; bal.back_buff = {"attack": 0.12, "speed": 0.10}
	db.formation_defs["balanced_3"] = bal
	var off := FormationDef.new()
	off.id = &"offense_3"; off.display_name = "Tấn Công"
	off.slots = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
	off.front_buff = {"attack": 0.10}; off.back_buff = {"attack": 0.20, "speed": 0.05}
	db.formation_defs["offense_3"] = off

# --- stages (world-map "3/3") ----------------------------------------------
static func _stages(db) -> void:
	var s1 := StageDef.new()
	s1.id = &"s_valoria_1"; s1.region_id = &"valoria"; s1.chapter_id = &"ch1"
	s1.display_name = "Ải Đồng Bằng 1"; s1.recommended_power = 40
	s1.enemy_waves = [["slime", "bat"], ["skeleton"]]
	db.stage_defs["s_valoria_1"] = s1
	var s2 := StageDef.new()
	s2.id = &"s_silverwood_boss"; s2.region_id = &"silverwood"; s2.chapter_id = &"ch2"
	s2.display_name = "Ải Rừng Bạc — Thủ Hộ"; s2.recommended_power = 120
	s2.enemy_waves = [["skeleton", "bat"]]
	s2.boss_def_id = &"forest_guardian"
	db.stage_defs["s_silverwood_boss"] = s2

# --- arena bot pool (seed vòng đời PvP async; P6 thay bằng snapshot online) ---
static func _arena_bots(db) -> void:
	db.arena_bot_pool = [
		_bot("bot_greenhorn", 900, [[520, 40, 10], [420, 34, 8], [380, 30, 6]]),
		_bot("bot_squire", 1000, [[640, 52, 14], [500, 44, 10], [440, 38, 8]]),
		_bot("bot_knight", 1120, [[780, 66, 18], [600, 55, 12], [520, 47, 10]]),
		_bot("bot_veteran", 1250, [[960, 82, 24], [720, 68, 16], [640, 58, 12]]),
		_bot("bot_champion", 1400, [[1180, 104, 30], [900, 86, 20], [780, 72, 15]]),
	]

static func _bot(owner: String, mmr: int, stat_rows: Array) -> Dictionary:
	var heroes: Array = []
	var power := 0
	for i in stat_rows.size():
		var row: Array = stat_rows[i]
		heroes.append({"hero_id": "%s_h%d" % [owner, i], "name": "%s#%d" % [owner, i],
			"max_hp": row[0], "attack": row[1], "defense": row[2],
			"crit_chance": 0.08, "crit_damage": 1.5, "lifesteal": 0.0, "attack_interval": 1.0})
		power += int(row[0]) + int(row[1]) * 8 + int(row[2]) * 4
	return {"owner_profile_id": owner, "power_ref": power, "heroes": heroes,
		"formation_id": "balanced_3", "mmr": mmr, "captured_tick": 0}
