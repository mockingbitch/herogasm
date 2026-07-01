class_name BuildingDef
extends Resource
## Định nghĩa công trình (data-driven). type: inn/market/blacksmith.
## param(name, level) = base + per_level*(level-1). Tạo bằng code trong Database.

@export var id: String = ""
@export var type: String = "inn"
@export var display_name: String = ""
@export var max_level: int = 3
@export var base_params: Dictionary = {}      # {"heal_rate": 25.0, ...}
@export var per_level: Dictionary = {}         # cộng thêm mỗi level > 1
@export var upgrade_cost_base: int = 100

func param(name: String, level: int) -> float:
	var b := float(base_params.get(name, 0.0))
	var p := float(per_level.get(name, 0.0))
	return b + p * float(maxi(level, 1) - 1)

func upgrade_cost(level: int) -> int:
	return upgrade_cost_base * maxi(level, 1)
