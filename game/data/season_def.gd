class_name SeasonDef
extends Resource
## 1 Season = 1 biến dị Abyss (trọng tâm P5): story arc + seasonal boss + event(s) + meta rotation
## (buff rune/equip/synergy, KHÔNG buff hero base — chống power-creep) + battle pass + currency/shop
## + world evolution + rank reset. Data-driven qua Database.

@export var id: StringName = &""
@export var display_name: String = ""
@export var number: int = 1
@export var abyss_mutation_id: StringName = &""
@export var duration_days: int = 56                 # 8 tuần (EVENTS.md)
@export var story_arc_chapter_ids: Array[StringName] = []
@export var seasonal_boss_id: StringName = &""
@export var event_ids: Array[StringName] = []
@export var meta_rotation: Dictionary = {}          # {rune_buffs:[], equip_buffs:[], synergy_buffs:[]}
@export var battle_pass_id: StringName = &""
@export var seasonal_currency_id: StringName = &""
@export var seasonal_shop_id: StringName = &""
@export var world_evolution_rules: Array = []       # [{trigger, condition, world_state_key, value}]
@export var rank_reset_policy: Dictionary = {"reset_rank": true, "reset_leaderboard": true,
	"keep": ["hero", "equip", "rune", "story"]}
@export var visual_theme_id: StringName = &""
@export var next_season_id: StringName = &""
