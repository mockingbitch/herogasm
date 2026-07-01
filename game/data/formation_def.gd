class_name FormationDef
extends Resource
## Đội hình (data-driven) — dùng CHUNG stage + arena. slots = toạ độ lưới tương đối
## (KHÔNG hardcode pixel). Buff theo hàng: front (y==0) chịu đòn +def, back (y>0) +tốc/atk.

@export var id: StringName = &""
@export var display_name: String = ""
@export var slots: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
@export var front_buff: Dictionary = {"defense": 0.20}          # {stat_key: pct}
@export var back_buff: Dictionary = {"attack": 0.10, "speed": 0.10}
@export var target_bias: Dictionary = {}                        # điều chỉnh ưu tiên bị nhắm theo slot (hook)

func row_of(slot_idx: int) -> int:
	if slot_idx < 0 or slot_idx >= slots.size():
		return 1
	return 0 if slots[slot_idx].y == 0 else 1
