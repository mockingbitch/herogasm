class_name BattlePanel
extends Control
## Panel Trận Đấu (P4): World Boss (khởi động/tấn công/nhận thưởng + BXH đóng góp), Stage 3/3,
## Đấu Trường Bot (tìm đối thủ/đánh/MMR/Honor/xem lại). UI chỉ đọc + điều khiển service.

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
	_world_boss_section()
	_stage_section()
	_arena_section()
	_msg = _label("", Color(0.6, 0.9, 0.6), 10)

# --- World Boss ------------------------------------------------------------
func _world_boss_section() -> void:
	_header("— WORLD BOSS —", Color(0.95, 0.6, 0.5))
	var did := WorldBossService.boss_of_day()
	var bdef: BossDef = Database.get_boss_def(did)
	_label("  Hôm nay: %s" % (bdef.display_name if bdef else "?"), Color(0.85, 0.8, 0.7), 10)
	if WorldBossService.current != null:
		var st := WorldBossService.current
		_label("  HP %.0f%% · trạng thái %d · phase %d" % [st.hp_pct() * 100.0, st.event_state, st.current_phase_idx],
			Color(0.9, 0.75, 0.7), 10)
		var board := WorldBossService.contribution_board()
		for i in mini(3, board.size()):
			var r: Dictionary = board[i]
			_label("   %d. %s  dmg %d" % [i + 1, str(r["hero_id"]), int(r["damage"])], Color(0.8, 0.8, 0.75), 9)
	var row := HBoxContainer.new()
	_btn(row, "Khởi động", func(): _do(func(): return "boss=%s" % str(WorldBossService.start_event())))
	_btn(row, "Tấn công", func(): _do(func():
		var s: Dictionary = WorldBossService.engage()
		return "HP %.0f%% %s" % [float(s.get("boss_hp_pct", 1.0)) * 100.0, "HẠ GỤC!" if bool(s.get("defeated", false)) else ""]))
	_btn(row, "Nhận thưởng", func(): _do(func():
		var s: Dictionary = WorldBossService.claim_rewards()
		return "thưởng: %s" % ("+%d vàng" % int(s.get("total_gold", 0)) if bool(s.get("ok", false)) else str(s.get("reason", "?")))))
	_box.add_child(row)

# --- Stage 3/3 -------------------------------------------------------------
func _stage_section() -> void:
	_header("— ẢI (STAGE) —", Color(0.6, 0.85, 0.95))
	for sid in Database.stage_ids():
		var sd: StageDef = Database.get_stage_def(sid)
		var stars := PlayerProfile.stage_star(str(sid))
		var star_txt := "★".repeat(stars) + "☆".repeat(maxi(0, 3 - stars))
		var row := HBoxContainer.new()
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 10)
		l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
		l.text = "  %s %s" % [sd.display_name, star_txt]
		row.add_child(l)
		_btn(row, "Đánh", func(): _do(func():
			var s: Dictionary = StageBattleService.run(str(sid))
			return "%s %d★%s" % ["Thắng" if bool(s.get("won", false)) else "Thua", int(s.get("stars", 0)),
				" (first-clear!)" if bool(s.get("first_clear", false)) else ""]))
		_box.add_child(row)

# --- Arena -----------------------------------------------------------------
func _arena_section() -> void:
	_header("— ĐẤU TRƯỜNG —", Color(0.85, 0.7, 0.95))
	_label("  MMR %d · Honor %d · lượt %d/%d" % [ArenaService.mmr, PlayerProfile.honor(),
		ArenaService.quota_used, ArenaService.QUOTA_PER_DAY], Color(0.85, 0.8, 0.9), 10)
	for opp in ArenaService.find_opponents(3):
		var row := HBoxContainer.new()
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 10)
		l.add_theme_color_override("font_color", Color(0.82, 0.8, 0.85))
		var wc := MmrService.predict_win_chance(ArenaService.mmr, int(opp.get("mmr", 1000)))
		l.text = "  %s (MMR%d, thắng~%d%%)" % [str(opp.get("owner_profile_id", "?")), int(opp.get("mmr", 0)), int(wc * 100.0)]
		row.add_child(l)
		_btn(row, "Đấu", func(): _do(func(): return _fight(opp)))
		_box.add_child(row)
	if ArenaService.last_result != null:
		var row2 := HBoxContainer.new()
		_btn(row2, "Xem lại trận cuối", func(): _do(func():
			var res: SimResult = ArenaService.watch(str(ArenaService.last_result.replay_id))
			return "Replay: %s" % ("THẮNG" if res != null and res.winner == 0 else "THUA")))
		_box.add_child(row2)

func _fight(opp: Dictionary) -> String:
	var out: Dictionary = ArenaService.fight(opp)
	if not bool(out.get("ok", false)):
		return "không đấu được: %s" % str(out.get("reason", "?"))
	var res: ArenaMatchResult = out["result"]
	return "%s  MMR%+d  +%d honor" % [_outcome_text(res.outcome), res.mmr_delta, res.honor_gained]

func _outcome_text(o: int) -> String:
	match o:
		Enums.ArenaOutcome.WIN: return "THẮNG"
		Enums.ArenaOutcome.TIMEOUT_WIN: return "THẮNG (hết giờ)"
		Enums.ArenaOutcome.TIMEOUT_LOSE: return "THUA (hết giờ)"
		_: return "THUA"

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
