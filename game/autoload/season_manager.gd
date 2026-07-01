extends Node
## SeasonManager (P0 stub) — nền cho hệ Season↔Story (Abyss) ở P5.
## P0 chỉ giữ API; SeasonDef/rotation/battle-pass hiện thực ở P5.

var current_season_id: String = ""

func is_season_active() -> bool:
	return current_season_id != ""

## Trả SeasonDef của mùa hiện tại (null ở P0).
func get_season() -> Resource:
	return null
