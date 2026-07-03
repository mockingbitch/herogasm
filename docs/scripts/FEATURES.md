# FEATURES.md

# Danh mục Chức năng — sắp theo Timeline người chơi

> **Master backlog để thiết kế chi tiết dần.** Sắp theo thứ tự người chơi *gặp* trong game (không phải thứ tự code).
> Mỗi dòng: chức năng · mô tả 1 câu · **trạng thái** · doc/hệ thống liên quan.

## Cách dùng
- **⬜ Chưa (greenfield)** = hàng đợi thiết kế + build sắp tới. **🟡 Một phần** = có data/stub nhưng thiếu runner/UI/nội dung. **✅ Đã có** = P1–P6 đã build (headless-test xanh).
- Timeline (T0→T13) cũng gần đúng là **thứ tự nên thiết kế/build**. Cluster greenfield lớn nhất = **T1/T2/T7** (cửa trước) → đã gói vào `docs/PHASE7.md`.
- Khi thiết kế chi tiết 1 chức năng → tạo/ghi vào doc riêng của nó (cột cuối), cập nhật trạng thái ở đây.

---

# T0 — Nền tảng & Khởi động (trước khi vào chơi)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Save/Load atomic | Ghi/đọc save + `.bak` + checksum | ✅ | SaveManager v7 (`save-system.md`) |
| Migration phiên bản save | Nâng save cũ v1→N không mất data | ✅ | SaveManager `_migrate` |
| Offline progression | Tính thưởng khi offline, trần ≤80% | ✅ | PlayerProfile / `balancing.md` |
| Cloud save + conflict | Đồng bộ đám mây, giải xung đột | ✅ | CloudSaveService (P6) |
| Splash / Title screen | Màn mở app, chạm để vào | ⬜ | — |
| Settings (âm thanh/đồ hoạ/ngôn ngữ) | Màn cài đặt | ⬜ | `ui.md` |
| Localization (i18n) | Tách chuỗi, đa ngôn ngữ | ⬜ | (hiện hardcode VN) |

---

# T1 — Lần Mở Đầu / Cold Open (0–15 phút)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| **Tạo Lãnh Chúa** | Tên + chân dung + huy hiệu | ⬜ | PHASE7 S0/S4 · FLOW A |
| Prologue cutscene | Đoạn mở đầu cốt truyện | 🟡 | DialogueDef có, runner ⬜ |
| **Dialogue Runner + View** | Chạy thoại/cutscene + UI | ⬜ | PHASE7 S1 · `STORY.md` |
| Tặng hero đầu tiên | Hero kịch bản, dễ dùng | ⬜ | PHASE7 S4 |
| Trận auto đầu (có dẫn) | Dạy "xem, không điều khiển" | ⬜ | PHASE7 S4 |
| **Triệu hồi đầu đảm bảo** | x10 free, ≥1 hero hiếm | ⬜ | PHASE7 S4 (gacha ✅) |
| Sắp đội hình đầu | 5 hero + vị trí | ⬜ | PHASE7 SF |
| Điều phối New-Player Flow | Nối các bước cold-open | ⬜ | PHASE7 S4 |

---

# T2 — Tân Thủ / Onboarding (Lord 1–15)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| **Chuỗi nhiệm vụ tân thủ** | Progressive disclosure, mỗi bước mở 1 tính năng | ⬜ | PHASE7 S3 · FLOW B |
| Feature-unlock gating | Ẩn tính năng chưa mở khoá | 🟡 | StoryManager.features ✅, gate UI ⬜ |
| Tutorial overlay/highlight | Mũi tên trỏ + prompt | ⬜ | PHASE7 S3 |
| **Tốt nghiệp → Sổ Mục Tiêu** | Lord15+đủ lõi → bỏ tân thủ | ⬜ | PHASE7 S3 · FLOW C |

---

# T3 — Thành Sống & Vòng Lặp Lõi (living world)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Hero AI tự trị (Utility) | Goal cạnh tranh, tự quyết | ✅ | `ai.md` (HeroGoalEvaluator) |
| AI Scheduler | Tick-budget, không AI trong `_process` | ✅ | `performance.md` |
| FSM hero | idle/travel/hunt/rest/buy/repair/heal/train | ✅ | hero.gd |
| 7 Building + dịch vụ | inn/market/blacksmith/training/alchemy/kitchen/guild | ✅ | `economy.md` |
| Nâng cấp building | Cost curve, hard-cap idle | ✅ | EconomyService |
| Field-hunt + spawner | Hero roaming đánh quái tự động | ✅ | Monster/Spawner |
| Vòng đời hero | fatigue/injury/mood/KO (no-permadeath) | ✅ | HeroInstance |
| World Map (region/zone) | Gating theo level + sao | ✅ | WorldMap · `world.md` |
| Expedition idle | Phái hero đi zone, resolve offline | ✅ | ExpeditionService |
| **Lord Level + Đặc Ân** | Cấp tài khoản + buff tiện ích no-P2W | ⬜ | PHASE7 S0 |
| Camera (zoom/pan) | Điều khiển camera | ✅ | CameraController |
| NPC schedule / dân thành | NPC đi lại, lịch sinh hoạt | ⬜ | `world.md` |
| Day/Night + thời tiết | Chu kỳ ngày đêm, weather ảnh hưởng | ⬜ | `world.md`/`events.md` |

---

# T4 — Đội Hình & Chiến Đấu

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Battle Engine tất định | Tick 10Hz, seeded, SIM↔VIEW | ✅ | `COMBAT.md` |
| Damage pipeline | Dmg→Crit→Def→Resist→Shield→HP | ✅ | DamageFormula |
| Formation (hàng + buff) | Front/Mid/Back, buff hàng | ✅ (team=3) | FormationDef |
| **Nâng team 3 → 5** | Đội hình 5 slot | ⬜ | PHASE7 SF · TEAMBUILD |
| **Loadouts nhiều đội** | Lưu nhiều preset, overlap OK | ⬜ | PHASE7 SF · TEAMBUILD |
| **Deploy-lock hero** | 1 hero 1 chỗ tại 1 thời điểm | 🟡 | expedition-busy ✅, tổng quát ⬜ |
| Synergy race/class | Aura theo count | ✅ (cần retune) | TEAMBUILD |
| **Coalition (cổ tức đa dạng)** | +stat theo số tộc khác nhau | ⬜ | TEAMBUILD (cần code) |
| **Synergy soft-cap + validator + sim** | Chứng minh cân bằng band | ⬜ | TEAMBUILD |
| **Skill-kit hero trong engine** | Active/Ultimate/mana/CD/status(Burn/Stun/Shield) | 🟡 | SkillDef (boss) ✅, hero-kit hoãn · `SKILLS.md` |
| Replay tất định | Phát lại trận | ✅ | ReplayData/Player |

---

# T5 — Sưu Tập & Nâng Cấp Hero

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Gacha triệu hồi | Banner + pity soft/hard + dup→shard | ✅ | `HERO.md` |
| Hero Level / XP | Lên cấp, đường cong | ✅ | HeroInstance |
| Trang bị 8 ô | Roll affix, enhance, set-bonus | ✅ | `EQUIPMENT.md` |
| Rune (core+4) | Main/level-unlock/resonance | ✅ | `RUNE.md` |
| Talent tree + respec | Chọn nhánh, reset phí gold | ✅ | `RUNE.md` |
| Awakening | Shard-gated, +stat + swap passive/ult | ✅ | `ECONOMY.md` Soul Stone |
| Collection / Codex | Đánh dấu sở hữu/đã thấy | ✅ | — |
| Hero shards | Mảnh ghép hero (dup + boss) | ✅ | PlayerProfile |
| **Pet** | Hỗ trợ (không đánh trực tiếp) | ⬜ | GDD §15 |
| **Hero personal questline** | Cốt truyện riêng từng hero | ⬜ | QuestCategory.CHARACTER · `STORY.md` |
| **Hero relationships** | Bạn/thù/hôn nhân ảnh hưởng hành vi | ⬜ | `ai.md`/GDD |
| Ascension/Ascend cấp cao | Bậc tiến hoá sau awaken | ⬜ | `ECONOMY.md` |

---

# T6 — Nội Dung PvE (mục tiêu tuần/mùa)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Story Campaign | Prologue→Ch1-10→World/Abyss/Final Arc | ✅ | StoryManager · `STORY.md` |
| Story Boss | Boss cuối chapter | ✅ | `BOSS.md` |
| Stage 3/3 | Trận formation, chấm sao | ✅ | StageDef |
| **World Boss** | Đa phase, break/enrage, xoay ngày | ✅ | WorldBossService |
| **Ancient/Season Boss** | Trigger quest/shrine, drop legendary | 🟡 | boss ✅, trigger ⬜ |
| **Raid Dungeon** | Đa boss, offline solo + assist bot | ⬜ | PHASE7 S6 · `DUNGEON.md` |
| **Resource Dungeon** | Gold/EXP/Crystal/Material/Awaken | ⬜ | `DUNGEON.md` |
| **Equipment/Rune Dungeon** | Farm đồ/rune theo ngày | ⬜ | `DUNGEON.md` |
| **Endless Tower** | Leo tầng vô hạn, reset season | ⬜ | `DUNGEON.md` |
| **Elite Dungeon** | Khó cao, drop epic | ⬜ | `DUNGEON.md` |
| **Challenge Dungeon** | Luật riêng (mage-only/no-heal/modifier) | ⬜ | `DUNGEON.md` |
| Hidden Boss / Hidden Room | Bí mật, khám phá | ⬜ | `BOSS.md`/`DUNGEON.md` |
| Dungeon objective phi-combat | Escort/Protect/Survive | ⬜ | `DUNGEON.md` |

---

# T7 — Nhịp Ngày/Tuần (giữ chân)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| **Hệ Nhiệm Vụ** | Daily/Weekly/Milestone/Achievement | ⬜ | PHASE7 S2 · FLOW D |
| **Điểm hoạt động → Rương** | Đủ điểm mở rương ngày/tuần | ⬜ | PHASE7 S2 |
| Daily/Weekly reset | Reset qua TimeService | ⬜ | PHASE7 S2 (TimeService ✅) |
| Login rewards | Thưởng đăng nhập | ⬜ | `EVENTS.md` |
| **Minigame: Câu Cá** | Timing bar, thưởng trần-ngày | ⬜ | PHASE7 S5 |
| **Minigame: Rèn Nhịp** | Nhấn nhịp, +% enhance | ⬜ | PHASE7 S5 |
| Minigame khác (Xúc xắc/Đào kho báu) | Thêm dần | ⬜ | `EVENTS.md` |
| Daily rotation (dungeon/event) | Hôm nay khác hôm qua | 🟡 | world-boss rotation ✅, dungeon ⬜ |

---

# T8 — Cạnh Tranh & Xã Hội (offline-first)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Đấu Trường (Arena bot) | Async, snapshot, MMR + Honor | ✅ | ArenaService · `PVP.md` |
| Leaderboard | Xếp hạng (offline vs bot / online thật) | ✅ | LeaderboardService (P6) |
| Guild (hội) | Create/join/role | ✅ | GuildService · `GUILD.md` |
| Guild Boss | Shared-HP, damage cộng dồn | ✅ | `BOSS.md`/`GUILD.md` |
| Guild Shop / Tech / Quest | Cửa hàng + công nghệ guild | 🟡 | shop ✅, tech/quest ⬜ |
| **Guild War** | PvP guild vs guild | ⬜ | out-of-phase · `GUILD.md` |
| **PvP real-time / Draft-Ban** | Chọn/cấm hero mỗi trận | ⬜ | `PVP.md` |

---

# T9 — Season / Sự Kiện / LiveOps

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Khung Season | Meta rotation + currency + shop + rank reset | ✅ | SeasonManager · `EVENTS.md` |
| Meta rotation (anti-creep) | Buff rune/equip/synergy, không hero base | ✅ | MetaRotationValidator |
| Event lifecycle | Scheduled→Active→Reward→Cooldown | ✅ | EventManager |
| Battle Pass | Free/Premium track (cosmetic-first) | ✅ | BattlePassService |
| Seasonal Shop | Đổi seasonal currency | ✅ | SeasonalShopService |
| World Evolution | Kết cục boss/event đổi vùng đất | ✅ | WorldEvolutionService |
| Festival/Collab/Community event | Nội dung theo mùa/lịch | 🟡 | khung ✅, nội dung ⬜ |
| Event Dungeon / Event Boss | Độc quyền theo event | ⬜ | `EVENTS.md`/`DUNGEON.md` |
| Event Shop / Currency hết hạn | Tiền tệ event tạm | 🟡 | seasonal ✅, event-riêng ⬜ |

---

# T10 — Kinh Tế & Cửa Hàng (xuyên suốt)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Tiền tệ đa loại | Gold/Diamond/Crystal/Essence/Honor/Guild/Event/Ancient/Soul | ✅ | `ECONOMY.md` |
| Ví + router thưởng | `grant_reward` chung | ✅ | PlayerProfile |
| Chợ NPC (mua/bán/sửa) | Market building | ✅ | `economy.md` |
| Repair durability | Sửa đồ (gold+material sink) | ✅ | Blacksmith |
| Enhance / Upgrade gear | Nâng cấp trang bị | ✅ | EquipmentService |
| **Crafting đầy đủ** | Công thức + material → item | ⬜ | `ECONOMY.md` |
| **Salvage / Recycle** | Đồ cũ → material/dust | ⬜ | `ECONOMY.md` |
| **Premium Shop / IAP** | Skin/pass/tiện ích (no-P2W) | ⬜ | `ECONOMY.md` |
| Inflation control / sinks | Giám sát source↔sink | ✅ | EconomySimRunner (P6) |
| **Auction / Player Market** | Trade giữa người chơi | ⬜ | out-of-phase |

---

# T11 — Hậu Game (endgame)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Endless Tower | Leo vô hạn | ⬜ | `DUNGEON.md` |
| Difficulty Mythic/Chaos | Bậc khó cao (AI+mechanic, không HP) | ⬜ | `DUNGEON.md`/`BOSS.md` |
| **Achievements** | Thành tựu dài hạn | ⬜ | PHASE7 S2 (achievement cat) |
| Collection completion | Hoàn thành codex | 🟡 | codex ✅, thưởng ⬜ |
| Titles / Cosmetics / Avatar frame | Trang trí (no power) | 🟡 | cosmetics dict ✅, UI ⬜ |
| Hero retire / danh vọng | Nghỉ hưu theo danh vọng | ⬜ | (đã chốt hoãn) |

---

# T12 — Lớp Online (offline-first → sync)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Net / command queue / reconnect | Offline queue, replay idempotent | ✅ | NetManager (P6) |
| Anti-cheat server-assisted | Verify trận/stat/progress | ✅ | AntiCheatValidator |
| Online arena/guild/leaderboard | MockBackend mirror Edge Function | ✅ | (logic) `multiplayer.md` |
| **Backend thật (Supabase + Edge)** | Provision + HTTP adapter | ⬜ | ops · PHASE6 §6 |
| **Network UI screens** | Leaderboard/Guild/Conflict UI | ⬜ | PHASE6 §6 |
| Cross-server / real-time raid | Tương lai | ⬜ | out-of-phase |

---

# T13 — Hạ Tầng & Sản Xuất (xuyên suốt)

| Chức năng | Mô tả | TT | Doc/Hệ |
|---|---|---|---|
| Debug console + tools | Lệnh spawn/skip/inspect (gate release) | ✅ | `debug-tools.md` |
| Telemetry | Event buffered + sampling, no PII | ✅ | `telemetry.md` |
| Performance/scheduler/pooling | 300 hero/1000 monster @60fps | ✅ (khung) | `performance.md` |
| Stress test / Economy sim | Test tải + bất biến kinh tế | ✅ | `stress-test.md` (P6) |
| ReleaseGate | Tắt debug ở release build | ✅ | PHASE6 |
| **Audio (SFX/Music)** | Âm thanh thật | 🟡 | AudioManager stub |
| **Pixel art / sprite thật** | Thay placeholder | 🟡 | `pixel-art.md` (SpriteLib) |
| **Animation** | Idle/walk/attack/skill... | ⬜ | `character-asset-pipeline.md` |
| **UI/UX polish + theme** | Art hoá panel | 🟡 | `ui.md` (theme.tres) |
| Notifications / Push | Nhắc quay lại | ⬜ | — |

---

# Tóm tắt hàng đợi greenfield (ưu tiên theo timeline)

1. **T1+T2+T4-SF+T7** = cụm "cửa trước" → **`docs/PHASE7.md`** (Lãnh Chúa, tân thủ, quest, minigame, formation-5+loadout, raid). **Ưu tiên #1** vì người chơi chạm đầu tiên.
2. **T4** synergy hoàn thiện (team-5, coalition, soft-cap, sim) + **skill-kit hero** (lát lớn, hoãn lâu nhất).
3. **T6** các dungeon còn thiếu (resource/equip/rune/endless/elite/challenge) + ancient boss.
4. **T5** pet, hero questline, relationships (chiều sâu collection).
5. **T10** crafting/salvage/premium-shop; **T11** endgame; **T13** art/audio/i18n (production).
6. **T12** backend thật (ops, sau cùng).

> **Plan forward hợp nhất** cho TẤT CẢ greenfield (Phase 7→12) nằm trong MỘT file: **`docs/PHASE7.md`** (PHẦN A=P7 cửa-trước chi-tiết-tới-unit; PHẦN B–F=P8–12 slice+unit-chính). Khi tới lượt một mục ⬜ → đào sâu tới-từng-unit **trong chính file đó** (không tách file mới), rồi cập nhật trạng thái ở bảng này. Quyết định mở của P7: `docs/PHASE7_OPTIONS.md`.
