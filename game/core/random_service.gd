extends Node
## Dịch vụ RNG tập trung (autoload). AI, loot, Battle Engine CHỈ dùng service này,
## KHÔNG gọi randi()/randf() toàn cục trực tiếp (rule gdscript.md §Randomness) —
## để có thể seed và tái lập (deterministic) cho test/replay/PvP.

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

## Seed cố định (dùng trong test/replay để tái lập kết quả).
func seed_with(s: int) -> void:
	rng.seed = s

func randf() -> float:
	return rng.randf()

func randf_range(a: float, b: float) -> float:
	return rng.randf_range(a, b)

func randi_range(a: int, b: int) -> int:
	return rng.randi_range(a, b)

func randi() -> int:
	return int(rng.randi())
