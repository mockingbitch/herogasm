# Phase 5 — Cốt truyện & khung Season/Event

> Tài liệu feature theo `prompts/feature.md`. Trạng thái: **HOÀN THÀNH** — 393/393 test xanh (headless Godot 4.7).

## 1. Mục đích & trải nghiệm

Story + Season là lớp **keo điều phối** gắn mọi hệ thống P1–P4 thành thế giới sống có mục tiêu tuần/mùa (CLAUDE.md: "Never build isolated gameplay. Always build systems"):

- **Campaign** (Prologue → Chapter 1–10 → World/Abyss/Final Arc): mỗi chapter mở tính năng (story-unlock gate), tặng hero/rune, dùng stage/boss của P4.
- **Season** = 1 biến dị Abyss: story arc + seasonal boss + event + **meta rotation** (buff rune/equip/synergy, KHÔNG hero base) + battle pass + seasonal currency/shop + rank reset + world evolution.
- **Event** lifecycle đầy đủ (Scheduled→Preparation→Active→Reward→Cooldown), modifier tạm & reversible, reward chống trùng, save active events.
- **World Evolution**: kết cục boss/event đổi trạng thái vùng đất (corruption / mở dungeon) → hook world scene.

## 2. Kiến trúc

```
UI (SeasonPanel)                         ← chỉ đọc + gọi service (signal-rules.md)
   ↓
Autoload: StoryManager · SeasonManager · EventManager · WorldEvolutionService
   ↓
Service thuần: MetaRotationService · BattlePassService · SeasonalShopService · RankResetService
   ↓
Data: ChapterDef · SeasonDef · EventDef · BattlePassDef · DialogueDef  (Database façade)
   ↓
State: PlayerProfile.story/battlepass/cosmetics + world.{season,events,world_state}  (save v6)
```

**Quyết định kiến trúc:**
- **CutsceneDef gộp vào `DialogueDef`** (`is_cutscene()` khi có `slides`) — DRY, như BossSkillDef→SkillDef ở P4.
- **Meta rotation inject qua `team_ctx`** (không để StatAggregator phụ thuộc autoload runtime): `PlayerProfile.team_context()` bơm `{synergy, meta}`, `StatAggregator._apply_meta` áp buff cho rune/equip hero ĐANG sở hữu. Không match → không đổi (giữ tính thuần & tất định cho test).
- **Anti-power-creep là gate cứng**: `MetaRotationValidator` từ chối mọi rule target hero base; `SeasonManager.start_season` reject season không hợp lệ.
- Content code-built trong `ContentP5` (nhất quán P1–P4). Reward đi qua router chung `PlayerProfile.grant_reward` (event/story/battle-pass/shop dùng chung).
- **WorldEvolutionService là autoload** (khác gợi ý "service dưới GameState") để subscribe EventBus + persist gọn — nhất quán ExpeditionService/ArenaService.

## 3. Data Model

| Def | Vai trò |
|---|---|
| `ChapterDef` | stage/boss (P4) + intro dialogue + `unlock_rewards` + `unlock_gate` + `prerequisite_id`. |
| `SeasonDef` | abyss mutation + story arc + seasonal boss + events + `meta_rotation` + battle pass + currency/shop + `world_evolution_rules` + `rank_reset_policy`. |
| `EventDef` | category/priority + duration/prep/cooldown + conditions + modifiers (reversible) + rewards + story dialogue + chain. |
| `BattlePassDef` | Free/Premium reward theo level (cosmetic-first). |
| `DialogueDef` | lines (hội thoại) + slides (cutscene) + next_action. |
| `EventRuntimeState` | phase/remaining/progress/participants/contribution/reward_claimed/cooldown/active_modifiers — serialize. |

## 4. Save Model (v5 → v6)

- `player.story` (arc/current_chapter/completed/features), `player.battlepass`, `player.cosmetics`.
- `world.season` (season_id/start_day), `world.events` (runtime), `world.world_state` (region flags).
- Migration `_migrate_v5_to_v6` thêm field mặc định, **không mất data**. Mỗi service `export/import_world` gộp vào world block qua `PlayerProfile._world_dict()`.

## 5. Anti-power-creep (meta rotation)

`meta_rotation` chỉ chứa `rune_buffs`/`equip_buffs`/`synergy_buffs` (id-based). Validator cấm mọi key hero-targeting. Buff áp **chỉ khi hero sở hữu** rune/set/synergy tương ứng → tổng power hero không đổi nếu không sở hữu. Gỡ khi rollover.

## 6. Event lifecycle & modifiers

`EventManager` là nơi DUY NHẤT start/stop. Tick qua scheduler chung (KHÔNG `_process` polling). Overlap: ≤1 major + ≤2 medium + nhiều minor. Modifier áp khi vào ACTIVE, **gỡ sạch khi rời ACTIVE** (reversible aggregate `modifier_multiplier(target)`). Reward `claim_reward` idempotent (`reward_claimed`). Save khôi phục remaining_time + phase.

## 7. Telemetry & Debug

- Telemetry: `story_chapter_started/completed`, `story_feature_unlocked`, `season_started/ended`, `event_scheduled/started/ended/reward_claimed`, `battlepass_level_up`, `seasonal_shop_purchase`, `seasonal_currency_expired`, `rank_reset`, `world_state_changed`.
- Debug console: `start_event/end_event/show_active_events/claim_event_reward/trigger_festival`, `set_chapter/complete_current_chapter/unlock_feature`, `start_season/skip_season_days/force_season_rollover/set_world_state/add_seasonal_currency/set_battlepass_level`.

## 8. Season of Frost (ví dụ tham chiếu)

`duration_days=56`, seasonal boss `abyss_dragon` (biến dị Ice demo), events `frost_festival`/`blizzard`/`double_rune_day`, meta rotation buff rune `fire_atk`/set `guardian`/synergy `elf_syn`, currency `frost_shard` + `frost_shop` (cosmetic-first, hết hạn cuối mùa), battle pass `frost_pass`, world evolution: boss sống → `iron_mountain.corruption`; hạ → `frozen_fortress_open`.

## 9. Ngoài phase (hook, chưa build)

Online season sync / cross-server / leaderboard backend → P6. Character personal questline & corruption-branch, Guild story, collaboration event, procedural side-quest, IAP battle pass → live-ops/P6.

## 10. Test coverage

`test_story` (complete/gate/prereq), `test_event` (prep→active→reward, modifier reversible, reward-once, festival mood, overlap cap), `test_season` (validator anti-creep, meta apply owned-only, currency expire, rank reset bất biến, battle pass claim-once), `test_migration_v6` (v5→v6 + event save/load), `test_season_simulation` (start → world evolution outcome → rollover sạch).
