extends Node
## Scheduler tập trung cho AI (ai.md §Scheduler, performance.md). KHÔNG hero nào think mỗi frame.
## Round-robin theo tick-budget: mỗi frame chỉ xử lý tối đa `max_per_frame` brain ĐẾN HẠN.
## Brain phải có: var think_interval:float, var _ai_accum:float, func ai_tick().

var max_per_frame: int = 8
var _brains: Array = []
var _cursor: int = 0

func register(brain: Object) -> void:
	if not _brains.has(brain):
		if not ("think_interval" in brain) or not ("_ai_accum" in brain):
			push_warning("AIScheduler: brain thiếu think_interval/_ai_accum")
		_brains.append(brain)

func unregister(brain: Object) -> void:
	_brains.erase(brain)

func count() -> int:
	return _brains.size()

func _process(delta: float) -> void:
	var n := _brains.size()
	if n == 0:
		return
	# dồn thời gian cho mọi brain (rẻ), rồi xử lý tối đa max_per_frame brain đến hạn
	var invalid: Array = []
	for b in _brains:
		if not is_instance_valid(b):
			invalid.append(b)
			continue
		b._ai_accum += delta
	for b in invalid:
		_brains.erase(b)
	n = _brains.size()
	if n == 0:
		return
	var processed := 0
	var i := 0
	while i < n and processed < max_per_frame:
		var idx := (_cursor + i) % n
		var b: Object = _brains[idx]
		if is_instance_valid(b) and b._ai_accum >= b.think_interval:
			b._ai_accum = 0.0
			b.ai_tick()
			processed += 1
		i += 1
	_cursor = (_cursor + maxi(1, processed)) % n
