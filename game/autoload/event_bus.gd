extends Node
## Hub tín hiệu toàn cục (decouple gameplay / UI / audio) — rule signal-rules.md.
## P0: bỏ các signal action cũ (player/boss/hitbox); giữ signal kinh tế; thêm hero/save.
## KHÔNG emit signal mỗi frame.

# Kinh tế / kho
signal gold_changed(total: int)
signal gems_changed(total: int)
signal energy_changed(total: int, maximum: int)
signal offline_reward(summary: Dictionary)
signal day_changed(day: int)
signal xp_changed(level: int, xp: int, xp_to_next: int)
signal level_changed(level: int)
signal inventory_changed
signal equipment_changed
signal consumables_changed
signal item_picked_up(item_id: String)

# Build (P3)
signal stats_recomputed(hero_id: String)
signal rune_changed(hero_id: String)

# Gacha / collection (P3-cont)
signal hero_summoned(hero_def_id: String, is_dup: bool)
signal pity_reset(banner_id: String)
signal duplicate_to_shard(hero_def_id: String, shards: int)
signal awaken_completed(hero_id: String)
signal talent_respec(hero_id: String)
signal collection_updated

# Hero (living-world)
signal hero_spawned(hero_id: String)
signal hero_knocked_out(hero_id: String)
signal hero_recovered(hero_id: String)

# World / expedition (P2)
signal zone_cleared(zone_id: String, stars: int)
signal expedition_started(exp_id: String)
signal expedition_resolved(summary: Dictionary)
signal expeditions_batch_resolved(summary: Dictionary)

# Encounter / competitive (P4) — KHÔNG phát mỗi tick (signal-rules.md)
signal world_boss_spawned(boss_id: String)
signal world_boss_phase_changed(boss_id: String, phase_idx: int)
signal world_boss_ended(boss_id: String, event_state: int)
signal arena_match_finished(result: Dictionary)
signal stage_cleared(stage_id: String, stars: int)

# Save
signal save_completed(ok: bool)
