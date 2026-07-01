class_name WorldMap
extends RefCounted
## Helper gating world-map THUẦN (testable headless). Nhận profile qua tham số (không autoload).
## Gate = AND(region level, zone level, đủ sao ở prereq). Data từ Region/ZoneDef.

static func is_region_unlocked(region_id: String, profile) -> bool:
	var r: RegionDef = Database.get_region_def(region_id)
	if r == null:
		return false
	return profile.roster_max_level() >= r.required_level

static func is_zone_unlocked(zone_id: String, profile) -> bool:
	var z: ZoneDef = Database.get_zone_def(zone_id)
	if z == null:
		return false
	if not is_region_unlocked(z.region_id, profile):
		return false
	if profile.roster_max_level() < z.required_level:
		return false
	if z.unlock_by_stars > 0 and z.prereq_zone_id != "":
		if profile.zone_stars(z.prereq_zone_id) < z.unlock_by_stars:
			return false
	return true

static func unlocked_zone_ids(profile) -> Array:
	var out: Array = []
	for zid in Database.zone_ids():
		if is_zone_unlocked(str(zid), profile):
			out.append(str(zid))
	return out

static func hero_power(h: HeroInstance) -> int:
	return int(round(float(h.eff_attack()) * 2.0 + float(h.eff_defense()) + float(h.eff_max_hp()) * 0.1))

## Zone mở khó nhất mà power đủ; "" nếu chưa zone nào phù hợp (caller fallback zone dễ nhất).
static func best_unlocked_zone_for(h: HeroInstance, profile) -> String:
	var power := hero_power(h)
	var best := ""
	var best_req := -1
	for zid in unlocked_zone_ids(profile):
		var z: ZoneDef = Database.get_zone_def(zid)
		if z != null and power >= z.recommended_power and z.recommended_power > best_req:
			best_req = z.recommended_power
			best = zid
	return best

## Zone mở dễ nhất (recommended_power nhỏ nhất) — fallback.
static func easiest_unlocked_zone(profile) -> String:
	var best := ""
	var best_req := 1 << 30
	for zid in unlocked_zone_ids(profile):
		var z: ZoneDef = Database.get_zone_def(zid)
		if z != null and z.recommended_power < best_req:
			best_req = z.recommended_power
			best = zid
	return best
