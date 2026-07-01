class_name RuneInstance
extends RefCounted
## 1 rune runtime/save. slot_index: -1 chưa gắn, 0 = core, 1..4 = slot thường.

var uid: String = ""
var def_id: String = ""
var level: int = 1                   # 1..20
var owner_hero_id: String = ""
var slot_index: int = -1

func to_dict() -> Dictionary:
	return {"uid": uid, "def_id": def_id, "level": level,
		"owner_hero_id": owner_hero_id, "slot_index": slot_index}

static func from_dict(d: Dictionary) -> RuneInstance:
	var r := RuneInstance.new()
	r.uid = str(d.get("uid", ""))
	r.def_id = str(d.get("def_id", ""))
	r.level = clampi(int(d.get("level", 1)), 1, 20)
	r.owner_hero_id = str(d.get("owner_hero_id", ""))
	r.slot_index = clampi(int(d.get("slot_index", -1)), -1, 4)
	return r
