class_name BossRuntimeState
extends RefCounted
## Trạng thái RUNTIME của boss (KHÔNG phải .tres) — serialize vào save JSON (World Boss tuần).
## Boss "owns state" (multiplayer.md): 1 nguồn sự thật, không duplicate. Tách khỏi BossDef bất biến.

var boss_id: StringName = &""          # id sự kiện boss hiện hành (vd "wb_2026_w27")
var boss_def_id: StringName = &""      # trỏ BossDef
var current_hp: float = 0.0
var max_hp: float = 1.0
var current_phase_idx: int = 0
var break_value: float = 0.0
var enrage_active: bool = false
var spawn_tick: int = 0
var despawn_tick: int = 0
var event_state: int = Enums.BossEventState.ANNOUNCED

# --- window (Game Time) — World Boss cửa sổ tuần ---
var active_from_day: int = 0
var active_to_day: int = 0

# --- aggro + contribution (bounded) ---
var aggro_table: Dictionary = {}       # hero_id -> threat (clamp size)
var contribution: Dictionary = {}      # hero_id -> {damage, healing, tank_time}
var minions_alive: Array = []          # id minion còn sống trong trận
var reward_claimed: bool = false

const AGGRO_MAX_ENTRIES := 64          # aggro_table không phình vô hạn (rules/ai.md, perf)

func hp_pct() -> float:
	return current_hp / maxf(1.0, max_hp)

func add_contribution(hero_id: String, dmg: float, heal: float, tank_ticks: int) -> void:
	var e: Dictionary = contribution.get(hero_id, {"damage": 0.0, "healing": 0.0, "tank_time": 0})
	e["damage"] = float(e["damage"]) + dmg
	e["healing"] = float(e["healing"]) + heal
	e["tank_time"] = int(e["tank_time"]) + tank_ticks
	contribution[hero_id] = e

func add_threat(hero_id: String, amount: float) -> void:
	aggro_table[hero_id] = float(aggro_table.get(hero_id, 0.0)) + amount
	_bound_aggro()

## Giữ aggro_table trong giới hạn: bỏ entry threat thấp nhất khi vượt trần.
func _bound_aggro() -> void:
	if aggro_table.size() <= AGGRO_MAX_ENTRIES:
		return
	var lowest_key := ""
	var lowest := INF
	for k in aggro_table:
		if float(aggro_table[k]) < lowest:
			lowest = float(aggro_table[k]); lowest_key = k
	if lowest_key != "":
		aggro_table.erase(lowest_key)

## hero_id có threat cao nhất (tiebreak theo id -> tất định). "" nếu rỗng.
func top_threat_hero() -> String:
	var best := ""
	var best_v := -1.0
	for k in aggro_table:
		var v := float(aggro_table[k])
		if v > best_v or (v == best_v and (best == "" or k < best)):
			best_v = v; best = k
	return best

func to_dict() -> Dictionary:
	return {
		"boss_id": str(boss_id),
		"boss_def_id": str(boss_def_id),
		"current_hp": current_hp,
		"max_hp": max_hp,
		"current_phase_idx": current_phase_idx,
		"break_value": break_value,
		"enrage_active": enrage_active,
		"spawn_tick": spawn_tick,
		"despawn_tick": despawn_tick,
		"event_state": event_state,
		"active_from_day": active_from_day,
		"active_to_day": active_to_day,
		"aggro_table": aggro_table,
		"contribution": contribution,
		"minions_alive": minions_alive,
		"reward_claimed": reward_claimed,
	}

static func from_dict(d: Dictionary) -> BossRuntimeState:
	var s := BossRuntimeState.new()
	s.boss_id = StringName(str(d.get("boss_id", "")))
	s.boss_def_id = StringName(str(d.get("boss_def_id", "")))
	s.current_hp = float(d.get("current_hp", 0.0))
	s.max_hp = maxf(1.0, float(d.get("max_hp", 1.0)))
	s.current_phase_idx = int(d.get("current_phase_idx", 0))
	s.break_value = float(d.get("break_value", 0.0))
	s.enrage_active = bool(d.get("enrage_active", false))
	s.spawn_tick = int(d.get("spawn_tick", 0))
	s.despawn_tick = int(d.get("despawn_tick", 0))
	s.event_state = int(d.get("event_state", Enums.BossEventState.ANNOUNCED))
	s.active_from_day = int(d.get("active_from_day", 0))
	s.active_to_day = int(d.get("active_to_day", 0))
	s.aggro_table = d.get("aggro_table", {}) if typeof(d.get("aggro_table")) == TYPE_DICTIONARY else {}
	s.contribution = _norm_contrib(d.get("contribution", {}))
	s.minions_alive = d.get("minions_alive", []) if typeof(d.get("minions_alive")) == TYPE_ARRAY else []
	s.reward_claimed = bool(d.get("reward_claimed", false))
	return s

static func _norm_contrib(d) -> Dictionary:
	var out := {}
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for k in d:
		var e = d[k]
		if typeof(e) == TYPE_DICTIONARY:
			out[str(k)] = {"damage": float(e.get("damage", 0.0)),
				"healing": float(e.get("healing", 0.0)), "tank_time": int(e.get("tank_time", 0))}
	return out
