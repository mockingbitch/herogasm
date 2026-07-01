class_name ConflictResolver
extends RefCounted
## Giải quyết conflict cloud save. Mặc định highest_progress (giữ tiến trình cao hơn);
## manual_choice -> "" (mở ConflictDialog cho người chơi chọn). KHÔNG âm thầm ghi đè giá trị.

## meta = {updated_at, play_time, version}. Trả "local"/"cloud"/"" (chờ chọn tay).
static func resolve(local_meta: Dictionary, cloud_meta: Dictionary, policy: String = "highest_progress") -> String:
	match policy:
		"latest_timestamp":
			return "cloud" if int(cloud_meta.get("updated_at", 0)) > int(local_meta.get("updated_at", 0)) else "local"
		"highest_progress":
			return "cloud" if int(cloud_meta.get("play_time", 0)) > int(local_meta.get("play_time", 0)) else "local"
		"manual_choice":
			return ""
	return "local"
