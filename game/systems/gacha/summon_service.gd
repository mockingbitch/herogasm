class_name SummonService
extends RefCounted
## Gacha pull: weighted (RandomService seeded, tất định), pity soft/hard, dup->shard.
## PURE (không save/emit — PlayerProfile điều phối). Duyệt pool theo THỨ TỰ CỐ ĐỊNH (Array).

var _dup_shards: Array = [5, 10, 20, 40, 80]   # theo rarity, nạp từ CombatConstants

func setup(constants: CombatConstants) -> void:
	if constants != null and constants.dup_shard_by_rarity.size() > 0:
		_dup_shards = constants.dup_shard_by_rarity

## Trả Array<{hero_def_id, rarity, is_dup, shards_gained}>. pity_state mutate tại chỗ.
func pull(banner: BannerDef, count: int, pity_state: Dictionary, owned: Dictionary) -> Array:
	var results: Array = []
	for _i in count:
		var r := _pull_one(banner, pity_state)
		var def_id: String = r["hero_def_id"]
		var is_dup: bool = owned.has(def_id)
		var shards := _dup_shard_value(int(r["rarity"])) if is_dup else 0
		results.append({"hero_def_id": def_id, "rarity": int(r["rarity"]), "is_dup": is_dup, "shards_gained": shards})
	return results

func _pull_one(banner: BannerDef, st: Dictionary) -> Dictionary:
	var since := int(st.get("since_guaranteed", 0))
	st["total_pulls"] = int(st.get("total_pulls", 0)) + 1
	var forced := (since + 1) >= banner.pity_hard
	var soft_bonus := 0.0
	if (since + 1) > banner.pity_soft_start:
		soft_bonus = banner.pity_soft_step * float((since + 1) - banner.pity_soft_start)
	var rolled := _weighted_roll(banner, soft_bonus, forced)
	if int(rolled["rarity"]) >= banner.guaranteed_rarity:
		st["since_guaranteed"] = 0
	else:
		st["since_guaranteed"] = since + 1
	return rolled

func _weighted_roll(banner: BannerDef, soft_bonus: float, forced: bool) -> Dictionary:
	var entries: Array = banner.pool
	if forced:
		var hi: Array = entries.filter(func(e): return int(e.get("rarity", 0)) >= banner.guaranteed_rarity)
		return _pick(hi if not hi.is_empty() else entries, banner, 0.0)
	return _pick(entries, banner, soft_bonus)

func _pick(entries: Array, banner: BannerDef, soft_bonus: float) -> Dictionary:
	if entries.is_empty():
		return {"hero_def_id": "", "rarity": 0}
	var total := 0.0
	for e in entries:
		total += _weight(e, banner, soft_bonus)
	var roll := RandomService.randf() * total
	var acc := 0.0
	for e in entries:
		acc += _weight(e, banner, soft_bonus)
		if roll <= acc:
			return {"hero_def_id": str(e.get("hero_def_id", "")), "rarity": int(e.get("rarity", 0))}
	var last: Dictionary = entries[entries.size() - 1]
	return {"hero_def_id": str(last.get("hero_def_id", "")), "rarity": int(last.get("rarity", 0))}

func _weight(e: Dictionary, banner: BannerDef, soft_bonus: float) -> float:
	var w := float(e.get("weight", 1.0))
	if soft_bonus > 0.0 and int(e.get("rarity", 0)) >= banner.guaranteed_rarity:
		w *= (1.0 + soft_bonus)
	return w

func _dup_shard_value(rarity: int) -> int:
	if _dup_shards.is_empty():
		return 10
	return int(_dup_shards[clampi(rarity, 0, _dup_shards.size() - 1)])
