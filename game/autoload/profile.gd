extends Node
## Hồ sơ người chơi (BỀN VỮNG). Nguồn chỉ số duy nhất cho Player.
## Instance gear = { "id": String, "level": int, "affixes": Array<{stat,value}> }.

const BASE_ATTACK := 10
const BASE_DEFENSE := 0
const BASE_MAX_HP := 100
const BASE_SPEED := 92.0
const BASE_CRIT_CHANCE := 0.05
const BASE_CRIT_DAMAGE := 1.5

const ATK_PER_LEVEL := 2
const DEF_PER_LEVEL := 1
const HP_PER_LEVEL := 10
const UPGRADE_SCALE := 0.4
const UPGRADE_BASE_COST := 20
const BUY_MARKUP := 4

# Affix có thể roll lên gear. "int" = giá trị nguyên.
const AFFIX_POOL := [
	{"stat": "bonus_attack",  "min": 1.0, "max": 5.0,  "int": true},
	{"stat": "bonus_defense", "min": 1.0, "max": 4.0,  "int": true},
	{"stat": "bonus_max_hp",  "min": 5.0, "max": 20.0, "int": true},
	{"stat": "bonus_speed",   "min": 3.0, "max": 8.0,  "int": true},
	{"stat": "crit_chance",   "min": 0.02, "max": 0.06, "int": false},
	{"stat": "crit_damage",   "min": 0.10, "max": 0.30, "int": false},
	{"stat": "lifesteal",     "min": 0.01, "max": 0.03, "int": false},
]

# Cây talent: mỗi điểm tăng 1 rank, cộng "per" vào "stat".
const TALENTS := {
	"power":     {"name": "Sức Mạnh (+ATK)",      "stat": "bonus_attack", "per": 2.0,  "max": 5},
	"vitality":  {"name": "Sinh Lực (+HP)",        "stat": "bonus_max_hp", "per": 15.0, "max": 5},
	"precision": {"name": "Chính Xác (+Crit%)",    "stat": "crit_chance",  "per": 0.03, "max": 5},
	"ferocity":  {"name": "Hung Tàn (+CritDmg%)",  "stat": "crit_damage",  "per": 0.10, "max": 5},
	"swiftness": {"name": "Nhanh Nhẹn (+Tốc độ)",  "stat": "bonus_speed",  "per": 6.0,  "max": 3},
	"vampirism": {"name": "Hút Máu (+Lifesteal%)", "stat": "lifesteal",    "per": 0.02, "max": 3},
}

var gold: int = 0
var xp: int = 0
var level: int = 1
var talent_points: int = 0
var talents: Dictionary = {}                       # id -> rank
var inventory: Array = []                          # gear instances
var consumables: Dictionary = {}                   # id -> count
var materials: Dictionary = {}                     # id -> count
var equipment: Dictionary = {"weapon": null, "armor": null}

func _ready() -> void:
	var data := SaveManager.load_game()
	if data.is_empty():
		new_game()
	else:
		from_dict(data)
	_emit_all()

func new_game() -> void:
	gold = 0
	xp = 0
	level = 1
	talent_points = 0
	talents = {}
	inventory = []
	consumables = {}
	materials = {}
	equipment = {"weapon": _inst("rusty_sword"), "armor": null}
	add_consumable("health_potion", 2)
	save()

func reset_progress() -> void:
	SaveManager.delete_save()
	new_game()
	_emit_all()

func _inst(id: String, lvl: int = 0, affixes: Array = []) -> Dictionary:
	return {"id": id, "level": lvl, "affixes": affixes}

func roll_instance(id: String) -> Dictionary:
	var data: ItemData = Database.get_item(id)
	var affixes: Array = []
	if data != null and (data.type == ItemData.Type.WEAPON or data.type == ItemData.Type.ARMOR):
		for i in _affix_count(data.rarity):
			affixes.append(_roll_affix())
	return _inst(id, 0, affixes)

func _affix_count(rarity: int) -> int:
	match rarity:
		ItemData.Rarity.UNCOMMON: return 2
		ItemData.Rarity.RARE: return 3
		ItemData.Rarity.EPIC: return 3
		ItemData.Rarity.LEGENDARY: return 4
		_: return 1

func _roll_affix() -> Dictionary:
	var a: Dictionary = AFFIX_POOL[randi() % AFFIX_POOL.size()]
	var v: float
	if a["int"]:
		v = float(randi_range(int(a["min"]), int(a["max"])))
	else:
		v = snappedf(randf_range(a["min"], a["max"]), 0.01)
	return {"stat": a["stat"], "value": v}

# --- gold / items ---------------------------------------------------------
func add_gold(amount: int) -> void:
	gold = maxi(gold + amount, 0)
	EventBus.gold_changed.emit(gold)

func add_item(id: String, _lvl: int = 0) -> void:
	var data: ItemData = Database.get_item(id)
	if data == null:
		return
	match data.type:
		ItemData.Type.CONSUMABLE:
			add_consumable(id, 1)
		ItemData.Type.MATERIAL:
			add_material(id, 1)
		_:
			inventory.append(roll_instance(id))
			EventBus.inventory_changed.emit()
	EventBus.item_picked_up.emit(id)

func add_instance(inst: Dictionary) -> void:
	inventory.append(inst)
	EventBus.inventory_changed.emit()
	EventBus.item_picked_up.emit(str(inst.get("id", "")))

func add_consumable(id: String, n: int = 1) -> void:
	consumables[id] = int(consumables.get(id, 0)) + n
	EventBus.consumables_changed.emit()

func add_material(id: String, n: int = 1) -> void:
	materials[id] = int(materials.get(id, 0)) + n
	EventBus.inventory_changed.emit()

# --- equip ----------------------------------------------------------------
func equip(inv_index: int) -> void:
	if inv_index < 0 or inv_index >= inventory.size():
		return
	var inst: Dictionary = inventory[inv_index]
	var data: ItemData = Database.get_item(inst["id"])
	if data == null:
		return
	var slot := ""
	if data.type == ItemData.Type.WEAPON:
		slot = "weapon"
	elif data.type == ItemData.Type.ARMOR:
		slot = "armor"
	else:
		return
	inventory.remove_at(inv_index)
	if equipment[slot] != null:
		inventory.append(equipment[slot])
	equipment[slot] = inst
	EventBus.equipment_changed.emit()
	EventBus.inventory_changed.emit()
	save()

func unequip(slot: String) -> void:
	if equipment.get(slot) != null:
		inventory.append(equipment[slot])
		equipment[slot] = null
		EventBus.equipment_changed.emit()
		EventBus.inventory_changed.emit()
		save()

# --- forge ----------------------------------------------------------------
func upgrade_cost(slot: String) -> int:
	var inst = equipment.get(slot)
	if inst == null:
		return 0
	return UPGRADE_BASE_COST * (int(inst["level"]) + 1)

func upgrade(slot: String) -> bool:
	var inst = equipment.get(slot)
	if inst == null:
		return false
	var cost := upgrade_cost(slot)
	if gold < cost:
		return false
	gold -= cost
	inst["level"] = int(inst["level"]) + 1
	EventBus.gold_changed.emit(gold)
	EventBus.equipment_changed.emit()
	save()
	return true

# --- shop -----------------------------------------------------------------
func buy_price(id: String) -> int:
	var data: ItemData = Database.get_item(id)
	return data.sell_price * BUY_MARKUP if data else 0

func buy(id: String) -> bool:
	var price := buy_price(id)
	if price <= 0 or gold < price:
		return false
	gold -= price
	add_item(id)
	EventBus.gold_changed.emit(gold)
	save()
	return true

func sell_gear(inv_index: int) -> bool:
	if inv_index < 0 or inv_index >= inventory.size():
		return false
	var inst: Dictionary = inventory[inv_index]
	var data: ItemData = Database.get_item(inst["id"])
	var value := 0
	if data:
		value = int(round(data.sell_price * (1.0 + 0.5 * int(inst["level"]))))
		value += inst.get("affixes", []).size() * 3
	inventory.remove_at(inv_index)
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

# --- consumable -----------------------------------------------------------
func use_potion() -> int:
	var id := "health_potion"
	if int(consumables.get(id, 0)) <= 0:
		return 0
	consumables[id] = int(consumables[id]) - 1
	EventBus.consumables_changed.emit()
	var data: ItemData = Database.get_item(id)
	return data.heal_amount if data else 0

func potion_count() -> int:
	return int(consumables.get("health_potion", 0))

# --- talents --------------------------------------------------------------
func talent_rank(id: String) -> int:
	return int(talents.get(id, 0))

func spend_talent(id: String) -> bool:
	if talent_points <= 0 or not TALENTS.has(id):
		return false
	var rank := talent_rank(id)
	if rank >= int(TALENTS[id]["max"]):
		return false
	talents[id] = rank + 1
	talent_points -= 1
	EventBus.equipment_changed.emit()
	save()
	return true

func _talent_total(stat: String) -> float:
	var total := 0.0
	for tid in talents.keys():
		var d = TALENTS.get(tid)
		if d != null and d["stat"] == stat:
			total += int(talents[tid]) * float(d["per"])
	return total

# --- xp -------------------------------------------------------------------
func xp_to_next() -> int:
	return 20 + level * 15

func gain_xp(amount: int) -> void:
	xp += amount
	var before := level
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
	if level > before:
		talent_points += (level - before)
		EventBus.level_changed.emit(level)
	EventBus.xp_changed.emit(level, xp, xp_to_next())

# --- effective stats ------------------------------------------------------
func _equip_base(field: String) -> float:
	var total := 0.0
	for slot in equipment.keys():
		var inst = equipment[slot]
		if inst == null:
			continue
		var data: ItemData = Database.get_item(inst["id"])
		if data == null:
			continue
		total += float(data.get(field)) * (1.0 + UPGRADE_SCALE * int(inst["level"]))
	return total

func _affix_total(stat: String) -> float:
	var total := 0.0
	for slot in equipment.keys():
		var inst = equipment[slot]
		if inst == null:
			continue
		for a in inst.get("affixes", []):
			if a.get("stat") == stat:
				total += float(a.get("value", 0))
	return total

func _stat(stat: String) -> float:
	return _equip_base(stat) + _affix_total(stat) + _talent_total(stat)

func eff_attack() -> int:
	return BASE_ATTACK + ATK_PER_LEVEL * (level - 1) + int(round(_stat("bonus_attack")))

func eff_defense() -> int:
	return BASE_DEFENSE + DEF_PER_LEVEL * (level - 1) + int(round(_stat("bonus_defense")))

func eff_max_hp() -> int:
	return BASE_MAX_HP + HP_PER_LEVEL * (level - 1) + int(round(_stat("bonus_max_hp")))

func eff_speed() -> float:
	return BASE_SPEED + _stat("bonus_speed")

func eff_crit_chance() -> float:
	return clampf(BASE_CRIT_CHANCE + _affix_total("crit_chance") + _talent_total("crit_chance"), 0.0, 1.0)

func eff_crit_damage() -> float:
	return BASE_CRIT_DAMAGE + _affix_total("crit_damage") + _talent_total("crit_damage")

func eff_lifesteal() -> float:
	return clampf(_affix_total("lifesteal") + _talent_total("lifesteal"), 0.0, 0.8)

# Mô tả 1 instance để hiển thị.
func instance_label(inst) -> String:
	if inst == null:
		return "(trống)"
	var data: ItemData = Database.get_item(inst["id"])
	if data == null:
		return "?"
	var lv := int(inst["level"])
	var f := 1.0 + UPGRADE_SCALE * lv
	var parts: Array = []
	var atk := int(round(data.bonus_attack * f))
	var df := int(round(data.bonus_defense * f))
	var hp := int(round(data.bonus_max_hp * f))
	if atk != 0: parts.append("ATK+%d" % atk)
	if df != 0: parts.append("DEF+%d" % df)
	if hp != 0: parts.append("HP+%d" % hp)
	for a in inst.get("affixes", []):
		parts.append(_affix_text(a))
	var name := data.display_name
	if lv > 0:
		name += " +%d" % lv
	if parts.size() > 0:
		return "%s [%s]" % [name, ", ".join(parts)]
	return name

func _affix_text(a: Dictionary) -> String:
	var v = a.get("value", 0)
	match str(a.get("stat", "")):
		"bonus_attack": return "ATK+%d" % int(v)
		"bonus_defense": return "DEF+%d" % int(v)
		"bonus_max_hp": return "HP+%d" % int(v)
		"bonus_speed": return "Tốc+%d" % int(v)
		"crit_chance": return "Crit+%d%%" % int(round(float(v) * 100))
		"crit_damage": return "CritDmg+%d%%" % int(round(float(v) * 100))
		"lifesteal": return "Hút máu+%d%%" % int(round(float(v) * 100))
		_: return "?"

# --- save / load ----------------------------------------------------------
func save() -> void:
	SaveManager.save_game(to_dict())

func to_dict() -> Dictionary:
	return {
		"gold": gold,
		"xp": xp,
		"level": level,
		"talent_points": talent_points,
		"talents": talents,
		"inventory": inventory,
		"consumables": consumables,
		"materials": materials,
		"equipment": equipment,
	}

func from_dict(d: Dictionary) -> void:
	gold = int(d.get("gold", 0))
	xp = int(d.get("xp", 0))
	level = maxi(int(d.get("level", 1)), 1)
	talent_points = maxi(int(d.get("talent_points", 0)), 0)
	talents = _norm_talents(d.get("talents", {}))
	inventory = _norm_instances(d.get("inventory", []))
	consumables = _norm_counts(d.get("consumables", {}))
	materials = _norm_counts(d.get("materials", {}))
	var eq = d.get("equipment", {})
	if typeof(eq) != TYPE_DICTIONARY:
		eq = {}
	equipment = {
		"weapon": _norm_instance(eq.get("weapon")),
		"armor": _norm_instance(eq.get("armor")),
	}

func _norm_instance(v) -> Variant:
	if typeof(v) != TYPE_DICTIONARY or not v.has("id"):
		return null
	return {"id": str(v["id"]), "level": int(v.get("level", 0)), "affixes": _norm_affixes(v.get("affixes", []))}

func _norm_affixes(arr) -> Array:
	var out: Array = []
	if typeof(arr) != TYPE_ARRAY:
		return out
	for a in arr:
		if typeof(a) == TYPE_DICTIONARY and a.has("stat"):
			out.append({"stat": str(a["stat"]), "value": float(a.get("value", 0))})
	return out

func _norm_instances(arr) -> Array:
	var out: Array = []
	if typeof(arr) != TYPE_ARRAY:
		return out
	for v in arr:
		var inst = _norm_instance(v)
		if inst != null:
			out.append(inst)
	return out

func _norm_counts(d) -> Dictionary:
	var out: Dictionary = {}
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for k in d.keys():
		out[str(k)] = int(d[k])
	return out

func _norm_talents(d) -> Dictionary:
	var out: Dictionary = {}
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for k in d.keys():
		if TALENTS.has(str(k)):
			out[str(k)] = maxi(int(d[k]), 0)
	return out

func _emit_all() -> void:
	EventBus.gold_changed.emit(gold)
	EventBus.xp_changed.emit(level, xp, xp_to_next())
	EventBus.inventory_changed.emit()
	EventBus.equipment_changed.emit()
	EventBus.consumables_changed.emit()
