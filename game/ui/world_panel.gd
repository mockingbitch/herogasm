class_name WorldPanel
extends Control
## Panel Thế Giới: list region/zone (lock/sao) + nút Phái đoàn + expedition đang chạy + tăng tốc gem.
## Rebuild nội dung mỗi 0.5s khi hiển thị (đếm ngược + trạng thái đổi). UI chỉ đọc/điều khiển service.

var _box: VBoxContainer
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
		_refresh_cd = 0.5
		refresh()

func refresh() -> void:
	if _box == null:
		return
	for c in _box.get_children():
		c.queue_free()
	_header("— THẾ GIỚI —", Color(0.9, 0.85, 0.6))
	for rid in Database.region_ids():
		var r: RegionDef = Database.get_region_def(rid)
		if r == null:
			continue
		var runlocked := WorldMap.is_region_unlocked(rid, PlayerProfile)
		_header("  %s%s" % [r.display_name, "" if runlocked else " 🔒(Lv.%d)" % r.required_level],
			Color(0.7, 0.8, 0.95) if runlocked else Color(0.5, 0.5, 0.5))
		for zid in r.zone_ids:
			_zone_row(zid)
	_header("— ĐANG ĐI SĂN —", Color(0.9, 0.85, 0.6))
	for e in ExpeditionService.active():
		_exp_row(e)

func _zone_row(zid: String) -> void:
	var z: ZoneDef = Database.get_zone_def(zid)
	if z == null:
		return
	var row := HBoxContainer.new()
	var unlocked := PlayerProfile.is_zone_unlocked(zid)
	var stars := PlayerProfile.zone_stars(zid)
	var star_txt := "★".repeat(stars) + "☆".repeat(maxi(0, 3 - stars))
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 10)
	if unlocked:
		lbl.text = "    %s %s (NL%d)" % [z.display_name, star_txt, z.energy_cost]
		lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	else:
		lbl.text = "    %s 🔒 Lv.%d/%d★" % [z.display_name, z.required_level, z.unlock_by_stars]
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	row.add_child(lbl)
	if unlocked:
		var free := ExpeditionService.first_free_hero()
		var b := Button.new()
		b.text = "Phái"
		b.disabled = free == "" or not ExpeditionService.can_start(free, zid)["ok"]
		b.pressed.connect(func(): _dispatch(zid))
		row.add_child(b)
	_box.add_child(row)

func _exp_row(e: ExpeditionState) -> void:
	var row := HBoxContainer.new()
	var h: HeroInstance = PlayerProfile.get_hero(e.hero_id)
	var nm := h.display_name if h != null else e.hero_id
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.75))
	lbl.text = "  %s → %s (còn %ds)" % [nm, e.zone_id, int(ExpeditionService.remaining(e))]
	row.add_child(lbl)
	var b := Button.new()
	b.text = "Tăng tốc(1💎)"
	b.disabled = PlayerProfile.gems < 1
	b.pressed.connect(func(): ExpeditionService.speedup(e.id, 1))
	row.add_child(b)
	_box.add_child(row)

func _dispatch(zid: String) -> void:
	var free := ExpeditionService.first_free_hero()
	if free != "":
		ExpeditionService.start(free, zid)
	refresh()

func _header(text: String, col: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", col)
	_box.add_child(l)
