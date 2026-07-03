extends RefCounted
## Unit — CameraController: zoom clamp + pinch/wheel zoom + drag pan.
## Gọi thẳng input handler (không cần viewport) -> kiểm state thay đổi đúng.

static func _cam() -> CameraController:
	var c := CameraController.new()
	c._target_zoom = 1.0            # _ready không chạy khi chưa vào tree
	return c

static func _wheel(up: bool) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN
	e.pressed = true
	e.position = Vector2(270, 480)
	return e

static func _touch(idx: int, pos: Vector2, pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.index = idx; e.position = pos; e.pressed = pressed
	return e

static func _drag(idx: int, pos: Vector2, rel: Vector2) -> InputEventScreenDrag:
	var e := InputEventScreenDrag.new()
	e.index = idx; e.position = pos; e.relative = rel
	return e

static func run(t) -> void:
	# --- wheel zoom in tăng target ---
	var c := _cam()
	c._unhandled_input(_wheel(true))
	t.truthy(c._target_zoom > 1.0, "WheelUp_ZoomsIn")

	# --- clamp trần: cuộn lên nhiều lần không vượt zoom_max ---
	var c2 := _cam()
	for i in 60:
		c2._unhandled_input(_wheel(true))
	t.approx(c2._target_zoom, c2.zoom_max, "ZoomClampMax", 0.0001)

	# --- clamp sàn: cuộn xuống nhiều lần không dưới zoom_min ---
	var c3 := _cam()
	for i in 60:
		c3._unhandled_input(_wheel(false))
	t.approx(c3._target_zoom, c3.zoom_min, "ZoomClampMin", 0.0001)

	# --- 1 ngón kéo -> pan (global_position dịch -relative/zoom) ---
	var c4 := _cam()
	c4.global_position = Vector2.ZERO
	c4._unhandled_input(_touch(0, Vector2(100, 100), true))
	c4._unhandled_input(_drag(0, Vector2(140, 100), Vector2(40, 0)))
	t.approx(c4.global_position.x, -40.0, "OneFingerPan", 0.001)

	# --- 2 ngón pinch xa ra -> zoom in ---
	var c5 := _cam()
	c5._unhandled_input(_touch(0, Vector2(100, 100), true))
	c5._unhandled_input(_touch(1, Vector2(200, 100), true))
	c5._unhandled_input(_drag(1, Vector2(200, 100), Vector2.ZERO))   # set _pinch_dist=100
	c5._unhandled_input(_drag(1, Vector2(300, 100), Vector2(100, 0))) # dist 200 -> x2
	t.truthy(c5._target_zoom > 1.0, "PinchOut_ZoomsIn")

	# --- nhả 1 ngón -> reset pinch, còn 1 ngón chuyển sang pan ---
	var c6 := _cam()
	c6._unhandled_input(_touch(0, Vector2(100, 100), true))
	c6._unhandled_input(_touch(1, Vector2(200, 100), true))
	c6._unhandled_input(_touch(1, Vector2(200, 100), false))
	t.truthy(c6._pinch_dist == 0.0 and c6._touches.size() == 1, "ReleaseFinger_ResetsPinch")
