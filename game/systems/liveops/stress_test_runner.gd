class_name StressTestRunner
extends RefCounted
## Stress headless (stress-test.md): chạy BattleSim quy mô lớn (nhiều hero/monster) -> không crash,
## không leak, luôn ra winner. Target render 300 hero/1000 monster @60fps validate on-device qua
## BenchmarkWorld (không headless). Đây kiểm SIM chịu tải + tất định + bounded.

## Dựng đội combatant tổng hợp (headless, không HeroInstance) — nhanh + tất định.
static func _units(prefix: String, team: int, n: int, hp: int, atk: int) -> Array:
	var out: Array = []
	for i in n:
		var c := SimCombatant.new()
		c.id = "%s_%04d" % [prefix, i]
		c.team = team; c.max_hp = hp; c.hp = hp; c.attack = atk; c.defense = 5
		c.attack_interval = 1.0
		if team == 1: c.source_enemy_id = "slime"
		else: c.source_hero_id = c.id
		c.add_skill(SkillFactory.basic_attack(1.0))
		out.append(c)
	return out

## 1 trận stress. Trả {units, ticks, winner, alive_a, alive_b}.
static func run(n_a: int, n_b: int, seed_val: int, max_ticks: int = 300) -> Dictionary:
	var a := _units("h", 0, n_a, 300, 40)
	var b := _units("m", 1, n_b, 60, 6)
	var res := BattleSim.new().simulate(a, b, seed_val, max_ticks)
	return {"units": n_a + n_b, "ticks": res.duration_ticks, "winner": res.winner,
		"total_damage": res.total_damage}

## Level 1→4 (quy mô tăng dần). Trả report mỗi level. FAIL nếu winner không hợp lệ.
static func run_levels() -> Array:
	var levels := [[10, 30], [30, 80], [50, 150], [80, 240]]
	var report: Array = []
	for i in levels.size():
		var r := run(levels[i][0], levels[i][1], 100 + i)
		r["level"] = i + 1
		report.append(r)
	return report
