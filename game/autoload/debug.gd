extends Node
## Debug console stub (P0) theo debug-tools.md: registry lệnh + gate theo build.
## Cheat CHỈ bật ở build debug (release không có). Thay print bằng Debug.log/warning/error.

var enabled: bool = OS.is_debug_build()
var _commands: Dictionary = {}                     # name -> {callable, help}

func _ready() -> void:
	_register_defaults()

func register_command(name: String, callable: Callable, help: String = "") -> void:
	_commands[name] = {"callable": callable, "help": help}

## Thực thi 1 dòng lệnh "name arg1 arg2". Trả chuỗi kết quả.
func execute(line: String) -> String:
	line = line.strip_edges()
	if line == "":
		return ""
	if not enabled:
		return "Debug tắt (release build)."
	var parts := line.split(" ", false)
	var name := parts[0]
	var args: Array = Array(parts.slice(1))
	if not _commands.has(name):
		return "Lệnh không tồn tại: %s (gõ 'help')" % name
	return str((_commands[name]["callable"] as Callable).call(args))

func log(msg: Variant) -> void:
	if enabled:
		print("[LOG] ", msg)

func warning(msg: Variant) -> void:
	push_warning(str(msg))

func error(msg: Variant) -> void:
	push_error(str(msg))

# --- lệnh mặc định (method có tên, tránh lambda đa dòng) -------------------
func _register_defaults() -> void:
	register_command("help", _cmd_help, "liệt kê lệnh")
	register_command("save", _cmd_save, "lưu game")
	register_command("load", _cmd_load, "nạp lại save")
	register_command("wipe", _cmd_wipe, "xoá save + new game")
	register_command("add_gold", _cmd_add_gold, "+gold <n>")
	register_command("add_gems", _cmd_add_gems, "+gems <n>")
	register_command("show_save_info", _cmd_save_info, "thông tin save")

func _cmd_help(_a: Array) -> String:
	return ", ".join(PackedStringArray(_commands.keys()))

func _cmd_save(_a: Array) -> String:
	PlayerProfile.save()
	return "saved"

func _cmd_load(_a: Array) -> String:
	PlayerProfile.from_dict(SaveManager.load_game())
	PlayerProfile._emit_all()
	return "loaded"

func _cmd_wipe(_a: Array) -> String:
	PlayerProfile.reset_progress()
	return "wiped"

func _cmd_add_gold(a: Array) -> String:
	var n := int(a[0]) if a.size() > 0 else 100
	PlayerProfile.add_gold(n)
	return "gold=%d" % PlayerProfile.gold

func _cmd_add_gems(a: Array) -> String:
	var n := int(a[0]) if a.size() > 0 else 10
	PlayerProfile.add_gems(n)
	return "gems=%d" % PlayerProfile.gems

func _cmd_save_info(_a: Array) -> String:
	return str(SaveManager.save_info())
