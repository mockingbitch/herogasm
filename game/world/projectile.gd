class_name Projectile
extends Area2D
## Đạn của boss. Bắn trúng Hurtbox của player (layer 4). Gán velocity/damage trước add_child.

var velocity: Vector2 = Vector2.ZERO
var damage: int = 10
var life: float = 3.5
var color: Color = Color(1.0, 0.45, 0.2)

func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(4, true)  # player_hurt
	var vis := Polygon2D.new()
	vis.polygon = PackedVector2Array([Vector2(0, -3), Vector2(3, 0), Vector2(0, 3), Vector2(-3, 0)])
	vis.color = color
	add_child(vis)
	var col := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = 4.0
	col.shape = sh
	add_child(col)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()

func _on_area_entered(a: Area2D) -> void:
	if a is Hurtbox:
		(a as Hurtbox).receive(damage, self)
		queue_free()
