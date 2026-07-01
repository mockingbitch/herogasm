class_name BattleEngine
extends RefCounted
## Battle Engine THUẦN, HEADLESS, TẤT ĐỊNH (seeded, tick cố định). Tách SIM↔VIEW.
## Dùng chung cho Bãi Săn / stage / boss / PvP. Damage qua DamageFormula (COMBAT.md pipeline).
## Xác định lại được 100% với cùng (units, seed) — nền cho replay/offline/PvP công bằng.

const DT := 0.1                 # 10 tick/giây
const DEFAULT_MAX_TICKS := 1200 # ~120s trần (COMBAT.md: quá giờ -> xử theo HP)

## a, b: Array[BattleUnit]. Trả BattleResult. KHÔNG mutate input ngoài field runtime của unit.
static func simulate(a: Array, b: Array, seed_val: int, max_ticks: int = DEFAULT_MAX_TICKS) -> BattleResult:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val

	var units: Array = []
	for u in a:
		u.team = 0
		u.cooldown = 0.0
		units.append(u)
	for u in b:
		u.team = 1
		u.cooldown = 0.0
		units.append(u)
	# Thứ tự duyệt ỔN ĐỊNH theo id (đảm bảo tất định).
	units.sort_custom(func(x, y): return x.id < y.id)

	var result := BattleResult.new()
	result.seed = seed_val
	var t := 0.0

	for _tick in max_ticks:
		if _alive_count(units, 0) == 0 or _alive_count(units, 1) == 0:
			break
		t += DT
		for u in units:
			if not u.is_alive():
				continue
			u.cooldown -= DT
			if u.cooldown > 0.0:
				continue
			var target: BattleUnit = _pick_target(units, u.team)
			if target == null:
				continue
			u.cooldown = u.attack_interval
			var r := DamageFormula.compute(u.attack, target.defense, u.crit_chance, u.crit_damage, rng, 100.0)
			var dmg: int = r["damage"]
			target.hp = maxi(target.hp - dmg, 0)
			result.total_damage += dmg
			if u.lifesteal > 0.0 and dmg > 0:
				u.hp = mini(u.hp + int(round(dmg * u.lifesteal)), u.max_hp)
			result.timeline.append({"t": t, "type": "hit", "src": u.id, "tgt": target.id, "value": dmg, "crit": r["crit"]})
			if target.hp == 0:
				result.timeline.append({"t": t, "type": "death", "src": u.id, "tgt": target.id, "value": 0, "crit": false})

	result.duration = t
	_finalize(units, result)
	return result

static func _finalize(units: Array, result: BattleResult) -> void:
	var alive0 := _alive_count(units, 0)
	var alive1 := _alive_count(units, 1)
	if alive1 == 0 and alive0 > 0:
		result.winner = 0
	elif alive0 == 0 and alive1 > 0:
		result.winner = 1
	else:
		# timeout / cả hai còn sống -> phe nhiều HP hơn thắng (tie -> hero)
		result.winner = 0 if _total_hp(units, 0) >= _total_hp(units, 1) else 1
	for u in units:
		result.survivors_hp[u.id] = u.hp
		if u.source_hero_id != "":
			result.hero_hp_after[u.source_hero_id] = u.hp
		if u.source_enemy_id != "" and u.hp == 0:
			result.dead_enemy_ids.append(u.source_enemy_id)

static func _alive_count(units: Array, team: int) -> int:
	var n := 0
	for u in units:
		if u.team == team and u.is_alive():
			n += 1
	return n

static func _total_hp(units: Array, team: int) -> int:
	var s := 0
	for u in units:
		if u.team == team:
			s += u.hp
	return s

## Mục tiêu: quái/hero địch còn sống có HP thấp nhất; tiebreak theo id (tất định).
static func _pick_target(units: Array, my_team: int) -> BattleUnit:
	var best: BattleUnit = null
	for u in units:
		if u.team == my_team or not u.is_alive():
			continue
		if best == null or u.hp < best.hp or (u.hp == best.hp and u.id < best.id):
			best = u
	return best
