class_name MetricsCollector
extends RefCounted
## Thu số liệu perf (profiling.md): sample theo key -> aggregate avg/min/max. Detect regression so baseline.
## Dùng bởi PerfHarness/BenchmarkWorld (on-device) + test headless (feed sample tổng hợp).

var _samples: Dictionary = {}            # key -> Array[float]

func sample(key: String, value: float) -> void:
	if not _samples.has(key):
		_samples[key] = []
	(_samples[key] as Array).append(value)

func aggregate() -> Dictionary:
	var out: Dictionary = {}
	for key in _samples:
		var arr: Array = _samples[key]
		if arr.is_empty():
			continue
		var s := 0.0; var mn := INF; var mx := -INF
		for v in arr:
			s += v; mn = minf(mn, v); mx = maxf(mx, v)
		out[key] = {"avg": s / arr.size(), "min": mn, "max": mx, "count": arr.size()}
	return out

## Regression: true nếu metric vượt ngưỡng so baseline (profiling.md: FPS>10%, mem>15%, tick>20%).
## direction "lower_bad" (fps: giảm là xấu) / "higher_bad" (mem/tick: tăng là xấu).
static func is_regression(baseline: float, current: float, threshold_pct: float, direction: String) -> bool:
	if baseline <= 0.0:
		return false
	var change := (current - baseline) / baseline
	if direction == "lower_bad":
		return change < -threshold_pct
	return change > threshold_pct

func report() -> Dictionary:
	return {"metrics": aggregate()}
