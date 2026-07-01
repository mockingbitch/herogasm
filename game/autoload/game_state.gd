extends Node
## Tiện ích toàn cục transient. Dữ liệu bền vững -> PlayerProfile.
## P0: bỏ hit_stop (action combat); rút input map còn tối thiểu cho UI mobile.
## TODO(P1): chuyển input sang Project Settings > Input Map + touch controls.

func _ready() -> void:
	_register_input_actions()

func _register_input_actions() -> void:
	_add_action(&"interact",      [_key(KEY_E), _key(KEY_ENTER), _key(KEY_KP_ENTER)])
	_add_action(&"toggle_menu",   [_key(KEY_TAB)])
	_add_action(&"quick_save",    [_key(KEY_F5)])
	_add_action(&"quick_load",    [_key(KEY_F6)])
	_add_action(&"debug_console", [_key(KEY_F12)])

func _add_action(action: StringName, events: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for ev in events:
		InputMap.action_add_event(action, ev)

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e
