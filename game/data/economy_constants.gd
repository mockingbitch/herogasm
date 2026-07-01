class_name EconomyConstants
extends Resource
## Hệ số kinh tế toàn cục (data-driven). Thay mọi magic number kinh tế trong code.
## idle_cap_ratio bị EconomyService chặn cứng ≤0.8 (economy.md: idle ≤80%, khuyến 60~75%).

@export var idle_cap_ratio: float = 0.75
@export var default_cost_growth: float = 1.6      # fallback growth cost(L)=base*growth^(L-1)
@export var train_xp_per_sec: float = 0.8         # EXP nhẹ đổi từ thời gian (< hunt nhiều)
@export var train_gold_per_sec: float = 0.02
@export var market_tax: float = 0.05              # thuế bán loot (sink)
@export var repair_full: float = 100.0
