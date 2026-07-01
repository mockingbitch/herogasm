# Phase 6 — LiveOps hardening · Online · Release

> Trạng thái: **CORE HOÀN THÀNH (headless-testable)** — 464/464 test xanh (Godot 4.7). Phần cần hạ tầng thật
> (Supabase project, Edge Functions Deno, release runbook/monitoring) là lớp adapter mỏng + ops, đặt sau khi deploy.

## 1. Phạm vi đã giao (client + server-assisted logic, offline-first)

P6 **hardening thứ đã tồn tại** (P1–P5 đã deterministic + serializable). Nguyên tắc: **offline chơi trọn vẹn**, online chỉ là lớp **verify + source-of-truth** cho giá trị cạnh tranh (multiplayer.md). Vì môi trường dev không provision được Supabase, logic Edge Function được hiện thực trong **`MockBackend` in-memory** (mirror y hệt) → toàn bộ đường online chạy & test headless được. Bản production chỉ thay `MockBackend` bằng adapter `HTTPRequest` tới Edge Function **cùng logic**.

- **Net** (autoload, nâng từ stub): `ConnectionState` (OFFLINE/CONNECTING/ONLINE/DEGRADED), offline **command queue**, **reconnect replay idempotent** (dedupe theo `command_id` → không double reward). `submit/send/query`. Offline → queue + game chạy local.
- **GameCommand / CommandResult**: lệnh có giá trị serializable (ID-based) + kết quả server.
- **MockBackend** (server-assisted verify, single source of truth): `lb-submit` (chạy lại BattleSim seeded → chống điểm giả), `save-upload/download` (checksum + chống progress-regression + conflict), `guild-create/join/boss-hit/shop-buy` (shared-HP & coin trừ **server-side**), `pvp-defense-set/submit` (verify `stat_hash` chống chỉnh + chạy lại seed), dedupe idempotent, rate-limit.
- **LeaderboardService** (submit server-verified, client chỉ read), **GuildService** (create Lv20+, role, boss-hit, shop), **AsyncPvpService** (defense snapshot + attack + tamper reject) — tái dùng ArenaSnapshot/BattleSim (P4).
- **CloudSaveService + ConflictResolver** (policy highest_progress/latest_timestamp/manual), **AntiCheatValidator** (energy/integrity/verify-trận/progress).
- **Hardening headless**: `MetricsCollector` (aggregate + regression detect), `StressTestRunner` (Level 1-4 SIM tải lớn, luôn ra winner), `EconomySimRunner` (30 ngày: source↔sink, no infinite gold, offline cap ≤80%).
- **ReleaseGate** (autoload): feature flag `is_release` (env `HEROGASM_RELEASE` / `OS.is_debug_build`) — release build TẮT toàn bộ Debug/cheat. `Debug.enabled = ReleaseGate.debug_enabled()`.
- **Telemetry**: `track(event, category, payload)` + **sampling** event tần suất cao (giữ 1/N, never-sample event quan trọng) + versioned + không PII.
- **Save v7** (+migration v6→v7 account fields). **Sửa bug save-checksum tất định** (xem §3).

## 2. Kiến trúc

```
UI/Service → GameCommand → Net.submit → [ONLINE] MockBackend.invoke (verify+authority, dedupe)
                                       → [OFFLINE] queue + local SIM → reconnect replay
Net.query (read-only) → leaderboard/guild (offline → rỗng, game không phụ thuộc)
```

**Quyết định:** online services là **static** gọi `NetManager` (không autoload thừa). Server logic sống trong `MockBackend` = mirror Edge Function; production thay bằng HTTP adapter cùng interface. Không có `.tscn` network UI ở P6 core (gate dev-only + không headless-verify được) — dựng khi tích hợp backend thật.

## 3. Save integrity fix (bug tiềm ẩn từ P0)

JSON của Godot parse MỌI số thành float, nên `int 777` lúc ghi hash ra `"777"` nhưng đọc lại thành `777.0` → `"777.0"` ⇒ **checksum luôn mismatch**, mọi save âm thầm rơi vào fallback (`.bak`/cloud recovery chưa từng hoạt động). Đã sửa: `_checksum` normalize qua 1 vòng `parse(canon(x))` (int→float thống nhất) + ghi file `full_precision`. Nay save→load→verify tất định, `.bak` recovery & cloud conflict hoạt động thật. Verify: boot lần 2 nạp save không còn cảnh báo checksum.

## 4. Anti-cheat (server-assisted)

Client KHÔNG insert trực tiếp bảng giá trị (RLS/khái niệm). Mọi ghi qua backend verify: điểm leaderboard **chạy lại trận seeded**; PvP verify `stat_hash` + replay seed; guild boss HP/coin trừ server-side; reward idempotent theo `command_id`; save chống checksum sai + progress tụt; rate-limit theo (account,type).

## 5. Telemetry & Debug

- Telemetry event: session/hero/quest/building/economy/boss/event/save + network (`connection_state`, `command_sent/failed`, `reconnect_success`, `conflict_detected`, `cloud_save_upload/download`) + perf (sampled). Không PII.
- Debug (gate `ReleaseGate`): `simulate_disconnect/reconnect`, `show_pending_commands`, `clear_command_queue`, `force_cloud_upload`, `validate_save_integrity`, `save_now`, `run_stress`, `run_economy_sim`, `show_leaderboard`, `release_info`.

## 6. Ngoài phase (ops/LiveOps sau deploy)

Supabase project thật + Edge Functions Deno + RLS; `HTTPRequest` async adapter (thay MockBackend); network UI scenes (LeaderboardScreen/GuildScreen/ArenaScreen/ConflictDialog/NetworkInspector); `BenchmarkWorld.tscn` on-device 300 hero/1000 monster @60fps profiling; release runbook 13-step + rollback + monitoring dashboard; Guild War / PvP real-time / market (LiveOps).

## 7. Test coverage

`test_net` (serialize roundtrip, idempotent dedupe, offline queue + reconnect replay, rate-limit), `test_cloud_save` (checksum fail, progress regression, conflict detect, resolver policy, integrity), `test_pvp_online` (tamper reject, seed-deterministic match, forged leaderboard reject), `test_guild` (create/join/role, boss shared-HP server-side, shop coin server-side), `test_migration_suite` (v1→N preserve + dup-id validate + **.bak recovery**), `test_liveops` (metrics regression, stress levels, 30-day economy invariants, release gate).
