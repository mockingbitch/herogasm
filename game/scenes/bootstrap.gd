extends Node
## Main scene P0 — điểm neo kiểm chứng spine (chưa có gameplay).
## Hiển thị trạng thái PlayerProfile; F5 lưu, F6 nạp lại, F12 console debug.

var _status: Label
var _console: LineEdit
var _toast: Label

func _ready() -> void:
	EventBus.save_completed.connect(_on_save_completed)
	EventBus.gold_changed.connect(func(_v): _refresh())
	EventBus.xp_changed.connect(func(_a, _b, _c): _refresh())
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := VBoxContainer.new()
	root.position = Vector2(16, 16)
	root.add_theme_constant_override("separation", 8)
	layer.add_child(root)

	var title := Label.new()
	title.text = "Herogasm — P0 spine OK"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.95, 0.78, 0.35))
	root.add_child(title)

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 14)
	root.add_child(_status)

	var hint := Label.new()
	hint.text = "[F5] Lưu   ·   [F6] Nạp lại   ·   [F12] Console"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	root.add_child(hint)

	_toast = Label.new()
	_toast.add_theme_font_size_override("font_size", 12)
	_toast.add_theme_color_override("font_color", Color(0.5, 0.85, 0.5))
	root.add_child(_toast)

	_console = LineEdit.new()
	_console.placeholder_text = "console: help / add_gold 500 / show_save_info"
	_console.custom_minimum_size = Vector2(360, 0)
	_console.visible = false
	_console.text_submitted.connect(_on_command)
	root.add_child(_console)

func _refresh() -> void:
	var lines: Array[String] = []
	lines.append("Vàng: %d   Gems: %d   Hero: %d" % [PlayerProfile.gold, PlayerProfile.gems, PlayerProfile.hero_ids.size()])
	var h: HeroInstance = PlayerProfile.primary_hero()
	if h != null:
		lines.append("%s  Lv.%d  (XP %d/%d)" % [
			h.display_name if h.display_name != "" else h.hero_id, h.level, h.xp, h.xp_to_next()])
		lines.append("ATK %d · DEF %d · HP %d/%d · Crit %d%%" % [
			h.eff_attack(), h.eff_defense(), h.current_hp, h.eff_max_hp(),
			int(round(h.eff_crit_chance() * 100))])
	lines.append("Bình máu: %d" % PlayerProfile.potion_count())
	if _status != null:
		_status.text = "\n".join(lines)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"quick_save"):
		PlayerProfile.save()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"quick_load"):
		PlayerProfile.from_dict(SaveManager.load_game())
		PlayerProfile._emit_all()
		_refresh()
		_flash("Đã nạp lại save")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"debug_console"):
		_console.visible = not _console.visible
		if _console.visible:
			_console.grab_focus()
		get_viewport().set_input_as_handled()

func _on_command(text: String) -> void:
	var result := Debug.execute(text)
	_console.text = ""
	_refresh()
	_flash(result)

func _on_save_completed(ok: bool) -> void:
	_flash("save_completed ok=%s" % str(ok))

func _flash(msg: String) -> void:
	if _toast != null:
		_toast.text = msg
