extends RefCounted
## Unit — SummonService: determinism (seed), pity hard, dup->shard.

static func run(t) -> void:
	var svc := SummonService.new()
	svc.setup(CombatConstants.new())
	var banner: BannerDef = Database.get_banner_def("standard")

	# determinism: cùng seed -> cùng chuỗi pull
	RandomService.seed_with(12345)
	var a := svc.pull(banner, 10, {"since_guaranteed": 0, "total_pulls": 0}, {})
	RandomService.seed_with(12345)
	var b := svc.pull(banner, 10, {"since_guaranteed": 0, "total_pulls": 0}, {})
	var same := true
	for i in a.size():
		if str(a[i]["hero_def_id"]) != str(b[i]["hero_def_id"]) or int(a[i]["rarity"]) != int(b[i]["rarity"]):
			same = false
	t.truthy(same, "Summon_Determinism")

	# pity hard -> guaranteed + reset
	var pb := BannerDef.new()
	pb.pool = banner.pool; pb.pity_hard = 10; pb.guaranteed_rarity = 3; pb.pity_soft_start = 100
	var st := {"since_guaranteed": 9, "total_pulls": 0}
	RandomService.seed_with(1)
	var r := svc._pull_one(pb, st)
	t.truthy(int(r["rarity"]) >= 3, "PityHard_Guaranteed")
	t.eq(int(st["since_guaranteed"]), 0, "PityReset")

	# duplicate -> shard
	var kb := BannerDef.new()
	kb.pool = [{"hero_def_id": "knight", "rarity": 3, "weight": 1.0}]; kb.guaranteed_rarity = 3
	RandomService.seed_with(7)
	var d := svc.pull(kb, 1, {"since_guaranteed": 0, "total_pulls": 0}, {"knight": {"owned": 1}})
	t.truthy(bool(d[0]["is_dup"]), "Dup_Detected")
	t.truthy(int(d[0]["shards_gained"]) > 0, "Dup_GivesShards")
