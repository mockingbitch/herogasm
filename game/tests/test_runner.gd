extends Node
## Test harness tối giản (không phụ thuộc addon GUT — chạy được headless mọi lúc).
## Chạy: godot --headless --path game res://tests/test_runner.tscn
## Mỗi test file có `static func run(t) -> void:` dùng t.eq/t.truthy/t.approx.
## Exit code 0 = tất cả pass, 1 = có fail (dùng cho CI / cổng Run & Test).

const SUITES := [
	preload("res://tests/unit/test_damage_formula.gd"),
	preload("res://tests/unit/test_battle_engine.gd"),
	preload("res://tests/unit/test_hero_instance.gd"),
	preload("res://tests/unit/test_goal_scoring.gd"),
	preload("res://tests/unit/test_save_roundtrip.gd"),
	preload("res://tests/unit/test_migration_v1.gd"),
	preload("res://tests/unit/test_offline.gd"),
	preload("res://tests/unit/test_bootstrap.gd"),
	# --- Phase 2 ---
	preload("res://tests/unit/test_hero_condition.gd"),
	preload("res://tests/unit/test_migration_v2.gd"),
	preload("res://tests/unit/test_goal_scoring_p2.gd"),
	preload("res://tests/unit/test_economy_curve.gd"),
	preload("res://tests/unit/test_world_gate.gd"),
	preload("res://tests/unit/test_expedition.gd"),
	# --- Phase 3 (build depth) ---
	preload("res://tests/unit/test_stat_aggregator.gd"),
	preload("res://tests/unit/test_equipment.gd"),
	preload("res://tests/unit/test_rune.gd"),
	preload("res://tests/unit/test_synergy.gd"),
	preload("res://tests/unit/test_build_save.gd"),
	# --- P3-cont (gacha/progression) ---
	preload("res://tests/unit/test_summon_service.gd"),
	preload("res://tests/unit/test_talent_respec.gd"),
	preload("res://tests/unit/test_migration_v4.gd"),
	preload("res://tests/simulation/test_ai_simulation.gd"),
	# --- Phase 4 (boss · stage · arena) ---
	preload("res://tests/unit/test_battle_sim.gd"),
	preload("res://tests/unit/test_boss.gd"),
	preload("res://tests/unit/test_formation.gd"),
	preload("res://tests/unit/test_arena.gd"),
	preload("res://tests/unit/test_stage.gd"),
	preload("res://tests/unit/test_replay_regression.gd"),
	preload("res://tests/simulation/test_boss_arena_simulation.gd"),
	# --- Phase 5 (story · season · event) ---
	preload("res://tests/unit/test_story.gd"),
	preload("res://tests/unit/test_event.gd"),
	preload("res://tests/unit/test_season.gd"),
	preload("res://tests/unit/test_migration_v6.gd"),
	preload("res://tests/simulation/test_season_simulation.gd"),
]

var _pass: int = 0
var _fail: int = 0
var _current: String = ""

func _ready() -> void:
	print("=== Herogasm test suite (P0) ===")
	for suite in SUITES:
		_current = suite.resource_path.get_file()
		var ok_before := _fail
		suite.run(self)
		var suite_fail := _fail - ok_before
		print("  %s %s" % ["FAIL" if suite_fail > 0 else "ok  ", _current])
	print("=== %d passed, %d failed ===" % [_pass, _fail])
	get_tree().quit(1 if _fail > 0 else 0)

# --- assert helpers -------------------------------------------------------
func eq(actual, expected, name: String) -> void:
	if _deep_eq(actual, expected):
		_ok(name)
	else:
		_bad(name, "expected %s, got %s" % [str(expected), str(actual)])

func truthy(cond: bool, name: String) -> void:
	if cond:
		_ok(name)
	else:
		_bad(name, "expected true")

func approx(actual: float, expected: float, name: String, eps: float = 0.001) -> void:
	if absf(actual - expected) <= eps:
		_ok(name)
	else:
		_bad(name, "expected ~%s, got %s" % [str(expected), str(actual)])

func _ok(name: String) -> void:
	_pass += 1

func _bad(name: String, detail: String) -> void:
	_fail += 1
	printerr("    ✗ [%s] %s — %s" % [_current, name, detail])

func _deep_eq(a, b) -> bool:
	if typeof(a) != typeof(b):
		# cho phép so sánh int/float tương đương
		if (a is int or a is float) and (b is int or b is float):
			return absf(float(a) - float(b)) < 0.0001
		return false
	if a is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not _deep_eq(a[i], b[i]):
				return false
		return true
	if a is Dictionary:
		if a.size() != b.size():
			return false
		for k in a.keys():
			if not b.has(k) or not _deep_eq(a[k], b[k]):
				return false
		return true
	return a == b
