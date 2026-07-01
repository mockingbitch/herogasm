class_name AwakenDef
extends Resource
## Awaken 1 hero (HERO.md): đổi passive/ultimate + stat bonus NHỎ (không power-creep).

@export var hero_def_id: String = ""
@export var shard_cost: int = 40
@export var new_passive_id: String = ""
@export var upgraded_ultimate_id: String = ""
@export var stat_bonus: Dictionary = {}       # {stat: flat} — nhỏ
