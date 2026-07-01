class_name SkillFactory
extends RefCounted
## Lò tạo SkillDef runtime (basic-attack + helper dựng boss skill trong Database).
## Tách khỏi content để tái dùng; boss skill thật khai báo data-driven ở Database._build_p4.

static func basic_attack(interval: float) -> SkillDef:
	var s := SkillDef.new()
	s.id = &"basic_attack"
	s.display_name = "Đánh Thường"
	s.kind = Enums.SkillKind.ACTIVE
	s.skill_type = Enums.SkillType.DAMAGE
	s.target_mode = Enums.SkillTarget.SINGLE_LOWEST_HP
	s.power_mult = 1.0
	s.cooldown_sec = maxf(0.1, interval)
	s.threat_gen = 1.0
	s.break_damage = 1.0                 # mỗi đòn thường cộng 1 điểm break vào boss
	return s

## Helper dựng boss skill gọn (dùng trong Database). Trả SkillDef đã set field boss.
static func boss_skill(id: String, nm: String, stype: int, mult: float, cd: float,
		target: int = Enums.SkillTarget.SINGLE_LOWEST_HP, cast: float = 0.0,
		warning: float = 0.0, select: int = Enums.SkillSelectRule.LOWEST_CD) -> SkillDef:
	var s := SkillDef.new()
	s.id = StringName(id)
	s.display_name = nm
	s.kind = Enums.SkillKind.ACTIVE
	s.skill_type = stype
	s.target_mode = target
	s.power_mult = mult
	s.cooldown_sec = cd
	s.cast_time_sec = cast
	s.warning_sec = warning
	s.select_rule = select
	s.interruptible = cast > 0.0
	return s
