extends Node2D
## Dev-only: nạp world.tscn, chờ vài frame cho iso render, chụp viewport ra PNG rồi thoát.
## Chạy: <godot> --path game res://tools/shot.tscn   (cần DISPLAY, KHÔNG --headless)

var _frames: int = 0
const OUT := "user://iso_shot.png"

func _ready() -> void:
	var w: Node = load("res://scenes/world.tscn").instantiate()
	add_child(w)

func _process(_delta: float) -> void:
	_frames += 1
	if _frames == 45:
		var img := get_viewport().get_texture().get_image()
		img.save_png(OUT)
		print("SHOT_SAVED=", ProjectSettings.globalize_path(OUT))
		get_tree().quit()
