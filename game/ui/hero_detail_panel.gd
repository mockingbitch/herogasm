class_name HeroDetailPanel
extends Control
## Panel Anh Hùng: duyệt roster, xem FinalStats breakdown + shards/awaken + nút Awaken/Respec.

var _box: VBoxContainer
var _idx: int = 0

func _ready() -> void:
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 2)
	add_child(_box)
	refresh()

func refresh() -> void:
	if _box == null:
		return
	for c in _box.get_children():
		c.queue_free()
	if PlayerProfile.hero_ids.is_empty():
		_line("(chưa có hero)", Color(0.6, 0.6, 0.6))
		return
	_idx = clampi(_idx, 0, PlayerProfile.hero_ids.size() - 1)
	var hid: String = PlayerProfile.hero_ids[_idx]
	var h: HeroInstance = PlayerProfile.get_hero(hid)
	if h == null:
		return

	var nav := HBoxContainer.new()
	_nav_btn(nav, "◀", -1)
	var name_lbl := Label.new()
	name_lbl.text = "  %s Lv.%d [%s/%s]  " % [h.display_name, h.level, h.class_role, h.race]
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.5))
	nav.add_child(name_lbl)
	_nav_btn(nav, "▶", 1)
	_box.add_child(nav)

	var fs := h.get_final_stats(PlayerProfile.team_context())
	_line("ATK %d · DEF %d · HP %d" % [int(fs.get_v("bonus_attack")), int(fs.get_v("bonus_defense")), int(fs.get_v("bonus_max_hp"))], Color(0.85, 0.85, 0.8))
	_line("Crit %d%% · CritDmg %d%% · Tốc %d" % [int(fs.get_v("crit_chance") * 100), int(fs.get_v("crit_damage") * 100), int(fs.get_v("bonus_speed"))], Color(0.8, 0.8, 0.75))
	_line("Shards: %d · Awaken rank: %d" % [h.shards, int(h.awaken_state.get("rank", 0))], Color(0.7, 0.8, 0.9))
	# breakdown nguồn (base/equip/talent/rune/synergy...)
	_line("— nguồn —", Color(0.6, 0.6, 0.55))
	for layer in fs.sources:
		var atk: float = float(fs.sources[layer].get("bonus_attack", 0.0))
		if atk != 0.0:
			_line("  %s: ATK %+d" % [layer, int(atk)], Color(0.6, 0.7, 0.6))

	var act := HBoxContainer.new()
	var awk := Button.new()
	awk.text = "Awaken"
	awk.pressed.connect(func(): PlayerProfile.awaken_hero(hid); refresh())
	act.add_child(awk)
	var rsp := Button.new()
	rsp.text = "Respec talent"
	rsp.pressed.connect(func(): PlayerProfile.respec_hero_talents(hid); refresh())
	act.add_child(rsp)
	_box.add_child(act)

func _nav_btn(parent: Node, text: String, delta: int) -> void:
	var b := Button.new()
	b.text = text
	b.pressed.connect(func(): _idx = wrapi(_idx + delta, 0, PlayerProfile.hero_ids.size()); refresh())
	parent.add_child(b)

func _line(text: String, col: Color) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_color", col)
	_box.add_child(l)
