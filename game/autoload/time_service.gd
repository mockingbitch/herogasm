extends Node
## Dịch vụ thời gian (P0 stub) — nền cho Scheduler (P1) + offline accrual (P2).
## Cung cấp tick đếm, thời gian hệ thống, và slice định kỳ tối thiểu.
## P1 sẽ thay bằng bucket-scheduler có tick-budget (rule performance.md/ai.md).

const SECONDS_PER_GAME_DAY := 3600.0               # 1 giờ thực = 1 ngày game (P4 rotation)

var _tick: int = 0
var _slices: Array = []                            # {cb: Callable, interval: float, accum: float}
var game_time: float = 0.0                         # thời gian GAME (KHÔNG dùng OS time cho gameplay — multiplayer.md)

func _process(delta: float) -> void:
	_tick += 1
	game_time += delta
	for s in _slices:
		s["accum"] += delta
		if s["accum"] >= s["interval"]:
			s["accum"] = 0.0
			(s["cb"] as Callable).call()

func get_tick() -> int:
	return _tick

# --- game time (nền World Boss rotation tuần — dùng Game Time, không OS time) --
## Chỉ số ngày game trôi qua (từ mốc bắt đầu). Deterministic theo game_time.
func game_day() -> int:
	return int(game_time / SECONDS_PER_GAME_DAY)

## 0..6 (thứ trong tuần) — WorldBossService map -> boss-of-the-day.
func day_of_week() -> int:
	return game_day() % 7

## Cộng thẳng thời gian game (debug/test/skip-day). KHÔNG lùi về quá khứ.
func advance_game_time(seconds: float) -> void:
	game_time += maxf(0.0, seconds)

func now_unix() -> float:
	return Time.get_unix_time_from_system()

## Thời gian đã trôi từ mốc ts (giây), không âm — dùng cho offline progression P2.
func elapsed_since(ts: float) -> float:
	return maxf(0.0, now_unix() - ts)

func register_slice(cb: Callable, interval: float) -> void:
	_slices.append({"cb": cb, "interval": maxf(0.001, interval), "accum": 0.0})
