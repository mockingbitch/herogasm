extends RefCounted
## Regression — save migration 1→N không mất data + validate dup-id + recovery từ .bak.

static func run(t) -> void:
	# --- v1 (phẳng) -> current: giữ gold/level/inventory ---
	var v1 := {"save_version": 1, "gold": 123, "level": 5, "xp": 10,
		"inventory": [{"id": "iron_sword", "level": 2, "affixes": []}],
		"equipment": {"weapon": null, "armor": null}}
	var out := SaveManager._migrate(v1)
	t.eq(int(out["save_version"]), SaveManager.SAVE_VERSION, "Mig_V1ToCurrent")
	t.eq(int(out["player"]["gold"]), 123, "Mig_GoldPreserved")
	t.eq(int(out["heroes"]["hero_0"]["level"]), 5, "Mig_LevelPreserved")
	# mọi block mới của các phase đều có mặt
	var pl: Dictionary = out["player"]
	t.truthy(pl.has("story") and pl.has("stage_stars") and pl.has("account_id") and pl.has("battlepass"), "Mig_AllBlocksPresent")
	var wd: Dictionary = out["world"]
	t.truthy(wd.has("season") and wd.has("events") and wd.has("world_state") and wd.has("expeditions"), "Mig_WorldBlocksPresent")

	# --- round-trip: nạp vào PlayerProfile giữ gold ---
	PlayerProfile.from_dict(out)
	t.eq(PlayerProfile.gold, 123, "Mig_RoundtripGold")

	# --- dup-id validation ---
	t.eq(SaveManager.has_duplicate_ids({"hero_ids": ["a", "b", "a"]}), true, "Validate_DuplicateIdsFail")
	t.eq(SaveManager.has_duplicate_ids({"hero_ids": ["a", "b", "c"]}), false, "Validate_UniqueIdsOk")

	# --- recovery: main corrupt -> load từ .bak (bản trước), không crash ---
	PlayerProfile.reset_progress()
	PlayerProfile.gold = 100
	PlayerProfile.save()                          # main=100 (bak=new_game)
	PlayerProfile.gold = 555
	PlayerProfile.save()                          # main=555, bak=100 (bản trước)
	var f := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	f.store_string("{ this is broken json")
	f.close()
	var recovered := SaveManager.load_game()
	t.truthy(not recovered.is_empty(), "Recovery_FromBackup")
	t.eq(int((recovered.get("player", {}) as Dictionary).get("gold", -1)), 100, "Recovery_GoldFromBackup")
	PlayerProfile.reset_progress()
