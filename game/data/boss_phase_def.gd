class_name BossPhaseDef
extends Resource
## 1 phase của boss (data-driven). Trigger theo HP%/thời gian/số minion/break đầy.
## Vào phase: áp stat_mult, bật hazard, đổi pool skill (đè phase trước), có thể summon.

@export var id: StringName = &""
@export var trigger_type: int = Enums.BossTrigger.HP_PCT
@export var trigger_value: float = 0.75          # HP_PCT: HP<=75% ; TIME: giây ; MINION: số ; BREAK: 1
@export var skill_ids: Array[StringName] = []     # pool skill phase này (id SkillDef trong Database)
@export var stat_mult: Dictionary = {}            # {"attack":1.2,"attack_interval":0.9} nhân so base
@export var summon_group_id: StringName = &""     # "" = không summon khi vào phase
@export var arena_hazard_id: StringName = &""     # hazard bật (lava/poison...) — SIM: dmg/tick lên phe hero
@export var hazard_dps: float = 0.0               # sát thương hazard mỗi giây lên toàn phe hero
@export var loot_bonus_pct: float = 0.0
