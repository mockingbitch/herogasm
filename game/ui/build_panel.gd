class_name BuildPanel
extends Control
## Panel Xây Dựng: list 7 building + nút nâng cấp (cost từ EconomyService qua BuildingDef).

var _box: VBoxContainer

func _ready() -> void:
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 3)
	add_child(_box)
	refresh()

func refresh() -> void:
	if _box == null:
		return
	for c in _box.get_children():
		c.queue_free()
	_header("— XÂY DỰNG (Vàng %d) —" % PlayerProfile.gold)
	for s in ServiceRegistry.all():
		var b := s["node"] as Building
		if b == null or b.def == null:
			continue
		_building_row(b)

func _building_row(b: Building) -> void:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	lbl.text = "  %s Lv.%d" % [b.def.display_name, b.level]
	row.add_child(lbl)
	var btn := Button.new()
	if b.can_upgrade():
		var cost := b.upgrade_cost()
		btn.text = "Nâng (%d vàng)" % cost
		btn.disabled = PlayerProfile.gold < cost
		btn.pressed.connect(func(): _upgrade(b))
	else:
		btn.text = "MAX"
		btn.disabled = true
	row.add_child(btn)
	_box.add_child(row)

func _upgrade(b: Building) -> void:
	if b.upgrade():
		refresh()

func _header(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	_box.add_child(l)
