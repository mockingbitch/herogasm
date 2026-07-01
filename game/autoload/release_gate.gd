extends Node
## ReleaseGate (autoload) — feature flag build (prompts/release.md Step 8). Release build TẮT toàn bộ
## debug/cheat/overlay/profiler/verbose log. Dev/QA build bật. Nguồn: env OVERRIDE hoặc OS.is_debug_build().

var is_release: bool = false

func _ready() -> void:
	# Bản export release đặt biến môi trường HEROGASM_RELEASE=1; editor/debug -> dev.
	if OS.has_environment("HEROGASM_RELEASE"):
		is_release = OS.get_environment("HEROGASM_RELEASE") == "1"
	else:
		is_release = not OS.is_debug_build()

## Debug tools / cheat chỉ bật khi KHÔNG phải release.
func debug_enabled() -> bool:
	return not is_release
