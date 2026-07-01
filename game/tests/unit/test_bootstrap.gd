extends RefCounted
## Integration nhẹ — new_game tạo 1 hero starter với rusty_sword + 2 potion.

static func run(t) -> void:
	PlayerProfile.reset_progress()
	var expected := Database.hero_def_ids().size()
	t.eq(PlayerProfile.hero_ids.size(), expected, "NewGame_RosterFromDefs")
	t.truthy(expected >= 4, "NewGame_AtLeast4Heroes")
	var h: HeroInstance = PlayerProfile.primary_hero()
	t.truthy(h != null, "NewGame_PrimaryHeroExists")
	t.truthy(h != null and h.equipment.get("weapon") != null, "NewGame_HasWeapon")
	t.truthy(h != null and h.display_name != "", "NewGame_HeroNamedFromDef")
	t.truthy(h != null and h.ai_weights.has("aggression"), "NewGame_AiWeightsApplied")
	t.eq(PlayerProfile.potion_count(), 2, "NewGame_TwoPotions")
	t.truthy(h != null and h.current_hp == h.eff_max_hp(), "NewGame_FullHp")
	t.truthy(PlayerProfile.energy > 0, "NewGame_HasEnergy")
