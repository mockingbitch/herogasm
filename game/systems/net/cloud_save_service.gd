class_name CloudSaveService
extends RefCounted
## Cloud save (P6): upload/download qua Edge (verify checksum + chống progress regression), phát hiện
## conflict (updated_at server > base) -> ConflictResolver/UI. KHÔNG tự ghi đè tiến trình giá trị.

static var _base: Dictionary = {}        # account -> updated_at đã đồng bộ lần cuối (phát hiện conflict)

static func upload() -> CommandResult:
	var acc := _acc()
	var blob := PlayerProfile.to_dict()
	var checksum := str(JSON.stringify(blob).hash())
	var res := NetManager.send("save-upload", {
		"account_id": acc, "blob": blob, "checksum": checksum,
		"save_version": SaveManager.SAVE_VERSION, "play_time": PlayerProfile.play_time,
		"base_updated_at": int(_base.get(acc, 0))})
	if res.code == CommandResult.Code.OK:
		if bool(res.data.get("conflict", false)):
			EventBus.cloud_conflict_detected.emit(res.data.get("cloud_meta", {}))
			Telemetry.track(&"conflict_detected", &"network", {})
		else:
			_base[acc] = int(res.data.get("updated_at", 0))
			Telemetry.track(&"cloud_save_upload", &"network", {})
	return res

static func download() -> Dictionary:
	var r = NetManager.query("save-download", {"account_id": _acc()})
	if typeof(r) == TYPE_DICTIONARY and bool(r.get("exists", false)):
		_base[_acc()] = int((r.get("meta", {}) as Dictionary).get("updated_at", 0))
		Telemetry.track(&"cloud_save_download", &"network", {})
		return r
	return {}

## Chấp nhận bản cloud: nạp blob vào PlayerProfile (dùng khi ConflictResolver chọn "cloud").
static func apply_cloud(blob: Dictionary) -> void:
	PlayerProfile.from_dict(blob)
	PlayerProfile._emit_all()
	PlayerProfile.save()

static func _acc() -> String:
	return PlayerProfile.account_id if PlayerProfile.account_id != "" else "local"
