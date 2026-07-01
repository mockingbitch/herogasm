# Herogasm — Kế hoạch phát triển (PLAN)

> Tài liệu triển khai chi tiết theo từng giai đoạn cho **Herogasm** — game *living-world idle RPG* (pixel-art, Godot 4.x, Typed GDScript, mobile-first), lấy cảm hứng **Evil Hunter Tycoon**.
>
> **Nguồn sự thật của dự án:** [`CLAUDE.md`](CLAUDE.md) + [`.claude/rules/`](.claude/rules/) (24 rule bắt buộc) + `.claude/agents/` (11) + `.claude/skills/` (14 `build-*`). Tài liệu này *cụ thể hoá* các nguyên tắc đó thành lộ trình thực thi. Khi có mâu thuẫn: **CLAUDE.md / rules thắng**, kế đến là quyết định đã chốt (mục dưới), rồi đến PLAN này.
> **Design bible:** [`docs/scripts/`](docs/scripts/) (GDD, HERO, COMBAT, SKILLS, EQUIPMENT, RUNE, DUNGEON, BOSS, GUILD, PVP, EVENTS, ECONOMY, BALANCE, STORY, WORLD).

*Cập nhật: 2026-07-01 · Trạng thái: pre-production, chuẩn bị vào Phase 0.*

---

## 0. Cách dùng tài liệu này

- Mỗi phase là một chương độc lập với cùng bố cục: **Mục tiêu → Vì sao ở đây → Phạm vi → Hệ thống → Data model → Autoload → Scene → Task breakdown → Tests → Telemetry & Debug → Cổng Run & Test → Deliverables → Rủi ro**.
- **Cổng Run & Test** là điều kiện PASS/FAIL. *Chỉ qua phase sau khi cổng hiện tại PASS.*
- Ký hiệu: 🟡 = hàng rào MVP · ◈ = việc online/Supabase · ⚙️ = việc kỹ thuật nền · 🎨 = phụ thuộc art.
- Ước lượng thời lượng theo **1 dev có kinh nghiệm**; đội đông hơn thì P3 và P4 chạy song song được.

---

## 1. Tóm tắt game

**Herogasm KHÔNG phải RPG truyền thống.** Đó là một **mô phỏng thế giới sống**:

- Hero **tự sống** trong thành — tự đi săn, nghỉ, ăn, sửa đồ, mua sắm, nhận quest, rời cổng, quay về.
- Quái roam liên tục; thành vận hành cả khi người chơi offline.
- Người chơi là **chủ thành + nhà chiến thuật**, *ảnh hưởng* chứ *không điều khiển* hero.
- Niềm vui đến từ việc **ngắm thế giới tiến hoá** và ra quyết định build/xây/đội hình.

Bốn trụ cột: **Living Town · Autonomous Heroes (Utility AI) · Simulation-First · Mobile-First**. Thế giới đổi thay theo **Season gắn cốt truyện** (cơ chế *Abyss* — xem Phụ lục A).

---

## 2. Quyết định đã chốt

| # | Quyết định | Hệ quả |
|---|-----------|--------|
| 1 | **Tên game = Herogasm**; "Kingdom of Ashes" giữ làm **lore** (vương quốc đổ nát) | Rename đã xong trong docs/.claude |
| 2 | **Bỏ hẳn action-RPG**; archive slice cũ sang branch `archive/action-slice` | Giữ ~700 dòng spine, bỏ ~900 dòng combat vật lý |
| 3 | Hero **KHÔNG permadeath** — chết combat = **bất tỉnh** → về thành hồi | "Retire theo danh vọng" để tính năng muộn |
| 4 | **Expedition = xem trận trực tiếp** (xem hero auto-hunt ở Bãi Săn mở) | Stage "3/3" là chế độ phụ |
| 5 | **Supabase sớm** (cloud-save P1, leaderboard P2, full P6) | Game vẫn chơi **offline trọn vẹn**; online là lớp sync |
| 6 | **Art = AI-generate** | 0x72 tileset làm placeholder P0–P1 |
| 7 | Quy mô mục tiêu **300 hero / 1000 monster / 200 NPC @ 60fps** | Scheduler + pooling từ đầu; không AI trong `_process()` |

**Còn phải chốt trước khi author data:** năng lượng-lá gate cái gì (Bãi Săn/expedition?) · team size (đề xuất 5 đánh / 4 expedition) · ai vận hành Supabase backend · công cụ AI-art & license thương mại · phiên bản Godot chính xác (repo ghi 4.7).

---

## 3. Kiến trúc chung (tham chiếu xuyên suốt các phase)

### 3.1 Autoloads / Services (singletons)

| Autoload | Trách nhiệm | Nguồn |
|----------|-------------|-------|
| `EventBus` | Hub signal decouple gameplay↔UI | tái dùng (giữ signal kinh tế/inventory, bỏ combat vật lý) |
| `GameState` | Trạng thái phiên, tiện ích chung | tái dùng (bỏ input map action) |
| `SaveManager` | Ghi atomic + `.bak` + version + **migration** | tái dùng, mở rộng v2 |
| `Database` | Façade registry data-driven (`get_hero/get_item/...`) | tái dùng, mở rộng bảng |
| `PlayerProfile` | State tài khoản: ví, roster, thành, tiến trình | **mới** (tách từ Profile) |
| `TimeService` | Thời gian, timer expedition, offline accrual | **mới** |
| `Telemetry` | Ghi event (không PII) | **mới** (stub P0) |
| `Debug` | God-mode, spawn, fast-time, cheat (chỉ internal/QA) | **mới** (stub P0) |
| `SeasonManager` | Vòng đời season/event/story | **mới** (stub P0, đầy đủ P5) |
| `AudioManager`, `NetManager` | Âm thanh; online (Supabase) | tái dùng stub |

> `HeroInstance` **không** phải autoload — là object/Resource per-hero mang toàn bộ math chỉ số (tái dùng từ `profile.gd`). `PlayerProfile` giữ một mảng `HeroInstance`.

### 3.2 Dữ liệu — data-driven qua Resource `.tres`

`HeroDef · SkillDef · ItemDef · RuneDef · TalentDef · BuildingDef · RegionDef · EnemyDef · LootTable · ChapterDef · SeasonDef · EventDef`. Tất cả nạp qua `Database` để call-site ổn định. Nội dung (`.tres`) tách khỏi code → dễ thêm hero/building/season và localization.

### 3.3 Battle Engine (trái tim combat)

- Module **thuần, headless, TẤT ĐỊNH**: `input = (team A snapshot, team B snapshot, seed)` → step tick cố định (đề xuất 20 tick/s) → `output = BattleResult + timeline sự kiện`.
- Damage pipeline thống nhất: **Damage → Crit → Defense → Resistance → Shield → HP**.
- Dùng chung cho: Bãi Săn (roaming), stage formation, boss đa phase, PvP bot.
- **Tách SIM ↔ VIEW**: `BattleView` replay timeline (tái dùng decouple `EventBus` + `damage_number`). Cho phép: giải offline tức thì, replay, PvP công bằng, **unit-test combat headless**.

### 3.4 Hero AI — Utility AI (không FSM ngây thơ)

Goal cạnh tranh điểm (`Hunt / Rest / Repair / Shop / Train / Idle / Flee`), scorer theo consideration (HP%, độ bền đồ, túi tiền, khoảng cách, nhu cầu). **Chạy qua Scheduler theo bucket** (chia hero thành N nhóm, mỗi tick chỉ chấm 1 nhóm) để đạt 300 hero @ 60fps. Tuyệt đối không AI trong `_process()`.

### 3.5 Save (JSON atomic + migration)

Ghi file tạm → `rename` (atomic) + giữ `.bak` + `save_version`. Lưu: **ID / runtime data / inventory / progress / world state** (KHÔNG lưu node/animation/signal). Mỗi lần đổi schema → **migration test round-trip** bắt buộc. Cloud-save Supabase từ P1 (offline vẫn đầy đủ).

### 3.6 Cấu trúc thư mục đề xuất (dưới `game/`)

```text
game/
├── autoload/        # services singleton
├── data/            # class Resource (*Def.gd)
├── resources/       # nội dung .tres (heroes/, items/, buildings/, regions/, seasons/…)
├── entities/        # hero/ monster/ npc/ building/ (scene + script + view-model)
├── systems/         # battle_engine/ ai/ save/ economy/ season/ spawn/ time/
├── ui/              # screens/ components/ viewmodels/
├── scenes/          # Main.tscn + screen router
├── tests/           # unit/ integration/ simulation/ regression/
├── tools/           # debug/ (debug panel, cheats — build internal/QA)
└── assets/          # sprite/audio/vfx (AI-gen + 0x72 placeholder)
```

### 3.7 Quy ước code (theo `.claude/rules/coding-style.md` + `gdscript.md`)

- **Typed GDScript** bắt buộc, đặt tên rõ, hàm/lớp nhỏ, composition > inheritance.
- Không: global mutable state, magic number/hardcoded gameplay value, gameplay trong UI, save-logic trong entity, animation điều khiển gameplay, business logic trong scene.
- Mỗi feature kèm: **Debug tool + Telemetry + Test + Doc** (PR checklist trong CLAUDE.md).

---

## 4. Tổng quan lộ trình

| Phase | Tên | Thời lượng | Phụ thuộc | Cột mốc |
|------:|-----|-----------|-----------|---------|
| **0** | Pivot · đổi tên · xương sống | 4–6 ngày | — | Nền refactor xong |
| **1** 🟡 | MVP: Lõi thế giới sống | 3–4 tuần | P0 | **Vòng lặp EHT chạy được** |
| **2** | Chiều sâu thành · vòng đời hero · bản đồ | 4–5 tuần | P1 | Bản sắc idle/AFK |
| **3** | Sưu tập hero & chiều sâu build | 4–6 tuần | P1 (∥ P2) | Meta/build đa dạng |
| **4** | Boss · stage · PvP bot | 4–6 tuần | P3 | Encounter + cạnh tranh |
| **5** | Cốt truyện & khung Season/Event | 4–6 tuần | P4 | **Live-service ready** |
| **6** | LiveOps · Online · Release | 6–10 tuần + backend | P5 | Đủ chuẩn phát hành |

### Đồ thị phụ thuộc

```text
P0 ──► P1 ──►┬──► P2 ──┐
             │         ├──► (P2 & P3 hội tụ) ──► P4 ──► P5 ──► P6
             └──► P3 ──┘
```

> **Nếu thiếu thời gian:** dừng sau P1 để test vòng lặp; dừng sau P3 để có bản chơi sâu offline; P5–P6 là live-service.

---

## Phase 0 — Pivot, đổi tên Herogasm & xương sống
> **Mục tiêu:** Chốt hướng living-world, dọn code sai thể loại (action-RPG cũ), refactor spine kinh tế/stat sang `PlayerProfile` + `HeroInstance`, nâng SaveManager lên v2 có migration, dựng khung test/telemetry/debug/time để mọi phase sau bám vào · **Thời lượng:** 4-6 ngày · **Phụ thuộc:** không (phase nền tảng)

### Vì sao ở đây
Repo hiện tại là một **vertical slice action-RPG**: người chơi điều khiển 1 `Player` (`game/actors/player/player.gd`) đánh quái bằng hitbox/hurtbox, chạy scene `run.tscn`/`boss_arena.tscn`, input WASD+attack đăng ký trong `game_state.gd`. Toàn bộ mô hình này **mâu thuẫn trực tiếp** với `CLAUDE.md` ("player is the ruler, not the hero", "Autonomous Heroes", "The world is always visible"). Nếu không dọn trước, mọi phase sau sẽ xây trên một trục điều khiển sai và các rule (`architecture.md` mục *Hero Autonomy*, `ui.md`) sẽ bị vi phạm ngay từ nền.

Đồng thời `Profile` (autoload duy nhất, 448 dòng) đang gánh **tất cả** math kinh tế/stat/affix/talent cho *một* nhân vật là player. Living-world cần **N hero độc lập** cùng chia sẻ công thức đó nhưng có state riêng. Tách `Profile` → `PlayerProfile` (account) + `HeroInstance` (per-hero) ở đây là điều kiện tiên quyết để P1 spawn nhiều hero, P2 quản vòng đời, P3 collection. Phase 0 cũng dựng 4 autoload stub (TimeService/Telemetry/Debug/SeasonManager) + GUT harness — nếu để sau, mọi feature phải retrofit debug/telemetry/test (vi phạm PR checklist của `CLAUDE.md`).

### Phạm vi
**Trong phase:**
- Git branch `archive/action-slice` giữ nguyên slice cũ; trên `master` xoá code sai thể loại (actors player-controlled, hitbox/hurtbox, projectile/pickup, scene arena/run).
- Refactor `profile.gd` → `PlayerProfile` (account: gold/gems, roster hero-id, unlock) + class mới `HeroInstance` (per-hero: level/xp/equipment/stat) tái dùng nguyên math hiện có.
- SaveManager **v2**: cấu trúc lồng `player`/`heroes`/`world`, thêm checksum + migration `v1→v2`, giữ atomic + `.bak` sẵn có.
- Chốt **công thức damage placeholder** đặt trong data (`CombatConstants` Resource), không hardcode trong entity.
- Tạo autoload stub: `TimeService`, `Telemetry`, `Debug`, `SeasonManager` (chỉ khung + API, chưa gameplay).
- Cài **GUT** vào `game/addons/gut`, viết test đầu tiên (damage, save round-trip, migration, HeroInstance stat).
- Cấu hình `project.godot`: viewport **portrait mobile-first**, Nearest filter (đã có), input map tối thiểu (bỏ combat keys).

**Ngoài phase (làm sau — chống scope creep):**
- Utility AI hero, FSM, NavigationAgent2D di chuyển thật → **P1**.
- Battle Engine tick-loop tất định đầy đủ, damage pipeline hoàn chỉnh (Crit→Def→Resist→Shield→HP) → **P1** (Phase 0 chỉ chốt *công thức* + hằng số, chưa dựng engine).
- Town scene, buildings, NPC, world map → **P1/P2**.
- Supabase/Net thật → **P1+** (`net_manager.gd` giữ nguyên stub).
- Migration `.tres` cho content (Database vẫn build bằng code như hiện tại) → dời sang khi thêm content thật; Phase 0 chỉ **đổi tên class** `EnemyData→EnemyDef`, `ItemData→ItemDef` nếu chi phí thấp, KHÔNG viết lại Database.
- Art AI-generate → giữ 0x72 placeholder.

### Hệ thống xây
| Hệ thống | Mô tả | Skill / Agent .claude |
|---|---|---|
| Archive & dọn dẹp | Branch `archive/action-slice`; xoá actors/hitbox/hurtbox/projectile/pickup/arena khỏi `master` | `refactor` skill · **Architect** + **Reviewer** agent |
| PlayerProfile (account) | Autoload thay `Profile`: gold/gems, danh sách hero-id, unlock, save orchestration | **Architect** + **Economy** agent |
| HeroInstance (per-hero) | Class dữ liệu 1 hero: level/xp/equipment/talent/stat effective; tái dùng math từ `profile.gd` | `build-hero` skill · **Gameplay** + **Balancing** agent |
| SaveManager v2 | Cấu trúc lồng + version + checksum + migration `v1→v2`, giữ atomic/.bak | `build-save` skill · **Architect** agent |
| CombatConstants + DamageFormula | Resource chứa hằng số + hàm tính damage placeholder tất định | `build-combat` skill · **Balancing** + **AI** agent |
| Autoload stubs | TimeService / Telemetry / Debug / SeasonManager — khung API | **Architect** agent (Telemetry theo `telemetry.md`, Debug theo `debug-tools.md`) |
| GUT harness | Addon test + thư mục `game/tests/`, script chạy headless | `build-save`/general · **QA** agent |
| Project config | Viewport portrait, input map tối thiểu | **UIUX** + **Performance** agent |

### Data model / Resource (.tres)
**`HeroInstance` (class_name HeroInstance extends Resource)** — per-hero, serializable, tái dùng công thức từ `profile.gd`:

| field | kiểu | ý nghĩa |
|---|---|---|
| `hero_id` | `String` | ID bền vững duy nhất (uuid ngắn), khoá trong roster & save |
| `hero_def_id` | `String` | Trỏ tới `HeroDef` (class/lore) — data-driven, chưa dùng P0 |
| `display_name` | `String` | Tên hero (P0 để trống/placeholder) |
| `level` | `int` | (từ `Profile.level`) |
| `xp` | `int` | (từ `Profile.xp`) |
| `talent_points` | `int` | (từ `Profile.talent_points`) |
| `talents` | `Dictionary` | id→rank (từ `Profile.talents`) |
| `equipment` | `Dictionary` | `{"weapon": inst, "armor": inst}` (từ `Profile.equipment`) |
| `inventory` | `Array` | gear instances riêng của hero (từ `Profile.inventory`) |
| `current_hp` | `int` | HP runtime để hỗ trợ "bất tỉnh → về thành hồi" (mới) |
| `state` | `int` (enum) | placeholder cho FSM P1 (IDLE=0) |

> Instance gear vẫn là `{"id","level","affixes"}` như hiện tại — **giữ nguyên format**, không migrate cấu trúc gear.

**`PlayerProfile` (autoload)** — account-level:

| field | kiểu | ý nghĩa |
|---|---|---|
| `gold` | `int` | (từ `Profile.gold`) — kinh tế cấp account |
| `gems` | `int` | tiền cứng (mới, cho gacha P3) |
| `hero_ids` | `Array[String]` | roster: danh sách hero-id |
| `heroes` | `Dictionary` | hero_id → HeroInstance (runtime, không lưu trực tiếp mà serialize) |
| `consumables` | `Dictionary` | id→count (từ `Profile.consumables`) — kho chung town |
| `materials` | `Dictionary` | id→count (từ `Profile.materials`) — kho chung town |
| `unlocks` | `Dictionary` | cờ mở khoá (region/building) — placeholder |

**`CombatConstants` (class_name CombatConstants extends Resource)** — nguồn sự thật cho balance, thay các `const` rải trong `profile.gd`:

| field | kiểu | ý nghĩa |
|---|---|---|
| `def_k` | `float = 100.0` | hằng số mềm hoá defense trong công thức |
| `crit_damage_default` | `float = 1.5` | (từ `BASE_CRIT_DAMAGE`) |
| `base_attack` / `base_defense` / `base_max_hp` | `int` | (từ `BASE_*`) |
| `atk_per_level` / `def_per_level` / `hp_per_level` | `int` | scale theo level |
| `upgrade_scale` / `upgrade_base_cost` / `buy_markup` | `float`/`int` | kinh tế (từ `profile.gd`) |

**Đổi tên class data (chi phí thấp, làm nếu kịp):** `ItemData`→`ItemDef`, `EnemyData`→`EnemyDef` để đồng bộ với danh mục `*Def` trong kiến trúc chung. Nếu rủi ro cao thì hoãn — ghi vào backlog P1.

### Autoload / Service
| Autoload | Trạng thái | Trách nhiệm P0 |
|---|---|---|
| `EventBus` | **giữ + mở rộng** | Bỏ dần signal action cũ (`player_damaged`, `player_died`); thêm `hero_spawned(hero_id)`, `hero_knocked_out(hero_id)`, `save_completed(ok)`. Giữ `gold_changed`, `xp_changed`, `inventory_changed`... |
| `SaveManager` | **nâng v2** | Cấu trúc lồng + checksum + migration. Emit `EventBus.save_completed`. |
| `Database` | **giữ nguyên** | Chỉ đổi tên class trả về nếu rename `ItemDef/EnemyDef`. Không viết lại. |
| `PlayerProfile` | **mới (thay `Profile`)** | Account state + orchestrate load/save qua HeroInstance. |
| `GameState` | **thu gọn** | Bỏ `hit_stop()` (action combat); rút input map còn tối thiểu (xem Task 12). |
| `AudioManager` / `NetManager` | **giữ stub** | Không đụng gameplay. |
| `TimeService` | **mới (stub)** | API `get_tick()`, `register_slice(callable, interval)` — nền cho scheduler P1. Chưa chạy AI. Theo `architecture.md` mục *Update Frequency*. |
| `Telemetry` | **mới (stub)** | `log_event(category:String, name:String, data:Dictionary)` → buffer in-memory + flush ra `user://telemetry.jsonl`. Versioned schema. Theo `telemetry.md` (buffer, <1% CPU, không PII). |
| `Debug` | **mới (stub)** | `log/warning/error` (thay `print`), cờ `enabled` theo build; console command registry rỗng. Theo `debug-tools.md` + `coding-style.md` mục *Logging*. |
| `SeasonManager` | **mới (stub)** | `current_season_id:String`, `get_season() -> SeasonDef?` (null P0). Nền cho Abyss season P5. |

> Thứ tự autoload trong `project.godot` phải đảm bảo `EventBus` load trước, `Database` trước `PlayerProfile` (vì stat cần `Database.get_item`), `SaveManager` trước `PlayerProfile`.

### Scene / màn hình
Phase 0 **không xây gameplay scene**. Chỉ:
- **Xoá** `scenes/run.tscn`, `scenes/boss_arena.tscn` (action) — chuyển sang branch archive.
- **`scenes/bootstrap.tscn`** (mới, `main_scene`): root `Node`, nhiệm vụ khởi tạo — chờ `PlayerProfile` load xong rồi hiển thị placeholder Label "Herogasm — P0 spine OK". View-model: không có; chỉ label debug + phím F5/F6 quick save/load để kiểm chứng thủ công.
- **`scenes/hub.tscn`** hiện có: giữ tạm làm điểm neo UI-first cho P1 (đổi `main_scene` sang `bootstrap.tscn` để tránh phụ thuộc code action đã xoá). Nếu `hub.gd` tham chiếu `Profile` → sửa sang `PlayerProfile`, hoặc archive nếu quá dính action.

### Task breakdown
1. **Tạo branch archive.** `git checkout -b archive/action-slice && git push -u origin archive/action-slice`, rồi quay lại `master`. Xác nhận slice cũ chạy được trên branch archive (chạy headless kiểm tra không lỗi parse).
2. **Kiểm kê phụ thuộc action.** Grep `master` tìm mọi tham chiếu tới `player.gd`, `hitbox`, `hurtbox`, `projectile`, `pickup`, `boss_arena`, `run.tscn`, `hit_stop`, các input action combat. Lập danh sách file cần xoá/sửa (dùng **Reviewer** agent để không bỏ sót).
3. **Xoá code sai thể loại** trên `master`: `game/actors/` (player/enemies/boss action), `game/systems/combat/hitbox.gd`, `hurtbox.gd`, `game/world/projectile.gd`, `pickup.gd`, `scenes/run.*`, `scenes/boss_arena.*`. **Giữ** `damage_number.gd`, `health.gd`, `sprite_lib.gd` (tái dùng được cho VIEW sau — đánh dấu review).
4. **Trích spine ra chỗ đúng.** Tạo `game/data/combat_constants.gd` (`CombatConstants`) + `game/data/combat_constants.tres` chứa mọi hằng số balance đang nằm trong `profile.gd` (`BASE_*`, `*_PER_LEVEL`, `UPGRADE_*`, `BUY_MARKUP`) + `def_k=100`. Theo rule `gdscript.md` (*Resources for configuration*, không hardcode).
5. **Tạo `DamageFormula` (class_name, pure static).** Đặt `game/systems/combat/damage_formula.gd`. Hàm tất định, seed qua RandomService (P0 dùng seed cố định cho test):
   ```gdscript
   class_name DamageFormula
   ## Placeholder damage: mềm hoá defense + crit nhân. Tất định khi cho trước rng.
   static func compute(attack: int, defense: int, cc: float, cd: float, rng: RandomNumberGenerator, k: float = 100.0) -> Dictionary:
       var base := float(attack) * 100.0 / (100.0 + maxf(0.0, float(defense)))
       var is_crit := rng.randf() < clampf(cc, 0.0, 1.0)
       var dmg := base * (cd if is_crit else 1.0)
       return {"damage": int(round(dmg)), "crit": is_crit}
   ```
   Ghi rõ đây là *placeholder* — pipeline đầy đủ (Resist/Shield) để P1.
6. **Viết `HeroInstance`** (`game/entities/heroes/hero_instance.gd`). Chuyển các hàm stat từ `profile.gd` thành method của HeroInstance, đọc hằng số từ `CombatConstants`:
   - từ `_stat`, `_equip_base`, `_affix_total`, `_talent_total` → `eff_attack/eff_defense/eff_max_hp/eff_speed/eff_crit_chance/eff_crit_damage/eff_lifesteal`.
   - từ `equip/unequip/upgrade/upgrade_cost/sell_gear`, `gain_xp/xp_to_next`, `spend_talent/talent_rank`, `roll_instance/_roll_affix/_affix_count` → giữ logic, đổi `self`-scope. RNG qua **RandomService** (tạo stub `game/core/random_service.gd` nếu chưa có — theo `gdscript.md` cấm `randi()` trực tiếp).
   - `to_dict()/from_dict()` per-hero (tách khỏi account fields).
7. **Viết `PlayerProfile`** (`game/autoload/player_profile.gd`) thay `profile.gd`:
   - giữ `gold/add_gold/buy/buy_price/sell_all_materials`, `consumables/materials`, `use_potion/potion_count` (kho chung town-level).
   - thêm `hero_ids`, `heroes: Dictionary`, `spawn_hero(def_id) -> HeroInstance`, `get_hero(id)`, `add_gems`.
   - `to_dict()` lồng: `{"player": {...}, "heroes": {id: hero.to_dict()}, "world": {}}`.
   - `_ready()`: `SaveManager.load_game()` → nếu rỗng `new_game()` (tạo 1 hero starter với `rusty_sword`, 2 potion — port từ `Profile.new_game`), else `from_dict()` → `_emit_all()`.
8. **Xoá `profile.gd`** sau khi PlayerProfile+HeroInstance pass test; cập nhật `project.godot` autoload `Profile="..."` → `PlayerProfile="*res://autoload/player_profile.gd"`.
9. **SaveManager v2.** Sửa `save_manager.gd`: `SAVE_VERSION := 2`; thêm `_checksum(data)` (hash JSON không gồm field checksum) lưu `data["checksum"]`; `load_game()` validate version+checksum → nếu `save_version==1` gọi `_migrate_v1_to_v2(old)`; giữ nguyên atomic tmp→rename + `.bak`. Emit `EventBus.save_completed.emit(ok)`.
10. **Migration v1→v2.** Hàm `_migrate_v1_to_v2(d: Dictionary) -> Dictionary`: save v1 (phẳng: gold/xp/level/equipment...) → bọc thành `{"player": {gold, consumables, materials}, "heroes": {"hero_0": {level, xp, talents, equipment, inventory}}, "world": {}}`. Không được ném data (rule `save-system.md`: *migration must never break saves*).
11. **Autoload stubs.** Tạo 4 file `game/autoload/time_service.gd`, `telemetry.gd`, `debug.gd`, `season_manager.gd` với API tối thiểu (mô tả ở mục Autoload). Đăng ký trong `project.godot` đúng thứ tự phụ thuộc. `Debug.log` gate bằng `OS.is_debug_build()`.
12. **Rút gọn input & bỏ hit_stop.** Trong `game_state.gd`: xoá `hit_stop()`; xoá các action combat (`attack/dodge/skill_1/use_item/move_*`). Giữ tối thiểu cho UI mobile: `ui_accept`, `interact`, `toggle_menu`, `debug_console` (F12), `quick_save` (F5), `quick_load` (F6). TODO chuyển sang Project Settings Input Map.
13. **Cấu hình project portrait.** Sửa `[display]` trong `project.godot`: `viewport_width=540`, `viewport_height=960` (portrait 9:16 mobile), `window_width_override=405`, `height_override=720`, giữ `stretch/mode="canvas_items"`, `aspect="keep"`. `default_texture_filter=0` (Nearest) giữ nguyên. Đổi `main_scene="res://scenes/bootstrap.tscn"`.
14. **Bootstrap scene.** Tạo `scenes/bootstrap.tscn` + `bootstrap.gd`: `_ready()` connect `EventBus.save_completed`, hiển thị Label trạng thái spine, bind F5/F6 → `PlayerProfile.save()` / reload.
15. **Cài GUT.** Copy addon vào `game/addons/gut/`, bật plugin, tạo `game/tests/unit/`. Script headless `tools/run_tests.sh`: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`.
16. **Viết test lô đầu** (mục Tests). Chạy `run_tests.sh` xanh.
17. **Cập nhật CLAUDE-facing docs nhẹ:** ghi backlog "rename ItemDef/EnemyDef", "Battle Engine P1" để tránh quên. Chạy **Reviewer** agent theo PR checklist của `CLAUDE.md`.

### Tests
Theo `testing.md` + `unit-testing.md` (Given/When/Then, deterministic, seeded, UI-free, <10ms/test):
- **Unit — DamageFormula** (`test_damage_formula.gd`):
  - `GivenAtk50Def0NoCrit_WhenCompute_ThenDamage50` (rng seed cho `randf` > cc).
  - `GivenAtk100Def100NoCrit_WhenCompute_ThenDamage50` (mềm hoá: 100·100/200=50).
  - `GivenCrit100Percent_WhenCompute_ThenDamageTimesCd` (cc=1.0, cd=1.5).
  - Edge: `def<0` bị clamp về 0; `cc>1` clamp 1; `attack=0` → 0.
- **Unit — HeroInstance stat** (`test_hero_instance.gd`):
  - `GivenLevel1NoGear_WhenEffAttack_ThenBaseAttack` (=`base_attack`).
  - `GivenWeaponUpgradeLevel_WhenEffAttack_ThenScaledByUpgradeScale` (kiểm `1+upgrade_scale*lvl`).
  - `GivenTalentPowerRank1_WhenEffAttack_ThenPlusPer`.
  - `GivenAffixCritChance_WhenEffCritChance_ThenClamped01`.
  - Boundary: level 1 vs 2, crit_chance 0% và 100%, lifesteal clamp ≤0.8.
- **Unit — Save round-trip** (`test_save_roundtrip.gd`):
  - `GivenProfileWithHero_WhenToDictFromDict_ThenIdenticalState` (so sánh gold, hero level/xp/equipment/affixes).
  - Corrupt: checksum sai → `load_game` trả `{}` hoặc fallback `.bak`.
- **Unit — Migration** (`test_migration_v1.gd`):
  - `GivenV1FlatSave_WhenLoad_ThenMigratedToV2Nested` (gold giữ nguyên, hero_0 có level/equipment cũ, `save_version==2`).
  - `GivenV1MissingFields_WhenMigrate_ThenDefaultsAppliedNoCrash`.
- **Integration (nhẹ)** (`test_profile_bootstrap.gd`): `GivenNoSave_WhenNewGame_ThenOneStarterHeroWithRustySwordAnd2Potions`.
- **Regression harness:** mỗi bug P0 (vd load v1 crash) → thêm 1 test theo `regression.md`, không bao giờ tái phát.
- **Simulation/stress:** chưa áp dụng ở P0 (chưa có AI/world) — chỉ ghi placeholder trong `tests/simulation/` cho P1.

### Telemetry & Debug
**Telemetry (theo `telemetry.md`):** khung buffer-then-flush. Event P0 tối thiểu (category → name):
- `Save`: `save_completed` (data: `{size_bytes, duration_ms, version, ok}`), `save_failed`, `migration_run` (data: `{from, to}`).
- `Player`: `game_start`, `new_game`.
- `Error`: `corrupted_save`, `checksum_mismatch`.
Mỗi event tự gắn `game_version`, `telemetry_version`, `timestamp`, `session_id` (uuid phiên). Flush ra `user://telemetry.jsonl`; buffer flush mỗi N event. Không PII (`telemetry.md` mục *Privacy*).

**Debug (theo `debug-tools.md`):** ở P0 dựng khung, chưa full overlay.
- `Debug.log/warning/error` thay mọi `print` còn sót (rule `coding-style.md`).
- Console command registry (rỗng nội dung, có cơ chế đăng ký) + phím **F12** mở console stub.
- Cheat/command P0: `save`, `load`, `wipe` (xoá save), `add_gold <n>`, `show_save_info` (in version/checksum/size). Gate bằng `OS.is_debug_build()` — release không có (rule *Safety*).
- Overlay tối thiểu (F2): FPS + Save Status + Session ID — nền cho overlay đầy đủ P1.

### ▶ Cổng Run & Test
**Tự động (bắt buộc xanh):**
- `tools/run_tests.sh` chạy headless → **tất cả unit test PASS**, 0 lỗi, suite < 10s.
- `godot --headless --check-only` (parse toàn project) → **0 lỗi parse/reference** (không còn tham chiếu `Profile`, `hit_stop`, actor đã xoá).

**Thủ công (quan sát được):**
- Mở project trong Godot 4.7 → chạy `bootstrap.tscn` → thấy Label "Herogasm — P0 spine OK", cửa sổ **portrait** (cao hơn rộng).
- Nhấn **F5** → log `save_completed ok=true`; file `user://save_0.json` tồn tại, có `save_version: 2`, `checksum`, cấu trúc `player/heroes/world`.
- Đặt một save v1 cũ (phẳng) vào `user://save_0.json`, chạy lại → **load không crash**, migration chạy, telemetry ghi `migration_run {from:1,to:2}`, gold/hero cũ còn nguyên.
- Sửa 1 byte trong save (hỏng checksum) → không crash, fallback `.bak` hoặc `new_game`, telemetry `checksum_mismatch`.
- **F12** mở console stub; gõ `add_gold 500` → gold tăng (kiểm qua `show_save_info`).

**FAIL nếu:** còn tham chiếu code action đã xoá; save v1 làm crash; test đỏ; cửa sổ vẫn landscape 384×216; `PlayerProfile` còn logic UI/action.

### Deliverables
- ✓ Branch `archive/action-slice` đẩy lên remote, chứa slice action nguyên vẹn.
- ✓ `master` sạch code sai thể loại (actors/hitbox/hurtbox/projectile/pickup/arena đã gỡ).
- ✓ `PlayerProfile` (autoload) + `HeroInstance` (Resource) thay `Profile`, giữ nguyên math kinh tế/stat/affix/talent, có test.
- ✓ `CombatConstants` (.tres) + `DamageFormula` (pure static) — công thức placeholder `atk*100/(100+def)` + crit trong data.
- ✓ SaveManager **v2**: cấu trúc lồng + checksum + migration `v1→v2`, giữ atomic/.bak.
- ✓ 4 autoload stub: `TimeService`, `Telemetry`, `Debug`, `SeasonManager` đăng ký đúng thứ tự.
- ✓ GUT cài đặt + `tools/run_tests.sh` + bộ test (damage/hero-stat/save round-trip/migration/bootstrap) xanh.
- ✓ `project.godot`: viewport portrait mobile-first, input map tối thiểu, `main_scene=bootstrap.tscn`.
- ✓ `bootstrap.tscn` chạy được, F5/F6/F12 hoạt động.
- ✓ Backlog ghi rõ việc hoãn (rename `ItemDef/EnemyDef`, Battle Engine P1).

### Rủi ro & giảm thiểu
- **Mất logic khi tách `Profile`:** math kinh tế 448 dòng dễ sai lệch khi chẻ đôi. → Viết test **trước** khi xoá `profile.gd` (Task 6/16), so sánh output eff_* giữa `Profile` cũ và `HeroInstance` mới trên cùng input trước khi gỡ.
- **Migration làm hỏng save người chơi thật:** → luôn giữ `.bak`; migration chỉ *đọc* v1, dựng dict v2 mới, không mutate in-place; test `test_migration_v1` với nhiều biến thể (thiếu field, gear rỗng). Rule `save-system.md`: *never break saves*.
- **Rename ItemData/EnemyData lan rộng** (Database dựng bằng code, nhiều điểm chạm) → coi là *optional*; nếu grep thấy >~15 điểm chạm thì hoãn sang P1, ghi backlog. Tránh nuốt scope.
- **Xoá nhầm code VIEW còn tái dùng** (`damage_number`, `health`, `sprite_lib`) → chỉ archive, đánh dấu "review P1", không xoá vĩnh viễn khỏi lịch sử (đã có branch archive).
- **Portrait viewport vỡ UI hub cũ** (thiết kế cho 384×216 landscape) → P0 không dùng hub cho gameplay; chỉ bootstrap Label co giãn theo `stretch=canvas_items` + `aspect=keep`. UI thật thiết kế lại ở P1 theo `ui.md`.
- **GUT không tương thích Godot 4.7** → chốt phiên bản GUT hỗ trợ 4.x; nếu addon vênh, chạy test qua script `SceneTree` thuần tối giản làm phương án dự phòng (vẫn headless, vẫn deterministic).

---

## Phase 1 — MVP: Lõi thế giới sống
> **Mục tiêu:** Đóng trọn vòng lặp EHT: town → hero tự trị đi săn → về nghỉ → loot → offline · **Thời lượng:** 3-4 tuần · **Phụ thuộc:** P0

### Vì sao ở đây
P0 đã archive action-slice, đổi tên, refactor `Profile` → `PlayerProfile` (account) + `HeroInstance` (per-hero) và dựng scaffold autoload/Database/scene-router. P1 là lần đầu tiên "thế giới sống" thực sự chạy: không còn người chơi điều khiển, mà là hero AI tự trị chấm điểm goal và đi săn ở một Bãi Săn mở. Đây là MVP chứng minh triết lý cốt lõi trong `CLAUDE.md` ("A tiny fantasy kingdom that keeps living even when the player does nothing") — nếu vòng lặp town→hunt→rest→loot→offline không khép kín và cảm giác sống, mọi phase sau vô nghĩa.

P1 mở khoá 3 trụ tech mà mọi phase sau tái dùng nguyên vẹn: (1) **Utility AI** (Goal/Consideration/Scorer + Scheduler theo bucket) sẽ scale lên 300 hero ở P2 và tái dùng cho Monster/NPC AI; (2) **Battle Engine tick tất định** (snapshot+seed → BattleResult+timeline) là nền cho boss/PvP-bot P4 và replay; (3) **offline progression** (elapsed→reward clamp) là nền cho cloud-save P1/P6. Ta cố tình giữ quy mô nhỏ (4-6 hero, 1 building, 1 Bãi Săn) để hoàn thiện *kiến trúc* chứ không phải nội dung.

### Phạm vi
**Trong phase:**
- `PlayerProfile` (account: wallet Gold/Gem/Energy, roster hero IDs) + `HeroInstance` (per-hero runtime + save) hoàn chỉnh, 4-6 hero khởi tạo từ `HeroDef` (.tres), class Knight/Archer/Mage (tái dùng math `eff_attack/eff_defense/eff_max_hp/eff_crit_chance/eff_crit_damage/eff_lifesteal` đã có trong spine `profile.gd`).
- **Utility AI** đủ 5 goal MVP: `HuntGoal`, `RestGoal`, `RepairGoal`, `ShopGoal` (mua potion), `IdleGoal`. Mỗi goal = tổ hợp `Consideration` chấm điểm 0..1 → scorer chọn goal cao nhất. FSM thực thi goal.
- **AIScheduler** tick theo bucket (round-robin frame), tách tick-rate: Needs 1Hz, Goal re-score ~500ms–1s, Movement 60fps qua `_physics_process`.
- **1 building nâng cấp được**: Inn (rest/heal) — nhưng scaffold `BuildingDef` + `ServiceRegistry` đủ tổng quát cho Blacksmith/Market ở P2. Blacksmith (repair) + Market (buy potion) hiện diện ở dạng service tối thiểu để goal Repair/Shop có đích đến.
- **1 Bãi Săn mở** (`HuntingGround.tscn`) với `MonsterSpawner` + respawn theo population cap; 1-2 monster family (Slime/Goblin) từ `EnemyDef`.
- **Battle Engine headless tất định**: `BattleContext` (snapshot đội hình + seed) → tick-loop → `BattleResult` + `timeline: Array[BattleEvent]`. `BattleView` replay timeline (SIM↔VIEW tách rời).
- **Offline progression**: khi mở lại app, `TimeService` tính `elapsed`, mô phỏng "rẻ" số trận/loot/xp rồi **clamp** theo trần (chống exploit đổi giờ hệ thống).
- Loot tối thiểu: monster chết → `LootResult` → cộng Gold + gear instance vào `PlayerProfile` (tái dùng `roll_instance`).
- HUD tối thiểu: TopBar (Gold/Gem/Energy/Day), Hero List, panel 1 hero (goal/needs/target). Save atomic (đã có SaveManager) + migration hook.

**Ngoài phase (làm sau):**
- Mood/Personality/Relationship/Memory scoring nâng cao (chỉ để **hook** field, chưa dùng trong scorer) → P2.
- World map nhiều region, travel time giữa zone, day/night ảnh hưởng spawn → P2.
- Skill/Equipment sâu, rune, synergy, gacha → P3. P1 chỉ đánh thường + 1 active skill/class hardcoded-in-data.
- Boss/stage 3/3, PvP-bot, threat table đầy đủ → P4.
- Story/Season/Event framework → P5. Cloud-save Supabase (chỉ giữ scaffold `Net` autoload no-op) → P6.
- Permadeath: KHÔNG có. Hero chết combat = bất tỉnh → `ReturnTownGoal` tự động → hồi ở Inn.

### Hệ thống xây
| Hệ thống | Mô tả | Skill/Agent .claude |
| --- | --- | --- |
| PlayerProfile + HeroInstance | Tách account vs per-hero; wallet 3 currency; roster; save/load per-hero | `build-hero`, `build-save`; agent **Architect**, **Economy** |
| Utility AI (Goal/Consideration/Scorer) | 5 goal MVP chấm điểm 0..1, data-driven từ `HeroDef` | `build-ai`, `build-hero`; agent **AI** |
| AIScheduler (bucket tick) | Round-robin, tick-budget/frame, tách tick-rate theo `performance.md`/`ai.md` | `build-ai`; agent **Performance** |
| FSM thực thi goal | State nhỏ, interruptible: Idle/Travel/Hunt/Combat/Rest/Shop/Repair/Return/KO | `build-ai`, `build-hero`; agent **AI** |
| Battle Engine (tick tất định) | Snapshot+seed → tick → `BattleResult`+timeline; damage pipeline `COMBAT.md` | `build-combat`; agent **Gameplay**, **Balancing** |
| BattleView (replay) | Render timeline; xem hero auto-hunt trực tiếp; tách khỏi SIM | `build-combat`, `build-ui`; agent **UIUX** |
| Monster + Spawner | 1-2 family, respawn + population cap; aggro/leash tối thiểu | `build-monster`; agent **AI**, **Gameplay** |
| Town + Building service | Inn nâng cấp; `ServiceRegistry` cho Rest/Repair/Shop | `build-town`, `build-building`; agent **Architect** |
| Loot pipeline | Death → `LootResult` → wallet/inventory; không tạo loot trong combat | `build-loot`, `build-combat`; agent **Economy** |
| Offline progression | `elapsed → reward clamp`; mô phỏng rẻ | `build-save`; agent **Economy**, **Balancing** |
| HUD + Hero List/Panel | ViewModel-driven, event-driven update | `build-ui`; agent **UIUX** |

### Data model / Resource (.tres)
**`HeroDef` (Resource, static — mở rộng từ scaffold P0)**
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `id` | `StringName` | ID bền vững, dùng làm key Database |
| `display_name` | `String` | Tên hiển thị |
| `hero_class` | `StringName` | knight/archer/mage (mapping AI target-priority theo `COMBAT.md`) |
| `base_stats` | `Dictionary` | max_hp/attack/defense/crit_chance/crit_damage/speed... |
| `growth` | `Dictionary` | growth-rate mỗi stat (HERO.md), dùng khi level up |
| `skill_ids` | `Array[StringName]` | 1 active MVP + basic attack |
| `ai_weights` | `Dictionary` | trọng số Consideration data-driven (aggression, repair_threshold, rest_threshold, shopping_chance — theo `ai.md` §Data Driven) |
| `sprite_set` | `String` | placeholder 0x72 |

**`HeroInstance` (RefCounted/Resource, runtime + save — module mới thay `Profile`)**
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `hero_id` | `StringName` | ID instance duy nhất (không dùng NodePath — `save-system.md`) |
| `def_id` | `StringName` | trỏ về `HeroDef` |
| `level`, `xp` | `int` | tiến trình |
| `cur_hp`, `cur_mp`, `stamina` | `int/float` | runtime |
| `needs` | `Dictionary` | health/stamina/hunger/sleep/durability/inventory_space 0..100 (`ai.md`) |
| `mood`, `personality_id` | `float/StringName` | HOOK cho P2, chưa dùng trong scorer |
| `equipment` | `Dictionary` | slot→gear instance `{id, level, affixes}` (tái dùng format `profile.gd`) |
| `inventory` | `Array` | gear instances |
| `consumables` | `Dictionary` | id→count (potion) |
| `cur_goal_id`, `cur_state_id` | `StringName` | debug/telemetry |
| `location_id` | `StringName` | town/hunting_ground_01 (không lưu Node) |
| `is_ko` | `bool` | bất tỉnh (không permadeath) |

**`EnemyDef` (Resource — mở rộng từ `enemy_data.gd` spine)**: `id`, `family`, `level`, `base_stats`, `aggro_range`, `attack_range`, `move_speed`, `respawn_time`, `loot_table_id`, `spawn_group_id`, `sprite_set`.

**`BuildingDef` (Resource, mới)**: `id`, `building_type` (inn/blacksmith/market), `service_id`, `max_level`, `upgrade_cost_curve: Curve`/`Array[int]`, `service_params: Dictionary` (vd heal_rate, repair_price_mult).

**`LootTableDef` (Resource, mới, tối thiểu)**: `id`, `entries: Array[{item_id, weight, min, max}]`, `gold_min`, `gold_max`.

**`HeroDefault` config (`RegionDef`/`HuntingGroundDef` tối thiểu)**: `id`, `recommended_level`, `monster_pool: Array[StringName]`, `spawn_points`, `population_target`, `population_max`.

**Runtime-only (KHÔNG .tres, KHÔNG save trực tiếp)**: `BattleContext`, `BattleResult`, `BattleEvent`, `DecisionContext`, `Blackboard` (theo `ai.md`/`build-ai`).

### Autoload / Service
Kế thừa autoload P0. P1 thêm/hoàn thiện:
- **`Database`** (façade đã có): thêm `get_hero_def(id)`, `get_enemy_def(id)`, `get_building_def(id)`, `get_loot_table(id)` — tra cứu O(1) bằng Dictionary (`performance.md` §Database). KHÔNG `load()` trong gameplay; preload toàn bộ .tres lúc boot.
- **`AIScheduler`** (mới, autoload): quản lý bucket hero, `register(brain)`, `unregister(brain)`, tick round-robin với `max_time_per_frame_ms` + `max_tasks_per_frame` (`build-ai` §Scheduler Budget). Không dùng 300 Timer.
- **`BattleEngine`** (mới, autoload service headless): `simulate(ctx: BattleContext) -> BattleResult`. Thuần logic, không đụng SceneTree, tất định theo `ctx.seed`.
- **`ServiceRegistry`** (mới): discovery service theo type ("nearest Inn", "available Blacksmith") — AI KHÔNG hardcode node path (`build-ai` §Building Integration).
- **`RandomService`** (mới hoặc trong TimeService): PRNG seeded; AI và Battle **chỉ** dùng service này, cấm `randf()` (`ai.md` §Randomness).
- **`TimeService`** (mở rộng): cung cấp `now_unix()`, `game_day`, và tính `elapsed` cho offline progression + time-scale (1x..1000x cho simulation, `simulation.md`).
- **`SaveManager`** (đã có, giữ nguyên atomic + .bak + version): thêm section `heroes`, `wallet`, `world`, `offline_ts`; thêm `migrate(data, from_v, to_v)` hook (`save-system.md`).
- **`Telemetry`** (mở rộng): nhận event AI/combat/economy (xem mục Telemetry).
- **`EventBus`** (đã có): thêm signal cross-system (xem dưới). KHÔNG emit mỗi frame (`signal-rules.md`).

### Scene / màn hình
Theo `scene-structure.md` (composition, depth ≤ 5, visual tách gameplay, UI qua CanvasLayer, giao tiếp qua Signal/EventBus/Service):

- **`World.tscn`** (Node2D, root router) → `Town`, `HuntingGround01`, `Entities`, `Effects`, `UI(CanvasLayer)`, `Camera`. World persistent, không đổi scene khi hero di chuyển.
- **`Hero.tscn`** (`CharacterBody2D`): `NavigationAgent2D`, `AnimatedSprite2D`, `Shadow`, `HealthBar`, `InteractionArea`, `DebugLabel`, node `Components` chứa `HeroBrain`, `MovementComponent`, `CombatComponent`, `NeedsComponent`, `InventoryComponent`, `EquipmentComponent`, `SaveComponent`. Script Hero **chỉ điều phối component** (không God Object — `build-hero`).
- **`Monster.tscn`** (`CharacterBody2D`): theo scene tree `build-monster` (rút gọn cho MVP: Brain, Movement, Combat, Aggro, Loot, Spawn component).
- **`Town.tscn`** (Node2D): `Navigation(NavigationRegion2D)`, `Buildings`(Inn/Blacksmith/Market), `SpawnPoints`, `Gates`, `Roads`, `Heroes`, `Decorations`. Không chứa combat logic.
- **`HuntingGround01.tscn`** (Node2D): `NavigationRegion2D`, `SpawnPoints`, `Monsters`, `ExitPoints`, `Decoration`.
- **`Building.tscn`** (Node2D): `Sprite`, `Entrance`, `ServiceArea`, `Label`. Expose service, không chạy gameplay.
- **UI (CanvasLayer)**: `TopBar` (Gold/Gem/Energy/Day), `HeroList` (virtualized), `HeroPanel` (goal/state/needs/target/location), `NotificationLayer`, `DebugOverlay` (layer riêng, không ship bật).
- **`BattleView.tscn`**: node replay timeline — dùng cho "xem hero auto-hunt trực tiếp" ở Bãi Săn (là live-view của SIM), stage 3/3 chỉ là badge phụ.

**ViewModel**: `HeroListVM`, `HeroPanelVM`, `WalletVM` — đọc GameState/PlayerProfile, cập nhật UI qua signal (`ui.md`: Gameplay→State→ViewModel→UI, UI không đọc/sửa gameplay trực tiếp).

### Task breakdown
1. **Refactor data spine → `HeroInstance`**: tách math per-hero từ `profile.gd` (`eff_attack/eff_defense/eff_max_hp/eff_crit_chance/eff_crit_damage/eff_lifesteal`, `roll_instance`, affix/talent) sang class `HeroInstance`; `PlayerProfile` chỉ giữ wallet + roster (Array hero_id) + shared inventory. Giữ nguyên format gear `{id,level,affixes}`.
2. **Wallet 3 currency**: thêm Gold/Gem/Energy vào `PlayerProfile` với `add/spend/can_afford` + signal `wallet_changed(kind, total)`; mỗi currency có Source+Sink rõ ràng (`ECONOMY.md`). Energy làm gate nhịp (chưa tiêu mạnh ở MVP).
3. **Định nghĩa `HeroDef` + 4-6 hero .tres** (Knight/Archer/Mage) qua `build-hero`; nạp vào `Database.get_hero_def`. Điền `ai_weights` data-driven.
4. **Core AI classes** (`build-ai`): `Goal`, `Consideration` (scorer 0..1 + `UtilityCurve`), `GoalEvaluator`, `DecisionContext`, `Blackboard`, `State`, `StateMachine`. Score range chuẩn 0.0..1.0 (`build-ai` §Goal Score Rules).
5. **5 goal MVP**: `HuntGoal`, `RestGoal`, `RepairGoal`, `ShopGoal(potion)`, `IdleGoal`. Mỗi goal build từ Consideration (vd RestGoal ↑ khi hp thấp + stamina thấp + inn gần + có gold — theo ví dụ `build-hero` §Goal Evaluation). Ưu tiên tổng thể theo Decision Priority (`ai.md`): Survival→Safety→Maintenance→Quest→Profit→Idle.
6. **FSM states**: `HeroIdleState`, `HeroTravelState`, `HeroHuntState`, `HeroCombatState`, `HeroRestState`, `HeroShopState`, `HeroRepairState`, `HeroReturnState`, `HeroKOState`. State nhỏ, `enter/tick/exit/can_interrupt/get_debug_info` (`build-ai` §State Rules).
7. **`AIScheduler`**: bucket round-robin theo frame; tick-rate Needs 1Hz / re-score 500ms–1s / movement 60fps. Tôn trọng tick-budget (`performance.md` §AI Tick Rate). Đăng ký brain khi hero spawn, huỷ khi despawn.
8. **`NeedsComponent`**: decay theo scheduler 1Hz (hunger/sleep/stamina), tính `durability` từ equipment, `inventory_space` từ inventory. Emit `hero_needs_changed` chỉ khi vượt ngưỡng (không mỗi tick — `signal-rules.md`).
9. **`MovementComponent`**: wrap `NavigationAgent2D`; `move_to(dest)`, `arrived` signal; chỉ set target khi đổi đích (không recalc path mỗi frame — `performance.md` §Pathfinding). Recovery khi path fail → chọn đích thay thế (`build-ai` §Recovery).
10. **`ServiceRegistry` + Town buildings**: Inn (heal/rest), Blacksmith (repair), Market (buy potion). AI query `find_nearest(service_type, from_pos)`. `BuildingDef` .tres + Inn nâng cấp (upgrade cost curve, heal_rate tăng theo level).
11. **`Monster` + `MonsterSpawner`** (`build-monster`): 1-2 family từ `EnemyDef`; spawner giữ population trong [target,max], respawn theo scheduler (không spawn hàng loạt 1 frame — `performance.md` §Spawn). Aggro/leash tối thiểu (leash về home khi target rời range).
12. **Battle Engine tất định** (`build-combat`): định nghĩa `BattleContext{team_a, team_b, seed}` (snapshot stat, KHÔNG ref Node), tick-loop cố định dt (vd 100ms/tick), damage pipeline **Damage→Crit→Def→Resist→Shield→HP** (`COMBAT.md`). Công thức tái dùng `DamageCalculator`: `raw = attack * skill_mult`; `def_reduction = def/(def+100)`; `final = max(1, raw*(1-def_reduction))`; crit dùng `RandomService` seeded. Sinh `BattleResult{winner, survivors_hp, loot_seed}` + `timeline: Array[BattleEvent{t, type, src, tgt, value, is_crit}]`.
13. **`BattleView` replay**: consume timeline, spawn `DamageNumber` từ pool (`performance.md` §Object Pool), phát animation *sau* khi kết quả có sẵn (Animation không điều khiển gameplay — `CLAUDE.md`). Live-view: hero auto-hunt ở Bãi Săn render trực tiếp qua chính SIM đang chạy.
14. **Loot pipeline** (`build-loot`): trên `monster_died` → `LootComponent` roll `LootTableDef` bằng seed → `LootResult` → cộng Gold + gear vào `PlayerProfile` (tái dùng `roll_instance`) + xp cho hero tham chiến. Death chỉ xử lý **một lần** (`build-combat` §Death Flow).
15. **KO flow (không permadeath)**: hero hp≤0 → `is_ko=true` → interrupt goal → `HeroReturnState` về town → Inn hồi phục → `is_ko=false`. Emit `hero_ko`/`hero_recovered`.
16. **Offline progression** (`build-save`): lưu `offline_ts` khi thoát; khi mở lại tính `elapsed = min(now - offline_ts, MAX_OFFLINE_SEC)`; mô phỏng rẻ: ước lượng số trận = f(hero_dps_trung_bình, monster_pool) → cộng gold/xp/loot **clamp** theo trần/giờ. Popup "Khi bạn vắng mặt…".
17. **Save integration**: `SaveManager` section `heroes[]` (mỗi `HeroInstance.to_dict`), `wallet`, `world{day, spawns_persistent}`, `offline_ts`, `save_version`. Thêm `migrate()` hook rỗng (v1). Autosave 30–120s + save ngay khi major event (hero KO, level up, building upgrade — `save-system.md` §Save Timing).
18. **HUD + ViewModel** (`build-ui`): TopBar, HeroList (virtualized, `ui.md` §Lists), HeroPanel. Update event-driven qua EventBus/signal, không mỗi frame.
19. **Debug tools + cheats** (mục dưới) và **Telemetry hook** (mục dưới) — làm song song từng hệ thống, không để cuối.
20. **Wire vòng lặp end-to-end**: spawn 4-6 hero ở town → AI tự chọn HuntGoal → Travel→HuntingGround → Battle → Loot → needs giảm → RestGoal/ShopGoal/RepairGoal → về town → lặp. Chạy headless 1 giờ time-scale để xác nhận không deadlock.

### Tests
Theo `testing.md`/`unit-testing.md`/`simulation.md`/`regression.md`. Tái dùng test-case chuẩn trong `build-ai`/`build-hero`/`build-combat`/`build-monster`.

**Unit**
- Damage formula: `GivenAttackerAndDefender_WhenDamageCalculated_ThenDamageIsPositive`; def cao → final≥1; `GivenCriticalChanceOneHundred_ThenCriticalDamageApplied`; pipeline đúng thứ tự Crit→Def→Resist→Shield→HP.
- Wallet: spend>balance → reject; add/spend phát signal đúng; không âm.
- Needs decay: sau N tick 1Hz, hunger/stamina giảm đúng lượng; ngưỡng phát signal đúng 1 lần.
- Goal scoring: score ∈ [0,1]; `GivenHeroLowHp_WhenAIScoresGoals_ThenRestGoalWins`; `GivenWeaponBroken_WhenBlacksmithAvailable_ThenRepairGoalWins`; `GivenNoGoal_WhenSchedulerTicks_ThenHeroSelectsGoal`.

**Integration**
- `GivenHeroLowHp_WhenNoPotion_ThenReturnToInn`; `GivenInventoryFull_WhenHunting_ThenReturnTown`.
- Spawner: `GivenPopulationBelowTarget_ThenSpawnerCreatesMonster`; `GivenZoneAtCap_ThenNoExtraSpawn`.
- Loot chỉ trigger 1 lần: `GivenMonsterDies_ThenLootDropsOnce`; death 2 lần → `died` emit 1 lần.
- Leash: `GivenHeroLeavesLeashRange_ThenMonsterReturnsHome`.
- Save round-trip: `GivenSaveLoad_WhenHeroHasEquipment_ThenEquipmentRestored`; Save→Load→Save cho state đồng nhất (`save-system.md` §Testing).

**Simulation (headless, `simulation.md`)**
- Level 1 (single hero) & Level 3 (town 4-6 hero) chạy time-scale 50x/100x: mọi hero luôn có goal, không idle >5 phút, không deadlock/oscillation, không âm gold/hp, không duplicate ID.
- Offline 8h: reward bị clamp, không exploit đổi giờ; economy Source≈Sink không phình vô hạn.
- Combat sim: đo DPS trung bình, fight duration (mục tiêu 30–90s theo `COMBAT.md`/`BALANCE.md`), tỉ lệ crit khớp cấu hình.

**Regression**
- Snapshot `BattleResult`/timeline với seed cố định → tất định 100% qua nhiều lần chạy (nền cho replay).
- Golden save v1 load được sau mỗi thay đổi schema (migration test).

### Telemetry & Debug
**Telemetry** (`telemetry.md`, hook trong từng component):
- AI: `goal_selected`, `goal_completed`, `goal_failed`, `state_changed`, `decision_time`, `decision_score`, `idle_duration`, `stuck_detected`, `recovery`.
- Combat: `attack`, `skill_cast`, `damage_dealt/taken`, `critical`, `dodge`, `death`, `fight_duration`, `potion_used`, `retreat`.
- Economy: `gold_earned`, `gold_spent`, `loot_dropped`, `repair_cost`, `offline_reward` (để phát hiện lạm phát — `ECONOMY.md`/`BALANCE.md`).
- Hero lifecycle: `hero_spawned`, `hero_ko`, `hero_recovered`, `level_up`, `travel_time`.

**Debug/cheat** (`debug-tools.md`; DebugOverlay layer riêng, không ship bật):
- Hero inspector: id/state/goal/decision_scores/last_reason/needs/target/destination/scheduler_slot (`build-hero`/`build-ai`).
- Cheat: `spawn_hero`, `kill_hero`, `revive_hero`, `heal_hero`, `force_goal`, `force_state`, `fill_inventory`, `break_equipment`, `set_need`, `level_up`.
- World/combat: `spawn_monster`, `kill_all_monsters`, `show_aggro_radius`, `show_leash_radius`, `god_mode`, `force_critical`, `show_damage_formula`.
- Time/sim: `fast_forward` (time-scale), `skip_day`, `give_gold`, `pause_ai`/`resume_ai`/`step_ai`, `trigger_offline(hours)`.

### ▶ Cổng Run & Test
**PASS khi (quan sát được):**
- **Manual**: mở app → 4-6 hero tự rời town, đi Bãi Săn, đánh quái (không click điều khiển). Hp/potion cạn → hero **tự** về Inn nghỉ / mua potion / sửa đồ rồi quay lại. TopBar Gold tăng khi loot; HeroPanel hiển thị đúng goal/state/target theo thời gian thực. Hero KO → tự về town hồi, **không** biến mất (không permadeath).
- Đóng app ≥ vài phút → mở lại → popup offline hiện reward hợp lý & bị **clamp** (đổi giờ hệ thống +100h không cho thưởng vô hạn).
- **Tự động**: toàn bộ unit/integration test xanh. Sim headless town 100x trong ≥1 giờ game-time: không crash, không deadlock, không hero idle >5 phút, không giá trị âm, không duplicate ID (`simulation.md` §Failure Detection & Success Criteria).
- Battle tất định: cùng seed → cùng `BattleResult` + timeline qua ≥100 lần chạy.
- Perf smoke: 4-6 hero + ~30-50 monster giữ ≥60fps trên desktop; AIScheduler không vượt tick-budget (không AI trong `_process`).

**FAIL nếu:** hero đứng yên không lý do; goal oscillation; combat phụ thuộc timing animation; loot/death nhân đôi; gold/hp âm; save round-trip mất state; battle không tất định; đổi giờ hệ thống cho reward vô hạn.

### Deliverables
- ✓ `PlayerProfile` (wallet Gold/Gem/Energy + roster) + `HeroInstance` (runtime+save) tách bạch, tái dùng math spine.
- ✓ Utility AI: `Goal`/`Consideration`/`GoalEvaluator` + 5 goal MVP + FSM states, data-driven từ `HeroDef.ai_weights`.
- ✓ `AIScheduler` tick theo bucket + tick-budget; không AI trong `_process`.
- ✓ Battle Engine headless tất định (snapshot+seed → `BattleResult`+timeline) + `BattleView` replay/live-view.
- ✓ Town với Inn nâng cấp + `ServiceRegistry` (Rest/Repair/Shop) + `BuildingDef`.
- ✓ 1 Bãi Săn mở + `MonsterSpawner` (respawn + population cap) + 1-2 monster family.
- ✓ Loot pipeline + KO flow (không permadeath).
- ✓ Offline progression (elapsed→reward clamp) + Save atomic/.bak/version + migration hook.
- ✓ HUD (TopBar/HeroList/HeroPanel) event-driven + ViewModel.
- ✓ Telemetry events + Debug inspector/cheats.
- ✓ Bộ test unit/integration/simulation/regression xanh; docs (architecture/scene/data/save/perf notes) theo `CLAUDE.md` §Documentation.

### Rủi ro & giảm thiểu
- **Goal oscillation / hero rung lắc giữa 2 goal**: thêm hysteresis (goal hiện tại được cộng bonus giữ, chỉ đổi khi goal khác vượt ngưỡng) + `can_interrupt()` + cooldown re-score; test oscillation trong sim (`simulation.md` §AI Validation).
- **AIScheduler quá tải khi scale**: thiết kế bucket + tick-budget ngay từ MVP dù chỉ 4-6 hero, benchmark với 300 hero giả lập headless để chắc kiến trúc scale (`performance.md`).
- **Battle không tất định** (float/thứ tự lặp): cố định dt tick, dùng `RandomService` seeded duy nhất, sort deterministic theo `hero_id`, cấm `randf()`; regression snapshot theo seed.
- **Exploit offline đổi giờ**: clamp `elapsed` theo trần cứng + (P6) đối chiếu server time; log `offline_reward` telemetry để phát hiện bất thường.
- **Over-engineering scope creep** (nhồi mood/relationship/world-map): chỉ **hook field**, giữ danh sách "Ngoài phase" nghiêm ngặt; reviewer chặn PR vượt scope.
- **Coupling AI↔animation/UI**: enforce qua `signal-rules.md`/`scene-structure.md` (Brain→Component method call; UI chỉ listen); code-review checklist `performance.md`.
- **Migration save vỡ ở phase sau**: đặt `save_version`+`migrate()` hook và golden-save test ngay từ v1.

---

## Phase 2 — Chiều sâu thành · vòng đời hero · bản đồ

> **Mục tiêu:** Biến thành từ "1 building đơn lẻ ở P1" thành HỆ SINH THÁI phục vụ hero; mở nhiều Bãi Săn gate theo level + clear-star; hoàn thiện vòng đời hero (HP/fatigue/injury/mood, bất tỉnh→hồi, KHÔNG permadeath); expedition timer idle fire-and-forget + tăng tốc gem; energy regen + trần; tinh chỉnh offline accrual qua TimeService. · **Thời lượng:** 4-5 tuần · **Phụ thuộc:** P1 (world sống lõi: HeroInstance, Battle Engine tất định, SaveManager atomic, EventBus, Database, TimeService khung, ít nhất 1 building + 1 Bãi Săn)

### Vì sao ở đây

P1 đã chứng minh vòng lặp "sống" tối thiểu chạy được: một hero AI tự đi săn ở một Bãi Săn, đánh tất định (seeded), về thành, save/offline cơ bản. Nhưng P1 chỉ có xương sống — thành gần như trống, hero chưa có nhu cầu thực (chưa mệt/thương/mood), thế giới chỉ một điểm săn. Phase 2 lấp đúng khoảng đó: bơm CHIỀU SÂU vào 3 trụ mà pillar "Living Town / Autonomous Heroes / Open World" của `CLAUDE.md` yêu cầu. Thứ tự này bắt buộc trước P3/P4 vì: (a) collection/skill/rune/gacha (P3) cần hero có vòng đời và nhu cầu để "có lý do" mua/nâng cấp — nếu không có fatigue/durability sink thì economy P3 sẽ lạm phát ngay; (b) boss/stage/PvP (P4) cần world map nhiều Bãi Săn gate theo level + clear-star làm khung tiến trình để cắm boss vào; (c) story/season (P5) cần building Guild Hall + region tree data-driven để mở khoá theo chương.

Phase 2 mở khoá: hệ thống Utility AI đầy đủ nhu cầu (goal cạnh tranh thật, không còn chỉ "hunt/return"), đường cong cost building (nền tảng cho mọi sink kinh tế về sau), và khung RegionDef/ZoneDef data-driven cho phép P4/P5 thêm vùng "without changing code" đúng như `world.md` yêu cầu.

### Phạm vi

**Trong phase:**
- 7 building phục vụ nhu cầu hero, mỗi cái 1 service + đường cong cost + upgrade level: **Nhà Trọ (Inn)** hồi HP/fatigue/mood · **Xưởng Rèn (Blacksmith)** sửa durability + (đặt móng) upgrade · **Cửa Hàng (Market/Shop)** bán potion/food + mua loot của hero · **Sân Huấn Luyện (Training Ground)** đổi thời gian → stat/EXP nhẹ · **Lab (Alchemy)** craft potion/medicine trị injury · **Nhà Bếp (Kitchen/Farm)** sản food nuôi Inn/Market · **Hội Quán (Guild Hall)** cấp expedition/quest + tăng trần energy + roster cap.
- Vòng đời hero: `hp`, `fatigue`, `injury` (mức + timer hồi), `mood` (mặt cảm xúc như demo mockup), luồng bất tỉnh (knockout) → khiêng về thành → hồi (KHÔNG permadeath).
- World map: nhiều Bãi Săn (HuntingZone) trong nhiều Region; gate theo `required_level` + `clear_stars`; hiển thị clear-star 3 sao/zone.
- Expedition idle: timer fire-and-forget (đặt hero vào zone → chạy nền theo TimeService), tăng tốc bằng gem; reward roll tất định khi kết thúc.
- Energy: regen theo thời gian + trần (`energy_cap`), gate số expedition đồng thời.
- Offline accrual tinh chỉnh: tính đúng qua `TimeService` (fatigue tích, expedition hoàn tất, energy hồi tới cap, injury hồi) với trần idle ≤ 80% active theo `economy.md`.

**Ngoài phase (làm sau — chống scope creep):**
- Enchant/socket/reforge/awaken equipment, upgrade stone, failure chance (P3 — chỉ đặt móng "repair + placeholder upgrade" ở P2).
- Skill tree / rune / synergy / gacha summon (P3).
- Dungeon nhiều tầng, boss thật, mini-boss AI đổi phase, PvP-bot (P4).
- Story campaign, Season/Event framework, weather/day-night gameplay đầy đủ (P5 — P2 chỉ để hook `TimeService.time_of_day` nếu rẻ, không làm mood-by-weather).
- NPC schedule đầy đủ (thợ rèn/dân đi lại theo giờ), relationship/bond hero-hero (P3+).
- Online cloud-save leaderboard, telemetry backend (P6 — P2 chỉ emit event local + ghi log).
- Player market / auction (future-ready, không build).

### Hệ thống xây

| Hệ thống | Mô tả | Skill / Agent .claude |
| --- | --- | --- |
| Town shell + TownManager | Scene thành chứa building slots, road, spawn point, camera bounds; router "world visible" theo `ui.md` | `build-town` · Architect + UIUX |
| 7 Building (Inn/Blacksmith/Market/Training/Alchemy/Kitchen/Guild) | Mỗi cái = Data + State + Service tách bạch; queue; upgrade; cost curve | `build-building` (1 lần/building, tái dùng khung) · Economy + Gameplay |
| Hero lifecycle | fatigue/injury/mood component + knockout→revive flow; feed vào Utility AI | `build-hero` + `build-ai` · AI + Gameplay |
| Utility AI needs | Goal cạnh tranh: RestGoal/RepairGoal/BuyGoal/HealInjuryGoal/TrainGoal/HuntGoal/IdleGoal; scheduler, KHÔNG `_process()` | `build-ai` · AI (theo `ai.md`) |
| World map + Region/Zone tree | RegionDef→ZoneDef data-driven; gate level + clear-star; map screen | `build-monster` (spawn pool/zone) + Architect · World |
| Expedition service (idle) | Fire-and-forget timer per hero-zone; TimeService driven; gem speedup; reward roll seeded | `build-combat` (reuse Battle Engine headless) + Economy |
| Energy + offline accrual | Regen + cap; catch-up khi mở app qua TimeService | Economy + Architect (theo `economy.md`) |

### Data model / Resource (.tres)

**BuildingDef** (mở rộng — 1 file .tres/loại building, load qua Database):
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `id` | StringName | vd `&"inn"`, `&"blacksmith"` |
| `display_name` | String | tên hiển thị VI |
| `category` | StringName | `&"service"` |
| `service_type` | StringName | `&"rest"`/`&"repair"`/`&"shop"`/`&"train"`/`&"alchemy"`/`&"food"`/`&"guild"` |
| `max_level` | int | trần nâng cấp (vd 10) |
| `build_cost` | Dictionary | `{ "gold": int, "wood": int, "stone": int }` chi phí xây |
| `upgrade_cost_base` | Dictionary | cost nền cho công thức đường cong |
| `cost_growth` | float | hệ số mũ đường cong: `cost(L)=base*pow(growth,L-1)` (vd 1.15) |
| `capacity_base` | int | số hero phục vụ đồng thời ở L1 |
| `capacity_per_level` | int | +slot mỗi level |
| `service_rate_base` | float | tốc/hiệu suất service ở L1 (hồi HP/s, giảm giá sửa…) |
| `service_rate_per_level` | float | +hiệu suất mỗi level |
| `unlock_requirement` | Dictionary | `{ "player_level": int, "prereq_building": StringName }` |
| `nav_marker_ids` | Array[StringName] | điểm entrance/queue/service (không hardcode toạ độ) |

**RegionDef** (mới):
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `id` | StringName | vd `&"valoria"`, `&"silverwood"` (khớp WORLD.md) |
| `display_name` | String | tên vùng |
| `theme` | StringName | `&"plains"`/`&"forest"`/… (music/lighting sau) |
| `zone_ids` | Array[StringName] | danh sách Bãi Săn thuộc region |
| `unlock_requirement` | Dictionary | gate region theo player_level/story |

**ZoneDef / HuntingZone** (mới — 1 Bãi Săn):
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `id` | StringName | vd `&"beginner_field"` |
| `region_id` | StringName | region cha |
| `display_name` | String | tên zone |
| `required_level` | int | gate: hero/roster phải đạt để mở |
| `unlock_by_stars` | int | gate clear-star zone trước đó |
| `recommended_power` | int | dùng cho AI chọn zone + ước tính winrate |
| `monster_pool` | Array[StringName] | id EnemyDef (reuse P1) |
| `spawn_group_id` | StringName | nối `build-monster` SpawnPool |
| `expedition_duration_s` | float | thời lượng 1 expedition idle nền |
| `energy_cost` | int | energy tiêu để phái 1 lượt |
| `reward_table_id` | StringName | loot/gold/exp table |
| `star_thresholds` | Array[int] | ngưỡng đạt 1/2/3 sao (vd theo clear-count hoặc no-KO) |

**HeroInstance** (mở rộng field vòng đời — runtime, save qua JSON theo `save-system.md`, chỉ lưu ID + số):
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `hp` / `max_hp` | float | máu; hp=0 → knockout (không chết) |
| `fatigue` | float | 0..100; săn tăng, nghỉ Inn giảm; cao → hiệu suất giảm |
| `injury_level` | int | 0=lành, 1..3 mức thương; chỉ Alchemy/Inn hồi |
| `injury_recover_at` | float | epoch (TimeService) hết thương nếu để tự hồi |
| `mood` | float | 0..100 → map ra 5 mặt cảm xúc (demo) |
| `energy` | int | năng lượng cá nhân để phái expedition |
| `state` | StringName | `&"in_town"`/`&"expedition"`/`&"knocked_out"`/`&"recovering"` |
| `active_expedition_id` | StringName | expedition đang chạy (nếu có) |
| `equip_durability` | Dictionary | `{ slot: float }` độ bền → sink sửa ở Blacksmith |

**ExpeditionState** (mới — runtime, save được để offline accrual tính tiếp):
| field | kiểu | ý nghĩa |
| --- | --- | --- |
| `id` | StringName | uid expedition |
| `hero_id` | StringName | hero được phái |
| `zone_id` | StringName | Bãi Săn |
| `start_epoch` | float | mốc bắt đầu (TimeService) |
| `end_epoch` | float | mốc kết thúc = start + duration (đã trừ speedup) |
| `seed` | int | seed reward roll (tất định, reproduce khi resolve) |
| `resolved` | bool | đã trao thưởng chưa |

**MoodDef / FatigueCurve** (nhỏ, data-driven theo `ai.md` "AI values từ Resource"): ngưỡng `rest_threshold`, `repair_threshold`, `heal_threshold`, `fatigue_efficiency_curve` — không hardcode trong AI.

### Autoload / Service

- **TownService** (mới, autoload nhẹ hoặc node dưới GameState): registry building đang có + level + state; API `get_building(service_type)`, `enqueue(hero, service_type)`; là điểm AI hỏi "đâu có service" (theo `build-building` "Never hardcode destinations").
- **ExpeditionService** (mới): `start(hero_id, zone_id) -> ExpeditionState`; `tick()` do TimeService gọi (KHÔNG `_process`); `resolve(exp)` chạy Battle Engine headless seeded (reuse `build-combat`), phát reward, cập nhật clear-star; `speedup(exp, gem)` trừ gem giảm `end_epoch`.
- **EconomyService** (mở rộng từ math P1 trong `profile.gd`): công thức đường cong cost building `cost(L)=base*pow(growth,L-1)`; áp trần idle reward 80% (`economy.md` "Idle Rewards ≤ 80%, khuyến 60~75%"); mọi giá lấy từ .tres — "Never hardcode".
- **TimeService** (mở rộng từ khung P1): nguồn epoch duy nhất; API `now_epoch()`, `advance(dt)`; on-resume tính `elapsed = now - last_save_epoch` rồi gọi accrual (fatigue/energy/injury/expedition). Là NƠI DUY NHẤT tính offline, tránh mỗi hệ tự đọc giờ (chống lệch).
- **SeasonManager** (đã có khung): P2 chỉ đăng ký hook `time_of_day` nếu rẻ; không thêm gameplay.
- **AIScheduler** (mở rộng): thêm slot needs (1s), economy/mood (5-30s) theo bảng Decision Interval của `ai.md`; đảm bảo ≤ 300 hero không nghĩ cùng frame.

### Scene / màn hình

- `world/town/Town.tscn` — node: `TownManager`, `Navigation`, `Roads`, `BuildingSlots` (Marker2D theo `nav_marker_ids`), `HeroLayer` (pooled), `SpawnPoints`, `CameraBounds`. View-model: `TownViewModel` đọc TownService phát UI.
- `world/buildings/<name>/Building.tscn` × 7 — theo `build-building` scene: `BuildingRoot`, `Sprite`, `InteractionArea`, `NavigationPoint`, `AnimationPlayer`, `StateMachine`, `ServiceMarker`, `DebugNode`. Script tách `Building.gd`/`*Service.gd`/`*View.gd`.
- `ui/BuildingWindow.tscn` — panel service + upgrade + queue view + cost hiển thị (đọc EconomyService).
- `ui/WorldMap.tscn` — danh sách Region → Zone card; mỗi card: tên, `required_level`, clear-star (3 sao), nút "Phái đoàn"/"Locked"; view-model `WorldMapViewModel`.
- `ui/ExpeditionPanel.tscn` — hero đang đi, timer đếm ngược, nút "Tăng tốc (gem)", nút "Xem trực tiếp" (mở view battle của zone — quyết định chốt: expedition = xem trận trực tiếp; stage 3/3 phụ).
- `ui/HeroCard.tscn` (mở rộng P1) — bar HP/fatigue/energy + icon mặt mood (5 trạng thái) + badge injury/knockout.
- Debug: `ui/DebugPanel.tscn` mở rộng tab Town/Hero/World.

### Task breakdown

1. Refactor `HeroInstance` thêm field vòng đời (`fatigue/injury_level/injury_recover_at/mood/energy/state/active_expedition_id/equip_durability`); viết migration save version P1→P2 (theo `save-system.md`: version + .bak, mặc định giá trị an toàn cho save cũ).
2. Mở rộng `TimeService`: `now_epoch/advance`, lưu `last_save_epoch` vào save; hàm `compute_offline(elapsed)` trả struct delta (fatigue+, energy+, injury tick, expedition-to-resolve). Không hệ nào tự đọc `Time.get_*` ngoài đây.
3. Tạo `BuildingDef` mở rộng + 7 file `.tres` (inn/blacksmith/market/training/alchemy/kitchen/guild) với cost curve & capacity; nạp qua Database façade.
4. Dùng `build-building` sinh khung Inn đầu tiên (Data/State/Service/View/UI + test) làm TEMPLATE; xác nhận queue + upgrade + cost hoạt động.
5. Nhân bản khung cho 6 building còn lại, chỉ đổi Service logic + .tres (KHÔNG viết lại kiến trúc). Blacksmith: chỉ `repair(hero)` (trừ gold theo durability) + stub `upgrade` (Ngoài phase). Market: `buy(potion/food)`, `sell(loot)`. Alchemy: `craft(medicine)` trị `injury_level`. Kitchen: sản `food` (nguồn cho Inn/Market). Guild: cấp expedition + `+energy_cap` + roster cap.
6. Viết `TownService` registry + `get_building(service_type)` + queue API; TownManager instantiate building từ slot data-driven.
7. Tạo `RegionDef` + `ZoneDef` + ≥3 region (Valoria/Silverwood/Iron Mountain theo WORLD.md) mỗi region ≥2 zone; nối `monster_pool` tới EnemyDef P1 + `build-monster` SpawnPool/SpawnZone.
8. Implement gate mở khoá zone: hàm `is_zone_unlocked(zone)` kiểm `required_level` + `unlock_by_stars`; lưu `cleared_stars` per zone trong PlayerProfile.
9. `WorldMap.tscn` + `WorldMapViewModel`: render region→zone card, hiển thị lock/star, nút phái đoàn (disable khi khoá/thiếu energy).
10. `ExpeditionService.start()`: kiểm energy + unlock + hero rảnh; trừ `energy_cost`; tạo `ExpeditionState` với `seed` từ RandomService (KHÔNG `randf()` — theo `ai.md`); set hero `state=&"expedition"`.
11. `ExpeditionService.resolve()`: chạy Battle Engine headless seeded (reuse `build-combat`, damage pipeline P1), tính winrate theo `hero.power` vs `recommended_power`; trao reward từ `reward_table_id`; nếu thua nặng → hero `knocked_out`; cập nhật `cleared_stars` theo `star_thresholds`. Áp trần idle 80%.
12. TimeService tick gọi `ExpeditionService.tick()` để resolve mọi expedition có `end_epoch<=now`; fire-and-forget: không cần app mở (tính khi resume).
13. Gem speedup: `speedup(exp)` trừ gem (giá từ .tres), giảm `end_epoch`; emit `expedition_speedup`.
14. Energy regen: TimeService accrual `energy += rate*elapsed` clamp `energy_cap` (cap tăng theo Guild level). Expedition gate bằng energy.
15. Knockout→revive flow: hp=0 trong resolve → `state=&"knocked_out"`, đặt `injury_recover_at`; hero "khiêng về thành" (transition state, animation hook, KHÔNG xoá hero); Inn/Alchemy rút ngắn recover. KHÔNG permadeath.
16. Utility AI needs (`build-ai`): định nghĩa goal `RestGoal/RepairGoal/HealInjuryGoal/BuyGoal/TrainGoal/HuntGoal/IdleGoal`; scorer đọc `fatigue/hp/injury/durability/mood/gold` + ngưỡng từ .tres; highest score wins (KHÔNG `if hp<30`). Decision order bám `ai.md`: Survival→Safety→Quest→Profit→Relationship→Entertainment→Idle.
17. Mood system: cập nhật `mood` theo thắng/thua/nghỉ/ăn/injury (interval 5s theo `ai.md`); map `mood`→5 mặt cảm xúc cho HeroCard; mood thấp giảm hiệu suất (đọc curve từ .tres).
18. Fatigue efficiency: hàm `effective_power(hero)=base * fatigue_curve(fatigue) * mood_mult` dùng trong resolve + AI chọn zone.
19. Offline accrual tinh chỉnh: on-resume, `TimeService.compute_offline` → áp fatigue+, energy tới cap, resolve expedition xong trong lúc offline, injury hồi; hiển thị popup "Trong lúc bạn vắng mặt…" tổng kết reward (≤80% active).
20. UI HeroCard mở rộng + BuildingWindow + ExpeditionPanel + WorldMap wiring qua EventBus signals; tôn chỉ `ui.md` "world always visible".
21. Debug/cheat + telemetry (task riêng ở mục dưới) và test suite (mục Tests) — làm song song từng hệ, không dồn cuối.

### Tests

Theo `testing.md`/`unit-testing.md`/`simulation.md`/`regression.md`. Đặt tại `tests/`, chạy headless (nhắc trong MEMORY: chạy Godot headless để validate).

- **Unit — EconomyService cost curve:** `GivenBuildingLevel_WhenComputeUpgradeCost_ThenMatchesBasePowGrowth` (kiểm `cost(3)=base*growth^2`, làm tròn ổn định).
- **Unit — offline idle cap:** `GivenLongOffline_WhenAccrual_ThenIdleRewardNotExceed80PctActive` (bám ngưỡng `economy.md`).
- **Unit — energy cap:** `GivenEnergyBelowCap_WhenRegenElapsed_ThenClampedToCap` + `GivenAtCap_ThenNoOverflow`.
- **Unit — gate zone:** `GivenZoneRequiresLevelOrStars_WhenNotMet_ThenLocked` / `WhenMet_ThenUnlocked`.
- **Unit — mood/fatigue curve:** `GivenHighFatigue_WhenEffectivePower_ThenReducedPerCurve`.
- **Integration — Utility AI chọn goal:** `GivenLowHpAndHighFatigue_WhenThink_ThenRestGoalWins` (không dùng if-else cứng); `GivenBrokenGear_ThenRepairGoalWinsOverHunt`.
- **Integration — knockout→revive:** `GivenHeroHpZeroInExpedition_WhenResolve_ThenStateKnockedOut_AndNoPermadeath_AndRecoversLater`.
- **Integration — building service:** `GivenHeroNeedsRepair_WhenBlacksmithHasCapacity_ThenGoldSpent_AndDurabilityRestored`; queue: `GivenBuildingAtCapacity_ThenHeroWaitsInQueue`.
- **Integration — expedition lifecycle:** `GivenExpeditionStarted_WhenTimeReachesEndEpoch_ThenResolvedOnce_AndRewardGranted` (idempotent: `resolved` chặn double-grant).
- **Simulation — determinism:** `GivenSameSeedAndRoster_WhenResolveExpedition_ThenIdenticalReward` (SIM↔VIEW tách, tất định theo kiến trúc chung).
- **Simulation — kinh tế dài hạn:** chạy 50 hero × N ngày mô phỏng; assert gold Source≈Sink (không lạm phát vô hạn), durability sink hoạt động (theo `economy.md` "2 sources 2 sinks").
- **Regression — offline resume:** save trước, `advance` giờ mô phỏng, load lại → trạng thái expedition/energy/fatigue khớp bản tính online tương đương (chống drift do đọc giờ nhiều nơi).
- **Regression — save migration:** load save P1 (thiếu field mới) → không crash, field default hợp lệ, save lại version P2 + .bak tồn tại.
- **Stress (nhẹ, theo `stress-test.md`):** 300 hero + expedition đồng thời + AIScheduler → không tick trong `_process`, không spike frame (đo bằng harness headless).

### Telemetry & Debug

Telemetry (theo `telemetry.md` + `economy.md` "Track": Gold Earned/Spent, Repair Cost…), emit qua EventBus, sink local ở P2 (backend P6):
- Economy: `gold_earned{source}`, `gold_spent{sink}`, `repair_cost`, `building_upgrade{id,level,cost}`, `food_produced`, `potion_crafted`.
- Building: `building_visitor{id}`, `building_queue_time`, `building_usage_rate`, `building_downtime`.
- Expedition/world: `expedition_started{zone}`, `expedition_resolved{zone,win,reward}`, `expedition_speedup{gem}`, `zone_unlocked`, `zone_star_earned{zone,stars}`, `energy_spent`.
- Hero: `hero_knocked_out`, `hero_recovered`, `mood_changed{from,to}`, `fatigue_high`, `ai_goal_selected{goal,reason}` (theo `ai.md` "Always explain why").

Debug tools/cheat (theo `debug-tools.md` + danh sách Debug của `build-building`/`build-town`/`world.md`):
- Town: `spawn_building`, `instant_upgrade`, `fill_storage`, `reset_queue`, `pause_town`, `show_navigation`, `show_economy`.
- Hero: inspector hiển thị `state/goal/needs(hp,fatigue,injury,mood,energy)/target/reason`; cheat `set_fatigue`, `set_injury`, `knock_out_hero`, `revive_hero`, `set_mood`.
- World/Expedition: `unlock_all_zones`, `grant_stars{zone}`, `finish_expedition_now`, `add_gold/gem/energy`, `skip_time{hours}` (drive TimeService để test offline accrual), `reveal_map`.

### ▶ Cổng Run & Test

PASS khi (quan sát được, manual + tự động):
- Manual: mở thành thấy ≥7 building; hero AI TỰ chọn đi Inn khi mệt, đi Blacksmith khi gear mòn, đi Alchemy khi injury — KHÔNG do người chơi ra lệnh (chứng minh Utility AI, không if-else).
- Manual: mở WorldMap thấy ≥3 region, zone khoá hiện lock + điều kiện; clear một zone → clear-star tăng và mở zone kế theo `unlock_by_stars`.
- Manual: phái expedition → timer chạy; đóng app; `skip_time 8h` (hoặc chỉnh giờ hệ thống) mở lại → expedition đã resolve, reward popup hiện, energy/fatigue cập nhật đúng, tổng reward ≤ 80% mốc active tương đương.
- Manual: hero knockout trong expedition → được "khiêng về thành", vào `recovering`, KHÔNG biến mất; sau khi hồi (hoặc dùng Inn/Alchemy) trở lại `in_town` và có thể phái tiếp.
- Manual: gem speedup rút ngắn timer đúng lượng; gem bị trừ.
- Tự động: toàn bộ test suite ở mục Tests xanh khi chạy headless; sim determinism trả reward giống hệt với cùng seed; sim kinh tế không lạm phát; regression migration + offline resume pass; stress 300 hero giữ 60fps và 0 lần AI tick trong `_process`.

FAIL nếu: có `if hp<30`-style trong AI; bất kỳ expedition resolve 2 lần (double reward); hero permadeath; giá building/energy/reward hardcode trong code thay vì .tres; offline reward > active; đọc `Time.get_*`/`randf()` ngoài TimeService/RandomService; AI/building poll trong `_process`.

### Deliverables

- ✓ Town.tscn + TownManager + TownService data-driven (7 building slot từ .tres).
- ✓ 7 BuildingDef .tres + 7 building (Data/State/Service/View/UI) theo khung `build-building`, mỗi cái 1 service + cost curve + upgrade level.
- ✓ HeroInstance mở rộng vòng đời (fatigue/injury/mood/energy/state/durability) + knockout→revive (không permadeath).
- ✓ Utility AI needs đầy đủ (7 goal cạnh tranh, scorer data-driven, decision order theo `ai.md`).
- ✓ RegionDef/ZoneDef + ≥3 region/≥6 zone, gate level + clear-star; WorldMap.tscn.
- ✓ ExpeditionService idle fire-and-forget + gem speedup + reward seeded tất định; ExpeditionPanel + "xem trực tiếp".
- ✓ Energy regen + cap; offline accrual qua TimeService (≤80% active) + popup tổng kết.
- ✓ Telemetry events + debug/cheat (skip_time, knock_out, unlock_all_zones…).
- ✓ Test suite unit/integration/simulation/regression/stress xanh headless.
- ✓ Save migration P1→P2 (version + .bak) không mất dữ liệu.
- ✓ Docs feature (theo `CLAUDE.md` Documentation): architecture/scene tree/data model/save model/service flow/hero interaction flow/perf notes cho town + expedition.

### Rủi ro & giảm thiểu

- **Utility AI "kẹt": hero dao động giữa 2 goal (thrashing).** → Thêm hysteresis/cooldown chuyển goal + "commitment" tới khi hoàn thành goal hiện tại (theo `ai.md` "Avoid constant target switching"); test integration khẳng định 1 primary goal ổn định.
- **Offline accrual drift (nhiều hệ tự đọc giờ → lệch online/offline).** → TimeService là NGUỒN GIỜ DUY NHẤT; regression test so online vs offline cho cùng elapsed; cấm `Time.get_*` ngoài TimeService (kiểm bằng grep trong Cổng Run).
- **Lạm phát gold do 7 building + expedition bơm reward.** → Cost curve mũ + trần idle 80% + durability/repair/food/potion là sink bắt buộc; sim kinh tế dài hạn giám sát Source vs Sink (theo `economy.md`).
- **Expedition resolve trùng (double reward) khi resume nhiều lần / cùng lúc mở app.** → Cờ `resolved` idempotent + resolve trong 1 điểm (ExpeditionService.tick), test lifecycle.
- **Perf: 300 hero + needs tick + 7 building queue.** → AIScheduler theo interval `ai.md`; building dùng signal/timer không poll (`build-building` Performance); stress test glate-catch trước khi qua phase.
- **Scope creep sang equipment upgrade/skill/dungeon.** → Blacksmith upgrade chỉ stub; danh sách "Ngoài phase" rõ ràng; review gate reject nếu chạm P3/P4.
- **Save bloat do lưu expedition/monster.** → Chỉ lưu ExpeditionState + persistent monster (elite/rare) theo `build-monster` Save Rules; normal monster respawn từ zone data, không lưu.

---

## Phase 3 — Sưu tập hero & chiều sâu build
> **Mục tiêu:** Biến team-comp + build (class/race/skill/equip/rune/talent/synergy) thành đòn bẩy chiến thuật chống power-creep, để "AI + build > chỉ số cao" · **Thời lượng:** 4-6 tuần · **Phụ thuộc:** P1 (Battle Engine, HeroInstance, Database, LootService lõi) — chạy song song P2 được (không đụng world map/town lifecycle).

### Vì sao ở đây
P1 đã có Battle Engine tick-loop tất định (SIM↔VIEW, pipeline `Damage→Crit→Def→Resist→Shield→HP`), `HeroInstance` và affix/stat math trong `game/autoload/profile.gd`. P3 lấy các "lỗ cắm" đó và biến thành hệ thống sưu tập/build đầy đủ: đây là nơi giá trị lâu dài của một hero được sinh ra, đúng triết lý `HERO.md` ("giá trị hero đến từ Build/Synergy/Equipment/Rune/Talent/chiến thuật, không phải rarity"). P3 phải xong trước P4 (boss/stage/PvP-bot cần kit skill + status + synergy để test counter) và trước P5 (Season đổi meta bằng Rune/Modifier chứ không buff hero — theo `BALANCE.md` "Seasonal Balance").

Thứ tự trong nội bộ P3: **stat aggregation trước** (mọi thứ khác cộng dồn vào một chỗ), rồi **skill kit → equipment → rune → talent → synergy/awakening → gacha/codex**. Nếu làm gacha trước sẽ không có gì để "sưu tập". Aggregation là hợp đồng trung tâm — build-combat và mọi source phải chảy qua nó.

### Phạm vi
**Trong phase:**
- 7 class role (Tank/Warrior/Assassin/Ranger/Mage/Support/Summoner) + subclass data-driven; 8 race (Human/Elf/Orc/Dwarf/Undead/Angel/Demon/Dragonkin); rarity Common/Elite/Epic/Legend/Mythic; growth curve (sao 1-5 per stat).
- Skill kit chuẩn: 1 passive + 3 active + 1 ultimate, chạy trong Battle Engine (mana, cooldown + Skill Haste, status Burn/Freeze/Stun/Shield/Slow/Silence/Taunt…), AI ưu tiên skill (Ultimate→support→damage→basic).
- Equipment 8 slot (Weapon/Helmet/Armor/Gloves/Boots/Ring/Necklace/Artifact): main+secondary affix roll theo rarity/iLv/quality, enhance +0..+20, refine (roll lại secondary), reforge (prefix/suffix), socket, salvage — **tái dùng affix code** trong `profile.gd`.
- Rune: core + 4 slot, quality, level 1-20 (mở effect ở 5/10/15/20), set 2/4, resonance, loadout preset.
- Talent 3 nhánh (chọn 1 hướng chính), respec có phí.
- Synergy race/class (aura khi đủ số hero cùng loại) + Awakening (đổi passive/ultimate, không tăng chỉ số nhiều).
- Recruit/Summon gacha (pity/duplicate→shard→awaken), Collection/Codex.
- Công thức stat aggregation tất định + telemetry usage.

**Ngoài phase (làm sau — chống scope creep):**
- Boss phase/stage tuyến/PvP-bot arena → **P4** (P3 chỉ đưa hook synergy & skill để P4 test counter).
- Story/Season framework, seasonal rune farm, cursed/corrupted rune → **P5** (P3 để field `season_id`, `is_seasonal` sẵn nhưng không farm).
- Transmog/skin, Equipment Fusion, Hybrid Rune, Guild Rune, pet/summon leveling sâu → future.
- Cloud sync collection/gacha lịch sử → **P6** (P3 lưu offline JSON đầy đủ, `Net` no-op).

### Hệ thống xây
| Hệ thống | Mô tả | Skill/Agent .claude dùng |
|---|---|---|
| StatAggregator | Pure service gom base→growth→equip→rune→set/resonance→talent→awakening→synergy→buff thành `FinalStats` tất định | `build-hero`, `build-combat`; agent Architect + Balancing |
| SkillKitService + effects | Nạp `SkillDef` (1P+3A+1U) vào Battle Engine, quản mana/cooldown/haste, resolve effect (Damage/Heal/Buff/Debuff/CC/Summon/Shield) | `build-combat` (tái dùng `SkillExecutor`, `effects/`, `status/`) |
| StatusEffectRegistry (mở rộng) | Burn/Freeze/Stun/Slow/Bleed/Shield/Silence/Taunt/Regen + stack rule, combo (Freeze×Lightning→Shatter) | `build-combat` (thư mục `status/`) |
| EquipmentService | Roll affix theo rarity/iLv/quality, enhance/refine/reforge/socket/salvage, equip-validate theo class | `build-loot` (LootRoller, affix), `build-hero` (EquipmentComponent); agent Economy |
| RuneService | Core+4 slot, level→effect, set/resonance, loadout preset, fusion/reforge | `build-loot` (roll), Architect |
| TalentService | 3 nhánh point-buy, respec phí, apply vào aggregator | `build-hero`; agent Balancing |
| SynergyService | Đếm race/class trong team → aura data-driven; awakening apply | `build-combat`, `build-hero` |
| SummonService (gacha) | Banner weighted (RandomService), pity, guaranteed, dup→shard | `build-loot` (RewardProtection, weighted, claim_id) |
| CollectionService / Codex | Track hero/skill/item/rune đã sở hữu/đã thấy, milestone reward | `build-ui`; agent UIUX |
| Build UI screens | Hero detail, equip, rune, talent, codex, summon | `build-ui`; agent UIUX |

Mọi randomness qua `RandomService` seeded (rule `ai.md` "Never randf() inside AI", `build-loot` "deterministic seeded rolls"). Balancing bằng percentage, không magic number (rule `balancing.md`, `coding-style.md`).

### Data model / Resource (.tres)
**HeroDef (mở rộng, `res://resources/heroes/*.tres`)**
| field | kiểu | ý nghĩa |
|---|---|---|
| id / display_name / title | StringName / String | định danh, tên hiển thị |
| class_role | int (enum ClassRole) | Tank/Warrior/Assassin/Ranger/Mage/Support/Summoner |
| subclass_id | StringName | Knight/Berserker/Ninja… (data-driven, không tạo `Knight.gd`) |
| race | int (enum Race) | 8 race |
| element | int (enum Element) | Fire/Ice/…/Void |
| rarity | int (enum Rarity) | Common/Elite/Epic/Legend/Mythic |
| base_stats | Dictionary | 15 stat gốc (max_hp, attack, magic_attack, defense, magic_defense, attack_speed, move_speed, crit_chance, crit_damage, dodge, accuracy, luck, lifesteal, block, skill_haste) |
| growth_stars | Dictionary[StringName,int] | 1..5 sao per stat → hệ số/level |
| skill_ids | Array[StringName] | 5 phần tử: [passive, a1, a2, a3, ultimate] |
| allowed_weapon_types | Array[int] | tương thích equip (Knight: sword/shield/spear) |
| talent_tree_id | StringName | trỏ TalentTreeDef |
| bond_ids | Array[StringName] | Hero Bond (bonus nhỏ) |
| awaken_def_id | StringName | trỏ AwakenDef |
| personality_id / trait_ids | StringName / Array | ảnh hưởng AI scoring (dùng ở P1/P2) |
| season_id / is_seasonal | StringName / bool | placeholder cho P5 |

**SkillDef (`res://resources/skills/*.tres`)** — nới `SkillData` của build-combat:
`id, display_name, kind(Passive/Active/Ultimate), skill_type(Damage/Heal/Shield/Buff/Debuff/CC/Summon/Utility), target_rule(single/lowest_hp/largest_group/backline/all_enemy/all_ally/self…), aoe_shape(single/line/circle/cone/chain/aura), element, scaling_stat(StringName: attack/magic_attack/max_hp/healing_power…), base_multiplier(float), per_level_multiplier(float), mana_cost(int), base_cooldown(float), cast_time(float), effect_ids(Array), status_apply(Array[StringName]), combo_tag(StringName), tags(Array[StringName]), ai_priority(int), max_level(int=5), evolve_to_id(StringName cho Awakening)`.
Cooldown là runtime state (`SkillRuntimeState`), KHÔNG lưu trong SkillDef (build-combat rule).

**ItemDef / EquipmentInstance**
- `ItemDef` (static): `id, slot(enum 8 ô), weapon_type, rarity, base_ilvl, allowed_class_roles, main_stat_key, main_stat_range(Vector2), secondary_pool(Array[AffixDef]), max_sockets, set_id, legendary_effect_id, is_seasonal`.
- `EquipmentInstance` (runtime/save, JSON): `uid, item_def_id, ilvl, quality(int 0-4 Poor..Perfect), enhance_level(0-20), main_stat_value, affixes(Array[AffixRoll{key,value,locked}]), sockets(Array[rune_uid]), owner_hero_id, is_locked`.
- `AffixDef`: `key, min, max, rarity_weight, is_percent` — feed vào affix roller **tái dùng từ `profile.gd`**.

**RuneDef / RuneInstance**
- `RuneDef`: `id, category(Offensive/Defensive/Utility/Control/Summoner), is_core, core_effect_id, element_set_id, base_main_stat, per_level_gain, level_unlock_effects(Dictionary{5,10,15,20→effect_id}), max_level(20), quality`.
- `RuneInstance` (save): `uid, rune_def_id, level, affixes, quality, owner_hero_id, slot_index(-1 core..0-3)`.

**TalentTreeDef**: `id, branches(Array[TalentBranch])`; `TalentBranch{branch_id, nodes(Array[TalentNode])}`; `TalentNode{id, requires, cost_points, stat_mods(Dictionary), grant_effect_id}`.
**SynergyDef**: `id, kind(race/class), key, thresholds(Dictionary{count→aura_effect}), scope(team)`.
**AwakenDef**: `id, hero_id, cost(materials/shards), new_passive_id, upgraded_ultimate_id, extra_talent_node_ids, unlock_skin_id`.
**BannerDef (gacha)**: `id, pool(Array[weighted{hero_id,rarity,weight}]), pity_hard(int), pity_soft_start(int), guaranteed_rarity_on_pity, cost_currency, cost_amount, rate_up_ids`.
**Runtime aggregate**: `FinalStats` (RefCounted, không phải Resource) — snapshot bất biến dùng cho Battle Engine.

### Autoload / Service
- **Không thêm autoload mới** (giữ danh sách P0). Các service P3 là instance thường (RefCounted/Node con của scene manager hoặc thuộc `HeroInstance`/`PlayerProfile`), tiêm qua DI, không singleton lạm dụng (CLAUDE.md "avoid Singleton Abuse").
- `Database` (façade, có sẵn): thêm loader cho SkillDef/ItemDef/RuneDef/TalentTreeDef/SynergyDef/AwakenDef/BannerDef.
- `PlayerProfile` (account, P0): thêm kho `owned_equipment`, `owned_runes`, `collection`, `codex_seen`, `pity_counters`, `currency`.
- `HeroInstance` (module, P0): thêm `equipped[8]`, `rune_loadouts`, `active_loadout`, `talent_points`, `awaken_state`, `skill_levels`, hàm `get_final_stats() -> FinalStats` (gọi StatAggregator).
- `Telemetry` (có sẵn): thêm event nhóm build/gacha (mục Telemetry bên dưới).
- `EventBus`: signal `stats_recomputed(hero_id)`, `equipment_changed`, `rune_changed`, `hero_summoned`, `awaken_completed` — chỉ emit khi có sự kiện thật, không mỗi frame (rule `signal-rules.md`).

### Scene / màn hình
UI-first, world luôn nhìn thấy phía sau (CLAUDE.md "world always visible"), portrait mobile:
- `HeroDetailScreen.tscn` — root `Control`; node `PortraitPanel`, `StatColumn`, `SkillRow(5)`, `TabBar(Equip/Rune/Talent/Awaken)`; VM `HeroDetailViewModel` (bind `FinalStats`, listen `stats_recomputed`).
- `EquipmentScreen.tscn` — `SlotGrid(8)`, `AffixList`, `EnhancePanel`, `ReforgePanel`, `SalvageDrawer`; VM `EquipViewModel`.
- `RuneScreen.tscn` — `CoreSlot`, `RuneSlot(4)`, `SetResonanceBadge`, `LoadoutTabs`; VM `RuneViewModel`.
- `TalentScreen.tscn` — `BranchColumn(3)` node graph, `RespecButton`; VM `TalentViewModel`.
- `CodexScreen.tscn` — `HeroGrid`, `SkillCodex`, `ItemCodex`, `RuneCodex`, milestone bar; VM `CodexViewModel`.
- `SummonScreen.tscn` — `BannerCard`, `PullButton(x1/x10)`, `PityBar`, `ResultReveal` (pooled reveal FX); VM `SummonViewModel`.
- Tái dùng `DamageNumber.tscn`/`FloatingText.tscn`/`StatusIcon.tscn` pool từ build-combat cho hiển thị status kit mới. VM chỉ đọc state, không điều khiển hero (rule `ui.md`).

### Task breakdown
1. **Enum + Database loader**: thêm ClassRole/Race/Element/Rarity/EquipSlot/WeaponType/RuneCategory vào `game/enums.gd`; viết loader `.tres` cho các Def mới trong `Database`; seed ~3 hero/class (21 hero), ~30 skill, ~40 item, ~20 rune mẫu.
2. **StatAggregator (pure)**: `func aggregate(hero: HeroInstance, ctx) -> FinalStats`. Thứ tự cộng dồn (công thức bên dưới). 100% deterministic, không đọc scene tree, không random. Đây là contract — viết test trước (TDD).
3. **HeroInstance.get_final_stats()** cache theo dirty-flag; invalidate khi equip/rune/talent/awaken/level đổi → emit `stats_recomputed`.
4. **SkillKitService**: nạp 5 skill/hero vào Battle Engine; `SkillRuntimeState` giữ cooldown/level; `effective_cooldown = base * (1 - clamp(skill_haste, 0, 0.7))`; mana gate; AI priority Ultimate→support→damage→basic (theo `COMBAT.md`, `SKILLS.md` "AI Priority"), skip skill nếu điều kiện sai (vd Heal khi full HP).
5. **StatusEffect mở rộng**: thêm Freeze/Silence/Taunt/Regen/Slow vào `status/`; định nghĩa stack_rule + max_stacks; xử lý bất khả kháng (Freeze = mất lượt) tất định theo tick.
6. **Skill combo**: bảng combo data-driven (Burn+Wind→FireStorm, Freeze+Lightning→Shatter, Poison+Explosion…) trong `SkillKitService`; trigger khi status nguồn tồn tại lúc skill combo_tag đánh trúng.
7. **EquipmentService.roll_affixes**: dùng affix roller tái dùng từ `profile.gd`; số dòng secondary theo rarity (Common 0-1 … Mythic 4); main_stat theo iLv×quality. Seeded.
8. **Enhance/Refine/Reforge/Socket/Salvage**: enhance +0..+20 chỉ tăng base (không đổi effect — `EQUIPMENT.md`); refine roll lại secondary (lock line có phí); reforge đổi prefix/suffix; socket gắn rune uid; salvage → gold+material+crystal+essence (gold sink, rule `economy.md`).
9. **Equip validate**: chặn equip nếu `weapon_type` không thuộc `allowed_weapon_types` của class; chặn equip khi `is_locked`; ownership = 1 instance/1 hero.
10. **Set bonus**: đếm số item cùng `set_id` đang mặc → apply 2/4/6-piece effect vào aggregator (Guardian, Shadow…).
11. **RuneService**: gắn core+4; level 1-20 mở effect ở 5/10/15/20; set 2/4; resonance khi đủ cùng element (4 Fire → +15% Burn); fusion 3→1; reforge secondary; loadout preset (Raid/PvP/Guild/Tower) đổi 1 nút.
12. **TalentService**: point-buy 3 nhánh, prerequisite, ép chọn 1 hướng chính; respec tốn currency; apply node vào aggregator.
13. **SynergyService**: đếm race/class trong team hiện tại → aura effect (data-driven `SynergyDef`); recompute khi team đổi; đẩy vào aggregator layer synergy.
14. **AwakenService**: tiêu materials/shards → swap passive/ultimate id, mở extra talent node, unlock skin; KHÔNG tăng chỉ số quá nhiều (rule `HERO.md`, `BALANCE.md`).
15. **SummonService (gacha)**: banner weighted qua RandomService; pity soft/hard; guaranteed rarity; duplicate → shard (feed Awaken); mỗi pull có `claim_id`+`reward_hash` chống double-claim (tái dùng `RewardProtection` build-loot); lưu `pity_counters` vào PlayerProfile.
16. **CollectionService/Codex**: mark owned/seen cho hero/skill/item/rune; milestone reward bundle; feed CodexScreen.
17. **Save/migration**: mở rộng save JSON atomic (+`.bak`+version+migration) cho owned_equipment/runes/collection/pity/currency/loadouts; bump version; viết migration từ save P1/P2.
18. **UI screens + VM**: dựng 6 scene ở mục trên; bind qua ViewModel + EventBus; reuse pooled FX.
19. **Debug cheats + inspector panel** (mục Telemetry & Debug).
20. **Balance pass**: chỉnh power budget theo `BALANCE.md` (mỗi hero cùng ngân sách 100 điểm; ultimate mạnh → active yếu hơn); chạy simulation win-rate.

### Công thức stat aggregation (tất định, thứ tự cố định)
```gdscript
# StatAggregator.gd (pure, no scene, no RNG)
func aggregate(hero: HeroInstance) -> FinalStats:
    var s := FinalStats.new()
    # 1) base + growth theo level
    for key in hero.def.base_stats:
        var star := hero.def.growth_stars.get(key, 1)
        s.flat[key] = hero.def.base_stats[key] + growth_per_level(star) * (hero.level - 1)
    # 2) flat từ equipment main+secondary+enhance (flat trước, percent gom riêng)
    for eq in hero.equipped:            # add_flat / add_percent phân tách
        _apply_affixes(s, eq)           # dùng affix code tái dùng từ profile.gd
    # 3) set bonus (2/4/6) -> flat & percent
    _apply_set_bonus(s, hero.equipped)
    # 4) rune main + level effect + set/resonance
    _apply_runes(s, hero.rune_loadouts[hero.active_loadout])
    # 5) talent node mods
    _apply_talents(s, hero.talent_points)
    # 6) awakening (đa số đổi cơ chế, ít cộng chỉ số)
    _apply_awaken(s, hero.awaken_state)
    # 7) synergy aura (race/class) — layer riêng để tách nguồn cho telemetry
    _apply_synergy(s, hero.team_context)
    # 8) tổng hợp cuối: final = (flat) * (1 + sum_percent), rồi clamp
    for key in s.flat:
        s.value[key] = (s.flat[key]) * (1.0 + s.percent.get(key, 0.0))
    _clamp(s)   # crit_chance<=0.8, crit_damage<=3.0, dodge<=0.4, skill_haste<=0.7
    return s
```
- **Nguyên tắc**: flat cộng trước, percent gom rồi nhân **một lần** cuối (tránh multiplier ẩn — rule `balancing.md` "Damage Formula: Avoid hidden multipliers"). Mỗi layer giữ nguồn riêng để debug/telemetry biết % power đến từ đâu (target `balancing.md`: Level 30% / Equipment 50% / Skill 20%). Clamp theo `build-combat` (crit 80%, crit dmg 300%, dodge 40%) + skill_haste 70%. `growth_per_level(star)` map 1★→+x%..5★→+5x% base, data-driven.

### Tests
Theo `testing.md`/`unit-testing.md`/`simulation.md`/`regression.md`; đặt trong `tests/`, dùng khung GUT (naming `GivenX_WhenY_ThenZ`):
- **Unit — aggregation**: `GivenSameHeroSameBuild_WhenAggregatedTwice_ThenIdenticalFinalStats` (tất định); `GivenPercentAndFlatStack_WhenAggregated_ThenFlatBeforePercent`; `GivenCritOver100Percent_WhenClamped_ThenCritChanceEquals80`.
- **Unit — skill/status**: `GivenSkillHaste50_WhenCooldownComputed_ThenReducedByHalf`; `GivenUltimateNotFullMana_WhenAISelects_ThenUltimateSkipped`; `GivenFrozenTarget_WhenTick_ThenTargetLosesTurn`; `GivenBurnPlusWindCombo_WhenTriggered_ThenFireStormApplied`.
- **Unit — equip/rune**: `GivenMythicItem_WhenAffixRolled_ThenSecondaryCountEquals4`; `GivenSameSeed_WhenAffixRolledTwice_ThenSameAffixes`; `GivenWeaponWrongType_WhenEquip_ThenRejected`; `Given4FireRunes_WhenEquipped_ThenFireResonanceApplied`; `GivenRuneLevel10_WhenReached_ThenEffectUnlocked`.
- **Unit — talent/awaken/synergy**: `GivenTalentBranchChosen_WhenPickOtherBranchExclusive_ThenRejected`; `GivenAwaken_WhenCompleted_ThenPassiveSwappedNotStatsInflated`; `Given3Elves_WhenTeamBuilt_ThenElfSynergyAura`.
- **Unit — gacha**: `GivenPityHardReached_WhenPull_ThenGuaranteedRarity`; `GivenDuplicateHero_WhenSummoned_ThenConvertedToShards`; `GivenSameSeed_WhenPullTwice_ThenSameResult`; `GivenReward_WhenClaimedAgain_ThenRejected`.
- **Integration**: equip→aggregate→Battle Engine dùng đúng `FinalStats`; save→load→build khôi phục nguyên vẹn (equip/rune/talent/pity).
- **Simulation** (`simulation.md`): chạy N trận headless seeded 2 team khác build → thu win-rate; kiểm tra counter (Assassin build burst thắng Support-line, thua Tank-line) đúng `COMBAT.md` counter wheel; không team nào win-rate >55% (`BALANCE.md`).
- **Regression** (`regression.md`): snapshot `FinalStats` của bộ hero mẫu + kết quả trận seeded; fail nếu đổi ngoài ý muốn.

### Telemetry & Debug
Telemetry (`telemetry.md`, mục Telemetry của build-combat/build-loot/`balancing.md`):
- Build: `equipment_equipped`, `enhance_attempt{level,result}`, `reforge`, `salvage{materials}`, `rune_equipped`, `rune_fusion`, `talent_pick/respec`, `awaken_completed`, `loadout_switch`, `stat_power_breakdown{level%,equip%,skill%,rune%}`.
- Combat balance: `skill_cast{skill_id}`, `skill_usage_rate`, `status_applied`, `combo_triggered`, `synergy_active`, `hero_pick_rate`, `team_usage`, `win_rate` (feed KPI `BALANCE.md`: hero usage>70%, rune/set không >40-45%).
- Gacha/economy: `summon_pull{banner,rarity}`, `pity_reset`, `duplicate_to_shard`, `currency_spent`, `duplicate_claim_rejected`.
Debug tools (`debug-tools.md` + inspector build-combat/hero):
- Cheats: `give_item`, `give_rune`, `force_affix`, `max_enhance`, `unlock_all_skills`, `set_talent`, `awaken_now`, `force_summon_rarity`, `reset_pity`, `add_currency`, `dump_final_stats`, `sim_battle{teamA,teamB,seed}`.
- Panel: hiển thị `FinalStats` với **breakdown theo layer** (base/growth/equip/set/rune/resonance/talent/awaken/synergy), cooldown/mana skill, status đang chịu, và "reason" AI chọn skill (rule `ai.md` "Always explain why").

### ▶ Cổng Run & Test
PASS khi (quan sát được):
- Chạy headless `sim_battle` cùng seed 2 lần → kết quả **bit-identical** (log damage/order trùng khớp) → xác nhận tất định.
- Đổi 1 món equip Legend qua UI → `stats_recomputed` bắn, stat panel cập nhật, breakdown cho thấy Equipment ~50% power ở mid-game (khoảng `balancing.md`).
- Pull gacha 100 lần headless → phân phối rarity khớp banner ±sai số, pity hard **luôn** trả guaranteed đúng mốc, không double-claim.
- Save khi đầy build → tắt → load: equip/rune/talent/loadout/pity/collection khôi phục 100% (diff JSON = rỗng ngoài timestamp).
- Simulation 500 trận đa build: không hero win-rate >55% & không team >55%; ít nhất 3 build khả thi cho mỗi class role (theo `RUNE.md` "3-5 build/hero").
- Toàn bộ unit/integration/regression tests xanh; `godot --headless` không lỗi/leak.
FAIL nếu: aggregation ra khác nhau giữa 2 lần cùng input; skill AI spam sai (Heal khi full HP, Ultimate khi thiếu mana); equip sai class được nhận; gacha double-claim hoặc pity không kích; save mất bất kỳ owned item; có 1 team stomp (>60% win-rate) trong sim.

### Deliverables
- ✓ StatAggregator tất định + `FinalStats`, tài liệu công thức, 100% test aggregation.
- ✓ 7 class role + 8 race + 5 rarity + growth curve data-driven (≥21 hero seed).
- ✓ Skill kit 1P+3A+1U trong Battle Engine + status mở rộng + combo, AI priority.
- ✓ Equipment 8 slot: roll/enhance/refine/reforge/socket/salvage/set bonus (affix code tái dùng từ `profile.gd`).
- ✓ Rune core+4, level/effect, set/resonance, fusion/reforge, loadout preset.
- ✓ Talent 3 nhánh + respec; Synergy race/class; Awakening.
- ✓ Gacha (pity/dup→shard/claim protection) + Collection/Codex.
- ✓ 6 UI screens + ViewModel; save/migration bump version; debug cheats + inspector breakdown; telemetry đầy đủ.
- ✓ Test suite (unit/integration/simulation/regression) xanh; báo cáo win-rate/pick-rate.

### Rủi ro & giảm thiểu
- **Power creep / hero "must-have"** (nguy cơ chính, ngược `HERO.md`+`BALANCE.md`): giữ **power budget cố định** (100 điểm/hero), buff bằng AI/utility/cooldown trước damage, telemetry win/pick-rate + gate sim win-rate <55%; hero mới phải mở lối chơi mới, không mạnh hơn.
- **Multiplier explosion / stat khó cân**: bắt buộc pipeline flat-trước-percent-nhân-một-lần + clamp; cấm nested multiplier; mọi source qua aggregator duy nhất.
- **Non-determinism từ skill/gacha**: mọi RNG qua `RandomService` seeded; test bit-identical; cấm `randf()` (rule `ai.md`).
- **Save bloat / migration lỗi** với hàng nghìn item/rune: lưu instance gọn (uid+def_id+delta), version+`.bak`+migration test round-trip; salvage là gold sink giữ inventory không phình vô hạn.
- **Perf khi recompute** (300 hero): aggregation cache + dirty-flag, chỉ recompute hero đổi build; không aggregate trong `_process`; dùng scheduler cho recompute hàng loạt (rule `performance.md`, target 60fps).
- **Scope creep sang boss/season/PvP**: giữ ranh giới mục "Ngoài phase"; chỉ để hook (field `season_id`, synergy) cho P4/P5, không implement nội dung.

---

## Phase 4 — Nội dung có cấu trúc: boss · stage · PvP
> **Mục tiêu:** Chiều sâu encounter + lớp cạnh tranh · **Thời lượng:** 4-6 tuần · **Phụ thuộc:** P3
>
> ✅ **HOÀN THÀNH** — xem `docs/PHASE4.md`. Giao: BattleSim tất định (skill/cast/CC/interrupt/shield/formation),
> Boss đa phase (BossDef/BossPhaseDef + BossController + enrage/weak-point/break/summon/hazard), WorldBossService
> (rotation tuần + event machine + ContributionBoard + reward-once), StageBattleService (3/3 seeded + chấm sao +
> first-clear once), ArenaService async (MMR-lite + Honor + quota 10/ngày + snapshot freeze), ReplayPlayer tất định,
> save v5 (+migration), Telemetry+Debug, UI BattlePanel, 337/337 test xanh.
> Ghi chú kiến trúc: BossSkillDef gộp vào `SkillDef` (DRY); content code-built trong `ContentP4` (nhất quán P1–P3).

### Vì sao ở đây
P4 nằm ngay sau P3 vì mọi hệ thống cạnh tranh (boss đa phase, stage formation, Đấu Trường Bot) đều tiêu thụ trực tiếp output của P3: hero có skill/equip/rune/synergy, gacha đã cấp đủ pool hero để dựng đội. Không có chiều sâu build từ P3 thì boss "kiểm tra chiến thuật" (theo `docs/scripts/BOSS.md`, `COMBAT.md`) chỉ còn là bài kiểm tra Battle Power thuần — vi phạm triết lý "chiến thuật thắng chỉ số" trong `docs/scripts/PVP.md`. P4 cũng đòi Battle Engine tick-loop tất định (seeded) đã ổn định từ P1: boss phase, PvP replay và stage đều phải cho **cùng input → cùng output** (rules/multiplayer.md, mục Deterministic Logic + Rollback).

P4 mở khoá cho P5-P6: khung boss đa phase + event flow trở thành nền cho Story Boss/Seasonal Boss/Final Boss của campaign & Season (P5); PvP snapshot + MMR-lite + Honor là tiền đề cho leaderboard online và telemetry cân bằng meta (P6). Đây là phase biến "thế giới sống" thành "thế giới có mục tiêu tuần/mùa".

### Phạm vi
**Trong phase:**
- **Boss đa phase**: chuyển phase theo ngưỡng HP %, `enrage timer`, `weak-point`/`interrupt`, `break gauge`, summon minion — data-driven qua `BossDef` + `BossPhaseDef` + `BossSkillDef`, KHÔNG hardcode trong `Boss.gd`.
- **World Boss rotation tuần** (7 boss/tuần theo lịch, tham chiếu `docs/scripts/BOSS.md`) + **BXH sát thương demo** (local, contribution tracking, chưa online).
- **Stage battle formation deterministic**: node "3/3" trên world-map, đội hình cố định, kết quả tất định seeded (đây là stage "3/3" phụ đúng như quyết định chốt — expedition chính vẫn là xem hero auto-hunt ở Bãi Săn mở).
- **Đấu Trường Bot (async)**: đấu với snapshot đội đối thủ đã lưu, trận 90s auto, timeout = nhiều HP hơn thắng, **MMR-lite**, thưởng **Honor**, **replay tất định**.

**Ngoài phase (làm sau — chống scope creep):**
- Guild War, Team Arena, Draft/Ban, Tournament, Cross-Server (P6 online + backend).
- World Boss leaderboard **online thật** (P6); P4 chỉ demo local + snapshot.
- Guild Boss / Raid 10-hero, Endless Tower, Challenge Dungeon, Hidden Room, Dungeon random event/puzzle/escort (P5+ hoặc backlog).
- Anti-Meta system, Seasonal PvP Modifier động, PvP maps đa dạng (chỉ chừa hook data, chưa build).
- Ancient/Final Boss 5-phase + đổi arena vật lý (P5 story).
- Spectator mode, PvP mua thêm lượt bằng IAP.

### Hệ thống xây
| Hệ thống | Mô tả | Skill / Agent .claude |
|---|---|---|
| Boss Engine đa phase | `BossController` + `BossPhaseComponent` + `BossSkillComponent` + `BossAggroComponent` + `BossMinionComponent`; phase trigger HP%/time/minion-count, enrage timer, weak-point, interrupt, break gauge | **build-boss**, **build-combat** · Architect, AI, Balancing |
| World Boss rotation | `WorldBossService` chọn boss theo `day_of_week` (TimeService.game_time), spawn/despawn theo cửa sổ tuần, `BossContributionTracker` | **build-boss**, **build-events** · Gameplay, Economy |
| Contribution + Reward | `BossRewardComponent` chia thưởng theo damage/heal/tank-time, chống double-claim (save/load, rejoin) | **build-boss**, **build-loot** · Economy, Balancing |
| Stage Battle (3/3) | `StageBattleService` chạy Battle Engine headless seeded với formation cố định; kết quả sao 1-3 | **build-combat** · Architect, Gameplay |
| Formation | `FormationService` + `FormationDef` (slot, buff vị trí, target priority) dùng chung stage + PvP | **build-combat**, **build-ui** · Gameplay, Balancing |
| Đấu Trường Bot async | `ArenaService` vs snapshot; `ArenaSnapshot`; `MmrService` (MMR-lite Elo); Honor sink/source | **build-combat**, **build-network** (offline stub) · Gameplay, Economy, Balancing |
| Replay tất định | `ReplayRecorder`/`ReplayPlayer` ghi seed + command stream, phát lại bằng chính SIM tick-loop | **build-combat** · Architect, QA |
| UI encounter | BossBar, PhaseIndicator, EnrageTimer, ContributionBoard, ArenaResult, ReplayViewer | **build-ui** · UIUX |

### Data model / Resource (.tres)
Mọi `*Def` load qua Database façade (không `load()` rải rác). Runtime state tách khỏi Def (rules multiplayer: Def bất biến, state có authority).

**BossDef** (Resource, `.tres`)
- `id : StringName` — khoá boss
- `display_name : String`
- `boss_type : int` — enum {MINI, REGION, DUNGEON, WORLD, EVENT, STORY}
- `region_id : StringName` — nơi spawn (liên kết RegionDef P2)
- `level : int`, `difficulty : int` — enum {NORMAL, HARD, NIGHTMARE, HELL, MYTHIC, CHAOS}
- `base_stats : Dictionary` — hp/atk/def/resist/spd (đọc theo stat schema của game/autoload/profile.gd)
- `phase_ids : Array[StringName]` — danh sách BossPhaseDef theo thứ tự
- `enrage_timer_sec : float` — 0 = không enrage
- `weak_points : Array[Dictionary]` — {`part_id`, `bonus_dmg_pct`, `on_break_effect`}
- `break_max : float` — 0 = không có break gauge
- `reward_table_id : StringName`
- `respawn_time_sec : int`
- `music_id : StringName`, `sprite_set : StringName`, `intro_text : String`

**BossPhaseDef** (Resource)
- `id : StringName`
- `trigger_type : int` — enum {HP_PCT, TIME_ELAPSED, MINION_COUNT, BREAK_FULL}
- `trigger_value : float` — vd 0.75 = HP ≤ 75%
- `skill_ids : Array[StringName]` — pool skill phase này (đè phase trước)
- `stat_mult : Dictionary` — {`atk`:1.2, `spd`:1.1} nhân so với base
- `summon_group_id : StringName` — "" nếu không summon
- `arena_hazard_id : StringName` — hazard bật khi vào phase (lava/poison/darkness…)
- `loot_bonus_pct : float`

**BossSkillDef** (mở rộng SkillDef P3, thêm field boss)
- `cast_time_sec : float` — >0 mới interrupt được
- `interruptible : bool`
- `warning_sec : float` — banner cảnh báo ultimate (BOSS.md "Meteor 5…4…")
- `select_rule : int` — enum {LOWEST_CD, HIGHEST_THREAT, ON_CLUSTER, PHASE_FIXED}
- `threat_gen : float`

**BossRuntimeState** (class, KHÔNG .tres — serialize vào save JSON)
- `boss_id, boss_def_id : StringName`
- `current_hp : float`, `current_phase_idx : int`, `current_state : StringName`
- `break_value : float`, `enrage_active : bool`, `spawn_tick : int`, `despawn_tick : int`
- `aggro_table : Dictionary` — hero_id → threat (bounded, clamp size)
- `contribution : Dictionary` — hero_id → {damage, healing, tank_time}
- `minions_alive : Array[StringName]`
- `reward_claimed : bool`, `event_state : int` — enum {ANNOUNCED, ACTIVE, WON, FAILED, COOLDOWN}

**FormationDef** (Resource)
- `id : StringName`, `display_name : String`
- `slots : Array[Vector2i]` — toạ độ lưới tương đối (KHÔNG hardcode pixel)
- `slot_buffs : Array[Dictionary]` — buff theo hàng (front/back) — vd front +def%, back +range%
- `target_bias : Dictionary` — điều chỉnh target priority theo slot

**StageDef** (Resource — node world-map "3/3")
- `id : StringName`, `region_id : StringName`, `chapter_id : StringName`
- `enemy_waves : Array[StringName]` — 1..N wave EnemyDef group
- `boss_def_id : StringName` — "" nếu stage thường
- `star_rules : Array[Dictionary]` — {`stars`, `condition`} (vd 3★ = thắng ≤ 40s, không hero bất tỉnh)
- `first_clear_reward_id : StringName`, `repeat_reward_id : StringName`

**ArenaSnapshot** (class — serialize, khớp save = network snapshot theo rules/multiplayer.md)
- `owner_profile_id : StringName`, `power_ref : int`
- `hero_ids : Array[StringName]` + per-hero: level, skill_ids, equip_ids, rune_ids, stat block đã tính sẵn (freeze để tất định)
- `formation_id : StringName`
- `mmr : int`, `captured_tick : int`

**ArenaMatchResult** (class)
- `attacker_id, defender_snapshot_id : StringName`
- `outcome : int` — enum {WIN, LOSE, TIMEOUT_WIN, TIMEOUT_LOSE}
- `duration_ticks : int`, `attacker_hp_left_pct, defender_hp_left_pct : float`
- `mmr_delta : int`, `honor_gained : int`, `replay_id : StringName`

**ReplayData** (class — serialize gọn theo rules/multiplayer.md "Network Messages: small, ID-based")
- `replay_id : StringName`, `seed : int`, `sim_version : int`
- `initial_state : Dictionary` (2 đội, formation, seed)
- `command_stream : Array[Dictionary]` — chỉ {tick, actor_id, cmd_type, target_id, skill_id} — KHÔNG lưu node/animation

### Autoload / Service
Thêm/đổi trong P4 (giữ nguyên spine autoload đã định nghĩa đầu PLAN.md):
- **WorldBossService** (autoload mới): quyết định boss-of-the-day từ `TimeService.game_time` (dùng Game Time, KHÔNG OS time — rules/multiplayer.md mục Time), quản lý cửa sổ spawn/despawn tuần, phát `EventBus.world_boss_spawned / world_boss_ended`, giữ `BossRuntimeState` hiện hành. Boss **owns state** (multiplayer.md), không duplicate.
- **ArenaService** (autoload mới): matchmaking async theo MMR-lite, nạp `ArenaSnapshot` đối thủ từ SaveManager (P4 lấy từ pool snapshot local + snapshot của chính người chơi các mùa trước; P6 thay bằng Net), chạy trận qua BattleSim, trả `ArenaMatchResult`, cộng/trừ Honor qua Economy. Quản lý quota 10 lượt/ngày (reset theo game-day).
- **MmrService** (service, không cần autoload — inject vào ArenaService): Elo rút gọn `new = old + K*(score - expected)`, K theo band; expose `predict_win_chance()`.
- **StageBattleService** (service): dựng CombatContext từ StageDef + đội hero người chơi + FormationDef, chạy headless seeded, chấm sao theo `star_rules`.
- **BattleSim** (mở rộng Battle Engine P1): thêm boss hooks (phase check, enrage tick, break, interrupt), formation buff apply, replay record hook. Vẫn tách SIM↔VIEW, damage pipeline **Damage→Crit→Def→Resist→Shield→HP** (COMBAT.md).
- **EventBus**: thêm signal `world_boss_spawned(boss_id)`, `world_boss_phase_changed(boss_id, phase_idx)`, `world_boss_ended(boss_id, event_state)`, `arena_match_finished(result)`, `stage_cleared(stage_id, stars)`. Signal không phát tần suất cao mỗi tick (rules/signal-rules.md, build-combat "no high-frequency signals").
- **Telemetry / Debug**: thêm channel boss/arena/stage (mục dưới).

### Scene / màn hình
- **WorldBossArena.tscn** — root `Node2D`; `Boss.tscn` (theo scene structure của build-boss: BossRoot CharacterBody2D + PhaseController + Components), `MinionSpawnPoints`, `HazardAreas`, `NavigationRegion2D`, `CameraBounds`. View-model: `WorldBossVM` bind từ `BossRuntimeState`.
- **BossBar.tscn** — HP bar + PhaseIndicator + EnrageTimer + BreakGauge; listen state, KHÔNG sửa boss trực tiếp (rules/ui.md, multiplayer.md UI).
- **ContributionBoard.tscn** — bảng damage/heal/tank-time (BXH sát thương demo), sort giảm dần, highlight MVP.
- **StageMapNode.tscn** — node "3/3" trên world map; `StageResultPopup.tscn` hiện sao + loot.
- **ArenaScreen.tscn** — root Control (mobile portrait): tab chọn đối thủ (MMR gần), nút Fight, hiển thị Honor + rank. View-model `ArenaVM`.
- **BattleView.tscn** (tái dùng từ P1, mở rộng) — render kết quả SIM; dùng cho cả stage, world boss xem trực tiếp, và replay.
- **ReplayViewer.tscn** — thanh timeline + tốc độ 1x/2x/4x; feed từ `ReplayPlayer` phát lại `ReplayData` (COMBAT.md Replay, PVP.md Replay System).
- Object pool (rules/performance.md, build-combat): `DamageNumber`, `Projectile`, `HitEffect`, `WarningZone`, `StatusIcon` — pool sẵn, KHÔNG instantiate trong combat.

### Task breakdown
1. **BattleSim boss-ready**: refactor Battle Engine P1 để nhận `BossRuntimeState` như một combatant đặc biệt; thêm điểm móc `on_phase_check(tick)`, `on_enrage_tick(tick)`. Giữ tất định seeded (RandomService, KHÔNG `randf()` — rules/ai.md).
2. **BossDef / BossPhaseDef / BossSkillDef** + loader qua Database; tạo 2 boss mẫu .tres (1 Region 2-phase, 1 World Boss 4-phase như Raid mẫu trong BOSS.md: Shield→Summon→ArenaBreak→Enrage).
3. **BossPhaseComponent**: đánh giá trigger (HP_PCT/TIME/MINION/BREAK) mỗi bước decision (KHÔNG mỗi frame — scheduler, rules/ai.md), phát `world_boss_phase_changed`, áp `stat_mult` + `arena_hazard_id` + swap `skill_ids`.
4. **BossSkillComponent**: chọn skill theo `select_rule` (LOWEST_CD/HIGHEST_THREAT/ON_CLUSTER/PHASE_FIXED); implement `cast_time` + `warning_sec` banner; **interrupt** khi bị hard-CC lúc casting (COMBAT.md CC, BOSS.md Interrupt).
5. **Enrage timer**: đếm theo tick từ `spawn_tick`; hết giờ → `enrage_active=true`, atk +100%/spd +50%/miễn stun (theo BOSS.md Enrage), phát telemetry.
6. **Weak-point / Break gauge**: skill trúng weak-point cộng `bonus_dmg_pct`; break đầy → stun boss + tăng damage nhận + huỷ skill đang cast; reset sau cửa sổ.
7. **BossMinionComponent**: summon theo `summon_group_id`, spawn dàn nhiều tick (KHÔNG mass-spawn 1 frame — build-boss Performance), dùng pool; minion "phải giết trước" chặn damage lên boss.
8. **BossAggroComponent**: aggro_table bounded (clamp số entry), nguồn damage/heal/taunt/proximity; tránh đổi target liên tục (rules/ai.md Target Selection).
9. **BossContributionTracker**: cộng dồn damage/heal/tank_time vào `contribution`; cập nhật theo batch (KHÔNG recalc mỗi frame).
10. **BossRewardComponent + reward-once**: chia thưởng theo contribution qua Economy sink/source; đặt `reward_claimed`, chống double qua save/load & rejoin & offline (build-boss Reward Distribution).
11. **WorldBossService + rotation**: map `day_of_week`→boss_id (7 boss BOSS.md), cửa sổ ACTIVE theo tuần, event_state machine (ANNOUNCED→ACTIVE→WON/FAILED→COOLDOWN); FAILED → hệ quả nhẹ (region danger +, boss về mạnh hơn) tạo story chứ không chỉ phạt.
12. **BossBar / ContributionBoard UI** + bind VM; WarningBanner cho ultimate.
13. **FormationDef + FormationService**: lưới slot, buff vị trí, target_bias; dùng chung stage + arena; validate slot không trùng.
14. **StageDef + StageBattleService**: node "3/3" world map; chạy headless seeded; chấm sao `star_rules`; first-clear vs repeat reward; mở Auto/Quick-Clear sau 3★ (DUNGEON.md Auto Battle).
15. **StageMapNode + StageResultPopup UI** + tích hợp world-map P2.
16. **ArenaSnapshot capture**: chụp đội phòng thủ của người chơi (freeze stat đã tính) khi kết thúc chỉnh đội; lưu qua SaveManager (version + migration).
17. **MmrService (MMR-lite)**: Elo K-band, `predict_win_chance`, clamp MMR ≥ 0.
18. **ArenaService async**: matchmaking chọn snapshot MMR gần (±band), chạy trận 90s (900 tick @10Hz) headless, timeout → so `hp_left_pct` (multiplayer.md deterministic), cập nhật MMR + Honor, sinh `ReplayData`. Quota 10 lượt/game-day.
19. **Honor economy**: source (thắng/tham gia/streak — không chỉ top1, PVP.md Ranking Rewards) + sink (đổi material/rune/cosmetic ở shop Honor); cân theo rules/economy.md & balancing.md.
20. **ReplayRecorder / ReplayPlayer**: record seed + command_stream trong SIM; ReplayPlayer phát lại **qua chính BattleSim** để đảm bảo replay == trận gốc (rules/multiplayer.md Rollback).
21. **ArenaScreen + ReplayViewer UI**: chọn đối thủ, Fight, xem replay tua 1x/2x/4x, damage/heal chart.
22. **Telemetry + Debug hooks** (task riêng, mục dưới) cho cả 3 hệ thống.
23. **Balance pass**: TTK boss 60-180s / world boss 5-15 min (balancing.md Time To Kill); crit ≤80%, dodge ≤40%; chạy simulation batch để lấy số.
24. **Tài liệu feature** theo prompts/feature.md (Architecture/Data Model/Save Model/Perf Notes) cho boss, stage, arena.

### Tests
Theo rules/testing.md, unit-testing.md, simulation.md, regression.md; case đặt tên theo mẫu Given/When/Then của build-boss & build-combat.

**Unit**
- `GivenBossHpBelowThreshold_WhenPhaseComponentTicks_ThenBossChangesPhase`
- `GivenEnrageTimerExpired_WhenTicks_ThenEnrageActivatedOnce` (không kích hoạt lại)
- `GivenSkillCasting_WhenHardCcApplied_ThenSkillInterruptedAndNoEffect`
- `GivenWeakPointHit_WhenDamageApplied_ThenBonusDamageAdded`
- `GivenBreakGaugeFull_WhenTicks_ThenBossStunnedAndTakesMoreDamage`
- `GivenBossDefeated_WhenRewardsDistributed_ThenEachParticipantReceivesRewardOnce`
- `GivenRewardAlreadyClaimed_WhenPlayerClaimsAgain_ThenClaimIsRejected`
- `GivenTwoPlayersSameMmr_WhenWin_ThenMmrDeltaSymmetricAndClamped`
- `GivenFormationBackRow_WhenBuffApplied_ThenRangeStatIncreased`

**Integration**
- `GivenWorldBossEventStarted_WhenPreparationEnds_ThenBossSpawns`
- `GivenBossTimeout_WhenNotDefeated_ThenBossEscapesAndEventFails` (event_state=FAILED, hệ quả region)
- `GivenArenaMatch90sTimeout_WhenBothAlive_ThenSideWithMoreHpWins`
- `GivenStageCleared_WhenUnder40s_ThenThreeStarsAndFirstClearRewardOnce`
- `GivenHealerContributesHealing_WhenBossDefeated_ThenHealerReceivesContributionCredit`

**Simulation** (headless, seeded — rules/simulation.md)
- Chạy 1000 trận Arena giữa các build đa dạng → phân bố winrate không có build >60% (PVP.md Anti-Meta ngưỡng), log ra Telemetry.
- Sim world boss với 200 hero + 1000 monster nearby → đo TTK & fps (build-boss Performance target).

**Regression** (rules/regression.md — golden output)
- `GivenSameSeedAndSnapshots_WhenArenaRunTwice_ThenIdenticalResultAndReplay` (tất định).
- `GivenBossSaveLoad_WhenBossInPhaseTwo_ThenPhaseAndHpAndContributionRestored`.
- Golden replay: lưu 1 ReplayData mẫu, mọi build sau phải phát lại ra cùng kết quả; nếu sim_version đổi → cảnh báo regression.

### Telemetry & Debug
**Telemetry event** (rules/telemetry.md; nuôi Balancing agent):
- Boss: `boss_spawned`, `boss_phase_changed`, `boss_skill_cast`, `boss_interrupted`, `boss_minion_spawned`, `boss_enraged`, `boss_defeated`, `boss_failed`, `fight_duration`, `participant_count`, `damage_contribution`, `reward_claimed`.
- Stage: `stage_started`, `stage_cleared`, `stage_stars`, `stage_first_clear`, `stage_ttk`.
- Arena: `arena_match_started`, `arena_match_finished` (outcome/duration/mmr_delta), `arena_timeout`, `honor_gained`, `honor_spent`, `replay_saved`. Track winrate theo build để phát hiện meta lệch (balancing.md Live Balance — không rebalance mù).

**Debug tool / cheat** (rules/debug-tools.md; theo lệnh build-boss & build-combat):
- Boss inspector: state/phase/hp/break/enrage/aggro_table/contribution/active_skills/cooldowns/minions_alive/decision_reason (rules/ai.md Debug — luôn giải thích *vì sao* boss ra quyết định).
- Lệnh: `spawn_boss`, `kill_boss`, `start_world_boss`, `end_world_boss`, `force_phase`, `set_boss_hp`, `trigger_enrage`, `break_boss`, `spawn_minions`, `clear_minions`, `show_aggro_table`, `show_contribution`, `claim_rewards`, `reset_boss_event`.
- Combat cheat: `god_mode`, `one_hit_kill`, `disable_cooldowns`, `force_critical`, `show_damage_formula`, `show_hitboxes`.
- Arena: `set_mmr <v>`, `grant_honor <n>`, `load_snapshot <id>`, `replay_last`, `dump_replay <id>`.
- Stage: `set_stars <n>`, `unlock_auto <stage>`.

### ▶ Cổng Run & Test
PASS khi tất cả quan sát được:
- **Manual (headless + view)**: `godot --headless` chạy `test_boss_simulation`, `test_combat_simulation`, arena sim 1000 trận, stage sim → exit 0, không lỗi.
- **World Boss**: `start_world_boss` → boss spawn, HP giảm → tự đổi phase đúng ngưỡng (BossBar PhaseIndicator đổi), enrage kích hoạt khi hết timer, giết boss → ContributionBoard hiện đúng top damage, reward chia 1 lần; gọi `claim_rewards` lần 2 bị từ chối.
- **Interrupt/Break**: boss cast ultimate có banner; hero hard-CC → skill bị huỷ (telemetry `boss_interrupted`); break đầy → boss stun.
- **Stage 3/3**: vào node world-map, chạy → thắng, popup hiện đúng số sao theo `star_rules`, first-clear reward chỉ nhận 1 lần, mở Auto sau 3★.
- **Arena**: chọn đối thủ MMR gần → trận chạy ≤90s auto; nếu hết giờ, bên nhiều HP% thắng; MMR & Honor cập nhật đúng dấu; xem lại ReplayViewer ra **đúng y** kết quả trận (tất định).
- **Regression**: cùng seed + snapshot chạy 2 lần → kết quả + replay byte-identical.
- **Perf** (rules/profiling.md, stress-test.md): world boss + 200 hero + 1000 monster nearby ≥ 60 fps trên mid-range; không AI trong `_process()`, không instantiate trong combat, aggro_table không phình vô hạn.

FAIL nếu: phase đổi sai ngưỡng, reward chia >1 lần, replay lệch trận gốc, arena timeout xử sai bên thắng, hoặc fps < 60 ở stress target.

### Deliverables
- ✓ Boss Engine đa phase data-driven (BossDef/BossPhaseDef/BossSkillDef) + 2 boss mẫu `.tres`.
- ✓ Cơ chế enrage timer, weak-point, interrupt, break gauge, summon minion — chạy tất định seeded.
- ✓ WorldBossService rotation tuần (7 boss theo lịch) + ContributionBoard (BXH sát thương demo) + reward-once.
- ✓ FormationDef + FormationService dùng chung stage & arena.
- ✓ Stage Battle "3/3" deterministic + chấm sao + first-clear/repeat reward + Auto sau 3★.
- ✓ ArenaService async vs snapshot, trận 90s, timeout=HP, MMR-lite, Honor source/sink.
- ✓ ReplayRecorder/Player + ReplayViewer (tua 1x/2x/4x) tất định.
- ✓ Save/load khôi phục BossRuntimeState (phase/hp/contribution) + ArenaSnapshot (version + migration).
- ✓ Telemetry đầy đủ 3 hệ thống + Debug inspector/cheat.
- ✓ Bộ test unit/integration/simulation/regression xanh; tài liệu feature theo prompts/feature.md.

### Rủi ro & giảm thiểu
- **Boss thành HP-sponge** (vi phạm BOSS.md/balancing.md): bắt buộc mỗi boss ≥1 cơ chế độc quyền (weak-point/interrupt/break) trong review; test kiểm tra phase đổi *AI/skill*, không chỉ HP.
- **Replay lệch (non-determinism)**: cấm `randf()`/`Time.get_ticks` trong SIM (rules/ai.md, multiplayer.md); mọi ngẫu nhiên qua RandomService seeded; regression golden-replay + `sim_version` bump khi đổi công thức.
- **Perf world boss + đông entity**: scheduler + batch contribution + pool + aggro_table bounded; stress-test là cổng chặn merge.
- **Meta lệch / build bất bại** (PVP.md): telemetry winrate theo build; nếu >60% → xử lý bằng Seasonal Modifier/rotation hook (chừa sẵn), KHÔNG nerf hero trực tiếp (PVP.md Balance Philosophy).
- **Honor lạm phát**: mỗi nguồn Honor phải có sink tương ứng (economy.md); giám sát qua telemetry `honor_gained`/`honor_spent`.
- **Coupling arena với local player**: dùng ArenaSnapshot + command stream ID-based ngay từ P4 để P6 chỉ cần thay nguồn snapshot bằng Net (rules/multiplayer.md: never assume local authority).
- **Scope creep sang Guild/Tournament/Cross-Server**: chốt "Ngoài phase" ở trên; chỉ chừa data hook, không implement.

---

## Phase 5 — Cốt truyện & khung Season/Event

> **Mục tiêu:** Story campaign (Prologue → Chapters 1-10 → World Arc → Abyss Arc → Final Arc) + hệ Season/Event data-driven gắn cốt truyện (tính năng đầu bảng), có World Evolution phản ứng theo outcome boss/event · **Thời lượng:** 4-6 tuần · **Phụ thuộc:** P4 (boss/stage/PvP-bot)

### Vì sao ở đây

Story và Season là lớp "keo" gắn mọi hệ thống lại thành một thế giới sống, nên chúng phải đến SAU khi các hệ thống bên dưới đã tồn tại và tất định: cần boss & stage nhiều-phase của P4 để làm boss-intro/chapter-boss/seasonal-boss; cần collection/skill/equip/rune/synergy của P3 làm phần thưởng story-unlock (theo `STORY.md` mục "Story Progression Rewards" và "Story & Gameplay Link"); cần vòng đời hero + world map của P2 để World Evolution đổi trạng thái vùng đất; cần lõi thế giới sống + Battle Engine tất định của P1. Đúng như CLAUDE.md nhấn mạnh "Never build isolated gameplay. Always build systems" — Story ở đây KHÔNG phải nội dung trang trí mà là hệ thống điều phối.

Phase này mở khoá cho P6 (online): SeasonManager + battle pass + seasonal shop + rank reset + leaderboard hook là bộ khung live-service để P6 nối Supabase (season sync, cross-server event, community event). Nó cũng khoá "meta rotation" — buff Rune/Equip/Synergy theo Season chứ KHÔNG buff thẳng hero (chống power-creep, theo `GDD.md` mục 22 và `ECONOMY.md` "Seasonal Reset").

### Phạm vi

**Trong phase:**
- StoryManager + ChapterDef/SeasonDef/EventDef data-driven qua Database façade (đã có từ P0).
- Story delivery: dialogue runner, cutscene (pixel-art slide + text), boss-intro overlay, event text; **story-unlock gate** mở tính năng theo tiến trình.
- Campaign scaffold: Prologue "Awakening" → 10 Chapter (mỗi chapter 10-20 stage, 1-2 boss, 1 hero/rune unlock) → World Arc → Abyss Arc → Final Arc. Nội dung text đầy đủ cho Prologue + Chapter 1-3 (mẫu), còn lại placeholder-data hợp lệ.
- SeasonManager + SeasonDef: mỗi Season = 1 biến dị Abyss = story arc + seasonal boss + event(s) + world-evolution + battle pass (Free/Premium, cosmetic-first) + meta rotation (buff rune/equip/synergy) + seasonal currency/shop + rank reset.
- EventManager theo `build-events` skill (tái dùng, KHÔNG viết lại): scheduler, lifecycle, modifier tạm-thời-reversible, reward chống trùng, save active events. Ở phase này chỉ hiện thực các event category cần cho Season/Story: Season, Festival, WorldBoss, Economy, Combat(MonsterFrenzy/DoubleEXP). Merchant/TownAttack đã có khung ở P2 sẽ được EventManager điều phối.
- World Evolution service: `WorldState` per-region flag đổi theo outcome (boss sống/chết, event thành/bại) → NPC dialogue, shop stock, spawn table, corruption tint.
- Battle Pass (season track Free/Premium) + Seasonal Currency + Seasonal Shop + Rank Reset service.

**Ngoài phase (làm sau — chống scope creep):**
- Online season sync, cross-server/community event, leaderboard backend → **P6**.
- Character personal questline & corruption-branch cho từng hero (STORY.md "Character Storylines") → post-P6 live-ops (chỉ để hook `story_id` sẵn).
- Guild story/Guild event, PvP season rank UI đầy đủ → gắn khi Guild có (P6+).
- Collaboration/IP event, mini-games trong event (fishing, card...) → live-ops.
- Procedural/AI-generated side quest (STORY.md "Future Expansion") → ngoài phạm vi.
- Battle pass thanh toán thật (IAP) → P6 release.

### Hệ thống xây

| Hệ thống | Mô tả | Skill/Agent .claude |
|---|---|---|
| StoryManager (autoload) | Máy trạng thái tiến trình story: prologue/chapter/arc hiện tại, cờ đã-xem, story-unlock gate; phát `EventBus` signal khi unlock | Architect + Gameplay; theo `architecture.md`, `signal-rules.md` |
| StoryDelivery (service+scene) | Runner cho dialogue/cutscene/boss-intro/event-text; SIM không phụ thuộc VIEW | `build-ui` (UI-first), UIUX + Animator |
| SeasonManager (autoload) | Vòng đời Season: start/rollover, gắn story-arc + seasonal boss + event(s) + meta rotation + battle pass + rank reset | Architect + Economy + Balancing |
| EventManager + Scheduler | Điều phối event lifecycle/overlap/priority/reward — **tái dùng nguyên `build-events`** | `build-events` (bắt buộc), AI + Economy; theo `events.md` |
| WorldEvolutionService | Đổi `WorldState` theo outcome boss/event → visuals/NPC/shop/spawn | `build-town`+`build-monster`, Gameplay; theo `world.md` |
| SeasonalBoss | Boss biến dị Abyss của season, nhiều phase | **tái dùng `build-boss`** (P4), Balancing |
| MetaRotationService | Áp buff Season lên Rune/Equip/Synergy (KHÔNG lên hero) | Balancing + Economy; theo `balancing.md`, `economy.md` |
| BattlePassService | Track Free/Premium, XP pass từ mission, reward cosmetic-first | Economy; theo `economy.md` (`ECONOMY.md` "Battle Pass") |
| SeasonalShopService + SeasonalCurrency | Currency tạm (hết hạn cuối season) + shop đổi cosmetic/material/rune | `build-loot` cho reward, Economy |
| RankResetService | Reset rank/leaderboard/seasonal progress; KHÔNG reset hero/equip/rune/story | Economy; theo `ECONOMY.md` "Seasonal Reset" |

### Data model / Resource (.tres)

**ChapterDef** (Resource, mở rộng scaffold P0)
| field | kiểu | ý nghĩa |
|---|---|---|
| id : StringName | | id chapter (vd `&"ch01_broken_kingdom"`) |
| display_name : String | | "The Broken Kingdom" |
| order_index : int | | thứ tự trong campaign |
| arc : StringName | | `&"chapter"`/`&"world"`/`&"abyss"`/`&"final"` |
| stage_ids : Array[StringName] | | 10-20 stage (StageDef từ P4) |
| boss_ids : Array[StringName] | | 1-2 boss (EnemyDef/BossDef từ P4) |
| intro_dialogue_id : StringName | | dialogue mở chapter |
| boss_intro_id : StringName | | boss-intro overlay |
| unlock_rewards : Array[Dictionary] | | `{type, id, amount}` (hero/rune/dungeon/system) |
| unlock_gate : StringName | | feature key mở khi hoàn thành (vd `&"rune_system"`) |
| region_id : StringName | | vùng world map liên quan (P2) |
| prerequisite_id : StringName | | chapter phải xong trước |

**SeasonDef** (Resource — trọng tâm phase)
| field | kiểu | ý nghĩa |
|---|---|---|
| id : StringName | | vd `&"season_of_frost"` |
| display_name : String | | "Season of Frost" |
| number : int | | số thứ tự season |
| abyss_mutation_id : StringName | | biến dị Abyss định danh season |
| duration_days : int | | 56 (8 tuần, theo `EVENTS.md` "Seasonal Events") |
| story_arc_chapter_ids : Array[StringName] | | chapter/limited-story của season |
| seasonal_boss_id : StringName | | boss biến dị (build-boss) |
| event_ids : Array[StringName] | | EventDef chạy trong season |
| meta_rotation : Dictionary | | buff rune/equip/synergy (xem MetaRotationDef) |
| battle_pass_id : StringName | | BattlePassDef của season |
| seasonal_currency_id : StringName | | vd `&"frost_shard"` |
| seasonal_shop_id : StringName | | ShopDef seasonal |
| world_evolution_rules : Array[Dictionary] | | `{trigger, condition, world_state_key, value}` |
| rank_reset_policy : Dictionary | | `{reset_rank, reset_leaderboard, keep:[hero,equip,rune,story]}` |
| visual_theme_id : StringName | | sky/lighting/music theme |
| next_season_id : StringName | | rollover kế tiếp |

**EventDef** (Resource — schema theo `build-events` "EventData", KHÔNG runtime state)
| field | kiểu | ý nghĩa |
|---|---|---|
| id : StringName | | id event |
| display_name : String / description : String | | text hiển thị |
| category : StringName | | `Season/Festival/WorldBoss/Economy/Combat` |
| priority : int | | Critical/Major/Medium/Minor/Ambient (`build-events` "Priority") |
| duration_sec / preparation_sec / cooldown_sec : float | | thời lượng (theo `events.md` "Event Duration") |
| conditions : Array[Dictionary] | | `{type, value}` (time/season/boss_defeated/monster_kill_count/random_weight/manual_debug) |
| modifiers : Array[Dictionary] | | `{target, value}` (loot_rate/gold_rate/exp_rate/monster_spawn_rate…) — tạm & reversible |
| rewards : Array[Dictionary] | | `{type,id,amount}` (không gold-only, theo `events.md` "Event Rewards") |
| currency_id : StringName | | event currency tạm (có thể trống) |
| story_dialogue_id : StringName | | text cốt truyện gắn event (limited story event) |
| visual_theme_id / music_id / notification_text | StringName/String | feedback |
| chain_next_id : StringName | | chain event kế (data-driven, `build-events` "Chain Events") |

**EventRuntimeState / EventSaveData** — dùng nguyên schema `build-events` (event_id, phase, remaining_time, progress, participants, contribution, reward_claimed, cooldown_remaining, active_modifiers). KHÔNG lưu Node/Timer/Signal/UI (theo `save-system.md`).

**BattlePassDef** (Resource)
| field | kiểu | ý nghĩa |
|---|---|---|
| id : StringName / season_id : StringName | | định danh |
| max_level : int | | vd 50 |
| xp_per_level : int | | XP mỗi bậc |
| free_rewards : Array[Dictionary] | | `{level, type, id, amount}` cosmetic/material/resource |
| premium_rewards : Array[Dictionary] | | thêm cosmetic-first, KHÔNG power (theo `ECONOMY.md` "Battle Pass") |

**MetaRotationDef** (Dictionary trong SeasonDef.meta_rotation)
- `rune_buffs : Array[{rune_id, stat, mult}]`
- `equip_buffs : Array[{set_id, stat, mult}]`
- `synergy_buffs : Array[{synergy_id, bonus}]`
- Ràng buộc validate: KHÔNG có key nào target `hero_base_stat` → chống power-creep (theo `GDD.md` mục 22 "Không buff Hero trực tiếp").

**DialogueDef / CutsceneDef** (Resource nhẹ)
- `id`, `lines : Array[{speaker, portrait_id, text}]`, `slides : Array[{image_id, text}]`, `next_action : Dictionary` (unlock/start_battle/none).

### Autoload / Service

- **StoryManager** (autoload MỚI): giữ tiến trình story trong PlayerProfile; API `get_current_chapter()`, `complete_chapter(id)`, `is_feature_unlocked(key) -> bool`, `advance_arc()`. Phát `EventBus.story_chapter_completed(id)`, `story_feature_unlocked(key)`. KHÔNG chứa logic UI.
- **SeasonManager** (đã liệt kê ở kiến trúc chung — hiện thực đầy đủ tại phase này): `start_season(def)`, `rollover()`, `get_active_season()`, `time_remaining()`. Dùng `TimeService` cho đếm ngày (offline-safe), phát `EventBus.season_started/season_ended`. Điều phối gọi MetaRotationService/BattlePassService/RankResetService/EventManager.
- **EventManager** (autoload, đã có ở kiến trúc chung — build ở phase này qua `build-events`): là nơi DUY NHẤT start/stop event (theo `events.md` "Event Manager"). Scheduler tick qua scheduler chung (KHÔNG `_process` polling — theo `build-events` "Performance").
- **WorldEvolutionService** (service, không autoload; sống dưới GameState): đọc `SeasonDef.world_evolution_rules` + outcome từ EventBus → set `WorldState[region][key]`; phát `EventBus.world_state_changed(region, key, value)`.
- **MetaRotationService / BattlePassService / SeasonalShopService / RankResetService**: service thuần data, inject qua GameState (dependency injection, theo `architecture.md`).

### Scene / màn hình

- `scenes/story/DialogueRunner.tscn` — Control + portrait TextureRect + typewriter RichTextLabel; view-model `DialogueVM` (chỉ đọc DialogueDef, phát `finished`).
- `scenes/story/CutscenePlayer.tscn` — full-screen slide + fade; skip button.
- `scenes/story/BossIntroOverlay.tscn` — banner boss + lore line trước battle (dùng data BossDef P4).
- `scenes/story/CampaignMap.tscn` — danh sách chapter/arc, node khoá/mở, gắn CampaignMapVM.
- `scenes/season/SeasonHubScreen.tscn` — tab: Story arc · Seasonal Boss · Events · Battle Pass · Seasonal Shop · Rank; VM `SeasonHubVM` bind SeasonManager.
- `scenes/season/BattlePassScreen.tscn` — track Free/Premium, thanh XP; `BattlePassVM`.
- `scenes/events/EventBanner.tscn` + `EventPanel.tscn` + `EventCountdownBadge.tscn` + `EventRewardPopup.tscn` — **tái dùng nguyên từ `build-events` folder structure**; UI chỉ listen event state, KHÔNG start event (trừ debug).
- World Evolution KHÔNG có scene riêng: nó đổi tint/NPC/shop trên scene world (P2) qua `world_state_changed`.

### Task breakdown

1. Tạo Resource class `ChapterDef`, `SeasonDef`, `EventDef`, `BattlePassDef`, `DialogueDef`, `CutsceneDef` (Typed GDScript, `@export`) + đăng ký vào Database façade; viết validator (KHÔNG hardcode giá trị — `balancing.md`, `economy.md`).
2. Viết validator `SeasonDef.meta_rotation`: assert không target hero base stat; test riêng để chống power-creep.
3. Hiện thực **StoryManager** autoload + máy trạng thái arc/chapter; lưu tiến trình vào PlayerProfile (schema version + migration theo `save-system.md`); phát signals qua EventBus.
4. Hiện thực **story-unlock gate**: `is_feature_unlocked(key)`; hook vào router UI để ẩn/hiện tính năng (rune/dungeon/pvp) theo `ChapterDef.unlock_gate` (theo `STORY.md` "Story & Gameplay Link").
5. Build **StoryDelivery**: `DialogueRunner.tscn` (typewriter, portrait), `CutscenePlayer.tscn`, `BossIntroOverlay.tscn` — dùng `build-ui`; tách SIM (state) ↔ VIEW (scene). Boss-intro nối vào flow battle P4.
6. Soạn data campaign: Prologue "Awakening" + Chapter 1 "The Broken Kingdom" (boss Black Knight, first hero Knight of Dawn — theo `STORY.md`/`WORLD.md`) + Chapter 2-3 full text; Chapter 4-10 + World/Abyss/Final Arc tạo `.tres` placeholder hợp lệ (stage/boss id trỏ P4).
7. Build **EventManager + Scheduler + lifecycle** bằng skill `build-events` (Scheduled→Announced→Preparation→Active→Ending→Reward→Cleanup→Cooldown); tuân overlap rule (1 major/2 medium/nhiều minor) + priority resolve.
8. Hiện thực **EventModifier** áp/gỡ tạm thời & reversible (áp lên loot/gold/exp/spawn qua service tương ứng); đảm bảo gỡ sạch khi event end (test `GivenEventModifierApplied_WhenEventEnds_ThenModifierRemoved`).
9. Hiện thực **EventReward + chống trùng** (reward_claimed guard; chống save/load & offline exploit — `build-events` "Reward Protection").
10. Hiện thực event save/load qua SaveManager (active events, remaining_time, progress, cooldown) — case `GivenSaveLoad_WhenEventActive_ThenRemainingTimeAndProgressRestored`.
11. Hiện thực **SeasonManager**: start/rollover theo `duration_days` dùng TimeService (offline-safe khi mở lại app); phát season signals; điều phối các service con.
12. Build **MetaRotationService**: áp `meta_rotation` khi season start, gỡ khi rollover; verify tổng power hero không đổi (chỉ rune/equip/synergy đổi).
13. Build **BattlePassService** + `BattlePassScreen.tscn`: XP pass từ event/story mission; claim reward Free/Premium; guard chống double-claim.
14. Build **SeasonalCurrency + SeasonalShopService** + shop UI: currency hết hạn khi season end (theo `economy.md` "Event Currency"/`ECONOMY.md` "Event Economy"); auto-convert/remove leftover.
15. Build **RankResetService**: reset rank/leaderboard/seasonal progress; assert KHÔNG động hero/equip/rune/story (theo `ECONOMY.md` "Seasonal Reset").
16. Build **WorldEvolutionService**: parse `world_evolution_rules`, subscribe outcome signals (boss defeated/event success/fail), set WorldState, phát `world_state_changed`; hook vào world scene P2 để đổi tint/NPC dialogue/shop stock/spawn table (theo `STORY.md` "World Evolution", `EVENTS.md` "Dynamic World Events").
17. Build **SeasonHubScreen.tscn** ghép tất cả tab; router UI-first; VM bind read-only.
18. Soạn **ví dụ 1 season đầy đủ** "Season of Frost" (`.tres`, xem mục Deliverables) như dữ liệu tham chiếu cho QA & designer.
19. Thêm telemetry + debug commands (mục Telemetry & Debug).
20. Viết test suite (mục Tests); chạy headless validate; cập nhật docs (Architecture/Data Model/Save Model theo CLAUDE.md "Documentation").

### Tests

Theo `testing.md`, `unit-testing.md`, `simulation.md`, `regression.md` (mỗi feature phải có unit/integration/simulation/regression):

- **Unit — Story:** `complete_chapter` cập nhật state đúng; `is_feature_unlocked` trả false trước gate, true sau; prerequisite chặn nhảy chapter.
- **Unit — Season:** meta_rotation validator reject buff hero base stat; seasonal currency expire = 0 sau rollover; rank reset giữ nguyên hero/equip/rune/story.
- **Unit — Event (từ `build-events` "Required Test Cases"):**
  - `GivenEventScheduled_WhenPreparationEnds_ThenEventBecomesActive`
  - `GivenEventActive_WhenDurationEnds_ThenEventMovesToRewardPhase`
  - `GivenEventRewardClaimed_WhenClaimedAgain_ThenSecondClaimRejected`
  - `GivenEventModifierApplied_WhenEventEnds_ThenModifierRemoved`
  - `GivenFestivalActive_WhenHeroMoodUpdates_ThenMoodBonusApplied`
- **Integration:** hoàn thành Chapter 1 → boss-intro → battle (Engine P4 seeded) → unlock Knight of Dawn + rune_system gate; season start → battle pass/shop/meta rotation cùng active.
- **Integration — World Evolution:** seasonal boss thua (sống) → region corruption flag on → NPC dialogue & spawn table đổi; thắng → mở region mới (theo `STORY.md` "Nếu World Boss sống → corruption; nếu hạ → mở vùng mới").
- **Simulation:** chạy tua nhanh trọn 1 season (TimeService accelerate) headless → sự kiện lên lịch đúng tần suất (`events.md` "Event Frequency"), overlap không vượt 1 major/2 medium, season rollover sạch (currency purge, meta gỡ, rank reset).
- **Simulation:** 300 hero react event (Festival→Socialize, WorldBoss→join/avoid) ở 60fps — no AI trong `_process` (theo `build-events` "Performance", CLAUDE.md "Performance Philosophy").
- **Regression:** save-load giữa event active → remaining_time & progress khớp; migration save cũ (thêm story/season block) không mất dữ liệu; event modifier không "dính" vĩnh viễn sau nhiều lần start/end (leak test).
- **Save/Load exploit:** `GivenSaveLoad_WhenEventActive_ThenRemainingTimeAndProgressRestored` + reward không claim lại được sau reload.

### Telemetry & Debug

**Telemetry** (theo `telemetry.md` + `build-events`/`economy.md` "Telemetry"): `story_chapter_started/completed`, `story_feature_unlocked`, `season_started/ended`, `event_scheduled/started/ended/duration`, `event_participants`, `event_completion_rate`, `event_failure_rate`, `event_reward_claimed`, `battlepass_level_up`, `seasonal_currency_earned/spent`, `seasonal_shop_purchase`, `world_state_changed`, `boss_participation`. Kinh tế: gom vào dashboard inflation (gold earned/spent, seasonal currency flow) để phát hiện Source>Sink (theo `ECONOMY.md` "Live Economy Dashboard").

**Debug/Cheat** (theo `debug-tools.md` + `build-events` "Debug Commands"): `start_event/end_event/force_event_phase/skip_event_time/claim_event_reward/reset_event_cooldown/show_active_events/show_event_modifiers`, `trigger_festival/trigger_world_boss`; story: `set_chapter <id>`, `unlock_feature <key>`, `complete_current_chapter`, `play_dialogue <id>`; season: `start_season <id>`, `skip_season_days <n>`, `force_season_rollover`, `set_world_state <region> <key> <value>`, `add_seasonal_currency <n>`, `set_battlepass_level <n>`. `EventInspector.tscn` (từ `build-events`) hiển thị event_id/phase/remaining/modifiers/rewards/affected_regions.

### ▶ Cổng Run & Test

**Manual (headless + build chạy được):**
- Chạy prologue → thấy dialogue typewriter + first hero unlock; vào Chapter 1 → boss-intro overlay → battle → thắng → CampaignMap mở Chapter 2, tính năng gated hiện đúng.
- `start_season season_of_frost` → SeasonHub hiện đủ tab; seasonal boss/event/battle pass/shop cùng active; sky/music theme đổi.
- `trigger_festival` → NPC react + banner + countdown xuất hiện KHÔNG cần mở menu (theo `events.md` "Visual Feedback").
- Đánh seasonal boss thua → region đổi tint corruption + NPC dialogue đổi; `skip_season_days 56` → rollover: seasonal currency = 0, meta rotation gỡ, rank reset, hero/equip/rune/story còn nguyên.

**Tự động (PASS/FAIL):**
- PASS khi toàn bộ test suite ở mục Tests xanh (unit+integration+simulation+regression) chạy headless.
- FAIL nếu: event modifier còn sót sau end; seasonal currency còn > 0 sau rollover; meta_rotation chứa buff hero base stat; reward claim lại được sau reload; story gate cho vào tính năng chưa unlock; AI event-reaction chạy trong `_process`; sim 1 season overlap vượt 1 major/2 medium event.

### Deliverables

- ✓ Resource classes + validator: `ChapterDef`, `SeasonDef`, `EventDef`, `BattlePassDef`, `DialogueDef`, `CutsceneDef` đăng ký Database.
- ✓ StoryManager autoload + story-unlock gate + tiến trình lưu trong PlayerProfile (migration ok).
- ✓ StoryDelivery: DialogueRunner / CutscenePlayer / BossIntroOverlay + CampaignMap.
- ✓ Campaign data: Prologue + Chapter 1-3 full text; Chapter 4-10 + World/Abyss/Final Arc placeholder hợp lệ.
- ✓ EventManager + Scheduler + lifecycle + modifier reversible + reward chống trùng + save/load (qua `build-events`).
- ✓ SeasonManager + MetaRotationService + BattlePassService + SeasonalShop/Currency + RankResetService.
- ✓ WorldEvolutionService nối outcome → WorldState → visuals/NPC/shop/spawn.
- ✓ SeasonHubScreen + BattlePassScreen + event UI (banner/countdown/panel/reward popup).
- ✓ **Ví dụ 1 season cụ thể — "Season of Frost"** (`.tres` tham chiếu):
  - `abyss_mutation_id = &"frost_abyss"`, `duration_days = 56`.
  - Story arc: limited-story "The Frozen Fortress" (theo `EVENTS.md` mẫu Season of Frost → Ice Queen → Frozen Fortress → Frost Rune → Winter Skin).
  - `seasonal_boss_id = &"ice_queen"` (build-boss, nhiều phase).
  - Events: `frost_festival` (Festival, mood/relationship bonus + winter decorations), `blizzard` (Weather/Combat: giảm move speed, spawn ice monster, tăng ice-loot), `double_rune_day` (Combat/Economy).
  - Meta rotation: buff Frost Rune (+ice dmg mult), buff "Frozen set" equip, buff synergy 3-Ice; KHÔNG buff hero.
  - `seasonal_currency_id = &"frost_shard"` → SeasonalShop đổi Winter Skin/avatar/frost-rune material (cosmetic-first, hết hạn cuối season).
  - Battle Pass "Frost Pass": Free (material/resource) + Premium (Winter Skin, emote) — không power.
  - World evolution: nếu Ice Queen sống hết season → Frozen North region corruption (spawn ice-elite tăng, NPC lo sợ); nếu bị hạ → mở dungeon "Frozen Fortress" + NPC ăn mừng.
  - Rank reset: reset arena rank + seasonal leaderboard; giữ hero/equip/rune/story.
- ✓ Telemetry events + debug commands + EventInspector.
- ✓ Test suite xanh (headless) + docs cập nhật (Data Model, Save Model, Gameplay Flow).

### Rủi ro & giảm thiểu

- **Power-creep qua meta rotation:** rủi ro season buff làm hero mạnh dần. → validator cứng chặn target hero base stat + test; chỉ cho buff rune/equip/synergy (GDD mục 22).
- **Event chaos / spam:** nhiều event chồng chéo phá readability. → enforce overlap rule (1 major/2 medium/nhiều minor) + priority resolve trong EventManager + sim test tần suất (`events.md`).
- **Modifier leak (buff dính vĩnh viễn):** áp/gỡ không cân xứng. → mọi modifier reversible + cleanup handler + regression leak test sau nhiều chu kỳ.
- **Reward exploit (save/reload, offline, rejoin):** → reward_claimed guard idempotent + test `ClaimedAgain_ThenRejected`; validate offline claim qua TimeService thay vì wall-clock tin cậy client.
- **Story gate lỏng lẻo:** người chơi vào tính năng chưa mở → crash/exploit. → gate tập trung ở StoryManager, router UI chỉ hỏi `is_feature_unlocked`; test âm tính.
- **Season rollover không sạch (offline dài):** app đóng qua nhiều season. → SeasonManager tính rollover theo TimeService lũy kế, xử lý nhiều rollover trong 1 lần mở; sim test skip nhiều ngày.
- **Content scale (10 chapter + arc):** dễ trượt lịch. → chỉ full-text Prologue+Ch1-3, phần còn lại placeholder-data hợp lệ; text còn lại đẩy sang live-ops (Post-Game Story theo STORY.md).
- **Coupling story↔UI:** vi phạm "no gameplay in UI". → SIM/state ở StoryManager, VIEW ở scene qua VM (CLAUDE.md Code Standards, `ui.md`).

---

## Phase 6 — LiveOps hardening · Online · Release
> **Mục tiêu:** Đạt chuẩn phát hành theo `prompts/release.md`: online đầy đủ (leaderboard/guild/async-PvP/cloud-save conflict), telemetry đầy đủ không PII, hiệu năng đạt target trên Android mid-range, chống cheat authoritative server-side, save-migration test, gate debug, release checklist + rollback + post-release monitoring. · **Thời lượng:** 6-10 tuần + backend · ongoing · **Phụ thuộc:** P5 (story/season/event framework đã ổn định — leaderboard & guild boss & PvP-bot có nội dung để phục vụ)

### Vì sao ở đây
P6 nằm cuối vì nó **hardening thứ đã tồn tại**: mọi hệ thống lõi (world sống, hero AI, combat tất định seeded, battle engine SIM↔VIEW, save atomic + migration, town, collection/gacha, boss/stage/PvP-bot P4, story/season P5) đã hoàn chỉnh và ổn định về gameplay. Không thể "làm online" một hệ thống chưa deterministic hay chưa serializable, cũng không thể "tối ưu" cái chưa đo được. P6 lấy các mảnh sẵn có — `GameService` interface + `CommandBus` (skill `build-network` đã dựng từ P1 offline-first), snapshot/diff, cloud-save hooks (skill `build-save`) — và **kích hoạt nhánh server authority**, thêm anti-cheat, telemetry đầy đủ, profiling regression gate, stress suite tự động.

Đây là phase mở khoá **vòng đời sản phẩm**: sau P6 game có thể release Soft Launch → Production, chạy LiveOps (season mới, event, leaderboard reset) mà không cần re-architect. P6 không mở khoá phase gameplay tiếp theo (đây là phase cuối trong lộ trình 7 phase), nó mở khoá **ongoing operations**.

Nguyên tắc xuyên suốt P6 (bám `rules/multiplayer.md`): giữ **offline chơi trọn vẹn** — Supabase chỉ là lớp authority/sync phủ lên trên, không phải điều kiện để game chạy. "Offline save = online snapshot", nên client SIM (Utility AI hero, battle seeded, economy source→flow→sink) vẫn là nguồn trải nghiệm; server chỉ **verify + là single source of truth** cho những gì có giá trị cạnh tranh (rank, reward, gold, guild boss HP, MMR). Mọi thứ P6 làm là "server-assisted", chưa full-authoritative — đủ để chống cheat và xếp hạng công bằng mà không đập lại kiến trúc.

### Phạm vi
**Trong phase:**
- Supabase đầy đủ: Auth (anonymous → account link), Postgres schema + RLS, **Edge Functions** cho mọi ghi có giá trị (leaderboard submit, guild boss damage, PvP snapshot exchange, reward claim). Client KHÔNG bao giờ `insert` trực tiếp vào bảng điểm/reward.
- Leaderboard: submit qua Edge Function (server verify battle replay seeded), season reset, phân trang, quanh-tôi (±N).
- Guild: create/join, role (Leader/Officer/Member/Recruit), Guild Boss shared-HP (damage tracking server-side), Guild Shop (Guild Coin), contribution — theo `docs/scripts/GUILD.md`.
- Async PvP: snapshot exchange (đội hình phòng thủ lưu server, tấn công tải snapshot đối thủ, combat replay tất định client → submit kết quả → server verify) — theo `docs/scripts/PVP.md` phần Arena/Ranked.
- Cloud save conflict resolution: upload/download, checksum, phát hiện conflict, policy (`latest_timestamp`/`highest_progress`/`manual_choice`), UI chọn tay.
- Anti-cheat authoritative: energy/time verify server-side, verify-trận (replay seed), rate limit, idempotent reward, replay protection.
- Telemetry đầy đủ (danh sách event trong `prompts/release.md` Step 7 + categories trong `rules/telemetry.md`), buffered, versioned, không PII, offline-store-then-upload.
- Perf: đạt target `rules/performance.md` (FPS≥60/min≥45, mem≤512MB, autosave<500ms, load<3s); `BenchmarkWorld.tscn` + `MetricsCollector` (`rules/profiling.md`); stress 300 hero/1000 monster (`rules/stress-test.md`).
- Save-migration test suite (`rules/regression.md` mục Save); 30-day + economy simulation (`prompts/release.md` Step 6).
- Gate/disable debug tools (`rules/debug-tools.md` + `prompts/release.md` Step 8) qua feature flag build.
- Release checklist + rollback + post-release monitoring theo `prompts/release.md`.

**Ngoài phase (làm sau — chống scope creep):**
- Guild War / Guild Dungeon / Guild Territory PvE co-op (chỉ dựng schema `guild_id`, KHÔNG implement trận war ở P6 — LiveOps sau).
- PvP real-time đồng bộ / Draft Arena / Tournament / Cross-Server Championship / Spectator live (P6 chỉ async snapshot + AI replay).
- Chat/mail thời gian thực (để LiveOps sau; nếu cần chỉ guild chat text async — tách hẳn, `rules/multiplayer.md` "Chat is isolated").
- Server-authoritative full simulation (P6 dừng ở **Server Assisted**: verify + authority cho reward/rank/economy nhạy cảm; SIM vẫn chạy client). Full authoritative để version live sau.
- Market/trading player-to-player (chỉ Guild Shop NPC-priced ở P6).

### Hệ thống xây
| Hệ thống | Mô tả | Skill / Agent .claude |
|---|---|---|
| RemoteGameService (kích hoạt) | Nhánh online của `GameService`; gửi command tới Edge Function, nhận CommandResult; fallback offline queue | `build-network`; Architect, Performance |
| SupabaseClient / Net autoload | Wrap Supabase Auth + REST + Edge Function invoke; timeout/retry/backoff; KHÔNG block main thread | `build-network`; Architect |
| LeaderboardService | Submit qua Edge `lb-submit`, fetch top/around; season key | `build-network`; Economy, Balancing |
| GuildService | create/join/leave, role, contribution, guild boss damage submit, guild shop buy | `build-network`; Gameplay, Economy |
| AsyncPvpService | lưu defense snapshot; fetch opponent; run local seeded battle; submit result cho Edge verify | `build-network`, `build-combat`; AI, Gameplay |
| CloudSaveService + ConflictResolver | upload/download snapshot, checksum, detect + resolve conflict, UI manual choice | `build-save`, `build-network`; Architect, QA |
| AntiCheatValidator (client-side pre-check + server verify) | verify energy/time, replay-seed battle verify, rate limit, idempotency, integrity checksum | `build-network`; QA, Reviewer |
| TelemetryService đầy đủ | buffer → exporter → Supabase table `telemetry_events`; versioned schema; sampling high-freq | (theo `rules/telemetry.md`); Performance, QA |
| MetricsCollector + PerfHarness | thu FPS/mem/tick, aggregate, export report, detect regression | (theo `rules/profiling.md`); Performance |
| StressTestRunner | headless chạy Level 1-4, spawn 300 hero/1000 monster, long session, save spam | (theo `rules/stress-test.md`); Performance, QA |
| ReleaseGate / FeatureFlags | build flag `is_release` tắt debug/cheat/overlay; env config endpoint | (theo `prompts/release.md`); Architect, Reviewer |
| SimulationRunner (30-day + economy) | headless tick nhanh 30 ngày, log gold in/out, inflation, progression wall | (theo `prompts/release.md` Step 6); Economy, Balancing |

### Data model / Resource (.tres) + bảng server
Client-side (thêm/mở rộng, kiểu Typed GDScript):
- **NetworkConfig.tres** (Resource): `supabase_url: String` — endpoint; `anon_key: String` — key public; `env: StringName` — `&"dev"`/`&"staging"`/`&"prod"`; `command_timeout_ms: int`; `retry_max: int`; `retry_backoff_ms: int`; `telemetry_flush_sec: float`; `enable_online: bool`.
- **PvpDefenseSnapshot** (class serializable): `profile_id: StringName`; `hero_ids: Array[StringName]`; `formation_id: StringName`; `battle_power: int`; `hero_stat_hash: String` — hash chống chỉnh; `schema_version: int`; `updated_at: int` (game-time đã ký server).
- **LeaderboardEntry** (class): `rank: int`; `profile_id: StringName`; `display_name: String` (chỉ tên hiển thị người dùng tự đặt, KHÔNG PII); `score: int`; `season_key: StringName`.
- **GuildData** (class, khớp `rules/multiplayer.md` "Guild is data"): `guild_id: StringName`; `name: String`; `level: int`; `member_ids: Array[StringName]`; `roles: Dictionary` (profile_id → StringName role); `guild_coin: int`; `boss_hp_current: int`; `boss_hp_max: int`; `boss_reset_at: int`; `contribution: Dictionary`.
- **CloudConflictResult** (class): `has_conflict: bool`; `local_meta: SaveMetadata`; `cloud_meta: SaveMetadata`; `policy_applied: StringName`; `chosen: StringName` — `&"local"`/`&"cloud"`.
- **PlayerProfile** mở rộng (từ spine giữ lại): thêm `account_id: StringName` (Supabase auth uid, rỗng nếu anonymous), `cloud_save_id: StringName`, `guild_id: StringName`, `pvp_mmr: int`, `pvp_rank: StringName`.

Server-side (Supabase Postgres — bám `rules/multiplayer.md` "single source of truth" & "identified by ID"):
- `profiles(account_id pk, display_name, created_at, last_seen)` — RLS: owner read/write own.
- `cloud_saves(account_id pk, save_blob, checksum, save_version, game_version, updated_at, play_time)` — RLS owner; write chỉ qua Edge `save-upload` (verify checksum + progress không tụt bất thường).
- `leaderboards(season_key, account_id, score, battle_seed, submitted_at, PRIMARY KEY(season_key, account_id))` — RLS: **read-only cho client**, insert/update chỉ qua Edge `lb-submit`.
- `guilds(guild_id pk, name unique, level, guild_coin, boss_hp_current, boss_reset_at)`; `guild_members(guild_id, account_id, role, contribution, joined_at)`; `guild_boss_damage(guild_id, account_id, damage, day_key)` — cộng damage chỉ qua Edge `guild-boss-hit`.
- `pvp_defenses(account_id pk, snapshot_json, stat_hash, battle_power, updated_at)`; `pvp_matches(match_id pk, attacker_id, defender_id, result, seed, mmr_delta, created_at)` — kết quả ghi qua Edge `pvp-submit` sau verify.
- `telemetry_events(event_id, session_id, anon_player_id, event_name, category, payload_json, game_version, telemetry_version, ts)` — RLS insert-only; KHÔNG chứa name/email/IP (`rules/telemetry.md` Privacy).

### Autoload / Service
- **Net** (autoload đã có từ P1, nay bật online): giữ `ConnectionState` (`OFFLINE/CONNECTING/ONLINE/DEGRADED`), sở hữu `SupabaseClient`, `RemoteGameService`, command queue offline. Emit `EventBus.net_state_changed(state)`. Mọi request async qua `HTTPRequest` node pool — KHÔNG block (`build-network` Performance: "No blocking network calls on main thread").
- **Telemetry** (autoload đã có, nay hoàn thiện exporter): `track(event_name: StringName, category: StringName, payload: Dictionary)` → buffer → flush mỗi `telemetry_flush_sec` hoặc khi buffer đầy → Edge/table. Sampling cho `movement`/`damage`/`path`; NEVER sample `boss_defeated`/`quest_completed`/`save_failed`. Budget <1% CPU, <10MB (`rules/telemetry.md`).
- **SaveManager** (đã có atomic + .bak + version + migration): thêm hook `on_after_save` → `CloudSaveService.enqueue_upload()`; `on_before_load` → check cloud conflict. Autosave vẫn async không freeze (`rules/save-system.md`).
- **SeasonManager** (đã có từ P5): thêm `leaderboard_season_key()` + phát `season_rollover` để reset bảng xếp hạng (server cron/Edge).
- **Debug** (autoload đã có): bọc toàn bộ trong `if not ReleaseGate.is_release:` — gate theo build flag.

Ví dụ offline queue + reconnect replay (Typed GDScript, ở `Net` — idempotent theo `command_id`, không block gameplay):
```gdscript
func submit(cmd: GameCommand) -> void:
    if _state == ConnectionState.ONLINE:
        _remote.execute(cmd)          # RemoteGameService → Edge
    else:
        _queue.append(cmd)            # OFFLINE: chơi tiếp bình thường
        _local.execute(cmd)           # SIM local vẫn chạy (offline-first)

func _on_reconnected() -> void:
    for cmd: GameCommand in _queue:   # server dedupe bằng command_id → không double reward
        _remote.execute(cmd)
    _queue.clear()
    Telemetry.track(&"reconnect_success", &"network", {})
```

### Scene / màn hình
- `ui/network/NetworkInspector.tscn` (chỉ dev/QA build) — node `VBox` hiển thị `mode`, `connection_state`, `latency`, `queued_commands`, `last_snapshot_version`, `cloud_save_status`, `conflicts`, `server_time_offset`, `command_failures` (theo `build-network` Debug Tools). View-model: `NetworkInspectorVM` đọc `Net` signals.
- `ui/leaderboard/LeaderboardScreen.tscn` — `ItemList`/`VBox` phân trang top + nút "quanh tôi"; VM `LeaderboardVM` (chỉ display state, `rules/multiplayer.md` UI→Command→State→UI).
- `ui/guild/GuildScreen.tscn` (tabs: Members / Boss / Shop / Contribution) + `GuildBossScreen.tscn` (thanh shared-HP, danh sách damage). VM `GuildVM`.
- `ui/pvp/ArenaScreen.tscn` (danh sách đối thủ + nút Attack) + tái dùng `BattleView` (SIM↔VIEW từ battle engine) để xem replay async; `ui/pvp/DefenseSetupScreen.tscn` đặt đội hình phòng thủ. VM `ArenaVM`.
- `ui/cloud/ConflictDialog.tscn` — hiện `local_meta` vs `cloud_meta` (play_time, updated_at, level) + 2 nút chọn (manual_choice). VM `ConflictVM`.
- `tools/BenchmarkWorld.tscn` (theo `rules/profiling.md`): town + roads + hunting zones + 300 hero + 1000 monster + 100 NPC + 50 building + boss + merchant + weather + festival + loot + combat + UI — scene đo lặp lại được.

### Task breakdown
1. **Supabase bootstrap**: tạo project (dev/staging/prod), bật Auth anonymous, tạo bảng + RLS theo schema trên; `NetworkConfig.tres` per-env; secret không commit (env var). Agent: Architect.
2. **SupabaseClient**: wrap Auth (anonymous sign-in, link account sau), REST select (leaderboard read, guild read), `invoke_edge(fn_name, payload) -> CommandResult` async qua `HTTPRequest` pool + timeout/retry/backoff. Không block main thread.
3. **Bật RemoteGameService**: implement nhánh online của `GameService` interface có sẵn; command đi qua `CommandBus` → serialize (`command_id/type/player_id/session_id/timestamp/payload/client_version/schema_version`) → Edge. Offline: queue vào `Net`, replay khi reconnect (idempotent bằng `command_id`).
4. **Edge Function `save-upload` + `save-download`**: verify checksum, chặn progress tụt bất thường (anti-cheat), trả conflict nếu `updated_at` server > local base. `CloudSaveService` gọi các hàm này.
5. **ConflictResolver + ConflictDialog**: detect conflict → default policy `highest_progress`, fallback `manual_choice` mở `ConflictDialog.tscn`. Không tự ghi đè tiến trình giá trị (`build-save`/`build-network` "Never silently overwrite").
6. **Edge Function `lb-submit`**: nhận `{score, battle_seed, replay_digest}`; server **re-run verify** trận bằng seed (battle engine tất định port sang Deno/logic-mirror hoặc verify digest) → chống điểm giả → upsert `leaderboards`. Client chỉ read.
7. **LeaderboardService + LeaderboardScreen**: fetch top N phân trang + around-me; hiển thị; refresh khi `season_rollover`.
8. **GuildService + Edge `guild-create`/`guild-join`/`guild-boss-hit`**: create (Level 20+, gold cost, name unique — `docs/scripts/GUILD.md`), role management, `guild-boss-hit` cộng damage **server-side** vào shared-HP (chống client tự trừ HP), Guild Shop buy trừ Guild Coin server-side. Contribution decay job (anti-abuse).
9. **GuildScreen + GuildBossScreen**: hiển thị members/role, thanh shared-HP boss, bảng damage, shop.
10. **AsyncPvpService**: lưu `PvpDefenseSnapshot` (kèm `stat_hash`) qua Edge `pvp-defense-set`; `fetch_opponent(mmr_range)`; chạy **battle engine seeded local** → tạo result + seed; submit Edge `pvp-submit`.
11. **Edge Function `pvp-submit`**: verify snapshot chưa bị chỉnh (so `stat_hash` với dữ liệu account đối thủ), re-run/verify replay theo seed, cập nhật `pvp_matches` + MMR + `pvp_rank`. Idempotent theo `match_id`.
12. **ArenaScreen + DefenseSetupScreen + replay**: tái dùng `BattleView` để xem async replay (SIM tất định từ seed → VIEW). Fair play: KHÔNG buff pay-to-win (`docs/scripts/PVP.md` Fair Play).
13. **AntiCheatValidator**: pre-check client (energy/time/cooldown) + mọi verify thực nằm server. Rate limit (commands/sec, reward claims, save uploads, boss join). Replay protection: reject duplicate `command_id`/`nonce`. Idempotent `ClaimRewardCommand` (grant once). Integrity checksum save.
14. **TelemetryService hoàn thiện**: exporter → `telemetry_events`; versioned schema (`telemetry_version`, `game_version`, `build`, `session_id`, `anon_player_id`); buffer + periodic flush + sampling; offline-store-then-upload. Emit đủ event list (xem mục Telemetry).
15. **MetricsCollector + BenchmarkWorld.tscn**: thu `fps_avg/min`, `frame_time`, `memory`, `node_count`, `ai_tick`, `combat_tick`, `navigation_tick`, `save_time`, `load_time`, `pool_hit_rate`; aggregate + export `profiling/reports/` (summary.md, metrics.json, csv). Baseline build.
16. **StressTestRunner (headless)**: Level 1→4 theo `rules/stress-test.md`: 10→300→500 hero, 100→1000→3000 monster, spawn 1000 hero/30s, long session 12/24/72h (giả lập tick nhanh), save spam autosave/5s/1h, event storm. Failure conditions: FPS<30, memory leak, deadlock, negative gold, duplicate ID, pool exhausted.
17. **Perf optimization pass**: profile → fix theo priority `rules/profiling.md` (algorithm→frequency→allocation→pool→data structure). Đảm bảo scheduler + pooling; AI KHÔNG trong `_process()`; đạt target.
18. **SimulationRunner 30-day + economy**: headless mô phỏng 30 ngày (offline+active mix), log gold in/out, inflation, craft/repair count, richest/poorest hero, progression wall check. Verify no infinite gold, no reward dup, no runaway inflation (`prompts/release.md` Step 6).
19. **Save-migration test suite**: sinh save version 1→N, verify migrate không mất item/equipment/progress; round-trip equality; corrupted/missing-field/duplicate-ID recovery từ .bak.
20. **ReleaseGate + FeatureFlags**: build flag `is_release` → disable dev panel, debug commands, cheats, debug overlay, verbose logs, force-event tools, profiler overlay (`prompts/release.md` Step 8). Endpoint/telemetry đúng env (Step 9).
21. **Release runbook**: script chạy full `prompts/release.md` (13 step) → output verdict; rollback plan (previous stable build, save backup policy, feature flags, hotfix branch); post-release monitoring dashboard (crashes, save failures, FPS, inflation, boss success rate, retention).

### Tests
Theo `rules/testing.md`, `rules/unit-testing.md`, `rules/simulation.md`, `rules/regression.md`:
- **Unit — network** (`build-network` Required Test Cases): `GivenClaimRewardCommand_WhenExecutedTwice_ThenRewardGrantedOnce`; `GivenCommandSerialized_WhenDeserialized_ThenPayloadMatches`; `GivenModifiedSaveChecksum_WhenCloudUploadAttempted_ThenIntegrityCheckFails`; `GivenSnapshotDiff_WhenOnlyGoldChanges_ThenDiffContainsOnlyEconomyChange`.
- **Unit — save** (`build-save`): `GivenSaveVersionOne_WhenLoaded_ThenMigrationToCurrentVersionRuns`; `GivenCorruptedCurrentSave_WhenLoadRequested_ThenPreviousBackupLoads`; `GivenDuplicateItemIds_WhenValidateSave_ThenValidationFails`; `GivenRewardAlreadyClaimed_WhenSaveLoad_ThenRewardCannotBeClaimedAgain`.
- **Integration — cloud conflict**: `GivenLocalSaveNewerThanCloud_WhenConflictDetected_ThenConflictPolicyApplies`; `GivenDisconnected_WhenCommandSubmitted_ThenCommandQueued`; `GivenReconnect_WhenPendingCommandsExist_ThenCommandsReplaySafely`.
- **Integration — PvP verify**: `GivenTamperedDefenseSnapshot_WhenPvpSubmit_ThenServerRejects`; `GivenSameSeed_WhenReplayOnClientAndServer_ThenResultMatches` (deterministic, seeded — `rules/multiplayer.md` Deterministic).
- **Integration — leaderboard**: `GivenForgedScore_WhenLbSubmit_ThenServerVerifyRejects`.
- **Simulation** (`rules/simulation.md`, seeded RandomService, không phụ thuộc real time/render): 30-day progression → no wall, no infinite gold; economy source↔sink cân bằng; offline cap respected.
- **Stress** (`rules/stress-test.md`): 300 hero + 1000 monster @≥60fps (min≥45); 1000 nav request đồng thời; save file 1/10/50/100MB round-trip; long session không leak.
- **Regression** (`rules/regression.md`): mỗi bug LiveOps → test tối thiểu, deterministic, lưu `tests/regression/<system>/`, ghi `docs/bugs/regression-log.md`. Bắt buộc cho: save corruption, gold/item duplication, reward dup online, offline reward abuse, migration break, AI deadlock, perf regression (FPS>10%, mem>15%, tick>20%).
- **CI gate**: PR chạy unit + save + economy-exploit + AI-deadlock + data-validation; nightly chạy simulation + performance + long-running (`rules/regression.md` CI Rules). Release bị chặn nếu bất kỳ Critical/Save/Economy/crash/migration regression fail.

Ví dụ regression test (Typed GDScript, minimal, deterministic):
```gdscript
# Bug ID: BUG-06xx  System: Economy(Online)  Severity: Critical
# Cause: Edge lb-submit chấp nhận score không verify seed.
# Expected: score không khớp replay-seed bị từ chối.
func test_given_forged_score_when_lb_submit_then_rejected() -> void:
    var seed := 12345
    var real_score: int = _run_seeded_battle(seed).score
    var forged := real_score * 100
    var result: CommandResult = _edge_lb_submit(seed, forged)
    assert_eq(result.code, CommandResult.REJECTED_VERIFY)
```

### Telemetry & Debug
**Telemetry event thêm** (khớp `prompts/release.md` Step 7 + categories `rules/telemetry.md`): `session_started`, `session_ended`, `hero_level_up`, `hero_died`, `quest_completed`, `building_upgraded`, `item_obtained`, `gold_earned`, `gold_spent`, `boss_spawned`, `boss_defeated`, `event_started`, `event_ended`, `save_completed`, `load_completed`, `error_occurred`. Network (từ `build-network`): `connection_state`, `command_sent`, `command_failed`, `command_latency`, `sync_duration`, `conflict_detected`, `cloud_save_upload`, `cloud_save_download`, `reconnect_success`, `reconnect_failed`, `anti_cheat_flag`. Save (`build-save`): `save_failed`, `migration_completed`, `migration_failed`, `checksum_failed`, `recovery_used`, `offline_progression_applied`. Performance: `fps`, `memory`, `ai_tick`, `combat_tick`, `pool_usage` (sampled). **Versioned, buffered, không PII** (`rules/telemetry.md` Privacy: never name/email/IP).

**Debug tools thêm** (theo `rules/debug-tools.md` + `build-network`/`build-save`), TẤT CẢ gate sau `ReleaseGate.is_release`:
- Network: `simulate_disconnect`, `simulate_reconnect`, `force_cloud_upload`, `force_cloud_download`, `clear_command_queue`, `show_pending_commands`, `simulate_conflict`, `validate_save_integrity`.
- Save: `save_now`, `run_migration`, `corrupt_save_test`, `show_save_diff`, `simulate_offline`.
- Telemetry: `view_event_stream`, `export_logs`, `replay_session`, `clear_buffer` (`rules/telemetry.md` Debug).
- Perf: `NetworkInspector.tscn`, debug overlay FPS/mem/tick/pool.
- `prompts/release.md` Step 8: release build phải TẮT toàn bộ mục trên + profiler overlay + verbose log.

### ▶ Cổng Run & Test
PASS khi (quan sát được, cả manual lẫn tự động):
- **Perf (headless `BenchmarkWorld.tscn`, 300 hero/1000 monster)**: `fps_avg ≥ 60`, `fps_min ≥ 45`, `memory_peak ≤ 512MB`, `autosave < 500ms`, `load < 3s`, không allocation/AI trong `_process()` (grep + profiler xác nhận). FAIL nếu bất kỳ ngưỡng `rules/profiling.md` Regression Detection vượt.
- **Online**: sign-in anonymous OK; submit leaderboard qua Edge → điểm hiện đúng, forged score bị từ chối; guild create/join → role đúng, guild-boss-hit trừ shared-HP server-side; async PvP: đặt defense → attack opponent → replay xem được, tampered snapshot bị reject; cloud conflict → `ConflictDialog` hiện đúng 2 meta, chọn tay áp dụng đúng.
- **Offline trọn vẹn**: rút mạng → game chơi bình thường, command queue; reconnect → replay idempotent, không double reward.
- **Save-migration**: load save version 1→N không mất item/equipment/progress; corrupt current → recover từ .bak, không crash.
- **Simulation**: 30-day + economy chạy hết, no infinite gold / no reward dup / no runaway inflation / no progression wall (log verdict).
- **Stress**: Level 1→4 survive không crash/leak/deadlock; 1000 nav request hoàn tất; save 100MB round-trip nguyên vẹn.
- **Release gate**: build `is_release=true` → mọi debug/cheat/overlay/profiler TẮT (kiểm tra thủ công + assert); endpoint = prod env.
- **CI**: unit + regression + save + economy-exploit + AI-deadlock xanh; nightly simulation + perf xanh. Release bị chặn nếu có Critical/Save/Economy/crash/migration regression fail (`rules/regression.md` Release Rules).

FAIL bất kỳ mục nào ở trên = không release (khớp `prompts/release.md` Release Blockers).

### Deliverables
- ✓ Supabase project (dev/staging/prod) + schema + RLS + Edge Functions (`save-upload/download`, `lb-submit`, `guild-create/join/boss-hit`, `pvp-defense-set/submit`).
- ✓ `RemoteGameService` bật, offline queue + reconnect replay idempotent.
- ✓ LeaderboardService + `LeaderboardScreen.tscn` (submit server-verified).
- ✓ GuildService + `GuildScreen.tscn` + `GuildBossScreen.tscn` (shared-HP server-side, guild shop).
- ✓ AsyncPvpService + `ArenaScreen.tscn` + `DefenseSetupScreen.tscn` + replay (seeded, fair-play).
- ✓ CloudSaveService + ConflictResolver + `ConflictDialog.tscn`.
- ✓ AntiCheatValidator (energy/time/verify-trận server-side, rate limit, idempotency, replay protection, integrity).
- ✓ TelemetryService đầy đủ (event list Step 7, versioned, không PII, buffered, offline-then-upload).
- ✓ MetricsCollector + `BenchmarkWorld.tscn` + baseline report; perf đạt target.
- ✓ StressTestRunner headless (Level 1-4) + report.
- ✓ SimulationRunner 30-day + economy report.
- ✓ Save-migration test suite + regression suite + CI gate + `docs/bugs/regression-log.md`.
- ✓ ReleaseGate/FeatureFlags tắt debug; release runbook (13 step `prompts/release.md`) + rollback plan + post-release monitoring dashboard.

### Rủi ro & giảm thiểu
- **Server authority phá tính tất định combat** (client SIM vs server verify lệch): giữ battle engine 100% seeded, tách SIM↔VIEW; verify server dùng CÙNG seed + CÙNG data-driven `.tres` digest; test `GivenSameSeed_WhenReplayOnClientAndServer_ThenResultMatches`. Nếu port logic sang Deno tốn kém → dùng **replay digest verify** thay vì re-simulate đầy đủ ở P6.
- **Network làm tụt FPS / block gameplay**: mọi request async qua `HTTPRequest` pool, no JSON parse trong hot loop, no full snapshot mỗi frame (`build-network` Performance). Telemetry budget <1% CPU, buffered, không ghi trực tiếp từ gameplay (`rules/telemetry.md`).
- **Cloud conflict ghi đè tiến trình**: default `highest_progress`, luôn giữ .bak + backup policy, manual_choice khi mơ hồ; test conflict policy.
- **Cheat qua client insert trực tiếp**: RLS chặn write bảng nhạy cảm, MỌI ghi có giá trị qua Edge Function verify (`rules/multiplayer.md` Security "Never trust client"); rate limit + idempotency + integrity checksum.
- **Alt/guild farming abuse** (`docs/scripts/GUILD.md` Anti-Abuse): contribution decay, cooldown rời guild, activity detection server-side.
- **Scope creep online** (Guild War/PvP real-time/market): khoá phạm vi ở "Ngoài phase"; P6 chỉ Server-Assisted + async; các mảng lớn để LiveOps sau.
- **Save migration hỏng khi live** (blocker theo `prompts/release.md`): bắt buộc migration test 1→N + round-trip trước mọi release; rollback plan có previous stable build + save backup.
- **Debug tool lọt release**: ReleaseGate assert ở CI (grep `Debug.`/cheat call ngoài gate) → chặn build nếu phát hiện.

---

## Phụ lục A — Thiết kế hệ Season ↔ Story (Abyss engine)

> Spec kỹ thuật cho dev + designer. Hiện thực ở **P5** (Story campaign + Season/Event framework), nhưng schema `SeasonDef`/`ChapterDef`/`EventDef` phải được scaffold sẵn ở P0 (data-driven Resource `.tres` qua `Database` façade) để P1–P4 không phải refactor. Phụ lục này KHÔNG lặp lại kiến trúc autoload/Battle Engine ở đầu PLAN.md — chỉ tham chiếu. Mọi live-content tuân `.claude/rules/events.md` và TÁI DÙNG skill `build-*` (không viết lại loop/scheduler/save).

### A.0 Nguyên tắc nền & chuẩn hoá tên (đọc trước)

- **Nguồn sự thật lore**: `docs/scripts/STORY.md` + `WORLD.md`. Có mâu thuẫn tên: WORLD.md ghi lục địa "Asteria" / Ma Vương "Azrath"; CLAUDE.md + brief chốt "Azerath" / thực thể "Abyss" / vương quốc đổ nát "Kingdom of Ashes". **Quyết định chuẩn hoá**: lục địa = **Azerath**; thực thể phản diện meta = **The Abyss** (Vực Thẳm); Ma Vương cổ đại bị phong ấn = **Azrath** (một *avatar/ý chí* của Abyss). Alias cũ ("Asteria") chỉ giữ trong lore-text làm tên cổ. Toàn bộ `id`/`enum` dùng tên chuẩn hoá.
- **Abyss không phải content, Abyss là DIRECTOR** (đạo diễn). Nó không được code cứng; nó được *cấu hình* qua `SeasonDef` và diễn giải bởi `SeasonManager`. Đây là điểm khác biệt cốt lõi so với "season = gói asset mới".
- **Rule bắt buộc** (`.claude/rules/events.md`): (1) chỉ `EventManager` được start/stop event — gameplay system KHÔNG tự khởi event; (2) event có lifecycle `Scheduled→Announced→Preparation→Active→Ending→Reward→Cooldown`; (3) event *temporary* nhưng *hậu quả có thể permanent* (World Evolution); (4) mọi event **data-driven**, cấu hình không cần đổi code; (5) hỗ trợ Debug Force Start/End/Skip Time; (6) multiplayer-ready (shared state/contribution/ranking). Abyss engine là *tầng trên* của EventManager, không thay thế nó.
- **Không power-creep**: theo GDD §22 + ECONOMY "Seasonal Reset". Season xoay *meta* bằng buff Rune/Equipment/Synergy/Dungeon/World-modifier, KHÔNG buff chỉ số Hero trực tiếp. Xem §A.6.

---

### A.1 Mô hình Abyss như "meta-entity" (Director)

Abyss là một *thực thể phản ánh trạng thái game* (STORY.md: "thực thể phản ánh meta game"). Về mặt kỹ thuật nó là một **finite-state director** sống trong `SeasonManager` (autoload), có 4 quyền năng — mỗi quyền năng map thẳng vào một hệ có sẵn:

| Quyền năng Abyss | Diễn giải kỹ thuật | Hệ tiêu thụ |
|---|---|---|
| **Spawn Boss** | inject `EnemyDef` (tag `abyss_corrupted`) vào bảng spawn của region/dungeon theo `SeasonDef.boss_schedule` | Battle Engine (EnemyDef), World Boss rotation (WORLD.md) |
| **Corrupt Hero** | áp `CorruptionModifier` lên `HeroInstance` (tạm thời, per-season) → mở nhánh skill/rune tối, có thể "mất tích" theo Hero Event | HeroInstance, Skill/Rune synergy (P3), Hero Events (`.claude/rules/events.md`) |
| **Reshape Dungeon** | override `RegionDef`/dungeon spawn table + tileset variant + weather + loot table theo `world_modifiers` | RegionDef, Dungeon system (GDD §16), Weather Events |
| **Drive Events** | phát các `EventDef` theo cadence trong `SeasonDef.event_calendar`; quyết định *branch* chain-event dựa trên `WorldState` | EventManager (KHÔNG bypass) |

**Abyss Intensity (AI-độc-lập, tất định)** — Abyss có một biến số duy nhất điều phối "độ dữ dội": `abyss_intensity ∈ [0.0, 1.0]`, tính tất định (seeded, KHÔNG random mỗi frame) từ:

```
abyss_intensity = clamp01(
    base_from_chapter_progress          # story arc đi càng sâu, Abyss càng mạnh
  + w_world_state * corruption_score    # WorldState corrupt nhiều → intensity tăng
  - w_victory   * server_victory_score  # server đánh bại boss/event thành công → giảm
  + w_calendar  * seasonal_ramp(day)     # ramp theo lịch season (leo dần tới finale)
)
```

`abyss_intensity` được **cache và chỉ recompute khi có event trigger** (boss chết, chapter clear, day rollover từ `TimeService`) — KHÔNG chạy trong `_process()` (tuân mục tiêu 300 hero/1000 monster @60fps → scheduler-driven). Intensity điều chỉnh: spawn rate boss corrupted, xác suất corrupt hero, độ mạnh world-modifier, và tần suất event minor.

**Vòng phản hồi (feedback loop) — đây là "sống"**: hành động cộng đồng/người chơi → `WorldState` đổi → `abyss_intensity` đổi → Abyss director đổi hành vi (spawn/corrupt/reshape) → tạo event mới → người chơi phản ứng. Loop này khép kín trong `SeasonManager`, mọi bước đi qua EventBus (không system nào gọi trực tiếp system khác).

---

### A.2 Cấu trúc Story Arc (bám STORY.md "storyflow1")

```
Prologue  →  Chapter Arc (1–10)  →  World Arc  →  Abyss Arc  →  Final Arc  →  Post-game Seasonal Arcs
```

| Giai đoạn | Nội dung | Vai trò Abyss | Nơi hiện thực |
|---|---|---|---|
| **Prologue** | "Awakening" — tỉnh dậy ở Kingdom of Ashes, không ký ức, Hero đầu tiên xuất hiện. Dạy gameplay lõi. | Dormant (intensity ≈ 0.05); chỉ "nứt bầu trời" làm hook | P1 (tutorial), text P5 |
| **Chapter Arc (1–10)** | Mỗi chapter: 10–20 stage, 1–2 boss, 1 Hero/Rune mới, 1 dungeon mới (STORY §Chapter System). VD Ch.1 "The Broken Kingdom": Abyss tấn công Valoria, King mất tích, Hero=Knight of Dawn, Boss=Black Knight (corrupted). | Abyss gieo corruption cục bộ theo region; boss = guardian/tướng bị tha hoá | P5 campaign |
| **World Arc** | Corruption lan ra world map (7 vùng WORLD.md); mở World Boss rotation; World Evolution bắt đầu ảnh hưởng persistent. | Abyss reshape nhiều region cùng lúc; intensity leo | P5 (dựa world map P2) |
| **Abyss Arc** | "Abyss War" — toàn server, boss xuất hiện liên tục, guild hợp tác toàn server (STORY §Endgame). | Abyss ở đỉnh; Corrupt Hero mở rộng; multi-timeline (Light/Abyss/Broken) lộ diện | P5 + P6 (online) |
| **Final Arc** | STORY "final1": Abyss Core awakens → World collapse → Hero sacrifice arc → Final battle (Azrath avatar). | Abyss dồn toàn lực; kết quả set `WorldState` vĩnh viễn cho hậu-game | P5 finale |
| **Post-game Seasonal Arcs** | Sau main story, world tiếp tục evolve; **mỗi Season = một arc hậu-game** (mutation mới của Abyss, cross-server, vùng đất mới theo WORLD §Future). | Abyss "mutate": mỗi season một biến thể mới, không reset progress người chơi | P5→P6, live-ops vĩnh viễn |

**Quan hệ Season ↔ Arc**: main story (Prologue→Final) là *xương sống tuyến tính* ship dần qua các bản cập nhật. **Season là container live-ops chồng lên trên**: một season có thể *mở* một chapter mới của main arc, HOẶC là một *post-game seasonal arc* độc lập (mutation). `SeasonDef.arc_link` nối season với `ChapterDef`/`arc_id` tương ứng.

---

### A.3 `SeasonDef` schema đầy đủ

Resource `.tres`, load qua `Database` façade, hot-swap không cần rebuild (tuân rule data-driven). Kiểu là GDScript typed.

| Field | Kiểu | Bắt buộc | Mô tả |
|---|---|---|---|
| `id` | `StringName` | ✔ | Định danh duy nhất, vd `season_of_frost` |
| `display_name` | `String` | ✔ | Tên hiển thị: "Season of Frost" |
| `season_number` | `int` | ✔ | Số thứ tự (1..n); dùng cho ordering & catch-up |
| `arc_link` | `StringName` | ✔ | ID arc/`ChapterDef` mà season này thúc đẩy (`""` nếu post-game standalone) |
| `story_hook` | `String` | ✔ | Câu hook 1–2 dòng hiển thị màn intro |
| `intro_cutscene` | `String` (path) | – | Path cutscene/dialogue resource (Story Delivery, STORY.md) |
| `cadence_weeks` | `int` | ✔ | Độ dài (8 tuần chuẩn EVENTS.md; brief chốt 2–3 tháng → cho phép 8–12) |
| `start_utc` | `String` (ISO) | ✔ | Thời điểm start; `TimeService` là nguồn thời gian duy nhất |
| `abyss_profile` | `AbyssProfile` (sub-res) | ✔ | Cấu hình director: xem bảng dưới |
| `boss_schedule` | `Array[BossSpawnEntry]` | ✔ | Danh sách boss + điều kiện/lịch xuất hiện |
| `event_calendar` | `Array[EventCalendarEntry]` | ✔ | Lịch phát `EventDef` (daily/weekly/seasonal) |
| `world_modifiers` | `Array[WorldModifier]` | ✔ | Reshape dungeon/region/weather/loot |
| `new_content` | `SeasonContent` (sub-res) | ✔ | refs Hero/Boss/Dungeon/Rune/Skin mới (EVENTS §Seasonal) |
| `battle_pass` | `BattlePassDef` (sub-res) | ✔ | Free+Premium track; chỉ cosmetic/material/convenience (ECONOMY) |
| `season_currency` | `SeasonCurrencyDef` | ✔ | Currency tạm, hết hạn cuối season (ECONOMY "Event Economy") |
| `meta_shift` | `MetaShiftDef` (sub-res) | ✔ | Cách xoay meta không power-creep (xem §A.6) |
| `world_evolution` | `Array[EvolutionRule]` | ✔ | outcome→WorldState delta (xem §A.5) |
| `leaderboards` | `Array[StringName]` | – | IDs leaderboard mùa (Boss Damage / Tower / Arena / Guild) |
| `catch_up` | `CatchUpDef` | – | Bonus quest / event-EXP / fast story cho người vào muộn |
| `archive_on_end` | `bool` | ✔ | true → story/cutscene vào Archive replay (EVENTS §Replay) |
| `seasonal_reset` | `SeasonResetDef` | ✔ | Chỉ reset Rank/Leaderboard/Season Currency/Season Progress (ECONOMY) |
| `save_version` | `int` | ✔ | Version cho migration save (spine SaveManager) |

**`AbyssProfile` (sub-resource)** — cấu hình director:

| Field | Kiểu | Mô tả |
|---|---|---|
| `theme_id` | `StringName` | Biến thể/mutation Abyss của mùa (`frost`, `plague`, `void`...) |
| `intensity_weights` | `Dictionary` | `{w_world_state, w_victory, w_calendar}` cho công thức §A.1 |
| `base_intensity` | `float` | Intensity khởi điểm (0..1) |
| `corrupt_hero_pool` | `Array[StringName]` | Hero-def eligible bị Corrupt; kèm rate scale theo intensity |
| `reshape_targets` | `Array[StringName]` | RegionDef IDs được phép reshape trong mùa |
| `escalation_curve` | `Curve` | `seasonal_ramp(day)` — ramp intensity theo ngày, đỉnh trước finale |

**`BossSpawnEntry`**: `{ enemy_def: StringName, spawn_kind: enum(World/Raid/Season/Hidden), schedule: enum(Daily/Weekly/OnIntensity/OnChapterClear), min_intensity: float, region: StringName, phases: int }`.

**`EventCalendarEntry`**: `{ event_def: StringName, cadence: enum(Daily/Weekly/Seasonal/Festival/Community), weekday_mask: int, chain_next: StringName }` — `event_def` được phát QUA `EventManager` (không bypass).

**`WorldModifier`**: `{ target_region: StringName, tileset_variant: StringName, weather: enum, spawn_table_override: StringName, loot_table_override: StringName, ai_mood_shift: float, revert_on_season_end: bool }`.

**`MetaShiftDef`**: xem §A.6.

---

### A.4 Season MẪU hoàn chỉnh — **Season 4: "Frostfall of the Broken Crown"**

Tổng hợp EVENTS "Season of Frost" + WORLD "Frozen North" (Ice Titan/Frost Dragon) + STORY Abyss. Đây là ví dụ *thực thi được* cho `season_frostfall.tres`.

| Thuộc tính | Giá trị |
|---|---|
| `id` | `season_frostfall` |
| `season_number` | 4 |
| `arc_link` | `chapter_07_frozen_throne` (đẩy World Arc) |
| `story_hook` | *"Băng giá không đến từ mùa đông — nó đến từ vết nứt Abyss. Ngai vàng Frozen North đã đóng băng cùng vị vua đã chết."* |
| `cadence_weeks` | 10 (≈2.5 tháng) |
| `abyss_profile.theme_id` | `frost` |

**Story hook chi tiết**: Abyss "nứt bầu trời" trên **Frozen North** (WORLD §5). Ice Titan cổ đại — vốn là *guardian ngủ yên* — bị Abyss corrupt thành **Frost Dragon "Glacius the Fallen"** (boss mùa). Corruption lan: NPC town đổi thoại (co ro, đóng cửa shop — EVENTS §Town Reaction), weather toàn map chuyển Snow/Blizzard.

**Boss (`boss_schedule`)**:
- `frost_wraith` — Elite spawn, Daily, `min_intensity 0.2`, region Frozen North.
- `ice_titan_awakened` — Raid boss, Weekly, `min_intensity 0.4`, 3 phases.
- `glacius_fallen` — **Season Boss**, `OnIntensity ≥ 0.85` (leo dần tới tuần 8), World-scale, 4 phases. Đây là "corrupt guardian" của Abyss.

**Event (`event_calendar`)** — tuân cadence EVENTS §Live Operations:
- Daily: `frost_gold_rush`, `double_rune_frost`.
- Weekly: `blizzard_boss_rush`, `frozen_endless_tower`, `guild_expedition_north`.
- Festival: `midwinter_festival` (cosmetic-only: skin/mount/emote — không bán power).
- Community: `server_thaw_1M` (server giết 1M frost-monster → mở khu ẩn "Glacier Vault").
- Chain: `blizzard → road_frozen → merchant_delayed` (chain-event `.claude/rules/events.md`).

**World-change (`world_modifiers`)**: Frozen North + biên Valoria đổi `tileset_variant=snow`, `weather=Blizzard`, loot table thêm Frost drops, `ai_mood_shift=-0.15` (hero dễ "cold/mệt" → tăng nhu cầu về thành nghỉ, khớp Utility AI). `revert_on_season_end=true` cho vùng biên, `false` cho hậu quả cốt lõi (xem §A.5).

**Battle Pass**: Free+Premium, 60 tier. Reward: Winter Skin, Frost avatar frame, material, season currency, convenience (vé tăng tốc). KHÔNG hero độc quyền, KHÔNG chỉ số vượt trội (ECONOMY/GDD §23).

**Season Currency**: `snowflake` — chỉ tiêu ở "Frostfall Shop" (skin, artifact fragment, rune material). Hết hạn khi season kết thúc → quy đổi phần dư sang soft-material theo tỷ giá (chống mất trắng, tránh FOMO gắt — EVENTS §Design Principles).

**Meta shift (`meta_shift`)**: mùa này **buff Frost Rune synergy + Ice-element equipment set + "Frozen Ground" dungeon modifier** (địch bị slow, hero Ranger/Mage lên kèo). KHÔNG buff chỉ số Ice Mage trực tiếp. Kết quả: Ice/Control comp lên meta *một mùa*, hết mùa modifier revert (xem §A.6).

**Meta shift bổ sung (cadence)**: mỗi 2–3 tháng đổi theme (§A.7). Mùa kế `season_5_dragon_continent` (WORLD §Future) sẽ xoay meta sang Dragonkin/skill-damage — comp Frost hết "bệ đỡ", về giá trị nền → tự nhiên xoay không cần nerf.

---

### A.5 World Evolution mechanic (outcome → World State)

Bám STORY §World Evolution + EVENTS §Dynamic World Events + rule "event temporary, consequence permanent". `WorldState` là một **struct persistent** trong `PlayerProfile` (local) + đồng bộ Supabase P2+ cho phần server-wide.

**`WorldState` (persistent, versioned trong save)**:

| Field | Kiểu | Ý nghĩa |
|---|---|---|
| `corruption_by_region` | `Dictionary[StringName→float]` | 0..1 mỗ vùng; feed `abyss_intensity` |
| `regions_unlocked` | `Array[StringName]` | Vùng đã mở (World Evolution mở khu mới) |
| `regions_lost` | `Array[StringName]` | Vùng bị quái chiếm (outcome thất bại) |
| `bosses_defeated` | `Array[StringName]` | Server/account victory log |
| `npc_dialogue_state` | `Dictionary` | Trạng thái thoại NPC theo outcome (Town Reaction) |
| `shop_unlocks` | `Array[StringName]` | Shop/vật phẩm mới mở do event |
| `timeline_alignment` | `enum(Light/Abyss/Broken)` | Nhánh timeline hiện tại (STORY multi-timeline) |
| `evolution_log` | `Array[EvolutionEvent]` | Lịch sử thay đổi (audit + replay archive) |

**`EvolutionRule` (trong `SeasonDef`)**: `{ trigger: enum(BossDefeated/BossSurvived/EventSuccess/EventFail/GuildWarOutcome/CommunityGoalMet), source_id: StringName, effect: enum(UnlockRegion/CorruptRegion/ShiftTimeline/ChangeNPC/OpenShop/RevertModifier), payload: Dictionary, persistent: bool }`.

**Ví dụ (khớp STORY "Nếu World Boss sống → map corruption; nếu bị hạ → mở vùng mới")**:
- `glacius_fallen` **bị hạ** → `UnlockRegion: glacier_vault` (vùng ẩn hậu-game) + `corruption_by_region[frozen_north] -= 0.4` + timeline nghiêng `Light`. `persistent=true` → tồn tại sau season.
- `glacius_fallen` **sống hết mùa** (community fail) → `CorruptRegion: frozen_north (=1.0)` + NPC panic dialogue + shop đóng + timeline nghiêng `Abyss`. Vùng "bị chiếm" cho tới khi arc/event sau giải phóng.

**Quy tắc kỹ thuật**:
1. Chỉ `EvolutionRule` được ghi `WorldState`; system khác chỉ *đọc*. Ghi phát qua EventBus (`world_state_changed`).
2. Mọi thay đổi persistent phải **reversible bằng content sau** (không dead-end): dead-end phá live-ops dài hạn.
3. `WorldState` versioned trong save JSON atomic + `.bak` + migration (spine SaveManager) — không được để save cũ crash khi thêm field.
4. Phần server-wide (community/guild) là **shared state** (rule Multiplayer Ready) → nguồn sự thật là Supabase (P2+); offline dùng snapshot cuối, reconcile khi online (đảm bảo "chơi offline trọn vẹn").

---

### A.6 Xoay meta KHÔNG power-creep

Nguyên tắc gốc (GDD §22, §26; ECONOMY): *"Không buff Hero trực tiếp. Chỉ buff Rune/Equipment/Synergy/Dungeon."* Season xoay meta bằng cách **đổi ngữ cảnh chiến đấu**, không cộng dồn sức mạnh tuyệt đối.

**`MetaShiftDef` schema**:

| Field | Kiểu | Mô tả |
|---|---|---|
| `featured_rune_synergies` | `Array[StringName]` | Rune synergy được "spotlight" mùa này (buff hiệu lực *chỉ trong mùa*) |
| `featured_equip_sets` | `Array[StringName]` | Set trang bị theo theme mùa |
| `dungeon_modifiers` | `Array[DungeonModifier]` | VD "Frozen Ground: enemy -20% speed" — đổi kèo, không đổi stat hero |
| `world_battle_rules` | `Array[BattleRuleMod]` | Modifier áp *đều cho cả hai phe* (element resonance, terrain) → cân bằng đối xứng |
| `rotation_scope` | `enum(SeasonOnly/Persistent)` | Mặc định `SeasonOnly` → tự revert cuối mùa |
| `power_budget_check` | `bool` | Bật gate: nội dung mới phải nằm trong power-band hiện tại (Telemetry gác) |

**Cơ chế chống creep**:
1. **Rotation, không stacking**: buff synergy/set là *SeasonOnly* → hết mùa hiệu lực về nền. Comp mạnh mùa này KHÔNG mạnh vĩnh viễn → không cần nerf hero (tránh phá build người chơi).
2. **Symmetric battle rules**: `world_battle_rules` (terrain/element resonance) áp cho cả monster lẫn hero → thay đổi *chiến thuật* chứ không *sức mạnh tuyệt đối*. Đây là cách Draft/Formation (GDD §10,18) vẫn quyết định thắng thua.
3. **Content mới trong power-band**: Hero/Rune/Equip mùa mới phải rơi trong dải sức mạnh của content cũ (không "vượt trội độc quyền" — GDD §23). `power_budget_check` + Telemetry (Hero Usage/Win Rate) là hàng rào tự động; nếu một Hero/set thống trị >X% pick/win → flag để designer điều chỉnh *modifier* (không sửa base stat).
4. **Seasonal Reset chỉ reset thi đấu** (ECONOMY): Rank/Leaderboard/Season Currency/Season Progress reset; Hero/Equipment/Rune/Story **không** reset → người chơi không mất tài sản, whale không "mua đứt" meta.
5. **Battle Pass/Event chỉ cosmetic/material/convenience** → tiền không mua sức mạnh (ECONOMY Monetization, EVENTS Economy Rules).

**Ví dụ vòng đời meta**: S4 Frost → Ice/Control top. S5 Dragon Continent → Dragonkin/skill-damage top, Frost modifier revert. S6 Heaven Realm → Support/Holy top. Mỗi comp có "mùa của nó"; nền tảng cân bằng đối xứng giữ tất cả Hero *đều dùng được* (GDD "không tồn tại Hero mạnh nhất").

---

### A.7 Lịch Live-ops (daily / weekly / seasonal) — do `EventManager` + `SeasonManager` điều phối

Tuân EVENTS §Live Operations + §Event Scheduler (max 1 Major / 2 Medium / vài Minor cùng lúc; tránh spam). `TimeService` là nguồn thời gian; `EventManager` là *chủ* mọi start/stop; `SeasonManager` cấp lịch từ `SeasonDef.event_calendar` và điều phối Abyss director.

| Nhịp | Nội dung (data-driven `EventDef`) | Reset | Điều phối |
|---|---|---|---|
| **Daily** | Gold Rush / Double EXP / Double Drop / Free Summon / Hero Trial (EVENTS §Daily). Abyss minor: Elite Spawn, Monster Frenzy scale theo `abyss_intensity`. | 00:00 UTC (TimeService) | EventManager phát theo `weekday_mask`; daily quest reset |
| **Weekly** | Boss Rush / Endless Challenge / Guild Expedition / Arena Championship / Treasure Hunt (EVENTS §Weekly). World Boss rotation 7 ngày (WORLD): Mon Ancient Dragon … Sun "Azrath's Avatar". | Mon 00:00 UTC | Rotation table trong SeasonDef; leaderboard tuần |
| **Seasonal (2–3 tháng)** | Season arc: Hero/Boss/Dungeon/Rune/Skin/Story mới; battle pass; season currency; meta shift; finale boss `OnIntensity`. | Cuối `cadence_weeks` → Seasonal Reset (§A.6.4) + Archive story | SeasonManager: escalation curve, world evolution, catch-up |
| **Festival (theo lịch thực)** | New Year/Lunar/Halloween/Christmas/Summer (EVENTS §Festival) — cosmetic-only, chồng lên season đang chạy nhưng KHÔNG override Major slot. | Tự kết thúc | EventManager, tách currency riêng |
| **Community/Guild** | Server-goal (giết N quái, thu Crystal) → trigger World Evolution. Shared state (Supabase P6). | Theo mục tiêu | EventManager + Net autoload |

**Ràng buộc scheduler (kỹ thuật)**:
- Không có AI/event tick trong `_process()`. Event & Abyss recompute là **scheduler-driven** (timer bucket + on-trigger), khớp mục tiêu 300 hero/1000 monster @60fps.
- **Persistence** (rule Event Persistence): running events + remaining time + progress + reward-state + `WorldState` + `abyss_intensity` cache đều lưu trong save (versioned). Reload phải khôi phục đúng pha lifecycle.
- **Catch-up** (EVENTS §Catch-Up + ECONOMY): người vào muộn nhận bonus quest / event-EXP x / fast-forward story tới điểm cộng đồng, không bị bỏ xa; nhưng end-game vẫn cần đầu tư.
- **Debug** (rule bắt buộc): `SeasonManager`/`EventManager` phải expose Force Start/End, Skip Time (qua TimeService override), Set Intensity, Spawn Event, Inspect WorldState — cho QA/designer test season mà không chờ lịch thực.
- **Visual/Notify** (rule): mỗi event/season đổi Music/Sky/Lighting/NPC/Particles + notify Before/Ending-soon/Reward-ready; người chơi nhận biết không cần mở menu.

---

### A.8 Trách nhiệm module & tái dùng skill `build-*` (checklist P5)

- `SeasonManager` (autoload, đã liệt kê ở kiến trúc chung): giữ Abyss director + `abyss_intensity` + escalation; đọc `SeasonDef` qua `Database`; ra lệnh QUA `EventManager`/EventBus, không tự spawn.
- `EventManager`: chủ lifecycle event (rule) — dùng skill `build-*` sẵn có cho event loop/scheduler/persistence thay vì viết lại.
- `WorldState`: struct trong `PlayerProfile`; ghi qua `EvolutionRule`; save atomic + `.bak` + migration (spine SaveManager, KHÔNG viết lại I/O).
- `SeasonDef`/`ChapterDef`/`EventDef`/`EnemyDef`: Resource `.tres` data-driven qua `Database` façade — scaffold field ở P0, đổ nội dung ở P5.
- Battle finale/boss phases: chạy trên Battle Engine tick-loop tất định (seeded) đã định nghĩa — season chỉ *cấu hình* EnemyDef/phase, không fork engine.
- Telemetry: feed power-budget check (§A.6.3) + economy dashboard (ECONOMY) để cân bằng meta không creep.

**Định nghĩa hoàn thành (P5, phần season↔story)**: (1) `SeasonManager` chạy được 1 season mẫu end-to-end headless (Debug Skip Time qua đủ 6 pha lifecycle); (2) `abyss_intensity` tất định & repro[ducible với cùng seed; (3) World Evolution ghi/đọc `WorldState` bền qua save/reload + migration; (4) meta shift revert đúng cuối mùa; (5) tất cả nội dung phát qua EventManager, 0 lần gameplay-system tự start event (assert trong test).

---

## Phụ lục B — Kỷ luật sản xuất (xuyên suốt)

Theo `CLAUDE.md` + `.claude/rules/`, các trụ chất lượng được **scaffold từ P0** và lớn dần, không dồn cuối dự án. Mỗi feature (theo PR checklist trong CLAUDE.md) phải kèm **Test + Telemetry + Debug tool + Doc**.

| Trụ | Rule | Làm liên tục từ | Nội dung |
|-----|------|-----------------|----------|
| Testing & Simulation | `testing.md`, `unit-testing.md`, `simulation.md` | P0 (GUT harness) | Unit cho math/save; integration cho loop; **simulation** cho combat/economy; regression cho bug đã fix |
| Save & Migration | `save-system.md` | P0 (v2) | Atomic + `.bak` + version; **migration test round-trip** mỗi lần đổi schema |
| Performance | `performance.md`, `profiling.md`, `stress-test.md` | P1 (profile sớm) | Scheduler + pooling; stress **300 hero/1000 monster**; target FPS≥60/min≥45, mem≤512MB, autosave<500ms, load<3s |
| Telemetry | `telemetry.md` | P0 (stub) | Event list chuẩn (session/level/quest/economy/boss/error…), **không PII** |
| Economy safety | `economy.md`, `balancing.md` | P2 | Sim chống: infinite gold · reward duplication · negative currency · runaway inflation · dominant exploit |
| Debug & Release | `debug-tools.md`, `prompts/release.md` | P0 (stub) → P6 (gate) | Debug/cheat chỉ build internal/QA; disable trước release; rollback + post-release monitoring |

**Chiến lược test xuyên suốt:** manual run-test gate mỗi phase (mục "Cổng"); unit test sớm cho math dễ vỡ (damage, affix roll, xp curve, save round-trip/migration); **simulation test** cho hệ nổi lên (Utility AI, offline accrual, economy 30 ngày); debug toggles tiết kiệm hàng giờ test.

---

## Phụ lục C — Công thức combat placeholder (đặt trong `BalanceConfig.tres`)

`COMBAT.md` chỉ cho **thứ tự pipeline**, không cho công thức. Đề xuất placeholder *tunable* (mọi hằng số nằm trong data, không hardcode) để P0 chốt và P6 cân bằng bằng simulation:

| Bước | Công thức đề xuất | Ghi chú |
|------|-------------------|---------|
| Sát thương gốc | `raw = ATK * skill_mult` (magic dùng `MATK`) | `skill_mult` theo `SkillDef` |
| Giảm bởi giáp | `dmg = raw * 100 / (100 + max(0, DEF - PEN))` | `PEN` = penetration; magic dùng `MDEF/RES` |
| Chí mạng | `if rand < CRIT_RATE: dmg *= CRIT_DMG` (mặc định 1.5) | seeded RNG |
| Né/trượt | `if rand < clamp(EVA - ACC, 0, cap): miss` | một số skill không né được |
| Shield | trừ shield trước HP; shield không hồi HP | cộng dồn/ghi đè tuỳ loại |
| Hút máu | `heal_attacker = dmg_dealt * LIFESTEAL` | |
| Nhịp đánh | `attack_interval = base_interval / (1 + SPEED/100)` | Speed cao → đánh nhanh → hồi mana nhanh |
| Mana | +X khi đánh thường, +Y khi nhận đòn; **Ultimate khi đầy** | `Skill Haste` giảm cooldown active |
| DoT | Burn/Poison/Bleed: `%HP hoặc flat` mỗi tick | true/percent damage riêng |

> **Nguyên tắc cân bằng (theo `balancing.md`):** không buff sát thương trực tiếp — chỉnh cooldown/mana/AI/buff-duration/target-priority. Battle Power chỉ tham khảo, không quyết thắng thua.

---

## Phụ lục D — Chỉ mục Resource (data-driven)

| Resource | Giới thiệu ở | Field chính |
|----------|--------------|-------------|
| `HeroDef` | P1 | id, name, class_role, subclass, race, element, rarity, base StatBlock, growth, skill_ids[], portrait |
| `SkillDef` | P1→P3 | id, type(passive/active/ultimate), target_rule, mana, cooldown, scaling_stat, effect, status |
| `EnemyDef` | P1 | id, StatBlock, ai_profile, loot_table_id, sprite |
| `BuildingDef` | P1→P2 | id, name, levels[](cost, effect, unlock), service_type |
| `RegionDef` | P2 | id, name, level_range, unlock_req, spawn_table, energy_cost |
| `ItemDef` | P3 | id, slot, rarity, base_stats, affix_pool, set_id, enhance_curve |
| `RuneDef` | P3 | id, slot(core/1-4), set, main_stat, sub_stats |
| `TalentDef` | P3 | id, branch, nodes[] |
| `LootTable` | P1→P3 | entries[](item_id, weight, chance) |
| `ChapterDef` | P5 | id, arc, stages[], unlocks, boss_id, story_beats |
| `SeasonDef` | P5 | id, arc, boss_id, event_ids[], world_change, battle_pass, currency, meta_mods, cadence |
| `EventDef` | P5 | id, type, schedule, reward_table, shop, currency |
| `BalanceConfig` | P0 | các hằng số công thức (Phụ lục C) |

---

## Phụ lục E — Việc cần chốt & Glossary

### Cần xác nhận (không chặn P0)
1. **Open-world vs stage:** "xem trận" = xem hero auto-hunt ở Bãi Săn mở (đúng CLAUDE.md "no mission instance"); stage "3/3" là chế độ phụ — xác nhận.
2. **Death/retire:** CLAUDE.md có "die/retire"; ta chốt no-permadeath → chết = bất tỉnh, "retire theo danh vọng" để P5+.
3. Năng lượng-lá gate cái gì · team size (5 đánh / 4 expedition?) · ai vận hành Supabase · công cụ AI-art + license · bản Godot chính xác.

### Glossary
- **Bãi Săn (Hunting Ground):** vùng open-world hero tự roam & auto-đánh quái.
- **Battle Engine:** module giải combat headless, tất định (seeded, tick-loop).
- **Utility AI:** AI chấm điểm goal cạnh tranh, hành vi nổi lên.
- **Offline accrual:** tính thưởng theo thời gian vắng mặt (có clamp trần).
- **Abyss:** thực thể lore điều khiển meta → sinh Season/boss/event (Phụ lục A).
- **SeasonDef:** Resource đóng gói một mùa (arc + boss + event + battle pass + meta shift).
- **Spine:** phần code tái dùng từ slice cũ (save/event/database/profile-math).

---

## Tham chiếu
- Master: [`CLAUDE.md`](CLAUDE.md) · Rules: [`.claude/rules/`](.claude/rules/) · Skills: [`.claude/skills/`](.claude/skills/) · Agents: [`.claude/agents/`](.claude/agents/)
- Design bible: [`docs/scripts/`](docs/scripts/)
- Ảnh demo tham chiếu: `demo.png` (Thành Chính) · `demo2.png` (Bãi Săn) · `7360b652-*.png` (World map / stage / PvP / Sự Kiện)
