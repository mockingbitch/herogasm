class_name SkillDef
extends Resource
## Định nghĩa 1 skill dùng trong BattleSim (data-driven, dùng chung hero + boss).
## Basic-attack cũng là 1 SkillDef (power_mult=1, cooldown=nhịp đánh). Boss skill thêm
## cast_time/warning/interrupt/select_rule/weak_point (COMBAT.md, BOSS.md). KHÔNG hardcode.

@export var id: StringName = &""
@export var display_name: String = ""
@export var kind: int = Enums.SkillKind.ACTIVE            # PASSIVE/ACTIVE/ULTIMATE
@export var skill_type: int = Enums.SkillType.DAMAGE      # DAMAGE/HEAL/SHIELD/CC/SUMMON...
@export var target_mode: int = Enums.SkillTarget.SINGLE_LOWEST_HP

# --- công thức ---
@export var power_mult: float = 1.0                        # nhân với attack (damage/heal)
@export var cooldown_sec: float = 1.0
@export var flat_amount: float = 0.0                       # cộng thẳng (shield/heal cố định)

# --- boss / cast ---
@export var cast_time_sec: float = 0.0                     # >0 mới interrupt được
@export var interruptible: bool = true
@export var warning_sec: float = 0.0                       # banner cảnh báo ultimate (>0 mới báo)
@export var select_rule: int = Enums.SkillSelectRule.LOWEST_CD
@export var threat_gen: float = 1.0                        # đóng góp aggro khi cast

# --- CC / weak-point / break ---
@export var cc_type: int = Enums.CcType.NONE
@export var cc_duration_sec: float = 0.0
@export var weak_point_id: StringName = &""                # trúng weak-point boss -> bonus dmg
@export var break_damage: float = 0.0                      # cộng vào break gauge boss khi trúng
@export var summon_group_id: StringName = &""              # skill SUMMON gọi nhóm minion nào

func is_offensive() -> bool:
	return skill_type == Enums.SkillType.DAMAGE

func needs_target() -> bool:
	return target_mode != Enums.SkillTarget.SELF
