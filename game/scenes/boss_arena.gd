extends Node2D
## Đấu boss. Thắng (boss chết) hoặc thua (player chết) -> E về thị trấn.

const ARENA_SIZE := Vector2(520, 360)
const WALL_T := 8.0

var _run_over: bool = false

func _ready() -> void:
	Engine.time_scale = 1.0
	_build_walls()

	var player := Player.new()
	player.position = Vector2(ARENA_SIZE.x * 0.5, ARENA_SIZE.y - 60.0)
	add_child(player)

	var boss := Boss.new()
	boss.position = Vector2(ARENA_SIZE.x * 0.5, 70.0)
	add_child(boss)

	var hud := HUD.new()
	hud.player = player
	hud.enemies_total = 1
	add_child(hud)

	add_child(BossBar.new())

	EventBus.player_died.connect(_on_over)
	EventBus.boss_died.connect(_on_over)

func _on_over() -> void:
	_run_over = true

func _unhandled_input(event: InputEvent) -> void:
	if _run_over and event.is_action_pressed(&"interact"):
		Profile.save()
		get_tree().change_scene_to_file("res://scenes/hub.tscn")

func _build_walls() -> void:
	var w := ARENA_SIZE.x
	var h := ARENA_SIZE.y
	_make_wall(Vector2(w * 0.5, WALL_T * 0.5), Vector2(w, WALL_T))
	_make_wall(Vector2(w * 0.5, h - WALL_T * 0.5), Vector2(w, WALL_T))
	_make_wall(Vector2(WALL_T * 0.5, h * 0.5), Vector2(WALL_T, h))
	_make_wall(Vector2(w - WALL_T * 0.5, h * 0.5), Vector2(WALL_T, h))

func _make_wall(center: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = center
	wall.collision_layer = 0
	wall.collision_mask = 0
	wall.set_collision_layer_value(1, true)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	wall.add_child(col)
	var vis := Polygon2D.new()
	var hx := size.x * 0.5
	var hy := size.y * 0.5
	vis.polygon = PackedVector2Array([Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)])
	vis.color = Color(0.22, 0.18, 0.24)
	wall.add_child(vis)
	add_child(wall)
