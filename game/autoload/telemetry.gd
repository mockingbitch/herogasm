extends Node
## Telemetry stub (P0) theo telemetry.md: buffer-then-flush, versioned, KHÔNG PII.
## API: Telemetry.log_event(category, name, data). Flush ra user://telemetry.jsonl.

const SCHEMA_VERSION := 1
const FLUSH_EVERY := 20
const LOG_PATH := "user://telemetry.jsonl"
## Sample 1/N cho event tần suất cao (movement/damage/path/fps...). NEVER sample event dưới.
const SAMPLE_RATE := 10
const HIGH_FREQ := ["movement", "damage", "path", "fps", "ai_tick", "combat_tick", "pool_usage"]
const NEVER_SAMPLE := ["boss_defeated", "quest_completed", "save_failed", "reward_claimed", "error_occurred"]

var _buffer: Array = []
var _session_id: String = ""
var _sample_counter: Dictionary = {}       # event_name -> count (cho sampling tất định)

func _ready() -> void:
	_session_id = "s_%d_%d" % [int(Time.get_unix_time_from_system()), randi() % 100000]

## API P6 (rules/telemetry.md): track(event_name, category, payload). Buffered, versioned, KHÔNG PII.
## Sampling event tần suất cao (giữ 1/N) trừ event quan trọng. category/name đảo thứ tự so log_event.
func track(event_name: StringName, category: StringName, payload: Dictionary = {}) -> void:
	var nm := str(event_name)
	if str(category) in HIGH_FREQ and nm not in NEVER_SAMPLE:
		var c := int(_sample_counter.get(nm, 0)) + 1
		_sample_counter[nm] = c
		if c % SAMPLE_RATE != 0:
			return
	log_event(str(category), nm, payload)

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
