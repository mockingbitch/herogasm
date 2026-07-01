extends RefCounted
## Unit — fatigue/mood/injury multipliers + effective_power + injury lifecycle.

static func run(t) -> void:
	var h := HeroInstance.new()
	h.set_curves(HeroConditionCurves.new())   # defaults cố định

	h.set_fatigue(100.0)
	t.approx(h.fatigue_mult(), 0.5, "Fatigue100_HalfPower")
	h.set_fatigue(0.0)
	t.approx(h.fatigue_mult(), 1.0, "Fatigue0_Full")

	h.set_mood(0.0)
	t.approx(h.mood_mult(), 0.75, "Mood0_Min")
	h.set_mood(50.0)
	t.approx(h.mood_mult(), 1.0, "MoodPivot_Full")

	h.injury_level = 3
	t.approx(h.injury_mult(), 0.55, "Injury3_Mult")
	var ep := h.effective_power()
	t.truthy(ep >= 0.1 and ep <= 1.0, "EffectivePower_InRange")

	# injury lifecycle (Time truyền vào để test được)
	var h2 := HeroInstance.new()
	h2.set_curves(HeroConditionCurves.new())
	h2.apply_injury(1, 1000.0)
	t.truthy(not h2.injury_ready(1000.0), "Injury_NotReadyImmediately")
	t.truthy(h2.injury_ready(1000.0 + 1800.0 + 1.0), "Injury_ReadyAfterDeadline")
	h2.recover_injury()
	t.eq(h2.injury_level, 0, "Injury_RecoverClears")
	t.approx(h2.injury_recover_at, 0.0, "Injury_RecoverResetsDeadline")
