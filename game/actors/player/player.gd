class_name Player
extends CharacterBody2D
## Nhân vật. Chỉ số từ Profile. Combat qua Hitbox/Hurtbox (C1).
## Hình ảnh: AnimatedSprite2D (0x72 knight_m). Đổi sprite -> sửa _build_visual().

@export var attack_cooldown: float = 0.32
@export var dodge_speed: float = 240.0
@export var dodge_time: float = 0.18
@export var dodge_cooldown: float = 0.45

var attack_damage: int = 14
var max_hp: int = 100
var speed: float = 92.0
var defense: int = 0
var crit_chance: float = 0.05
var crit_damage: float = 1.5
var lifesteal: float = 0.0

var health: Health
var facing: Vector2 = Vector2.RIGHT

var _sprite: AnimatedSprite2D
var _swing: Polygon2D
var _hurtbox: Hurtbox
var _weapon: Hitbox
var _can_attack: bool = true
var _can_dodge: bool = true
var _dodging: bool = false

func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(2, true)   # body (để pickup phát hiện)
	set_collision_mask_value(1, true)    # va chạm tường

	attack_damage = Profile.eff_attack()
	max_hp = Profile.eff_max_hp()
	speed = Profile.eff_speed()
	defense = Profile.eff_defense()
	crit_chance = Profile.eff_crit_chance()
	crit_damage = Profile.eff_crit_damage()
	lifesteal = Profile.eff_lifesteal()

	_build_visual()

	var col := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(14, 14)
	col.shape = sh
	add_child(col)

	_hurtbox = Hurtbox.new()
	var hsh := RectangleShape2D.new()
	hsh.size = Vector2(14, 14)
	_hurtbox.configure(4, hsh)         # layer 4 = player_hurt
	add_child(_hurtbox)
	_hurtbox.hurt.connect(_on_hurt)

	_weapon = Hitbox.new()
	var wsh := RectangleShape2D.new()
	wsh.size = Vector2(24, 20)
	_weapon.configure(5, wsh)          # mask 5 = enemy_hurt
	add_child(_weapon)
	_weapon.hit.connect(_on_weapon_hit)

	health = Health.new()
	health.max_hp = max_hp
	add_child(health)
	health.damaged.connect(_on_health_damaged)
	health.healed.connect(_on_health_healed)
	health.died.connect(_on_died)

	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	add_child(cam)
	cam.make_current()

func _build_visual() -> void:
	# >>> Đổi sprite player ở đây <<<
	_sprite = SpriteLib.build(SpriteLib.defs_for("knight_m", false), 8.0)
	_sprite.offset = Vector2(0, -6)   # nâng để "chân" gần tâm va chạm (knight cao 28px)
	add_child(_sprite)
	_sprite.play(&"idle")
	_swing = Polygon2D.new()
	_swing.polygon = PackedVector2Array([Vector2(7, -7), Vector2(24, -11), Vector2(24, 11), Vector2(7, 7)])
	_swing.color = Color(1, 1, 1, 0.55)
	_swing.visible = false
	add_child(_swing)

func get_hp() -> int:
	return health.hp if health else max_hp

func get_max_hp() -> int:
	return max_hp

func _physics_process(_delta: float) -> void:
	if not health.is_alive():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if _dodging:
		move_and_slide()
		return
	var dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if dir != Vector2.ZERO:
		facing = dir.normalized()
	velocity = dir * speed
	move_and_slide()
	_update_anim(dir != Vector2.ZERO)

func _update_anim(moving: bool) -> void:
	if not is_instance_valid(_sprite):
		return
	if absf(facing.x) > 0.01:
		_sprite.flip_h = facing.x < 0.0
	var a := &"run" if moving else &"idle"
	if _sprite.animation != a:
		_sprite.play(a)

func _unhandled_input(event: InputEvent) -> void:
	if not health.is_alive():
		return
	if event.is_action_pressed(&"attack"):
		_attack()
	elif event.is_action_pressed(&"dodge"):
		_dodge()
	elif event.is_action_pressed(&"use_item"):
		_use_potion()

func _attack() -> void:
	if not _can_attack or _dodging:
		return
	_can_attack = false
	_weapon.position = facing * 16.0
	_weapon.rotation = facing.angle()
	_show_swing()
	_weapon.activate(0.12)
	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true

func _on_weapon_hit(hurtbox: Hurtbox) -> void:
	var is_crit := randf() < crit_chance
	var dmg := attack_damage
	if is_crit:
		dmg = int(round(dmg * crit_damage))
	hurtbox.receive(dmg, self)
	DamageNumber.spawn(get_parent(), hurtbox.global_position, dmg,
		Color(1, 0.55, 0.1) if is_crit else Color(1, 0.9, 0.35), is_crit)
	if lifesteal > 0.0:
		var h := int(round(dmg * lifesteal))
		if h > 0 and health.hp < health.max_hp:
			health.heal(h)
	GameState.hit_stop(0.04)

func _show_swing() -> void:
	_swing.rotation = facing.angle()
	_swing.visible = true
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(_swing):
		_swing.visible = false

func _dodge() -> void:
	if not _can_dodge or _dodging:
		return
	_dodging = true
	_can_dodge = false
	_hurtbox.set_invincible(true)
	velocity = facing * dodge_speed
	if is_instance_valid(_sprite):
		_sprite.modulate = Color(1, 1, 1, 0.5)
	await get_tree().create_timer(dodge_time).timeout
	_dodging = false
	_hurtbox.set_invincible(false)
	if is_instance_valid(_sprite):
		_sprite.modulate = Color.WHITE
	await get_tree().create_timer(dodge_cooldown).timeout
	_can_dodge = true

func _use_potion() -> void:
	if health.hp >= health.max_hp:
		return
	var heal := Profile.use_potion()
	if heal > 0:
		health.heal(heal)
		DamageNumber.spawn(get_parent(), global_position, heal, Color(0.4, 1.0, 0.4))

func _on_hurt(amount: int, _source: Node) -> void:
	if not health.is_alive():
		return
	health.take_damage(maxi(amount - defense, 1))
	_flash()

func _flash() -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.modulate = Color(1, 0.4, 0.4)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.2)

func _on_health_damaged(amount: int, hp: int, max_hp_: int) -> void:
	EventBus.player_damaged.emit(amount, hp, max_hp_)
	if amount > 0:
		DamageNumber.spawn(get_parent(), global_position, amount, Color(1, 0.5, 0.5))

func _on_health_healed(_amount: int, hp: int, max_hp_: int) -> void:
	EventBus.player_damaged.emit(0, hp, max_hp_)

func _on_died() -> void:
	EventBus.player_died.emit()
	if is_instance_valid(_sprite):
		_sprite.modulate = Color(0.4, 0.4, 0.4)
