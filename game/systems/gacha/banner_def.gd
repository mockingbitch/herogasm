class_name BannerDef
extends Resource
## Banner gacha data-driven. pool: [{hero_def_id, rarity, weight}]. Pity soft/hard.

@export var id: String = ""
@export var display_name: String = ""
@export var pool: Array = []                  # [{hero_def_id:String, rarity:int, weight:float}]
@export var pity_hard: int = 90               # pull thứ N từ reset -> BẮT BUỘC guaranteed
@export var pity_soft_start: int = 74         # từ pull này rate guaranteed tăng dần
@export var pity_soft_step: float = 0.06      # +6%/pull vượt soft_start
@export var guaranteed_rarity: int = 2        # rarity tối thiểu được đảm bảo khi pity
@export var cost_currency: String = "gems"
@export var cost_amount: int = 160            # /1 pull
