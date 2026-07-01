class_name EquipmentService
extends RefCounted
## Roll/enhance/equip-validate/set-bonus cho equipment 8-slot. Static, pure (RNG qua RandomService).
## TÁI DÙNG AFFIX_POOL của HeroInstance. Enhance chỉ tăng main (base-only, EQUIPMENT.md).

const ILVL_SCALE := 0.02   # main += 2%/ilvl trên base_ilvl

static func secondary_count(item_rarity: int) -> int:
	match item_rarity:
		ItemData.Rarity.UNCOMMON: return 2
		ItemData.Rarity.RARE: return 3
		ItemData.Rarity.EPIC: return 3
		ItemData.Rarity.LEGENDARY: return 4
		_: return 1

static func roll_affix(pool: Array) -> Dictionary:
	var src: Array = pool if not pool.is_empty() else HeroInstance.AFFIX_POOL
	var a: Dictionary = src[RandomService.randi() % src.size()]
	var v: float
	if a["int"]:
		v = float(RandomService.randi_range(int(a["min"]), int(a["max"])))
	else:
		v = snappedf(RandomService.randf_range(a["min"], a["max"]), 0.01)
	return {"stat": a["stat"], "value": v, "locked": false}

## Roll 1 EquipmentInstance từ def. Caller PHẢI RandomService.seed_with() trước để tất định.
static func roll_equipment(def_id: String, ilvl: int = -1, quality: int = 1) -> EquipmentInstance:
	var def: EquipDef = Database.get_equip_def(def_id)
	var inst := EquipmentInstance.new()
	inst.def_id = def_id
	inst.quality = quality
	if def == null:
		return inst
	var lv := ilvl if ilvl >= 0 else def.base_ilvl
	inst.main_value = def.main_stat_base * (1.0 + ILVL_SCALE * float(lv - def.base_ilvl))
	for _i in secondary_count(def.rarity):
		inst.affixes.append(roll_affix(def.secondary_pool))
	return inst

static func enhance(inst: EquipmentInstance) -> bool:
	if inst == null or inst.enhance >= 20:
		return false
	inst.enhance += 1
	return true

## Main hiệu dụng = main × (1 + upgrade_scale × enhance) — khớp _equip_base cũ.
static func effective_main(inst: EquipmentInstance, c: CombatConstants) -> float:
	return inst.main_value * (1.0 + c.upgrade_scale * float(inst.enhance))

static func can_equip(hero: HeroInstance, inst: EquipmentInstance) -> bool:
	var def: EquipDef = Database.get_equip_def(inst.def_id)
	if def == null:
		return false
	if not def.allowed_class.is_empty() and not def.allowed_class.has(hero.class_role):
		return false
	return true

## Gắn vào slot; trả instance cũ (để trả kho) hoặc null. Set owner + mark_dirty.
static func equip(hero: HeroInstance, inst: EquipmentInstance) -> EquipmentInstance:
	if not can_equip(hero, inst):
		return null
	var def: EquipDef = Database.get_equip_def(inst.def_id)
	var prev = hero.equipped[def.slot]
	if prev != null:
		(prev as EquipmentInstance).owner_hero_id = ""
	inst.owner_hero_id = hero.hero_id
	hero.equipped[def.slot] = inst
	hero.mark_stats_dirty()
	return prev

## Set bonus: đếm item cùng set_id -> áp mọi mốc <= count. Trả {stat:percent}.
static func set_bonus(equipped: Array) -> Dictionary:
	var counts := {}
	for e in equipped:
		if e == null:
			continue
		var def: EquipDef = Database.get_equip_def(e.def_id)
		if def != null and def.set_id != "":
			counts[def.set_id] = int(counts.get(def.set_id, 0)) + 1
	var out := {}
	for sid in counts:
		var sdef = Database.get_set_bonus(sid)   # {2:{stat:pct}, 4:{...}}
		if typeof(sdef) != TYPE_DICTIONARY:
			continue
		var n: int = counts[sid]
		for th in sdef:
			if n >= int(th):
				_merge(out, sdef[th])
	return out

static func _merge(out: Dictionary, d: Dictionary) -> void:
	for k in d:
		out[str(k)] = float(out.get(k, 0.0)) + float(d[k])
