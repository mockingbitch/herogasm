class_name Monster
extends Node2D
## Quái lang thang trong Bãi Săn. Combat được giải bởi Battle Engine khi hero giao chiến
## (mỗi encounter = 1 sim tất định); monster chỉ roam + là mục tiêu. Không permadeath cho hero.

signal died(monster: Monster)

var data: EnemyData
var uid: String = ""
var alive: bool = true

var _field: Rect2
var _wander_target: Vector2 = Vector2.ZERO
var _wander_cd: float = 0.0

func setup(d: EnemyData, uid_: String, field: Rect2) -> void:
	data = d
	uid = uid_
	_field = field

func _ready() -> void:
	_build_visual()
	position = _rand_point()
	_wander_target = _rand_point()

func _process(delta: float) -> void:
	if not alive:
		return
	_wander_cd -= delta
	if position.distance_to(_wander_target) < 6.0 or _wander_cd <= 0.0:
		_wander_target = _rand_point()
		_wander_cd = RandomService.randf_range(2.0, 4.5)
	var spd: float = data.speed * 0.35
	position = position.move_toward(_wander_target, spd * delta)

func is_alive() -> bool:
	return alive

func die() -> void:
	if not alive:
		return
	alive = false
	died.emit(self)
	queue_free()

func _rand_point() -> Vector2:
	return Vector2(
		RandomService.randf_range(_field.position.x, _field.end.x),
		RandomService.randf_range(_field.position.y, _field.end.y))

func _build_visual() -> void:
	var s: float = data.size if data != null else 7.0
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-s, -s), Vector2(s, -s), Vector2(s, s), Vector2(-s, s)])
	poly.color = data.body_color if data != null else Color(0.8, 0.3, 0.3)
	add_child(poly)
	var lbl := Label.new()
	lbl.text = data.display_name if data != null else "?"
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.position = Vector2(-s, -s - 12)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)
