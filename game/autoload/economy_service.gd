extends Node
## EconomyService (autoload) — nguồn công thức kinh tế duy nhất. KHÔNG hardcode cost ở nơi khác.
## Cost curve số mũ + trần idle ≤80% (economy.md). Deterministic (không RNG, không Time).
## Thứ tự autoload: sau Database, trước PlayerProfile (Profile._apply_offline_progress gọi clamp_idle).

const CONSTANTS_PATH := "res://data/economy_constants.tres"
const IDLE_HARD_CAP := 0.8

var _ec: EconomyConstants

func _ready() -> void:
	_ec = load(CONSTANTS_PATH) as EconomyConstants
	if _ec == null:
		_ec = EconomyConstants.new()

# --- cost curve số mũ: cost(L) = base * growth^(L-1) ----------------------
func building_cost(base: int, growth: float, level: int) -> int:
	var g: float = growth if growth > 1.0 else _ec.default_cost_growth
	return int(round(float(base) * pow(g, float(maxi(level, 1) - 1))))

# --- trần idle ≤ 80% (chặn cứng dù .tres set cao hơn) ---------------------
func idle_ratio() -> float:
	return clampf(_ec.idle_cap_ratio, 0.0, IDLE_HARD_CAP)

func clamp_idle(active_equivalent: float) -> float:
	return active_equivalent * idle_ratio()

# --- service pricing/formula ----------------------------------------------
func train_xp(seconds: float) -> int:
	return int(seconds * _ec.train_xp_per_sec)

func train_gold_cost(seconds: float) -> int:
	return int(round(seconds * _ec.train_gold_per_sec))

func market_tax() -> float:
	return _ec.market_tax

func repair_full() -> float:
	return _ec.repair_full
