extends RefCounted
## Unit — world map gating (level + prereq stars) + star_for monotonic.

static func run(t) -> void:
	PlayerProfile.reset_progress()
	PlayerProfile.cleared_stars = {}

	t.truthy(PlayerProfile.is_zone_unlocked("beginner_field"), "Beginner_Unlocked")
	t.truthy(not PlayerProfile.is_zone_unlocked("goblin_camp"), "Goblin_LockedByLevel")

	# nâng 1 hero lên level 3 (đủ level cho goblin_camp)
	var h: HeroInstance = PlayerProfile.get_hero(PlayerProfile.hero_ids[0])
	while h.level < 3:
		h.gain_xp(h.xp_to_next())
	t.truthy(not PlayerProfile.is_zone_unlocked("goblin_camp"), "Goblin_LockedByStars")

	# clear beginner 3 lần -> 2 sao (thresholds [1,3,6]) -> mở goblin (unlock_by_stars=2)
	for i in 3:
		PlayerProfile.record_zone_clear("beginner_field")
	t.eq(PlayerProfile.zone_stars("beginner_field"), 2, "Beginner_2Stars")
	t.truthy(PlayerProfile.is_zone_unlocked("goblin_camp"), "Goblin_UnlockedAfterStars")

	# star_for đơn điệu + trần 3
	var z: ZoneDef = Database.get_zone_def("beginner_field")
	t.eq(z.star_for(0), 0, "Star_0")
	t.eq(z.star_for(1), 1, "Star_1")
	t.eq(z.star_for(3), 2, "Star_2")
	t.eq(z.star_for(6), 3, "Star_3")
	t.eq(z.star_for(99), 3, "Star_CapAt3")
