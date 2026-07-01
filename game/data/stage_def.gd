class_name StageDef
extends Resource
## Stage battle "3/3" trên world-map (data-driven). Đội hình cố định, kết quả TẤT ĐỊNH seeded.
## star_rules: điều kiện đạt sao (thắng dưới X giây, không hero bất tỉnh). Thưởng first-clear vs repeat.

@export var id: StringName = &""
@export var region_id: StringName = &""
@export var chapter_id: StringName = &""
@export var display_name: String = ""
@export var recommended_power: int = 50
@export var enemy_waves: Array = []                # [[enemy_id,...], ...] 1..N wave
@export var boss_def_id: StringName = &""          # "" nếu stage thường
@export var team_size: int = 3
# star_rules: [{stars:int, max_time_sec:float, no_ko:bool}] — đánh giá giảm dần
@export var star_rules: Array = [
	{"stars": 3, "max_time_sec": 40.0, "no_ko": true},
	{"stars": 2, "max_time_sec": 90.0, "no_ko": false},
	{"stars": 1, "max_time_sec": 999.0, "no_ko": false},
]
@export var first_clear_gold: int = 300
@export var first_clear_gems: int = 30
@export var repeat_gold: int = 60
@export var repeat_xp: int = 40

## Chấm sao theo (thắng, thời gian, có hero bất tỉnh không). 0 nếu thua.
func score_stars(won: bool, duration: float, any_ko: bool) -> int:
	if not won:
		return 0
	for rule in star_rules:
		var ok := duration <= float(rule.get("max_time_sec", 999.0))
		if bool(rule.get("no_ko", false)) and any_ko:
			ok = false
		if ok:
			return int(rule.get("stars", 1))
	return 1
