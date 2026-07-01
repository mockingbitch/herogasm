class_name EconomySimRunner
extends RefCounted
## Mô phỏng kinh tế 30 ngày (release.md Step 6): log gold in/out, kiểm no infinite gold, source↔sink
## cân bằng, offline cap ≤80% (economy.md). Deterministic (không real time/render).

## days: số ngày. active_ratio: tỉ lệ ngày chơi chủ động (còn lại offline ≤80%).
## Trả {days, gold_in, gold_out, ending_gold, inflation_ratio, offline_capped}.
static func run(days: int = 30, seed_val: int = 1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var gold := 0
	var gold_in := 0
	var gold_out := 0
	var offline_capped := true
	for d in days:
		# nguồn: săn/quest (active) hoặc idle ≤80% (offline)
		var active := (d % 3) != 0                     # ~2/3 ngày active
		var earn_active := rng.randi_range(400, 800)
		var earn := earn_active if active else int(EconomyService.clamp_idle(float(earn_active)))
		if not active and earn > int(earn_active * 0.8):
			offline_capped = false                     # vi phạm trần idle
		gold_in += earn
		gold += earn
		# sink: nâng cấp/sửa (tiêu bớt) — sink phải tồn tại (economy.md)
		var spend := mini(gold, rng.randi_range(300, 700))
		gold_out += spend
		gold -= spend
	var inflation := float(gold_in) / maxf(1.0, float(gold_out))
	return {"days": days, "gold_in": gold_in, "gold_out": gold_out, "ending_gold": gold,
		"inflation_ratio": inflation, "offline_capped": offline_capped}
