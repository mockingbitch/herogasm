class_name BossBar
extends CanvasLayer
## Thanh máu boss ở đỉnh màn hình. Nghe EventBus boss_*.

const W := 240.0
var _name: Label
var _bg: ColorRect
var _fill: ColorRect

func _ready() -> void:
	layer = 5
	var x := 192.0 - W * 0.5  # 192 = giữa viewport 384

	_name = Label.new()
	_name.add_theme_font_size_override("font_size", 8)
	_name.position = Vector2(x, 5)
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name)

	_bg = ColorRect.new()
	_bg.color = Color(0.1, 0.1, 0.1, 0.85)
	_bg.position = Vector2(x, 17)
	_bg.size = Vector2(W, 6)
	add_child(_bg)

	_fill = ColorRect.new()
	_fill.color = Color(0.82, 0.2, 0.27)
	_fill.position = _bg.position
	_fill.size = Vector2(W, 6)
	add_child(_fill)

	visible = false
	EventBus.boss_spawned.connect(_on_spawned)
	EventBus.boss_health.connect(_on_health)
	EventBus.boss_died.connect(_on_died)

func _on_spawned(boss_name: String, _max_hp: int) -> void:
	_name.text = boss_name
	visible = true
	_set_frac(1.0)

func _on_health(hp: int, max_hp: int) -> void:
	_set_frac(float(hp) / float(maxi(max_hp, 1)))

func _on_died() -> void:
	visible = false

func _set_frac(f: float) -> void:
	_fill.size = Vector2(W * clampf(f, 0.0, 1.0), 6)
