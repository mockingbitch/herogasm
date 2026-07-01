class_name BuildingDef
extends Resource
## Định nghĩa công trình (data-driven). type: inn/market/blacksmith.
## param(name, level) = base + per_level*(level-1). Tạo bằng code trong Database.

@export var id: String = ""
@export var type: String = "inn"               # cũng là khóa ServiceRegistry (P1 tương thích)
@export var service_type: String = ""          # "" -> dùng `type` (effective_service)
@export var display_name: String = ""
@export var max_level: int = 3
@export var base_params: Dictionary = {}       # {"heal_rate": 25.0, ...}
@export var per_level: Dictionary = {}          # cộng thêm mỗi level > 1
@export var upgrade_cost_base: int = 100        # fallback nếu cost_base==0 (tương thích)
@export var cost_base: int = 0                  # base cost curve
@export var cost_growth: float = 1.6            # cost(L)=base*growth^(L-1)
@export var capacity: int = 1
@export var unlock_requirement: Dictionary = {}

## param theo level (tuyến tính): base + per_level*(level-1).
func param(name: String, level: int) -> float:
	var b := float(base_params.get(name, 0.0))
	var p := float(per_level.get(name, 0.0))
	return b + p * float(maxi(level, 1) - 1)

func effective_service() -> String:
	return service_type if service_type != "" else type

## Cost nâng cấp = số mũ qua EconomyService (data-driven, no hardcode).
func upgrade_cost(level: int) -> int:
	var base := cost_base if cost_base > 0 else upgrade_cost_base
	return EconomyService.building_cost(base, cost_growth, level)
