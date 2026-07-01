class_name EquipmentInstance
extends RefCounted
## 1 món equipment runtime/save. Roll từ EquipDef; enhance chỉ tăng main (base-only).
## affix format = { "stat": String, "value": float, "locked": bool } (khớp _roll_affix + locked).

var uid: String = ""
var def_id: String = ""
var enhance: int = 0                 # 0..20
var quality: int = 1                 # 0..4 (MVP luôn 1 = Normal)
var main_value: float = 0.0          # main đã roll cố định
var affixes: Array = []              # [{stat,value,locked}]
var sockets: Array = []              # rune uid (P3-cont)
var owner_hero_id: String = ""
var is_locked: bool = false

func to_dict() -> Dictionary:
	return {
		"uid": uid, "def_id": def_id, "enhance": enhance, "quality": quality,
		"main_value": main_value, "affixes": affixes, "sockets": sockets,
		"owner_hero_id": owner_hero_id, "is_locked": is_locked,
	}

static func from_dict(d: Dictionary) -> EquipmentInstance:
	var e := EquipmentInstance.new()
	e.uid = str(d.get("uid", ""))
	e.def_id = str(d.get("def_id", ""))
	e.enhance = clampi(int(d.get("enhance", 0)), 0, 20)
	e.quality = clampi(int(d.get("quality", 1)), 0, 4)
	e.main_value = float(d.get("main_value", 0.0))
	e.affixes = d.get("affixes", []) if typeof(d.get("affixes")) == TYPE_ARRAY else []
	e.sockets = d.get("sockets", []) if typeof(d.get("sockets")) == TYPE_ARRAY else []
	e.owner_hero_id = str(d.get("owner_hero_id", ""))
	e.is_locked = bool(d.get("is_locked", false))
	return e
