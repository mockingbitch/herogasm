class_name BattleResult
extends RefCounted
## Kết quả 1 trận Battle Engine. TẤT ĐỊNH theo seed.
## timeline: Array[Dictionary] {t, type("hit"/"death"), src, tgt, value, crit} — cho BattleView replay.

var seed: int = 0
var winner: int = -1                 # 0 phe hero, 1 phe địch, -1 hoà/timeout chưa xử
var duration: float = 0.0
var timeline: Array = []
var survivors_hp: Dictionary = {}    # unit_id -> hp còn lại
var dead_enemy_ids: Array = []       # source_enemy_id của quái chết (loot)
var hero_hp_after: Dictionary = {}   # hero_id -> hp còn lại (áp vào HeroInstance)
var total_damage: int = 0

func hero_won() -> bool:
	return winner == 0
