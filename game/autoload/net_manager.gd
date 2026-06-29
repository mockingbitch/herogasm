extends Node
## Lớp online (~30%). OFFLINE-FIRST: mọi hàm phải an toàn khi không có mạng.
## Hiện là stub. Phase 6 sẽ nối Supabase (auth + leaderboard + cloud save).
## Xem docs/ARCHITECTURE.md mục 4–5.

var is_online: bool = false

## Lấy seed của tuần cho chế độ Trial. Offline: tự suy ra cục bộ (tạm).
func weekly_seed() -> int:
	# TODO: lấy từ server để mọi người chơi cùng seed. Tạm cố định để test.
	return 20260629

func submit_score(_mode: String, _seed: int, _score: int) -> void:
	if not is_online:
		# TODO: hàng đợi cục bộ, gửi lại khi có mạng.
		return
	# TODO: gọi Supabase Edge Function (không insert trực tiếp).

func fetch_leaderboard(_mode: String, _season: String) -> Array:
	if not is_online:
		return []
	# TODO: SELECT từ bảng leaderboards (đọc công khai).
	return []

func push_cloud_save(_payload: Dictionary) -> void:
	if not is_online:
		return
	# TODO: upsert vào cloud_saves (RLS theo user).

func pull_cloud_save() -> Dictionary:
	if not is_online:
		return {}
	# TODO
	return {}
