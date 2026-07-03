class_name GameHud
extends CanvasLayer
## HUD "màn Bãi Săn" theo demo-play (ui.md: world always visible).
## Layout: player card + resource pills + menu 2x2 (top) · Quest + Auto (trái) ·
## Minimap + Event + x2EXP (phải) · chat log + skill bar + hero party bar + nav (dưới).
## Event-driven + poll nhẹ (HP party, timers). Nav mở panel popup (giữ từ P2.5).

const VW := 540.0
const VH := 1138.0
const ICON := "res://assets/ui/icons/named/"

var _gold: Label
var _gems: Label
var _energy: Label
var _toast: Label
var _toast_cd: float = 0.0
var _chat_log: Label
var _party := []           # mảng dict {name, lv, hp, xN}
var _event_timers := []    # mảng dict {label, remain}
var _timer_acc: float = 0.0

var _world_panel: WorldPanel
var _build_panel: BuildPanel
var _summon_panel: SummonPanel
var _hero_panel: HeroDetailPanel
var _battle_panel: BattlePanel
var _season_panel: SeasonPanel
var _panel_bg: Panel

# minimap + boss target (bind từ world qua bind_world)
var _world: Node = null
var _spawner = null
var _minimap: MiniMap = null
var _boss_root: Control = null
var _boss_name: Label = null
var _boss_hp: ProgressBar = null
var _boss_target = null
var _boss_hp_val: float = 100.0

## world.gd gọi để cấp nguồn dữ liệu sống cho minimap + boss nameplate.
func bind_world(w: Node, sp, field: Rect2) -> void:
	_world = w
	_spawner = sp
	if _minimap != null:
		_minimap.spawner = sp
		_minimap.world_node = w
		_minimap.field = field

## Minimap live: vẽ dot hero (xanh) + monster (đỏ) theo vị trí thật trong FIELD_RECT.
class MiniMap extends Control:
	var spawner = null
	var world_node: Node = null
	var field: Rect2 = Rect2()
	var _acc: float = 0.0

	func _process(delta: float) -> void:
		_acc += delta
		if _acc >= 0.2:      # ~5 FPS (ui.md: minimap không cần realtime)
			_acc = 0.0
			queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.13, 0.17, 0.12))
		if field.size.x <= 0.0 or field.size.y <= 0.0:
			return
		if spawner != null:
			for m in spawner._alive:
				if m != null and is_instance_valid(m) and m.is_alive():
					_dot(m.global_position, Color(0.9, 0.32, 0.3), 2.0)
		if world_node != null:
			for c in world_node.get_children():
				if c is Hero:
					_dot(c.global_position, Color(0.42, 0.72, 1.0), 2.5)

	func _dot(wp: Vector2, col: Color, r: float) -> void:
		var lx := (wp.x - field.position.x) / field.size.x * size.x
		var ly := (wp.y - field.position.y) / field.size.y * size.y
		if lx < 0.0 or ly < 0.0 or lx > size.x or ly > size.y:
			return
		draw_circle(Vector2(lx, ly), r, col)

func _ready() -> void:
	_build()
	EventBus.gold_changed.connect(func(v): _gold.text = _fmt(v))
	EventBus.gems_changed.connect(func(v): _gems.text = _fmt(v))
	EventBus.energy_changed.connect(func(v, m): _energy.text = "%d/%d" % [v, m])
	EventBus.offline_reward.connect(_on_offline)
	EventBus.hero_knocked_out.connect(func(id): _log("%s bất tỉnh — về thành hồi" % _hero_name(id)))
	EventBus.expedition_resolved.connect(_on_exp_resolved)
	EventBus.expeditions_batch_resolved.connect(func(b): _flash("Offline: %d expedition hoàn tất" % int(b.get("count", 0)), 7.0))
	EventBus.zone_cleared.connect(func(z, s): _log("Clear %s (%d★)" % [z, s]))
	EventBus.world_boss_spawned.connect(func(id): _flash("⚔ World Boss: %s" % id, 6.0))
	EventBus.stage_cleared.connect(func(sid, s): _log("Ải %s: %d★" % [sid, s]))
	EventBus.arena_match_finished.connect(func(r): _log("Đấu Trường: MMR%+d" % int(r.get("mmr_delta", 0))))
	EventBus.story_chapter_completed.connect(func(id): _flash("📖 Hoàn thành chương: %s" % id, 6.0))
	EventBus.story_feature_unlocked.connect(func(key): _flash("🔓 Mở khoá: %s" % key, 6.0))
	EventBus.season_started.connect(func(id): _flash("❄ Mùa mới: %s" % id, 7.0))
	EventBus.event_started.connect(func(id): _flash("🎉 Sự kiện: %s" % id, 5.0))
	_gold.text = _fmt(PlayerProfile.gold)
	_gems.text = _fmt(PlayerProfile.gems)
	_energy.text = "%d/%d" % [PlayerProfile.energy, PlayerProfile.max_energy]

func _process(delta: float) -> void:
	_refresh_party()
	_update_boss(delta)
	if _toast_cd > 0.0:
		_toast_cd -= delta
		if _toast_cd <= 0.0:
			_toast.text = ""
	# đếm ngược event mỗi giây (nhẹ)
	_timer_acc += delta
	if _timer_acc >= 1.0:
		_timer_acc = 0.0
		for e in _event_timers:
			e["remain"] = maxi(0, int(e["remain"]) - 1)
			e["label"].text = _hms(e["remain"])

# --- format helpers --------------------------------------------------------
static func _fmt(v: int) -> String:
	var s := str(absi(v))
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if v < 0 else "") + out

static func _hms(sec: int) -> String:
	return "%02d:%02d:%02d" % [sec / 3600, (sec / 60) % 60, sec % 60]

static func _mood_face(m: float) -> String:
	if m >= 80.0: return ":D"
	elif m >= 60.0: return ":)"
	elif m >= 40.0: return ":|"
	elif m >= 20.0: return ":("
	return "T_T"

func _hero_name(id: String) -> String:
	var h: HeroInstance = PlayerProfile.get_hero(id)
	return h.display_name if h != null else id

# --- party bar (6 card: avatar + tên/Lv + xN + HP) -------------------------
func _refresh_party() -> void:
	var ids := PlayerProfile.hero_ids
	for i in _party.size():
		var card: Dictionary = _party[i]
		if i < ids.size():
			var h: HeroInstance = PlayerProfile.get_hero(ids[i])
			if h == null:
				card["root"].visible = false
				continue
			card["root"].visible = true
			var badge := ""
			if h.is_ko: badge = " KO"
			elif h.is_injured(): badge = " ✚"
			if ExpeditionService.is_on_expedition(ids[i]): badge = " ⚑"
			card["name"].text = "%s%s" % [h.display_name, badge]
			card["lv"].text = "Lv.%d" % h.level
			var hp: ProgressBar = card["hp"]
			hp.max_value = maxi(1, h.eff_max_hp())
			hp.value = clampi(h.current_hp, 0, h.eff_max_hp())
			card["hplbl"].text = "%d/%d" % [h.current_hp, h.eff_max_hp()]
		else:
			card["root"].visible = false

# --- toasts / log ----------------------------------------------------------
func _on_offline(s: Dictionary) -> void:
	_flash("Khi vắng ~%dph: +%d vàng, +%d xp/hero" % [int(s.get("seconds", 0)) / 60, int(s.get("gold", 0)), int(s.get("xp_each", 0))], 8.0)

func _on_exp_resolved(s: Dictionary) -> void:
	var res := "thắng %d★" % int(s.get("stars", 0)) if str(s.get("outcome", "")) == "win" else "thất bại (KO)"
	_log("%s về từ %s: %s" % [_hero_name(str(s.get("hero_id", ""))), str(s.get("zone_id", "")), res])

func _flash(msg: String, dur: float = 4.0) -> void:
	_toast.text = msg
	_toast_cd = dur
	_log(msg)

func _log(msg: String) -> void:
	if _chat_log == null:
		return
	var lines := _chat_log.text.split("\n", false)
	var arr: Array = []
	for l in lines:
		arr.append(l)
	arr.append("[Hệ thống] " + msg)
	while arr.size() > 6:
		arr.pop_front()
	_chat_log.text = "\n".join(arr)

# ===========================================================================
# BUILD LAYOUT (bám demo-play.png)
# ===========================================================================
func _build() -> void:
	_build_top()
	_build_left()
	_build_right()
	_build_boss_bar()
	_build_bottom()
	_build_popups()

## Boss/target bar giữa-trên map: nameplate = quái gần tâm (thật), HP = xấp xỉ auto-battle.
func _build_boss_bar() -> void:
	_boss_root = _panel(Vector2(VW / 2.0 - 104, 150), Vector2(208, 34))
	_boss_name = _text(_boss_root, Vector2(8, 3), "", 12, Color(0.95, 0.42, 0.36))
	_boss_hp = ProgressBar.new()
	_boss_hp.position = Vector2(8, 20)
	_boss_hp.custom_minimum_size = Vector2(192, 8)
	_boss_hp.size = Vector2(192, 8)
	_boss_hp.show_percentage = false
	_boss_hp.max_value = 100
	_boss_hp.value = 100
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.82, 0.22, 0.2)
	fill.set_corner_radius_all(2)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.08, 0.08)
	bg.set_corner_radius_all(2)
	_boss_hp.add_theme_stylebox_override("fill", fill)
	_boss_hp.add_theme_stylebox_override("background", bg)
	_boss_hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_root.add_child(_boss_hp)
	_boss_root.visible = false

func _update_boss(delta: float) -> void:
	if _boss_root == null or _spawner == null:
		return
	# Thanh máu CHỈ hiện khi có boss trong field (quái thường: không hiện).
	var boss = null
	for m in _spawner._alive:
		if m != null and is_instance_valid(m) and m.is_alive() and m.data != null and m.data.is_boss:
			boss = m
			break
	if boss == null:
		_boss_root.visible = false
		_boss_target = null
		return
	_boss_root.visible = true
	if boss != _boss_target:
		_boss_target = boss
		_boss_hp_val = 100.0
		var lv := maxi(1, int(boss.data.max_hp / 6.0))
		_boss_name.text = "Lv.%d %s" % [lv, boss.data.display_name]
	else:
		_boss_hp_val = maxf(6.0, _boss_hp_val - delta * 15.0)   # xấp xỉ hero whittle HP
	_boss_hp.value = _boss_hp_val

# --- TOP: player card + resource pills + menu 2x2 --------------------------
func _build_top() -> void:
	# Player card
	var card := _panel(Vector2(6, 6), Vector2(158, 96))
	_tex(card, Vector2(8, 8), Vector2(46, 46), "res://assets/ui/icons/player_info/icon-01.png")
	_text(card, Vector2(60, 8), "Lãnh Chúa", 13, Color(0.96, 0.92, 0.8))
	_text(card, Vector2(60, 26), "Lv.%d" % maxi(1, PlayerProfile.hero_ids.size()), 11, Color(0.75, 0.8, 0.9))
	var php := _hpbar(card, Vector2(60, 46), Vector2(92, 12))
	php.value = 100
	_tex(card, Vector2(8, 62), Vector2(20, 20), ICON + "nav-battle.png")
	_text(card, Vector2(32, 64), _fmt(PlayerProfile.gold + PlayerProfile.gems), 13, Color(0.98, 0.85, 0.4))

	# Resource pills
	var gp := _panel(Vector2(170, 8), Vector2(126, 30))
	_tex(gp, Vector2(4, 5), Vector2(20, 20), ICON + "res-gold.png")
	_gold = _text(gp, Vector2(28, 7), "0", 13, Color(0.98, 0.85, 0.4))
	var mp := _panel(Vector2(302, 8), Vector2(96, 30))
	_tex(mp, Vector2(4, 5), Vector2(20, 20), ICON + "res-gem.png")
	_gems = _text(mp, Vector2(28, 7), "0", 13, Color(0.72, 0.55, 0.96))
	_mini_btn(Vector2(402, 10), "+")
	var ep := _panel(Vector2(170, 42), Vector2(126, 30))
	_tex(ep, Vector2(4, 5), Vector2(20, 20), ICON + "res-energy.png")
	_energy = _text(ep, Vector2(28, 7), "0/0", 13, Color(0.6, 0.9, 0.5))
	_mini_btn(Vector2(302, 44), "+")

	# Menu 2x2 (top-right)
	var menu := [
		["res://assets/ui/icons/topbar/icon-01.png", "Hộp Thư"],
		["res://assets/ui/icons/topbar/icon-02.png", "Sự Kiện"],
		["res://assets/ui/icons/topbar/icon-03.png", "Nhiệm Vụ"],
		["res://assets/ui/icons/topbar/icon-04.png", "Cài Đặt"],
	]
	var mcols := [434.0, 486.0]
	var mrows := [6.0, 52.0]
	for i in menu.size():
		var ix: float = mcols[i % 2]
		var iy: float = mrows[i / 2]
		_icon_btn(Vector2(ix, iy), Vector2(34, 34), menu[i][0], menu[i][1], func(): _flash(menu[i][1]))
		var ml := _text(self, Vector2(ix - 7, iy + 33), menu[i][1], 8, Color(0.85, 0.85, 0.92))
		ml.custom_minimum_size = Vector2(48, 0)
		ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

# --- LEFT: Quest panel + Auto toggle ---------------------------------------
func _build_left() -> void:
	var q := _panel(Vector2(6, 110), Vector2(220, 108))
	_text(q, Vector2(10, 8), "Quest", 13, Color(0.96, 0.9, 0.7))
	_text(q, Vector2(198, 6), "✕", 13, Color(0.7, 0.7, 0.75))
	_tex(q, Vector2(10, 32), Vector2(16, 16), ICON + "nav-campaign.png")
	_text(q, Vector2(30, 30), "Truy tìm Huyết Kiếm", 11, Color(0.95, 0.8, 0.4))
	_text(q, Vector2(30, 46), "Đánh bại Huyết Kiếm — Rừng Âm U", 9, Color(0.8, 0.8, 0.85))
	_text(q, Vector2(184, 46), "0/1", 10, Color(0.7, 0.85, 0.7))
	_tex(q, Vector2(10, 70), Vector2(16, 16), ICON + "nav-build.png")
	_text(q, Vector2(30, 68), "Nâng cấp Nhà Trọ", 11, Color(0.95, 0.8, 0.4))
	_text(q, Vector2(30, 84), "Nâng Nhà Trọ lên Lv.3", 9, Color(0.8, 0.8, 0.85))
	_text(q, Vector2(184, 84), "2/3", 10, Color(0.7, 0.85, 0.7))

	var auto := _panel(Vector2(6, 226), Vector2(60, 54))
	_tex(auto, Vector2(8, 6), Vector2(24, 24), ICON + "nav-battle.png")
	_text(auto, Vector2(10, 34), "Auto ON", 9, Color(0.7, 0.95, 0.6))

# --- RIGHT: Minimap + Event + x2 EXP ---------------------------------------
func _build_right() -> void:
	# Minimap
	var mm := _panel(Vector2(360, 110), Vector2(174, 150))
	_text(mm, Vector2(8, 6), "Bài Săn Mở 1", 12, Color(0.96, 0.9, 0.7))
	_text(mm, Vector2(154, 4), "✕", 12, Color(0.7, 0.7, 0.75))
	_minimap = MiniMap.new()
	_minimap.position = Vector2(8, 28)
	_minimap.size = Vector2(158, 86)
	_minimap.custom_minimum_size = Vector2(158, 86)
	_minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mm.add_child(_minimap)
	_text(mm, Vector2(52, 120), "Thế Giới 1", 12, Color(0.9, 0.85, 0.7))
	_mini_btn(Vector2(500, 224), "+")

	# Event panel
	var ev := _panel(Vector2(360, 266), Vector2(174, 176))
	_text(ev, Vector2(8, 6), "Event", 13, Color(0.96, 0.9, 0.7))
	var rows := [
		["Boss Thế Giới", 930], ["Săn Báu Vật", 1530], ["Quái Tinh Anh", 510], ["Đoàn Lữ Hành", 2130],
	]
	var icons := [ICON + "nav-battle.png", ICON + "res-gold.png", ICON + "nav-hero.png", ICON + "nav-team.png"]
	for i in rows.size():
		var y := 30.0 + i * 36.0
		_tex(ev, Vector2(8, y), Vector2(24, 24), icons[i])
		_text(ev, Vector2(36, y + 2), rows[i][0], 11, Color(0.92, 0.88, 0.8))
		var tl := _text(ev, Vector2(36, y + 16), _hms(rows[i][1]), 10, Color(0.55, 0.9, 0.55))
		_event_timers.append({"label": tl, "remain": rows[i][1]})

	# x2 EXP banner
	var xp := _panel(Vector2(360, 450), Vector2(174, 40))
	_tex(xp, Vector2(6, 6), Vector2(28, 28), "res://assets/ui/icons/item_icons/icon-04.png")
	_text(xp, Vector2(40, 6), "Đang diễn ra x2 EXP", 10, Color(0.95, 0.85, 0.5))
	_text(xp, Vector2(40, 20), "00:25:30", 10, Color(0.55, 0.9, 0.55))

# --- BOTTOM: chat log + skill bar + party bar + nav ------------------------
func _build_bottom() -> void:
	# System chat log
	var chat := _panel(Vector2(6, 796), Vector2(306, 96))
	_chat_log = _text(chat, Vector2(10, 6), "", 10, Color(0.82, 0.86, 0.8))
	var inp := _panel(Vector2(6, 894), Vector2(252, 24))
	_text(inp, Vector2(8, 4), "Nhập để chat...", 10, Color(0.6, 0.62, 0.66))
	_mini_btn(Vector2(262, 894), "+")
	_log("Bạn đã vào Bài Săn Mở 1")

	# Skill bar (3 skill + locked + Auto)
	var skills := ["icon-01", "icon-02", "icon-03"]
	for i in skills.size():
		var b := _panel(Vector2(320.0 + i * 44.0, 846), Vector2(40, 40))
		_tex(b, Vector2(2, 2), Vector2(36, 36), "res://assets/ui/icons/skills/%s.png" % skills[i])
	var lock := _panel(Vector2(452, 846), Vector2(40, 40))
	_text(lock, Vector2(4, 14), "Lv.25", 9, Color(0.6, 0.6, 0.65))
	var autob := _panel(Vector2(496, 846), Vector2(40, 40))
	_tex(autob, Vector2(2, 2), Vector2(36, 36), ICON + "nav-battle.png")

	# Hero party bar (6 card)
	var party_bg := _panel(Vector2(6, 900), Vector2(528, 62))
	for i in 6:
		var cx := 4.0 + i * 87.0
		var root := Panel.new()
		root.position = Vector2(cx, 3); root.size = Vector2(84, 56)
		party_bg.add_child(root)
		_tex(root, Vector2(3, 3), Vector2(28, 28), ICON + "nav-hero.png")
		var nm := _text(root, Vector2(33, 3), "-", 9, Color(0.95, 0.9, 0.78))
		var lv := _text(root, Vector2(33, 16), "", 9, Color(0.72, 0.8, 0.92))
		var hp := _hpbar(root, Vector2(4, 40), Vector2(76, 10))
		var hplbl := _text(root, Vector2(8, 39), "", 8, Color(1, 1, 1))
		_party.append({"root": root, "name": nm, "lv": lv, "hp": hp, "hplbl": hplbl})

	_toast = _text(self, Vector2(12, 770), "", 12, Color(0.75, 0.95, 0.7))

	# Nav bar (7 icon + label)
	var navbar := _panel(Vector2(0, VH - 116), Vector2(VW, 116))
	var items := [
		["nav-team", "Thành Chính", Callable(self, "_go_town")],
		["nav-hero", "Hero", Callable(self, "_show_hero")],
		["nav-quest", "Nhiệm Vụ", Callable(self, "_show_season")],
		["nav-battle", "Bãi Săn", Callable(self, "_go_hunt")],
		["nav-world", "Đấu Trường", Callable(self, "_show_battle")],
		["nav-summon", "Sự Kiện", Callable(self, "_show_summon")],
		["nav-build", "Cửa Hàng", Callable(self, "_show_build")],
	]
	for i in items.size():
		var vb := VBoxContainer.new()
		vb.position = Vector2(4 + i * 76, 6)
		vb.custom_minimum_size = Vector2(72, 0)
		vb.add_theme_constant_override("separation", 1)
		navbar.add_child(vb)
		var b := Button.new()
		b.tooltip_text = items[i][1]
		var tex: Texture2D = load(ICON + items[i][0] + ".png")
		if tex != null:
			b.icon = tex
		b.custom_minimum_size = Vector2(72, 58)
		b.pressed.connect(items[i][2])
		vb.add_child(b)
		var lbl := Label.new()
		lbl.text = items[i][1]
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.clip_text = true
		lbl.custom_minimum_size = Vector2(72, 14)
		vb.add_child(lbl)

# nav callbacks (tránh bind lambda phức tạp)
func _go_town() -> void:
	_show(null)
	if _world != null and _world.has_method("go_town_view"):
		_world.go_town_view()

func _go_hunt() -> void:
	_show(null)
	if _world != null and _world.has_method("go_hunt_view"):
		_world.go_hunt_view()

func _show_hero() -> void: _show(_hero_panel)
func _show_battle() -> void: _show(_battle_panel)
func _show_summon() -> void: _show(_summon_panel)
func _show_build() -> void: _show(_build_panel)
func _show_season() -> void: _show(_season_panel)
func _show_world() -> void: _show(_world_panel)

# --- popup panels (mở khi bấm nav) -----------------------------------------
func _build_popups() -> void:
	_panel_bg = Panel.new()
	_panel_bg.position = Vector2(40, 108)
	_panel_bg.size = Vector2(460, 660)
	_panel_bg.visible = false
	add_child(_panel_bg)
	_world_panel = WorldPanel.new()
	_build_panel = BuildPanel.new()
	_summon_panel = SummonPanel.new()
	_hero_panel = HeroDetailPanel.new()
	_battle_panel = BattlePanel.new()
	_season_panel = SeasonPanel.new()
	for p in [_world_panel, _build_panel, _summon_panel, _hero_panel, _battle_panel, _season_panel]:
		p.position = Vector2(52, 120)
		p.visible = false
		add_child(p)

func _show(panel) -> void:
	for p in [_world_panel, _build_panel, _summon_panel, _hero_panel, _battle_panel, _season_panel]:
		p.visible = (p == panel)
	_panel_bg.visible = panel != null
	if panel != null and panel.has_method("refresh"):
		panel.refresh()

# --- widget helpers --------------------------------------------------------
func _panel(pos: Vector2, size: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	add_child(p)
	return p

func _text(parent: Node, pos: Vector2, txt: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if parent == null:
		add_child(l)
	else:
		parent.add_child(l)
	return l

func _tex(parent: Node, pos: Vector2, size: Vector2, path: String) -> TextureRect:
	var tr := TextureRect.new()
	tr.position = pos
	tr.size = size
	tr.custom_minimum_size = size
	tr.texture = load(path)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr)
	return tr

func _icon_btn(pos: Vector2, size: Vector2, icon_path: String, tip: String, cb: Callable) -> Button:
	var b := Button.new()
	b.position = pos
	b.custom_minimum_size = size
	b.size = size
	b.tooltip_text = tip
	var tex: Texture2D = load(icon_path)
	if tex != null:
		b.icon = tex
	b.pressed.connect(cb)
	add_child(b)
	return b

func _mini_btn(pos: Vector2, txt: String) -> Button:
	var b := Button.new()
	b.position = pos
	b.custom_minimum_size = Vector2(24, 24)
	b.text = txt
	add_child(b)
	return b

func _hpbar(parent: Node, pos: Vector2, size: Vector2) -> ProgressBar:
	var pb := ProgressBar.new()
	pb.position = pos
	pb.custom_minimum_size = size
	pb.size = size
	pb.show_percentage = false
	pb.max_value = 100
	pb.value = 100
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.78, 0.2, 0.2)
	fill.set_corner_radius_all(2)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.1, 0.1)
	bg.set_corner_radius_all(2)
	pb.add_theme_stylebox_override("fill", fill)
	pb.add_theme_stylebox_override("background", bg)
	pb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(pb)
	return pb
