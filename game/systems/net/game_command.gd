class_name GameCommand
extends RefCounted
## Lệnh gameplay có giá trị (leaderboard/guild/pvp/reward/save). Serializable, ID-based
## (multiplayer.md). command_id để server DEDUPE -> replay khi reconnect KHÔNG double reward.

var command_id: String = ""
var type: StringName = &""              # "lb-submit"/"guild-boss-hit"/"pvp-submit"/"claim-reward"/"save-upload"...
var player_id: String = ""
var session_id: String = ""
var timestamp: int = 0                   # game-time tick (KHÔNG OS time — multiplayer.md)
var payload: Dictionary = {}
var client_version: String = ""
var schema_version: int = 1

func _init(type_: String = "", payload_: Dictionary = {}, command_id_: String = "") -> void:
	type = StringName(type_)
	payload = payload_
	command_id = command_id_

func to_dict() -> Dictionary:
	return {"command_id": command_id, "type": str(type), "player_id": player_id,
		"session_id": session_id, "timestamp": timestamp, "payload": payload,
		"client_version": client_version, "schema_version": schema_version}

static func from_dict(d: Dictionary) -> GameCommand:
	var c := GameCommand.new()
	c.command_id = str(d.get("command_id", ""))
	c.type = StringName(str(d.get("type", "")))
	c.player_id = str(d.get("player_id", ""))
	c.session_id = str(d.get("session_id", ""))
	c.timestamp = int(d.get("timestamp", 0))
	c.payload = d.get("payload", {}) if typeof(d.get("payload")) == TYPE_DICTIONARY else {}
	c.client_version = str(d.get("client_version", ""))
	c.schema_version = int(d.get("schema_version", 1))
	return c
