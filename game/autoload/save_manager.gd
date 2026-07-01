extends Node
## Lưu/đọc offline. Ghi atomic (file tạm -> rename) + giữ 1 bản .bak.
## v2 (P0): cấu trúc lồng player/heroes/world + checksum + migration v1->v2.
## Rule save-system.md: migration KHÔNG được làm hỏng save; luôn giữ .bak.

const SAVE_PATH := "user://save_0.json"
const BAK_PATH := "user://save_0.bak"
const TMP_PATH := "user://save_0.tmp"
const SAVE_VERSION := 5

func save_game(data: Dictionary) -> bool:
	var payload := data.duplicate(true)
	payload["save_version"] = SAVE_VERSION
	payload.erase("checksum")
	payload["checksum"] = _checksum(payload)
	var json := JSON.stringify(payload, "\t")

	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: không mở được file tạm (%s)" % FileAccess.get_open_error())
		_report(false, 0)
		return false
	f.store_string(json)
	f.close()

	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, BAK_PATH)

	var err := DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)
	var ok := err == OK
	if not ok:
		push_error("SaveManager: rename thất bại (%d)" % err)
	_report(ok, json.length())
	return ok

func _report(ok: bool, size: int) -> void:
	if Engine.has_singleton("Telemetry") or has_node("/root/Telemetry"):
		Telemetry.log_event("Save", "save_completed" if ok else "save_failed",
			{"size_bytes": size, "version": SAVE_VERSION, "ok": ok})
	EventBus.save_completed.emit(ok)

func load_game() -> Dictionary:
	var data := _read_valid(SAVE_PATH)
	if data.is_empty():
		data = _read_valid(BAK_PATH)   # file chính hỏng/thiếu -> thử backup
	if data.is_empty():
		return {}
	return _migrate(data)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BAK_PATH)

func delete_save() -> void:
	for p in [SAVE_PATH, BAK_PATH, TMP_PATH]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func save_info() -> Dictionary:
	var d := _read_raw(SAVE_PATH)
	return {
		"exists": FileAccess.file_exists(SAVE_PATH),
		"version": int(d.get("save_version", 0)),
		"checksum": str(d.get("checksum", "")),
		"heroes": (d.get("heroes", {}) as Dictionary).size() if typeof(d.get("heroes")) == TYPE_DICTIONARY else 0,
	}

# --- internal -------------------------------------------------------------
func _read_raw(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: save hỏng tại %s" % path)
		return {}
	return parsed as Dictionary

## Đọc + xác thực checksum (nếu có). Trả {} nếu hỏng/không khớp.
func _read_valid(path: String) -> Dictionary:
	var d := _read_raw(path)
	if d.is_empty():
		return {}
	if d.has("checksum"):
		var stored := str(d["checksum"])
		var copy := d.duplicate(true)
		copy.erase("checksum")
		if _checksum(copy) != stored:
			push_warning("SaveManager: checksum không khớp tại %s" % path)
			if has_node("/root/Telemetry"):
				Telemetry.log_event("Error", "checksum_mismatch", {"path": path})
			return {}
	return d

func _checksum(d: Dictionary) -> String:
	var copy := d.duplicate(true)
	copy.erase("checksum")
	return str(JSON.stringify(copy).hash())

## Nâng cấp save cũ về schema hiện tại. KHÔNG mutate input; dựng dict mới.
func _migrate(d: Dictionary) -> Dictionary:
	var v := int(d.get("save_version", 1))
	if v >= SAVE_VERSION:
		return d
	var out := d
	if v <= 1:
		out = _migrate_v1_to_v2(out)
		if has_node("/root/Telemetry"):
			Telemetry.log_event("Save", "migration_run", {"from": 1, "to": 2})
	if v <= 2:
		out = _migrate_v2_to_v3(out)
		if has_node("/root/Telemetry"):
			Telemetry.log_event("Save", "migration_run", {"from": 2, "to": 3})
	if v <= 3:
		out = _migrate_v3_to_v4(out)
		if has_node("/root/Telemetry"):
			Telemetry.log_event("Save", "migration_run", {"from": 3, "to": 4})
	if v <= 4:
		out = _migrate_v4_to_v5(out)
		if has_node("/root/Telemetry"):
			Telemetry.log_event("Save", "migration_run", {"from": 4, "to": 5})
	out["save_version"] = SAVE_VERSION
	return out

## v4 -> v5: thêm stage_stars/stage_claims + honor currency + world.{world_boss,arena}. Không mất data.
func _migrate_v4_to_v5(d: Dictionary) -> Dictionary:
	var out := d.duplicate(true)
	var player = out.get("player", {})
	if typeof(player) == TYPE_DICTIONARY:
		if not player.has("stage_stars"): player["stage_stars"] = {}
		if not player.has("stage_claims"): player["stage_claims"] = {}
		var cur = player.get("currency", {})
		if typeof(cur) != TYPE_DICTIONARY: cur = {}
		if not cur.has("honor"): cur["honor"] = 0
		player["currency"] = cur
		out["player"] = player
	var world = out.get("world", {})
	if typeof(world) != TYPE_DICTIONARY:
		world = {}
	if not world.has("world_boss"): world["world_boss"] = {}
	if not world.has("arena"): world["arena"] = {}
	out["world"] = world
	return out

## v3 -> v4: thêm equipped[8]/runes[5] mỗi hero + owned_equipment/owned_runes. Không mất data.
func _migrate_v3_to_v4(d: Dictionary) -> Dictionary:
	var out := d.duplicate(true)
	var heroes = out.get("heroes", {})
	if typeof(heroes) == TYPE_DICTIONARY:
		for id in heroes.keys():
			var h = heroes[id]
			if typeof(h) == TYPE_DICTIONARY:
				if not h.has("equipped"): h["equipped"] = [null, null, null, null, null, null, null, null]
				if not h.has("runes"): h["runes"] = [null, null, null, null, null]
				if not h.has("shards"): h["shards"] = 0
				if not h.has("awaken_state"): h["awaken_state"] = {}
	var player = out.get("player", {})
	if typeof(player) == TYPE_DICTIONARY:
		if not player.has("owned_equipment"): player["owned_equipment"] = {}
		if not player.has("owned_runes"): player["owned_runes"] = {}
		if not player.has("collection"): player["collection"] = {}
		if not player.has("codex_seen"): player["codex_seen"] = {}
		if not player.has("pity_counters"): player["pity_counters"] = {}
		if not player.has("currency"): player["currency"] = {}
		if not player.has("claimed_ids"): player["claimed_ids"] = {}
	out["player"] = player
	return out

## v2 -> v3: thêm field vòng đời hero + cleared_stars + world.expeditions. Không mất data.
func _migrate_v2_to_v3(d: Dictionary) -> Dictionary:
	var out := d.duplicate(true)
	var heroes = out.get("heroes", {})
	if typeof(heroes) == TYPE_DICTIONARY:
		for id in heroes.keys():
			var h = heroes[id]
			if typeof(h) == TYPE_DICTIONARY:
				if not h.has("fatigue"): h["fatigue"] = 0.0
				if not h.has("injury_level"): h["injury_level"] = 0
				if not h.has("injury_recover_at"): h["injury_recover_at"] = 0.0
				if not h.has("mood"): h["mood"] = 70.0
	var player = out.get("player", {})
	if typeof(player) == TYPE_DICTIONARY:
		if not player.has("cleared_stars"): player["cleared_stars"] = {}
		if not player.has("injuries"): player["injuries"] = {}
	var world = out.get("world", {})
	if typeof(world) != TYPE_DICTIONARY:
		world = {}
	if not world.has("expeditions"): world["expeditions"] = []
	if not world.has("exp_seq"): world["exp_seq"] = 0
	out["world"] = world
	return out

## v1 (phẳng: gold/xp/level/equipment...) -> v2 (lồng player/heroes/world).
func _migrate_v1_to_v2(d: Dictionary) -> Dictionary:
	var hero := {
		"hero_id": "hero_0",
		"hero_def_id": "",
		"display_name": "Anh Hùng",
		"level": maxi(int(d.get("level", 1)), 1),
		"xp": maxi(int(d.get("xp", 0)), 0),
		"talent_points": maxi(int(d.get("talent_points", 0)), 0),
		"talents": d.get("talents", {}),
		"inventory": d.get("inventory", []),
		"equipment": d.get("equipment", {"weapon": null, "armor": null}),
		"current_hp": -1,
		"state": 0,
	}
	return {
		"player": {
			"gold": maxi(int(d.get("gold", 0)), 0),
			"gems": 0,
			"consumables": d.get("consumables", {}),
			"materials": d.get("materials", {}),
			"unlocks": {},
		},
		"hero_ids": ["hero_0"],
		"heroes": {"hero_0": hero},
		"world": {},
	}
