class_name HeroGoalEvaluator
extends RefCounted
## Utility AI: chấm điểm 5 goal MVP (0..1), goal cao nhất thắng. Testable headless.
## Trật tự ưu tiên nổi lên từ điểm số: Survival(rest) > Maintenance(repair/potion) >
## Profit(hunt) > Idle (ai.md/build-ai §Decision Priority). Có hysteresis chống dao động.

const GOALS := ["rest", "repair", "buy_potion", "hunt", "idle"]
const HYSTERESIS := 0.05           # bonus giữ goal hiện tại, tránh oscillation

## Trả {"goal": String, "score": float, "reason": String, "scores": Dictionary}.
func evaluate(ctx: DecisionContext, current_goal: String = "") -> Dictionary:
	var scores := {
		"rest": _score_rest(ctx),
		"repair": _score_repair(ctx),
		"buy_potion": _score_buy_potion(ctx),
		"hunt": _score_hunt(ctx),
		"idle": 0.1,
	}
	var best := "idle"
	var best_score := -1.0
	for g in GOALS:
		var s: float = scores[g]
		if g == current_goal:
			s += HYSTERESIS
		if s > best_score:
			best_score = s
			best = g
	return {"goal": best, "score": best_score, "reason": _reason(best, ctx), "scores": scores}

# --- considerations -------------------------------------------------------
## Nghỉ: khẩn khi HP thấp; vừa khi stamina thấp. Sống còn -> ưu tiên cao nhất.
func _score_rest(ctx: DecisionContext) -> float:
	if ctx.is_ko:
		return 1.0
	var by_hp := _below(ctx.hp_pct, ctx.rest_threshold)
	var by_stam := _below(ctx.stamina01, 0.25) * 0.7
	return maxf(by_hp, by_stam)

## Sửa đồ: KHÔNG săn với gear hỏng. Cần gold. Vượt hunt khi durability thấp.
func _score_repair(ctx: DecisionContext) -> float:
	if ctx.durability01 >= ctx.repair_threshold:
		return 0.0
	if ctx.repair_cost > 0 and ctx.gold < ctx.repair_cost:
		return 0.0
	if ctx.durability01 <= 0.0:
		return 0.95
	return _below(ctx.durability01, ctx.repair_threshold) * 0.9

## Mua potion: khi hết potion + đủ gold -> restock trước khi săn.
func _score_buy_potion(ctx: DecisionContext) -> float:
	if ctx.potion_count > 0:
		return 0.0
	if ctx.potion_price > 0 and ctx.gold < ctx.potion_price:
		return 0.0
	return 0.55

## Săn: goal lợi nhuận nền. 0 nếu không đủ điều kiện (hp/stamina/durability/energy).
func _score_hunt(ctx: DecisionContext) -> float:
	if ctx.is_ko:
		return 0.0
	if ctx.hp_pct < 0.25 or ctx.stamina01 < 0.1 or ctx.durability01 <= 0.0:
		return 0.0
	if ctx.energy <= 0:
		return 0.0
	if ctx.inventory_full():
		return 0.0
	return clampf(0.5 * ctx.aggression, 0.0, 0.9)

# --- helpers --------------------------------------------------------------
## Trả 0 khi v>=thr, tiến tới 1 khi v->0 (mức độ "dưới ngưỡng").
func _below(v: float, thr: float) -> float:
	if thr <= 0.0 or v >= thr:
		return 0.0
	return clampf((thr - v) / thr, 0.0, 1.0)

func _reason(goal: String, ctx: DecisionContext) -> String:
	match goal:
		"rest": return "KO/hồi phục" if ctx.is_ko else "HP/stamina thấp"
		"repair": return "gear sắp hỏng"
		"buy_potion": return "hết potion"
		"hunt": return "đi săn kiếm loot"
		_: return "chờ"
