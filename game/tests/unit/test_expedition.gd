extends RefCounted
## Unit — expedition idle: start/energy, idempotent resolve, offline ≤80%, no-permadeath, save roundtrip.

static func _strong_hero() -> String:
	PlayerProfile.reset_progress()
	var hid: String = PlayerProfile.hero_ids[0]
	var h: HeroInstance = PlayerProfile.get_hero(hid)
	for i in 20:
		h.gain_xp(h.xp_to_next())          # đủ mạnh để chắc thắng beginner_field
	h.current_hp = h.eff_max_hp(); h.is_ko = false; h.fatigue = 0.0
	return hid

static func run(t) -> void:
	# --- start ---
	var hid := _strong_hero()
	var e0 := PlayerProfile.energy
	var z: ZoneDef = Database.get_zone_def("beginner_field")
	var exp := ExpeditionService.start(hid, "beginner_field")
	t.truthy(exp != null, "Start_Ok")
	t.eq(PlayerProfile.energy, e0 - z.energy_cost, "Start_EnergySpent")
	t.truthy(ExpeditionService.is_on_expedition(hid), "Start_OnExpedition")
	t.approx(exp.end_epoch - exp.start_epoch, z.duration_sec, "Start_Duration")

	# --- export/import roundtrip ---
	var w := ExpeditionService.export_world()
	t.truthy(int((w["expeditions"] as Array).size()) >= 1, "Export_HasExpedition")
	ExpeditionService.import_world(w)
	t.truthy(ExpeditionService.is_on_expedition(hid), "Import_Roundtrip")

	# --- resolve idempotent (no double reward) ---
	var hid2 := _strong_hero()
	var e := ExpeditionState.new()
	e.id = "idem"; e.hero_id = hid2; e.zone_id = "beginner_field"; e.seed = 7
	ExpeditionService.resolve(e, false)
	t.truthy(e.resolved, "Resolve_Marks")
	t.eq(e.outcome, "win", "Resolve_StrongHeroWins")
	var g := PlayerProfile.gold
	ExpeditionService.resolve(e, false)      # gọi lại
	t.eq(PlayerProfile.gold, g, "Resolve_Idempotent_NoDoubleGold")
	t.truthy(PlayerProfile.get_hero(hid2) != null, "NoPermadeath")

	# --- offline ≤80% (cùng seed online vs offline) ---
	var hid3 := _strong_hero()
	var g0 := PlayerProfile.gold
	var eon := ExpeditionState.new(); eon.id = "on"; eon.hero_id = hid3; eon.zone_id = "beginner_field"; eon.seed = 42
	ExpeditionService.resolve(eon, false)
	var online_gold := PlayerProfile.gold - g0
	# reset hero + replay offline cùng seed
	var hh: HeroInstance = PlayerProfile.get_hero(hid3)
	hh.current_hp = hh.eff_max_hp(); hh.is_ko = false; hh.fatigue = 0.0
	var g1 := PlayerProfile.gold
	var eoff := ExpeditionState.new(); eoff.id = "off"; eoff.hero_id = hid3; eoff.zone_id = "beginner_field"; eoff.seed = 42
	ExpeditionService.resolve(eoff, true)
	var offline_gold := PlayerProfile.gold - g1
	if eon.outcome == "win" and eoff.outcome == "win":
		t.eq(offline_gold, int(online_gold * ExpeditionService.IDLE_REWARD_FACTOR), "Offline_ScaledByFactor")
		t.truthy(offline_gold <= int(online_gold * 0.8), "Offline_Leq80Pct")
