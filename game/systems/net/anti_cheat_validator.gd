class_name AntiCheatValidator
extends RefCounted
## Pre-check client-side (energy/time/checksum/replay-verify). VERIFY THẬT nằm server (MockBackend/Edge)
## — "Never trust client" (multiplayer.md). Đây chỉ là lớp chặn sớm + tự-kiểm để bắt lỗi/gian lận local.

static func pre_check_energy(cost: int) -> bool:
	return PlayerProfile.energy >= cost

## Integrity: checksum khớp blob (server cũng verify lại).
static func save_integrity(blob: Dictionary, checksum: String) -> bool:
	return str(JSON.stringify(blob).hash()) == checksum

## Verify điểm/kết quả trận: chạy lại seeded local == score khai báo (server là authority cuối).
static func verify_battle_score(team_blocks: Array, opp_blocks: Array, seed_val: int, claimed_score: int,
		formation_a: String = "balanced_3", formation_b: String = "balanced_3") -> bool:
	var a := _team(team_blocks, 0, formation_a)
	var b := _team(opp_blocks, 1, formation_b)
	return BattleSim.new().simulate(a, b, seed_val, 900).total_damage == claimed_score

## Chống progress tụt (offline reward abuse / save chỉnh): play_time mới >= cũ.
static func check_progress(new_play_time: int, old_play_time: int) -> bool:
	return new_play_time >= old_play_time

static func _team(blocks: Array, team: int, formation_id: String) -> Array:
	var out: Array = []
	for hb in blocks:
		if typeof(hb) == TYPE_DICTIONARY:
			out.append(SimCombatant.from_snapshot_hero(hb, team))
	FormationService.apply(out, Database.get_formation_def(formation_id))
	return out
