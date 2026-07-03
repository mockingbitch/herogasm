extends Node2D
## World (main scene): CITADEL lớn (thành trì) + Bãi Săn ở "màn khác" (region tách xa),
## hero tự trị đi qua CỔNG DỊCH CHUYỂN (teleport gate) ở cổng thành để tới Bãi Săn.
## Living-world: mọi thứ tồn tại đồng thời; camera chuyển giữa 2 view (Thành / Bãi Săn).

# --- Layout (pixel-space sim) ------------------------------------------------
const TOWN := Vector2(0, 0)               # tâm CITADEL
const CITADEL_HW := 330.0                 # nửa bề rộng nội thành
const CITADEL_HH := 210.0                 # nửa bề cao nội thành
const GATE := Vector2(360, 0)             # cổng thành (đông) — đặt teleport portal
const GATE_X := 500.0                     # ranh giới citadel(<) | hunt(>)
const HUNT := Vector2(860, 0)             # tâm Bãi Săn (màn khác, tách xa)
const FIELD_CENTER := HUNT
const FIELD_RECT := Rect2(HUNT.x - 150, -110, 300, 220)

var _spawner: MonsterSpawner
var _cam: CameraController

func _ready() -> void:
	ServiceRegistry.clear()
	y_sort_enabled = true
	_build_ground()
	_build_town()
	_build_field()
	_build_field_decor()
	_spawn_heroes()
	_build_camera()
	var hud := GameHud.new()
	add_child(hud)
	hud.bind_world(self, _spawner, FIELD_RECT)
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
			return

func F6_hint() -> void:
	Debug.log("World ready — %d hero, %d monster" % [PlayerProfile.hero_ids.size(), _spawner.alive_count()])

# ---------------------------------------------------------------------------
# ISO GROUND (2 patch: citadel lớn + hunt tách xa)
# ---------------------------------------------------------------------------
const ISO_HW := 26
const ISO_HH := 13
const GROUND_DIR := "res://assets/iso/ground/"
const GROUND_KEYS := ["grass", "grass2", "dirt", "cobble", "stone", "path", "water", "snow"]

func _iso(col: int, row: int) -> Vector2:
	return Vector2((col - row) * ISO_HW, (col + row) * ISO_HH)

func _cell_at(p: Vector2, origin: Vector2) -> Vector2i:
	var l := p - origin
	var col := roundi((l.x / ISO_HW + l.y / ISO_HH) / 2.0)
	var row := roundi((l.y / ISO_HH - l.x / ISO_HW) / 2.0)
	return Vector2i(col, row)

func _build_ground() -> void:
	_ground_patch(TOWN, 34, 26, 20260703, "citadel")
	_ground_patch(HUNT, 22, 16, 771027, "hunt")

## 1 patch nền iso đặt sao cho tâm lưới rơi đúng world_center.
func _ground_patch(world_center: Vector2, cols: int, rows: int, seed: int, kind: String) -> void:
	var g := Node2D.new()
	g.z_index = -100
	g.y_sort_enabled = true
	add_child(g)
	g.position = world_center - _iso(cols / 2, rows / 2)

	var tex := {}
	for k in GROUND_KEYS:
		tex[k] = load(GROUND_DIR + k + ".png")

	var special := {}
	if kind == "citadel":
		# quảng trường đá trung tâm + đường trục (đông-tây ra cổng, bắc-nam)
		for c in _cells_in_rect(Rect2(world_center.x - 150, world_center.y - 110, 300, 220), g.position):
			special[c] = "cobble"
		for c in _cells_in_rect(Rect2(world_center.x - 260, world_center.y - 16, 660, 32), g.position):
			if not special.has(c):
				special[c] = "path"
		for c in _cells_in_rect(Rect2(world_center.x - 16, world_center.y - 190, 32, 380), g.position):
			if not special.has(c):
				special[c] = "path"
	elif kind == "hunt":
		for c in _cells_in_rect(Rect2(world_center.x - 85, world_center.y - 58, 195, 122), g.position):
			special[c] = "dirt"
		for cy in range(-5, 6):
			var wc := _cell_at(Vector2(world_center.x + 190, world_center.y + cy * 26.0), g.position)
			special[wc] = "water"

	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for col in cols:
		for row in rows:
			var key: String = special.get(Vector2i(col, row), "")
			if key == "":
				key = "grass2" if rng.randf() < 0.1 else "grass"
			var spr := Sprite2D.new()
			spr.texture = tex[key]
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = _iso(col, row)
			g.add_child(spr)

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

# ---------------------------------------------------------------------------
# DECOR helper
# ---------------------------------------------------------------------------
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
	s.offset = Vector2(0, -tex.get_height() / 2.0)
	s.position = pos
	add_child(s)

# ---------------------------------------------------------------------------
# CITADEL: tường bao + cổng (arch + tháp + portal) + building trải rộng + decor
# ---------------------------------------------------------------------------
func _build_town() -> void:
	_citadel_walls()
	_citadel_gate()
	# 7 building trải rộng khắp nội thành (không còn cụm sát nhau)
	_building("guild", TOWN + Vector2(0, -30))
	_building("inn", TOWN + Vector2(-210, -120))
	_building("market", TOWN + Vector2(-210, 110))
	_building("blacksmith", TOWN + Vector2(200, -120))
	_building("alchemy", TOWN + Vector2(200, 110))
	_building("kitchen", TOWN + Vector2(-60, -140))
	_building("training", TOWN + Vector2(70, 140))
	_citadel_decor()

## Vòng tường quanh nội thành, chừa cổng phía đông.
func _citadel_walls() -> void:
	var step := 30.0
	var x := -CITADEL_HW
	while x <= CITADEL_HW:
		_decor(DEC + "wall.png", TOWN + Vector2(x, -CITADEL_HH))   # bắc
		_decor(DEC + "wall.png", TOWN + Vector2(x, CITADEL_HH))    # nam
		x += step
	var y := -CITADEL_HH + step
	while y < CITADEL_HH:
		_decor(DEC + "wall.png", TOWN + Vector2(-CITADEL_HW, y))   # tây
		if absf(y) > 54.0:                                          # đông: chừa khoảng cổng
			_decor(DEC + "wall.png", TOWN + Vector2(CITADEL_HW, y))
		y += step

## Cổng thành phía đông: 2 tháp kẹp + vòm cổng + CỔNG DỊCH CHUYỂN (portal).
func _citadel_gate() -> void:
	_decor(DEC + "tower.png", TOWN + Vector2(CITADEL_HW, -60))
	_decor(DEC + "tower.png", TOWN + Vector2(CITADEL_HW, 60))
	_decor(DEC + "gate-arch.png", GATE + Vector2(6, 0))
	_decor(DEC + "portal.png", GATE + Vector2(44, 2))            # teleport gate
	_decor(DEC + "torch.png", GATE + Vector2(-8, -34))
	_decor(DEC + "torch.png", GATE + Vector2(-8, 34))

func _citadel_decor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242
	# cây dọc trong tường (né building/đường)
	for i in 26:
		var p := TOWN + Vector2(rng.randf_range(-CITADEL_HW + 24, CITADEL_HW - 24), rng.randf_range(-CITADEL_HH + 20, CITADEL_HH - 20))
		if absf(p.y - TOWN.y) < 26 or Rect2(TOWN.x - 160, TOWN.y - 120, 320, 240).has_point(p):
			continue   # né đường trục + quảng trường trung tâm
		_decor(NAT + ["tree-oak", "tree-pine", "tree-bush"][rng.randi() % 3] + ".png", p)
	# điểm nhấn quanh quảng trường
	_decor(DEC + "wagon.png", TOWN + Vector2(-150, 40))
	_decor(DEC + "barrel.png", TOWN + Vector2(-130, 56))
	_decor(DEC + "crate.png", TOWN + Vector2(150, -70))
	_decor(NAT + "flowers.png", TOWN + Vector2(-90, -80))
	_decor(NAT + "flowers2.png", TOWN + Vector2(90, 70))
	_decor(NAT + "campfire.png", TOWN + Vector2(0, 120))

func _building(id: String, pos: Vector2) -> void:
	var def: BuildingDef = Database.get_building_def(id)
	if def == null:
		return
	var b := Building.new()
	b.setup(def, pos, 1)
	add_child(b)

# ---------------------------------------------------------------------------
# BÃI SĂN (region tách xa, quanh HUNT)
# ---------------------------------------------------------------------------
const TREES := ["tree-pine", "tree-pine2", "tree-oak", "tree-bush"]

func _build_field() -> void:
	_spawner = MonsterSpawner.new()
	_spawner.setup(FIELD_RECT)
	add_child(_spawner)

func _build_field_decor() -> void:
	var off := FIELD_CENTER - Vector2(260, 0)   # dời decor cũ (tuned quanh 260,0) sang HUNT
	var clearing := Rect2(170 + off.x, -66 + off.y, 210, 132)
	var rng := RandomNumberGenerator.new()
	rng.seed = 771026
	var placed := 0
	for i in 120:
		if placed >= 40:
			break
		var p := Vector2(rng.randf_range(138, 452) + off.x, rng.randf_range(-142, 142) + off.y)
		if clearing.has_point(p) or p.x > 444 + off.x:
			continue
		if absf(p.y - FIELD_CENTER.y) < 22 and p.x < 210 + off.x:
			continue
		_decor(NAT + TREES[rng.randi() % TREES.size()] + ".png", p)
		placed += 1
	for r in [[Vector2(176, 60), "rock2"], [Vector2(392, -30), "rock1"], [Vector2(360, -60), "rock3"], [Vector2(300, 70), "rock2"], [Vector2(162, -42), "crystal-rock"], [Vector2(348, 40), "rock1"]]:
		_decor(NAT + str(r[1]) + ".png", (r[0] as Vector2) + off)
	for b in [[Vector2(214, 68), "flowers"], [Vector2(332, -58), "flowers2"], [Vector2(280, 84), "wheat"], [Vector2(232, -50), "flowers2"], [Vector2(356, 60), "flowers"], [Vector2(190, 44), "log"], [Vector2(320, 8), "flowers"]]:
		_decor(NAT + str(b[1]) + ".png", (b[0] as Vector2) + off)
	_decor(DEC + "crystal.png", Vector2(178, 20) + off)
	_decor(DEC + "chest.png", Vector2(210, -30) + off)
	_decor(DEC + "wagon.png", Vector2(360, -34) + off)
	_decor(DEC + "torch.png", Vector2(196, 66) + off)
	_decor(DEC + "torch.png", Vector2(360, 66) + off)
	_decor(NAT + "campfire.png", Vector2(236, 78) + off)

# ---------------------------------------------------------------------------
# HEROES (home trong citadel, field=HUNT, teleport qua gate)
# ---------------------------------------------------------------------------
func _spawn_heroes() -> void:
	var town_ent := GATE + Vector2(-40, 0)          # điểm ra ở cổng thành
	var hunt_ent := Vector2(HUNT.x - 140, HUNT.y)   # điểm vào Bãi Săn
	var i := 0
	for id in PlayerProfile.hero_ids:
		var h := Hero.new()
		var home := TOWN + Vector2(-40 + (i % 3) * 40, -10 + (i / 3) * 30)
		h.setup(id, home, FIELD_CENTER, _spawner, GATE_X, town_ent, hunt_ent)
		add_child(h)
		i += 1

# ---------------------------------------------------------------------------
# CAMERA + 2 VIEW (Thành / Bãi Săn) — cổng dịch chuyển đổi màn
# ---------------------------------------------------------------------------
func _build_camera() -> void:
	_cam = CameraController.new()
	add_child(_cam)
	go_town_view()          # mặc định: nhìn toàn CITADEL

func go_town_view() -> void:
	if _cam != null:
		_cam.focus(TOWN + Vector2(70, 10), 1.0)      # zoom gần: vật thể rõ; pan để xem cả thành

func go_hunt_view() -> void:
	if _cam != null:
		_cam.focus(FIELD_CENTER + Vector2(0, 20), 1.12)   # zoom gần như màn Bãi Săn
