class_name HeroInstance
extends Resource
## Một hero độc lập (per-hero state + math). Tách từ Profile cũ (player singleton) để
## living-world có N hero cùng dùng chung công thức nhưng state riêng.
## THUẦN dữ liệu + math: KHÔNG đụng EventBus/SaveManager (PlayerProfile điều phối việc đó).
## Instance gear = { "id": String, "level": int, "affixes": Array<{stat,value}> }.

enum State { IDLE = 0 }   # placeholder cho FSM P1 (Utility AI)

# Affix có thể roll lên gear (port từ profile.gd). "int" = giá trị nguyên.
const AFFIX_POOL := [
	{"stat": "bonus_attack",  "min": 1.0, "max": 5.0,  "int": true},
	{"stat": "bonus_defense", "min": 1.0, "max": 4.0,  "int": true},
	{"stat": "bonus_max_hp",  "min": 5.0, "max": 20.0, "int": true},
	{"stat": "bonus_speed",   "min": 3.0, "max": 8.0,  "int": true},
	{"stat": "crit_chance",   "min": 0.02, "max": 0.06, "int": false},
	{"stat": "crit_damage",   "min": 0.10, "max": 0.30, "int": false},
	{"stat": "lifesteal",     "min": 0.01, "max": 0.03, "int": false},
]

# Cây talent: mỗi điểm tăng 1 rank, cộng "per" vào "stat" (port từ profile.gd).
const TALENTS := {
	"power":     {"name": "Sức Mạnh (+ATK)",      "stat": "bonus_attack", "per": 2.0,  "max": 5},
	"vitality":  {"name": "Sinh Lực (+HP)",        "stat": "bonus_max_hp", "per": 15.0, "max": 5},
	"precision": {"name": "Chính Xác (+Crit%)",    "stat": "crit_chance",  "per": 0.03, "max": 5},
	"ferocity":  {"name": "Hung Tàn (+CritDmg%)",  "stat": "crit_damage",  "per": 0.10, "max": 5},
	"swiftness": {"name": "Nhanh Nhẹn (+Tốc độ)",  "stat": "bonus_speed",  "per": 6.0,  "max": 3},
	"vampirism": {"name": "Hút Máu (+Lifesteal%)", "stat": "lifesteal",    "per": 0.02, "max": 3},
}

var hero_id: String = ""
var hero_def_id: String = ""          # trỏ HeroDef (data-driven, dùng đầy đủ ở P1+)
var display_name: String = ""
var level: int = 1
var xp: int = 0
var talent_points: int = 0
var talents: Dictionary = {}                       # id -> rank
var inventory: Array = []                          # gear instances của hero
var equipment: Dictionary = {"weapon": null, "armor": null}
var current_hp: int = -1                            # -1 = chưa init (sẽ = eff_max_hp)
var state: int = State.IDLE

var _constants: CombatConstants

func _c() -> CombatConstants:
	if _constants == null:
		_constants = CombatConstants.new()
	return _constants

func set_constants(c: CombatConstants) -> void:
	_constants = c

## Đặt máu về đầy (khi tạo mới / hồi ở Nhà Trọ).
func reset_hp() -> void:
	current_hp = eff_max_hp()

func is_knocked_out() -> bool:
	return current_hp == 0

# --- gear instance helpers ------------------------------------------------
static func make_instance(id: String, lvl: int = 0, affixes: Array = []) -> Dictionary:
	return {"id": id, "level": lvl, "affixes": affixes}

func roll_instance(id: String) -> Dictionary:
	var data: ItemData = Database.get_item(id)
	var affixes: Array = []
	if data != null and (data.type == ItemData.Type.WEAPON or data.type == ItemData.Type.ARMOR):
		for i in _affix_count(data.rarity):
			affixes.append(_roll_affix())
	return make_instance(id, 0, affixes)

func _affix_count(rarity: int) -> int:
	match rarity:
		ItemData.Rarity.UNCOMMON: return 2
		ItemData.Rarity.RARE: return 3
		ItemData.Rarity.EPIC: return 3
		ItemData.Rarity.LEGENDARY: return 4
		_: return 1

func _roll_affix() -> Dictionary:
	var a: Dictionary = AFFIX_POOL[RandomService.randi() % AFFIX_POOL.size()]
	var v: float
	if a["int"]:
		v = float(RandomService.randi_range(int(a["min"]), int(a["max"])))
	else:
		v = snappedf(RandomService.randf_range(a["min"], a["max"]), 0.01)
	return {"stat": a["stat"], "value": v}

# --- equip (pure; PlayerProfile lo emit/save) ------------------------------
func equip(inv_index: int) -> bool:
	if inv_index < 0 or inv_index >= inventory.size():
		return false
	var inst: Dictionary = inventory[inv_index]
	var data: ItemData = Database.get_item(inst["id"])
	if data == null:
		return false
	var slot := ""
	if data.type == ItemData.Type.WEAPON:
		slot = "weapon"
	elif data.type == ItemData.Type.ARMOR:
		slot = "armor"
	else:
		return false
	inventory.remove_at(inv_index)
	if equipment[slot] != null:
		inventory.append(equipment[slot])
	equipment[slot] = inst
	return true

func unequip(slot: String) -> bool:
	if equipment.get(slot) != null:
		inventory.append(equipment[slot])
		equipment[slot] = null
		return true
	return false

# --- forge (chi phí gold do PlayerProfile kiểm tra & trừ) ------------------
func upgrade_cost(slot: String) -> int:
	var inst = equipment.get(slot)
	if inst == null:
		return 0
	return _c().upgrade_base_cost * (int(inst["level"]) + 1)

func upgrade_gear(slot: String) -> bool:
	var inst = equipment.get(slot)
	if inst == null:
		return false
	inst["level"] = int(inst["level"]) + 1
	return true

# --- xp -------------------------------------------------------------------
func xp_to_next() -> int:
	return 20 + level * 15

## Cộng xp, trả về số level tăng được (PlayerProfile lo emit).
func gain_xp(amount: int) -> int:
	xp += amount
	var before := level
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
	var gained := level - before
	if gained > 0:
		talent_points += gained
	return gained

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
	return true

func _talent_total(stat: String) -> float:
	var total := 0.0
	for tid in talents.keys():
		var d = TALENTS.get(tid)
		if d != null and d["stat"] == stat:
			total += int(talents[tid]) * float(d["per"])
	return total

# --- effective stats (port nguyên từ profile.gd, hằng số từ CombatConstants) --
func _equip_base(field: String) -> float:
	var total := 0.0
	for slot in equipment.keys():
		var inst = equipment[slot]
		if inst == null:
			continue
		var data: ItemData = Database.get_item(inst["id"])
		if data == null:
			continue
		total += float(data.get(field)) * (1.0 + _c().upgrade_scale * int(inst["level"]))
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
	return _c().base_attack + _c().atk_per_level * (level - 1) + int(round(_stat("bonus_attack")))

func eff_defense() -> int:
	return _c().base_defense + _c().def_per_level * (level - 1) + int(round(_stat("bonus_defense")))

func eff_max_hp() -> int:
	return _c().base_max_hp + _c().hp_per_level * (level - 1) + int(round(_stat("bonus_max_hp")))

func eff_speed() -> float:
	return _c().base_speed + _stat("bonus_speed")

func eff_crit_chance() -> float:
	return clampf(_c().base_crit_chance + _affix_total("crit_chance") + _talent_total("crit_chance"), 0.0, 1.0)

func eff_crit_damage() -> float:
	return _c().crit_damage_default + _affix_total("crit_damage") + _talent_total("crit_damage")

func eff_lifesteal() -> float:
	return clampf(_affix_total("lifesteal") + _talent_total("lifesteal"), 0.0, _c().lifesteal_cap)

# --- hiển thị (port từ profile.gd) ----------------------------------------
func instance_label(inst) -> String:
	if inst == null:
		return "(trống)"
	var data: ItemData = Database.get_item(inst["id"])
	if data == null:
		return "?"
	var lv := int(inst["level"])
	var f := 1.0 + _c().upgrade_scale * lv
	var parts: Array = []
	var atk := int(round(data.bonus_attack * f))
	var df := int(round(data.bonus_defense * f))
	var hp := int(round(data.bonus_max_hp * f))
	if atk != 0: parts.append("ATK+%d" % atk)
	if df != 0: parts.append("DEF+%d" % df)
	if hp != 0: parts.append("HP+%d" % hp)
	for a in inst.get("affixes", []):
		parts.append(_affix_text(a))
	var nm := data.display_name
	if lv > 0:
		nm += " +%d" % lv
	if parts.size() > 0:
		return "%s [%s]" % [nm, ", ".join(parts)]
	return nm

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

# --- serialize (per-hero) -------------------------------------------------
func to_dict() -> Dictionary:
	return {
		"hero_id": hero_id,
		"hero_def_id": hero_def_id,
		"display_name": display_name,
		"level": level,
		"xp": xp,
		"talent_points": talent_points,
		"talents": talents,
		"inventory": inventory,
		"equipment": equipment,
		"current_hp": current_hp,
		"state": state,
	}

static func from_dict(d: Dictionary) -> HeroInstance:
	var h := HeroInstance.new()
	h.hero_id = str(d.get("hero_id", ""))
	h.hero_def_id = str(d.get("hero_def_id", ""))
	h.display_name = str(d.get("display_name", ""))
	h.level = maxi(int(d.get("level", 1)), 1)
	h.xp = maxi(int(d.get("xp", 0)), 0)
	h.talent_points = maxi(int(d.get("talent_points", 0)), 0)
	h.talents = h._norm_talents(d.get("talents", {}))
	h.inventory = h._norm_instances(d.get("inventory", []))
	var eq = d.get("equipment", {})
	if typeof(eq) != TYPE_DICTIONARY:
		eq = {}
	h.equipment = {
		"weapon": h._norm_instance(eq.get("weapon")),
		"armor": h._norm_instance(eq.get("armor")),
	}
	h.state = int(d.get("state", State.IDLE))
	h.current_hp = int(d.get("current_hp", -1))
	if h.current_hp < 0:
		h.reset_hp()
	return h

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

func _norm_talents(d) -> Dictionary:
	var out: Dictionary = {}
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for k in d.keys():
		if TALENTS.has(str(k)):
			out[str(k)] = maxi(int(d[k]), 0)
	return out
