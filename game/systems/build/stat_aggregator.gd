class_name StatAggregator
extends RefCounted
## Gom mọi nguồn build -> FinalStats. PURE, deterministic (không scene, không RNG).
## Thứ tự: base+growth -> equip(cũ P1 + mới 8-slot) -> talent -> rune -> set/resonance/synergy(percent).
## Flat cộng trước, percent gom rồi NHÂN MỘT LẦN + clamp (balancing.md: no hidden multiplier).

const STATS := ["bonus_attack", "bonus_defense", "bonus_max_hp", "bonus_speed", "crit_chance", "crit_damage", "lifesteal"]

## team_ctx = {"synergy": {stat:percent}} hoặc {} nếu solo.
static func aggregate(hero: HeroInstance, team_ctx: Dictionary = {}) -> FinalStats:
	var c: CombatConstants = hero._c()
	var s := FinalStats.new()

	# 1) base + per-level (KHỚP eff_* P1)
	s.add_flat("bonus_attack", float(c.base_attack + c.atk_per_level * (hero.level - 1)), "base")
	s.add_flat("bonus_defense", float(c.base_defense + c.def_per_level * (hero.level - 1)), "base")
	s.add_flat("bonus_max_hp", float(c.base_max_hp + c.hp_per_level * (hero.level - 1)), "base")
	s.add_flat("bonus_speed", c.base_speed, "base")
	s.add_flat("crit_chance", c.base_crit_chance, "base")
	s.add_flat("crit_damage", c.crit_damage_default, "base")

	# 2a) equipment CŨ (P1 equipment{weapon,armor}) — tái dùng _equip_base/_affix_total
	for stat in ["bonus_attack", "bonus_defense", "bonus_max_hp", "bonus_speed"]:
		s.add_flat(stat, hero._equip_base(stat), "equip")
	for stat in STATS:
		s.add_flat(stat, hero._affix_total(stat), "equip")
		s.add_flat(stat, hero._talent_total(stat), "talent")
		s.add_flat(stat, hero._awaken_total(stat), "awaken")

	# 2b) equipment MỚI 8-slot (main + affix -> flat)
	for e in hero.equipped:
		if e == null:
			continue
		var def: EquipDef = Database.get_equip_def(e.def_id)
		if def != null:
			s.add_flat(def.main_stat_key, EquipmentService.effective_main(e, c), "equip")
		for a in e.affixes:
			s.add_flat(str(a.get("stat", "")), float(a.get("value", 0.0)), "equip")

	# 3) set bonus -> percent
	s.add_percent_dict(EquipmentService.set_bonus(hero.equipped), "set")

	# 4) rune: main flat + level-unlock percent + core percent + resonance percent
	for r in hero.runes:
		if r == null:
			continue
		s.add_flat_dict(RuneService.rune_main(r), "rune")
		s.add_percent_dict(RuneService.unlocked_effects(r), "rune")
		var rdef: RuneDef = Database.get_rune_def(r.def_id)
		if rdef != null and rdef.is_core:
			s.add_percent_dict(rdef.core_percent, "rune_core")
	s.add_percent_dict(RuneService.resonance(hero.runes), "resonance")

	# 5) synergy aura -> percent
	s.add_percent_dict(team_ctx.get("synergy", {}), "synergy")

	# 6) final = flat*(1+Σpercent) + clamp
	s.finalize()
	_clamp(s, c)
	return s

static func _clamp(s: FinalStats, c: CombatConstants) -> void:
	s.value["crit_chance"] = clampf(s.value.get("crit_chance", 0.0), 0.0, 0.8)
	s.value["crit_damage"] = clampf(s.value.get("crit_damage", 1.5), 1.0, 3.0)
	s.value["lifesteal"] = clampf(s.value.get("lifesteal", 0.0), 0.0, c.lifesteal_cap)
	s.value["bonus_max_hp"] = maxf(1.0, s.value.get("bonus_max_hp", 1.0))
	s.value["bonus_attack"] = maxf(0.0, s.value.get("bonus_attack", 0.0))
	s.value["bonus_defense"] = maxf(0.0, s.value.get("bonus_defense", 0.0))
