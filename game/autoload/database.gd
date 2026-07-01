extends Node
## Nguồn content tập trung (data-driven). Items + enemies + danh mục cửa hàng.
## Thêm content = thêm 1 dòng ở đây. Có thể chuyển sang .tres trong editor sau.

var items: Dictionary = {}     # id -> ItemData
var enemies: Dictionary = {}   # id -> EnemyData
var hero_defs: Dictionary = {} # id -> HeroDef
var building_defs: Dictionary = {} # id -> BuildingDef
var region_defs: Dictionary = {} # id -> RegionDef
var zone_defs: Dictionary = {} # id -> ZoneDef
var equip_defs: Dictionary = {} # id -> EquipDef (P3)
var rune_defs: Dictionary = {} # id -> RuneDef
var synergy_defs: Dictionary = {} # id -> SynergyDef
var set_bonuses: Dictionary = {} # set_id -> {2:{stat:pct},4:{...}}
var resonances: Dictionary = {} # Element(int) -> {stat:pct}
var banner_defs: Dictionary = {} # id -> BannerDef (P3-cont gacha)
var awaken_defs: Dictionary = {} # hero_def_id -> AwakenDef
# --- P4: boss / stage / formation / arena ---
var skill_defs: Dictionary = {}        # id -> SkillDef (hero+boss dùng chung)
var boss_defs: Dictionary = {}         # id -> BossDef
var boss_phase_defs: Dictionary = {}   # id -> BossPhaseDef
var formation_defs: Dictionary = {}    # id -> FormationDef
var stage_defs: Dictionary = {}        # id -> StageDef
var boss_minion_groups: Dictionary = {} # group_id -> Array[enemy_id]
var world_boss_rotation: Array = []    # day_of_week(0..6) -> boss_def_id
var arena_bot_pool: Array = []         # Array[Dictionary] snapshot bot mẫu (seed vòng đời PvP)
var monster_pool: Array[String] = ["slime", "bat", "skeleton"]   # Bãi Săn MVP
var shop_stock: Array[String] = ["health_potion", "leather_armor", "iron_sword", "chain_armor", "knight_blade"]

const C_COMMON := Color(0.72, 0.72, 0.72)
const C_UNCOMMON := Color(0.40, 0.85, 0.40)
const C_RARE := Color(0.40, 0.60, 1.00)

func _ready() -> void:
	_build_items()
	_build_enemies()
	_build_heroes()
	_build_buildings()
	_build_world()
	_build_p3()
	ContentP4.build(self)                  # boss/stage/formation/arena (tách file, <300 dòng)

func get_building_def(id: String) -> BuildingDef:
	return building_defs.get(id)

func _build_buildings() -> void:
	# 7 building — mỗi cái 1 service (type = khóa ServiceRegistry). Cost curve số mũ.
	_building("inn", "Nhà Trọ", 5, {"heal_rate": 30.0}, {"heal_rate": 20.0}, 150, 1.6)
	_building("market", "Cửa Hàng", 3, {"potion_price": 40.0}, {}, 200, 1.5)
	_building("blacksmith", "Xưởng Rèn", 3, {"repair_price": 30.0}, {"repair_price": -3.0}, 200, 1.6)
	_building("training", "Sân Huấn Luyện", 3, {"train_price": 25.0}, {}, 220, 1.6)
	_building("alchemy", "Phòng Chế Dược", 3, {"heal_injury_price": 60.0}, {"heal_injury_price": -8.0}, 240, 1.6)
	_building("kitchen", "Nhà Bếp", 3, {"food_yield": 3.0}, {"food_yield": 2.0}, 180, 1.5)
	_building("guild", "Hội Quán", 3, {"energy_cap_bonus": 20.0, "roster_cap_bonus": 1.0}, {"energy_cap_bonus": 20.0, "roster_cap_bonus": 1.0}, 300, 1.8)

func _building(id: String, nm: String, mx: int, base: Dictionary, per: Dictionary, cost: int, growth: float) -> void:
	var b := BuildingDef.new()
	b.id = id; b.type = id; b.display_name = nm; b.max_level = mx
	b.base_params = base; b.per_level = per
	b.upgrade_cost_base = cost; b.cost_base = cost; b.cost_growth = growth
	building_defs[id] = b

# --- World map: regions + zones (data-driven, reuse EnemyData P1) ----------
func get_region_def(id: String) -> RegionDef:
	return region_defs.get(id)

func get_zone_def(id: String) -> ZoneDef:
	return zone_defs.get(id)

func region_ids() -> Array:
	return region_defs.keys()

func zone_ids() -> Array:
	return zone_defs.keys()

func _build_world() -> void:
	_region("valoria", "Vương Quốc Valoria", "plains", 1, ["beginner_field", "goblin_camp", "wolf_hill"])
	_region("silverwood", "Rừng Bạc", "forest", 8, ["whisper_grove", "ancient_tree"])
	_region("iron_mountain", "Núi Sắt", "mountain", 15, ["mine_entrance"])

	#     id, region, name, req_lv, unlock_stars, prereq, rec_power, pool, e_count, dur, energy, gmin, gmax, xp
	_zone("beginner_field", "valoria", "Cánh Đồng Tân Thủ", 1, 0, "", 10, ["slime", "bat"], 2, 180.0, 15, 15, 40, 12)
	_zone("goblin_camp", "valoria", "Trại Goblin", 3, 2, "beginner_field", 30, ["slime", "skeleton"], 3, 240.0, 20, 30, 70, 20)
	_zone("wolf_hill", "valoria", "Đồi Sói", 6, 2, "goblin_camp", 60, ["skeleton", "bat"], 3, 300.0, 25, 50, 110, 32)
	_zone("whisper_grove", "silverwood", "Rừng Thì Thầm", 8, 3, "wolf_hill", 90, ["skeleton", "slime"], 4, 360.0, 30, 80, 160, 45)
	_zone("ancient_tree", "silverwood", "Cổ Thụ", 12, 3, "whisper_grove", 140, ["skeleton", "bat"], 4, 420.0, 35, 120, 220, 60)
	_zone("mine_entrance", "iron_mountain", "Cửa Mỏ", 15, 3, "ancient_tree", 200, ["skeleton"], 5, 480.0, 40, 180, 320, 80)

func _region(id: String, nm: String, theme: String, req_lv: int, zones: Array) -> void:
	var r := RegionDef.new()
	r.id = id; r.display_name = nm; r.theme = theme; r.required_level = req_lv
	r.zone_ids.assign(zones)
	region_defs[id] = r

func _zone(id: String, region: String, nm: String, req_lv: int, unlock_stars: int, prereq: String,
		rec_power: int, pool: Array, e_count: int, dur: float, energy: int, gmin: int, gmax: int, xp: int) -> void:
	var z := ZoneDef.new()
	z.id = id; z.region_id = region; z.display_name = nm
	z.required_level = req_lv; z.unlock_by_stars = unlock_stars; z.prereq_zone_id = prereq
	z.recommended_power = rec_power
	z.monster_pool.assign(pool)
	z.enemy_count = e_count; z.duration_sec = dur; z.energy_cost = energy
	z.reward_gold_min = gmin; z.reward_gold_max = gmax; z.reward_xp = xp
	zone_defs[id] = z

# --- P3 build content (equipment/rune/synergy/set/resonance) ----------------
func get_equip_def(id: String) -> EquipDef:
	return equip_defs.get(id)

func get_rune_def(id: String) -> RuneDef:
	return rune_defs.get(id)

func get_synergy_def(id: String) -> SynergyDef:
	return synergy_defs.get(id)

func get_set_bonus(set_id: String) -> Variant:
	return set_bonuses.get(set_id)

func get_resonance(element: int) -> Dictionary:
	return resonances.get(element, {})

func _build_p3() -> void:
	_equip("warrior_sword", Enums.EquipSlot.WEAPON, Enums.WeaponType.SWORD, "Kiếm Chiến Binh", ["tank", "warrior"], ItemData.Rarity.RARE, "bonus_attack", 30.0, "")
	_equip("mage_staff", Enums.EquipSlot.WEAPON, Enums.WeaponType.STAFF, "Trượng Pháp Sư", ["mage"], ItemData.Rarity.RARE, "bonus_attack", 26.0, "")
	_equip("guardian_armor", Enums.EquipSlot.ARMOR, Enums.WeaponType.SHIELD, "Giáp Vệ Thần", [], ItemData.Rarity.EPIC, "bonus_defense", 22.0, "guardian")
	_equip("guardian_helm", Enums.EquipSlot.HELMET, Enums.WeaponType.SHIELD, "Mũ Vệ Thần", [], ItemData.Rarity.EPIC, "bonus_defense", 12.0, "guardian")
	_equip("shadow_gloves", Enums.EquipSlot.GLOVES, Enums.WeaponType.DAGGER, "Găng Bóng Tối", [], ItemData.Rarity.EPIC, "bonus_speed", 6.0, "shadow")
	_equip("shadow_boots", Enums.EquipSlot.BOOTS, Enums.WeaponType.DAGGER, "Giày Bóng Tối", [], ItemData.Rarity.EPIC, "bonus_speed", 8.0, "shadow")
	_equip("hp_necklace", Enums.EquipSlot.NECKLACE, Enums.WeaponType.ORB, "Dây Chuyền Sinh Lực", [], ItemData.Rarity.RARE, "bonus_max_hp", 40.0, "")
	_equip("crit_ring", Enums.EquipSlot.RING, Enums.WeaponType.ORB, "Nhẫn Chí Mạng", [], ItemData.Rarity.LEGENDARY, "bonus_attack", 15.0, "")

	set_bonuses["guardian"] = {2: {"bonus_defense": 0.10}, 4: {"bonus_max_hp": 0.15}}
	set_bonuses["shadow"] = {2: {"crit_chance": 0.05}, 4: {"crit_damage": 0.30}}

	_rune_core("berserker_core", Enums.RuneCategory.OFFENSIVE, {"bonus_attack": 0.25, "bonus_defense": -0.15})
	_rune_core("guardian_core", Enums.RuneCategory.DEFENSIVE, {"bonus_defense": 0.20})
	_rune("fire_atk", Enums.RuneCategory.OFFENSIVE, Enums.Element.FIRE, "bonus_attack", 8.0, 1.0, {5: {"crit_chance": 0.05}, 10: {"bonus_attack": 0.10}})
	_rune("fire_hp", Enums.RuneCategory.DEFENSIVE, Enums.Element.FIRE, "bonus_max_hp", 20.0, 3.0, {10: {"bonus_max_hp": 0.10}})
	_rune("ice_def", Enums.RuneCategory.DEFENSIVE, Enums.Element.ICE, "bonus_defense", 6.0, 0.8, {5: {"bonus_defense": 0.08}})
	_rune("util_speed", Enums.RuneCategory.UTILITY, Enums.Element.WIND, "bonus_speed", 5.0, 0.5, {})

	resonances[Enums.Element.FIRE] = {"bonus_attack": 0.15}
	resonances[Enums.Element.ICE] = {"bonus_defense": 0.15}

	_synergy("human_syn", "race", "human", {3: {"bonus_max_hp": 0.10}, 5: {"bonus_max_hp": 0.15}})
	_synergy("elf_syn", "race", "elf", {3: {"crit_chance": 0.10}})
	_synergy("mage_syn", "class", "mage", {3: {"bonus_attack": 0.10}})

	# Gacha banner + awaken (P3-cont)
	_banner("standard", "Triệu Hồi Thường", [
		{"hero_def_id": "knight", "rarity": 3, "weight": 1.0},
		{"hero_def_id": "rogue", "rarity": 2, "weight": 3.0},
		{"hero_def_id": "mage", "rarity": 2, "weight": 3.0},
		{"hero_def_id": "archer", "rarity": 1, "weight": 8.0},
		{"hero_def_id": "cleric", "rarity": 1, "weight": 8.0},
	])
	_awaken("knight", 40, "battle_lord", "guardian_wall_plus", {"bonus_attack": 10.0})

# --- P4 getters (façade duy nhất — không load() rải rác) --------------------
func get_skill_def(id: String) -> SkillDef:
	return skill_defs.get(id)

func get_boss_def(id: String) -> BossDef:
	return boss_defs.get(id)

func get_boss_phase_def(id: String) -> BossPhaseDef:
	return boss_phase_defs.get(id)

## Phases (theo thứ tự phase_ids) của 1 boss -> Array[BossPhaseDef].
func boss_phases(def: BossDef) -> Array:
	var out: Array = []
	if def == null:
		return out
	for pid in def.phase_ids:
		var p: BossPhaseDef = boss_phase_defs.get(str(pid))
		if p != null:
			out.append(p)
	return out

func get_formation_def(id: String) -> FormationDef:
	return formation_defs.get(id)

func get_stage_def(id: String) -> StageDef:
	return stage_defs.get(id)

func stage_ids() -> Array:
	return stage_defs.keys()

func boss_def_ids() -> Array:
	return boss_defs.keys()

func get_boss_minion_group(group_id: String) -> Array:
	return boss_minion_groups.get(group_id, [])

## Boss-of-the-day theo day_of_week (0..6). "" nếu chưa cấu hình.
func world_boss_for_day(dow: int) -> String:
	if world_boss_rotation.is_empty():
		return ""
	return str(world_boss_rotation[dow % world_boss_rotation.size()])

func get_banner_def(id: String) -> BannerDef:
	return banner_defs.get(id)

func get_awaken_def(hero_def_id: String) -> AwakenDef:
	return awaken_defs.get(hero_def_id)

func banner_ids() -> Array:
	return banner_defs.keys()

func _banner(id: String, nm: String, pool: Array) -> void:
	var b := BannerDef.new()
	b.id = id; b.display_name = nm; b.pool = pool
	banner_defs[id] = b

func _awaken(hero_def_id: String, cost: int, passive: String, ult: String, bonus: Dictionary) -> void:
	var a := AwakenDef.new()
	a.hero_def_id = hero_def_id; a.shard_cost = cost
	a.new_passive_id = passive; a.upgraded_ultimate_id = ult; a.stat_bonus = bonus
	awaken_defs[hero_def_id] = a

func _equip(id: String, slot: int, wtype: int, nm: String, allowed: Array, rarity: int, main_key: String, main_base: float, set_id: String) -> void:
	var e := EquipDef.new()
	e.id = id; e.slot = slot; e.weapon_type = wtype; e.display_name = nm
	e.allowed_class.assign(allowed); e.rarity = rarity
	e.main_stat_key = main_key; e.main_stat_base = main_base; e.set_id = set_id
	equip_defs[id] = e

func _rune(id: String, cat: int, elem: int, main_key: String, main_base: float, per_lvl: float, unlocks: Dictionary) -> void:
	var r := RuneDef.new()
	r.id = id; r.category = cat; r.element = elem; r.main_stat_key = main_key
	r.main_stat_base = main_base; r.per_level_gain = per_lvl; r.level_unlock_effects = unlocks
	rune_defs[id] = r

func _rune_core(id: String, cat: int, core_pct: Dictionary) -> void:
	var r := RuneDef.new()
	r.id = id; r.category = cat; r.is_core = true; r.core_percent = core_pct
	r.main_stat_base = 0.0; r.per_level_gain = 0.0   # core chỉ cho % (core_percent), không main flat
	rune_defs[id] = r

func _synergy(id: String, kind: String, key: String, thresholds: Dictionary) -> void:
	var s := SynergyDef.new()
	s.id = id; s.kind = kind; s.key = key; s.thresholds = thresholds
	synergy_defs[id] = s

func get_item(id: String) -> ItemData:
	return items.get(id)

func get_enemy(id: String) -> EnemyData:
	return enemies.get(id)

func get_hero_def(id: String) -> HeroDef:
	return hero_defs.get(id)

func hero_def_ids() -> Array:
	return hero_defs.keys()

func _build_heroes() -> void:
	# 5 hero khởi tạo, khác class/tính cách (ai_weights data-driven).
	_hero("knight", "Rogan", "tank", "iron_sword", "knight_m",
		{"aggression": 0.85, "rest_threshold": 0.55, "repair_threshold": 0.30})
	_hero("rogue", "Luna", "rogue", "iron_sword", "elf_f",
		{"aggression": 1.15, "rest_threshold": 0.40, "repair_threshold": 0.25}, "elf")
	_hero("archer", "Beo", "ranger", "rusty_sword", "elf_m",
		{"aggression": 1.05, "rest_threshold": 0.42, "repair_threshold": 0.30}, "elf")
	_hero("mage", "Mira", "mage", "rusty_sword", "wizard_m",
		{"aggression": 1.0, "rest_threshold": 0.45, "repair_threshold": 0.30})
	_hero("cleric", "Kane", "support", "rusty_sword", "knight_f",
		{"aggression": 0.7, "rest_threshold": 0.6, "repair_threshold": 0.35})

func _hero(id: String, nm: String, cls: String, weapon: String, sprite: String, weights: Dictionary, race: String = "human") -> void:
	var h := HeroDef.new()
	h.id = id; h.display_name = nm; h.hero_class = cls; h.class_role = cls; h.race = race
	h.start_weapon = weapon; h.sprite = sprite; h.ai_weights = weights
	hero_defs[id] = h

func _build_items() -> void:
	# Vũ khí
	_weapon("rusty_sword", "Kiếm Gỉ", ItemData.Rarity.COMMON, C_COMMON, 5, 6)
	_weapon("iron_sword", "Kiếm Sắt", ItemData.Rarity.UNCOMMON, C_UNCOMMON, 18, 12)
	_weapon("knight_blade", "Đao Hiệp Sĩ", ItemData.Rarity.RARE, C_RARE, 50, 20, 2)
	# Giáp
	_armor("leather_armor", "Giáp Da", ItemData.Rarity.COMMON, C_COMMON, 5, 4, 10)
	_armor("chain_armor", "Giáp Xích", ItemData.Rarity.UNCOMMON, C_UNCOMMON, 18, 8, 25)
	# Tiêu hao
	_consumable("health_potion", "Bình Máu", C_COMMON, 4, 45)
	_consumable("food_ration", "Suất Ăn", Color(0.8, 0.7, 0.4), 3, 0)     # +stamina (Nhà Bếp)
	_consumable("medicine", "Thuốc Trị Thương", Color(0.6, 0.85, 0.6), 6, 0)  # trị injury (Chế Dược)
	# Nguyên liệu
	_material("slime_gel", "Nhớt Slime", Color(0.5, 0.8, 0.5), 2)
	_material("bone", "Xương", Color(0.9, 0.9, 0.8), 3)
	_material("herb", "Thảo Dược", Color(0.4, 0.8, 0.5), 3)               # input chế dược

func _build_enemies() -> void:
	_enemy("slime", "Slime", 24, 40.0, 6, 0.9, 140.0, 4, 2, 5, Color(0.4, 0.8, 0.4), 7.0,
		[{"id": "slime_gel", "chance": 0.6}, {"id": "rusty_sword", "chance": 0.05}], "swampy", true)
	_enemy("bat", "Dơi", 16, 72.0, 5, 0.7, 165.0, 3, 1, 4, Color(0.6, 0.4, 0.7), 6.0,
		[{"id": "bone", "chance": 0.4}], "imp", false)
	_enemy("skeleton", "Bộ Xương", 42, 48.0, 11, 0.85, 150.0, 9, 4, 9, Color(0.85, 0.85, 0.8), 8.0,
		[{"id": "bone", "chance": 0.7}, {"id": "iron_sword", "chance": 0.08},
		 {"id": "chain_armor", "chance": 0.04}, {"id": "health_potion", "chance": 0.15}], "skelet", false)

# --- helpers --------------------------------------------------------------
func _weapon(id: String, name: String, rarity: ItemData.Rarity, color: Color, sell: int, atk: int, def: int = 0) -> void:
	var it := ItemData.new()
	it.id = id; it.display_name = name; it.type = ItemData.Type.WEAPON
	it.rarity = rarity; it.icon_color = color; it.sell_price = sell
	it.bonus_attack = atk; it.bonus_defense = def
	items[id] = it

func _armor(id: String, name: String, rarity: ItemData.Rarity, color: Color, sell: int, def: int, hp: int) -> void:
	var it := ItemData.new()
	it.id = id; it.display_name = name; it.type = ItemData.Type.ARMOR
	it.rarity = rarity; it.icon_color = color; it.sell_price = sell
	it.bonus_defense = def; it.bonus_max_hp = hp
	items[id] = it

func _consumable(id: String, name: String, color: Color, sell: int, heal: int) -> void:
	var it := ItemData.new()
	it.id = id; it.display_name = name; it.type = ItemData.Type.CONSUMABLE
	it.rarity = ItemData.Rarity.COMMON; it.icon_color = color; it.sell_price = sell
	it.heal_amount = heal
	items[id] = it

func _material(id: String, name: String, color: Color, sell: int) -> void:
	var it := ItemData.new()
	it.id = id; it.display_name = name; it.type = ItemData.Type.MATERIAL
	it.rarity = ItemData.Rarity.COMMON; it.icon_color = color; it.sell_price = sell
	items[id] = it

func _enemy(id: String, name: String, hp: int, spd: float, dmg: int, interval: float, aggro: float,
		xp: int, gmin: int, gmax: int, color: Color, sz: float, drops: Array,
		sprite: String, single: bool) -> void:
	var e := EnemyData.new()
	e.id = id; e.display_name = name; e.max_hp = hp; e.speed = spd
	e.contact_damage = dmg; e.attack_interval = interval; e.aggro_range = aggro
	e.xp_reward = xp; e.gold_drop_min = gmin; e.gold_drop_max = gmax
	e.body_color = color; e.size = sz; e.drops = drops
	e.sprite = sprite; e.sprite_single = single
	enemies[id] = e
