class_name MmrService
extends RefCounted
## MMR-lite (Elo rút gọn): new = old + K*(score - expected). K theo band. clamp MMR >= 0.
## PURE, deterministic — inject vào ArenaService. predict_win_chance cho matchmaking/UI.

const BASE := 1000

## Xác suất thắng kỳ vọng của a trước b (Elo logistic).
static func predict_win_chance(mmr_a: int, mmr_b: int) -> float:
	return 1.0 / (1.0 + pow(10.0, float(mmr_b - mmr_a) / 400.0))

## K theo band: MMR thấp biến động mạnh (leo nhanh), cao ổn định.
static func k_factor(mmr: int) -> int:
	if mmr < 1200:
		return 40
	elif mmr < 1800:
		return 24
	return 16

## MMR mới sau trận. won: thắng thật. clamp >= 0.
static func update(old_mmr: int, opponent_mmr: int, won: bool) -> int:
	var expected := predict_win_chance(old_mmr, opponent_mmr)
	var score := 1.0 if won else 0.0
	var delta := int(round(k_factor(old_mmr) * (score - expected)))
	return maxi(0, old_mmr + delta)
