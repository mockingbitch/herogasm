extends RefCounted
## Unit/Integration — StoryManager: complete_chapter, feature gate, prerequisite, unlock reward.

static func run(t) -> void:
	PlayerProfile.reset_progress()
	PlayerProfile.story = {}                        # ép init lại từ đầu

	# feature gate: rune_system bị gate bởi ch01 (chưa xong) -> khoá; feature không gate -> mở
	t.eq(StoryManager.is_feature_unlocked("rune_system"), false, "Feature_LockedBeforeGate")
	t.eq(StoryManager.is_feature_unlocked("codex"), true, "Feature_UngatedOpen")

	# prerequisite chặn nhảy chapter
	t.eq(StoryManager.can_start_chapter("ch00_awakening"), true, "FirstChapter_Startable")
	t.eq(StoryManager.can_start_chapter("ch02_silver_forest"), false, "Prereq_BlocksStart")

	# hoàn thành tuần tự ch00 -> ch01
	t.truthy(StoryManager.complete_chapter("ch00_awakening"), "Complete_Ch00")
	t.truthy(StoryManager.complete_chapter("ch01_broken_kingdom"), "Complete_Ch01")
	t.eq(StoryManager.is_chapter_completed("ch01_broken_kingdom"), true, "Ch01_Marked")

	# unlock gate mở sau khi hoàn thành chapter gate nó
	t.eq(StoryManager.is_feature_unlocked("rune_system"), true, "Feature_UnlockedAfterGate")

	# chống double-complete + prereq chặn hoàn thành vượt cấp
	t.eq(StoryManager.complete_chapter("ch01_broken_kingdom"), false, "NoDoubleComplete")
	t.eq(StoryManager.complete_chapter("ch03_guardian"), false, "Prereq_CompleteBlocked")

	# chapter kế đúng là ch02 (prereq ch01 đã xong)
	var cur := StoryManager.get_current_chapter()
	t.truthy(cur != null and str(cur.id) == "ch02_silver_forest", "CurrentChapter_IsCh02")
