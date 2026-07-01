class_name EventDef
extends Resource
## Định nghĩa 1 event (schema theo build-events "EventData" — KHÔNG chứa runtime state).
## Modifier tạm & reversible; reward không gold-only; có thể gắn story dialogue (limited story event).

@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var category: StringName = &"Festival"      # Season/Festival/WorldBoss/Economy/Combat
@export var priority: int = 2                        # 0 Critical .. 4 Ambient (build-events Priority)
@export var duration_sec: float = 1800.0
@export var preparation_sec: float = 0.0
@export var cooldown_sec: float = 0.0
@export var conditions: Array = []                   # [{type,value}] time/season/boss_defeated/monster_kill_count/random_weight/manual_debug
@export var modifiers: Array = []                    # [{target,value}] loot_rate/gold_rate/exp_rate/monster_spawn_rate/mood_bonus/move_speed
@export var rewards: Array = []                      # [{type,id,amount}] (không gold-only)
@export var currency_id: StringName = &""            # event currency tạm (có thể trống)
@export var story_dialogue_id: StringName = &""
@export var visual_theme_id: StringName = &""
@export var music_id: StringName = &""
@export var notification_text: String = ""
@export var chain_next_id: StringName = &""          # chain event kế (data-driven)

const PRIORITY_CRITICAL := 0
const PRIORITY_MAJOR := 1
const PRIORITY_MEDIUM := 2
const PRIORITY_MINOR := 3
const PRIORITY_AMBIENT := 4

func is_major() -> bool:
	return priority <= PRIORITY_MAJOR

func is_medium() -> bool:
	return priority == PRIORITY_MEDIUM
