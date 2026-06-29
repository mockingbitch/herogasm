class_name Hurtbox
extends Area2D
## Vùng NHẬN đòn. Gắn lên thực thể có máu. Khi bị Hitbox chạm -> phát signal `hurt`
## để chủ sở hữu xử lý (trừ giáp, máu, flash, knockback).
##
## Phân đội bằng collision layer: 4 = player_hurt, 5 = enemy_hurt.
## I-frame = set_invincible(true) (tắt monitorable -> Hitbox không thấy).

signal hurt(amount: int, source: Node)

func _ready() -> void:
	monitoring = false
	monitorable = true

## Gọi TRƯỚC add_child: đặt layer + hình va chạm.
func configure(layer_bit: int, shape: Shape2D) -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(layer_bit, true)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

func receive(amount: int, source: Node) -> void:
	if monitorable:
		hurt.emit(amount, source)

func set_invincible(on: bool) -> void:
	monitorable = not on
