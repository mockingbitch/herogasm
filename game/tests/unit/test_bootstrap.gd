extends RefCounted
## Integration nhẹ — new_game tạo 1 hero starter với rusty_sword + 2 potion.

static func run(t) -> void:
	PlayerProfile.reset_progress()
	t.eq(PlayerProfile.hero_ids.size(), 1, "NewGame_OneHero")
	var h: HeroInstance = PlayerProfile.primary_hero()
	t.truthy(h != null, "NewGame_PrimaryHeroExists")
	t.truthy(h != null and h.equipment.get("weapon") != null, "NewGame_HasWeapon")
	t.eq(str(h.equipment["weapon"]["id"]), "rusty_sword", "NewGame_StarterRustySword")
	t.eq(PlayerProfile.potion_count(), 2, "NewGame_TwoPotions")
	t.truthy(h != null and h.current_hp == h.eff_max_hp(), "NewGame_FullHp")
