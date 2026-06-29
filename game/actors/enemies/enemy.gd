class_name Enemy
extends CharacterBody2D
## Quái data-driven. Combat qua Hitbox/Hurtbox (C1).
## Hình ảnh: AnimatedSprite2D theo data.sprite (0x72). Fallback Polygon2D nếu thiếu.

@export var data: EnemyData

var speed: float = 46.0
var aggro_range: float = 150.0
var contact_damage: int = 8
var attack_interval: float = 0.8
var max_hp: int = 30
var xp_reward: int = 5
var gold_min: int = 3
var gold_max: int = 8
var body_color: Color = Color(0.85, 0.27, 0.27)
var body_size: float = 7.0
var drops: Array = []
var sprite_name: String = ""
var sprite_single: bool = false

var health: Health
var _sprite: AnimatedSprite2D
var _player: Node2D
var _dead: bool = false
var _stop_dist: float = 13.0

func _ready() -> void:
	add_to_group("enemies")
	if data != null:
		speed = data.speed
		aggro_range = data.aggro_range
		contact_damage = data.contact_damage
		attack_interval = data.attack_interval
		max_hp = data.max_hp
		xp_reward = data.xp_reward
		gold_min = data.gold_drop_min
		gold_max = data.gold_drop_max
		body_color = data.body_color
		body_size = data.size
		drops = data.drops
		sprite_name = data.sprite
		sprite_single = data.sprite_single
	_stop_dist = body_size + 6.0

	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)

	_build_visual()

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(body_size * 2.0, body_size * 2.0)
	col.shape = shape
	add_child(col)

	_hurtbox_setup()

	var contact := Hitbox.new()
	contact.tick_interval = attack_interval
	var csh := CircleShape2D.new()
	csh.radius = body_size + 9.0
	contact.configure(4, csh)          # mask 4 = player_hurt
	add_child(contact)
	contact.hit.connect(_on_contact_hit)

	health = Health.new()
	health.max_hp = max_hp
	add_child(health)
	health.died.connect(_on_died)

func _build_visual() -> void:
	if sprite_name != "":
		_sprite = SpriteLib.build(SpriteLib.defs_for(sprite_name, sprite_single), 8.0)
		add_child(_sprite)
		_sprite.play(&"idle")
	else:
		var poly := Polygon2D.new()
		var h := body_size
		poly.polygon = PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
		poly.color = body_color
		add_child(poly)

func _hurtbox_setup() -> void:
	var hb := Hurtbox.new()
	var hsh := RectangleShape2D.new()
	hsh.size = Vector2(body_size * 2.0, body_size * 2.0)
	hb.configure(5, hsh)               # layer 5 = enemy_hurt
	add_child(hb)
	hb.hurt.connect(_on_hurt)

func _physics_process(_delta: float) -> void:
	if _dead:
		return
	if _player == null or not is_instance_valid(_player):
		_player = _find_player()
		if _player == null:
			return
	var to_p: Vector2 = _player.global_position - global_position
	var dist := to_p.length()
	velocity = to_p.normalized() * speed if (dist <= aggro_range and dist > _stop_dist) else Vector2.ZERO
	move_and_slide()
	_update_anim(to_p.x)

func _update_anim(to_player_x: float) -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.flip_h = to_player_x < 0.0
	var a := &"run" if velocity.length() > 1.0 else &"idle"
	if _sprite.animation != a:
		_sprite.play(a)

func _on_contact_hit(hurtbox: Hurtbox) -> void:
	hurtbox.receive(contact_damage, self)

func _on_hurt(amount: int, source: Node) -> void:
	if _dead:
		return
	health.take_damage(amount)
	_flash()
	if source != null and is_instance_valid(source):
		global_position += (global_position - (source as Node2D).global_position).normalized() * 6.0

func _flash() -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.modulate = Color(1.8, 1.8, 1.8)
	create_tween().tween_property(_sprite, "modulate", Color.WHITE, 0.18)

func _on_died() -> void:
	if _dead:
		return
	_dead = true
	Profile.gain_xp(xp_reward)
	EventBus.enemy_died.emit(self, global_position)
	_spawn_pickup(Pickup.Kind.GOLD, "", randi_range(gold_min, gold_max))
	for entry in drops:
		if randf() < float(entry.get("chance", 0.0)):
			_spawn_pickup(Pickup.Kind.ITEM, str(entry["id"]), 0)
	queue_free()

func _spawn_pickup(kind: int, item_id: String, amount: int) -> void:
	var p := Pickup.new()
	p.kind = kind
	p.item_id = item_id
	p.amount = amount
	p.position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
	get_parent().add_child(p)

func _find_player() -> Node2D:
	var arr := get_tree().get_nodes_in_group("player")
	return (arr[0] as Node2D) if arr.size() > 0 else null
