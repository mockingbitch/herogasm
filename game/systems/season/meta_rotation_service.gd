class_name MetaRotationService
extends RefCounted
## Áp meta rotation của Season lên rune/equip/synergy (KHÔNG hero base). SeasonManager set khi start,
## clear khi rollover. StatAggregator đọc rules qua team_ctx["meta"]; synergy qua team_context.
## Giữ rules đã validate — power hero không đổi nếu không sở hữu rune/set/synergy được buff.

var _rules: Dictionary = {}

func set_rotation(rules: Dictionary) -> bool:
	if not MetaRotationValidator.is_valid(rules):
		return false
	_rules = rules.duplicate(true)
	return true

func clear() -> void:
	_rules = {}

func is_active() -> bool:
	return not _rules.is_empty()

func rules() -> Dictionary:
	return _rules

## {stat:pct} cộng thêm nếu synergy_id đang active (dùng trong team_context).
func synergy_percent_for(synergy_id: String) -> Dictionary:
	var out: Dictionary = {}
	for b in _rules.get("synergy_buffs", []):
		if str(b.get("synergy_id", "")) == synergy_id:
			for k in b.get("bonus", {}):
				out[str(k)] = float(out.get(k, 0.0)) + float(b["bonus"][k])
	return out
