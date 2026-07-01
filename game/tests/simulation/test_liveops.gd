extends RefCounted
## Simulation/Unit — LiveOps harness: metrics regression, stress levels, economy 30-day, release gate.

static func run(t) -> void:
	# --- MetricsCollector ---
	var mc := MetricsCollector.new()
	mc.sample("fps", 60.0); mc.sample("fps", 58.0)
	var agg := mc.aggregate()
	t.approx(float(agg["fps"]["avg"]), 59.0, "Metrics_Avg")
	t.eq(float(agg["fps"]["min"]), 58.0, "Metrics_Min")
	t.eq(MetricsCollector.is_regression(60.0, 40.0, 0.1, "lower_bad"), true, "Metrics_FpsRegression")
	t.eq(MetricsCollector.is_regression(100.0, 105.0, 0.15, "higher_bad"), false, "Metrics_MemWithinThreshold")
	t.eq(MetricsCollector.is_regression(100.0, 130.0, 0.15, "higher_bad"), true, "Metrics_MemRegression")

	# --- StressTestRunner: 4 level, không crash, luôn có winner ---
	var report := StressTestRunner.run_levels()
	t.eq(report.size(), 4, "Stress_FourLevels")
	for r in report:
		t.truthy(int(r["winner"]) == 0 or int(r["winner"]) == 1, "Stress_Level%d_Winner" % int(r["level"]))
		t.truthy(int(r["ticks"]) > 0, "Stress_Level%d_Ran" % int(r["level"]))

	# --- EconomySimRunner 30-day: source↔sink, no infinite gold, offline cap ---
	var eco := EconomySimRunner.run(30, 1)
	t.truthy(int(eco["gold_in"]) > 0, "Economy_GoldInPositive")
	t.truthy(int(eco["gold_out"]) > 0, "Economy_SinkExists")
	t.truthy(int(eco["ending_gold"]) >= 0, "Economy_NoNegativeGold")
	t.truthy(bool(eco["offline_capped"]), "Economy_OfflineCapRespected")

	# --- ReleaseGate: dev build bật debug, release tắt ---
	t.eq(ReleaseGate.debug_enabled(), not ReleaseGate.is_release, "ReleaseGate_Consistent")
	t.eq(Debug.enabled, ReleaseGate.debug_enabled(), "ReleaseGate_DebugMatches")
