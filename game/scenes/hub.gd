extends Node2D
## Thị trấn (main scene mới). Nơi nâng cấp & vào dungeon. Không có quái.
## E/I: mở HubMenu. Lưu Profile mỗi khi vào hub (chốt tiến trình sau run).

const SIZE := Vector2(384, 216)
const WALL_T := 8.0

var _menu: HubMenu
var _info: Label

func _ready() -> void:
	Engine.time_scale = 1.0
	Profile.save()
	_build_room()

	var player := Player.new()
	player.position = SIZE * 0.5
	add_child(player)

	_menu = HubMenu.new()
	_menu.enter_dungeon.connect(_on_enter_dungeon)
	_menu.enter_boss.connect(_on_enter_boss)
	add_child(_menu)

	_build_info()

func _process(_delta: float) -> void:
	if _info != null:
		_info.text = "Vàng: %d   Cấp: %d      [E / I] mở menu thị trấn — mua bán, lò rèn, vào dungeon" % [Profile.gold, Profile.level]

func _unhandled_input(event: InputEvent) -> void:
	if _menu.visible:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"toggle_menu"):
		_menu.open()
		get_viewport().set_input_as_handled()

func _on_enter_dungeon() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/run.tscn")

func _on_enter_boss() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/boss_arena.tscn")

func _build_info() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_info = Label.new()
	_info.position = Vector2(4, 4)
	_info.add_theme_font_size_override("font_size", 8)
	_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_info)

func _build_room() -> void:
	var w := SIZE.x
	var h := SIZE.y
	_make_wall(Vector2(w * 0.5, WALL_T * 0.5), Vector2(w, WALL_T))
	_make_wall(Vector2(w * 0.5, h - WALL_T * 0.5), Vector2(w, WALL_T))
	_make_wall(Vector2(WALL_T * 0.5, h * 0.5), Vector2(WALL_T, h))
	_make_wall(Vector2(w - WALL_T * 0.5, h * 0.5), Vector2(WALL_T, h))
	# Bục trang trí (thị giác): Cửa hàng / Lò rèn / Cổng
	_deco(Vector2(80, 70), Color(0.3, 0.7, 0.4))
	_deco(Vector2(192, 60), Color(0.8, 0.5, 0.2))
	_deco(Vector2(300, 70), Color(0.5, 0.4, 0.8))

func _deco(center: Vector2, color: Color) -> void:
	var n := Node2D.new()
	n.position = center
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)])
	p.color = color
	n.add_child(p)
	add_child(n)

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
