extends Node2D
## Dev-only: nạp world.tscn, chờ vài frame cho iso render, chụp viewport ra PNG rồi thoát.
## Chạy: <godot> --path game res://tools/shot.tscn   (cần DISPLAY, KHÔNG --headless)

var _frames: int = 0
var _w: Node = null

func _ready() -> void:
	_w = load("res://scenes/world.tscn").instantiate()
	add_child(_w)

func _process(_delta: float) -> void:
	_frames += 1
	if _frames == 45:
		_save("user://iso_shot_town.png")           # view mặc định: CITADEL
		if _w != null and _w.has_method("go_hunt_view"):
			_w.go_hunt_view()                        # chuyển sang Bãi Săn
	elif _frames == 90:
		_save("user://iso_shot_hunt.png")
		get_tree().quit()

func _save(path: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	print("SHOT_SAVED=", ProjectSettings.globalize_path(path))
