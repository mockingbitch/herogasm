class_name CommandResult
extends RefCounted
## Kết quả 1 command từ backend (Edge Function / MockBackend). Server là single source of truth.

enum Code { OK, QUEUED, REJECTED_VERIFY, REJECTED_DUP, REJECTED_RATE, ERROR }

var code: int = Code.OK
var reason: String = ""
var data: Dictionary = {}

func _init(code_: int = Code.OK, data_: Dictionary = {}, reason_: String = "") -> void:
	code = code_
	data = data_
	reason = reason_

func ok() -> bool:
	return code == Code.OK or code == Code.QUEUED

static func rejected(reason_: String, code_: int = Code.REJECTED_VERIFY) -> CommandResult:
	return CommandResult.new(code_, {}, reason_)
