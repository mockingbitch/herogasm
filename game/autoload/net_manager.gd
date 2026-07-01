extends Node
## Net (autoload) — lớp online P6, OFFLINE-FIRST. Sở hữu backend (MockBackend = mirror Edge Function;
## production thay bằng SupabaseClient HTTP), command queue offline, reconnect replay IDEMPOTENT.
## Game chơi trọn vẹn khi offline; online chỉ verify + là source-of-truth cho giá trị cạnh tranh.
## KHÔNG block main thread ở bản thật (HTTPRequest pool); MockBackend đồng bộ cho headless test.

enum ConnectionState { OFFLINE, CONNECTING, ONLINE, DEGRADED }

var state: int = ConnectionState.OFFLINE
var backend: MockBackend
var config: NetworkConfig
var _queue: Array[GameCommand] = []
var _cmd_seq: int = 0

func _ready() -> void:
	backend = MockBackend.new()
	config = NetworkConfig.new()                 # bản thật: load .tres per-env + env var secret
	if config.enable_online:
		go_online()

# --- connection ------------------------------------------------------------
func is_online() -> bool:
	return state == ConnectionState.ONLINE

func _set_state(s: int) -> void:
	if state == s:
		return
	state = s
	EventBus.net_state_changed.emit(s)
	Telemetry.track(&"connection_state", &"network", {"state": s})

func go_online() -> void:
	_set_state(ConnectionState.ONLINE)
	if not _queue.is_empty():
		_replay_queue()

func go_offline() -> void:
	_set_state(ConnectionState.OFFLINE)

# --- command submit (offline-first) ---------------------------------------
func next_command_id() -> String:
	_cmd_seq += 1
	return "cmd_%d_%d" % [TimeService.get_tick(), _cmd_seq]

## Gửi command có giá trị. Online -> backend verify. Offline -> queue (game vẫn chạy local).
func submit(cmd: GameCommand) -> CommandResult:
	if cmd.command_id == "":
		cmd.command_id = next_command_id()
	cmd.player_id = _account_id()
	cmd.timestamp = TimeService.get_tick()
	cmd.client_version = str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	Telemetry.track(&"command_sent", &"network", {"type": str(cmd.type)})
	if is_online():
		var res := backend.invoke(cmd)
		if not res.ok():
			Telemetry.track(&"command_failed", &"network", {"type": str(cmd.type), "reason": res.reason})
		return res
	_queue.append(cmd)
	return CommandResult.new(CommandResult.Code.QUEUED, {}, "offline_queued")

## Tiện dụng: dựng GameCommand rồi submit.
func send(type: String, payload: Dictionary, command_id: String = "") -> CommandResult:
	return submit(GameCommand.new(type, payload, command_id))

## Read-only fetch (leaderboard/guild). Offline -> rỗng (game không phụ thuộc).
func query(fn: String, payload: Dictionary) -> Variant:
	if not is_online():
		return null
	match fn:
		"lb-top": return backend.top(str(payload.get("season_key", "s0")), int(payload.get("n", 10)))
		"save-download": return backend.invoke(GameCommand.new("save-download", payload)).data
		_: return null

# --- reconnect replay (dedupe theo command_id -> không double reward) -------
func _replay_queue() -> void:
	var replayed := 0
	for cmd in _queue:
		backend.invoke(cmd)                      # backend dedupe bằng command_id
		replayed += 1
	_queue.clear()
	if replayed > 0:
		Telemetry.track(&"reconnect_success", &"network", {"replayed": replayed})

func queued_count() -> int:
	return _queue.size()

func pending_commands() -> Array:
	return _queue

func clear_queue() -> void:
	_queue.clear()

func _account_id() -> String:
	return PlayerProfile.account_id if PlayerProfile.account_id != "" else "local"

# --- legacy (P1 stub) — giữ tương thích; nay route qua hệ mới -------------
func weekly_seed() -> int:
	return 20260629
