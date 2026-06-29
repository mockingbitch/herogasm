extends Node
## Hub tín hiệu toàn cục để giảm phụ thuộc giữa gameplay / UI / audio.

# Combat / world
signal enemy_died(enemy: Node, position: Vector2)
signal player_damaged(amount: int, hp: int, max_hp: int)
signal player_died
signal loot_dropped(item_id: String, position: Vector2)

# Boss
signal boss_spawned(name: String, max_hp: int)
signal boss_health(hp: int, max_hp: int)
signal boss_died

# Profile / kinh tế
signal gold_changed(total: int)
signal xp_changed(level: int, xp: int, xp_to_next: int)
signal level_changed(level: int)
signal inventory_changed
signal equipment_changed
signal consumables_changed
signal item_picked_up(item_id: String)
