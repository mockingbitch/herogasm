extends Node2D
## Dungeon run: arena có tường, quái data-driven. Dọn sạch hoặc chết -> E về hub.

const ARENA_SIZE := Vector2(480, 320)
const WALL_T := 8.0

var _spawns: Array = [
	{"id": "slime", "pos": Vector2(90, 80)},
	{"id": "slime", "pos": Vector2(390, 80)},
	{"id": "slime", "pos": Vector2(160, 165)},
	{"id": "bat", "pos": Vector2(330, 90)},
	{"id": "bat", "pos": Vector2(90, 250)},
	{"id": "skeleton", "pos": Vector2(390, 250)},
	{"id": "skeleton", "pos": Vector2(330, 165)},
]

var _alive: int = 0
var _run_over: bool = false

func _ready() -> void:
	Engine.time_scale = 1.0
	_build_walls()

	var player := Player.new()
	player.position = ARENA_SIZE * 0.5
	add_child(player)

	for s in _spawns:
		var ed: EnemyData = Database.get_enemy(s["id"])
		if ed == null:
			continue
		var e := Enemy.new()
		e.data = ed
		e.position = s["pos"]
		add_child(e)
		_alive += 1

	var hud := HUD.new()
	hud.player = player
	hud.enemies_total = _alive
	add_child(hud)

	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.player_died.connect(_on_player_died)

func _on_enemy_died(_enemy: Node, _pos: Vector2) -> void:
	_alive = maxi(_alive - 1, 0)
	if _alive == 0:
		_run_over = true

func _on_player_died() -> void:
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
	_make_wall(Vector2(140, 110), Vector2(28, 28))
	_make_wall(Vector2(340, 220), Vector2(28, 28))

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
	vis.color = Color(0.26, 0.26, 0.32)
	wall.add_child(vis)
	add_child(wall)
