extends Node
## ExpeditionService (autoload) — phái hero đi zone theo timer idle (fire-and-forget).
## Resolve = Battle Engine headless TẤT ĐỊNH (seed lưu sẵn), IDEMPOTENT (cờ resolved),
## fire khi tick()/resume. Offline reward ≤80% (IDLE_REWARD_FACTOR). KHÔNG permadeath.
## PlayerProfile là chủ save duy nhất (service export/import qua world block).

const IDLE_REWARD_FACTOR := 0.7           # ≤0.8 (economy.md khuyến 60~75%)
const SPEEDUP_SEC_PER_GEM := 60.0
const TICK_INTERVAL := 5.0

var _active: Array[ExpeditionState] = []
var _seq: int = 0

func _ready() -> void:
	# PlayerProfile._ready chạy trước (autoload order) -> world_state sẵn sàng.
	import_world(PlayerProfile.world_state())
	TimeService.register_slice(tick, TICK_INTERVAL)

# --- start ----------------------------------------------------------------
func is_on_expedition(hero_id: String) -> bool:
	for e in _active:
		if e.hero_id == hero_id and not e.resolved:
			return true
	return false

func can_start(hero_id: String, zone_id: String) -> Dictionary:
	var z: ZoneDef = Database.get_zone_def(zone_id)
	if z == null:
		return {"ok": false, "reason": "no_zone"}
	if not PlayerProfile.is_zone_unlocked(zone_id):
		return {"ok": false, "reason": "locked"}
	var h: HeroInstance = PlayerProfile.get_hero(hero_id)
	if h == null:
		return {"ok": false, "reason": "no_hero"}
	if h.is_ko:
		return {"ok": false, "reason": "ko"}
	if is_on_expedition(hero_id):
		return {"ok": false, "reason": "busy"}
	if PlayerProfile.energy < z.energy_cost:
		return {"ok": false, "reason": "energy"}
	return {"ok": true, "reason": ""}

func start(hero_id: String, zone_id: String) -> ExpeditionState:
	if not can_start(hero_id, zone_id)["ok"]:
		return null
	var z: ZoneDef = Database.get_zone_def(zone_id)
	PlayerProfile.spend_energy(z.energy_cost)
	var e := ExpeditionState.new()
	e.id = "exp_%d" % _seq
	_seq += 1
	e.hero_id = hero_id
	e.zone_id = zone_id
	e.start_epoch = TimeService.now_unix()
	e.end_epoch = e.start_epoch + z.duration_sec
	e.seed = RandomService.randi()
	_active.append(e)
	EventBus.expedition_started.emit(e.id)
	Telemetry.log_event("Expedition", "expedition_started", {"hero": hero_id, "zone": zone_id})
	PlayerProfile.save()
	return e

# --- resolve (idempotent, tất định) ---------------------------------------
func resolve(e: ExpeditionState, offline: bool = false) -> Dictionary:
	if e.resolved:
		return _summary(e)
	var h: HeroInstance = PlayerProfile.get_hero(e.hero_id)
	var z: ZoneDef = Database.get_zone_def(e.zone_id)
	if h == null or z == null:
		e.resolved = true
		e.outcome = "ko"
		return _summary(e)
	# RNG cục bộ seed từ e.seed -> KHÔNG đụng global RandomService (tái lập offline==online).
	var rng := RandomNumberGenerator.new()
	rng.seed = e.seed
	h.team_context = PlayerProfile.team_context()   # synergy đội áp vào expedition
	var team_a: Array = [BattleUnit.from_hero(h, 0)]
	var team_b: Array = []
	for i in maxi(1, z.enemy_count):
		var eid: String = z.monster_pool[rng.randi() % maxi(1, z.monster_pool.size())]
		var ed: EnemyData = Database.get_enemy(eid)
		if ed != null:
			team_b.append(BattleUnit.from_enemy(ed, 1, "%s_e%d" % [e.id, i]))
	var res := BattleEngine.simulate(team_a, team_b, e.seed)
	var hp_after := int(res.hero_hp_after.get(e.hero_id, 0))
	h.current_hp = maxi(hp_after, 0)

	if res.hero_won() and h.current_hp > 0:
		var hp_pct := float(hp_after) / float(maxi(1, h.eff_max_hp()))
		e.result_stars = z.run_stars(hp_pct)
		var gold := rng.randi_range(z.reward_gold_min, z.reward_gold_max)
		var xp := z.reward_xp
		if offline:
			gold = int(gold * IDLE_REWARD_FACTOR)
			xp = int(xp * IDLE_REWARD_FACTOR)
		PlayerProfile.add_gold(gold)
		PlayerProfile.grant_xp(e.hero_id, xp)
		for d in z.reward_drops:
			if rng.randf() < float(d.get("chance", 0.0)):
				PlayerProfile.add_item(str(d.get("id", "")))
		PlayerProfile.record_zone_clear(e.zone_id)
		e.outcome = "win"
	else:
		h.current_hp = 0
		h.is_ko = true
		h.apply_injury(1, TimeService.now_unix())   # thương nhẹ, hồi được — KHÔNG permadeath
		PlayerProfile.knock_out(e.hero_id)
		e.outcome = "ko"
		e.result_stars = 0

	h.set_fatigue(h.fatigue + h._cv().fatigue_per_expedition)
	e.offline = offline
	e.resolved = true                                # đặt CUỐI -> idempotent
	Telemetry.log_event("Expedition", "expedition_resolved", {"zone": e.zone_id, "outcome": e.outcome, "stars": e.result_stars, "offline": offline})
	EventBus.expedition_resolved.emit(_summary(e))
	return _summary(e)

func tick() -> int:
	var now := TimeService.now_unix()
	var n := 0
	for e in _active:
		if not e.resolved and e.end_epoch <= now:
			resolve(e, false)
			n += 1
	_prune()
	if n > 0:
		PlayerProfile.save()
	return n

func speedup(exp_id: String, gems: int) -> bool:
	var e := _find(exp_id)
	if e == null or e.resolved or gems < 1 or PlayerProfile.gems < gems:
		return false
	PlayerProfile.add_gems(-gems)
	e.end_epoch = maxf(TimeService.now_unix(), e.end_epoch - float(gems) * SPEEDUP_SEC_PER_GEM)
	if e.end_epoch <= TimeService.now_unix():
		resolve(e, false)
	PlayerProfile.save()
	return true

## Resolve mọi expedition đã xong trong lúc offline (thứ tự ổn định, reward ≤80%).
func compute_offline(elapsed: float) -> Dictionary:
	var now := TimeService.now_unix()
	var due: Array = _active.filter(func(e): return not e.resolved and e.end_epoch <= now)
	due.sort_custom(func(a, b): return a.end_epoch < b.end_epoch or (a.end_epoch == b.end_epoch and a.id < b.id))
	var summaries: Array = []
	for e in due:
		summaries.append(resolve(e, true))
	_prune()
	var batch := {"count": summaries.size(), "expeditions": summaries}
	if summaries.size() > 0:
		EventBus.expeditions_batch_resolved.emit(batch)
	return batch

# --- save bridge (PlayerProfile là chủ save) ------------------------------
func export_world() -> Dictionary:
	var arr: Array = []
	for e in _active:
		if not e.resolved:
			arr.append(e.to_dict())
	return {"expeditions": arr, "exp_seq": _seq}

func import_world(d: Dictionary) -> void:
	_active.clear()
	_seq = int(d.get("exp_seq", 0))
	var arr = d.get("expeditions", [])
	if typeof(arr) == TYPE_ARRAY:
		for x in arr:
			if typeof(x) == TYPE_DICTIONARY:
				var e := ExpeditionState.from_dict(x)
				if not e.resolved:
					_active.append(e)

# --- helpers --------------------------------------------------------------
func active_count() -> int:
	return _active.size()

func active() -> Array:
	return _active

func remaining(e: ExpeditionState) -> float:
	return maxf(0.0, e.end_epoch - TimeService.now_unix())

## Tìm 1 hero rảnh (không đi expedition, không KO) để phái.
func first_free_hero() -> String:
	for id in PlayerProfile.hero_ids:
		var h: HeroInstance = PlayerProfile.get_hero(id)
		if h != null and not h.is_ko and not is_on_expedition(id):
			return id
	return ""

func _find(exp_id: String) -> ExpeditionState:
	for e in _active:
		if e.id == exp_id:
			return e
	return null

func _summary(e: ExpeditionState) -> Dictionary:
	return {"id": e.id, "hero_id": e.hero_id, "zone_id": e.zone_id,
		"outcome": e.outcome, "stars": e.result_stars, "offline": e.offline}

func _prune() -> void:
	_active = _active.filter(func(e): return not e.resolved)
