# Phase 4 — Nội dung có cấu trúc: Boss · Stage · PvP (Đấu Trường)

> Tài liệu feature theo `prompts/feature.md`. Trạng thái: **HOÀN THÀNH** — 337/337 test xanh (headless Godot 4.7).

## 1. Mục đích & trải nghiệm

Biến "thế giới sống" thành "thế giới có mục tiêu tuần/mùa":

- **World Boss** đa phase xoay theo ngày (rotation tuần) — kiểm tra chiến thuật (phase/enrage/break/interrupt/summon), không phải bài kiểm tra Battle Power thuần.
- **Stage "3/3"** trên world-map: trận tất định seeded, đội hình cố định, chấm sao 1–3.
- **Đấu Trường Bot (async)**: đấu snapshot đối thủ đã freeze, trận 90s auto, timeout xử theo HP%, MMR-lite + Honor, replay tất định.

Người chơi vẫn **không điều khiển** hero trong trận — mọi thứ auto, deterministic, xem được và tua lại được.

## 2. Kiến trúc (SIM ↔ VIEW tách bạch)

```
UI (BattlePanel)                         ← chỉ đọc + gọi service
   ↓
Service: WorldBossService / ArenaService / StageBattleService
   ↓
BattleSim (headless, tất định 10Hz) + BossController + FormationService
   ↓
Data: SkillDef / BossDef / BossPhaseDef / FormationDef / StageDef  (Database façade)
   ↓
State: BossRuntimeState / ArenaSnapshot / ReplayData  (serialize → save = network snapshot)
```

**Quyết định kiến trúc (Architect):**
- **BossSkillDef gộp vào `SkillDef`** — mọi field boss (`cast_time`, `interruptible`, `warning_sec`, `select_rule`, `threat_gen`, `weak_point_id`, `break_damage`, `summon_group_id`) nằm trong `SkillDef` dùng chung hero+boss. DRY, tránh lớp trùng.
- **Content code-built trong `ContentP4`** (giống `ZoneDef`/`BuildingDef` của P1–P3) thay vì rải `.tres` — nhất quán với dự án, dễ test, vẫn là `Resource` nên chuyển `.tres` sau được.
- **BattleSim là engine P4 riêng**, KHÔNG sửa `BattleEngine` P1 (expedition vẫn chạy nguyên) — mở rộng không phá vỡ.
- Boss "components" ở SIM headless là **pure class** (`BossController`) thao tác trên state, không phải Node — đúng "SIM là data + math".

## 3. Data Model

| Def / State | Vai trò |
|---|---|
| `SkillDef` | Skill dùng chung (basic-attack + boss skill). Target mode, CC, weak-point, break, summon. |
| `BossDef` | Boss đa phase: stats nền, `phase_ids`, `enrage_timer_sec`, `weak_points`, `break_max`. |
| `BossPhaseDef` | Trigger (HP%/TIME/MINION/BREAK) → `stat_mult`, swap `skill_ids`, `summon_group_id`, `hazard`. |
| `FormationDef` | Slot lưới + buff hàng (front +def, back +atk/tốc). Dùng chung stage & arena. |
| `StageDef` | Wave enemy + boss tuỳ chọn, `star_rules`, first-clear/repeat reward. |
| `BossRuntimeState` | HP/phase/break/enrage/aggro_table (bounded)/contribution/minions/reward_claimed — serialize. |
| `ArenaSnapshot` | Freeze stat đội (khớp save = network snapshot). |
| `ArenaMatchResult` | outcome/duration/hp%/mmr_delta/honor/replay_id. |
| `ReplayData` | seed + initial_state + command_stream (ID-based, KHÔNG animation). |

## 4. Save Model (v4 → v5)

- `player.stage_stars`, `player.stage_claims`, `player.currency.honor`.
- `world.world_boss` = `BossRuntimeState.to_dict()` (WorldBossService sở hữu).
- `world.arena` = {mmr, quota_used, quota_day, win_streak, defense snapshot} (ArenaService sở hữu).
- Migration `_migrate_v4_to_v5` thêm field mặc định, **không mất data**; giữ `.bak` + checksum như cũ.
- PlayerProfile `_world_dict()` gộp block từ ExpeditionService + WorldBossService + ArenaService; mỗi service `import_world()` trong `_ready` (autoload order: sau ExpeditionService).

## 5. Determinism & Replay

- Tick 10Hz, RNG **cục bộ seeded** mỗi trận (không đụng RandomService global), thứ tự duyệt ổn định theo `id`.
- Pipeline damage: **Damage → Crit → Def → Resist → (weak-point) → (break-mult) → Shield → HP**.
- `ReplayPlayer.play()` phát lại **qua chính BattleSim** ⇒ replay == trận gốc. `SIM_VERSION` pin = 1 (đổi công thức → bump → cảnh báo regression).

## 6. Telemetry & Debug

- Telemetry channel: `Boss` (spawned/phase_changed/enraged/interrupted/break/defeated/failed/reward_claimed), `Stage` (cleared/failed), `Arena` (match_finished/timeout/honor_gained/honor_spent/replay_saved).
- Debug console: `start_world_boss, engage_boss, set_boss_hp, show_contribution, claim_rewards, end_world_boss, reset_boss_event, run_stage, set_stars, arena_opponents, arena_fight, set_mmr, grant_honor, replay_last`.

## 7. Performance Notes

- Không AI trong `_process()`; sim headless chạy theo tick-budget.
- Minion **spawn dàn 1 con/tick** (không mass-spawn 1 frame), dùng pool enemy hiện có.
- `aggro_table` bounded (`AGGRO_MAX_ENTRIES=64`), contribution cộng dồn (không recalc mỗi frame).
- Sim batch 60 trận arena + world boss 8-hero trong test < 1s.

## 8. Cân bằng (số hiện tại)

- Arena bot pool 5 hạng, MMR 900–1400; MMR-lite K-band {40/24/16}, clamp ≥ 0.
- Timeout 90s (900 tick) xử theo HP% (tie → attacker/hero).
- Forest Guardian (Region 2-phase, cơ chế BREAK); Abyss Dragon (World 4-phase: Shield→Summon→ArenaBreak→Enrage, có weak-point "head" +50%, enrage 300s).

## 9. Ngoài phase (chừa hook, chưa build)

Guild War / Team Arena / Draft-Ban / Tournament / Cross-Server; World Boss leaderboard online (P6); Anti-Meta động & Seasonal PvP Modifier (chỉ chừa data hook); Ancient/Final Boss 5-phase (P5 story).

## 10. Test coverage

`test_battle_sim` (tất định, resist/weak-point/shield, CC-interrupt), `test_boss` (phase/enrage-once/break/reward-once/contribution), `test_formation`, `test_arena` (MMR đối xứng+clamp, timeout theo HP, fight+replay tất định), `test_stage` (sao + first-clear once), `test_replay_regression` (golden replay + boss save/load), `test_boss_arena_simulation` (60 trận arena + world boss 4-phase).
