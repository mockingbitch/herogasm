# Phase 7 — Cửa Trước: Lãnh Chúa · Tân Thủ · Nhiệm Vụ · Minigame

> Tài liệu **plan** (chưa build) theo `prompts/feature.md`, chi tiết **tới từng unit** (file/class/API/field/save/EventBus/test).
> Hiện thực hoá **tầng cửa trước** mô tả trong `docs/scripts/FLOW.md` (mục A–D + H).
> Trạng thái: **CHƯA BẮT ĐẦU**. Baseline: P0–P6 xong, save v7, 464 test xanh.

---

## 1. Mục đích & trải nghiệm

P1–P6 đã dựng xong **bộ máy mô phỏng + nội dung + online** (hero tự trị, expedition, gacha, build, boss, arena, story/season/event, net). Nhưng **người chơi thật chưa có "cửa trước"**: không có tạo nhân vật, không tân thủ, không hệ nhiệm vụ ngày/tuần, không minigame. P7 xây đúng lớp đó — biến "bộ máy" thành "đời chơi".

Ánh xạ vào `FLOW.md`:

| FLOW | P7 giao |
|---|---|
| A. Màn Mở (0–15') | Tạo Lãnh Chúa → prologue dialogue → tặng hero → trận đầu có dẫn → triệu hồi đầu đảm bảo |
| B. Tân Thủ (Lord 1–15) | Chuỗi tân thủ progressive-disclosure, mỗi bước mở 1 feature + thưởng |
| C. Tốt Nghiệp | Điều kiện Lord≥15 + mở hết lõi → retire chuỗi tân thủ → Sổ Mục Tiêu |
| D. Nhịp ngày/tuần | Hệ Nhiệm Vụ (daily/weekly/milestone/achievement) + điểm-HĐ → rương |
| H. Chống nhàm | Minigame (Câu Cá + Rèn Nhịp) + Raid Dungeon (lát cuối) |

Người chơi vẫn **không điều khiển hero trong trận**. P7 chỉ thêm lớp **meta/quản lý** quanh sim đã có.

---

## 2. Ràng buộc kiến trúc (BẮT BUỘC đọc trước khi code)

**Tái dùng, KHÔNG dựng lại.** Những thứ đã tồn tại và P7 phải dùng lại nguyên:

- Reward: mọi phần thưởng đi qua **`PlayerProfile.grant_reward(reward:{type,id,amount})`** (router chung P5). Không tự cộng gold/gem rời rạc.
- Idempotency: dùng **`PlayerProfile._reward_guard` (RewardProtection)** + `_claimed_ids` để chống nhận trùng (giống event/battle-pass).
- RNG tất định: mọi random qua **`RandomService.seed_with(seed)`**. Không `randf()` trực tiếp.
- Scheduler: nhịp thời gian qua **`TimeService.register_slice(cb, interval)`** + `game_day()` / `day_of_week()` cho reset ngày/tuần. KHÔNG `_process` polling.
- Feature-unlock **DÙNG CHUNG một registry**: `PlayerProfile.story.features` (đã có, đọc qua `StoryManager.is_feature_unlocked(key)`). Tutorial + Story **cùng ghi vào đây**; HUD gate nav/panel theo nó. Không tạo registry unlock thứ hai (Architect wins).
- Save root = `PlayerProfile.to_dict()` block `player`. Thêm key mới ở đây. **Bump `SAVE_VERSION` 7→8 MỘT LẦN** (trong S0), seed sẵn mọi block rỗng cho các slice sau dùng — không bump nhiều lần.
- Def mới: `data/*_def.gd` (`class_name X extends Resource`), seed trong **`data/content_p7.gd` (`ContentP7.build(db)`)**, gọi `ContentP7.build(self)` ở cuối `database.gd:_ready()`, thêm getter + `*_ids()`.
- Autoload mới: khai trong `project.godot [autoload]`, **thứ tự sau `PlayerProfile`** và sau manager mà nó subscribe (`StoryManager`/`EventManager`). Mỗi service `import_world()`/đọc state trong `_ready`.
- Test: file `game/tests/unit/test_*.gd` có `static func run(t)`, **thêm thủ công vào mảng `SUITES`** trong `test_runner.gd`. Assert: `t.eq/truthy/approx`.
- Debug: mỗi hệ đăng ký lệnh qua `Debug.register_command(...)` (gate `ReleaseGate`).

**Bảo toàn 464 test cũ:** `PlayerProfile.new_game()` HIỆN seed 5 hero + 800 gem (test phụ thuộc). **KHÔNG sửa `new_game()`.** Thêm **`new_account()`** riêng cho luồng thật (Lord chưa tạo, seed tối thiểu). Boot flow dùng `new_account()`; test cũ giữ `new_game()`.

---

## 3. Phân rã theo Slice (thứ tự build)

| Slice | Tên | Phụ thuộc | Ship được độc lập? |
|---|---|---|---|
| **S0** | Nền: Lãnh Chúa + Lord Level/Perk + save v8 | — | Có (Lord panel chạy) |
| **S1** | Dialogue Runner + View | S0 | Có (chạy 1 đoạn thoại) |
| **S2** | Hệ Nhiệm Vụ (daily/weekly/milestone/achievement + điểm-HĐ) | S0 | Có (quest panel chạy) |
| **S3** | Tân Thủ (progressive disclosure + tốt nghiệp) | S0,S1,S2 | Có |
| **S4** | Màn Mở first-session (tạo Lord → prologue → hero → trận → triệu hồi) | S0,S1,S3 | Có (luồng new-account) |
| **S5** | Minigame (Câu Cá + Rèn Nhịp) | S0,S2 | Có |
| **S6** | Raid Dungeon (composition trên Boss/Stage) | S0 | Có |

DAG: `S0 → {S1, S2, S6}`; `S1,S2 → S3`; `S3 → S4`; `S2 → S5`.

---

## 4. S0 — Nền: Lãnh Chúa + Lord Progression + Save v8

**Mục tiêu:** người chơi = **Lãnh Chúa** (avatar quản lý, không combat), có Lord Level (cấp tài khoản, cổng mở khoá) + Đặc Ân (buff tiện ích no-P2W). Bump save v8 seed sẵn mọi block P7.

### 4.1 Data units

| Unit (path) | class_name / extends | Field (name: type) | Ghi chú |
|---|---|---|---|
| `game/data/lord_perk_def.gd` | `LordPerkDef extends Resource` | `id:String`, `display_name:String`, `description:String`, `unlock_level:int=1`, `effect_key:String`, `effect_value:float`, `icon_color:Color` | `effect_key` ∈ {`inn_heal_rate`,`loot_gold_pct`,`expedition_slots`,`energy_cap`,`daily_quest_slots`...} |

`effect_key` là **buff tiện ích** — áp ở tầng town/economy, **không** đụng FinalStats hero (giữ no-P2W). Cách áp:
- `expedition_slots` → cộng vào `MAX_EXPEDITIONS` trong `world.gd._dispatch_tick` (đọc `PlayerProfile.lord_perk_value("expedition_slots")`).
- `loot_gold_pct` → nhân ở `Hero._loot` / `grant_reward` gold.
- `energy_cap` → cộng `PlayerProfile.max_energy`.
- `inn_heal_rate` → nhân `heal_rate` service (đọc trong Building/ServiceRegistry).

### 4.2 System units

| Unit (path) | class_name / extends | Public API | Trả về |
|---|---|---|---|
| `game/systems/lord/lord_progression.gd` | `LordProgression extends Object` (static) | `xp_to_level(level:int) -> int`, `level_for_xp(total_xp:int) -> int`, `perks_unlocked_at(level:int) -> Array[LordPerkDef]` | thuần, tất định, test được |

Đường cong XP data-driven: đọc hằng từ `CombatConstants`/`economy_constants` hoặc thêm `lord_xp_base`/`lord_xp_growth` vào `EconomyConstants` (`.tres`). **Không hardcode.**

### 4.3 PlayerProfile — field & method mới

Thêm field (trong block `player` của `to_dict()`):

```
lord_created:bool=false
lord_name:String=""
lord_portrait_id:String="lord_default"
lord_crest_id:String="crest_default"
lord_level:int=1
lord_xp:int=0
lord_perks:Array[String]=[]        # perk ids đã unlock
# (các block slice sau, seed rỗng ở v8):
tutorial:Dictionary={}             # S3
quests:Dictionary={}               # S2
minigames:Dictionary={}            # S5
raids:Dictionary={}                # S6
```

Method mới trên `PlayerProfile`:

| Method | Việc |
|---|---|
| `new_account() -> void` | Reset về fresh: `lord_created=false`, seed tối thiểu (0 hero, gems khởi điểm nhỏ, 0 quest), KHÔNG spawn roster. |
| `create_lord(name, portrait_id, crest_id) -> void` | Set `lord_created=true` + info, emit `EventBus.lord_created`. |
| `add_lord_xp(amount:int) -> void` | Cộng xp, tính level mới qua `LordProgression`, unlock perk mới, emit `lord_level_changed`/`lord_perk_unlocked`. |
| `lord_perk_value(effect_key:String) -> float` | Tổng effect_value của perk đã unlock theo key (0 nếu không có). |
| `has_lord_perk(id:String) -> bool` | — |

`grant_reward` mở rộng: thêm `type == "lord_xp"` → gọi `add_lord_xp`. (Quest/tutorial/boss cấp Lord XP qua router chung.)

### 4.4 Save v7 → v8

- `game/autoload/save_manager.gd`: `SAVE_VERSION = 8`; thêm `_migrate_v7_to_v8(d)` vào chain `_migrate` (sau v6→v7). Migration **thêm field mặc định** ở block `player`: `lord_created=false, lord_name="", lord_portrait_id="lord_default", lord_crest_id="crest_default", lord_level=1, lord_xp=0, lord_perks=[], tutorial={}, quests={}, minigames={}, raids={}`. **Không mất data.** Giữ `.bak` + checksum.
- `PlayerProfile.to_dict()`/`from_dict()`: đọc/ghi field mới (default an toàn khi thiếu).

### 4.5 EventBus signals mới (S0)

```
lord_created(name:String)
lord_level_changed(level:int)
lord_perk_unlocked(perk_id:String)
```

### 4.6 UI units (S0)

| Unit (path) | class_name / extends | Hiển thị / điều khiển |
|---|---|---|
| `game/ui/lord_panel.gd` | `LordPanel extends Control` | Chân dung + tên + huy hiệu Lãnh Chúa, Lord Level + thanh XP, danh sách Đặc Ân (đã mở / khoá theo level). Đọc-only. |

Wiring: `GameHud._make_panels` thêm `_lord_panel`; top-bar thêm **avatar Lãnh Chúa** (chạm → `_show(_lord_panel)`). Top-bar cũng hiển thị Lord Level.

### 4.7 ContentP7 seeds (S0)

`game/data/content_p7.gd` `ContentP7.build(db)`: seed ~6–8 `LordPerkDef` (unlock_level 2/4/6/8/10/12/15 tương ứng `energy_cap`/`loot_gold_pct`/`expedition_slots`/`daily_quest_slots`...). Database: thêm `get_lord_perk_def(id)` + `lord_perk_def_ids()` + `lord_perks_ordered()`.

### 4.8 Tests (S0) — `game/tests/unit/`

| File | Case |
|---|---|
| `test_lord_progression.gd` | xp_to_level tăng đơn điệu; level_for_xp nghịch đảo đúng; perks_unlocked_at trả đúng theo mốc |
| `test_lord_profile.gd` | create_lord set cờ+persist; add_lord_xp lên level đúng + unlock perk; lord_perk_value cộng dồn; new_account fresh |
| `test_migration_v8.gd` | v7→v8 thêm field default, không mất hero/gold/story; roundtrip to_dict/from_dict giữ lord_* |

Thêm 3 file vào `SUITES`.

### 4.9 Acceptance S0 (headless-verify)

- `test_lord_*` + `test_migration_v8` xanh; tổng suite vẫn xanh (464 + mới).
- Boot save v7 cũ → tự migrate v8, không cảnh báo checksum, Lord Level = 1.

---

## 5. S1 — Dialogue Runner + View

**Mục tiêu:** chạy được `DialogueDef` (thoại + cutscene slides) đã seed ở ContentP5; nền cho prologue (S4) + prompt tân thủ (S3).

### 5.1 System units

| Unit (path) | class_name / extends | Public API |
|---|---|---|
| `game/systems/dialogue/dialogue_runner.gd` | `DialogueRunner extends RefCounted` | `start(def:DialogueDef)`, `advance() -> bool` (false = hết), `current_line() -> Dictionary`, `is_cutscene() -> bool`, `finish()` → chạy `def.next_action` (dispatch qua callback), `is_finished() -> bool` |

`next_action` dispatch: runner **không** tự gọi gameplay; nó emit `EventBus.dialogue_finished(dialogue_id, next_action)` — hệ nghe (TutorialManager/NewPlayerFlow) xử lý. Giữ dialogue tách gameplay (signal-rules.md: notify, không execute).

### 5.2 UI units

| Unit (path) | class_name / extends | Việc |
|---|---|---|
| `game/ui/dialogue_view.gd` | `DialogueView extends CanvasLayer` | Overlay hộp thoại: tên + dòng thoại (typewriter tuỳ chọn), tap-to-advance; chế độ cutscene render `slides` (ảnh/màu + caption). Nhận `DialogueRunner`, chạm → `advance()`; hết → ẩn. |

Wiring: `GameHud` giữ 1 `DialogueView` ở layer trên cùng; hàm `GameHud.play_dialogue(dialogue_id)` tạo runner + hiện view.

### 5.3 EventBus (S1)

```
dialogue_started(dialogue_id:String)
dialogue_finished(dialogue_id:String, next_action:Dictionary)
```

### 5.4 Tests (S1)

| File | Case |
|---|---|
| `test_dialogue_runner.gd` | advance duyệt hết lines đúng số lần; is_cutscene khi có slides; finish emit next_action đúng payload; def rỗng xử lý an toàn |

Thêm vào `SUITES`. (UI view không unit-test — theo `unit-testing.md`.)

### 5.5 Acceptance S1

- `test_dialogue_runner` xanh.
- Smoke: `GameHud.play_dialogue("intro_ch00")` chạy hết đoạn, emit `dialogue_finished`.

---

## 6. S2 — Hệ Nhiệm Vụ (Quest/Mission)

**Mục tiêu:** daily/weekly/milestone/achievement, tiến độ auto theo EventBus, reset ngày/tuần, thưởng idempotent, **điểm hoạt động → rương** (mục D FLOW).

### 6.1 Data units

| Unit (path) | class_name / extends | Field |
|---|---|---|
| `game/data/quest_def.gd` | `QuestDef extends Resource` | `id:String`, `category:int` (enum `QuestCategory`), `title:String`, `description:String`, `objective_type:int` (enum `ObjectiveType`), `objective_target:String` (id lọc, "" = mọi), `objective_count:int=1`, `rewards:Array` ([{type,id,amount}]), `activity_points:int=0`, `unlock_feature:String=""`, `prerequisite_id:String=""`, `lord_level_req:int=1`, `hidden:bool=false`, `repeatable:bool=false` |
| `game/data/quest_track_def.gd` | `QuestTrackDef extends Resource` | `id:String`, `scope:int` (DAILY/WEEKLY), `point_tiers:Array[int]` (vd [20,40,60,100]), `tier_rewards:Array` (rương mỗi mốc) | rương điểm-HĐ |

Enum mới trong `game/enums.gd`:
```
QuestCategory { TUTORIAL, DAILY, WEEKLY, MILESTONE, ACHIEVEMENT, EVENT, CHARACTER }
ObjectiveType { WIN_BATTLE, CLEAR_ZONE, DISPATCH_EXPEDITION, SUMMON, CLEAR_STAGE,
                DEFEAT_BOSS, PLAY_MINIGAME, UPGRADE_BUILDING, ENHANCE_GEAR,
                AWAKEN_HERO, SPEND_GOLD, LOGIN, REACH_LORD_LEVEL, ARENA_WIN }
```

### 6.2 System units

| Unit (path) | class_name / extends | Public API | Ghi chú |
|---|---|---|---|
| `game/systems/quest/quest_progress.gd` | `QuestProgress extends Object` (static) | `matches(def:QuestDef, ev_type:int, ev_target:String) -> bool`, `is_complete(def, progress:int) -> bool` | thuần, test dày |
| `game/autoload/quest_manager.gd` | `QuestManager extends Node` (autoload) | `active_quests(category:int) -> Array[QuestDef]`, `progress_of(quest_id) -> int`, `is_completed(quest_id) -> bool`, `is_claimed(quest_id) -> bool`, `claim(quest_id) -> Dictionary{ok,rewards}`, `claim_track_tier(track_id, tier_idx) -> Dictionary`, `activity_points(scope) -> int`, `daily_reset()`, `weekly_reset()`, `notify(ev_type:int, ev_target:String, amount:int=1)` | subscribe EventBus |

`QuestManager._ready`: subscribe EventBus → map sang `notify(ObjectiveType, target)`:
- `fight`/`stage_cleared`→WIN_BATTLE/CLEAR_STAGE, `zone_cleared`→CLEAR_ZONE, `expedition_started`→DISPATCH_EXPEDITION, `hero_summoned`→SUMMON, `world_boss_ended(success)`→DEFEAT_BOSS, `arena_match_finished(won)`→ARENA_WIN, `awaken_completed`→AWAKEN_HERO, `gold_changed(spent)`→SPEND_GOLD, `lord_level_changed`→REACH_LORD_LEVEL, `minigame_played`(S5)→PLAY_MINIGAME.
- (Battle win: hiện Hero dùng `BattleEngine.simulate` trong `_engage` không có signal "fight_won" → **thêm EventBus `fight_resolved(hero_id, won)`** emit từ `Hero._engage`; QuestManager map won→WIN_BATTLE.)

`notify` cộng progress cho mọi quest active khớp; đủ → emit `quest_completed`; cộng `activity_points` vào track theo scope. Reset: đăng ký `TimeService.register_slice(_check_reset, 60)`; so `game_day()`/tuần với `quests.daily_day`/`quests.weekly_week` lưu trong save → reset khi đổi. Claim idempotent qua `_reward_guard` (claim-id = `quest_id:period`).

### 6.3 PlayerProfile.quests state

```
quests = {
  "daily_day": int, "weekly_week": int,
  "progress": { quest_id: int },
  "claimed": { quest_id: bool },        # theo period (reset xoá)
  "milestone_claimed": { quest_id: bool },   # milestone/achievement không reset
  "points": { "daily": int, "weekly": int },
  "track_claimed": { "track_id:tier": bool }
}
```

### 6.4 EventBus (S2) + emit bổ sung

```
quest_progress(quest_id:String, current:int, target:int)
quest_completed(quest_id:String)
quest_claimed(quest_id:String)
quests_reset(scope:String)                 # "daily"/"weekly"
activity_chest_claimed(track_id:String, tier:int)
fight_resolved(hero_id:String, won:bool)   # emit từ Hero._engage
```

### 6.5 ContentP7 seeds (S2)

- Daily set (~6): đăng nhập, thắng 5 trận, clear 1 dungeon/zone, phái 1 expedition, chơi 1 minigame, tiêu X gold.
- Weekly set (~5): clear 10 zone, đánh world boss 3 lần, thắng 10 arena, awaken/nâng 1 hero, chơi minigame 7 lần.
- Milestone (~10): đạt Lord 5/10/15/20, sưu tập 10 hero, clear region 2/3, first world-boss kill...
- Achievement (~10): thành tựu dài hạn.
- 2 `QuestTrackDef`: `daily_track`, `weekly_track`.
- Database: `get_quest_def`/`quest_defs_by_category(cat)`/`get_quest_track_def`.

### 6.6 UI units (S2)

| Unit (path) | class_name / extends | Việc |
|---|---|---|
| `game/ui/quest_panel.gd` | `QuestPanel extends Control` | Tab Ngày/Tuần/Mốc/Thành Tựu; mỗi quest: title + thanh tiến độ + nút Nhận (bật khi hoàn thành, tắt khi đã nhận); thanh điểm-HĐ + rương mốc. |

Wiring: `GameHud` thêm nav **"Nhiệm Vụ"** (badge số quest nhận được). Toast khi `quest_completed`.

### 6.7 Tests (S2)

| File | Case |
|---|---|
| `test_quest_progress.gd` | matches theo type/target/wildcard; is_complete biên (0, target-1, target, >target) |
| `test_quest_manager.gd` | notify cộng đúng nhiều quest; completed emit; claim-once (claim lần 2 = ok:false); daily_reset xoá progress+claimed nhưng giữ milestone; activity points cộng + claim_track_tier idempotent; reward route qua grant_reward |
| `test_quest_save.gd` | quests block roundtrip; reset theo day/week đổi |

Thêm vào `SUITES`.

### 6.8 Acceptance S2

- 3 test xanh. Smoke: emit `fight_resolved(_,true)` 5 lần → daily "thắng 5 trận" complete → claim → gold tăng đúng, claim lần 2 fail.

---

## 7. S3 — Tân Thủ (progressive disclosure + tốt nghiệp)

**Mục tiêu:** chuỗi 15 bước dẫn dắt; mỗi bước mở **1 feature** + thưởng; tốt nghiệp Lord≥15 + mở hết lõi → retire → Sổ Mục Tiêu.

### 7.1 Data units

| Unit (path) | class_name / extends | Field |
|---|---|---|
| `game/data/tutorial_step_def.gd` | `TutorialStepDef extends Resource` | `id:String`, `order:int`, `prompt_dialogue_id:String`, `complete_event:int` (ObjectiveType tái dùng), `complete_target:String`, `unlock_feature:String`, `reward:Array`, `lord_level_gate:int=1`, `highlight_id:String` (id widget để trỏ), `quest_id:String` (nếu map sang QuestDef category=TUTORIAL) |

Quyết định: **tân thủ tái dùng hạ tầng Quest** cho tracking+reward (mỗi step có `QuestDef` category=TUTORIAL), nhưng **TutorialManager sở hữu sequencing + highlight UI + graduation**. Không nhân đôi logic tiến độ.

### 7.2 System units

| Unit (path) | class_name / extends | Public API |
|---|---|---|
| `game/autoload/tutorial_manager.gd` | `TutorialManager extends Node` (autoload, sau QuestManager+StoryManager) | `current_step() -> TutorialStepDef`, `is_graduated() -> bool`, `advance_if_ready()`, `complete_step(id)`, `skip_completed()` (bỏ qua step đã thoả trước), `graduation_ready() -> bool`, `retire()` |

Logic: `_ready` nạp `tutorial` state; subscribe `quest_completed` (khớp step.quest_id) → `complete_step` → `unlock_feature` (ghi `PlayerProfile.story.features` qua `StoryManager.unlock_feature`) → cấp reward + Lord XP → advance. Mỗi advance: nếu `graduation_ready()` (Lord≥15 **và** mọi feature lõi ∈ features) → `retire()` (set `tutorial.graduated=true`, emit `tutorial_graduated`). `skip_completed`: khi vào game nếu điều kiện step đã thoả (vượt cấp) → auto-complete không bắt làm lại.

Danh sách "feature lõi" để tốt nghiệp (khớp FLOW bảng B): `equipment, building, summon, expedition, rune, synergy, dungeon, world_map, talent, boss, minigame, arena, awaken`.

### 7.3 PlayerProfile.tutorial state

```
tutorial = { "current": String, "completed": [step_id...], "graduated": bool }
```

### 7.4 EventBus (S3)

```
tutorial_step_started(step_id:String)
tutorial_step_completed(step_id:String)
tutorial_graduated()
feature_highlight(highlight_id:String)     # UI trỏ tới widget
```

### 7.5 UI units (S3)

| Unit (path) | class_name / extends | Việc |
|---|---|---|
| `game/ui/tutorial_overlay.gd` | `TutorialOverlay extends CanvasLayer` | Hiện prompt bước hiện tại + mũi tên/highlight tới `highlight_id`; ẩn khi `tutorial_graduated`. Sau tốt nghiệp: panel Nhiệm Vụ đổi tab mặc định sang **Mốc/Thành Tựu** ("Sổ Mục Tiêu"). |

Wiring: `GameHud` gate nav/panel theo `StoryManager.is_feature_unlocked` — panel chưa mở khoá thì **ẩn/disable** nút nav (progressive disclosure). Sau `tutorial_graduated`, ẩn `TutorialOverlay`.

### 7.6 ContentP7 seeds (S3)

15 `TutorialStepDef` + 15 `QuestDef` category=TUTORIAL đúng bảng FLOW mục B (Lv1 thắng trận → … → Lv15 awaken). Database: `get_tutorial_step`/`tutorial_steps_ordered()`.

### 7.7 Tests (S3)

| File | Case |
|---|---|
| `test_tutorial_manager.gd` | complete_step advance đúng thứ tự; unlock_feature ghi vào story.features; skip_completed bỏ qua step đã thoả; graduation_ready chỉ true khi Lord≥15 + đủ feature; retire set cờ + emit; sau retire không advance nữa |
| `test_tutorial_save.gd` | tutorial state roundtrip; graduated giữ qua save/load |

Thêm vào `SUITES`.

### 7.8 Acceptance S3

- 2 test xanh. Smoke: chạy chuỗi giả lập hoàn thành 15 step + set Lord 15 → `graduation_ready()`==true → retire → overlay ẩn.

---

## 8. S4 — Màn Mở First-Session

**Mục tiêu:** luồng new-account: tạo Lord → prologue → tặng hero → trận đầu có dẫn → triệu hồi đầu **đảm bảo ≥1 hero hiếm** → bàn giao cho TutorialManager.

### 8.1 System units

| Unit (path) | class_name / extends | Public API |
|---|---|---|
| `game/systems/lord/new_player_flow.gd` | `NewPlayerFlow extends RefCounted` (do GameHud/world khởi tạo) | `should_run() -> bool` (== `!PlayerProfile.lord_created`), `begin(hud)` → tuần tự: LordCreate → `play_dialogue("intro_prologue")` → `gift_starter_hero()` → guided battle → `first_summon()` → handoff Tutorial |

Phối hợp qua signal (không block): mỗi bước nghe `dialogue_finished`/`lord_created`/`hero_summoned` rồi tiến bước kế. Không `await` chuỗi dài (gdscript.md).

### 8.2 Đổi hành vi có kiểm soát

- `PlayerProfile.new_account()` (đã thêm S0): fresh, `lord_created=false`.
- Boot (`world.gd._ready` hoặc `GameHud`): nếu save trống → `new_account()`; nếu `NewPlayerFlow.should_run()` → chạy màn mở trước khi trả quyền điều khiển. Save cũ đã `lord_created` → bỏ qua.
- `gift_starter_hero()`: spawn 1 hero tank/warrior kịch bản (id cố định, vd `knight`) qua `PlayerProfile.spawn_hero`.
- **First-summon đảm bảo:** thêm `BannerDef` `beginner` (hoặc field `first_pull_guarantee:int` trên BannerDef) → `SummonService.pull` khi `pity_state` đánh dấu beginner ép ≥1 kết quả `rarity>=guaranteed_rarity`. Free x10, không tốn gems.

### 8.3 UI units (S4)

| Unit (path) | class_name / extends | Việc |
|---|---|---|
| `game/ui/lord_create_panel.gd` | `LordCreatePanel extends Control` | Nhập tên + chọn chân dung (`lord_portrait_id`) + huy hiệu (`crest_id`); nút Xác Nhận → `PlayerProfile.create_lord(...)`. |

Chân dung/huy hiệu: dùng màu/placeholder (art phase sau). Danh sách id seed trong ContentP7.

### 8.4 EventBus (S4)

Tái dùng `lord_created`, `hero_summoned`, `dialogue_finished`. Thêm:
```
new_player_flow_finished()
```

### 8.5 Tests (S4)

| File | Case |
|---|---|
| `test_new_player_flow.gd` | should_run true khi chưa tạo Lord; create_lord → should_run false; gift_starter_hero thêm đúng 1 hero; first_summon đảm bảo ≥1 rarity≥guaranteed (seed cố định, tất định); new_account KHÔNG phá new_game (test cũ) |
| `test_beginner_banner.gd` | pull beginner với nhiều seed → luôn có ≥1 elite+; pity beginner tiêu 1 lần |

Thêm vào `SUITES`. (UI create panel không unit-test.)

### 8.6 Acceptance S4

- 2 test xanh + toàn suite xanh (đặc biệt các test gọi `new_game` không đổi kết quả).
- Smoke world: xoá save → boot → LordCreate hiện → hoàn tất → prologue → có 1 hero + kết quả triệu hồi → TutorialOverlay bước 1 hiện.

---

## 9. S5 — Minigame (Câu Cá + Rèn Nhịp)

**Mục tiêu:** 2 minigame gắn building, thưởng **có trần ngày** (gia vị, không phá kinh tế), phát `minigame_played` cho Quest.

### 9.1 Data units

| Unit (path) | class_name / extends | Field |
|---|---|---|
| `game/data/minigame_def.gd` | `MinigameDef extends Resource` | `id:String`, `type:int` (enum `MinigameType{FISHING,FORGE_RHYTHM}`), `display_name`, `host_building:String` (vd "kitchen"/"blacksmith" — hoặc thêm "harbor"), `daily_cap:int=5`, `reward_table:Array` ([{type,id,amount,weight}]), `difficulty:Dictionary` |

Enum `MinigameType` vào `enums.gd`.

### 9.2 System units

| Unit (path) | class_name / extends | Public API |
|---|---|---|
| `game/systems/minigame/fishing_game.gd` | `FishingGame extends Object` (static) | `roll_catch(seed_val:int, difficulty:Dictionary) -> Dictionary{item,quality}` (tất định) |
| `game/systems/minigame/forge_rhythm_game.gd` | `ForgeRhythmGame extends Object` (static) | `score_hits(hit_timings:Array, seed_val:int) -> Dictionary{grade,bonus_pct}` |
| `game/autoload/minigame_service.gd` | `MinigameService extends Node` (autoload, sau PlayerProfile) | `can_play(minigame_id) -> Dictionary{ok,plays_left}`, `plays_left(minigame_id) -> int`, `play(minigame_id, input:Dictionary) -> Dictionary{ok,rewards}` (kiểm cap → roll seeded → grant_reward → emit `minigame_played`), `daily_reset()` |

`play` seed = hash(`game_day` + minigame_id + play_index) qua `RandomService.seed_with` → thưởng tất định/replay-được. Cap lưu `PlayerProfile.minigames`.

### 9.3 PlayerProfile.minigames state

```
minigames = { "day": int, "plays": { minigame_id: int } }
```

### 9.4 EventBus (S5)

```
minigame_played(minigame_id:String)
minigame_reward(minigame_id:String, rewards:Array)
```

### 9.5 UI units (S5)

| Unit (path) | class_name / extends | Việc |
|---|---|---|
| `game/ui/minigame_fishing_panel.gd` | `MinigameFishingPanel extends Control` | Thanh timing câu cá; nhấn đúng vùng → `MinigameService.play("fishing",{...})`; hiện lượt còn lại + phần thưởng. |
| `game/ui/minigame_forge_panel.gd` | `MinigameForgePanel extends Control` | Nhịp gõ búa; thu `hit_timings` → `play("forge_rhythm",...)`. |

Entry: chạm building (Blacksmith/Kitchen/Harbor) trong world → mở panel tương ứng; hoặc nút trong `build_panel`.

### 9.6 ContentP7 seeds (S5)

2 `MinigameDef` (`fishing` host harbor/kitchen, `forge_rhythm` host blacksmith), `daily_cap=5`, reward_table (food/gold/material/crystal weighted). Database: `get_minigame_def`/`minigame_def_ids()`.

### 9.7 Tests (S5)

| File | Case |
|---|---|
| `test_minigame_logic.gd` | fishing roll_catch tất định theo seed; trong bảng reward; forge score_hits phân grade đúng biên |
| `test_minigame_service.gd` | can_play chặn khi hết cap; play cộng plays + reward qua grant_reward; daily_reset về 0; emit minigame_played |

Thêm vào `SUITES`.

### 9.8 Acceptance S5

- 2 test xanh. Smoke: play "fishing" 5 lần → lần 6 `ok:false` (hết cap); reset ngày → chơi lại; mỗi lần emit `minigame_played` → daily quest "chơi 1 minigame" tick.

---

## 10. S6 — Raid Dungeon (composition, lát cuối)

**Mục tiêu:** boss nhiều-phase liên hoàn, offline = solo + **hero hỗ trợ (bot)**; quota tuần; tái dùng `BattleSim`/`BossController`/`BossDef`.

### 10.1 Data units

| Unit (path) | class_name / extends | Field |
|---|---|---|
| `game/data/raid_def.gd` | `RaidDef extends Resource` | `id:String`, `display_name`, `boss_ids:Array[StringName]` (chuỗi boss, tái dùng BossDef), `assist_bot_ids:Array[String]` (hero bot ghép đội offline), `weekly_attempts:int=3`, `recommended_power:int`, `reward_table_id:StringName`, `first_clear_rewards:Array` |

### 10.2 System units

| Unit (path) | class_name / extends | Public API |
|---|---|---|
| `game/systems/raid/raid_service.gd` | `RaidService extends Node` (autoload hoặc pure gọi từ BattlePanel) | `attempts_left(raid_id) -> int`, `can_enter(raid_id) -> Dictionary`, `run(raid_id, team:Array, seed_val:int) -> Dictionary{cleared,boss_reached,rewards,replay}` (lặp `BattleSim` qua từng boss, chèn assist bot nếu team thiếu), `weekly_reset()` |

Tất định seeded, tách SIM↔VIEW như P4. KHÔNG sửa BattleSim; chỉ **điều phối** nhiều lượt sim nối tiếp + trạng thái HP mang sang boss kế (tuỳ luật). Quota lưu `PlayerProfile.raids`.

### 10.3 PlayerProfile.raids + EventBus (S6)

```
raids = { "week": int, "attempts": { raid_id: int }, "cleared": { raid_id: bool } }
```
```
raid_started(raid_id:String)
raid_finished(raid_id:String, cleared:bool, boss_reached:int)
```

### 10.4 UI (S6)

Thêm **tab "Raid"** vào `battle_panel.gd` (không panel mới): chọn raid → chọn đội (auto điền assist bot) → chạy → xem kết quả + replay.

### 10.5 ContentP7 seeds (S6)

1–2 `RaidDef` tái dùng boss có sẵn (`forest_guardian` + `abyss_dragon`) làm chuỗi 2-boss demo; `assist_bot_ids` từ `arena_bot_pool`. Database: `get_raid_def`/`raid_def_ids()`.

### 10.6 Tests (S6)

| File | Case |
|---|---|
| `test_raid_service.gd` | run tất định (2 seed giống → kết quả giống); assist bot chèn khi thiếu slot; attempts_left giảm + chặn khi hết; weekly_reset; first-clear reward once |

Thêm vào `SUITES`.

### 10.7 Acceptance S6

- Test xanh. Smoke: run raid 2-boss → cleared/boss_reached hợp lệ; hết quota tuần → chặn; reset tuần → chơi lại.

---

## 11. Save Model tổng (v7 → v8)

**Một** migration `_migrate_v7_to_v8` (S0) seed **tất cả** block P7 rỗng ở `player`:
`lord_created, lord_name, lord_portrait_id, lord_crest_id, lord_level, lord_xp, lord_perks, tutorial{}, quests{}, minigames{}, raids{}`.
Các slice sau chỉ **đọc/ghi** block đã có — không migration thêm. `SAVE_VERSION=8`. Giữ `.bak` + checksum (đã đúng từ P6 fix).

---

## 12. Autoload đăng ký thêm (`project.godot [autoload]`)

Thứ tự (sau `PlayerProfile` #13, và sau manager subscribe được):

| Vị trí đề xuất | Name | Path |
|---|---|---|
| sau SeasonManager | `QuestManager` | `game/autoload/quest_manager.gd` |
| sau QuestManager | `TutorialManager` | `game/autoload/tutorial_manager.gd` |
| sau PlayerProfile | `MinigameService` | `game/autoload/minigame_service.gd` |
| (tuỳ chọn) | `RaidService` | `game/systems/raid/raid_service.gd` |

`LordProgression`/`QuestProgress`/`DialogueRunner`/`FishingGame`/`ForgeRhythmGame`/`NewPlayerFlow` là class thường (không autoload).

---

## 13. Telemetry & Debug (mỗi slice)

**Telemetry** (`Telemetry.track(event, category, payload)`; NEVER_SAMPLE cho mốc quan trọng):
`lord_created/lord_level_up/lord_perk_unlocked`, `quest_completed/quest_claimed/activity_chest`, `tutorial_step/tutorial_graduated`, `dialogue_shown`, `minigame_played`, `raid_finished`.

**Debug console** (`Debug.register_command`, gate ReleaseGate): `create_lord`, `add_lord_xp <n>`, `grant_perk <id>`, `complete_quest <id>`, `reset_daily/reset_weekly`, `tutorial_step/tutorial_skip/tutorial_graduate`, `play_dialogue <id>`, `play_minigame <id>`, `reset_minigame`, `run_raid <id>`.

---

## 14. Tổng hợp test mới (thêm vào `SUITES` trong `test_runner.gd`)

`test_lord_progression`, `test_lord_profile`, `test_migration_v8`, `test_dialogue_runner`, `test_quest_progress`, `test_quest_manager`, `test_quest_save`, `test_tutorial_manager`, `test_tutorial_save`, `test_new_player_flow`, `test_beginner_banner`, `test_minigame_logic`, `test_minigame_service`, `test_raid_service`.
Simulation (`game/tests/simulation/`): `test_onboarding_simulation` (new-account → tạo Lord → chạy hết tân thủ giả lập → tốt nghiệp → 1 vòng daily+minigame → save/load giữ nguyên).

Mục tiêu: **giữ 464 test cũ xanh** + ~15 test mới.

---

## 15. Ngoài phase (hook, chưa build)

- Chân dung/huy hiệu Lord = art thật (P-art). Hiện placeholder màu.
- Minigame thứ 3+ (Xúc Xắc quán trọ, Đào Kho Báu) — thêm bằng `MinigameDef` + logic unit, không đổi service.
- Character personal questline (category=CHARACTER) — có enum sẵn, seed sau (gắn `STORY.md`).
- Online: Lord/quest là account-state → đồng bộ qua CloudSave (P6) khi bật online; quest verify server sau. Raid co-op người thật (thay assist bot) = P6-online.
- DialogueView typewriter/cutscene art nâng cấp sau.

---

## 16. Checklist PR (mỗi slice, theo CLAUDE.md)

Architecture tôn trọng · Component/Service tách · Resource dùng · Save v8 support + migration · Debug tools · Telemetry · Test (unit + regression) · Docs (cập nhật `FLOW.md` §I mapping + `CHANGELOG.md`) · Performance (no `_process` AI, scheduler) · Mobile-friendly · Multiplayer-ready (ID-based, grant_reward router) · Reviewer approved.

---

## 17. Tunables cần chốt (đồng bộ `FLOW.md` §J)

1. Ngưỡng tốt nghiệp: **Lord 15 + đủ 13 feature lõi** (mục 7.2).
2. Đặc Ân Lord: chỉ buff tiện ích (energy/loot%/expedition-slot/quest-slot) — **không** đụng FinalStats.
3. Bộ minigame MVP: **Câu Cá + Rèn Nhịp** (S5). Raid = S6 (lát cuối).
4. Team size expedition/combat: giữ nguyên (3 active-team hiện tại; expedition qua service).
5. Điểm-HĐ mốc rương ngày/tuần: seed trong `QuestTrackDef` (mục 6.1) — cần bảng số cụ thể.
6. First-summon đảm bảo: free x10, ≥1 rarity≥`guaranteed_rarity` (S4).
