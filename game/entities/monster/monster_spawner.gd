class_name MonsterSpawner
extends Node2D
## Giữ dân số quái trong Bãi Săn ở khoảng [target, cap]; respawn sau delay (performance.md:
## không spawn hàng loạt 1 frame). Quái lấy từ Database.monster_pool.

@export var target: int = 8
@export var cap: int = 14
@export var respawn_delay: float = 1.5

var _field: Rect2
var _alive: Array[Monster] = []
var _cd: float = 0.0
var _seq: int = 0

func setup(field: Rect2) -> void:
	_field = field

func _ready() -> void:
	for i in target:
		_spawn()

func _process(delta: float) -> void:
	_prune()
	if _alive.size() >= target:
		return
	_cd -= delta
	if _cd <= 0.0 and _alive.size() < cap:
		_spawn()
		_cd = respawn_delay

func alive_count() -> int:
	_prune()
	return _alive.size()

func nearest_alive(from: Vector2) -> Monster:
	_prune()
	var best: Monster = null
	var best_d := INF
	for m in _alive:
		if not m.is_alive():
			continue
		var d: float = from.distance_squared_to(m.global_position)
		if d < best_d:
			best_d = d
			best = m
	return best

func _spawn() -> void:
	if Database.monster_pool.is_empty():
		return
	var idx := RandomService.randi_range(0, Database.monster_pool.size() - 1)
	var enemy_id: String = Database.monster_pool[idx]
	var d: EnemyData = Database.get_enemy(enemy_id)
	if d == null:
		return
	var m := Monster.new()
	_seq += 1
	m.setup(d, "mob_%d" % _seq, _field)
	m.died.connect(_on_died)
	add_child(m)
	_alive.append(m)

func _on_died(m: Monster) -> void:
	_alive.erase(m)

func _prune() -> void:
	_alive = _alive.filter(func(m): return is_instance_valid(m) and m.is_alive())
