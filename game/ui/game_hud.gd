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
var _battle_panel: BattlePanel
var _season_panel: SeasonPanel
var _panel_bg: Panel

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
	EventBus.world_boss_spawned.connect(func(id): _flash("⚔ World Boss xuất hiện: %s" % id, 6.0))
	EventBus.world_boss_ended.connect(func(id, st): _flash("World Boss %s kết thúc (%d)" % [id, st], 6.0))
	EventBus.stage_cleared.connect(func(sid, s): _flash("Ải %s: %d★" % [sid, s]))
	EventBus.arena_match_finished.connect(func(r): _flash("Đấu Trường: MMR%+d, +%d honor" % [int(r.get("mmr_delta", 0)), int(r.get("honor_gained", 0))]))
	EventBus.story_chapter_completed.connect(func(id): _flash("📖 Hoàn thành chương: %s" % id, 6.0))
	EventBus.story_feature_unlocked.connect(func(key): _flash("🔓 Mở khoá: %s" % key, 6.0))
	EventBus.season_started.connect(func(id): _flash("❄ Mùa mới bắt đầu: %s" % id, 7.0))
	EventBus.event_started.connect(func(id): _flash("🎉 Sự kiện: %s" % id, 5.0))
	EventBus.world_state_changed.connect(func(reg, k, v): _flash("🌍 %s: %s = %s" % [reg, k, str(v)], 6.0))
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

# --- build UI (dark-fantasy: top bar · roster panel · content · bottom nav) --
const VW := 540.0
const VH := 960.0

func _build() -> void:
	# Top resource bar
	var topbar := Panel.new()
	topbar.position = Vector2(0, 0)
	topbar.size = Vector2(VW, 48)
	add_child(topbar)
	var top := HBoxContainer.new()
	top.position = Vector2(14, 12)
	top.add_theme_constant_override("separation", 22)
	topbar.add_child(top)
	_gold = _mk(top, Color(0.98, 0.82, 0.32))
	_gems = _mk(top, Color(0.7, 0.5, 0.95))
	_energy = _mk(top, Color(0.55, 0.88, 0.45))
	_exp = _mk(top, Color(0.72, 0.78, 0.9))

	# Roster panel (trái, dưới top bar)
	var roster_bg := Panel.new()
	roster_bg.position = Vector2(8, 56)
	roster_bg.size = Vector2(240, 196)
	add_child(roster_bg)
	_roster = _lbl(Vector2(10, 8), 12, Color(0.92, 0.9, 0.82))
	roster_bg.add_child(_roster)

	# Nền panel nội dung dùng chung (hiện khi mở 1 panel)
	_panel_bg = Panel.new()
	_panel_bg.position = Vector2(256, 56)
	_panel_bg.size = Vector2(278, 786)
	_panel_bg.visible = false
	add_child(_panel_bg)

	# panels (ẩn mặc định)
	for p in _make_panels():
		p.position = Vector2(268, 66)
		p.visible = false
		add_child(p)

	_toast = _lbl(Vector2(14, VH - 96), 13, Color(0.75, 0.95, 0.7))
	add_child(_toast)

	# Bottom nav bar
	var navbar := Panel.new()
	navbar.position = Vector2(0, VH - 56)
	navbar.size = Vector2(VW, 56)
	add_child(navbar)
	var nav := HBoxContainer.new()
	nav.position = Vector2(8, 10)
	nav.add_theme_constant_override("separation", 4)
	navbar.add_child(nav)
	_nav_btn(nav, "Đội hình", func(): _show(null))
	_nav_btn(nav, "Hero", func(): _show(_hero_panel))
	_nav_btn(nav, "Thế Giới", func(): _show(_world_panel))
	_nav_btn(nav, "Xây Dựng", func(): _show(_build_panel))
	_nav_btn(nav, "Triệu Hồi", func(): _show(_summon_panel))
	_nav_btn(nav, "Trận", func(): _show(_battle_panel))
	_nav_btn(nav, "Chiến Dịch", func(): _show(_season_panel))

func _make_panels() -> Array:
	_world_panel = WorldPanel.new()
	_build_panel = BuildPanel.new()
	_summon_panel = SummonPanel.new()
	_hero_panel = HeroDetailPanel.new()
	_battle_panel = BattlePanel.new()
	_season_panel = SeasonPanel.new()
	return [_world_panel, _build_panel, _summon_panel, _hero_panel, _battle_panel, _season_panel]

func _show(panel) -> void:
	for p in [_world_panel, _build_panel, _summon_panel, _hero_panel, _battle_panel, _season_panel]:
		p.visible = (p == panel)
	_panel_bg.visible = panel != null
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
