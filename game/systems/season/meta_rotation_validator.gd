class_name MetaRotationValidator
extends RefCounted
## Chặn power-creep (GDD mục 22): meta_rotation season CHỈ được buff rune/equip/synergy,
## TUYỆT ĐỐI không target hero base stat trực tiếp. Validate cứng + test riêng.

const ALLOWED_KEYS := ["rune_buffs", "equip_buffs", "synergy_buffs"]
const FORBIDDEN_KEYS := ["hero_buffs", "hero_base", "hero_base_stat", "base_stats", "hero"]

## Trả {ok:bool, reason:String}. rules = SeasonDef.meta_rotation.
static func validate(rules: Dictionary) -> Dictionary:
	for k in rules.keys():
		if str(k) in FORBIDDEN_KEYS:
			return {"ok": false, "reason": "target hero base bị cấm: %s" % k}
		if str(k) not in ALLOWED_KEYS:
			return {"ok": false, "reason": "key không hợp lệ: %s" % k}
	if not _entries_ok(rules.get("rune_buffs", []), ["rune_id", "stat", "mult"]):
		return {"ok": false, "reason": "rune_buffs sai định dạng"}
	if not _entries_ok(rules.get("equip_buffs", []), ["set_id", "stat", "mult"]):
		return {"ok": false, "reason": "equip_buffs sai định dạng"}
	if not _entries_ok(rules.get("synergy_buffs", []), ["synergy_id", "bonus"]):
		return {"ok": false, "reason": "synergy_buffs sai định dạng"}
	return {"ok": true, "reason": ""}

static func is_valid(rules: Dictionary) -> bool:
	return bool(validate(rules)["ok"])

static func _entries_ok(arr, required: Array) -> bool:
	if typeof(arr) != TYPE_ARRAY:
		return false
	for e in arr:
		if typeof(e) != TYPE_DICTIONARY:
			return false
		for key in required:
			if not e.has(key):
				return false
	return true
