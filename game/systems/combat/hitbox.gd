class_name Hitbox
extends Area2D
## Vùng GÂY đòn. Phát `hit(hurtbox)` cho mỗi Hurtbox trúng; chủ sở hữu tự tính
## sát thương (crit/lifesteal...) rồi gọi hurtbox.receive().
##
## 2 chế độ:
##  - Burst (tick_interval <= 0): gọi activate(dur) -> bật vài frame, mỗi target trúng 1 lần
##    (xử lý cả mục tiêu đã nằm sẵn trong vùng + mục tiêu mới vào).
##  - Persistent (tick_interval > 0): luôn bật, cứ mỗi `tick_interval` giây lại đánh
##    các hurtbox đang chồng lấn (đòn tiếp xúc của quái/boss).
##
## mask trỏ tới layer hurtbox của ĐỐI THỦ: player hitbox -> 5, enemy/boss -> 4.

signal hit(hurtbox: Hurtbox)

var tick_interval: float = 0.0

var _active: bool = false
var _tick_cd: float = 0.0
var _already: Dictionary = {}

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)
	if tick_interval > 0.0:
		_active = true
		monitoring = true
	else:
		monitoring = false

## Gọi TRƯỚC add_child (và set tick_interval trước nếu dùng persistent).
func configure(target_layer_bit: int, shape: Shape2D) -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(target_layer_bit, true)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

func activate(duration: float) -> void:
	_active = true
	_already.clear()
	monitoring = true
	await get_tree().physics_frame
	for a in get_overlapping_areas():
		_try(a)
	await get_tree().create_timer(duration).timeout
	monitoring = false
	_active = false
	_already.clear()

func _physics_process(delta: float) -> void:
	if not _active or tick_interval <= 0.0:
		return
	_tick_cd = maxf(_tick_cd - delta, 0.0)
	if _tick_cd <= 0.0:
		_tick_cd = tick_interval
		for a in get_overlapping_areas():
			if a is Hurtbox:
				hit.emit(a)

func _on_area_entered(a: Area2D) -> void:
	if _active and tick_interval <= 0.0:
		_try(a)

func _try(a: Area2D) -> void:
	if a is Hurtbox and not _already.has(a):
		_already[a] = true
		hit.emit(a)
