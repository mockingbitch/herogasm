class_name Hero
extends Node2D
## Hero tự trị (living-world). Brain (Utility AI) chạy qua AIScheduler (KHÔNG _process);
## movement/combat thực thi ở _process. Combat giải bằng Battle Engine (mỗi encounter 1 sim
## tất định). KO thay vì permadeath: hp=0 -> về Nhà Trọ hồi. Data-driven từ HeroInstance/HeroDef.

enum St { IDLE, TRAVEL_FIELD, HUNT, GO_INN, REST, GO_MARKET, BUY, GO_BLACKSMITH, REPAIR, GO_ALCHEMY, HEAL, GO_TRAIN, TRAIN }

const MOVE_SPEED := 80.0
const HUNT_RANGE := 18.0
const ENGAGE_ENERGY := 1
const DUR_LOSS_PER_FIGHT := 3.0
const STAM_DECAY_HUNT := 1.6
const STAM_DECAY_MOVE := 0.5

# Scheduler contract
var think_interval: float = 0.6
var _ai_accum: float = 0.0

var hero_id: String = ""
var home_pos: Vector2 = Vector2.ZERO
var field_center: Vector2 = Vector2(260, 0)
var spawner: MonsterSpawner
# Cổng dịch chuyển: nếu di chuyển vượt _gate_x -> nhảy tới điểm vào bên kia (không đi bộ khoảng cách town<->hunt)
var _gate_x: float = 0.0
var _town_ent: Vector2 = Vector2.ZERO
var _hunt_ent: Vector2 = Vector2.ZERO

var state: int = St.IDLE
var goal: String = "idle"
var reason: String = ""
var destination: Vector2 = Vector2.ZERO
var target_monster: Monster

var _label: Label
var _spr: AnimatedSprite2D
var _prev_pos: Vector2 = Vector2.ZERO
var _evaluator := HeroGoalEvaluator.new()

func setup(id: String, home: Vector2, field: Vector2, spawner_: MonsterSpawner, gate_x: float = 0.0, town_ent: Vector2 = Vector2.ZERO, hunt_ent: Vector2 = Vector2.ZERO) -> void:
	hero_id = id
	home_pos = home
	field_center = field
	spawner = spawner_
	_gate_x = gate_x
	_town_ent = town_ent
	_hunt_ent = hunt_ent
	position = home

func _ready() -> void:
	_build_visual()
	AIScheduler.register(self)

func _exit_tree() -> void:
	AIScheduler.unregister(self)

func hero() -> HeroInstance:
	return PlayerProfile.get_hero(hero_id)

# --- BRAIN: chấm điểm goal (qua scheduler) --------------------------------
func ai_tick() -> void:
	var h := hero()
	if h == null:
		return
	# hero đang đi expedition idle -> không tự field-hunt (orthogonal)
	if has_node("/root/ExpeditionService") and ExpeditionService.is_on_expedition(hero_id):
		return
	# thương tự lành khi tới hạn
	if h.injury_ready(TimeService.now_unix()):
		h.recover_injury()
	# KO -> luôn về Inn hồi
	if h.is_ko:
		if state != St.GO_INN and state != St.REST:
			goal = "rest"; reason = "KO"; _go_service("inn", St.GO_INN)
		return
	# đang thực thi hành động dịch vụ -> để hoàn tất, không đổi goal
	if state == St.REST or state == St.BUY or state == St.REPAIR or state == St.HEAL or state == St.TRAIN:
		return
	var ctx := _build_context(h)
	var d := _evaluator.evaluate(ctx, goal)
	goal = d["goal"]
	reason = d["reason"]
	match goal:
		"hunt":
			if state != St.HUNT and state != St.TRAVEL_FIELD:
				state = St.TRAVEL_FIELD
				destination = field_center
		"rest": _go_service("inn", St.GO_INN)
		"buy_potion": _go_service("market", St.GO_MARKET)
		"repair": _go_service("blacksmith", St.GO_BLACKSMITH)
		"heal_injury": _go_service("alchemy", St.GO_ALCHEMY)
		"train": _go_service("training", St.GO_TRAIN)
		_:
			state = St.IDLE
			destination = home_pos
	Telemetry.log_event("AI", "goal_selected", {"hero": hero_id, "goal": goal})

func _build_context(h: HeroInstance) -> DecisionContext:
	var c := DecisionContext.new()
	c.hp_pct = float(h.current_hp) / float(maxi(1, h.eff_max_hp()))
	c.stamina01 = h.stamina / 100.0
	c.durability01 = h.durability / 100.0
	c.potion_count = PlayerProfile.potion_count()
	c.gold = PlayerProfile.gold
	c.energy = PlayerProfile.energy
	c.inventory_count = h.inventory.size()
	c.is_ko = h.is_ko
	c.aggression = h.aggression()
	c.rest_threshold = h.rest_threshold()
	c.repair_threshold = h.repair_threshold()
	# P2: vòng đời
	c.fatigue01 = h.fatigue01()
	c.injury_level = h.injury_level
	c.injury_ready = h.injury_ready(TimeService.now_unix())
	c.mood01 = h.mood01()
	c.xp_pct = float(h.xp) / float(maxi(1, h.xp_to_next()))
	c.train_threshold = h.ai_weight_f("train_threshold", 0.85)
	c.mood_care = h.ai_weight_f("mood_care", 1.0)
	c.fatigue_rest_threshold = h._cv().fatigue_rest_threshold
	var mk := ServiceRegistry.find_nearest("market", position)
	c.potion_price = (mk["node"] as Building).potion_price() if mk.has("node") else 40
	var bs := ServiceRegistry.find_nearest("blacksmith", position)
	c.repair_cost = (bs["node"] as Building).repair_price() if bs.has("node") else 30
	var al := ServiceRegistry.find_nearest("alchemy", position)
	c.has_alchemy_service = al.has("node")
	c.heal_cost = (al["node"] as Building).heal_injury_price() if al.has("node") else 60
	var tr := ServiceRegistry.find_nearest("training", position)
	c.has_training_service = tr.has("node")
	c.train_cost = (tr["node"] as Building).train_price() if tr.has("node") else 25
	return c

func _go_service(type: String, st: int) -> void:
	var s := ServiceRegistry.find_nearest(type, position)
	if s.has("pos"):
		destination = s["pos"]
		state = st
	else:
		state = St.IDLE
		destination = home_pos

# --- EXECUTION: movement + hành động (per-frame, KHÔNG phải "thinking") ----
func _process(delta: float) -> void:
	var h := hero()
	if h == null:
		queue_free()
		return
	# Đang đi expedition idle -> park ở thành, không field-hunt.
	if has_node("/root/ExpeditionService") and ExpeditionService.is_on_expedition(hero_id):
		_move(home_pos, delta)
		_refresh_label(h)
		_update_anim()
		return
	match state:
		St.IDLE:
			_move(home_pos, delta)
		St.TRAVEL_FIELD:
			_decay_stamina(h, STAM_DECAY_MOVE, delta)
			h.set_fatigue(h.fatigue + h._cv().fatigue_decay_move * delta)
			if _move(field_center, delta):
				state = St.HUNT
		St.HUNT:
			_tick_hunt(h, delta)
		St.GO_INN, St.GO_MARKET, St.GO_BLACKSMITH, St.GO_ALCHEMY, St.GO_TRAIN:
			h.set_fatigue(h.fatigue + h._cv().fatigue_decay_move * delta)
			if _move(destination, delta):
				state = _arrive_state()
		St.REST:
			_tick_rest(h, delta)
		St.BUY:
			_do_buy(h)
		St.REPAIR:
			_do_repair(h)
		St.HEAL:
			_do_heal(h)
		St.TRAIN:
			_do_train(h)
	_refresh_label(h)
	_update_anim()

## Trạng thái hành động khi tới đích (theo state di chuyển hiện tại).
func _arrive_state() -> int:
	match state:
		St.GO_INN: return St.REST
		St.GO_MARKET: return St.BUY
		St.GO_BLACKSMITH: return St.REPAIR
		St.GO_ALCHEMY: return St.HEAL
		St.GO_TRAIN: return St.TRAIN
		_: return St.IDLE

func _tick_hunt(h: HeroInstance, delta: float) -> void:
	_decay_stamina(h, STAM_DECAY_HUNT, delta)
	h.set_fatigue(h.fatigue + h._cv().fatigue_decay_hunt * delta)
	if spawner == null:
		return
	if target_monster == null or not is_instance_valid(target_monster) or not target_monster.is_alive():
		target_monster = spawner.nearest_alive(position)
	if target_monster == null:
		_move(field_center, delta)
		return
	if _move(target_monster.global_position, delta, HUNT_RANGE):
		_engage(target_monster)

func _tick_rest(h: HeroInstance, delta: float) -> void:
	var inn := ServiceRegistry.find_nearest("inn", position)
	var rate: float = (inn["node"] as Building).heal_rate() if inn.has("node") else 30.0
	h.current_hp = mini(h.current_hp + int(ceil(rate * delta)), h.eff_max_hp())
	h.stamina = minf(h.stamina + 25.0 * delta, 100.0)
	h.set_fatigue(h.fatigue - h._cv().fatigue_recover_rest * delta)
	h.set_mood(h.mood + h._cv().mood_gain_rest * delta)
	if h.current_hp >= h.eff_max_hp() and h.stamina >= 100.0 and h.fatigue <= 5.0:
		if h.is_ko:
			h.is_ko = false
			EventBus.hero_recovered.emit(hero_id)
		state = St.IDLE
		goal = "idle"

func _do_buy(h: HeroInstance) -> void:
	# mua tới 3 potion nếu đủ gold
	var bought := 0
	while bought < 3 and PlayerProfile.buy("health_potion"):
		bought += 1
	state = St.IDLE
	goal = "idle"

func _do_repair(h: HeroInstance) -> void:
	var bs := ServiceRegistry.find_nearest("blacksmith", position)
	var price: int = (bs["node"] as Building).repair_price() if bs.has("node") else 30
	if PlayerProfile.gold >= price and h.durability < 100.0:
		PlayerProfile.add_gold(-price)
		h.durability = EconomyService.repair_full()
		Telemetry.log_event("Economy", "repair", {"hero": hero_id, "cost": price})
	state = St.IDLE
	goal = "idle"

func _do_heal(h: HeroInstance) -> void:
	var al := ServiceRegistry.find_nearest("alchemy", position)
	var price: int = (al["node"] as Building).heal_injury_price() if al.has("node") else 60
	if h.is_injured() and PlayerProfile.gold >= price:
		PlayerProfile.add_gold(-price)
		h.recover_injury()
		Telemetry.log_event("Economy", "heal_injury", {"hero": hero_id, "cost": price})
	state = St.IDLE
	goal = "idle"

func _do_train(h: HeroInstance) -> void:
	var tr := ServiceRegistry.find_nearest("training", position)
	var price: int = (tr["node"] as Building).train_price() if tr.has("node") else 25
	if PlayerProfile.gold >= price:
		PlayerProfile.add_gold(-price)
		PlayerProfile.grant_xp(hero_id, EconomyService.train_xp(30.0))   # ~1 buổi 30s quy đổi
		h.set_fatigue(h.fatigue + h._cv().train_fatigue_add)
		h.set_mood(h.mood + h._cv().mood_train_gain)
		Telemetry.log_event("Progression", "train", {"hero": hero_id, "cost": price})
	state = St.IDLE
	goal = "idle"

# --- COMBAT: 1 encounter = 1 sim Battle Engine tất định -------------------
func _engage(monster: Monster) -> void:
	var h := hero()
	if h == null or monster == null or not monster.is_alive():
		return
	# tự uống potion nếu HP thấp trước khi đánh
	if h.current_hp < int(0.4 * h.eff_max_hp()) and PlayerProfile.potion_count() > 0:
		var heal := PlayerProfile.use_potion()
		h.current_hp = mini(h.current_hp + heal, h.eff_max_hp())
		Telemetry.log_event("Combat", "potion_used", {"hero": hero_id})
	PlayerProfile.spend_energy(ENGAGE_ENERGY)

	h.team_context = PlayerProfile.team_context()   # synergy đội áp vào combat
	var hu := BattleUnit.from_hero(h, 0)
	var mu := BattleUnit.from_enemy(monster.data, 1, monster.uid)
	var seed_val := RandomService.randi()
	var res := BattleEngine.simulate([hu], [mu], seed_val)

	h.current_hp = int(res.hero_hp_after.get(hero_id, h.current_hp))
	h.durability = maxf(0.0, h.durability - DUR_LOSS_PER_FIGHT)
	_spawn_damage_numbers(res, monster)
	Telemetry.log_event("Combat", "fight", {"hero": hero_id, "won": res.hero_won(), "dur": res.duration})

	if res.hero_won() and h.current_hp > 0:
		h.set_mood(h.mood + h._cv().mood_gain_victory)
		_loot(monster.data, h)
		monster.die()
		target_monster = null
	else:
		# thua/KO -> không permadeath (bất tỉnh + thương nhẹ, hồi được)
		h.set_mood(h.mood - h._cv().mood_loss_defeat)
		h.apply_injury(1, TimeService.now_unix())
		h.current_hp = 0
		PlayerProfile.knock_out(hero_id)
		target_monster = null
		goal = "rest"
		_go_service("inn", St.GO_INN)
		PlayerProfile.save()

func _loot(enemy: EnemyData, h: HeroInstance) -> void:
	var gold := RandomService.randi_range(enemy.gold_drop_min, enemy.gold_drop_max)
	PlayerProfile.add_gold(gold)
	var before := h.level
	PlayerProfile.grant_xp(hero_id, enemy.xp_reward)
	for drop in enemy.drops:
		if RandomService.randf() < float(drop.get("chance", 0.0)):
			PlayerProfile.add_item(str(drop.get("id", "")))
	Telemetry.log_event("Economy", "loot_dropped", {"hero": hero_id, "gold": gold, "enemy": enemy.id})
	if h.level > before:
		PlayerProfile.save()   # save khi level up (save-system.md §Save Timing)

func _spawn_damage_numbers(res: BattleResult, monster: Monster) -> void:
	var shown := 0
	for ev in res.timeline:
		if shown >= 6:
			break
		if ev["type"] != "hit":
			continue
		var to_monster: bool = str(ev["tgt"]) == monster.uid
		var pos: Vector2 = monster.global_position if to_monster else global_position
		var col := Color(1, 0.9, 0.3) if bool(ev["crit"]) else (Color(1, 1, 1) if to_monster else Color(1, 0.5, 0.4))
		DamageNumber.spawn(get_parent(), pos + Vector2(0, -14), int(ev["value"]), col, bool(ev["crit"]))
		shown += 1

# --- helpers --------------------------------------------------------------
## Di chuyển về dest; trả true khi đã trong `arrive` khoảng cách.
func _move(dest: Vector2, delta: float, arrive: float = 4.0) -> bool:
	# Cổng dịch chuyển: đích ở bên kia ranh giới -> nhảy tới điểm vào (thay vì đi bộ)
	if _gate_x > 0.0 and (position.x - _gate_x) * (dest.x - _gate_x) < 0.0:
		position = _hunt_ent if dest.x > _gate_x else _town_ent
	if position.distance_to(dest) <= arrive:
		return true
	position = position.move_toward(dest, MOVE_SPEED * delta)
	return position.distance_to(dest) <= arrive

func _decay_stamina(h: HeroInstance, rate: float, delta: float) -> void:
	h.stamina = maxf(0.0, h.stamina - rate * delta)

func _build_visual() -> void:
	_add_shadow(self, 8.0)
	var base := "knight_m"
	var def: HeroDef = Database.get_hero_def(hero().hero_def_id) if hero() != null else null
	if def != null and def.sprite != "":
		base = def.sprite
	if base == "archer":                       # hero dùng sheet archer.png (frame lớn -> scale nhỏ)
		_spr = SpriteLib.build_archer()
		_spr.scale = Vector2(0.16, 0.16)
		_spr.position = Vector2(0, -17)
	else:
		_spr = SpriteLib.build(SpriteLib.defs_for(base, false))
		_spr.scale = Vector2(1.6, 1.6)
		_spr.position = Vector2(0, -10)
	_spr.play("idle")
	add_child(_spr)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 7)
	_label.position = Vector2(-14, -34)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_prev_pos = position

## Bóng đổ đơn giản (ellipse tối bán trong suốt) dưới chân — đọc silhouette trên nền.
static func _add_shadow(node: Node2D, rx: float) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := TAU * i / 10.0
		pts.append(Vector2(cos(a) * rx, sin(a) * rx * 0.4 + 2.0))
	var sh := Polygon2D.new()
	sh.polygon = pts
	sh.color = Color(0, 0, 0, 0.28)
	node.add_child(sh)

## Cập nhật animation idle/run + lật hướng theo di chuyển (gọi cuối _process).
func _update_anim() -> void:
	if _spr == null:
		return
	var delta_pos := position - _prev_pos
	if delta_pos.length() > 0.5:
		if _spr.animation != "run":
			_spr.play("run")
		if absf(delta_pos.x) > 0.05:
			_spr.flip_h = delta_pos.x < 0.0
	elif _spr.animation != "idle":
		_spr.play("idle")
	_prev_pos = position

func _refresh_label(h: HeroInstance) -> void:
	if _label == null:
		return
	var names: Array[String] = ["idle", "→field", "hunt", "→inn", "rest", "→mkt", "buy", "→smith", "repair", "→dược", "heal", "→luyện", "train"]
	var st_name: String = names[state] if state >= 0 and state < names.size() else "?"
	_label.text = "%s\n%s hp%d" % [h.display_name, st_name, h.current_hp]
