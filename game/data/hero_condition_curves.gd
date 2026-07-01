class_name HeroConditionCurves
extends Resource
## Curve vòng đời hero (data-driven) — fatigue/mood/injury/train. Thay magic number trong hero/AI.

# Fatigue
@export var fatigue_decay_hunt: float = 3.0        # +fatigue/giây khi HUNT
@export var fatigue_decay_move: float = 0.8        # +fatigue/giây khi di chuyển
@export var fatigue_recover_rest: float = 20.0     # -fatigue/giây khi REST (Inn)
@export var fatigue_full_penalty: float = 0.5      # power ×(1-penalty) khi fatigue=100
@export var fatigue_rest_threshold: float = 0.80   # fatigue01 ≥ mức này -> muốn nghỉ
@export var fatigue_per_expedition: float = 15.0

# Mood
@export var mood_min_mult: float = 0.75            # power mult khi mood=0
@export var mood_pivot: float = 50.0               # mood ≥ pivot => mult 1.0
@export var mood_gain_victory: float = 6.0
@export var mood_loss_defeat: float = 12.0
@export var mood_gain_rest: float = 4.0            # +mood/giây khi REST
@export var mood_train_gain: float = 8.0

# Injury
@export var injury_recover_base_sec: float = 1800.0        # 30' × injury_level tự lành
@export var injury_power_penalty_per_level: float = 0.15   # -15% power/level

# Train
@export var train_fatigue_add: float = 15.0
