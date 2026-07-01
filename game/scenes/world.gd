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
	F6_hint()

func F6_hint() -> void:
	Debug.log("World P1 ready — %d hero, %d monster" % [PlayerProfile.hero_ids.size(), _spawner.alive_count()])

func _build_ground() -> void:
	# nền town (xanh) + field (nâu) cho dễ nhìn
	_rect(Rect2(-380, -140, 260, 280), Color(0.18, 0.22, 0.16))
	_rect(FIELD_RECT.grow(20), Color(0.22, 0.18, 0.12))

func _build_town() -> void:
	_building("inn", Vector2(-330, -30))
	_building("market", Vector2(-260, 55))
	_building("blacksmith", Vector2(-195, -30))

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

func _rect(r: Rect2, col: Color) -> void:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	p.color = col
	add_child(p)
