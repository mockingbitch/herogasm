extends Node2D
## World P1 (main scene): thành + Bãi Săn + hero tự trị + spawner + HUD.
## Living-world: mọi thứ tồn tại đồng thời; hero tự đi lại giữa town/field (CLAUDE.md).

const TOWN := Vector2(-260, 0)
const FIELD_CENTER := Vector2(260, 0)
const FIELD_RECT := Rect2(140, -110, 300, 220)

var _spawner: MonsterSpawner

func _ready() -> void:
	ServiceRegistry.clear()   # scene mới -> đăng ký lại dịch vụ
	y_sort_enabled = true     # ISO: xếp chiều sâu theo Y cho building/hero/monster
	_build_ground()
	_build_town()
	_build_field()
	_build_field_decor()
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

# --- ISO diorama ground -----------------------------------------------------
# Cube tile ~52px rộng, diamond 2:1 -> half-width 26, half-height 13.
const ISO_HW := 26
const ISO_HH := 13
const GRID_COLS := 26
const GRID_ROWS := 18
const GROUND_DIR := "res://assets/iso/ground/"
const GROUND_KEYS := ["grass", "grass2", "dirt", "cobble", "stone", "path", "water", "snow"]

func _iso(col: int, row: int) -> Vector2:
	return Vector2((col - row) * ISO_HW, (col + row) * ISO_HH)

## Chuyển pixel-space (toạ độ sim) -> ô iso gần nhất (để rải path/plaza quanh building).
func _cell_at(p: Vector2, origin: Vector2) -> Vector2i:
	var l := p - origin
	var col := roundi((l.x / ISO_HW + l.y / ISO_HH) / 2.0)
	var row := roundi((l.y / ISO_HH - l.x / ISO_HW) / 2.0)
	return Vector2i(col, row)

## Nền iso: diorama cỏ + quảng trường đá quanh thành + suối phía Bãi Săn.
func _build_ground() -> void:
	var ground := Node2D.new()
	ground.name = "GroundLayer"
	ground.z_index = -100                  # luôn dưới building/hero/monster
	ground.y_sort_enabled = true           # cube xếp painter đúng theo Y
	add_child(ground)
	var center := _iso(GRID_COLS / 2, GRID_ROWS / 2)
	ground.position = Vector2(20, -6) - center   # canh diorama dưới town+field

	var tex := {}
	for k in GROUND_KEYS:
		tex[k] = load(GROUND_DIR + k + ".png")

	# Ô đặc biệt theo pixel-space: quảng trường đá quanh thành, suối cột Bãi Săn.
	var special := {}
	var plaza_cells := _cells_in_rect(Rect2(TOWN.x - 90, TOWN.y - 70, 180, 150), ground.position)
	for c in plaza_cells:
		special[c] = "cobble"
	for cy in range(-5, 6):                # suối dọc mép phải Bãi Săn
		var wc := _cell_at(Vector2(FIELD_CENTER.x + 190, cy * 26.0), ground.position)
		special[wc] = "water"
	# Bãi Săn: mảng đất (clearing combat) + đường mòn nối town -> field
	for c in _cells_in_rect(Rect2(FIELD_CENTER.x - 85, FIELD_CENTER.y - 58, 195, 122), ground.position):
		if not special.has(c):
			special[c] = "dirt"
	for c in _cells_in_rect(Rect2(-40, -13, 300, 26), ground.position):
		if not special.has(c):
			special[c] = "path"

	var rng := RandomNumberGenerator.new()
	rng.seed = 20260703
	for col in GRID_COLS:
		for row in GRID_ROWS:
			var key: String = special.get(Vector2i(col, row), "")
			if key == "":
				key = "grass2" if rng.randf() < 0.12 else "grass"
			var spr := Sprite2D.new()
			spr.texture = tex[key]
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = _iso(col, row)
			ground.add_child(spr)

## Các ô iso phủ 1 rect pixel-space (dùng canh quảng trường quanh building).
func _cells_in_rect(r: Rect2, origin: Vector2) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var step := 16.0
	var y := r.position.y
	while y <= r.end.y:
		var x := r.position.x
		while x <= r.end.x:
			var c := _cell_at(Vector2(x, y), origin)
			if not out.has(c):
				out.append(c)
			x += step
		y += step
	return out

# --- Bãi Săn decor (rừng iso: cây/đá/bụi + điểm nhấn chest/crystal/wagon/lửa) ------
const NAT := "res://assets/iso/nature/"
const DEC := "res://assets/iso/deco/"

func _decor(path: String, pos: Vector2, sc: float = 1.0) -> void:
	var tex: Texture2D = load(path)
	if tex == null:
		return
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(sc, sc)
	s.offset = Vector2(0, -tex.get_height() / 2.0)   # neo đáy -> Y-sort theo gốc
	s.position = pos
	add_child(s)

const TREES := ["tree-pine", "tree-pine2", "tree-oak", "tree-bush"]
const CLEARING := Rect2(170, -66, 210, 132)   # vùng combat (không đặt cây)

## Rải cảnh vật Bãi Săn: rừng dày quanh rìa (né clearing/town/suối), đá/bụi/hoa, điểm nhấn.
func _build_field_decor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 771026
	# Viền rừng dày: rải ~40 cây trong dải field, né clearing combat + cột suối phải.
	var placed := 0
	for i in 120:
		if placed >= 40:
			break
		var p := Vector2(rng.randf_range(138, 452), rng.randf_range(-142, 142))
		if CLEARING.has_point(p) or p.x > 444:            # chừa clearing + suối
			continue
		if absf(p.y) < 22 and p.x < 210:                  # chừa đường mòn vào
			continue
		_decor(NAT + TREES[rng.randi() % TREES.size()] + ".png", p)
		placed += 1
	# Đá / bụi / hoa / lúa rải trong & ven clearing
	for r in [[Vector2(176, 60), "rock2"], [Vector2(392, -30), "rock1"], [Vector2(360, -60), "rock3"], [Vector2(300, 70), "rock2"], [Vector2(162, -42), "crystal-rock"], [Vector2(348, 40), "rock1"]]:
		_decor(NAT + str(r[1]) + ".png", r[0])
	for b in [[Vector2(214, 68), "flowers"], [Vector2(332, -58), "flowers2"], [Vector2(280, 84), "wheat"], [Vector2(232, -50), "flowers2"], [Vector2(356, 60), "flowers"], [Vector2(190, 44), "log"], [Vector2(320, 8), "flowers"]]:
		_decor(NAT + str(b[1]) + ".png", b[0])
	# Điểm nhấn (như demo): tinh thể trái, rương, xe ngựa phải, đuốc, lửa trại
	_decor(DEC + "crystal.png", Vector2(178, 20))
	_decor(DEC + "chest.png", Vector2(210, -30))
	_decor(DEC + "wagon.png", Vector2(360, -34))
	_decor(DEC + "barrel.png", Vector2(342, -20))
	_decor(DEC + "crate.png", Vector2(374, -16))
	_decor(DEC + "torch.png", Vector2(196, 66))
	_decor(DEC + "torch.png", Vector2(360, 66))
	_decor(NAT + "campfire.png", Vector2(236, 78))

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
	var cam := CameraController.new()
	cam.position = Vector2(255, 24)        # focus Bãi Săn (như màn demo, thành nằm ngoài khung)
	cam.zoom = Vector2(1.18, 1.18)         # zoom gần: thấy hero/quái to như demo
	add_child(cam)                         # CameraController._ready() tự make_current + set target
