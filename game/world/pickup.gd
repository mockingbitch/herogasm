class_name Pickup
extends Area2D
## Vật phẩm rơi ra đất: vàng hoặc item. Hút nhẹ về player, chạm thì nhận.
## Gán kind/item_id/amount TRƯỚC add_child.

enum Kind { GOLD, ITEM }

@export var kind: Kind = Kind.GOLD
@export var amount: int = 5
@export var item_id: String = ""
@export var magnet_range: float = 30.0
@export var magnet_speed: float = 120.0

var _player: Node2D

func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(2, true)  # phát hiện body player (layer 2)

	var color := Color(1.0, 0.85, 0.2)
	var vis := Polygon2D.new()
	if kind == Kind.GOLD:
		vis.polygon = PackedVector2Array([Vector2(0, -4), Vector2(4, 0), Vector2(0, 4), Vector2(-4, 0)])
	else:
		var data: ItemData = Database.get_item(item_id)
		if data != null:
			color = data.icon_color
		vis.polygon = PackedVector2Array([Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4)])
	vis.color = color
	add_child(vis)

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	col.shape = shape
	add_child(col)

	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		var arr := get_tree().get_nodes_in_group("player")
		_player = (arr[0] as Node2D) if arr.size() > 0 else null
		return
	var to_p: Vector2 = _player.global_position - global_position
	if to_p.length() <= magnet_range:
		global_position += to_p.normalized() * magnet_speed * delta

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if kind == Kind.GOLD:
		Profile.add_gold(amount)
	else:
		Profile.add_item(item_id)
	queue_free()
