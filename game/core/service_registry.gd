extends Node
## Discovery dịch vụ trong thành (ai.md/build-ai §Building Integration).
## AI KHÔNG hardcode node path — query find_nearest(type, pos).

var _services: Array = []          # {type: String, pos: Vector2, node: Node}

func register_service(type: String, pos: Vector2, node: Node) -> void:
	_services.append({"type": type, "pos": pos, "node": node})

func unregister_node(node: Node) -> void:
	_services = _services.filter(func(s): return s["node"] != node)

func clear() -> void:
	_services.clear()

## Trả {"type","pos","node"} gần nhất theo type, hoặc {} nếu không có.
func find_nearest(type: String, from: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d := INF
	for s in _services:
		if s["type"] != type or not is_instance_valid(s["node"]):
			continue
		var d: float = from.distance_squared_to(s["pos"])
		if d < best_d:
			best_d = d
			best = s
	return best

func has_service(type: String) -> bool:
	for s in _services:
		if s["type"] == type and is_instance_valid(s["node"]):
			return true
	return false
