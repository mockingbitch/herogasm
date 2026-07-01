class_name RewardProtection
extends RefCounted
## Chống double-claim (build-loot §Reward Protection). claim_id = idempotency key do caller sinh.
## `claimed` là ref tới PlayerProfile._claimed_ids (được SAVE để bền qua reload).

static func reward_hash(receiver_id: String, source_id: String, payload: Dictionary) -> String:
	return str(JSON.stringify({"r": receiver_id, "s": source_id, "p": payload}).hash())

func is_claimed(claimed: Dictionary, claim_id: String) -> bool:
	return claimed.has(claim_id)

## Trả false nếu đã claim (double). Caller PHẢI check is_claimed trước khi grant.
func mark(claimed: Dictionary, claim_id: String, hash_str: String) -> bool:
	if claimed.has(claim_id):
		return false
	claimed[claim_id] = hash_str
	return true
