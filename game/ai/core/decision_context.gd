class_name DecisionContext
extends RefCounted
## Ảnh chụp read-only để Utility AI chấm điểm goal (ai.md §Decision Context).
## THUẦN dữ liệu — build từ HeroInstance + PlayerProfile, testable headless không cần scene.

var hp_pct: float = 1.0            # 0..1
var stamina01: float = 1.0         # 0..1
var durability01: float = 1.0      # 0..1
var potion_count: int = 0
var gold: int = 0
var energy: int = 0
var inventory_count: int = 0
var inventory_cap: int = 20
var is_ko: bool = false

# Ngưỡng/tính cách data-driven (HeroDef.ai_weights)
var aggression: float = 1.0
var rest_threshold: float = 0.45   # hp/stamina dưới mức này -> muốn nghỉ
var repair_threshold: float = 0.30 # durability dưới mức này -> muốn sửa
var potion_price: int = 0
var repair_cost: int = 0

func inventory_full() -> bool:
	return inventory_count >= inventory_cap
