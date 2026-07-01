class_name SummonPanel
extends Control
## Panel Triệu Hồi: pull x1/x10 + pity bar + collection count. Gọi PlayerProfile.summon (claim-id an toàn).

var _box: VBoxContainer
var _pull_seq: int = 0
var _refresh_cd: float = 0.0

func _ready() -> void:
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 3)
	add_child(_box)
	refresh()

func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_cd -= delta
	if _refresh_cd <= 0.0:
		_refresh_cd = 0.5
		refresh()

func refresh() -> void:
	if _box == null:
		return
	for c in _box.get_children():
		c.queue_free()
	_header("— TRIỆU HỒI — (Gem %d)" % PlayerProfile.gems)
	for bid in Database.banner_ids():
		var b: BannerDef = Database.get_banner_def(bid)
		var st: Dictionary = PlayerProfile.pity_counters.get(bid, {"since_guaranteed": 0})
		_line("%s — pity %d/%d" % [b.display_name, int(st.get("since_guaranteed", 0)), b.pity_hard])
		var row := HBoxContainer.new()
		_pull_btn(row, "Triệu x1 (%d💎)" % b.cost_amount, bid, 1)
		_pull_btn(row, "x10 (%d💎)" % (b.cost_amount * 10), bid, 10)
		_box.add_child(row)
	_line("Bộ sưu tập: %d hero" % PlayerProfile.collection_count())

func _pull_btn(parent: Node, text: String, banner_id: String, n: int) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(func(): _pull(banner_id, n))
	parent.add_child(b)

func _pull(banner_id: String, n: int) -> void:
	_pull_seq += 1
	PlayerProfile.summon(banner_id, n, "ui_pull_%d" % _pull_seq)   # claim_id duy nhất/lần bấm
	refresh()

func _header(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color(0.65, 0.45, 0.9))
	_box.add_child(l)

func _line(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	_box.add_child(l)
