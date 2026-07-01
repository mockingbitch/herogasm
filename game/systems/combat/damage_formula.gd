class_name DamageFormula
extends RefCounted
## Công thức sát thương PLACEHOLDER (P0). Mềm hoá defense + nhân chí mạng.
## Tất định khi cho trước `rng` (seed cố định trong test) — nền cho Battle Engine P1.
## Pipeline đầy đủ (Resistance → Shield → HP, penetration, damage types) làm ở P1.

## attack/defense: chỉ số hiệu dụng. cc: crit chance 0..1. cd: crit multiplier (>=1).
## k: hằng số mềm hoá defense (CombatConstants.def_k). Trả {"damage": int, "crit": bool}.
static func compute(attack: int, defense: int, cc: float, cd: float,
		rng: RandomNumberGenerator, k: float = 100.0) -> Dictionary:
	var base := float(attack) * k / (k + maxf(0.0, float(defense)))
	var is_crit := rng.randf() < clampf(cc, 0.0, 1.0)
	var dmg := base * (cd if is_crit else 1.0)
	return {"damage": int(round(dmg)), "crit": is_crit}
