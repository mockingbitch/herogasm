class_name DamageNumber
extends Node2D
## Số sát thương bay lên rồi mờ dần. big=true cho đòn chí mạng (to + nổi bật).

var _amount: int = 0
var _color: Color = Color.WHITE
var _big: bool = false

static func spawn(parent: Node, world_pos: Vector2, amount: int, color: Color = Color.WHITE, big: bool = false) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	var dn := DamageNumber.new()
	dn._amount = amount
	dn._color = color
	dn._big = big
	dn.position = world_pos
	parent.add_child(dn)

func _ready() -> void:
	var label := Label.new()
	label.text = ("%d!" % _amount) if _big else str(_amount)
	label.add_theme_font_size_override("font_size", 12 if _big else 8)
	label.add_theme_color_override("font_color", _color)
	label.position = Vector2(-8 if _big else -6, -12)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

	var rise := 20.0 if _big else 14.0
	var start_y := position.y
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position:y", start_y - rise, 0.5) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 0.5)
	tw.set_parallel(false)
	tw.tween_callback(queue_free)
