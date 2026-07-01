class_name ZoneDef
extends Resource
## Bãi Săn (data-driven, HỢP NHẤT gating + expedition). Hai loại sao TÁCH BIỆT:
##  - star_thresholds (clear-count): dùng để GATE mở zone kế + hiển thị tiến trình.
##  - star_hp_thresholds (HP% còn lại): dùng cho chất lượng 1 lượt expedition.
## Content code-built trong Database (như building_defs). Reuse EnemyData id P1.

@export var id: String = ""
@export var region_id: String = ""
@export var display_name: String = ""

# --- gating (worldmap) ---
@export var required_level: int = 1           # roster_max_level >= mức này
@export var unlock_by_stars: int = 0          # cần >= sao ở prereq_zone_id (0 = bỏ qua)
@export var prereq_zone_id: String = ""
@export var recommended_power: int = 10       # AI chọn zone theo power
@export var star_thresholds: Array[int] = [1, 3, 6]   # clear-count -> 1/2/3 sao (gating)

# --- combat/expedition ---
@export var monster_pool: Array[String] = [] # id EnemyData P1
@export var enemy_count: int = 2
@export var duration_sec: float = 300.0       # thời lượng 1 expedition idle
@export var energy_cost: int = 20
@export var reward_gold_min: int = 10
@export var reward_gold_max: int = 30
@export var reward_xp: int = 10
@export var reward_drops: Array = []          # [{id, chance}] như EnemyData.drops
@export var star_hp_thresholds: Array = [0.0, 0.4, 0.75]  # HP% còn lại -> sao lượt chạy

## Sao GATING theo số lần clear (đếm ngưỡng vượt, trần 3).
func star_for(clears: int) -> int:
	var s := 0
	for i in star_thresholds.size():
		if clears >= int(star_thresholds[i]):
			s = i + 1
	return mini(s, 3)

## Sao CHẤT LƯỢNG lượt chạy theo HP% còn lại.
func run_stars(hp_pct: float) -> int:
	var s := 0
	for i in star_hp_thresholds.size():
		if hp_pct >= float(star_hp_thresholds[i]):
			s = i + 1
	return mini(s, 3)
