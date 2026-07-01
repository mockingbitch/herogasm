extends RefCounted
## Regression — tất định (golden): cùng seed+snapshot -> replay byte-identical; boss save/load khôi phục.

static func _block(hid: String, hp: int, atk: int, df: int) -> Dictionary:
	return {"hero_id": hid, "name": hid, "max_hp": hp, "attack": atk, "defense": df,
		"crit_chance": 0.0, "crit_damage": 1.5, "lifesteal": 0.0, "attack_interval": 1.0}

static func run(t) -> void:
	# --- golden replay: cùng seed + snapshot -> hai lần play giống hệt ---
	var replay := ReplayData.new()
	replay.replay_id = "golden"; replay.seed = 4242
	replay.initial_state = {
		"team_a": [_block("a0", 800, 60, 12), _block("a1", 600, 45, 8)],
		"team_b": [_block("b0", 700, 55, 10), _block("b1", 500, 40, 6)],
		"formation_a": "balanced_3", "formation_b": "offense_3", "max_ticks": 900,
	}
	var r1 := ReplayPlayer.play(replay)
	var r2 := ReplayPlayer.play(replay)
	t.eq(r1.winner, r2.winner, "Replay_SameWinner")
	t.eq(r1.duration_ticks, r2.duration_ticks, "Replay_SameDuration")
	t.eq(r1.total_damage, r2.total_damage, "Replay_SameTotalDamage")
	t.eq(r1.timeline.size(), r2.timeline.size(), "Replay_SameTimeline")

	# --- boss save/load: phase + hp + contribution khôi phục ---
	var st := BossRuntimeState.new()
	st.boss_def_id = &"abyss_dragon"
	st.max_hp = 60000.0; st.current_hp = 24000.0
	st.current_phase_idx = 2
	st.add_contribution("hero_a", 12000.0, 1000.0, 30)
	st.add_contribution("hero_b", 8000.0, 0.0, 12)
	st.event_state = Enums.BossEventState.ACTIVE
	var d := st.to_dict()
	var back := BossRuntimeState.from_dict(d)
	t.eq(back.current_phase_idx, 2, "BossSave_PhaseRestored")
	t.eq(int(back.current_hp), 24000, "BossSave_HpRestored")
	t.eq(int(back.contribution["hero_a"]["damage"]), 12000, "BossSave_ContributionRestored")
	t.eq(int(back.contribution["hero_a"]["tank_time"]), 30, "BossSave_TankTimeRestored")
	t.eq(back.event_state, Enums.BossEventState.ACTIVE, "BossSave_EventStateRestored")

	# sim_version ổn định (đổi -> cảnh báo regression)
	t.eq(BattleSim.SIM_VERSION, 1, "Sim_VersionPinned")
