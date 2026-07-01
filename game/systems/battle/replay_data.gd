class_name ReplayData
extends RefCounted
## Replay gọn theo multiplayer.md ("Network Messages: small, ID-based"): CHỈ lưu seed +
## initial_state (2 đội + formation) + command_stream. Phát lại bằng CHÍNH BattleSim ->
## replay == trận gốc (Rollback). KHÔNG lưu node/animation/particle.

var replay_id: String = ""
var seed: int = 0
var sim_version: int = BattleSim.SIM_VERSION
var initial_state: Dictionary = {}   # {team_a:[hero blocks], team_b:[...], formation_a, formation_b, max_ticks}
var command_stream: Array = []       # {tick, actor, cmd, target, skill}
var outcome: int = -1                # winner (0/1) — chỉ để hiển thị nhanh, replay tự tái lập

func to_dict() -> Dictionary:
	return {
		"replay_id": replay_id,
		"seed": seed,
		"sim_version": sim_version,
		"initial_state": initial_state,
		"command_stream": command_stream,
		"outcome": outcome,
	}

static func from_dict(d: Dictionary) -> ReplayData:
	var r := ReplayData.new()
	r.replay_id = str(d.get("replay_id", ""))
	r.seed = int(d.get("seed", 0))
	r.sim_version = int(d.get("sim_version", BattleSim.SIM_VERSION))
	r.initial_state = d.get("initial_state", {}) if typeof(d.get("initial_state")) == TYPE_DICTIONARY else {}
	r.command_stream = d.get("command_stream", []) if typeof(d.get("command_stream")) == TYPE_ARRAY else []
	r.outcome = int(d.get("outcome", -1))
	return r
