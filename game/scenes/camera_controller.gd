class_name CameraController
extends Camera2D
## View controller cho world: zoom (pinch 2 ngón / cuộn chuột / phím +-) + pan
## (kéo 1 ngón / kéo chuột / phím mũi tên). Mobile-first (touch) + desktop.
##
## scene-structure.md: Camera là scene riêng, hỗ trợ Zoom/Pan. Input qua _unhandled_input
## (SAU UI) nên chạm vào nút HUD không bị pan/zoom đè. performance.md: _process cho camera
## interpolation là hợp lệ; không tìm node/không cấp phát mỗi frame.

@export var zoom_min: float = 0.35        # xa nhất (thấy toàn cảnh)
@export var zoom_max: float = 2.2         # gần nhất
@export var wheel_step: float = 0.12      # mỗi nấc cuộn chuột
@export var key_zoom_rate: float = 0.9    # tốc độ zoom bằng phím +/- (theo giây)
@export var zoom_lerp: float = 12.0       # mượt zoom
@export var key_pan_speed: float = 700.0  # px/giây (ở zoom 1)

var _target_zoom: float = 1.0
var _anchor_screen: Vector2 = Vector2.ZERO   # điểm giữ cố định khi zoom
var _touches: Dictionary = {}                # index -> vị trí chạm (screen)
var _pinch_dist: float = 0.0
var _mouse_pan: bool = false

func _ready() -> void:
	_target_zoom = zoom.x
	_anchor_screen = _view_size() * 0.5
	make_current()

func _view_size() -> Vector2:
	return Vector2(get_viewport().get_visible_rect().size)

## Màn hình -> thế giới (Camera2D anchor giữa, không xoay). Không phụ thuộc timing canvas transform.
func _screen_to_world(s: Vector2) -> Vector2:
	return global_position + (s - _view_size() * 0.5) / zoom

## Chuyển màn: snap camera tới 1 vùng (Thành / Bãi Săn) + đặt zoom.
func focus(pos: Vector2, z: float) -> void:
	global_position = pos
	_target_zoom = clampf(z, zoom_min, zoom_max)
	zoom = Vector2(_target_zoom, _target_zoom)
	_anchor_screen = _view_size() * 0.5

func _set_zoom_target(z: float, anchor_screen: Vector2) -> void:
	_target_zoom = clampf(z, zoom_min, zoom_max)
	_anchor_screen = anchor_screen

func _process(delta: float) -> void:
	# zoom mượt, giữ điểm neo cố định trên màn hình (zoom-về-con-trỏ / tâm-pinch)
	if absf(zoom.x - _target_zoom) > 0.0005:
		var before := _screen_to_world(_anchor_screen)
		var z := lerpf(zoom.x, _target_zoom, clampf(zoom_lerp * delta, 0.0, 1.0))
		zoom = Vector2(z, z)
		var after := _screen_to_world(_anchor_screen)
		global_position += before - after

	# pan bằng phím mũi tên (desktop) — chia zoom để tốc độ cảm giác đều
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir != Vector2.ZERO:
		global_position += dir * key_pan_speed * delta / zoom.x

	# zoom bằng phím +/- (desktop)
	var center := _view_size() * 0.5
	if Input.is_key_pressed(KEY_EQUAL) or Input.is_key_pressed(KEY_KP_ADD):
		_set_zoom_target(_target_zoom * (1.0 + key_zoom_rate * delta), center)
	elif Input.is_key_pressed(KEY_MINUS) or Input.is_key_pressed(KEY_KP_SUBTRACT):
		_set_zoom_target(_target_zoom * (1.0 - key_zoom_rate * delta), center)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_set_zoom_target(_target_zoom + wheel_step, mb.position)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_set_zoom_target(_target_zoom - wheel_step, mb.position)
		elif mb.button_index == MOUSE_BUTTON_LEFT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			_mouse_pan = mb.pressed
	elif event is InputEventMouseMotion and _mouse_pan:
		var mm: InputEventMouseMotion = event
		global_position -= mm.relative / zoom.x
	elif event is InputEventScreenTouch:
		var st: InputEventScreenTouch = event
		if st.pressed:
			_touches[st.index] = st.position
		else:
			_touches.erase(st.index)
		if _touches.size() < 2:
			_pinch_dist = 0.0                 # reset pinch khi rời 1 ngón
	elif event is InputEventScreenDrag:
		var sd: InputEventScreenDrag = event
		_touches[sd.index] = sd.position
		if _touches.size() == 1:
			global_position -= sd.relative / zoom.x    # 1 ngón -> pan
		elif _touches.size() >= 2:
			_handle_pinch()                            # 2 ngón -> zoom

func _handle_pinch() -> void:
	var pts: Array = _touches.values()
	var a: Vector2 = pts[0]
	var b: Vector2 = pts[1]
	var dist := a.distance_to(b)
	var mid := (a + b) * 0.5
	if _pinch_dist > 0.0 and dist > 0.0:
		_set_zoom_target(_target_zoom * (dist / _pinch_dist), mid)
	_pinch_dist = dist
