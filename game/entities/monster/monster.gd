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
var _spr: AnimatedSprite2D

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
	var before := position.x
	position = position.move_toward(_wander_target, spd * delta)
	if _spr != null and absf(position.x - before) > 0.02:
		_spr.flip_h = position.x < before

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
	Hero._add_shadow(self, 7.0)
	var base := data.sprite if data != null and data.sprite != "" else "swampy"
	var single := data.sprite_single if data != null else true
	_spr = SpriteLib.build(SpriteLib.defs_for(base, single), 6.0)
	_spr.scale = Vector2(1.4, 1.4)
	_spr.position = Vector2(0, -8)
	_spr.play("idle")
	add_child(_spr)
	var lbl := Label.new()
	lbl.text = data.display_name if data != null else "?"
	lbl.add_theme_font_size_override("font_size", 6)
	lbl.position = Vector2(-12, -26)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lbl)
