class_name SimResult
extends RefCounted
## Kết quả 1 trận BattleSim (P4). TẤT ĐỊNH theo (units, seed, sim_version).
## timeline: cho VIEW/replay. contribution: chia thưởng boss. flags: cho telemetry/test.

var seed: int = 0
var sim_version: int = BattleSim.SIM_VERSION
var winner: int = -1                 # 0 phe người chơi, 1 phe địch
var duration_ticks: int = 0
var duration: float = 0.0
var timeline: Array = []             # {t, type, src, tgt, value, crit, skill}
var command_stream: Array = []       # {tick, actor, cmd, target, skill} — replay gọn (ID-based)
var survivors_hp: Dictionary = {}    # combatant_id -> hp
var hero_hp_after: Dictionary = {}   # hero_id -> hp (áp vào HeroInstance)
var dead_enemy_ids: Array = []
var contribution: Dictionary = {}    # hero_id -> {damage, healing, tank_time}
var total_damage: int = 0

# --- boss/encounter flags ---
var boss_defeated: bool = false
var enrage_activated: bool = false
var phases_entered: Array = []       # phase_idx đã vào (theo thứ tự)
var interrupts: int = 0
var breaks: int = 0
var timed_out: bool = false

# --- kết quả phe (arena timeout xử theo HP%) ---
var hp_left_pct: Dictionary = {0: 0.0, 1: 0.0}

func player_won() -> bool:
	return winner == 0

func team_hp_pct(team: int) -> float:
	return float(hp_left_pct.get(team, 0.0))
