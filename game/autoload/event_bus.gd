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

# Hero (living-world)
signal hero_spawned(hero_id: String)
signal hero_knocked_out(hero_id: String)
signal hero_recovered(hero_id: String)

# Save
signal save_completed(ok: bool)
