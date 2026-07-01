class_name ExpeditionState
extends Resource
## Trạng thái 1 expedition idle (serializable). Tất định qua `seed`; idempotent qua `resolved`.

var id: String = ""
var hero_id: String = ""
var zone_id: String = ""
var start_epoch: float = 0.0
var end_epoch: float = 0.0
var seed: int = 0
var resolved: bool = false
var offline: bool = false
var result_stars: int = 0
var outcome: String = "pending"   # pending/win/ko

func to_dict() -> Dictionary:
	return {
		"id": id, "hero_id": hero_id, "zone_id": zone_id,
		"start_epoch": start_epoch, "end_epoch": end_epoch, "seed": seed,
		"resolved": resolved, "offline": offline,
		"result_stars": result_stars, "outcome": outcome,
	}

static func from_dict(d: Dictionary) -> ExpeditionState:
	var e := ExpeditionState.new()
	e.id = str(d.get("id", ""))
	e.hero_id = str(d.get("hero_id", ""))
	e.zone_id = str(d.get("zone_id", ""))
	e.start_epoch = float(d.get("start_epoch", 0.0))
	e.end_epoch = float(d.get("end_epoch", 0.0))
	e.seed = int(d.get("seed", 0))
	e.resolved = bool(d.get("resolved", false))
	e.offline = bool(d.get("offline", false))
	e.result_stars = int(d.get("result_stars", 0))
	e.outcome = str(d.get("outcome", "pending"))
	return e
