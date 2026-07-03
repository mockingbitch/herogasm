class_name EnemyData
extends Resource
## Định nghĩa 1 loại quái. Tạo bằng code trong Database.
## drops: mảng các Dictionary { "id": String, "chance": float (0..1) }.

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 30
@export var speed: float = 46.0
@export var contact_damage: int = 8
@export var attack_interval: float = 0.8
@export var aggro_range: float = 150.0
@export var xp_reward: int = 5
@export var gold_drop_min: int = 3
@export var gold_drop_max: int = 8
@export var body_color: Color = Color(0.85, 0.27, 0.27)
@export var size: float = 7.0
@export var drops: Array = []
@export var sprite: String = ""          # tên base sprite 0x72 (vd "skelet")
@export var sprite_single: bool = false  # true nếu pack chỉ có "<base>_anim_fN"
@export var is_boss: bool = false        # true -> hiện thanh máu boss trên HUD (quái thường: ẩn)
