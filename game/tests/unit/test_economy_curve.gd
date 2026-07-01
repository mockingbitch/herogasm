extends RefCounted
## Unit — EconomyService cost curve số mũ + trần idle ≤80% + BuildingDef dùng curve.

static func run(t) -> void:
	t.eq(EconomyService.building_cost(100, 1.6, 1), 100, "Cost_L1_Base")
	t.eq(EconomyService.building_cost(100, 1.6, 2), 160, "Cost_L2")
	t.eq(EconomyService.building_cost(100, 1.6, 3), 256, "Cost_L3")   # 100*1.6^2
	t.truthy(EconomyService.building_cost(100, 1.6, 4) > EconomyService.building_cost(100, 1.6, 3), "Cost_Monotonic")

	# BuildingDef dùng EconomyService qua upgrade_cost
	var def: BuildingDef = Database.get_building_def("inn")
	t.truthy(def != null, "InnDefExists")
	t.eq(def.upgrade_cost(2), EconomyService.building_cost(def.cost_base, def.cost_growth, 2), "Def_UsesCurve")

	# Trần idle: hard cap ≤ 0.8 kể cả .tres set cao hơn
	t.truthy(EconomyService.idle_ratio() <= 0.8, "Idle_HardCap")
	t.approx(EconomyService.clamp_idle(1000.0), 1000.0 * EconomyService.idle_ratio(), "ClampIdle")
