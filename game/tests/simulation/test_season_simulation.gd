extends RefCounted
## Simulation/Integration — tua trọn 1 season: start → events active → world evolution theo outcome →
## rollover sạch (currency purge, meta gỡ, rank reset). Dùng TimeService.advance_game_time (offline-safe).

static func run(t) -> void:
	PlayerProfile.reset_progress()
	EventManager.import_world({})
	WorldEvolutionService.world_state = {}
	if SeasonManager.is_season_active():
		SeasonManager.rollover()

	# --- start season ---
	t.truthy(SeasonManager.start_season("season_of_frost"), "Season_Started")
	t.truthy(SeasonManager.meta_rotation().is_active(), "Season_MetaActive")
	t.truthy(EventManager.active_event_ids().size() >= 1, "Season_EventsActive")

	# --- world evolution theo outcome boss ---
	EventBus.world_boss_ended.emit("abyss_dragon", Enums.BossEventState.FAILED)
	t.eq(WorldEvolutionService.get_state("iron_mountain", "corruption", false), true, "WorldEvo_CorruptionOnSurvive")
	EventBus.world_boss_ended.emit("abyss_dragon", Enums.BossEventState.WON)
	t.eq(WorldEvolutionService.get_state("iron_mountain", "frozen_fortress_open", false), true, "WorldEvo_FortressOnDefeat")

	# --- rollover sau 56 ngày: sạch ---
	PlayerProfile.add_currency("frost_shard", 200)
	ArenaService.mmr = 1600
	TimeService.advance_game_time(57.0 * TimeService.SECONDS_PER_GAME_DAY)
	t.truthy(SeasonManager.should_rollover(), "Season_ShouldRollover")
	SeasonManager.rollover()
	t.eq(SeasonManager.is_season_active(), false, "Season_EndedNoNext")
	t.eq(SeasonManager.meta_rotation().is_active(), false, "Season_MetaCleared")
	t.eq(PlayerProfile.currency_amount("frost_shard"), 0, "Season_CurrencyPurged")
	t.eq(ArenaService.mmr, MmrService.BASE, "Season_RankReset")
	# hero/story còn nguyên
	t.truthy(PlayerProfile.hero_ids.size() >= 4, "Season_KeepsRoster")
