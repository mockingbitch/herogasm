extends Node
## Tiện ích toàn cục cho gameplay (transient). Dữ liệu bền vững -> xem Profile.

func _ready() -> void:
	_register_input_actions()

## Đóng băng hình vài mili-giây tạo cảm giác "đập" khi trúng đòn.
func hit_stop(duration: float = 0.05) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

# --- Đăng ký Input bằng code -------------------------------------------------
# TODO: chuyển sang Project Settings > Input Map khi ổn định.
func _register_input_actions() -> void:
	_add_action(&"move_left",  [_key(KEY_A), _key(KEY_LEFT)])
	_add_action(&"move_right", [_key(KEY_D), _key(KEY_RIGHT)])
	_add_action(&"move_up",    [_key(KEY_W), _key(KEY_UP)])
	_add_action(&"move_down",  [_key(KEY_S), _key(KEY_DOWN)])
	_add_action(&"attack",     [_key(KEY_J), _key(KEY_SPACE), _mouse(MOUSE_BUTTON_LEFT)])
	_add_action(&"dodge",      [_key(KEY_K), _key(KEY_SHIFT)])
	_add_action(&"skill_1",    [_key(KEY_L)])
	_add_action(&"use_item",   [_key(KEY_Q)])
	_add_action(&"interact",   [_key(KEY_E), _key(KEY_ENTER), _key(KEY_KP_ENTER)])
	_add_action(&"toggle_menu",[_key(KEY_I), _key(KEY_TAB)])
	_add_action(&"restart",    [_key(KEY_R)])

func _add_action(action: StringName, events: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for ev in events:
		InputMap.action_add_event(action, ev)

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e

func _mouse(button: MouseButton) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = button
	return e
