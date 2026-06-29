class_name HubMenu
extends CanvasLayer
## Bảng thị trấn: trang bị, túi đồ, lò rèn (nâng cấp), cửa hàng, vào dungeon.
## Mở bằng E/I trong hub. Pause game khi mở.

signal enter_dungeon
signal enter_boss

var _content: VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build()

func open() -> void:
	visible = true
	get_tree().paused = true
	_rebuild()

func close() -> void:
	get_tree().paused = false
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"toggle_menu") or event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(m, 8)
	add_child(margin)

	var scroll := ScrollContainer.new()
	margin.add_child(scroll)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 2)
	_content.custom_minimum_size = Vector2(364, 0)
	scroll.add_child(_content)

func _rebuild() -> void:
	for c in _content.get_children():
		c.queue_free()

	_add(_label("THỊ TRẤN HEROGASM", 12, Color(1, 0.9, 0.5)))
	_add(_label("Vàng: %d   Cấp: %d   Điểm talent: %d" % [Profile.gold, Profile.level, Profile.talent_points]))
	_add(_label("ATK %d  DEF %d  HP %d  Tốc %d  Crit %d%%  CritDmg %d%%  Hút máu %d%%" % [
		Profile.eff_attack(), Profile.eff_defense(), Profile.eff_max_hp(), int(Profile.eff_speed()),
		int(round(Profile.eff_crit_chance() * 100)), int(round(Profile.eff_crit_damage() * 100)),
		int(round(Profile.eff_lifesteal() * 100))]))

	var top := _row()
	var enter_btn := _button("⚔ VÀO DUNGEON", _on_enter)
	top.add_child(enter_btn)
	top.add_child(_button("👑 ĐẤU BOSS", _on_boss))
	top.add_child(_button("Đóng (Esc/I)", close))

	# Trang bị + lò rèn
	_add(_label("— Trang bị / Lò rèn —", 8, Color(0.7, 0.85, 1)))
	_equip_row("weapon", "Vũ khí")
	_equip_row("armor", "Giáp")

	# Talent
	_add(_label("— Talent (điểm: %d) —" % Profile.talent_points, 8, Color(0.7, 0.85, 1)))
	for tid in Profile.TALENTS:
		var d = Profile.TALENTS[tid]
		var rank := Profile.talent_rank(tid)
		var tr := _row()
		tr.add_child(_label("%s  [%d/%d]" % [d["name"], rank, int(d["max"])]))
		var tb := _button("Học", _on_talent.bind(tid))
		tb.disabled = Profile.talent_points <= 0 or rank >= int(d["max"])
		tr.add_child(tb)

	# Cửa hàng
	_add(_label("— Cửa hàng (mua) —", 8, Color(0.7, 0.85, 1)))
	for id in Database.shop_stock:
		var data: ItemData = Database.get_item(id)
		if data == null:
			continue
		var price := Profile.buy_price(id)
		var r := _row()
		r.add_child(_label("%s (%d v)" % [data.display_name, price]))
		var b := _button("Mua", _on_buy.bind(id))
		b.disabled = Profile.gold < price
		r.add_child(b)

	# Túi đồ
	_add(_label("— Túi đồ —", 8, Color(0.7, 0.85, 1)))
	if Profile.inventory.is_empty():
		_add(_label("(trống)", 8, Color(0.6, 0.6, 0.6)))
	for i in Profile.inventory.size():
		var inst = Profile.inventory[i]
		var r := _row()
		r.add_child(_label(Profile.instance_label(inst)))
		r.add_child(_button("Trang bị", _on_equip.bind(i)))
		r.add_child(_button("Bán", _on_sell.bind(i)))

	# Nguyên liệu
	_add(_label("— Nguyên liệu —", 8, Color(0.7, 0.85, 1)))
	var mat_total := 0
	for id in Profile.materials.keys():
		var data: ItemData = Database.get_item(id)
		var n := int(Profile.materials[id])
		if data:
			mat_total += data.sell_price * n
			_add(_label("%s x%d" % [data.display_name, n], 8, Color(0.75, 0.75, 0.75)))
	if mat_total > 0:
		_add(_button("Bán hết nguyên liệu (+%d v)" % mat_total, _on_sell_materials))

	# Bình máu
	_add(_label("Bình máu: x%d" % Profile.potion_count(), 8, Color(0.8, 0.5, 0.5)))

	# Demo / Debug (giúp playtest nhanh)
	_add(_label("— DEMO / DEBUG —", 8, Color(1.0, 0.7, 0.7)))
	var dbg := _row()
	dbg.add_child(_button("+500 vàng", _on_dbg_gold))
	dbg.add_child(_button("+1 cấp", _on_dbg_level))
	dbg.add_child(_button("Thêm đồ ngẫu nhiên", _on_dbg_item))
	dbg.add_child(_button("Reset tiến trình", _on_dbg_reset))

	enter_btn.grab_focus()

# --- handlers -------------------------------------------------------------
func _on_enter() -> void:
	enter_dungeon.emit()

func _on_boss() -> void:
	enter_boss.emit()

func _on_buy(id: String) -> void:
	Profile.buy(id)
	_rebuild()

func _on_equip(i: int) -> void:
	Profile.equip(i)
	_rebuild()

func _on_sell(i: int) -> void:
	Profile.sell_gear(i)
	_rebuild()

func _on_upgrade(slot: String) -> void:
	Profile.upgrade(slot)
	_rebuild()

func _on_unequip(slot: String) -> void:
	Profile.unequip(slot)
	_rebuild()

func _on_sell_materials() -> void:
	Profile.sell_all_materials()
	_rebuild()

func _on_talent(tid: String) -> void:
	Profile.spend_talent(tid)
	_rebuild()

func _on_dbg_gold() -> void:
	Profile.add_gold(500)
	_rebuild()

func _on_dbg_level() -> void:
	Profile.gain_xp(Profile.xp_to_next())
	_rebuild()

func _on_dbg_item() -> void:
	var ids: Array = Database.items.keys()
	if ids.is_empty():
		return
	var id := str(ids[randi() % ids.size()])
	Profile.add_item(id)
	_rebuild()

func _on_dbg_reset() -> void:
	Profile.reset_progress()
	_rebuild()

# --- ui builders ----------------------------------------------------------
func _equip_row(slot: String, slot_name: String) -> void:
	var inst = Profile.equipment.get(slot)
	var r := _row()
	r.add_child(_label("%s: %s" % [slot_name, Profile.instance_label(inst)]))
	if inst != null:
		var cost := Profile.upgrade_cost(slot)
		var ub := _button("Nâng cấp (%d v)" % cost, _on_upgrade.bind(slot))
		ub.disabled = Profile.gold < cost
		r.add_child(ub)
		r.add_child(_button("Tháo", _on_unequip.bind(slot)))

func _add(node: Control) -> void:
	_content.add_child(node)

func _row() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	_content.add_child(h)
	return h

func _label(text: String, size: int = 8, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 8)
	b.pressed.connect(cb)
	return b
