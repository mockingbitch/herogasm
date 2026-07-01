extends RefCounted
## Unit — FormationService: buff vị trí (front +def, back +atk) + validate slot trùng.

static func _c(id: String) -> SimCombatant:
	var c := SimCombatant.new()
	c.id = id; c.max_hp = 1000; c.hp = 1000; c.attack = 100; c.defense = 10; c.attack_interval = 1.0
	return c

static func run(t) -> void:
	var bal: FormationDef = Database.get_formation_def("balanced_3")
	var team := [_c("a"), _c("b"), _c("c")]
	FormationService.apply(team, bal)
	# slot 0 = front (y==0) -> +def25% ; slot 1,2 = back -> +atk12%
	t.eq(team[0].row, 0, "Formation_Slot0Front")
	t.eq(team[0].defense, 13, "Formation_FrontDefenseBuff")     # round(10*1.25)
	t.eq(team[1].row, 1, "Formation_Slot1Back")
	t.eq(team[1].attack, 112, "Formation_BackAttackBuff")       # round(100*1.12)
	t.truthy(team[1].attack_interval < 1.0, "Formation_BackSpeedBuff")

	# validate: slot trùng toạ độ -> invalid
	t.truthy(FormationService.is_valid(bal), "Formation_ValidUnique")
	var bad := FormationDef.new()
	bad.slots = [Vector2i(0, 0), Vector2i(0, 0)]
	t.eq(FormationService.is_valid(bad), false, "Formation_InvalidDuplicate")
