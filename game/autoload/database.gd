extends Node
## Nguồn content tập trung (data-driven). Items + enemies + danh mục cửa hàng.
## Thêm content = thêm 1 dòng ở đây. Có thể chuyển sang .tres trong editor sau.

var items: Dictionary = {}     # id -> ItemData
var enemies: Dictionary = {}   # id -> EnemyData
var hero_defs: Dictionary = {} # id -> HeroDef
var building_defs: Dictionary = {} # id -> BuildingDef
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

func get_building_def(id: String) -> BuildingDef:
	return building_defs.get(id)

func _build_buildings() -> void:
	_building("inn", "inn", "Nhà Trọ", 3, {"heal_rate": 30.0}, {"heal_rate": 20.0}, 150)
	_building("market", "market", "Cửa Hàng", 1, {"potion_price": 40.0}, {}, 200)
	_building("blacksmith", "blacksmith", "Xưởng Rèn", 1, {"repair_price": 30.0, "durability_restore": 100.0}, {}, 200)

func _building(id: String, type: String, nm: String, mx: int, base: Dictionary, per: Dictionary, cost: int) -> void:
	var b := BuildingDef.new()
	b.id = id; b.type = type; b.display_name = nm; b.max_level = mx
	b.base_params = base; b.per_level = per; b.upgrade_cost_base = cost
	building_defs[id] = b

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
		{"aggression": 1.15, "rest_threshold": 0.40, "repair_threshold": 0.25})
	_hero("archer", "Beo", "ranger", "rusty_sword", "elf_m",
		{"aggression": 1.05, "rest_threshold": 0.42, "repair_threshold": 0.30})
	_hero("mage", "Mira", "mage", "rusty_sword", "wizard_m",
		{"aggression": 1.0, "rest_threshold": 0.45, "repair_threshold": 0.30})
	_hero("cleric", "Kane", "support", "rusty_sword", "knight_f",
		{"aggression": 0.7, "rest_threshold": 0.6, "repair_threshold": 0.35})

func _hero(id: String, nm: String, cls: String, weapon: String, sprite: String, weights: Dictionary) -> void:
	var h := HeroDef.new()
	h.id = id; h.display_name = nm; h.hero_class = cls
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
	# Nguyên liệu
	_material("slime_gel", "Nhớt Slime", Color(0.5, 0.8, 0.5), 2)
	_material("bone", "Xương", Color(0.9, 0.9, 0.8), 3)

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
