# Phase 7+ — Lộ trình hoàn thiện game (Plan hợp nhất)

> **File plan forward DUY NHẤT** (chống phân mảnh). Bao trọn mọi việc còn lại sau P6.
> Baseline: P0–P6 xong, save v7, 464 test xanh. Trạng thái toàn bộ: **CHƯA BẮT ĐẦU**.
> Nguyên tắc độ sâu: **Phase 7 (PHẦN A) đã spec tới từng unit vì làm trước; Phase 8–12 (PHẦN B–F) spec ở mức slice + unit chính — sẽ đào sâu tới-từng-unit KHI tới lượt** (tránh over-spec việc xa, tránh lãng phí khi thiết kế đổi).

## Mục lục (Parts = Phases)

| Phần | Phase | Nội dung | Nhóm FEATURES | Ưu tiên | Độ sâu |
|---|---|---|---|---|---|
| **A** | **P7** | Cửa trước: Lãnh Chúa · Tân thủ · Quest · Minigame · Formation-5+Loadout · Raid | T1/T2/T4-SF/T7 | #1 (chạm đầu) | tới-từng-unit (§1–§18) |
| **B** | **P8** | T4 chiều sâu combat: Synergy hoàn thiện + **Skill-Kit hero trong engine** | T4 | #2 | slice + unit chính (§19) |
| **C** | **P9** | T6 nội dung PvE: Dungeon (resource/equip/rune/endless/elite/challenge) + Ancient Boss | T6 | #3 | §20 |
| **D** | **P10** | T5 chiều sâu collection: Pet · Hero questline · Relationships | T5 | #4 | §21 |
| **E** | **P11** | T10/T11/T13: Crafting/Salvage/Shop · Endgame · Art/Audio/i18n (production) | T10/11/13 | #5 | §22 |
| **F** | **P12** | T12: Backend Supabase thật + Network UI + Release (ops) | T12 | #6 (cuối) | §23 |

> Quyết định mở của PHẦN A: xem `docs/PHASE7_OPTIONS.md`. Danh mục trạng thái toàn game: `docs/scripts/FEATURES.md`.

---

# ══════════ PHẦN A — Phase 7 (Cửa Trước) ══════════

> Chi tiết tới từng unit. `prompts/feature.md`. Hiện thực `FLOW.md` mục A–D + H.

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
| **SF** | **Formation Core: team 3→5 + Loadouts + Deploy Lock** | S0 | Có (đội hình chạy) |
| **S1** | Dialogue Runner + View | S0 | Có (chạy 1 đoạn thoại) |
| **S2** | Hệ Nhiệm Vụ (daily/weekly/milestone/achievement + điểm-HĐ) | S0 | Có (quest panel chạy) |
| **S3** | Tân Thủ (progressive disclosure + tốt nghiệp) | S0,S1,S2 | Có |
| **S4** | Màn Mở first-session (tạo Lord → prologue → hero → trận → triệu hồi) | S0,S1,S3 | Có (luồng new-account) |
| **S5** | Minigame (Câu Cá + Rèn Nhịp) | S0,S2 | Có |
| **S6** | Raid Dungeon (composition trên Boss/Stage) | S0 | Có |

DAG: `S0 → {SF, S1, S2}`; `SF → {S3, S4, S6}` (tân thủ dạy formation; raid cần deploy-lock); `S1,S2 → S3`; `S3 → S4`; `S2 → S5`.
**Thứ tự build đề xuất:** S0 → **SF** → S1 → S2 → S3 → S4 → S5 → S6 (SF sớm vì số team=5 phải đúng trước khi tân thủ dạy đội hình).

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

Đường cong XP data-driven: thêm `lord_xp_base:int=80` + `lord_xp_growth:float=1.12` vào `EconomyConstants` (`.tres`). **Không hardcode.**

**Công thức:** `xp_to_level(L) = round(lord_xp_base * lord_xp_growth^(L-1))` = XP cần để đi từ level L→L+1.

**Bảng số (khởi điểm, base=80 growth=1.12):**

| Lv→next | XP mốc | Cộng dồn tới Lv | Ghi chú |
|---|---|---|---|
| 1→2 | 80 | 80 | |
| 2→3 | 90 | 170 | |
| 3→4 | 100 | 270 | |
| 5→6 | 126 | 486 | mở perk expedition slot |
| 10→11 | 222 | 1.330 | |
| 15→16 | 391 | 3.100 | **mốc tốt nghiệp tân thủ** (~3.1k XP dồn) |
| 20→21 | 690 | 5.900 | |
| 30→31 | 2.140 | 21.500 | |
| 50→51 | 20.600 | ~205k | end-game trần mềm |

Nguồn Lord XP: quest (daily ~40-80, weekly ~300, milestone ~200-500), story chapter (~300), tutorial step (~50-150). Tune sao cho **chơi đều tới Lv15 trong ~5-7 ngày** (khớp graduation ~1 tuần onboarding).

### 4.2b Bảng Đặc Ân Lord (LordPerkDef seed — buff tiện ích, no-P2W)

| id | unlock_level | effect_key | effect_value | Hiệu ứng |
|---|---|---|---|---|
| `perk_energy_1` | 2 | `energy_cap` | 20 | max_energy 120→140 |
| `perk_gold_1` | 4 | `loot_gold_pct` | 0.05 | +5% vàng loot |
| `perk_expedition_1` | 6 | `expedition_slots` | 1 | MAX_EXPEDITIONS 2→3 |
| `perk_inn_1` | 8 | `inn_heal_rate` | 0.10 | +10% tốc hồi Nhà Trọ |
| `perk_quest_1` | 10 | `daily_quest_slots` | 1 | +1 slot nhiệm vụ ngày |
| `perk_gold_2` | 12 | `loot_gold_pct` | 0.05 | +5% (cộng dồn +10%) |
| `perk_energy_2` | 15 | `energy_cap` | 30 | +30 (cộng dồn +50) |
| `perk_expedition_2` | 20 | `expedition_slots` | 1 | (cộng dồn +2 → 4 slot) |

`lord_perk_value(key)` = tổng `effect_value` các perk cùng key đã unlock (cộng dồn). Tất cả là buff **town/economy**, tuyệt đối không đụng `FinalStats`.

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
4. **Team size = 5 (CHỐT)** cho formation combat; nâng 3→5 + hệ **Loadouts nhiều đội** + **deploy-lock** ở slice **SF** (§18). Expedition/field-hunt vẫn per-hero. Xem `docs/scripts/TEAMBUILD.md`.
5. Điểm-HĐ mốc rương ngày/tuần: seed trong `QuestTrackDef` (mục 6.1) — cần bảng số cụ thể.
6. First-summon đảm bảo: free x10, ≥1 rarity≥`guaranteed_rarity` (S4).
7. Số preset đội tối đa: đề xuất **10** (mở thêm theo Lord level?). Arena defense = snapshot → **KHÔNG** khoá hero (cần xác nhận).

---

## 18. SF — Formation Core (team 3→5 + Loadouts + Deploy Lock)

**Mục tiêu:** nâng đội hình formation 3→**5**; cho lưu **nhiều preset đội** (overlap thoải mái); enforce **1 hero chỉ ở 1 deploy-theo-thời-gian tại một thời điểm**. Nền cho tân thủ (dạy formation) + raid (deploy-lock). Chi tiết thiết kế: `docs/scripts/TEAMBUILD.md`.

### 18.1 Nâng team 3 → 5

| Đụng | Đổi |
|---|---|
| `PlayerProfile.active_team(size=3)` | default 5 (giữ param cho test cũ); dần thay bằng loadout đã chọn |
| `data/content_p4.gd` FormationDef | thêm `balanced_5`/`offense_5` (5 slot + buff hàng front/back); giữ `*_3` cho test cũ |
| `data/stage_def.gd` `team_size` | seed stage mới 5 (stage cũ giữ 3 để không vỡ `test_stage`) |
| `systems/battle/battle_sim.gd` capacity | xác nhận nhận ≥5 hero/phe (đã 8-hero world boss → OK) |
| Synergy seeds | seed theo `TEAMBUILD.md` (race giảm dần + class 2/3 + coalition) — tune bằng `SynergyBalanceSim` |

### 18.2 Data & System units

| Unit (path) | class_name / extends | API / field |
|---|---|---|
| `game/data/team_loadout.gd` | `TeamLoadout extends Resource` | `id:String`, `name:String`, `hero_ids:Array[String]` (≤5, index=slot), `formation_id:String`, `purpose:String="general"`; `to_dict()`/`from_dict()`; `is_full()`, `contains(hero_id)` |
| `PlayerProfile` (mở rộng) | — | `teams:Array` + `deployments:Dictionary`(`hero_id→{activity,ref}`) vào block `player`. Methods: `create_team(name)`, `save_team(loadout)`, `delete_team(id)`, `rename_team(id,name)`, `get_team(id)`, `teams_all()`, `set_team_slot(id,slot,hero_id)`; `locked_heroes()→{hero_id:reason}`, `is_hero_available(hero_id)→bool`, `can_deploy(loadout)→{ok,conflicts:Array}`, `lock_team(loadout,activity,ref)`, `release(activity,ref)` |

`deployments` là **sổ commit dùng chung**: expedition (`is_on_expedition` tổng quát hoá vào đây), raid, event đa-đội đều ghi/xoá qua `lock_team`/`release`. Instant battle & arena-defense snapshot **không** ghi.

### 18.3 Gate & tích hợp

- `ExpeditionService.can_start(hero,zone)` + `RaidService.can_enter(raid_id)` gọi `PlayerProfile.is_hero_available`/`can_deploy`; resolve/kết thúc → `release`.
- `world.gd._dispatch_tick`: dispatch expedition qua `deployments` (thay cờ rời rạc), tôn trọng `MAX_EXPEDITIONS` + lord-perk `expedition_slots`.
- Arena defense set → **snapshot**, không lock (cho overlap offense).

### 18.4 Save v8

Gộp vào migration `_migrate_v7_to_v8` (S0): thêm `teams=[]`, `deployments={}`. Migration seed 1 preset **"Đội Chính"** từ `active_team()` hiện tại để người chơi cũ có sẵn 1 đội. Không mất data.

### 18.5 EventBus (SF)

```
team_saved(team_id:String)
team_deleted(team_id:String)
hero_locked(hero_id:String, activity:String)
hero_released(hero_id:String)
```

### 18.6 UI

`game/ui/team_loadout_panel.gd` `TeamLoadoutPanel extends Control` — gắn nav **"Đội hình"** (hiện `_show(null)`): list preset (tên + 5 chân dung + purpose), sửa (kéo hero vào 5 ô + chọn `FormationDef`), hero đang khoá hiện **xám + badge lý do**, nút **Deploy** cảnh báo `conflicts` nếu trùng. Tạo/xoá/đổi tên preset.

### 18.7 Tests — `game/tests/unit/test_team_loadout.gd`

| Case |
|---|
| create/save/rename/delete preset; roundtrip `to_dict/from_dict` |
| overlap OK: cùng hero ở 2 preset không lỗi |
| `can_deploy` báo conflict khi hero đang bận raid/expedition (concurrent) |
| instant battle & arena-defense **KHÔNG** khoá (is_hero_available vẫn true) |
| `lock_team` → không deploy được nơi khác; `release` → deploy lại được |
| migration v8 seed "Đội Chính" từ active_team; team=5 không vỡ `test_stage`/`test_arena` cũ |

Thêm vào `SUITES`.

### 18.8 Acceptance SF

- Test xanh + toàn suite xanh (đặc biệt `test_stage`/`test_arena`/`test_battle_sim` với team 5).
- Smoke: lưu 2 preset chung 1 hero → deploy preset 1 vào raid → deploy preset 2 báo conflict đúng hero → raid resolve → hết conflict.

---

# ══════════ PHẦN B — Phase 8 (T4: Chiều sâu Combat) ══════════

**Mục tiêu:** (1) hoàn thiện synergy cho đội-5 (coalition + soft-cap + validator + sim); (2) **Skill-Kit hero trong engine** — lát lớn nhất & rủi ro nhất của cả game (đã hoãn từ P3). Nguồn số: `docs/scripts/TEAMBUILD.md`. Design combat: `COMBAT.md`/`SKILLS.md`.
**Save:** B2 bump **v8→v9** (per-hero skill state). B1 không đụng save (synergy runtime). **SIM_VERSION** bump khi B2 đổi công thức combat.

---

## 19.1 Slice B1 — Synergy Completion (nhỏ, làm trước)

### Data
- `data/synergy_def.gd` `SynergyDef`: thêm hằng `kind` hợp lệ `"coalition"` (ngoài `"race"`/`"class"`). Field giữ nguyên (`thresholds:Dictionary`).
- Seed (trong `_build_p3`/`ContentP7`): 8 race-syn + 7 class-syn + 1 coalition-syn theo **bảng số TEAMBUILD** (increment-delta, vì `SynergyService` merge cộng dồn). Ví dụ đã có literal ở TEAMBUILD §Seed Data.

### System
| Unit | Sửa |
|---|---|
| `systems/build/synergy_service.gd` `compute` | thêm nhánh `sdef.kind == "coalition"` → `n = race_count.size()` (đếm **tộc khác nhau**); expand key `"all"` → cả 7 `StatAggregator.STATS` khi merge |
| `systems/build/stat_aggregator.gd` | trong bước (5) synergy: **clamp mỗi key ≤ 0.15** trước khi `add_percent_dict` (soft-cap band). Ghi layer `"synergy"` để breakdown |
| `systems/build/synergy_balance_validator.gd` `SynergyBalanceValidator` (mới, static) | `validate(defs:Array) -> {ok, errors}`: reject nếu tổng percent tối đa 1 tag-stack (mono-5) vào 1 key vượt cap; gọi ở `Database._ready` sau seed |

### Test
| File | Case |
|---|---|
| `test_synergy` (mở rộng) | coalition đếm đúng số tộc; `"all"` áp cả 7 key; soft-cap clamp ≤0.15; cộng-dồn threshold đúng (n=3 = th2+th3); determinism |
| `game/tests/simulation/test_synergy_balance.gd` (mới) | dựng 3 comp benchmark (mono-5 / 3+2 / rainbow-5), mỗi comp đấu N trận seeded qua `BattleSim` → thu win-rate → **assert |wr - 0.5| ≤ 0.08** cho mỗi archetype vs benchmark trung dung |

### Acceptance B1
- 2 test xanh; `SynergyBalanceValidator` chặn được bảng lệch (test negative). Sim in ra win-rate 3 archetype trong band. **Không** bump save/SIM_VERSION.

Deps: **SF** (team=5). Risk: **thấp**. Đây là bước "đo cân bằng" đã hứa ở TEAMBUILD.

---

## 19.2 Slice B2 — Skill-Kit hero trong engine (LỚN — tách 4 sub-slice)

Hiện `BattleSim` chỉ basic-attack cho hero; `SkillDef`/`SkillRuntime` đã có nhưng chỉ boss dùng. B2 đưa **passive + 3 active + ultimate + energy + cooldown + status** cho hero, **GIỮ tất định**.

### 19.2.0 Data model

| Unit | Field / thay đổi |
|---|---|
| `data/skill_def.gd` `SkillDef` (mở rộng) | thêm `energy_cost:int=0`, `energy_gain_on_hit:int`, `is_ultimate:bool` (hoặc dùng `SkillKind.ULTIMATE` đã có); các field boss cũ (cast_time/cc/target_mode/select_rule) tái dùng nguyên |
| `data/hero_def.gd` `HeroDef` | thêm `skill_ids:Array[StringName]` = [passive, active1, active2, active3, ultimate] |
| `HeroInstance` | thêm `skill_order:Array[int]` (thứ tự ưu tiên auto-cast, tuỳ chọn người chơi) — **field duy nhất cần save** (v9) |
| enums (đã có) | tái dùng `SkillKind/SkillType/SkillTarget/SkillSelectRule/CcType`; thêm `StatusType {BURN, STUN, SHIELD, BUFF, DEBUFF, HEAL_OVER_TIME}` nếu chưa đủ |

Seed: mỗi hero roster (5) một bộ 5 skill (`ContentP8`) — passive + 3 active + ult, theo `SKILLS.md` (vd Assassin: Dash/Poison Blade/Smoke Bomb/Shadow Kill).

### 19.2.1 Sub-slice a — Energy + Cooldown + 1 active
| Unit | Việc |
|---|---|
| `systems/battle/sim_combatant.gd` (mở rộng) | thêm `energy:int`, `max_energy`, `skill_slots:Array[SkillRuntime]`; `gain_energy(n)`, `ready_skills()` |
| `systems/battle/battle_sim.gd` | mỗi tick: trước basic-attack, nếu có active `ready_now()` & đủ energy → cast (chọn target theo `SkillTarget`, priority theo `skill_order`/`SkillSelectRule`); tick cooldown; energy +khi đánh & bị đánh |
| `SkillRuntime` (đã có) | tái dùng `ready_now/tick_cd/trigger` |
| Test | `test_skill_engine`: cast khi đủ energy+off-cd; không cast khi thiếu; 2 seed giống→giống |

### 19.2.2 Sub-slice b — Ultimate + charge
- Ultimate = skill `is_ultimate`, dùng energy đầy (charge) thay cooldown; cast khi `energy>=max_energy` → reset. Target/effect qua SkillDef.
- Test: ult chỉ nổ khi đầy; reset energy; tất định.

### 19.2.3 Sub-slice c — Status effects (module pure)
| Unit | Việc |
|---|---|
| `systems/battle/status_effects.gd` `StatusEffects` (pure) | `apply(combatant, type, magnitude, duration, stacks)`, `tick(combatant)` (Burn dmg/turn, HoT heal, expire), `is_stunned`; stack rules (refresh vs stack) |
| `battle_sim.gd` + `DamageFormula` | chèn Shield (hấp thụ trước HP), Burn (dmg cuối tick), Stun (skip turn — tái dùng `is_stunned` boss đã có), Buff/Debuff (mod stat tạm) |
| Test | `test_status_effects`: Burn tick đúng tổng, Shield hấp thụ đúng, Stun skip, stack/refresh, expire |

### 19.2.4 Sub-slice d — Rebalance + Replay
- **SIM_VERSION bump** (công thức đổi). Cập nhật golden replay `test_replay_regression`.
- Re-tune: stage/boss/arena/dungeon vì hero mạnh lên đáng kể; chạy lại `SynergyBalanceSim` + `test_boss_arena_simulation`.
- Test: `test_skill_determinism` (batch nhiều seed, replay == gốc).

### 19.2.5 Save v8 → v9
`_migrate_v8_to_v9`: thêm `skill_order:[]` mặc định mỗi hero (auto theo `skill_ids`). Không mất data.

### 19.2.6 UI
- `hero_detail_panel`: hiện 5 skill + mô tả + cho kéo `skill_order` (auto-cast priority).
- `battle_panel`/battle view: icon skill cast + status badge (Burn/Stun/Shield) trên unit.

### 19.2.7 EventBus (B2)
```
skill_cast(hero_id:String, skill_id:String)     # tuỳ chọn, cho VFX/telemetry (không mỗi tick)
status_applied(target_uid:int, status:int)      # client-only VFX
```

### Design forks B2 (chốt khi tới)
- **Energy model:** ★ energy tăng khi đánh + bị đánh, ult khi đầy (dễ đọc, tất định) · vs regen-theo-thời-gian · vs mana-pool cổ điển.
- **Auto-cast:** ★ AI priority + cho set `skill_order` đơn giản (giữ "xem, không điều khiển") · vs full-auto · vs người chơi bấm ult.
- **Passive:** ★ tĩnh (áp vào FinalStats qua layer mới) khi đơn giản; điều kiện (trigger trong sim) khi cần "khi HP<30%".

### Acceptance B2
- Tất cả `test_skill_*` + `test_status_effects` xanh; `test_replay_regression` cập nhật golden xanh; `SynergyBalanceSim` + boss sim vẫn trong band sau rebalance. Save v9 migrate sạch.

Deps: SF. Reuse: SkillDef/SkillRuntime/enums (P4). Risk: **CAO** — chạm engine lõi + rebalance toàn content. **Làm SAU khi PHẦN A ship** (game đã chơi được). Theo 4 sub-slice a→d, mỗi sub-slice test xanh mới sang bước kế.

---

# ══════════ PHẦN C — Phase 9 (T6: Nội dung PvE) ══════════

**Mục tiêu:** các mode dungeon `DUNGEON.md` mô tả nhưng code CHƯA có + Ancient Boss. Tất cả **tái dùng `BattleSim`/`StageBattleService`/`BossController`/`FormationService`** — KHÔNG engine mới.
**Save:** bump **v9→v10** (dungeon attempts + endless state).

---

## 20.1 Slice C1 — Dungeon Framework (generic, data-driven — 1 hệ, nhiều type)

### Data
| Unit | Field |
|---|---|
| `data/dungeon_def.gd` `DungeonDef` | `id:String`, `type:int` (enum `DungeonType`), `display_name`, `reward_table:Array` ([{type,id,amount,weight}]), `daily_attempts:int=3`, `rotation_dow:int=-1` (−1=mọi ngày), `recommended_power:int`, `enemy_waves:Array`, `boss_def_id:StringName`, `team_size:int=5`, `energy_cost:int=0` |
| enums | `DungeonType {GOLD, EXP, CRYSTAL, MATERIAL, AWAKEN, EQUIPMENT, RUNE}` |

Bao **Resource (gold/exp/crystal/material/awaken) + Equipment + Rune** = cùng `DungeonDef`, khác `type` → 1 hệ, seed nhiều data.

### System
| Unit | API |
|---|---|
| `systems/dungeon/dungeon_service.gd` `DungeonService` (autoload sau PlayerProfile) | `attempts_left(id)->int`, `can_enter(id)->{ok,reason}`, `run(id, team:Array, seed_val)->{cleared, rewards, replay}` (reuse `StageBattleService`/`BattleSim` + `grant_reward`), `available_today()->Array` (lọc theo `rotation_dow` = `TimeService.day_of_week`), `daily_reset()` |

### Save v9→v10 + State
`PlayerProfile.dungeons = {"day":int, "attempts":{id:int}}`. `_migrate_v9_to_v10` thêm `dungeons={}`. Reset theo **ngày lịch thực** (`now_unix`, giống quest), KHÔNG `game_day()`.

### UI + EventBus + Test
- `ui/dungeon_panel.gd`: list dungeon hôm nay (rotation) + lượt còn + Deploy (dùng loadout SF, tôn trọng deploy-lock).
- EventBus: `dungeon_cleared(dungeon_id, rewards)`.
- `test_dungeon_service`: rotation theo dow đúng, attempts cap + reset, reward trong bảng, determinism (seed giống→giống).

**Acceptance C1:** test xanh; smoke chạy 1 dungeon mỗi type ra reward đúng focus; hết lượt → chặn; reset ngày → chơi lại.

---

## 20.2 Slice C2 — Endless Tower

| Unit | Việc |
|---|---|
| `data/endless_def.gd` `EndlessDef` | scaling curve (hp/atk theo floor), `floor_buffs:Array` (buff chọn mỗi X tầng), `reset_policy` (season) |
| `systems/dungeon/endless_service.gd` `EndlessService` | `current_floor()`, `attempt(team,seed)->{advanced, floor}`, `season_reset()`; scaling khó theo floor, hook `LeaderboardService` (P6) submit best-floor |
| Save | `PlayerProfile.endless = {floor:int, best:int, season_key}` |
| UI/Test | tab trong dungeon/battle panel; `test_endless`: scaling đơn điệu tăng, season_reset về floor 1 giữ `best`, determinism |

Design fork: reset theo **season** (★ đề xuất — làm mới leaderboard) vs vĩnh viễn.

---

## 20.3 Slice C3 — Elite + Challenge Dungeon (modifier-driven)

Tái dùng pattern `EventDef.modifiers` (reversible) + `BossPhaseDef.arena_hazard`.
| Unit | Việc |
|---|---|
| `data/challenge_def.gd` `ChallengeDef` | `rule:int` (enum `ChallengeRule {CLASS_ONLY, NO_HEAL, ONE_LIFE, DOUBLE_SPEED, POISON_FIELD}`), `rule_param`, `modifier:Dictionary` (áp trong sim), `weekly_rotation:bool`, `reward` |
| System | validate đội theo `rule` trước khi vào (CLASS_ONLY → team phải cùng class...) + apply modifier vào `BattleSim` (reversible) |
| Test | `test_challenge`: rule-enforce chặn đội sai; modifier áp & gỡ sạch; weekly rotation |

Elite = dungeon khó cao (difficulty tier + drop epic) — dùng `Enums.Difficulty` + reward table đậm, không luật riêng.

---

## 20.4 Slice C4 — Ancient Boss

Reuse `BossDef`/`BossPhaseDef`/`WorldBossService`/`BossController` (đã có, đa-phase/break/enrage).
| Unit | Việc |
|---|---|
| `data/ancient_boss_def.gd` `AncientBossDef` | wrap `boss_def_id` + `trigger:int` (enum `AncientTrigger {QUEST, SHRINE, SEASON, RANDOM}`), `trigger_param`, `first_clear_rewards`, `respawn_policy` |
| System | `systems/boss/ancient_boss_service.gd`: kiểm trigger (subscribe quest_completed / season / shrine-interact) → spawn qua machinery WorldBoss; solo scale |
| Data seed | **Ancient/Legendary rarity** equip + rune (drop độc quyền) — thêm vào `_build_p3`/ContentP9; `Enums.Rarity.LEGEND/MYTHIC` đã có |
| Test | `test_ancient_boss`: trigger-once (không spawn lặp), drop table, first-clear reward once |

---

### Deps & Risk (PHẦN C)
- Deps: **PHẦN A** (energy/quest gating, loadout deploy). Chạy được trên engine hiện tại; **đẹp hơn nếu sau B2** (skill-kit → dungeon mechanic sâu). 
- Risk: **trung bình** — nhiều content/data, ít engine-mới (reuse tối đa BattleSim/Boss/Stage).
- Design forks C: energy vs vé vs no-limit mỗi type (`DUNGEON.md`: thường không gate, khó thì cap lượt); Endless reset season vs vĩnh viễn.

---

# ══════════ PHẦN D — Phase 10 (T5: Chiều sâu Collection) ══════════

**Mục tiêu:** làm roster "sống" hơn — Pet, cốt truyện riêng hero, quan hệ. Giữ **no-P2W & tất định**.
**Save:** bump **v10→v11** (pets + relationships). D2 dùng state quest sẵn (P7).

---

## 21.1 Slice D1 — Pet

| Loại | Unit | API / field |
|---|---|---|
| Data | `data/pet_def.gd` `PetDef` | `id`, `display_name`, `rarity:int`, `effect:Dictionary` (buff aura, **percent nhỏ**), `element:int`, `sprite` — **không có stat combat trực tiếp** (GDD §15: pet hỗ trợ) |
| State | `systems/pet/pet_instance.gd` `PetInstance` | `pet_id`, `def_id`, `level`; `to_dict/from_dict` |
| State | `PlayerProfile.pets:Dictionary` + `hero.pet_id` | gán 1 pet / hero (hoặc / đội — chốt ở fork) |
| System | `StatAggregator` | thêm layer `"pet"` (percent) — **budget ≤ synergy scale**, `SynergyBalanceValidator` mở rộng kiểm cả pet |
| Gacha | reuse `SummonService` | Pet Egg banner → pet (dup→pet-shard) |
| UI/Test | `ui/pet_panel.gd`; `test_pet` | aggregate đúng + clamp + determinism; no-P2W (tổng pet% ≤ cap) |

Save v10→v11: `pets={}`, `hero.pet_id=""`.

---

## 21.2 Slice D2 — Hero Personal Questline

Tái dùng **Quest (P7 S2, `QuestCategory.CHARACTER`)** + **DialogueRunner (P7 S1)** + StoryManager feature-unlock pattern.
| Unit | Việc |
|---|---|
| `data/hero_quest_def.gd` `HeroQuestDef` | `hero_def_id`, chuỗi `steps` (objective + dialogue_id), `rewards` (mở skill alt / rune-synergy / awaken material — `STORY.md`) |
| System | reuse `QuestManager` (category CHARACTER) — không service mới; unlock ghi `story.features` |
| Data seed | 1-2 hero questline demo (gắn lore roster) |
| Test | `test_hero_quest`: tiến bước đúng, reward-once, unlock đúng |

Deps: **P7 S1 (dialogue) + S2 (quest)**. Không đụng save mới (dùng quest state). Risk: **thấp** (reuse).

---

## 21.3 Slice D3 — Relationships

| Unit | Việc |
|---|---|
| `data/relationship_def.gd` `RelationshipDef` | cặp/nhóm hero + bonus khi cùng đội (nhỏ) |
| System | `systems/relationship/relationship_service.gd`: đồ thị affinity hero-hero; nguồn tăng = festival/inn/cùng-đội (subscribe EventBus event/expedition đã có); ảnh hưởng **mood nhỏ** (đã có mood) + synergy phụ khi cùng đội |
| Save | `PlayerProfile.relationships:{pair_key:affinity}` (v11) |
| EventBus | `relationship_changed(a,b,affinity)` |
| Test | `test_relationship`: affinity tăng đúng nguồn, bonus áp khi cùng đội, roundtrip |

Deps: mood (✅). Risk: **trung bình-thấp**.

---

### Design forks D (chốt khi tới)
- **Pet gán:** ★ 1 pet / hero (sâu, nhiều lựa chọn) vs 1 pet / đội (đơn giản).
- **Pet power:** ★ budget ≤ synergy scale, đưa vào `SynergyBalanceValidator` (no-P2W) vs pet chỉ cosmetic/utility.
- **Relationship ảnh hưởng:** ★ nhẹ (mood + synergy phụ) vs chỉ social/cosmetic (an toàn nhất) vs combat rõ (rủi ro cân bằng).

### Acceptance D
- `test_pet`/`test_hero_quest`/`test_relationship` xanh; `SynergyBalanceSim` vẫn trong band sau khi thêm pet%; save v11 migrate sạch.

---

# ══════════ PHẦN E — Phase 11 (T10/T11/T13: Kinh tế · Endgame · Production) ══════════

**Mục tiêu:** đóng vòng kinh tế (thêm sink), nội dung endgame, và **production polish** (art/audio/i18n).
**Save:** bump **v11→v12** (crafting inv? không — dùng materials sẵn; achievements claimed). E4 không đụng save.

---

## 22.1 Slice E1 — Crafting + Salvage (sink kinh tế)

| Loại | Unit | API |
|---|---|---|
| Data | `data/craft_recipe_def.gd` `CraftRecipeDef` | `id`, `output:{type,id,amount}`, `cost_gold`, `cost_materials:Dictionary`, `unlock_req` (`ECONOMY.md`: craft = gold+material, **không Diamond**) |
| System | `systems/economy/craft_service.gd` `CraftService` (static) | `can_craft(recipe)->{ok}`, `craft(recipe_id)->{ok, output}` (trừ gold+material qua PlayerProfile, cấp qua `grant_reward`) |
| System | `systems/economy/salvage_service.gd` `SalvageService` (static) | `salvage(equip_uid/rune_uid)->{materials, crystal, dust}` (đồ cũ → material/crystal/dust, mọi loot có giá trị — `ECONOMY.md`) |
| Test | `test_craft`, `test_salvage` | transaction trừ đúng & **không âm**, reject khi thiếu, salvage value đúng theo rarity |

Reuse: currency/materials của PlayerProfile (đã có). Đây là **sink** chống lạm phát (economy sim P6 giám sát).

---

## 22.2 Slice E2 — Shop (NPC / Premium / IAP scaffold)

| Unit | Việc |
|---|---|
| `data/shop_def.gd` `ShopDef` | `id`, `entries:Array` ([{cost_currency, cost_amount, reward, stock, refresh_dow}]), `category` (daily/premium/exchange) |
| `systems/economy/shop_service.gd` `ShopService` | `buy(shop_id, entry_idx, claim_id)->{ok}` (idempotent qua RewardProtection; trừ currency; stock/refresh) — **no-P2W** (chỉ cosmetic/tiện-ích/exchange, không hero-mạnh độc quyền, `ECONOMY.md`) |
| IAP | **thật = ops** (store SDK) — P11 chỉ offline stub grant (debug `grant_pack`) |
| UI/Test | `ui/shop_panel.gd`; `test_shop`: mua/trừ/stock/refresh/idempotent |

---

## 22.3 Slice E3 — Endgame

| Mục | Unit | Việc |
|---|---|---|
| Achievements | `data/achievement_def.gd` + reuse `QuestManager` (category ACHIEVEMENT) | track dài hạn; UI **Sổ Thành Tựu** (nối "Advanced Objectives" sau tốt nghiệp P7) |
| Collection completion | reuse codex (`collection`/`codex_seen`) | thưởng mốc % codex |
| Titles / Cosmetics | UI cho `PlayerProfile.cosmetics` (storage đã có) | trang bị title/avatar-frame (no power) |
| Difficulty Mythic/Chaos | reuse Elite/Challenge modifier (C3) + `Enums.Difficulty` | khó = AI/mechanic/modifier, **không +HP thuần** (`BOSS.md`) |

Save v11→v12: `achievements_claimed={}`. Test: `test_achievement` (unlock+claim-once), collection reward once.

---

## 22.4 Slice E4 — Production (LIÊN TỤC — interleave sớm, không dồn cuối)

> ⚠️ Đây là **art/content + polish trải suốt dự án**. Cần từ bản demo đầu tiên. KHÔNG phải 1 slice cuối.

| Mảng | Việc | Nguồn/Công cụ |
|---|---|---|
| Audio | SFX/music thật thay `AudioManager` stub (`play_sfx/play_music` hiện pass) | `pixel-art.md` mood |
| Pixel art / sprite | thay placeholder Polygon2D+Label; hero/monster/building/UI sprite | `pixel-art.md` + `character-asset-pipeline.md` + **PixelLab MCP** (AI-gen) |
| Animation | idle/walk/attack/cast/hit/death (`SpriteLib` → sprite thật) | `Animator` agent |
| UI/UX theme | art hoá panel qua `ui/theme.tres` | `ui.md` |
| Localization (i18n) | tách chuỗi VN hardcode → bảng dịch | — |
| Settings + Notifications | màn cài đặt (audio/graphics/lang) + push nhắc quay lại | — |

Risk: **cao công sức (art), thấp logic**. Deps: gameplay ổn định (nhưng art placeholder thay dần từ sớm).

### Acceptance E
- E1-E3 test xanh; economy sim (P6) xác nhận source↔sink cân sau khi thêm craft/salvage/shop (no infinite gold). E4 = tiêu chí visual/manual (`unit-testing.md`: không unit-test art).

---

# ══════════ PHẦN F — Phase 12 (T12: Backend thật + Release) ══════════

**Mục tiêu:** biến lớp online offline-first (P6, logic đã test qua `MockBackend` in-memory) thành **backend thật**. Chủ yếu **OPS + adapter mỏng** — logic đã có & đã test headless. Chi tiết nền: `docs/PHASE6.md §6`.
**Save:** v12→v13 nếu cần field liên kết account online (device→cloud link); phần lớn account field đã có từ P6 (v6→v7).

### F1 — Supabase provisioning (ops)
Project + tables (leaderboard/guild/save/pvp_defense) + **RLS** (client KHÔNG insert bảng giá trị trực tiếp) + auth (anonymous→link). Config qua `data/network_config.gd` `NetworkConfig` (đã có: `supabase_url/anon_key/env/enable_online`).

### F2 — Edge Functions (Deno) — port MockBackend 1:1
Port từng handler `MockBackend` sang Edge Function **cùng logic**: `lb-submit` (chạy lại BattleSim seeded chống điểm giả), `save-upload/download` (checksum + chống progress-regression + conflict), `guild-create/join/boss-hit/shop-buy` (shared-HP & coin trừ server-side), `pvp-defense-set/submit` (verify `stat_hash` + replay seed), dedupe idempotent theo `command_id`, rate-limit. **Nguồn sự thật = mirror của `MockBackend`** → so khớp được bằng test.

### F3 — HTTP adapter (thay MockBackend)
| Unit | Việc |
|---|---|
| `systems/net/http_backend.gd` `HttpBackend` | cùng interface `MockBackend` (`invoke(command)->CommandResult`) nhưng qua `HTTPRequest` async tới Edge Function; retry/backoff theo `NetworkConfig` |
| `NetManager` | chọn backend theo `NetworkConfig.enable_online` (offline→queue local; online→HttpBackend). Không đổi service tầng trên (Leaderboard/Guild/AsyncPvp gọi `NetManager` như cũ) |
| Test | `test_http_backend` (mock HTTP): serialize roundtrip, offline→queue→reconnect replay idempotent (tái dùng `test_net` pattern) |

### F4 — Network UI screens
`ui/leaderboard_screen.gd`, `ui/guild_screen.gd`, `ui/arena_screen.gd`, `ui/conflict_dialog.gd`, `ui/network_inspector.gd` (dev-only, gate `ReleaseGate`). Offline → hiện "chưa kết nối", game KHÔNG phụ thuộc (read-only rỗng).

### F5 — Release
| Việc | Chi tiết |
|---|---|
| `BenchmarkWorld.tscn` | on-device 300 hero/1000 monster @60fps profiling (`performance.md`) |
| Release runbook | 13-step + rollback + monitoring dashboard (`prompts/release.md`) |
| ReleaseGate verify | build release TẮT toàn bộ Debug/cheat/network-inspector |
| Store | IAP SDK (E2), quyền, đóng gói Android portrait |

Deps: **mọi phase khác ổn định**. Risk: **thấp code / cao infra-dependency**. Reuse: toàn bộ `systems/net/` + `AntiCheatValidator` + `CloudSaveService` + `LeaderboardService`/`GuildService`/`AsyncPvpService` **đã test headless P6**. Nguyên tắc offline-first giữ nguyên: online chỉ là lớp verify + source-of-truth cho giá trị cạnh tranh (`multiplayer.md`).

### Acceptance F
- `test_http_backend` xanh + toàn suite xanh với `enable_online=false` (offline vẫn trọn vẹn). Edge Function so khớp output `MockBackend` trên bộ case chung. Benchmark đạt ≥45fps floor / 60fps target trên mid-range.

---

# ══════════ Tổng: thứ tự & phụ thuộc ══════════

```
P7 (cửa trước)  ─┬─→ P8 (combat depth) ─→ P9 (PvE content)
                 │                          ↑
                 └─→ P10 (collection depth) ┘   (P10 D2 cần P7 S1+S2)
P9,P10 ─→ P11 (economy/endgame) ─→ P11.E4 art/audio (interleave sớm) ─→ P12 (backend/release)
```

- **Bắt buộc trước:** P7 (nền meta) → mọi thứ. SF (team-5) → B1 synergy. P7 S1+S2 → P10 D2 questline.
- **Làm sau khi game chơi được:** B2 skill-kit (rebalance toàn content), P12 backend.
- **Interleave, đừng dồn cuối:** E4 production (art/audio) — cần cho mọi bản demo/release.
- **Độ sâu spec:** PHẦN B–F đào tới-từng-unit KHI tới lượt (tạo `## §` mới trong CHÍNH file này — không tách file), cập nhật `FEATURES.md` trạng thái.
