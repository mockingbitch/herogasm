class_name RuneService
extends RefCounted
## Rune core+4: main (flat theo level), level-unlock effect (percent 5/10/15/20),
## core percent, resonance (>=4 cùng element -> aura). Static, pure.

static func rune_main(inst: RuneInstance) -> Dictionary:
	var def: RuneDef = Database.get_rune_def(inst.def_id)
	if def == null:
		return {}
	var v := def.main_stat_base + def.per_level_gain * float(inst.level - 1)
	return {def.main_stat_key: v}

## Gom mọi mốc {5,10,15,20} <= level -> percent.
static func unlocked_effects(inst: RuneInstance) -> Dictionary:
	var def: RuneDef = Database.get_rune_def(inst.def_id)
	var out := {}
	if def == null:
		return out
	for mark in [5, 10, 15, 20]:
		if inst.level >= mark and def.level_unlock_effects.has(mark):
			_merge(out, def.level_unlock_effects[mark])
	return out

## Resonance: >=4 rune cùng element -> aura percent (Database.get_resonance).
static func resonance(runes: Array) -> Dictionary:
	var elem_count := {}
	for r in runes:
		if r == null:
			continue
		var def: RuneDef = Database.get_rune_def(r.def_id)
		if def != null and def.element != Enums.Element.ARCANE:
			elem_count[def.element] = int(elem_count.get(def.element, 0)) + 1
	var out := {}
	for e in elem_count:
		if int(elem_count[e]) >= 4:
			_merge(out, Database.get_resonance(int(e)))
	return out

## core rune -> slot 0; slot thường -> 1..4.
static func can_slot_rune(inst: RuneInstance, slot_index: int) -> bool:
	var def: RuneDef = Database.get_rune_def(inst.def_id)
	if def == null or slot_index < 0 or slot_index > 4:
		return false
	return def.is_core == (slot_index == 0)

static func equip_rune(hero: HeroInstance, inst: RuneInstance, slot_index: int) -> RuneInstance:
	if not can_slot_rune(inst, slot_index):
		return null
	var prev = hero.runes[slot_index]
	if prev != null:
		(prev as RuneInstance).owner_hero_id = ""
		(prev as RuneInstance).slot_index = -1
	inst.owner_hero_id = hero.hero_id
	inst.slot_index = slot_index
	hero.runes[slot_index] = inst
	hero.mark_stats_dirty()
	return prev

static func _merge(out: Dictionary, d: Dictionary) -> void:
	for k in d:
		out[str(k)] = float(out.get(k, 0.0)) + float(d[k])
