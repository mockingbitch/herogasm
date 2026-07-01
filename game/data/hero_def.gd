class_name HeroDef
extends Resource
## Định nghĩa 1 hero (data-driven). Tạo bằng code trong Database (có thể .tres sau).
## ai_weights: aggression / rest_threshold / repair_threshold (ai.md §Data Driven).

@export var id: String = ""
@export var display_name: String = ""
@export var hero_class: String = "warrior"   # tank/warrior/rogue/mage/ranger/support
@export var class_role: String = ""          # P3 synergy key (fallback = hero_class)
@export var race: String = "human"           # P3 synergy key (human/elf/orc/...)
@export var element: int = Enums.Element.ARCANE
@export var start_level: int = 1
@export var start_weapon: String = "rusty_sword"
@export var ai_weights: Dictionary = {}       # aggression, rest_threshold, repair_threshold
@export var sprite: String = "knight_m"       # placeholder 0x72

func role() -> String:
	return class_role if class_role != "" else hero_class
