class_name CombatConstants
extends Resource
## Nguồn sự thật cho hằng số balance (thay các `const` từng nằm trong profile.gd).
## Đặt trong data (.tres) để tune không cần sửa code — theo rule gdscript.md
## (Resources for configuration, không hardcode gameplay value trong entity).
## P0: giá trị placeholder; sẽ cân bằng bằng simulation ở P6.

# --- Chỉ số nền của hero ---
@export var base_attack: int = 10
@export var base_defense: int = 0
@export var base_max_hp: int = 100
@export var base_speed: float = 92.0
@export var base_crit_chance: float = 0.05
@export var crit_damage_default: float = 1.5

# --- Tăng trưởng theo level ---
@export var atk_per_level: int = 2
@export var def_per_level: int = 1
@export var hp_per_level: int = 10

# --- Kinh tế / lò rèn ---
@export var upgrade_scale: float = 0.4      # gear +lvl => chỉ số × (1 + upgrade_scale*lvl)
@export var upgrade_base_cost: int = 20     # chi phí nâng cấp cơ bản (× (level+1))
@export var buy_markup: int = 4             # giá mua = sell_price × buy_markup

# --- Công thức damage placeholder ---
@export var def_k: float = 100.0            # hằng số mềm hoá defense: dmg = atk*k/(k+def)

## Trần hút máu (giữ nguyên hành vi cũ trong profile.gd).
@export var lifesteal_cap: float = 0.8

## Chi phí respec talent = respec_base_cost × số điểm đã tiêu (gold sink).
@export var respec_base_cost: int = 30
## Giá trị shard khi summon trùng, theo rarity (0..4). Data-driven, không magic.
@export var dup_shard_by_rarity: Array[int] = [5, 10, 20, 40, 80]
