class_name SeasonPanel
extends Control
## Panel Chiến Dịch (P5): Story campaign (chapter hiện tại + complete + feature unlock), Season
## (start/rollover + battle pass + events + seasonal shop). UI chỉ đọc + gọi service (signal-rules.md).

var _box: VBoxContainer
var _msg: Label
var _refresh_cd: float = 0.0

func _ready() -> void:
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 2)
	add_child(_box)
	refresh()

func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_cd -= delta
	if _refresh_cd <= 0.0:
		_refresh_cd = 0.7
		refresh()

func refresh() -> void:
	if _box == null:
		return
	for c in _box.get_children():
		c.queue_free()
	_story_section()
	_season_section()
	_msg = _label("", Color(0.6, 0.9, 0.6), 10)

# --- Story -----------------------------------------------------------------
func _story_section() -> void:
	_header("— CHIẾN DỊCH —", Color(0.9, 0.82, 0.6))
	_label("  Arc: %s · hoàn thành %d chương" % [StoryManager.current_arc(), StoryManager.completed_count()],
		Color(0.85, 0.8, 0.7), 10)
	var cd: ChapterDef = StoryManager.get_current_chapter()
	if cd == null:
		_label("  (đã hết chương)", Color(0.7, 0.7, 0.7), 10)
	else:
		_label("  Chương: %s" % cd.display_name, Color(0.9, 0.85, 0.75), 10)
		var dlg: DialogueDef = Database.get_dialogue_def(str(cd.intro_dialogue_id))
		if dlg != null and dlg.line_count() > 0:
			_label("   « %s »" % str(dlg.lines[0].get("text", "")), Color(0.7, 0.75, 0.8), 9)
		var row := HBoxContainer.new()
		_btn(row, "Hoàn thành", func(): _do(func():
			return "xong %s" % cd.display_name if StoryManager.complete_chapter(str(cd.id)) else "chưa đủ điều kiện"))
		_box.add_child(row)
	# feature gate hiển thị
	var feats := ["rune_system", "expedition", "arena", "world_boss"]
	var line := "  Mở khoá:"
	for f in feats:
		line += " %s%s" % [f, "✓" if StoryManager.is_feature_unlocked(f) else "🔒"]
	_label(line, Color(0.75, 0.8, 0.75), 9)

# --- Season ----------------------------------------------------------------
func _season_section() -> void:
	_header("— MÙA (SEASON) —", Color(0.6, 0.8, 0.95))
	if SeasonManager.is_season_active():
		var s: SeasonDef = SeasonManager.active_season()
		_label("  %s · còn %d ngày" % [s.display_name, SeasonManager.time_remaining_days()], Color(0.8, 0.85, 0.95), 10)
		_label("  BattlePass Lv.%d · Honor %d" % [BattlePassService.level(), PlayerProfile.honor()], Color(0.8, 0.8, 0.9), 9)
		_label("  Event: %s" % str(EventManager.active_event_ids()), Color(0.8, 0.82, 0.85), 9)
		if s.seasonal_currency_id != &"":
			_label("  %s: %d" % [str(s.seasonal_currency_id), PlayerProfile.currency_amount(str(s.seasonal_currency_id))],
				Color(0.7, 0.85, 0.9), 9)
		var row := HBoxContainer.new()
		_btn(row, "Lễ hội", func(): _do(func(): return str(EventManager.start_event("frost_festival"))))
		_btn(row, "Tua 7 ngày", func(): _do(func():
			TimeService.advance_game_time(7.0 * TimeService.SECONDS_PER_GAME_DAY)
			if SeasonManager.should_rollover():
				SeasonManager.rollover(); return "season kết thúc"
			return "còn %d ngày" % SeasonManager.time_remaining_days()))
		_box.add_child(row)
		_shop_section(s)
	else:
		var row := HBoxContainer.new()
		_btn(row, "Bắt đầu Mùa Băng Giá", func(): _do(func():
			return "season=%s" % str(SeasonManager.start_season("season_of_frost"))))
		_box.add_child(row)

func _shop_section(s: SeasonDef) -> void:
	var stock := SeasonalShopService.stock(str(s.seasonal_shop_id))
	for i in stock.size():
		var it: Dictionary = stock[i]
		var reward: Dictionary = it.get("reward", {})
		var row := HBoxContainer.new()
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 9)
		l.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		l.text = "  %s x%d — %d %s" % [str(reward.get("type", "?")), int(reward.get("amount", 1)),
			int(it.get("cost", 0)), str(it.get("currency", ""))]
		row.add_child(l)
		var idx := i
		_btn(row, "Mua", func(): _do(func():
			return str(SeasonalShopService.purchase(str(s.seasonal_shop_id), idx).get("reason", "OK"))))
		_box.add_child(row)

# --- helpers ---------------------------------------------------------------
func _do(action: Callable) -> void:
	var text := str(action.call())
	refresh()
	if _msg != null:
		_msg.text = "  » " + text

func _btn(parent: Node, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)

func _header(text: String, col: Color) -> void:
	_label(text, col, 11)

func _label(text: String, col: Color, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	_box.add_child(l)
	return l
