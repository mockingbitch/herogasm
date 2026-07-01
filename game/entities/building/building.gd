class_name Building
extends Node2D
## Công trình thành: đăng ký dịch vụ vào ServiceRegistry; Inn nâng cấp được.
## Không chứa gameplay logic của hero — chỉ expose tham số dịch vụ (build-building/ui.md).

var def: BuildingDef
var level: int = 1

func setup(d: BuildingDef, pos: Vector2, lvl: int = 1) -> void:
	def = d
	level = maxi(lvl, 1)
	position = pos

func _ready() -> void:
	_build_visual()
	if def == null:
		return
	ServiceRegistry.register_service(def.effective_service(), global_position, self)
	match def.effective_service():
		"kitchen":
			TimeService.register_slice(_produce_food, 20.0)   # sản food định kỳ (không _process)
		"guild":
			PlayerProfile.apply_guild_bonuses(energy_cap_bonus(), roster_cap_bonus())

func _produce_food() -> void:
	PlayerProfile.add_consumable("food_ration", maxi(1, food_yield()))
	Telemetry.log_event("Economy", "food_produced", {"n": food_yield()})

func _exit_tree() -> void:
	ServiceRegistry.unregister_node(self)

# --- tham số dịch vụ ------------------------------------------------------
func heal_rate() -> float:
	return def.param("heal_rate", level) if def != null else 30.0

func potion_price() -> int:
	return int(def.param("potion_price", level)) if def != null else 40

func repair_price() -> int:
	return int(def.param("repair_price", level)) if def != null else 30

func heal_injury_price() -> int:
	return int(def.param("heal_injury_price", level)) if def != null else 60

func train_price() -> int:
	return int(def.param("train_price", level)) if def != null else 25

func food_yield() -> int:
	return int(def.param("food_yield", level)) if def != null else 3

func energy_cap_bonus() -> int:
	return int(def.param("energy_cap_bonus", level)) if def != null else 0

func roster_cap_bonus() -> int:
	return int(def.param("roster_cap_bonus", level)) if def != null else 0

# --- nâng cấp (chi phí gold ở PlayerProfile) ------------------------------
func can_upgrade() -> bool:
	return def != null and level < def.max_level

func upgrade_cost() -> int:
	return def.upgrade_cost(level) if def != null else 0

func upgrade() -> bool:
	if not can_upgrade():
		return false
	var cost := upgrade_cost()
	if PlayerProfile.gold < cost:
		return false
	PlayerProfile.add_gold(-cost)
	level += 1
	PlayerProfile.save()
	_refresh_label()
	Telemetry.log_event("Economy", "building_upgraded", {"id": def.id, "level": level})
	return true

var _label: Label

func _build_visual() -> void:
	var col := _color_for(def.type if def != null else "inn")
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-22, -22), Vector2(22, -22), Vector2(22, 22), Vector2(-22, 22)])
	poly.color = col
	add_child(poly)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 8)
	_label.position = Vector2(-24, -38)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_refresh_label()

func _refresh_label() -> void:
	if _label != null and def != null:
		_label.text = "%s Lv.%d" % [def.display_name, level]

func _color_for(type: String) -> Color:
	match type:
		"inn": return Color(0.35, 0.55, 0.85)
		"market": return Color(0.85, 0.6, 0.25)
		"blacksmith": return Color(0.6, 0.4, 0.35)
		"training": return Color(0.8, 0.35, 0.35)
		"alchemy": return Color(0.5, 0.8, 0.55)
		"kitchen": return Color(0.85, 0.75, 0.4)
		"guild": return Color(0.55, 0.45, 0.8)
		_: return Color(0.5, 0.5, 0.5)
