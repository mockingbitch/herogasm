extends Node
## Lưu/đọc tiến trình offline. Ghi atomic (file tạm -> rename) + giữ 1 bản .bak.
## Dùng: SaveManager.save_game({"gold": 100, ...}) / var d = SaveManager.load_game()

const SAVE_PATH := "user://save_0.json"
const BAK_PATH := "user://save_0.bak"
const TMP_PATH := "user://save_0.tmp"
const SAVE_VERSION := 1

func save_game(data: Dictionary) -> bool:
	data["save_version"] = SAVE_VERSION
	var json := JSON.stringify(data, "\t")

	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: không mở được file tạm (%s)" % FileAccess.get_open_error())
		return false
	f.store_string(json)
	f.close()

	# Giữ bản hiện tại làm backup trước khi ghi đè.
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, BAK_PATH)

	var err := DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)
	if err != OK:
		push_error("SaveManager: rename thất bại (%d)" % err)
		return false
	return true

func load_game() -> Dictionary:
	var data := _read(SAVE_PATH)
	if data.is_empty():
		# File chính hỏng/thiếu -> thử backup.
		data = _read(BAK_PATH)
	return data

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BAK_PATH)

func delete_save() -> void:
	# Best-effort: xoá cả save chính, backup và tmp nếu còn.
	for p in [SAVE_PATH, BAK_PATH, TMP_PATH]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)

func _read(path: String) -> Dictionary:
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
