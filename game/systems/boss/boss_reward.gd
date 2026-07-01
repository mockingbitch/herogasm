class_name BossReward
extends RefCounted
## Chia thưởng boss theo contribution (damage/healing/tank-time) + chống double-claim.
## Nguồn/sink qua PlayerProfile (economy.md). reward_claimed lưu trong BossRuntimeState (save).

const HEAL_WEIGHT := 0.8            # heal quy đổi điểm (thấp hơn damage)
const TANK_WEIGHT := 4.0           # 1 tick tank ≈ 4 điểm (tank-time có giá trị)

## ContributionBoard: mảng {hero_id, damage, healing, tank_time, score, share} sắp giảm dần.
static func board(state: BossRuntimeState) -> Array:
	var rows: Array = []
	var total := 0.0
	for hid in state.contribution:
		var e: Dictionary = state.contribution[hid]
		var score := float(e.get("damage", 0.0)) + float(e.get("healing", 0.0)) * HEAL_WEIGHT \
			+ float(e.get("tank_time", 0)) * TANK_WEIGHT
		total += score
		rows.append({"hero_id": hid, "damage": float(e.get("damage", 0.0)),
			"healing": float(e.get("healing", 0.0)), "tank_time": int(e.get("tank_time", 0)), "score": score})
	for r in rows:
		r["share"] = float(r["score"]) / maxf(1.0, total)
	rows.sort_custom(func(a, b): return a["score"] > b["score"] or (a["score"] == b["score"] and a["hero_id"] < b["hero_id"]))
	return rows

## Chia thưởng 1 LẦN. Trả summary; đặt reward_claimed. Từ chối nếu đã nhận.
static func distribute(def: BossDef, state: BossRuntimeState, profile) -> Dictionary:
	if state.reward_claimed:
		return {"ok": false, "reason": "already_claimed"}
	var rows := board(state)
	var pool_gold := def.level * 500 + 1000
	var pool_honor := def.level * 20 + 40
	var grants: Array = []
	var total_gold := 0
	for i in rows.size():
		var r: Dictionary = rows[i]
		var gold := int(round(pool_gold * float(r["share"])))
		var honor := int(round(pool_honor * float(r["share"])))
		if i == 0:
			gold += 200; honor += 20                  # MVP bonus
		total_gold += gold
		grants.append({"hero_id": r["hero_id"], "gold": gold, "honor": honor, "share": r["share"]})
	# áp vào ví account (gold + honor dùng chung account, chia theo đóng góp)
	profile.add_gold(total_gold)
	var total_honor := 0
	for g in grants:
		total_honor += int(g["honor"])
	profile.add_currency("honor", total_honor)
	state.reward_claimed = true
	return {"ok": true, "grants": grants, "total_gold": total_gold, "total_honor": total_honor,
		"mvp": rows[0]["hero_id"] if rows.size() > 0 else ""}
