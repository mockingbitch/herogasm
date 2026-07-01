class_name RuneDef
extends Resource
## Định nghĩa rune (core + 4 slot). Main = base + per_level*(lvl-1) (FLAT).
## level_unlock_effects {5,10,15,20 -> {stat:percent}} + core_percent + resonance theo element.

@export var id: String = ""
@export var display_name: String = ""
@export var category: int = Enums.RuneCategory.OFFENSIVE
@export var is_core: bool = false                    # true -> chỉ vào slot 0 (core)
@export var element: int = Enums.Element.ARCANE      # ARCANE = trung tính (không tính resonance)
@export var set_id: String = ""
@export var main_stat_key: String = "bonus_attack"
@export var main_stat_base: float = 5.0
@export var per_level_gain: float = 1.0
@export var max_level: int = 20
@export var level_unlock_effects: Dictionary = {}    # {5:{stat:pct},10:{...},15:{...},20:{...}}
@export var core_percent: Dictionary = {}            # nếu is_core: {stat:pct}
