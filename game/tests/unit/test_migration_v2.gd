extends RefCounted
## Unit — migration v2->v3 (default vòng đời + cleared_stars + world) và chain v1->v3.

static func run(t) -> void:
	# v2 -> v3
	var v2 := {
		"save_version": 2,
		"player": {"gold": 100},
		"hero_ids": ["hero_0"],
		"heroes": {"hero_0": {"level": 2, "xp": 0}},
		"world": {},
	}
	var out := SaveManager._migrate(v2)
	t.eq(int(out["save_version"]), 3, "V2_MigratedTo3")
	t.approx(float(out["heroes"]["hero_0"]["mood"]), 70.0, "V2_MoodDefault70")
	t.eq(int(out["heroes"]["hero_0"]["injury_level"]), 0, "V2_InjuryDefault0")
	t.truthy((out["player"] as Dictionary).has("cleared_stars"), "V2_ClearedStarsAdded")
	t.truthy((out["world"] as Dictionary).has("expeditions"), "V2_WorldExpeditionsAdded")

	# v1 -> v3 (chain qua v2)
	var v1 := {"save_version": 1, "gold": 500, "level": 3, "equipment": {"weapon": null, "armor": null}}
	var o2 := SaveManager._migrate(v1)
	t.eq(int(o2["save_version"]), 3, "V1_ChainedTo3")
	t.eq(int(o2["player"]["gold"]), 500, "V1_GoldPreserved")
	t.approx(float(o2["heroes"]["hero_0"]["mood"]), 70.0, "V1_MoodDefault")

	# idempotent: migrate lần 2 (đã v3) không đổi
	var o3 := SaveManager._migrate(o2)
	t.eq(int(o3["save_version"]), 3, "V3_StaysV3")
	t.approx(float(o3["heroes"]["hero_0"]["mood"]), 70.0, "V3_Idempotent")
