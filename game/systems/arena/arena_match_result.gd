class_name ArenaMatchResult
extends RefCounted
## Kết quả 1 trận Đấu Trường async. Timeout xử theo HP% (multiplayer.md deterministic).

var attacker_id: StringName = &""
var defender_snapshot_id: StringName = &""
var outcome: int = Enums.ArenaOutcome.LOSE
var duration_ticks: int = 0
var attacker_hp_left_pct: float = 0.0
var defender_hp_left_pct: float = 0.0
var mmr_delta: int = 0
var honor_gained: int = 0
var replay_id: StringName = &""

func won() -> bool:
	return outcome == Enums.ArenaOutcome.WIN or outcome == Enums.ArenaOutcome.TIMEOUT_WIN

func to_dict() -> Dictionary:
	return {"attacker_id": str(attacker_id), "defender_snapshot_id": str(defender_snapshot_id),
		"outcome": outcome, "duration_ticks": duration_ticks,
		"attacker_hp_left_pct": attacker_hp_left_pct, "defender_hp_left_pct": defender_hp_left_pct,
		"mmr_delta": mmr_delta, "honor_gained": honor_gained, "replay_id": str(replay_id)}
