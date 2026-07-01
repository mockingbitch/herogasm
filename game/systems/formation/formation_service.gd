class_name FormationService
extends RefCounted
## Áp đội hình lên đội SimCombatant (PURE, deterministic). Gán slot/row + buff vị trí.
## Dùng chung stage & arena. front (y==0) +def; back (y>0) +atk/tốc. Buff = nhân stat.

## Áp đội hình cho team (theo thứ tự). Buff nhân vào attack/defense/max_hp/speed.
static func apply(team: Array, fdef: FormationDef) -> void:
	if fdef == null:
		return
	for i in team.size():
		var c: SimCombatant = team[i]
		c.slot = i
		c.row = fdef.row_of(i)
		var buff: Dictionary = fdef.front_buff if c.row == 0 else fdef.back_buff
		_apply_buff(c, buff)

static func _apply_buff(c: SimCombatant, buff: Dictionary) -> void:
	for k in buff:
		var pct := float(buff[k])
		match str(k):
			"attack": c.attack = maxi(1, int(round(c.attack * (1.0 + pct))))
			"defense": c.defense = int(round(c.defense * (1.0 + pct)))
			"max_hp":
				c.max_hp = maxi(1, int(round(c.max_hp * (1.0 + pct))))
				c.hp = mini(c.hp, c.max_hp) if c.hp < c.max_hp else c.max_hp
			"speed": c.attack_interval = clampf(c.attack_interval / (1.0 + pct), 0.1, 3.0)
			"resist": c.resist = clampf(c.resist + pct, 0.0, 0.9)
	# back-row +range% (hook target_bias) — SIM hiện dùng buff tốc/atk là đủ readable

## Validate: slot không trùng toạ độ (rules: validate slot không trùng).
static func is_valid(fdef: FormationDef) -> bool:
	var seen := {}
	for s in fdef.slots:
		var key := "%d_%d" % [s.x, s.y]
		if seen.has(key):
			return false
		seen[key] = true
	return true
