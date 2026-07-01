class_name SpriteLib
extends RefCounted
## Tạo AnimatedSprite2D từ các frame rời của 0x72 Dungeon Tileset II (CC0).
## defs = { "idle": ["knight_m_idle_anim_f0", ...], "run": [...] }

const DIR := "res://assets/dungeon/0x72_DungeonTilesetII_v1.7/frames/"

## Tự suy ra tên frame theo quy ước của pack.
##  single=true  -> "<base>_anim_f0..3" (vd swampy)
##  single=false -> "<base>_idle_anim_f0..3" + "<base>_run_anim_f0..3"
static func defs_for(base: String, single: bool) -> Dictionary:
	if single:
		var fr: Array = []
		for i in 4:
			fr.append("%s_anim_f%d" % [base, i])
		return {"idle": fr, "run": fr}
	var idle: Array = []
	var run: Array = []
	for i in 4:
		idle.append("%s_idle_anim_f%d" % [base, i])
		run.append("%s_run_anim_f%d" % [base, i])
	return {"idle": idle, "run": run}

## Archer custom (frame cắt từ archer.png): idle/run/attack/hit/death.
const ARCHER_DIR := "res://assets/generated/archer/"
const ARCHER_ANIMS := {
	"idle": ["a_r0c0", "a_r0c1", "a_r0c3", "a_r0c1"],
	"run": ["a_r1c0", "a_r1c1", "a_r1c2", "a_r1c3"],
	"attack": ["a_r2c0", "a_r2c1", "a_r2c3"],
	"skill": ["a_r3c1", "a_r3c2"],
	"hit": ["a_r4c0"],
	"death": ["a_r4c1"],
}

static func build_archer(fps: float = 6.0) -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	for anim in ARCHER_ANIMS.keys():
		sf.add_animation(anim)
		sf.set_animation_loop(anim, anim != "death" and anim != "hit")
		sf.set_animation_speed(anim, fps)
		for fname in ARCHER_ANIMS[anim]:
			var tex: Texture2D = load(ARCHER_DIR + fname + ".png")
			if tex != null:
				sf.add_frame(anim, tex)
	var spr := AnimatedSprite2D.new()
	spr.sprite_frames = sf
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return spr

static func build(defs: Dictionary, fps: float = 8.0) -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	for anim in defs.keys():
		sf.add_animation(anim)
		sf.set_animation_loop(anim, true)
		sf.set_animation_speed(anim, fps)
		for fname in defs[anim]:
			var tex: Texture2D = load(DIR + fname + ".png")
			if tex != null:
				sf.add_frame(anim, tex)
	var spr := AnimatedSprite2D.new()
	spr.sprite_frames = sf
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return spr
