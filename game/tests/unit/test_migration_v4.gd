extends RefCounted
## Unit — migration v3->v4 (default gacha fields) + gacha state save roundtrip.

static func run(t) -> void:
	var v3 := {"save_version": 3, "player": {"gold": 50}, "hero_ids": ["hero_0"],
		"heroes": {"hero_0": {"level": 1}}, "world": {}}
	var out := SaveManager._migrate(v3)
	t.eq(int(out["save_version"]), 4, "V3_To_V4")
	t.truthy((out["player"] as Dictionary).has("pity_counters"), "Player_PityAdded")
	t.truthy((out["player"] as Dictionary).has("collection"), "Player_CollectionAdded")
	t.eq(int(out["heroes"]["hero_0"]["shards"]), 0, "Hero_ShardsDefault")

	# gacha state roundtrip
	PlayerProfile.reset_progress()
	PlayerProfile.pity_counters["standard"] = {"since_guaranteed": 5, "total_pulls": 20}
	PlayerProfile.collection["mage"] = {"owned": 2, "first_at": 1.0}
	PlayerProfile._claimed_ids["c1"] = "h"
	var hid: String = PlayerProfile.hero_ids[0]
	PlayerProfile.get_hero(hid).shards = 7
	var d := PlayerProfile.to_dict()
	PlayerProfile.from_dict(d)
	t.eq(int(PlayerProfile.pity_counters["standard"]["since_guaranteed"]), 5, "Pity_Roundtrip")
	t.eq(int(PlayerProfile.get_hero(hid).shards), 7, "Shards_Roundtrip")
	t.eq(int(PlayerProfile.collection["mage"]["owned"]), 2, "Collection_Roundtrip")
	t.truthy(PlayerProfile._claimed_ids.has("c1"), "Claimed_Roundtrip")
