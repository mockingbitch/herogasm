class_name ContentP5
extends RefCounted
## Content P5 (data-driven, code-built): campaign (Prologue + Chapter 1-3 full text, 4-10 + arc
## placeholder hợp lệ) + dialogue + Season of Frost (event/battle pass/shop/meta rotation/world evo).
## Trỏ stage/boss của P4. Nội dung tách file để Database <300 dòng.

static func build(db) -> void:
	_dialogues(db)
	_chapters(db)
	_events(db)
	_battle_pass(db)
	_season_of_frost(db)

# --- dialogues -------------------------------------------------------------
static func _dialogues(db) -> void:
	_dlg(db, "prologue_awakening", [
		{"speaker": "Người Dẫn Chuyện", "portrait_id": "narrator", "text": "Vương quốc từng rực rỡ nay chỉ còn tro tàn..."},
		{"speaker": "Rogan", "portrait_id": "knight_m", "text": "Ta sẽ dựng lại nơi này. Từng viên đá một."},
	], {"type": "unlock", "feature": "town"})
	_dlg(db, "ch01_intro", [
		{"speaker": "Người Dẫn Chuyện", "portrait_id": "narrator", "text": "Hắc Kỵ Sĩ chiếm giữ tàn tích phía bắc."},
		{"speaker": "Mira", "portrait_id": "wizard_m", "text": "Muốn tiến lên, ta phải hạ hắn trước."},
	], {"type": "start_battle"})
	_dlg(db, "ch02_intro", [
		{"speaker": "Người Dẫn Chuyện", "portrait_id": "narrator", "text": "Rừng Bạc thì thầm những lời cảnh báo."},
	], {})
	_dlg(db, "ch03_intro", [
		{"speaker": "Người Dẫn Chuyện", "portrait_id": "narrator", "text": "Thủ Hộ Rừng thức giấc sau ngàn năm."},
	], {})
	_dlg(db, "boss_black_knight", [
		{"speaker": "Hắc Kỵ Sĩ", "portrait_id": "big_demon", "text": "Ngươi đến để chết như bao kẻ khác."},
	], {})
	# Season of Frost limited-story
	_dlg(db, "frost_frozen_fortress", [
		{"speaker": "Băng Hậu", "portrait_id": "ice", "text": "Mùa đông vĩnh cửu sẽ nuốt chửng vương quốc ngươi."},
	], {})

static func _dlg(db, id: String, lines: Array, next_action: Dictionary) -> void:
	var d := DialogueDef.new()
	d.id = StringName(id); d.lines = lines; d.next_action = next_action
	db.dialogue_defs[id] = d

# --- chapters --------------------------------------------------------------
static func _chapters(db) -> void:
	# Prologue "Awakening" — mở town, tặng hero khởi đầu (đã có), gate cơ bản.
	_chapter(db, "ch00_awakening", "Thức Tỉnh", 0, "prologue", ["s_valoria_1"], [],
		"prologue_awakening", "", [{"type": "feature", "id": "town"}], "town", "valoria", "")
	# Chapter 1 "The Broken Kingdom" — boss Black Knight, unlock hero + rune system.
	_chapter(db, "ch01_broken_kingdom", "Vương Quốc Vỡ Vụn", 1, "chapter", ["s_valoria_1"], ["forest_guardian"],
		"ch01_intro", "boss_black_knight",
		[{"type": "hero", "id": "knight"}, {"type": "feature", "id": "rune_system"}], "rune_system", "valoria", "ch00_awakening")
	# Chapter 2 — mở world map region silverwood + expedition.
	_chapter(db, "ch02_silver_forest", "Rừng Bạc", 2, "chapter", ["s_silverwood_boss"], ["forest_guardian"],
		"ch02_intro", "", [{"type": "feature", "id": "expedition"}, {"type": "rune", "id": "fire_atk"}],
		"expedition", "silverwood", "ch01_broken_kingdom")
	# Chapter 3 — mở arena (PvP bot).
	_chapter(db, "ch03_guardian", "Thủ Hộ Cổ Thụ", 3, "chapter", ["s_silverwood_boss"], ["forest_guardian"],
		"ch03_intro", "", [{"type": "feature", "id": "arena"}], "arena", "silverwood", "ch02_silver_forest")
	# Chapter 4-10 placeholder hợp lệ (trỏ stage/boss P4; text điền sau).
	var prev := "ch03_guardian"
	for i in range(4, 11):
		var cid := "ch%02d_placeholder" % i
		_chapter(db, cid, "Chương %d" % i, i, "chapter", ["s_silverwood_boss"], ["abyss_dragon"],
			"", "", [{"type": "gems", "amount": 100}], "", "iron_mountain", prev)
		prev = cid
	# Arc lớn — World / Abyss / Final (placeholder, trỏ world boss).
	_chapter(db, "arc_world", "Đại Arc — Thế Giới", 11, "world", ["s_silverwood_boss"], ["abyss_dragon"],
		"", "", [{"type": "feature", "id": "world_boss"}], "world_boss", "iron_mountain", prev)
	_chapter(db, "arc_abyss", "Đại Arc — Vực Sâu", 12, "abyss", ["s_silverwood_boss"], ["abyss_dragon"],
		"", "", [{"type": "gems", "amount": 300}], "", "iron_mountain", "arc_world")
	_chapter(db, "arc_final", "Đại Arc — Kết", 13, "final", ["s_silverwood_boss"], ["abyss_dragon"],
		"", "", [{"type": "cosmetic", "id": "crown_of_dawn"}], "", "iron_mountain", "arc_abyss")

static func _chapter(db, id: String, nm: String, order: int, arc: String, stages: Array, bosses: Array,
		intro: String, boss_intro: String, rewards: Array, gate: String, region: String, prereq: String) -> void:
	var c := ChapterDef.new()
	c.id = StringName(id); c.display_name = nm; c.order_index = order; c.arc = StringName(arc)
	c.stage_ids.assign(_sn(stages)); c.boss_ids.assign(_sn(bosses))
	c.intro_dialogue_id = StringName(intro); c.boss_intro_id = StringName(boss_intro)
	c.unlock_rewards = rewards; c.unlock_gate = StringName(gate)
	c.region_id = StringName(region); c.prerequisite_id = StringName(prereq)
	db.chapter_defs[id] = c

static func _sn(arr: Array) -> Array:
	var out: Array = []
	for x in arr:
		out.append(StringName(str(x)))
	return out

# --- events (Season of Frost) ----------------------------------------------
static func _events(db) -> void:
	_event(db, "frost_festival", "Lễ Hội Băng Giá", "Festival", EventDef.PRIORITY_MEDIUM, 3600.0,
		[{"target": "mood_bonus", "value": 15.0}],
		[{"type": "currency", "id": "frost_shard", "amount": 50}, {"type": "cosmetic", "id": "winter_hat"}],
		"frost_shard", "frost_frozen_fortress")
	_event(db, "blizzard", "Bão Tuyết", "Combat", EventDef.PRIORITY_MEDIUM, 2400.0,
		[{"target": "monster_spawn_rate", "value": 0.5}, {"target": "loot_rate", "value": 0.3}],
		[{"type": "currency", "id": "frost_shard", "amount": 30}], "frost_shard", "")
	_event(db, "double_rune_day", "Ngày Rune Đôi", "Economy", EventDef.PRIORITY_MINOR, 1800.0,
		[{"target": "rune_xp_rate", "value": 1.0}],
		[{"type": "material", "id": "herb", "amount": 5}], "", "")

static func _event(db, id: String, nm: String, cat: String, prio: int, dur: float,
		mods: Array, rewards: Array, currency: String, dlg: String) -> void:
	var e := EventDef.new()
	e.id = StringName(id); e.display_name = nm; e.category = StringName(cat); e.priority = prio
	e.duration_sec = dur; e.modifiers = mods; e.rewards = rewards
	e.currency_id = StringName(currency); e.story_dialogue_id = StringName(dlg)
	e.notification_text = nm + " đang diễn ra!"
	db.event_defs[id] = e

# --- battle pass -----------------------------------------------------------
static func _battle_pass(db) -> void:
	var bp := BattlePassDef.new()
	bp.id = &"frost_pass"; bp.season_id = &"season_of_frost"; bp.max_level = 50; bp.xp_per_level = 100
	bp.free_rewards = [
		{"level": 1, "type": "material", "id": "herb", "amount": 3},
		{"level": 2, "type": "currency", "id": "frost_shard", "amount": 20},
		{"level": 5, "type": "gems", "amount": 50},
	]
	bp.premium_rewards = [
		{"level": 1, "type": "cosmetic", "id": "winter_skin"},
		{"level": 3, "type": "cosmetic", "id": "frost_emote"},
		{"level": 10, "type": "cosmetic", "id": "ice_crown"},
	]
	db.battle_pass_defs["frost_pass"] = bp

# --- Season of Frost (ví dụ tham chiếu đầy đủ) ------------------------------
static func _season_of_frost(db) -> void:
	var s := SeasonDef.new()
	s.id = &"season_of_frost"; s.display_name = "Mùa Băng Giá"; s.number = 1
	s.abyss_mutation_id = &"frost_abyss"; s.duration_days = 56
	s.story_arc_chapter_ids = [&"arc_world"]
	s.seasonal_boss_id = &"abyss_dragon"        # dùng boss P4 làm biến dị Ice (demo)
	s.event_ids = [&"frost_festival", &"blizzard", &"double_rune_day"]
	s.meta_rotation = {
		"rune_buffs": [{"rune_id": "fire_atk", "stat": "bonus_attack", "mult": 0.15}],
		"equip_buffs": [{"set_id": "guardian", "stat": "bonus_defense", "mult": 0.10}],
		"synergy_buffs": [{"synergy_id": "elf_syn", "bonus": {"crit_chance": 0.05}}],
	}
	s.battle_pass_id = &"frost_pass"
	s.seasonal_currency_id = &"frost_shard"
	s.seasonal_shop_id = &"frost_shop"
	s.world_evolution_rules = [
		{"trigger": "boss_survived", "condition": "abyss_dragon", "region": "iron_mountain", "world_state_key": "corruption", "value": true},
		{"trigger": "boss_defeated", "condition": "abyss_dragon", "region": "iron_mountain", "world_state_key": "frozen_fortress_open", "value": true},
	]
	s.visual_theme_id = &"frost"
	s.next_season_id = &""
	db.season_defs["season_of_frost"] = s
	db.seasonal_shops["frost_shop"] = [
		{"cost": 200, "currency": "frost_shard", "reward": {"type": "cosmetic", "id": "winter_avatar"}},
		{"cost": 100, "currency": "frost_shard", "reward": {"type": "material", "id": "herb", "amount": 10}},
		{"cost": 500, "currency": "frost_shard", "reward": {"type": "cosmetic", "id": "frost_rune_skin"}},
	]
