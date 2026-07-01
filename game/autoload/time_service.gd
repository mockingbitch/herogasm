extends Node
## Dịch vụ thời gian (P0 stub) — nền cho Scheduler (P1) + offline accrual (P2).
## Cung cấp tick đếm, thời gian hệ thống, và slice định kỳ tối thiểu.
## P1 sẽ thay bằng bucket-scheduler có tick-budget (rule performance.md/ai.md).

var _tick: int = 0
var _slices: Array = []                            # {cb: Callable, interval: float, accum: float}

func _process(delta: float) -> void:
	_tick += 1
	for s in _slices:
		s["accum"] += delta
		if s["accum"] >= s["interval"]:
			s["accum"] = 0.0
			(s["cb"] as Callable).call()

func get_tick() -> int:
	return _tick

func now_unix() -> float:
	return Time.get_unix_time_from_system()

## Thời gian đã trôi từ mốc ts (giây), không âm — dùng cho offline progression P2.
func elapsed_since(ts: float) -> float:
	return maxf(0.0, now_unix() - ts)

func register_slice(cb: Callable, interval: float) -> void:
	_slices.append({"cb": cb, "interval": maxf(0.001, interval), "accum": 0.0})
