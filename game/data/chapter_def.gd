class_name ChapterDef
extends Resource
## 1 chapter campaign (data-driven). Trỏ stage/boss của P4 + dialogue + unlock reward + feature gate.
## Story là HỆ THỐNG điều phối (CLAUDE.md), không phải nội dung trang trí.

@export var id: StringName = &""
@export var display_name: String = ""
@export var order_index: int = 0
@export var arc: StringName = &"chapter"           # prologue/chapter/world/abyss/final
@export var stage_ids: Array[StringName] = []       # StageDef (P4)
@export var boss_ids: Array[StringName] = []        # BossDef (P4)
@export var intro_dialogue_id: StringName = &""
@export var boss_intro_id: StringName = &""
@export var unlock_rewards: Array = []              # [{type,id,amount}] hero/rune/dungeon/system
@export var unlock_gate: StringName = &""           # feature key mở khi hoàn thành (vd &"rune_system")
@export var region_id: StringName = &""
@export var prerequisite_id: StringName = &""       # chapter phải xong trước
