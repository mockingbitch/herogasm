extends Node
## Hồ sơ TÀI KHOẢN (bền vững) — thay Profile cũ. Giữ ví + roster hero + kho chung town.
## Chỉ số per-hero nằm trong HeroInstance; PlayerProfile điều phối economy/save/emit.

const CONSTANTS_PATH := "res://data/combat_constants.tres"

var gold: int = 0
var gems: int = 0                                  # tiền cứng (gacha P3)
var hero_ids: Array[String] = []                   # thứ tự roster
var heroes: Dictionary = {}                        # hero_id -> HeroInstance
var consumables: Dictionary = {}                   # id -> count (kho chung town)
var materials: Dictionary = {}                     # id -> count (kho chung town)
var unlocks: Dictionary = {}                       # cờ mở khoá (region/building) — placeholder

var _constants: CombatConstants
var _hero_seq: int = 0                             # sinh hero_id duy nhất

func _ready() -> void:
	_constants = load(CONSTANTS_PATH) as CombatConstants
	if _constants == null:
		_constants = CombatConstants.new()
	var data := SaveManager.load_game()
	if data.is_empty():
		new_game()
	else:
		from_dict(data)
	_emit_all()
	Telemetry.log_event("Player", "game_start", {"heroes": hero_ids.size(), "gold": gold})

func new_game() -> void:
	gold = 0
	gems = 0
	hero_ids = []
	heroes = {}
	consumables = {}
	materials = {}
	unlocks = {}
	_hero_seq = 0
	var starter := spawn_hero("", "Tân Binh")
	starter.equipment["weapon"] = HeroInstance.make_instance("rusty_sword")  # không affix (như bản cũ)
	starter.reset_hp()
	add_consumable("health_potion", 2)
	Telemetry.log_event("Player", "new_game", {})
	save()

func reset_progress() -> void:
	SaveManager.delete_save()
	new_game()
	_emit_all()

# --- roster ---------------------------------------------------------------
func spawn_hero(def_id: String, display_name: String = "") -> HeroInstance:
	var h := HeroInstance.new()
	h.hero_id = "hero_%d" % _hero_seq
	_hero_seq += 1
	h.hero_def_id = def_id
	h.display_name = display_name
	h.set_constants(_constants)
	h.reset_hp()
	heroes[h.hero_id] = h
	hero_ids.append(h.hero_id)
	EventBus.hero_spawned.emit(h.hero_id)
	return h

func get_hero(id: String) -> HeroInstance:
	return heroes.get(id)

func primary_hero() -> HeroInstance:
	if hero_ids.is_empty():
		return null
	return heroes.get(hero_ids[0])

func knock_out(id: String) -> void:
	var h: HeroInstance = get_hero(id)
	if h == null or h.is_knocked_out():
		return
	h.current_hp = 0
	EventBus.hero_knocked_out.emit(id)

# --- ví -------------------------------------------------------------------
func add_gold(amount: int) -> void:
	gold = maxi(gold + amount, 0)
	EventBus.gold_changed.emit(gold)

func add_gems(amount: int) -> void:
	gems = maxi(gems + amount, 0)
	EventBus.gems_changed.emit(gems)

# --- kho chung ------------------------------------------------------------
func add_consumable(id: String, n: int = 1) -> void:
	consumables[id] = int(consumables.get(id, 0)) + n
	EventBus.consumables_changed.emit()

func add_material(id: String, n: int = 1) -> void:
	materials[id] = int(materials.get(id, 0)) + n
	EventBus.inventory_changed.emit()

func potion_count() -> int:
	return int(consumables.get("health_potion", 0))

func use_potion() -> int:
	var id := "health_potion"
	if int(consumables.get(id, 0)) <= 0:
		return 0
	consumables[id] = int(consumables[id]) - 1
	EventBus.consumables_changed.emit()
	var data: ItemData = Database.get_item(id)
	return data.heal_amount if data else 0

## Định tuyến 1 item vào tài khoản/hero (mua hoặc nhặt). Gear -> vào inventory hero chính.
func add_item(id: String) -> void:
	var data: ItemData = Database.get_item(id)
	if data == null:
		return
	match data.type:
		ItemData.Type.CONSUMABLE:
			add_consumable(id, 1)
		ItemData.Type.MATERIAL:
			add_material(id, 1)
		_:
			var h: HeroInstance = primary_hero()
			if h != null:
				h.inventory.append(h.roll_instance(id))
				EventBus.inventory_changed.emit()
	EventBus.item_picked_up.emit(id)

# --- shop / forge (math kinh tế; gold ở account) --------------------------
func buy_price(id: String) -> int:
	var data: ItemData = Database.get_item(id)
	return data.sell_price * _constants.buy_markup if data else 0

func buy(id: String) -> bool:
	var price := buy_price(id)
	if price <= 0 or gold < price:
		return false
	add_gold(-price)
	add_item(id)
	save()
	return true

func upgrade_hero_gear(hero_id: String, slot: String) -> bool:
	var h: HeroInstance = get_hero(hero_id)
	if h == null:
		return false
	var cost := h.upgrade_cost(slot)
	if cost <= 0 or gold < cost:
		return false
	add_gold(-cost)
	h.upgrade_gear(slot)
	EventBus.equipment_changed.emit()
	save()
	return true

func sell_hero_gear(hero_id: String, inv_index: int) -> bool:
	var h: HeroInstance = get_hero(hero_id)
	if h == null or inv_index < 0 or inv_index >= h.inventory.size():
		return false
	var inst: Dictionary = h.inventory[inv_index]
	var data: ItemData = Database.get_item(inst["id"])
	var value := 0
	if data:
		value = int(round(data.sell_price * (1.0 + 0.5 * int(inst["level"]))))
		value += inst.get("affixes", []).size() * 3
	h.inventory.remove_at(inv_index)
	add_gold(value)
	EventBus.inventory_changed.emit()
	save()
	return true

func sell_all_materials() -> int:
	var total := 0
	for id in materials.keys():
		var data: ItemData = Database.get_item(id)
		if data:
			total += data.sell_price * int(materials[id])
	materials.clear()
	add_gold(total)
	EventBus.inventory_changed.emit()
	save()
	return total

## Cộng xp cho 1 hero; emit xp/level.
func grant_xp(hero_id: String, amount: int) -> void:
	var h: HeroInstance = get_hero(hero_id)
	if h == null:
		return
	var gained := h.gain_xp(amount)
	if gained > 0:
		EventBus.level_changed.emit(h.level)
	EventBus.xp_changed.emit(h.level, h.xp, h.xp_to_next())

# --- save / load ----------------------------------------------------------
func save() -> void:
	SaveManager.save_game(to_dict())

func to_dict() -> Dictionary:
	var hd: Dictionary = {}
	for id in heroes.keys():
		hd[id] = (heroes[id] as HeroInstance).to_dict()
	return {
		"player": {
			"gold": gold,
			"gems": gems,
			"consumables": consumables,
			"materials": materials,
			"unlocks": unlocks,
		},
		"hero_ids": hero_ids,
		"heroes": hd,
		"world": {},
	}

func from_dict(d: Dictionary) -> void:
	var p = d.get("player", {})
	if typeof(p) != TYPE_DICTIONARY:
		p = {}
	gold = maxi(int(p.get("gold", 0)), 0)
	gems = maxi(int(p.get("gems", 0)), 0)
	consumables = _norm_counts(p.get("consumables", {}))
	materials = _norm_counts(p.get("materials", {}))
	unlocks = p.get("unlocks", {}) if typeof(p.get("unlocks")) == TYPE_DICTIONARY else {}

	hero_ids = []
	for id in d.get("hero_ids", []):
		hero_ids.append(str(id))
	heroes = {}
	var hd = d.get("heroes", {})
	if typeof(hd) == TYPE_DICTIONARY:
		if hero_ids.is_empty():
			for k in hd.keys():
				hero_ids.append(str(k))
		for id in hero_ids:
			if hd.has(id) and typeof(hd[id]) == TYPE_DICTIONARY:
				var h := HeroInstance.from_dict(hd[id])
				h.hero_id = id
				h.set_constants(_constants)
				heroes[id] = h
	_hero_seq = _max_hero_index() + 1

func _max_hero_index() -> int:
	var mx := -1
	for id in hero_ids:
		var parts := str(id).split("_")
		if parts.size() == 2 and parts[1].is_valid_int():
			mx = maxi(mx, int(parts[1]))
	return mx

func _norm_counts(d) -> Dictionary:
	var out: Dictionary = {}
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for k in d.keys():
		out[str(k)] = int(d[k])
	return out

func _emit_all() -> void:
	EventBus.gold_changed.emit(gold)
	EventBus.gems_changed.emit(gems)
	EventBus.consumables_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.equipment_changed.emit()
	var h: HeroInstance = primary_hero()
	if h != null:
		EventBus.xp_changed.emit(h.level, h.xp, h.xp_to_next())
