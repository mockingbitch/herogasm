extends Node
## StoryManager (autoload) — máy trạng thái campaign: arc/chapter hiện tại, cờ đã-hoàn-thành,
## story-unlock gate (mở tính năng theo tiến trình). Tiến trình lưu trong PlayerProfile.story.
## KHÔNG chứa logic UI (signal-rules.md); phát EventBus signal khi complete/unlock.

func _ready() -> void:
	_ensure_init()

func _ensure_init() -> void:
	var st: Dictionary = PlayerProfile.story
	if st.is_empty():
		PlayerProfile.story = {"arc": "prologue", "current_chapter": _first_chapter_id(),
			"completed": {}, "features": {}}

func _story() -> Dictionary:
	_ensure_init()
	return PlayerProfile.story

# --- query ----------------------------------------------------------------
func is_chapter_completed(id: String) -> bool:
	return bool((_story().get("completed", {}) as Dictionary).get(id, false))

func current_arc() -> String:
	return str(_story().get("arc", "prologue"))

## Chapter kế cần chơi: order_index nhỏ nhất chưa hoàn thành & prereq đã xong. null nếu hết.
func get_current_chapter() -> ChapterDef:
	for cd in Database.chapters_ordered():
		if is_chapter_completed(str(cd.id)):
			continue
		if cd.prerequisite_id != &"" and not is_chapter_completed(str(cd.prerequisite_id)):
			continue
		return cd
	return null

func can_start_chapter(id: String) -> bool:
	var cd: ChapterDef = Database.get_chapter_def(id)
	if cd == null or is_chapter_completed(id):
		return false
	return cd.prerequisite_id == &"" or is_chapter_completed(str(cd.prerequisite_id))

# --- feature gate ----------------------------------------------------------
## Tính năng bị GATE bởi 1 chapter chưa xong -> khóa. Không chapter nào gate -> mở mặc định.
func is_feature_unlocked(key: String) -> bool:
	if bool((_story().get("features", {}) as Dictionary).get(key, false)):
		return true
	return not _is_feature_gated(key)

func _is_feature_gated(key: String) -> bool:
	for cd in Database.chapter_defs.values():
		if str(cd.unlock_gate) == key:
			return true
	return false

func unlock_feature(key: String) -> void:
	if key == "":
		return
	var feats: Dictionary = _story().get("features", {})
	if bool(feats.get(key, false)):
		return
	feats[key] = true
	PlayerProfile.story["features"] = feats
	Telemetry.log_event("Story", "story_feature_unlocked", {"key": key})
	EventBus.story_feature_unlocked.emit(key)

# --- transitions -----------------------------------------------------------
func start_chapter(id: String) -> bool:
	if not can_start_chapter(id):
		return false
	PlayerProfile.story["current_chapter"] = id
	PlayerProfile.story["arc"] = str(Database.get_chapter_def(id).arc)
	Telemetry.log_event("Story", "story_chapter_started", {"chapter": id})
	EventBus.story_chapter_started.emit(id)
	return true

## Hoàn thành chapter: mark + grant unlock_rewards + mở feature gate + advance arc. Chống double.
func complete_chapter(id: String) -> bool:
	if is_chapter_completed(id):
		return false
	var cd: ChapterDef = Database.get_chapter_def(id)
	if cd == null:
		return false
	if cd.prerequisite_id != &"" and not is_chapter_completed(str(cd.prerequisite_id)):
		return false
	var completed: Dictionary = _story().get("completed", {})
	completed[id] = true
	PlayerProfile.story["completed"] = completed
	for r in cd.unlock_rewards:
		PlayerProfile.grant_reward(r)
	if cd.unlock_gate != &"":
		unlock_feature(str(cd.unlock_gate))
	var nxt := get_current_chapter()
	PlayerProfile.story["current_chapter"] = str(nxt.id) if nxt != null else ""
	PlayerProfile.story["arc"] = str(nxt.arc) if nxt != null else str(cd.arc)
	Telemetry.log_event("Story", "story_chapter_completed", {"chapter": id})
	EventBus.story_chapter_completed.emit(id)
	PlayerProfile.save()
	return true

func completed_count() -> int:
	return (_story().get("completed", {}) as Dictionary).size()

# --- helpers ---------------------------------------------------------------
func _first_chapter_id() -> String:
	var ordered := Database.chapters_ordered()
	return str(ordered[0].id) if ordered.size() > 0 else ""
