class_name SeasonalShopService
extends RefCounted
## Shop seasonal đổi cosmetic/material bằng seasonal currency (hết hạn cuối season — economy.md).
## Stock data-driven ở Database.seasonal_shops[shop_id]: [{cost, currency, reward{type,id,amount}}].

static func stock(shop_id: String) -> Array:
	return Database.get_seasonal_shop(shop_id)

static func purchase(shop_id: String, index: int) -> Dictionary:
	var items := stock(shop_id)
	if index < 0 or index >= items.size():
		return {"ok": false, "reason": "bad_index"}
	var it: Dictionary = items[index]
	var cur := str(it.get("currency", ""))
	var cost := int(it.get("cost", 0))
	if not PlayerProfile.spend_currency(cur, cost):
		return {"ok": false, "reason": "insufficient"}
	PlayerProfile.grant_reward(it.get("reward", {}))
	Telemetry.log_event("Season", "seasonal_shop_purchase", {"shop": shop_id, "index": index, "cost": cost, "currency": cur})
	PlayerProfile.save()
	return {"ok": true, "reward": it.get("reward", {})}

## Xoá currency seasonal khi rollover (auto-convert/remove leftover — ECONOMY.md).
static func expire_currency(currency_id: String) -> int:
	var left := PlayerProfile.currency_amount(currency_id)
	if left > 0:
		PlayerProfile.spend_currency(currency_id, left)
		Telemetry.log_event("Season", "seasonal_currency_expired", {"currency": currency_id, "amount": left})
	return left
