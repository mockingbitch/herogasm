class_name GameHud
extends CanvasLayer
## HUD P2.5 (ui.md: world always visible). Top bar ví + HeroCard (hp/fatigue/mood/injury)
## + nav toggle World/Build panel + toast (expedition/offline). Event-driven + poll nhẹ roster.

var _gold: Label
var _gems: Label
var _energy: Label
var _exp: Label
var _roster: Label
var _toast: Label
var _toast_cd: float = 0.0
var _world_panel: WorldPanel
var _build_panel: BuildPanel
var _summon_panel: SummonPanel
var _hero_panel: HeroDetailPanel

func _ready() -> void:
	_build()
	EventBus.gold_changed.connect(func(v): _gold.text = "Vàng %d" % v)
	EventBus.gems_changed.connect(func(v): _gems.text = "Gem %d" % v)
	EventBus.energy_changed.connect(func(v, m): _energy.text = "NL %d/%d" % [v, m])
	EventBus.offline_reward.connect(_on_offline)
	EventBus.hero_knocked_out.connect(func(id): _flash("%s bất tỉnh — về thành hồi" % _hero_name(id)))
	EventBus.expedition_resolved.connect(_on_exp_resolved)
	EventBus.expeditions_batch_resolved.connect(func(b): _flash("Offline: %d expedition hoàn tất" % int(b.get("count", 0)), 7.0))
	EventBus.zone_cleared.connect(func(z, s): _flash("Clear %s (%d★)" % [z, s]))
	_gold.text = "Vàng %d" % PlayerProfile.gold
	_gems.text = "Gem %d" % PlayerProfile.gems
	_energy.text = "NL %d/%d" % [PlayerProfile.energy, PlayerProfile.max_energy]

func _process(delta: float) -> void:
	_refresh_roster()
	_exp.text = "Đội đi săn: %d" % ExpeditionService.active_count()
	if _toast_cd > 0.0:
		_toast_cd -= delta
		if _toast_cd <= 0.0:
			_toast.text = ""

# --- roster HeroCards ------------------------------------------------------
func _refresh_roster() -> void:
	var lines: Array[String] = ["— ĐỘI HÌNH —"]
	for id in PlayerProfile.hero_ids:
		var h: HeroInstance = PlayerProfile.get_hero(id)
		if h == null:
			continue
		var badge := ""
		if h.is_ko:
			badge = " [KO]"
		elif h.is_injured():
			badge = " [thương%d]" % h.injury_level
		if ExpeditionService.is_on_expedition(id):
			badge += " [đi săn]"
		lines.append("%s Lv.%d %s HP %d/%d mệt%d%%%s" % [
			h.display_name, h.level, _mood_face(h.mood), h.current_hp, h.eff_max_hp(),
			int(h.fatigue), badge])
	_roster.text = "\n".join(lines)

static func _mood_face(m: float) -> String:
	if m >= 80.0: return ":D"
	elif m >= 60.0: return ":)"
	elif m >= 40.0: return ":|"
	elif m >= 20.0: return ":("
	return "T_T"

func _hero_name(id: String) -> String:
	var h: HeroInstance = PlayerProfile.get_hero(id)
	return h.display_name if h != null else id

# --- toasts ----------------------------------------------------------------
func _on_offline(s: Dictionary) -> void:
	_flash("Khi vắng ~%dph: +%d vàng, +%d xp/hero, %d expedition" % [
		int(s.get("seconds", 0)) / 60, int(s.get("gold", 0)), int(s.get("xp_each", 0)), int(s.get("expeditions", 0))], 8.0)

func _on_exp_resolved(s: Dictionary) -> void:
	var res := "thắng %d★" % int(s.get("stars", 0)) if str(s.get("outcome", "")) == "win" else "thất bại (KO)"
	_flash("%s về từ %s: %s" % [_hero_name(str(s.get("hero_id", ""))), str(s.get("zone_id", "")), res])

func _flash(msg: String, dur: float = 4.0) -> void:
	_toast.text = msg
	_toast_cd = dur

# --- build UI --------------------------------------------------------------
func _build() -> void:
	var top := HBoxContainer.new()
	top.position = Vector2(10, 8)
	top.add_theme_constant_override("separation", 14)
	add_child(top)
	_gold = _mk(top, Color(0.95, 0.8, 0.3))
	_gems = _mk(top, Color(0.65, 0.45, 0.9))
	_energy = _mk(top, Color(0.5, 0.85, 0.4))
	_exp = _mk(top, Color(0.7, 0.75, 0.85))

	_roster = _lbl(Vector2(10, 34), 11, Color(0.9, 0.88, 0.8))
	add_child(_roster)

	_toast = _lbl(Vector2(10, 210), 12, Color(0.6, 0.9, 0.6))
	add_child(_toast)

	# panels (ẩn mặc định)
	_world_panel = WorldPanel.new()
	_world_panel.position = Vector2(220, 34)
	_world_panel.visible = false
	add_child(_world_panel)
	_build_panel = BuildPanel.new()
	_build_panel.position = Vector2(220, 34)
	_build_panel.visible = false
	add_child(_build_panel)
	_summon_panel = SummonPanel.new()
	_summon_panel.position = Vector2(220, 34)
	_summon_panel.visible = false
	add_child(_summon_panel)
	_hero_panel = HeroDetailPanel.new()
	_hero_panel.position = Vector2(220, 34)
	_hero_panel.visible = false
	add_child(_hero_panel)

	# nav
	var nav := HBoxContainer.new()
	nav.position = Vector2(10, 180)
	nav.add_theme_constant_override("separation", 8)
	add_child(nav)
	_nav_btn(nav, "Đội hình", func(): _show(null))
	_nav_btn(nav, "Anh Hùng", func(): _show(_hero_panel))
	_nav_btn(nav, "Thế Giới", func(): _show(_world_panel))
	_nav_btn(nav, "Xây Dựng", func(): _show(_build_panel))
	_nav_btn(nav, "Triệu Hồi", func(): _show(_summon_panel))

func _show(panel) -> void:
	for p in [_world_panel, _build_panel, _summon_panel, _hero_panel]:
		p.visible = (p == panel)
	if panel != null and panel.has_method("refresh"):
		panel.refresh()

func _nav_btn(parent: Node, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)

func _mk(parent: Node, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", col)
	parent.add_child(l)
	return l

func _lbl(pos: Vector2, size: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
