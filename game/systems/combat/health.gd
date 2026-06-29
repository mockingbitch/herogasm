class_name Health
extends Node
## Component máu, gắn vào thực thể bằng code:
##   var h := Health.new(); h.max_hp = 30; add_child(h)
## Phase 3 có thể tách thành scene .tscn riêng để tái dùng trong editor.

signal damaged(amount: int, hp: int, max_hp: int)
signal healed(amount: int, hp: int, max_hp: int)
signal died

@export var max_hp: int = 100
var hp: int = 0

func _ready() -> void:
	hp = max_hp

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = maxi(hp - amount, 0)
	damaged.emit(amount, hp, max_hp)
	if hp == 0:
		died.emit()

func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	healed.emit(amount, hp, max_hp)

func is_alive() -> bool:
	return hp > 0
