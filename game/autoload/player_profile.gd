extends Node
## Hồ sơ TÀI KHOẢN (bền vững) — thay Profile cũ. Giữ ví + roster hero + kho chung town.
## Chỉ số per-hero nằm trong HeroInstance; PlayerProfile điều phối economy/save/emit.

const CONSTANTS_PATH := "res://data/combat_constants.tres"
const MAX_ENERGY := 120
const ENERGY_REGEN_SEC := 30.0                     # +1 energy mỗi 30s
const MAX_OFFLINE_SEC := 8 * 3600.0                # trần offline 8h (chống đổi giờ)
const OFFLINE_GOLD_PER_SEC := 0.05                 # ~3 gold/phút/hero (placeholder)
const OFFLINE_XP_PER_SEC := 0.03

var gold: int = 0
var gems: int = 0                                  # tiền cứng (gacha P3)
var energy: int = MAX_ENERGY
var max_energy: int = MAX_ENERGY
var last_energy_ts: float = 0.0
var offline_ts: float = 0.0                        # mốc thời gian lần lưu cuối (offline calc)
var last_offline_reward: Dictionary = {}
var hero_ids: Array[String] = []                   # thứ tự roster
var heroes: Dictionary = {}                        # hero_id -> HeroInstance
var consumables: Dictionary = {}                   # id -> count (kho chung town)
var materials: Dictionary = {}                     # id -> count (kho chung town)
var unlocks: Dictionary = {}                       # cờ mở khoá + guild bonus (energy_cap_bonus/roster_cap_bonus)
var cleared_stars: Dictionary = {}                 # zone_id -> clear_count (gating world map)

const CONDITIONS_PATH := "res://data/hero_condition_curves.tres"
var _constants: CombatConstants
var _conditions: HeroConditionCurves
var _pending_world: Dictionary = {}                # world block chờ ExpeditionService import
var _hero_seq: int = 0                             # sinh hero_id duy nhất

func _ready() -> void:
	_constants = load(CONSTANTS_PATH) as CombatConstants
	if _constants == null:
		_constants = CombatConstants.new()
	_conditions = load(CONDITIONS_PATH) as HeroConditionCurves
	if _conditions == null:
		_conditions = HeroConditionCurves.new()
	var data := SaveManager.load_game()
	if data.is_empty():
		new_game()
	else:
		from_dict(data)
		_apply_offline_progress()
	_regen_energy()
	TimeService.register_slice(_regen_energy, ENERGY_REGEN_SEC)
	_emit_all()
	Telemetry.log_event("Player", "game_start", {"heroes": hero_ids.size(), "gold": gold})

func new_game() -> void:
	gold = 0
	gems = 0
	energy = max_energy
	last_energy_ts = TimeService.now_unix()
	hero_ids = []
	heroes = {}
	consumables = {}
	materials = {}
	unlocks = {}
	_hero_seq = 0
	# Roster khởi tạo từ HeroDef (data-driven).
	for def_id in Database.hero_def_ids():
		spawn_hero(def_id)
	add_consumable("health_potion", 2)
	Telemetry.log_event("Player", "new_game", {"heroes": hero_ids.size()})
	save()

func reset_progress() -> void:
	SaveManager.delete_save()
	new_game()
	_emit_all()

# --- roster ---------------------------------------------------------------
func spawn_hero(def_id: String) -> HeroInstance:
	var h := HeroInstance.new()
	h.hero_id = "hero_%d" % _hero_seq
	_hero_seq += 1
	h.hero_def_id = def_id
	h.set_constants(_constants)
	h.set_curves(_conditions)
	_apply_def(h)
	# Trang bị khởi đầu từ def (không affix).
	var def: HeroDef = Database.get_hero_def(def_id)
	if def != null and def.start_weapon != "":
		h.equipment["weapon"] = HeroInstance.make_instance(def.start_weapon)
	h.reset_hp()
	heroes[h.hero_id] = h
	hero_ids.append(h.hero_id)
	EventBus.hero_spawned.emit(h.hero_id)
	return h

## Áp thuộc tính data-driven từ HeroDef (display_name + ai_weights). Gọi khi spawn & load.
func _apply_def(h: HeroInstance) -> void:
	var def: HeroDef = Database.get_hero_def(h.hero_def_id)
	if def == null:
		return
	if h.display_name == "":
		h.display_name = def.display_name
	h.ai_weights = def.ai_weights

func get_hero(id: String) -> HeroInstance:
	return heroes.get(id)

func primary_hero() -> HeroInstance:
	if hero_ids.is_empty():
		return null
	return heroes.get(hero_ids[0])

func knock_out(id: String) -> void:
	var h: HeroInstance = get_hero(id)
	if h == null or h.is_ko:
		return
	h.current_hp = 0
	h.is_ko = true
	EventBus.hero_knocked_out.emit(id)

# --- ví -------------------------------------------------------------------
func add_gold(amount: int) -> void:
	gold = maxi(gold + amount, 0)
	EventBus.gold_changed.emit(gold)

func add_gems(amount: int) -> void:
	gems = maxi(gems + amount, 0)
	EventBus.gems_changed.emit(gems)

# --- energy (regen theo thời gian) ----------------------------------------
func add_energy(amount: int) -> void:
	energy = clampi(energy + amount, 0, max_energy)
	EventBus.energy_changed.emit(energy, max_energy)

func spend_energy(amount: int) -> bool:
	if energy < amount:
		return false
	energy -= amount
	EventBus.energy_changed.emit(energy, max_energy)
	return true

## Cộng energy dựa trên thời gian đã trôi từ last_energy_ts (regen offline luôn đúng).
func _regen_energy() -> void:
	var now := TimeService.now_unix()
	if last_energy_ts <= 0.0:
		last_energy_ts = now
		return
	var elapsed := now - last_energy_ts
	if elapsed < ENERGY_REGEN_SEC:
		return
	var gained := int(elapsed / ENERGY_REGEN_SEC)
	if gained > 0 and energy < max_energy:
		energy = clampi(energy + gained, 0, max_energy)
		EventBus.energy_changed.emit(energy, max_energy)
	last_energy_ts = now - fmod(elapsed, ENERGY_REGEN_SEC)

# --- offline progression (clamp trần, chống đổi giờ) ----------------------
func _apply_offline_progress() -> void:
	var now := TimeService.now_unix()
	if offline_ts <= 0.0:
		offline_ts = now
		return
	var elapsed: float = clampf(now - offline_ts, 0.0, MAX_OFFLINE_SEC)
	offline_ts = now
	if elapsed < 60.0 or hero_ids.is_empty():
		return
	var n := hero_ids.size()
	# Trần idle ≤80% qua EconomyService (economy.md).
	var gold_gain := int(EconomyService.clamp_idle(elapsed * OFFLINE_GOLD_PER_SEC * n))
	var xp_each := int(EconomyService.clamp_idle(elapsed * OFFLINE_XP_PER_SEC))
	add_gold(gold_gain)
	for id in hero_ids:
		grant_xp(id, xp_each)
	# Resolve expedition đã xong trong lúc offline (reward tự chặn ≤80% trong service).
	var exp_count := 0
	if has_node("/root/ExpeditionService"):
		var batch: Dictionary = ExpeditionService.compute_offline(elapsed)
		exp_count = int(batch.get("count", 0))
	last_offline_reward = {"seconds": int(elapsed), "gold": gold_gain, "xp_each": xp_each, "expeditions": exp_count}
	EventBus.offline_reward.emit(last_offline_reward)
	Telemetry.log_event("Economy", "offline_reward", last_offline_reward)

# --- kho chung ------------------------------------------------------------
func add_consumable(id: String, n: int = 1) -> void:
	consumables[id] = int(consumables.get(id, 0)) + n
	EventBus.consumables_changed.emit()

func add_material(id: String, n: int = 1) -> void:
	materials[id] = int(materials.get(id, 0)) + n
	EventBus.inventory_changed.emit()

func potion_count() -> int:
	return int(consumables.get("health_potion", 0))

func use_potion() -> int:
	var id := "health_potion"
	if int(consumables.get(id, 0)) <= 0:
		return 0
	consumables[id] = int(consumables[id]) - 1
	EventBus.consumables_changed.emit()
	var data: ItemData = Database.get_item(id)
	return data.heal_amount if data else 0

## Định tuyến 1 item vào tài khoản/hero (mua hoặc nhặt). Gear -> vào inventory hero chính.
func add_item(id: String) -> void:
	var data: ItemData = Database.get_item(id)
	if data == null:
		return
	match data.type:
		ItemData.Type.CONSUMABLE:
			add_consumable(id, 1)
		ItemData.Type.MATERIAL:
			add_material(id, 1)
		_:
			var h: HeroInstance = primary_hero()
			if h != null:
				h.inventory.append(h.roll_instance(id))
				EventBus.inventory_changed.emit()
	EventBus.item_picked_up.emit(id)

# --- shop / forge (math kinh tế; gold ở account) --------------------------
func buy_price(id: String) -> int:
	var data: ItemData = Database.get_item(id)
	return data.sell_price * _constants.buy_markup if data else 0

func buy(id: String) -> bool:
	var price := buy_price(id)
	if price <= 0 or gold < price:
		return false
	add_gold(-price)
	add_item(id)
	save()
	return true

func upgrade_hero_gear(hero_id: String, slot: String) -> bool:
	var h: HeroInstance = get_hero(hero_id)
	if h == null:
		return false
	var cost := h.upgrade_cost(slot)
	if cost <= 0 or gold < cost:
		return false
	add_gold(-cost)
	h.upgrade_gear(slot)
	EventBus.equipment_changed.emit()
	save()
	return true

func sell_hero_gear(hero_id: String, inv_index: int) -> bool:
	var h: HeroInstance = get_hero(hero_id)
	if h == null or inv_index < 0 or inv_index >= h.inventory.size():
		return false
	var inst: Dictionary = h.inventory[inv_index]
	var data: ItemData = Database.get_item(inst["id"])
	var value := 0
	if data:
		value = int(round(data.sell_price * (1.0 + 0.5 * int(inst["level"]))))
		value += inst.get("affixes", []).size() * 3
	h.inventory.remove_at(inv_index)
	add_gold(value)
	EventBus.inventory_changed.emit()
	save()
	return true

func sell_all_materials() -> int:
	var total := 0
	for id in materials.keys():
		var data: ItemData = Database.get_item(id)
		if data:
			total += data.sell_price * int(materials[id])
	materials.clear()
	add_gold(total)
	EventBus.inventory_changed.emit()
	save()
	return total

## Cộng xp cho 1 hero; emit xp/level.
func grant_xp(hero_id: String, amount: int) -> void:
	var h: HeroInstance = get_hero(hero_id)
	if h == null:
		return
	var gained := h.gain_xp(amount)
	if gained > 0:
		EventBus.level_changed.emit(h.level)
	EventBus.xp_changed.emit(h.level, h.xp, h.xp_to_next())

# --- world map / gating ---------------------------------------------------
func zone_clears(zone_id: String) -> int:
	return int(cleared_stars.get(zone_id, 0))

func zone_stars(zone_id: String) -> int:
	var z: ZoneDef = Database.get_zone_def(zone_id)
	return z.star_for(zone_clears(zone_id)) if z != null else 0

func record_zone_clear(zone_id: String) -> void:
	cleared_stars[zone_id] = zone_clears(zone_id) + 1
	EventBus.zone_cleared.emit(zone_id, zone_stars(zone_id))

func roster_max_level() -> int:
	var mx := 0
	for id in hero_ids:
		var h: HeroInstance = heroes.get(id)
		if h != null:
			mx = maxi(mx, h.level)
	return mx

func is_zone_unlocked(zone_id: String) -> bool:
	return WorldMap.is_zone_unlocked(zone_id, self)

## Guild bonus: recompute (maxi) — KHÔNG cộng dồn khi reload/gọi lại.
func apply_guild_bonuses(energy_bonus: int, roster_bonus: int) -> void:
	unlocks["energy_cap_bonus"] = maxi(int(unlocks.get("energy_cap_bonus", 0)), energy_bonus)
	unlocks["roster_cap_bonus"] = maxi(int(unlocks.get("roster_cap_bonus", 0)), roster_bonus)
	unlocks["guild_level"] = maxi(int(unlocks.get("guild_level", 0)), 1)
	max_energy = MAX_ENERGY + int(unlocks["energy_cap_bonus"])
	EventBus.energy_changed.emit(energy, max_energy)

# --- save / load ----------------------------------------------------------
func save() -> void:
	offline_ts = TimeService.now_unix()   # mốc cho offline khi mở lại
	SaveManager.save_game(to_dict())

func to_dict() -> Dictionary:
	var hd: Dictionary = {}
	for id in heroes.keys():
		hd[id] = (heroes[id] as HeroInstance).to_dict()
	return {
		"player": {
			"gold": gold,
			"gems": gems,
			"energy": energy,
			"max_energy": max_energy,
			"last_energy_ts": last_energy_ts,
			"offline_ts": offline_ts,
			"consumables": consumables,
			"materials": materials,
			"unlocks": unlocks,
			"cleared_stars": cleared_stars,
		},
		"hero_ids": hero_ids,
		"heroes": hd,
		"world": _world_dict(),
	}

## World block do ExpeditionService sở hữu; giữ _pending_world nếu service chưa sẵn sàng.
func _world_dict() -> Dictionary:
	if has_node("/root/ExpeditionService"):
		return ExpeditionService.export_world()
	return _pending_world

func world_state() -> Dictionary:
	return _pending_world

func from_dict(d: Dictionary) -> void:
	var p = d.get("player", {})
	if typeof(p) != TYPE_DICTIONARY:
		p = {}
	gold = maxi(int(p.get("gold", 0)), 0)
	gems = maxi(int(p.get("gems", 0)), 0)
	max_energy = maxi(int(p.get("max_energy", MAX_ENERGY)), 1)
	energy = clampi(int(p.get("energy", max_energy)), 0, max_energy)
	last_energy_ts = float(p.get("last_energy_ts", 0.0))
	offline_ts = float(p.get("offline_ts", 0.0))
	consumables = _norm_counts(p.get("consumables", {}))
	materials = _norm_counts(p.get("materials", {}))
	unlocks = p.get("unlocks", {}) if typeof(p.get("unlocks")) == TYPE_DICTIONARY else {}
	cleared_stars = _norm_counts(p.get("cleared_stars", {}))
	max_energy = MAX_ENERGY + int(unlocks.get("energy_cap_bonus", 0))
	energy = clampi(energy, 0, max_energy)

	hero_ids = []
	for id in d.get("hero_ids", []):
		hero_ids.append(str(id))
	heroes = {}
	var hd = d.get("heroes", {})
	if typeof(hd) == TYPE_DICTIONARY:
		if hero_ids.is_empty():
			for k in hd.keys():
				hero_ids.append(str(k))
		for id in hero_ids:
			if hd.has(id) and typeof(hd[id]) == TYPE_DICTIONARY:
				var h := HeroInstance.from_dict(hd[id])
				h.hero_id = id
				h.set_constants(_constants)
				h.set_curves(_conditions)
				_apply_def(h)
				heroes[id] = h
	_hero_seq = _max_hero_index() + 1
	_pending_world = d.get("world", {}) if typeof(d.get("world")) == TYPE_DICTIONARY else {}

func _max_hero_index() -> int:
	var mx := -1
	for id in hero_ids:
		var parts := str(id).split("_")
		if parts.size() == 2 and parts[1].is_valid_int():
			mx = maxi(mx, int(parts[1]))
	return mx

func _norm_counts(d) -> Dictionary:
	var out: Dictionary = {}
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for k in d.keys():
		out[str(k)] = int(d[k])
	return out

func _emit_all() -> void:
	EventBus.gold_changed.emit(gold)
	EventBus.gems_changed.emit(gems)
	EventBus.energy_changed.emit(energy, max_energy)
	EventBus.consumables_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.equipment_changed.emit()
	var h: HeroInstance = primary_hero()
	if h != null:
		EventBus.xp_changed.emit(h.level, h.xp, h.xp_to_next())
