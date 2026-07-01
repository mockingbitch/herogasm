class_name SkillRuntime
extends RefCounted
## Trạng thái runtime của 1 skill trên 1 combatant trong BattleSim (cooldown/cast).
## THUẦN dữ liệu — reset mỗi trận, không ref Node. Cast do BattleSim điều phối.

var def: SkillDef
var cooldown: float = 0.0            # thời gian còn tới khi sẵn sàng (giây)

func _init(d: SkillDef = null) -> void:
	def = d

func ready_now() -> bool:
	return cooldown <= 0.0

func tick_cd(dt: float) -> void:
	if cooldown > 0.0:
		cooldown = maxf(0.0, cooldown - dt)

func trigger() -> void:
	cooldown = def.cooldown_sec
