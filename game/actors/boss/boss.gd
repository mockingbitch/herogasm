class_name Boss
extends CharacterBody2D
## Boss 3 phase. Combat qua Hitbox/Hurtbox (C1). Hình ảnh: AnimatedSprite2D (0x72 big_demon).

@export var max_hp: int = 320
@export var move_speed: float = 38.0
@export var charge_speed: float = 220.0
@export var contact_damage: int = 14
@export var projectile_damage: int = 10
@export var xp_reward: int = 60
@export var display_name: String = "Lãnh Chúa Hắc Ám"
@export var drop_id: String = "knight_blade"

enum State { APPROACH, WINDUP, CHARGE, RECOVER, DEAD }

var health: Health
var _sprite: AnimatedSprite2D
var _player: Node2D
var _state: int = State.APPROACH
var _busy: bool = false
var _think: float = 1.5
var _charge_dir: Vector2 = Vector2.RIGHT
var _phase: int = 1
var _size: float = 16.0

func _ready() -> void:
	add_to_group("enemies")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)

	_build_visual()

	var col := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(_size * 2.0, _size * 2.0)
	col.shape = sh
	add_child(col)

	var hb := Hurtbox.new()
	var hsh := RectangleShape2D.new()
	hsh.size = Vector2(_size * 2.0, _size * 2.0)
	hb.configure(5, hsh)
	add_child(hb)
	hb.hurt.connect(_on_hurt)

	var contact := Hitbox.new()
	contact.tick_interval = 0.55
	var csh := CircleShape2D.new()
	csh.radius = _size + 10.0
	contact.configure(4, csh)
	add_child(contact)
	contact.hit.connect(_on_contact_hit)

	health = Health.new()
	health.max_hp = max_hp
	add_child(health)
	health.damaged.connect(_on_health_damaged)
	health.died.connect(_on_died)

	EventBus.boss_spawned.emit(display_name, max_hp)

func _build_visual() -> void:
	_sprite = SpriteLib.build(SpriteLib.defs_for("big_demon", false), 7.0)
	_sprite.offset = Vector2(0, -2)
	add_child(_sprite)
	_sprite.play(&"idle")

func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return
	if _player == null or not is_instance_valid(_player):
		_player = _find_player()
		if _player == null:
			return
	_update_phase()
	var to_p: Vector2 = _player.global_position - global_position
	var dist := to_p.length()

	match _state:
		State.CHARGE:
			velocity = _charge_dir * charge_speed
		State.WINDUP, State.RECOVER:
			velocity = Vector2.ZERO
		_:
			velocity = to_p.normalized() * move_speed if dist > _size + 14.0 else Vector2.ZERO
			if not _busy:
				_think -= delta
				if _think <= 0.0:
					_start_action()
	move_and_slide()
	_update_anim(to_p.x)

func _update_anim(to_player_x: float) -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.flip_h = to_player_x < 0.0
	var a := &"run" if velocity.length() > 1.0 else &"idle"
	if _sprite.animation != a:
		_sprite.play(a)

func _update_phase() -> void:
	var frac := float(health.hp) / float(max_hp)
	if frac <= 0.33:
		_phase = 3
	elif frac <= 0.66:
		_phase = 2
	else:
		_phase = 1

func _start_action() -> void:
	_busy = true
	if _phase >= 2 and randf() < 0.5:
		_shoot()
	else:
		_charge()

func _charge() -> void:
	_state = State.WINDUP
	_telegraph(Color(1, 0.5, 0.3))
	await get_tree().create_timer(0.55).timeout
	if _state == State.DEAD:
		return
	if is_instance_valid(_player):
		_charge_dir = (_player.global_position - global_position).normalized()
	_state = State.CHARGE
	await get_tree().create_timer(0.35).timeout
	if _state == State.DEAD:
		return
	_end_action()

func _shoot() -> void:
	_state = State.WINDUP
	_telegraph(Color(1, 0.9, 0.3))
	await get_tree().create_timer(0.5).timeout
	if _state == State.DEAD:
		return
	var n := 5 if _phase >= 3 else 3
	var base := (_player.global_position - global_position).angle() if is_instance_valid(_player) else 0.0
	var spread := 0.5
	for i in n:
		var a := base + lerpf(-spread, spread, float(i) / float(maxi(n - 1, 1)))
		_spawn_projectile(Vector2.RIGHT.rotated(a))
	_state = State.RECOVER
	await get_tree().create_timer(0.3).timeout
	if _state == State.DEAD:
		return
	_end_action()

func _end_action() -> void:
	_busy = false
	_state = State.APPROACH
	_think = (0.8 if _phase >= 3 else 1.4) + randf() * 0.6

func _telegraph(c: Color) -> void:
	if is_instance_valid(_sprite):
		_sprite.modulate = c
		create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.5)

func _spawn_projectile(dir: Vector2) -> void:
	var p := Projectile.new()
	p.velocity = dir * 110.0
	p.damage = projectile_damage
	p.position = global_position
	get_parent().add_child(p)

func _on_contact_hit(hurtbox: Hurtbox) -> void:
	hurtbox.receive(contact_damage, self)

func _on_hurt(amount: int, _source: Node) -> void:
	if _state == State.DEAD:
		return
	health.take_damage(amount)
	_hit_flash()

func _hit_flash() -> void:
	if is_instance_valid(_sprite):
		_sprite.modulate = Color(2, 2, 2)
		create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.12)

func _on_health_damaged(_amount: int, hp: int, max_hp_: int) -> void:
	EventBus.boss_health.emit(hp, max_hp_)

func _on_died() -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	velocity = Vector2.ZERO
	Profile.gain_xp(xp_reward)
	EventBus.boss_died.emit()
	EventBus.enemy_died.emit(self, global_position)
	var ip := Pickup.new()
	ip.kind = Pickup.Kind.ITEM
	ip.item_id = drop_id
	ip.position = global_position + Vector2(-12, 0)
	get_parent().add_child(ip)
	var gp := Pickup.new()
	gp.kind = Pickup.Kind.GOLD
	gp.amount = randi_range(40, 70)
	gp.position = global_position + Vector2(12, 0)
	get_parent().add_child(gp)
	queue_free()

func _find_player() -> Node2D:
	var arr := get_tree().get_nodes_in_group("player")
	return (arr[0] as Node2D) if arr.size() > 0 else null
