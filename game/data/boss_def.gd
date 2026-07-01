class_name BossDef
extends Resource
## Định nghĩa boss đa phase (data-driven, code-built trong Database — có thể .tres sau).
## KHÔNG hardcode hành vi trong controller: phase/skill/weak-point/break/enrage đều từ data.
## Mỗi boss BẮT BUỘC ≥1 cơ chế độc quyền (weak-point/interrupt/break) — chống HP-sponge (BOSS.md).

@export var id: StringName = &""
@export var display_name: String = ""
@export var boss_type: int = Enums.BossType.REGION
@export var region_id: StringName = &""
@export var level: int = 1
@export var difficulty: int = Enums.Difficulty.NORMAL

# --- stats nền (khớp stat schema hero) ---
@export var max_hp: int = 5000
@export var attack: int = 40
@export var defense: int = 10
@export var resist: float = 0.0
@export var attack_interval: float = 1.2

# --- phase / cơ chế ---
@export var phase_ids: Array[StringName] = []     # id BossPhaseDef theo thứ tự (phase 0 = mặc định)
@export var enrage_timer_sec: float = 0.0          # 0 = không enrage
@export var weak_points: Array = []                # [{part_id, bonus_dmg_pct, on_break_effect}]
@export var break_max: float = 0.0                 # 0 = không có break gauge
@export var break_stun_sec: float = 4.0            # thời gian stun khi break đầy
@export var break_dmg_taken_mult: float = 1.5      # nhân damage nhận khi đang bị break-stun

# --- meta ---
@export var reward_table_id: StringName = &""
@export var respawn_time_sec: int = 3600
@export var music_id: StringName = &""
@export var sprite_set: StringName = &"big_demon"
@export var intro_text: String = ""

func has_weak_point(part_id: StringName) -> bool:
	for w in weak_points:
		if StringName(w.get("part_id", &"")) == part_id:
			return true
	return false

func weak_point_bonus(part_id: StringName) -> float:
	for w in weak_points:
		if StringName(w.get("part_id", &"")) == part_id:
			return float(w.get("bonus_dmg_pct", 0.0))
	return 0.0
