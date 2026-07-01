class_name NetworkConfig
extends Resource
## Cấu hình lớp online (P6). Secret KHÔNG commit — anon_key/url nạp từ env ở build thật.
## enable_online=false mặc định: game chơi trọn vẹn offline; online là lớp phủ (multiplayer.md).

@export var supabase_url: String = ""
@export var anon_key: String = ""
@export var env: StringName = &"dev"                 # dev/staging/prod
@export var command_timeout_ms: int = 8000
@export var retry_max: int = 3
@export var retry_backoff_ms: int = 500
@export var telemetry_flush_sec: float = 30.0
@export var enable_online: bool = false

func is_prod() -> bool:
	return env == &"prod"
