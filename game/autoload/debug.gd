extends Node
## Debug console stub (P0) theo debug-tools.md: registry lệnh + gate theo build.
## Cheat CHỈ bật ở build debug (release không có). Thay print bằng Debug.log/warning/error.

var enabled: bool = OS.is_debug_build()
var _commands: Dictionary = {}                     # name -> {callable, help}

func _ready() -> void:
	_register_defaults()
	_register_p4()
	_register_p5()

func register_command(name: String, callable: Callable, help: String = "") -> void:
	_commands[name] = {"callable": callable, "help": help}

## Thực thi 1 dòng lệnh "name arg1 arg2". Trả chuỗi kết quả.
func execute(line: String) -> String:
	line = line.strip_edges()
	if line == "":
		return ""
	if not enabled:
		return "Debug tắt (release build)."
	var parts := line.split(" ", false)
	var name := parts[0]
	var args: Array = Array(parts.slice(1))
	if not _commands.has(name):
		return "Lệnh không tồn tại: %s (gõ 'help')" % name
	return str((_commands[name]["callable"] as Callable).call(args))

func log(msg: Variant) -> void:
	if enabled:
		print("[LOG] ", msg)

func warning(msg: Variant) -> void:
	push_warning(str(msg))

func error(msg: Variant) -> void:
	push_error(str(msg))

# --- lệnh mặc định (method có tên, tránh lambda đa dòng) -------------------
func _register_defaults() -> void:
	register_command("help", _cmd_help, "liệt kê lệnh")
	register_command("save", _cmd_save, "lưu game")
	register_command("load", _cmd_load, "nạp lại save")
	register_command("wipe", _cmd_wipe, "xoá save + new game")
	register_command("add_gold", _cmd_add_gold, "+gold <n>")
	register_command("add_gems", _cmd_add_gems, "+gems <n>")
	register_command("show_save_info", _cmd_save_info, "thông tin save")

func _cmd_help(_a: Array) -> String:
	return ", ".join(PackedStringArray(_commands.keys()))

func _cmd_save(_a: Array) -> String:
	PlayerProfile.save()
	return "saved"

func _cmd_load(_a: Array) -> String:
	PlayerProfile.from_dict(SaveManager.load_game())
	PlayerProfile._emit_all()
	return "loaded"

func _cmd_wipe(_a: Array) -> String:
	PlayerProfile.reset_progress()
	return "wiped"

func _cmd_add_gold(a: Array) -> String:
	var n := int(a[0]) if a.size() > 0 else 100
	PlayerProfile.add_gold(n)
	return "gold=%d" % PlayerProfile.gold

func _cmd_add_gems(a: Array) -> String:
	var n := int(a[0]) if a.size() > 0 else 10
	PlayerProfile.add_gems(n)
	return "gems=%d" % PlayerProfile.gems

func _cmd_save_info(_a: Array) -> String:
	return str(SaveManager.save_info())

# --- P4: boss / stage / arena (debug-tools.md) ----------------------------
func _register_p4() -> void:
	register_command("start_world_boss", _cmd_start_wb, "bắt đầu world boss [def_id]")
	register_command("engage_boss", _cmd_engage, "đánh 1 lượt world boss [seed]")
	register_command("set_boss_hp", _cmd_set_boss_hp, "đặt HP boss theo % [0..1]")
	register_command("show_contribution", _cmd_show_contrib, "bảng đóng góp boss")
	register_command("claim_rewards", _cmd_claim, "chia thưởng boss (1 lần)")
	register_command("end_world_boss", _cmd_end_wb, "kết thúc sự kiện boss (FAILED)")
	register_command("reset_boss_event", _cmd_reset_wb, "xoá sự kiện boss")
	register_command("run_stage", _cmd_run_stage, "chạy stage <id> [formation]")
	register_command("set_stars", _cmd_set_stars, "đặt sao stage <id> <n>")
	register_command("arena_opponents", _cmd_arena_opp, "liệt kê đối thủ arena")
	register_command("arena_fight", _cmd_arena_fight, "đấu đối thủ gần nhất")
	register_command("set_mmr", _cmd_set_mmr, "đặt MMR <v>")
	register_command("grant_honor", _cmd_grant_honor, "+honor <n>")
	register_command("replay_last", _cmd_replay_last, "phát lại trận arena gần nhất")

func _cmd_start_wb(a: Array) -> String:
	var ok := WorldBossService.start_event(str(a[0]) if a.size() > 0 else "")
	return "world_boss=%s" % (str(WorldBossService.active_def().id) if ok else "fail")

func _cmd_engage(a: Array) -> String:
	var seed_val := int(a[0]) if a.size() > 0 else -1
	return str(WorldBossService.engage(seed_val))

func _cmd_set_boss_hp(a: Array) -> String:
	if WorldBossService.current == null:
		return "no_boss"
	var pct := clampf(float(a[0]) if a.size() > 0 else 1.0, 0.0, 1.0)
	WorldBossService.current.current_hp = WorldBossService.current.max_hp * pct
	return "boss_hp=%.0f" % WorldBossService.current.current_hp

func _cmd_show_contrib(_a: Array) -> String:
	return str(WorldBossService.contribution_board())

func _cmd_claim(_a: Array) -> String:
	return str(WorldBossService.claim_rewards())

func _cmd_end_wb(_a: Array) -> String:
	WorldBossService.fail_event()
	return "ended"

func _cmd_reset_wb(_a: Array) -> String:
	WorldBossService.current = null
	return "reset"

func _cmd_run_stage(a: Array) -> String:
	if a.is_empty():
		return "cần <stage_id>"
	var form := str(a[1]) if a.size() > 1 else "balanced_3"
	return str(StageBattleService.run(str(a[0]), form))

func _cmd_set_stars(a: Array) -> String:
	if a.size() < 2:
		return "cần <stage_id> <n>"
	PlayerProfile.stage_stars[str(a[0])] = clampi(int(a[1]), 0, 3)
	return "stars=%d" % PlayerProfile.stage_star(str(a[0]))

func _cmd_arena_opp(_a: Array) -> String:
	var opps := ArenaService.find_opponents()
	var names: Array = []
	for o in opps:
		names.append("%s(mmr%d)" % [o.get("owner_profile_id", "?"), int(o.get("mmr", 0))])
	return "mmr=%d | %s" % [ArenaService.mmr, ", ".join(PackedStringArray(names))]

func _cmd_arena_fight(_a: Array) -> String:
	var opps := ArenaService.find_opponents()
	if opps.is_empty():
		return "no_opponent"
	var r: Dictionary = ArenaService.fight(opps[0])
	if not bool(r.get("ok", false)):
		return str(r.get("reason", "fail"))
	var res: ArenaMatchResult = r["result"]
	return "outcome=%d mmrΔ=%d honor=%d replay=%s" % [res.outcome, res.mmr_delta, res.honor_gained, str(res.replay_id)]

func _cmd_set_mmr(a: Array) -> String:
	ArenaService.mmr = maxi(0, int(a[0]) if a.size() > 0 else 1000)
	return "mmr=%d" % ArenaService.mmr

func _cmd_grant_honor(a: Array) -> String:
	PlayerProfile.add_currency("honor", int(a[0]) if a.size() > 0 else 100)
	return "honor=%d" % PlayerProfile.honor()

func _cmd_replay_last(_a: Array) -> String:
	if ArenaService.last_result == null:
		return "no_replay"
	var res: SimResult = ArenaService.watch(str(ArenaService.last_result.replay_id))
	return "replay winner=%d" % (res.winner if res != null else -1)

# --- P5: story / season / event (debug-tools.md) --------------------------
func _register_p5() -> void:
	register_command("start_event", _cmd_start_event, "bắt đầu event <id>")
	register_command("end_event", _cmd_end_event, "kết mọi event active")
	register_command("show_active_events", _cmd_show_events, "event đang active")
	register_command("claim_event_reward", _cmd_claim_event, "nhận thưởng event <id>")
	register_command("trigger_festival", _cmd_festival, "khởi động frost_festival")
	register_command("set_chapter", _cmd_set_chapter, "start chapter <id>")
	register_command("complete_current_chapter", _cmd_complete_chapter, "hoàn thành chapter hiện tại")
	register_command("unlock_feature", _cmd_unlock_feature, "mở feature <key>")
	register_command("start_season", _cmd_start_season, "bắt đầu season <id>")
	register_command("skip_season_days", _cmd_skip_days, "tua <n> ngày game")
	register_command("force_season_rollover", _cmd_rollover, "ép rollover season")
	register_command("set_world_state", _cmd_set_world_state, "<region> <key> <value>")
	register_command("add_seasonal_currency", _cmd_add_scurrency, "<currency> <n>")
	register_command("set_battlepass_level", _cmd_set_bp, "đặt level battle pass <n>")

func _cmd_start_event(a: Array) -> String:
	return str(EventManager.start_event(str(a[0]))) if a.size() > 0 else "cần <id>"

func _cmd_end_event(_a: Array) -> String:
	EventManager.end_all(); return "ended"

func _cmd_show_events(_a: Array) -> String:
	return str(EventManager.active_event_ids())

func _cmd_claim_event(a: Array) -> String:
	return str(EventManager.claim_reward(str(a[0]))) if a.size() > 0 else "cần <id>"

func _cmd_festival(_a: Array) -> String:
	return str(EventManager.start_event("frost_festival"))

func _cmd_set_chapter(a: Array) -> String:
	return "start=%s" % str(StoryManager.start_chapter(str(a[0]))) if a.size() > 0 else "cần <id>"

func _cmd_complete_chapter(_a: Array) -> String:
	var cd: ChapterDef = StoryManager.get_current_chapter()
	if cd == null:
		return "hết chapter"
	return "complete %s = %s" % [str(cd.id), str(StoryManager.complete_chapter(str(cd.id)))]

func _cmd_unlock_feature(a: Array) -> String:
	if a.is_empty():
		return "cần <key>"
	StoryManager.unlock_feature(str(a[0]))
	return "unlocked=%s" % str(a[0])

func _cmd_start_season(a: Array) -> String:
	var id := str(a[0]) if a.size() > 0 else "season_of_frost"
	return "season=%s" % str(SeasonManager.start_season(id))

func _cmd_skip_days(a: Array) -> String:
	var n := int(a[0]) if a.size() > 0 else 1
	TimeService.advance_game_time(float(n) * TimeService.SECONDS_PER_GAME_DAY)
	if SeasonManager.should_rollover():
		SeasonManager.rollover()
		return "skipped %d ngày -> rollover" % n
	return "skipped %d ngày (còn %d)" % [n, SeasonManager.time_remaining_days()]

func _cmd_rollover(_a: Array) -> String:
	SeasonManager.rollover(); return "rollover"

func _cmd_set_world_state(a: Array) -> String:
	if a.size() < 3:
		return "cần <region> <key> <value>"
	WorldEvolutionService.set_state(str(a[0]), str(a[1]), str(a[2]))
	return "%s.%s=%s" % [a[0], a[1], a[2]]

func _cmd_add_scurrency(a: Array) -> String:
	if a.size() < 2:
		return "cần <currency> <n>"
	PlayerProfile.add_currency(str(a[0]), int(a[1]))
	return "%s=%d" % [a[0], PlayerProfile.currency_amount(str(a[0]))]

func _cmd_set_bp(a: Array) -> String:
	var lvl := int(a[0]) if a.size() > 0 else 1
	PlayerProfile.battlepass["level"] = maxi(1, lvl)
	return "bp_level=%d" % int(PlayerProfile.battlepass.get("level", 1))
