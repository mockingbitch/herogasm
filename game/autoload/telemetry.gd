extends Node
## Telemetry stub (P0) theo telemetry.md: buffer-then-flush, versioned, KHÔNG PII.
## API: Telemetry.log_event(category, name, data). Flush ra user://telemetry.jsonl.

const SCHEMA_VERSION := 1
const FLUSH_EVERY := 20
const LOG_PATH := "user://telemetry.jsonl"

var _buffer: Array = []
var _session_id: String = ""

func _ready() -> void:
	_session_id = "s_%d_%d" % [int(Time.get_unix_time_from_system()), randi() % 100000]

func log_event(category: String, name: String, data: Dictionary = {}) -> void:
	_buffer.append({
		"category": category,
		"name": name,
		"data": data,
		"ts": Time.get_unix_time_from_system(),
		"session_id": _session_id,
		"telemetry_version": SCHEMA_VERSION,
		"game_version": str(ProjectSettings.get_setting("application/config/version", "0.0.0")),
	})
	if _buffer.size() >= FLUSH_EVERY:
		flush()

func flush() -> void:
	if _buffer.is_empty():
		return
	var mode := FileAccess.READ_WRITE if FileAccess.file_exists(LOG_PATH) else FileAccess.WRITE
	var f := FileAccess.open(LOG_PATH, mode)
	if f == null:
		_buffer.clear()
		return
	f.seek_end()
	for e in _buffer:
		f.store_line(JSON.stringify(e))
	f.close()
	_buffer.clear()

func _exit_tree() -> void:
	flush()
