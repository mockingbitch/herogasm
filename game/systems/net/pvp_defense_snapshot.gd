class_name PvpDefenseSnapshot
extends RefCounted
## Đội hình phòng thủ async lưu server (khớp save = network snapshot). hero_stat_hash chống chỉnh:
## server so hash để phát hiện snapshot bị sửa (multiplayer.md Security). Freeze stat -> tất định.

var profile_id: StringName = &""
var heroes: Array = []                   # hero blocks (schema SimCombatant.from_snapshot_hero)
var formation_id: StringName = &"balanced_3"
var battle_power: int = 0
var hero_stat_hash: String = ""
var schema_version: int = 1
var updated_at: int = 0                  # game-time tick

## Dựng từ đội hero người chơi (freeze FinalStats + tính hash chống chỉnh).
static func from_team(profile: String, team: Array, formation_id_: String, updated_at_: int) -> PvpDefenseSnapshot:
	var s := PvpDefenseSnapshot.new()
	s.profile_id = StringName(profile)
	s.formation_id = StringName(formation_id_)
	s.updated_at = updated_at_
	var ctx := PlayerProfile.team_context()
	for h in team:
		s.heroes.append(ArenaSnapshot.freeze_hero(h, ctx))
	s.battle_power = _power(s.heroes)
	s.hero_stat_hash = compute_hash(s.heroes)
	return s

## Hash ổn định của stat block (server tính lại từ account đối thủ để so — chống chỉnh client).
static func compute_hash(heroes: Array) -> String:
	return str(JSON.stringify(heroes).hash())

static func _power(heroes: Array) -> int:
	var p := 0
	for hb in heroes:
		p += int(hb.get("max_hp", 0)) + int(hb.get("attack", 0)) * 8 + int(hb.get("defense", 0)) * 4
	return p

func to_dict() -> Dictionary:
	return {"profile_id": str(profile_id), "heroes": heroes, "formation_id": str(formation_id),
		"battle_power": battle_power, "hero_stat_hash": hero_stat_hash,
		"schema_version": schema_version, "updated_at": updated_at}

static func from_dict(d: Dictionary) -> PvpDefenseSnapshot:
	var s := PvpDefenseSnapshot.new()
	s.profile_id = StringName(str(d.get("profile_id", "")))
	s.heroes = d.get("heroes", []) if typeof(d.get("heroes")) == TYPE_ARRAY else []
	s.formation_id = StringName(str(d.get("formation_id", "balanced_3")))
	s.battle_power = int(d.get("battle_power", 0))
	s.hero_stat_hash = str(d.get("hero_stat_hash", ""))
	s.schema_version = int(d.get("schema_version", 1))
	s.updated_at = int(d.get("updated_at", 0))
	return s
