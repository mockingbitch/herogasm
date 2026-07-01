extends RefCounted
## Integration — Cloud save: checksum integrity, chống progress regression, conflict detect + resolver.

static func run(t) -> void:
	NetManager.backend = MockBackend.new()
	NetManager.go_online()
	CloudSaveService._base.clear()
	PlayerProfile.reset_progress()
	PlayerProfile.account_id = "acc_cloud"

	# --- checksum integrity fail ---
	var bad := NetManager.send("save-upload", {"account_id": "acc_cloud", "blob": {"a": 1},
		"checksum": "WRONG", "play_time": 10, "base_updated_at": 0})
	t.eq(bad.code, CommandResult.Code.REJECTED_VERIFY, "Cloud_ChecksumFail")

	# --- upload OK ---
	PlayerProfile.play_time = 100
	var up := CloudSaveService.upload()
	t.eq(up.code, CommandResult.Code.OK, "Cloud_UploadOk")
	t.eq(bool(up.data.get("conflict", false)), false, "Cloud_NoConflictFirst")

	# --- progress regression rejected ---
	PlayerProfile.play_time = 50
	var reg := CloudSaveService.upload()
	t.eq(reg.code, CommandResult.Code.REJECTED_VERIFY, "Cloud_ProgressRegressionRejected")

	# --- conflict detect (base cũ hơn server) ---
	var blob := PlayerProfile.to_dict()
	var conf := NetManager.send("save-upload", {"account_id": "acc_cloud", "blob": blob,
		"checksum": str(JSON.stringify(blob).hash()), "play_time": 200, "base_updated_at": 0})
	t.truthy(bool(conf.data.get("conflict", false)), "Cloud_ConflictDetected")

	# --- ConflictResolver ---
	t.eq(ConflictResolver.resolve({"play_time": 50}, {"play_time": 100}, "highest_progress"), "cloud", "Resolver_HigherProgressCloud")
	t.eq(ConflictResolver.resolve({"play_time": 100}, {"play_time": 50}, "highest_progress"), "local", "Resolver_HigherProgressLocal")
	t.eq(ConflictResolver.resolve({"updated_at": 1}, {"updated_at": 2}, "latest_timestamp"), "cloud", "Resolver_LatestTimestamp")
	t.eq(ConflictResolver.resolve({}, {}, "manual_choice"), "", "Resolver_ManualDefers")

	# --- anti-cheat integrity helper ---
	var b2 := {"x": 1, "y": 2}
	t.truthy(AntiCheatValidator.save_integrity(b2, str(JSON.stringify(b2).hash())), "AntiCheat_IntegrityOk")
	t.eq(AntiCheatValidator.save_integrity(b2, "nope"), false, "AntiCheat_IntegrityFail")
	PlayerProfile.account_id = ""
