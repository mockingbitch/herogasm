class_name GameHud
extends CanvasLayer
## HUD event-driven (ui.md): TopBar (Gold/Gem/Energy) + roster list + popup offline.
## Gameplay -> State -> ViewModel(poll nhẹ) -> UI. UI KHÔNG sửa gameplay trực tiếp.

var _gold: Label
var _gems: Label
var _energy: Label
var _roster: Label
var _toast: Label
var _toast_cd: float = 0.0

func _ready() -> void:
	_build()
	EventBus.gold_changed.connect(func(v): _gold.text = "Vàng %d" % v)
	EventBus.gems_changed.connect(func(v): _gems.text = "Gem %d" % v)
	EventBus.energy_changed.connect(func(v, m): _energy.text = "NL %d/%d" % [v, m])
	EventBus.offline_reward.connect(_on_offline)
	EventBus.hero_knocked_out.connect(func(id): _flash("%s bất tỉnh — về thành hồi" % id))
	# init
	_gold.text = "Vàng %d" % PlayerProfile.gold
	_gems.text = "Gem %d" % PlayerProfile.gems
	_energy.text = "NL %d/%d" % [PlayerProfile.energy, PlayerProfile.max_energy]

func _process(delta: float) -> void:
	_refresh_roster()
	if _toast_cd > 0.0:
		_toast_cd -= delta
		if _toast_cd <= 0.0:
			_toast.text = ""

func _refresh_roster() -> void:
	var lines: Array[String] = ["— ĐỘI HÌNH —"]
	for id in PlayerProfile.hero_ids:
		var h: HeroInstance = PlayerProfile.get_hero(id)
		if h == null:
			continue
		var ko := " (KO)" if h.is_ko else ""
		lines.append("%s  Lv.%d  HP %d/%d%s" % [h.display_name, h.level, h.current_hp, h.eff_max_hp(), ko])
	_roster.text = "\n".join(lines)

func _on_offline(s: Dictionary) -> void:
	_flash("Khi bạn vắng mặt ~%dph: +%d vàng, +%d xp/hero" % [int(s.get("seconds", 0)) / 60, int(s.get("gold", 0)), int(s.get("xp_each", 0))], 8.0)

func _flash(msg: String, dur: float = 4.0) -> void:
	_toast.text = msg
	_toast_cd = dur

func _build() -> void:
	var top := HBoxContainer.new()
	top.position = Vector2(10, 8)
	top.add_theme_constant_override("separation", 16)
	add_child(top)
	_gold = _mk(top, Color(0.95, 0.8, 0.3))
	_gems = _mk(top, Color(0.65, 0.45, 0.9))
	_energy = _mk(top, Color(0.5, 0.85, 0.4))

	_roster = Label.new()
	_roster.position = Vector2(10, 40)
	_roster.add_theme_font_size_override("font_size", 11)
	_roster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_roster)

	_toast = Label.new()
	_toast.position = Vector2(10, 300)
	_toast.add_theme_font_size_override("font_size", 12)
	_toast.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast)

func _mk(parent: Node, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", col)
	parent.add_child(l)
	return l
