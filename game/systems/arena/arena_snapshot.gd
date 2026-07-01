class_name ArenaSnapshot
extends RefCounted
## Ảnh chụp đội (freeze stat đã tính) — khớp save = network snapshot (multiplayer.md).
## Freeze để trận async TẤT ĐỊNH qua thời gian (đối thủ không đổi build giữa các trận).
## hero block schema DÙNG CHUNG với arena bot pool + SimCombatant.from_snapshot_hero.

var owner_profile_id: StringName = &""
var power_ref: int = 0
var heroes: Array = []                # [{hero_id,name,max_hp,attack,defense,crit_chance,crit_damage,lifesteal,attack_interval}]
var formation_id: StringName = &"balanced_3"
var mmr: int = 1000
var captured_tick: int = 0

## Chụp đội hiện hành của người chơi (freeze FinalStats). team: Array[HeroInstance].
static func capture(owner: String, team: Array, formation_id: String, mmr_val: int, tick: int) -> ArenaSnapshot:
	var s := ArenaSnapshot.new()
	s.owner_profile_id = StringName(owner)
	s.formation_id = StringName(formation_id)
	s.mmr = mmr_val
	s.captured_tick = tick
	var ctx := PlayerProfile.team_context()
	for h in team:
		s.heroes.append(freeze_hero(h, ctx))
	s.power_ref = _power(s.heroes)
	return s

## Freeze 1 hero -> block stat cố định (đọc FinalStats + effective_power).
static func freeze_hero(h: HeroInstance, team_ctx: Dictionary) -> Dictionary:
	var fs: FinalStats = h.get_final_stats(team_ctx)
	var ep := h.effective_power()
	return {
		"hero_id": h.hero_id,
		"name": h.display_name,
		"max_hp": maxi(1, int(round(fs.get_v("bonus_max_hp", 1.0)))),
		"attack": maxi(1, int(round(fs.get_v("bonus_attack") * ep))),
		"defense": int(round(fs.get_v("bonus_defense"))),
		"crit_chance": fs.get_v("crit_chance"),
		"crit_damage": fs.get_v("crit_damage", 1.5),
		"lifesteal": fs.get_v("lifesteal"),
		"attack_interval": clampf(100.0 / maxf(1.0, fs.get_v("bonus_speed", 92.0)), 0.3, 3.0),
	}

static func _power(heroes: Array) -> int:
	var p := 0
	for hb in heroes:
		p += int(hb.get("max_hp", 0)) + int(hb.get("attack", 0)) * 8 + int(hb.get("defense", 0)) * 4
	return p

func to_dict() -> Dictionary:
	return {"owner_profile_id": str(owner_profile_id), "power_ref": power_ref, "heroes": heroes,
		"formation_id": str(formation_id), "mmr": mmr, "captured_tick": captured_tick}

static func from_dict(d: Dictionary) -> ArenaSnapshot:
	var s := ArenaSnapshot.new()
	s.owner_profile_id = StringName(str(d.get("owner_profile_id", "")))
	s.power_ref = int(d.get("power_ref", 0))
	s.heroes = d.get("heroes", []) if typeof(d.get("heroes")) == TYPE_ARRAY else []
	s.formation_id = StringName(str(d.get("formation_id", "balanced_3")))
	s.mmr = int(d.get("mmr", 1000))
	s.captured_tick = int(d.get("captured_tick", 0))
	return s
