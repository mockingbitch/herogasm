class_name ReplayPlayer
extends RefCounted
## Phát lại 1 ReplayData bằng CHÍNH BattleSim (cùng seed + cùng initial_state) -> replay == trận gốc
## (rules/multiplayer.md Rollback). KHÔNG lưu/đọc animation. VIEW đọc result.timeline để render.

## Tái lập trận. Trả SimResult (byte-identical với trận gốc nếu sim_version khớp).
static func play(replay: ReplayData) -> SimResult:
	var a := _build(replay.initial_state.get("team_a", []), 0, str(replay.initial_state.get("formation_a", "balanced_3")))
	var b := _build(replay.initial_state.get("team_b", []), 1, str(replay.initial_state.get("formation_b", "balanced_3")))
	var max_ticks := int(replay.initial_state.get("max_ticks", BattleSim.DEFAULT_MAX_TICKS))
	var sim := BattleSim.new()
	return sim.simulate(a, b, replay.seed, max_ticks, false)

static func _build(blocks: Array, team: int, formation_id: String) -> Array:
	var out: Array = []
	for hb in blocks:
		if typeof(hb) == TYPE_DICTIONARY:
			out.append(SimCombatant.from_snapshot_hero(hb, team))
	FormationService.apply(out, Database.get_formation_def(formation_id))
	return out

## Cùng seed + snapshot -> hai lần play cho cùng kết quả (dùng cho regression test).
static func is_deterministic(replay: ReplayData) -> bool:
	var r1 := play(replay)
	var r2 := play(replay)
	return r1.winner == r2.winner and r1.duration_ticks == r2.duration_ticks \
		and r1.total_damage == r2.total_damage
