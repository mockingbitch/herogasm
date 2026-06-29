class_name ItemData
extends Resource
## Định nghĩa 1 loại item. Hiện được tạo bằng code trong Database; cùng class này
## có thể lưu thành .tres để chỉnh trong Inspector ở Phase sau.

enum Type { WEAPON, ARMOR, MATERIAL, CONSUMABLE }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var id: String = ""
@export var display_name: String = ""
@export var type: Type = Type.MATERIAL
@export var rarity: Rarity = Rarity.COMMON
@export var icon_color: Color = Color.WHITE   # màu placeholder cho icon/loot
@export var sell_price: int = 5

# Bonus khi trang bị (weapon/armor)
@export var bonus_attack: int = 0
@export var bonus_defense: int = 0
@export var bonus_max_hp: int = 0
@export var bonus_speed: float = 0.0

# Consumable
@export var heal_amount: int = 0
