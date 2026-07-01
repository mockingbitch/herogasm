class_name EquipDef
extends Resource
## Định nghĩa 1 loại equipment (8 slot). Roll affix TÁI DÙNG roller trong HeroInstance.
## secondary count theo rarity (ItemData.Rarity, tái dùng _affix_count). set_id -> set bonus.

@export var id: String = ""
@export var slot: int = Enums.EquipSlot.WEAPON       # Enums.EquipSlot
@export var weapon_type: int = Enums.WeaponType.SWORD
@export var display_name: String = ""
@export var allowed_class: Array[String] = []        # [] = mọi class; else khớp hero.class_role
@export var rarity: int = ItemData.Rarity.COMMON     # dùng ItemData.Rarity (loot ladder cũ)
@export var base_ilvl: int = 10
@export var main_stat_key: String = "bonus_attack"   # bonus_attack/defense/max_hp/speed
@export var main_stat_base: float = 10.0
@export var secondary_pool: Array = []               # subset AFFIX_POOL; [] = dùng HeroInstance.AFFIX_POOL
@export var set_id: String = ""
