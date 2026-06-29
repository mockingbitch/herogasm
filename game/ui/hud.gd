class_name HUD
extends CanvasLayer
## HUD lúc đi run: HP, vàng, cấp, bình máu, số quái còn lại, overlay khi chết/clear.

var player: Player
var enemies_total: int = 0

var _enemies_left: int = 0
var _hp: Label
var _gold: Label
var _level: Label
var _potion: Label
var _enemies: Label
var _overlay: Label

func _ready() -> void:
	_enemies_left = enemies_total

	_hp = _make_label(Vector2(4, 4))
	_gold = _make_label(Vector2(4, 15))
	_level = _make_label(Vector2(4, 26))
	_potion = _make_label(Vector2(4, 37))
	_enemies = _make_label(Vector2(4, 48))

	var hint := _make_label(Vector2(4, 202))
	hint.text = "WASD di chuyển | J/Space đánh | K/Shift né | Q bình máu"

	_overlay = _make_label(Vector2(0, 94))
	_overlay.size = Vector2(384, 28)
	_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay.add_theme_font_size_override("font_size", 16)
	_overlay.visible = false

	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.xp_changed.connect(_on_xp_changed)
	EventBus.consumables_changed.connect(_on_consumables_changed)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.player_died.connect(_on_player_died)

	if player != null and is_instance_valid(player):
		_set_hp(player.get_hp(), player.get_max_hp())
	else:
		_set_hp(Profile.eff_max_hp(), Profile.eff_max_hp())
	_gold.text = "Vàng: %d" % Profile.gold
	_level.text = "Cấp: %d" % Profile.level
	_potion.text = "Bình máu: %d" % Profile.potion_count()
	_update_enemies()

func _make_label(pos: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _set_hp(hp: int, max_hp: int) -> void:
	_hp.text = "HP: %d / %d" % [hp, max_hp]

func _on_player_damaged(_amount: int, hp: int, max_hp: int) -> void:
	_set_hp(hp, max_hp)

func _on_gold_changed(total: int) -> void:
	_gold.text = "Vàng: %d" % total

func _on_xp_changed(level: int, _xp: int, _next: int) -> void:
	_level.text = "Cấp: %d" % level

func _on_consumables_changed() -> void:
	_potion.text = "Bình máu: %d" % Profile.potion_count()

func _on_enemy_died(_enemy: Node, _pos: Vector2) -> void:
	_enemies_left = maxi(_enemies_left - 1, 0)
	_update_enemies()
	if _enemies_left == 0:
		_show_overlay("CLEARED!   E: về Thị trấn")

func _on_player_died() -> void:
	_show_overlay("YOU DIED   —   E: về Thị trấn")

func _update_enemies() -> void:
	_enemies.text = "Quái còn lại: %d" % _enemies_left

func _show_overlay(text: String) -> void:
	_overlay.text = text
	_overlay.visible = true
