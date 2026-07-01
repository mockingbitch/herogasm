extends Node2D
## World P1 (main scene): thành + Bãi Săn + hero tự trị + spawner + HUD.
## Living-world: mọi thứ tồn tại đồng thời; hero tự đi lại giữa town/field (CLAUDE.md).

const TOWN := Vector2(-260, 0)
const FIELD_CENTER := Vector2(260, 0)
const FIELD_RECT := Rect2(140, -110, 300, 220)

var _spawner: MonsterSpawner

func _ready() -> void:
	ServiceRegistry.clear()   # scene mới -> đăng ký lại dịch vụ
	_build_ground()
	_build_town()
	_build_field()
	_spawn_heroes()
	_build_camera()
	add_child(GameHud.new())
	# Điều phối expedition idle: giữ ~MAX_EXPEDITIONS hero đi zone (số còn lại field-hunt).
	TimeService.register_slice(_dispatch_tick, 8.0)
	F6_hint()

const MAX_EXPEDITIONS := 2

func _dispatch_tick() -> void:
	if ExpeditionService.active_count() >= MAX_EXPEDITIONS:
		return
	for id in PlayerProfile.hero_ids:
		var h: HeroInstance = PlayerProfile.get_hero(id)
		if h == null or h.is_ko or ExpeditionService.is_on_expedition(id):
			continue
		var zone: String = WorldMap.best_unlocked_zone_for(h, PlayerProfile)
		if zone == "":
			zone = WorldMap.easiest_unlocked_zone(PlayerProfile)
		if zone != "" and ExpeditionService.can_start(id, zone)["ok"]:
			ExpeditionService.start(id, zone)
			return   # 1 dispatch / tick

func F6_hint() -> void:
	Debug.log("World P1 ready — %d hero, %d monster" % [PlayerProfile.hero_ids.size(), _spawner.alive_count()])

const TILE := 32
const T_GRASS := Vector2i(0, 0)
const T_GRASS_DK := Vector2i(1, 0)
const T_DIRT := Vector2i(2, 0)
const T_PATH := Vector2i(3, 0)
const T_WATER := Vector2i(4, 0)
const T_WALL := Vector2i(5, 0)
const T_PLAZA := Vector2i(6, 0)
const T_BUSH := Vector2i(7, 0)

## Nền TileMap từ atlas placeholder: thành có tường bao + quảng trường, Bãi Săn cỏ/đất + suối.
func _build_ground() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/generated/tiles/atlas.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	for i in 8:
		src.create_tile(Vector2i(i, 0))
	ts.add_source(src, 0)
	var layer := TileMapLayer.new()
	layer.tile_set = ts
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(layer)                       # thêm đầu tiên -> vẽ dưới cùng (sau buildings/hero)

	var rng := RandomNumberGenerator.new()
	rng.seed = 20260702
	# nền cỏ toàn bản đồ
	for cy in range(-6, 7):
		for cx in range(-15, 17):
			layer.set_cell(Vector2i(cx, cy), 0, T_GRASS_DK if rng.randf() < 0.16 else T_GRASS)

	# --- THÀNH (trái): tường bao + quảng trường + lối đá ---
	var tx0 := -14; var tx1 := -2; var ty0 := -5; var ty1 := 4
	for cx in range(tx0, tx1 + 1):
		layer.set_cell(Vector2i(cx, ty0), 0, T_WALL)
		layer.set_cell(Vector2i(cx, ty1), 0, T_WALL)
	for cy in range(ty0, ty1 + 1):
		layer.set_cell(Vector2i(tx0, cy), 0, T_WALL)
		layer.set_cell(Vector2i(tx1, cy), 0, T_WALL)
	for cy in range(-1, 2):                # quảng trường trung tâm
		for cx in range(-9, -5):
			layer.set_cell(Vector2i(cx, cy), 0, T_PLAZA)
	for cx in range(tx0 + 1, tx1):         # lối đá ngang giữa thành
		layer.set_cell(Vector2i(cx, 0), 0, T_PATH)

	# --- BÃI SĂN (phải): cỏ + mảng đất + suối + bụi cây ---
	for i in 26:
		layer.set_cell(Vector2i(rng.randi_range(4, 14), rng.randi_range(-4, 4)), 0, T_DIRT)
	for cy in range(-5, 6):                # suối cột phải
		layer.set_cell(Vector2i(15, cy), 0, T_WATER)
		layer.set_cell(Vector2i(16, cy), 0, T_WATER)
	for i in 14:
		layer.set_cell(Vector2i(rng.randi_range(4, 13), rng.randi_range(-4, 4)), 0, T_BUSH)

func _build_town() -> void:
	_building("inn", Vector2(-350, -40))
	_building("market", Vector2(-280, 55))
	_building("blacksmith", Vector2(-210, -40))
	_building("training", Vector2(-350, 55))
	_building("alchemy", Vector2(-210, 55))
	_building("kitchen", Vector2(-280, -45))
	_building("guild", Vector2(-140, 5))

func _building(id: String, pos: Vector2) -> void:
	var def: BuildingDef = Database.get_building_def(id)
	if def == null:
		return
	var b := Building.new()
	b.setup(def, pos, 1)
	add_child(b)

func _build_field() -> void:
	_spawner = MonsterSpawner.new()
	_spawner.setup(FIELD_RECT)
	add_child(_spawner)

func _spawn_heroes() -> void:
	var i := 0
	for id in PlayerProfile.hero_ids:
		var h := Hero.new()
		var home := TOWN + Vector2(-20 + (i % 3) * 20, -20 + (i / 3) * 24)
		h.setup(id, home, FIELD_CENTER, _spawner)
		add_child(h)
		i += 1

func _build_camera() -> void:
	var cam := Camera2D.new()
	cam.position = Vector2(20, 0)
	cam.zoom = Vector2(0.62, 0.62)   # zoom-out để thấy cả town + field
	add_child(cam)
	cam.make_current()               # sau khi vào tree
