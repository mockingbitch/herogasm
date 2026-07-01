class_name FinalStats
extends RefCounted
## Snapshot chỉ số cuối (bất biến sau finalize). Flat cộng trước, percent gom rồi NHÂN MỘT LẦN.
## sources: layer -> {key -> delta} để breakdown telemetry/UI (balancing.md: biết % power từ đâu).

var flat: Dictionary = {}      # key -> tổng flat
var percent: Dictionary = {}   # key -> tổng hệ số (0.15 = +15%)
var value: Dictionary = {}     # key -> kết quả cuối (sau nhân + clamp)
var sources: Dictionary = {}   # layer -> {key -> delta}

func add_flat(key: String, v: float, layer: String = "base") -> void:
	if v == 0.0:
		return
	flat[key] = float(flat.get(key, 0.0)) + v
	_track(layer, key, v)

func add_percent(key: String, v: float, layer: String = "misc") -> void:
	if v == 0.0:
		return
	percent[key] = float(percent.get(key, 0.0)) + v
	_track(layer, key + "%", v)

func add_flat_dict(d: Dictionary, layer: String = "misc") -> void:
	for k in d:
		add_flat(str(k), float(d[k]), layer)

func add_percent_dict(d: Dictionary, layer: String = "misc") -> void:
	for k in d:
		add_percent(str(k), float(d[k]), layer)

## value = flat * (1 + Σpercent). Gọi MỘT lần sau khi mọi source đã cộng.
func finalize() -> void:
	for key in flat:
		value[key] = float(flat[key]) * (1.0 + float(percent.get(key, 0.0)))

func get_v(key: String, def_val: float = 0.0) -> float:
	return float(value.get(key, def_val))

func _track(layer: String, key: String, v: float) -> void:
	if not sources.has(layer):
		sources[layer] = {}
	sources[layer][key] = float(sources[layer].get(key, 0.0)) + v
