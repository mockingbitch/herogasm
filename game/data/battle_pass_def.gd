class_name BattlePassDef
extends Resource
## Battle Pass 1 season: track Free/Premium, cosmetic-first (KHÔNG power — ECONOMY.md).
## reward: {level, type, id, amount}. XP pass đến từ mission event/story (không mua power).

@export var id: StringName = &""
@export var season_id: StringName = &""
@export var max_level: int = 50
@export var xp_per_level: int = 100
@export var free_rewards: Array = []                 # [{level,type,id,amount}]
@export var premium_rewards: Array = []              # cosmetic-first, KHÔNG power

## Reward ở 1 bậc cho track (free/premium). Trả Array các reward tại level đó.
func rewards_at(level: int, premium: bool) -> Array:
	var src: Array = premium_rewards if premium else free_rewards
	var out: Array = []
	for r in src:
		if int(r.get("level", 0)) == level:
			out.append(r)
	return out
