class_name SynergyService
extends RefCounted
## Aura team theo count race/class (HERO.md). Trả {stat:percent} áp cho mọi hero trong team.

## team: Array[HeroInstance].
static func compute(team: Array) -> Dictionary:
	var race_count := {}
	var class_count := {}
	for h in team:
		if h == null:
			continue
		race_count[h.race] = int(race_count.get(h.race, 0)) + 1
		class_count[h.class_role] = int(class_count.get(h.class_role, 0)) + 1
	var out := {}
	for sdef in Database.synergy_defs.values():
		var counts: Dictionary = race_count if sdef.kind == "race" else class_count
		var n: int = int(counts.get(sdef.key, 0))
		for th in sdef.thresholds:
			if n >= int(th):
				_merge(out, sdef.thresholds[th])
	return out

static func _merge(out: Dictionary, d: Dictionary) -> void:
	for k in d:
		out[str(k)] = float(out.get(k, 0.0)) + float(d[k])

## id các synergy ĐANG active (đủ threshold) — dùng cho meta rotation season buff synergy.
static func active_ids(team: Array) -> Array:
	var race_count := {}
	var class_count := {}
	for h in team:
		if h == null:
			continue
		race_count[h.race] = int(race_count.get(h.race, 0)) + 1
		class_count[h.class_role] = int(class_count.get(h.class_role, 0)) + 1
	var out: Array = []
	for sdef in Database.synergy_defs.values():
		var counts: Dictionary = race_count if sdef.kind == "race" else class_count
		var n: int = int(counts.get(sdef.key, 0))
		for th in sdef.thresholds:
			if n >= int(th):
				out.append(str(sdef.id))
				break
	return out
