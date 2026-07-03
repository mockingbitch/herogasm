# TEAMBUILD.md

# Team Building & Synergy — Đa dạng nhưng cân bằng

> *"Không tồn tại đội hình mạnh nhất. Chỉ có đội hình đúng cho trận này."*
> Doc này là **nguồn sự thật** cho hệ synergy. Số trong `GDD.md §11` là bản phác cũ — **doc này thay thế**.

---

# Mục tiêu

Người chơi phải **flex tự do** các race/class khác nhau — mono, 3+2, rainbow đều **viable** — mà **không** đội nào thống trị mọi trận. Đa dạng đến từ **thiết kế**, cân bằng đến từ **đo lường (sim)**, không phải hand-tune cảm tính.

Bám 4 pillar sẵn có: *Strategy > Power* (`BALANCE.md`), *No Mandatory Hero* (`README.md`), *Race zero-sum* (`hero-stats.md`), *No Power Creep* (meta rotation P5).

**Đội hình formation = 5 hero** (CHỐT — Stage/Boss/Arena/Raid). Field-hunt & Expedition là per-hero tự trị, không áp doc này.

---

# Nhiều đội hình (Loadouts) & Khoá khi Deploy

Người chơi lưu **nhiều preset đội** để biến thiên: Team Human (tank/archer/buff), Team Dwarf-Necro-Mage, Team burst, Team sustained... rồi chọn preset phù hợp từng mode.

## Hai luật vàng

1. **Preset = bản vẽ → overlap thoải mái.** Cùng một hero ĐƯỢC nằm trong nhiều preset. Preset chỉ là template tổ chức, không "giữ" hero.
2. **Deploy = đặt quân thật → mỗi hero chỉ ở 1 chỗ tại 1 thời điểm.** Ràng buộc chỉ bật lúc gửi đội đi: hero đang commit cho 1 hoạt động-theo-thời-gian thì **không** deploy được vào hoạt động song song thứ hai.

## Cái gì KHOÁ hero, cái gì không

| Hoạt động | Giữ hero qua thời gian? | Khoá |
|---|---|---|
| Raid đang chạy | Có | 🔒 |
| Expedition đang chạy (`is_on_expedition` đã có) | Có | 🔒 |
| Sự kiện đa-đội (field nhiều team cùng lúc) | Có | 🔒 |
| Stage / hit World Boss / 1 trận Arena (sim tức thì) | Không | ✅ |
| Arena DEFENSE (snapshot đông cứng) | Không (bản sao) | ✅ overlap offense |
| Field-hunt (tự trị trong thành) | — | rảnh mới deploy; đang săn thì recall |

→ Rút gọn: **1 hero commit tối đa 1 "đặt quân theo thời gian" (raid/expedition/slot-event) tại một thời điểm.** Trận tức thời & snapshot phòng thủ không tiêu commit.

## Vì sao overlap-preset + khoá-runtime (không hard-partition)

Hard-partition (gán Team 2 thì mất khỏi Team 1) buộc kéo-thả lại mỗi lần đổi content, khoá cứng roster mạnh vào 1 đội → loại. Overlap + khoá-runtime cho share hero tự do, chỉ chặn khi **xung đột vật lý thật** (2 raid song song) — chuẩn AFK Arena / Summoners War. Khớp code sẵn: chỉ tổng quát hoá `is_on_expedition`/`first_free_hero()` thành sổ commit dùng chung.

## Ánh xạ code (slice nền "Formation Core" — build sớm, trước tân thủ & raid)

| Unit | Việc |
|---|---|
| `data/team_loadout.gd` `TeamLoadout extends Resource` | `id,name,hero_ids:Array[String]`(≤5, index=slot)`,formation_id,purpose` + `to_dict/from_dict` |
| `PlayerProfile.teams:Array` + `deployments:{hero_id:{activity,ref}}` | vào block `player`, save v8 |
| PlayerProfile methods | `create/save/delete/rename/get/teams_all/set_team_slot`; `locked_heroes()`, `is_hero_available(id)`, `can_deploy(loadout)→{ok,conflicts}`, `lock_team/release_team(activity)` |
| Gate deploy | `RaidService.can_enter` + `ExpeditionService.can_start` → `can_deploy`/`is_hero_available` |
| EventBus | `team_saved/team_deleted/hero_locked/hero_released` |
| UI | `ui/team_loadout_panel.gd` (gắn nav "Đội hình"): list preset, kéo hero vào 5 ô + chọn formation, hero khoá hiện xám+badge, Deploy cảnh báo xung đột |
| Migration v8 | seed preset "Đội Chính" từ `active_team`; thay dần `active_team(size=3)` bằng loadout đã chọn (team=5) |
| Test `test_team_loadout.gd` | overlap OK; can_deploy phát hiện xung đột raid/expedition; instant/defense KHÔNG khoá; release khi resolve; roundtrip |

---

# Sự thật khó chịu: GDD cũ chống lại đa dạng

`GDD.md §11`: 3 Human → +5% HP, **5 Human → +15% HP** — đường cong **TĂNG DẦN**. Hero thứ 5 cùng tộc đáng giá gấp 3 hero thứ 3 ⇒ ai cũng gom mono, flex chết. Muốn đa dạng, **bắt buộc lật thành GIẢM DẦN.**

```text
GDD cũ (tăng dần — ép mono):   3→+5%   5→+15%    (bước 3→5 = +10%)
TEAMBUILD (giảm dần — mở flex): 2→+4% 3→+7% 4→+9% 5→+10%
                                (bước 3→5 chỉ +3% → 2 slot đó đi mở synergy khác đáng hơn)
```

---

# Bốn trục synergy (vuông góc — bật đồng thời)

Mỗi hero mang **cả Race lẫn Class lẫn Element**. Đội trộn = *cách* bật nhiều trục cùng lúc. Đó là lõi của flex.

## Trục 1 — Race synergy (giảm dần, buff stat "chữ ký" của tộc)

| Số hero cùng tộc | Buff (% stat chữ ký) |
|---|---|
| 2 | +4% |
| 3 | +7% |
| 4 | +9% |
| 5 | +10% |

Stat chữ ký mỗi tộc (khớp `hero-stats.md` Race Secondary Signature + `GDD` race identity):

| Race | Stat chữ ký |
|---|---|
| Human | Max HP |
| Elf | Critical Rate |
| Orc | Attack |
| Dwarf | Defense / Block |
| Undead | Lifesteal |
| Angel | Healing Bonus |
| Demon | Penetration |
| Dragonkin | Skill Haste / Skill Damage |

## Trục 2 — Class synergy (mốc 2/3, buff nhỏ, stat khác trục race)

| Số hero cùng class | Buff |
|---|---|
| 2 | +3% |
| 3 | +6% |

| Class | Stat |
|---|---|
| Tank | Defense/Block | 
| Warrior | Attack |
| Assassin | Critical Damage |
| Ranger | Accuracy/Attack |
| Mage | Skill Haste / Mana Regen |
| Support | Healing Bonus |
| Summoner | Summon/Skill Damage |

→ Vì race & class là 2 trục khác nhau, đội **3 Human + 2 Elf** với **2 Tank + 2 Mage** bật **cả 4 mảnh synergy** cùng lúc. Mono khó làm điều này.

## Trục 3 — Coalition (cổ tức đa dạng)

**+1.2% TOÀN core-stat cho mỗi TỘC KHÁC NHAU trong đội.**

| Số tộc khác nhau | Buff toàn stat |
|---|---|
| 2 | +2.4% |
| 3 | +3.6% |
| 4 | +4.8% |
| 5 | +6.0% |

→ Rainbow-5 (5 tộc khác) = +6% mọi stat: **hồ sơ tròn, lì đòn**. Mono-5 = +10% một stat, +1.2% dividend: **nhọn, giòn**. Đây là cái làm rainbow có *bản sắc riêng*, không phải "mono hỏng".

## Trục 4 — Element (mềm, đến từ content — xem "Content quyết định thắng")

Không phải synergy cộng %, mà là **rock-paper-scissors** qua kháng/khắc. Mono-element = sát thương dồn nhưng **gãy trước boss kháng**. Trộn element = hedge. Trục này **không** nằm trong band số — nó là tie-breaker theo trận.

---

# "Cân bằng" = một BAND, chứng minh bằng SIM

Nguyên tắc: **mọi đội hợp lệ nằm trong band tổng-lực ±~8%**, khác nhau ở **phân bố stat** và **rủi ro**, không ở tổng lực.

| Archetype | Hồ sơ | Điểm mạnh | Điểm yếu |
|---|---|---|---|
| **Mono-5** | Nhọn 1 stat (+10% + class stack) | Bùng nổ 1 hướng | Giòn, dễ bị counter element/mechanic |
| **3+2 (split)** | 2 synergy vừa + class | Cân, ít điểm chết | Không đỉnh mảng nào |
| **Rainbow-5** | +6% toàn stat, lì | Ổn định mọi trận, chống counter | Không có combo bùng nổ |

**Số ở trên là KHỞI ĐIỂM để sim tune, KHÔNG phải chân lý.** Cân bằng được *đo*, không *đoán*:

- **Synergy total soft-cap** (răng của band): tổng đóng góp synergy vào **effective power** của một đội **≤ ~15%** (clamp trong `StatAggregator`). Chặn 3+2 stack nhiều mảnh nhỏ vượt rào.
- **`SynergyBalanceValidator`** (bản sao `MetaRotationValidator`): reject bảng synergy nào để một tag-stack đơn (mono) hoặc một split vượt band ở load-time.
- **`SynergyBalanceSim`** (bản sao `EconomySimRunner`/`StressTestRunner`): mô phỏng mono / 3+2 / rainbow đấu benchmark bằng `BattleSim` seeded → **assert win-rate mọi archetype trong ±8%**. Đây là bằng chứng cân bằng headless.

---

# Content quyết định thắng (không phải công thức thô)

Đây là thứ biến "±8% band" thành "không đội nào qua mọi trận":

- **Element resist** (`BossDef.resist` + `DamageFormula`): boss kháng Lửa 60% → mono-Lửa-Dragonkin gãy; đội trộn element sống.
- **Boss/Event modifier** (`BossPhaseDef`/`EventDef`, đã build): 
  - "Blood Curse" (hero mất HP liên tục) → buộc slot Support/Undead-lifesteal.
  - Break gauge → buộc 1 hero Control (CC).
  - Arena hazard (Poison giảm heal) → phạt đội thiên heal.
- **Objective phi-combat** (`DUNGEON.md`: Escort/Protect/Survive) → thưởng đội bền/kiểm soát hơn đội burst.

→ Mỗi trận **đổi trọng số** giữa các archetype trong band → người chơi **xoay đội theo trận**, đúng pillar.

---

# Meta rotation (đã build P5) — đẩy trọng tâm mỗi mùa

`SeasonManager.meta_rotation` buff **rune/equip/synergy** (không đụng hero base, có `MetaRotationValidator` chặn) → mỗi season, một nhóm synergy khác lên hạng. Đa dạng **theo thời gian**, chống "meta chết cứng". Áp qua `team_context().meta` → `StatAggregator._apply_meta` chỉ khi hero **sở hữu** → không power-creep.

---

# Ánh xạ code (data-driven, tất định)

| Việc | Unit (đã có) |
|---|---|
| Ngưỡng + buff synergy | `data/synergy_def.gd` `SynergyDef.thresholds:Dictionary` (đổi số ở đây, không code) |
| Tính synergy đội | `systems/build/synergy_service.gd` `SynergyService.compute(team)` |
| Áp vào stat + clamp | `systems/build/stat_aggregator.gd` (thêm layer coalition + synergy soft-cap) |
| Bơm vào combat | `PlayerProfile.team_context()` → `{synergy, meta}` → `BattleUnit.from_hero` |
| Seed bảng | `data/database.gd` `_build_p3` (mở rộng: 8 race-syn + 7 class-syn + coalition) |
| Element khắc/kháng | `BossDef.resist`, `systems/combat/damage_formula.gd`, `Enums.Element` |

Cần thêm mới (P7 hoặc lát "synergy-depth" riêng):
- `data/synergy_def.gd`: thêm `kind` = `"coalition"` (đếm tộc khác nhau).
- `systems/build/synergy_balance_validator.gd` (load-time check).
- `game/tests/simulation/test_synergy_balance.gd` (sim win-rate band) — thêm vào `SUITES`.
- Seed đủ bộ synergy trong `ContentP7`/`_build_p3`: 8 SynergyDef race (giảm dần) + 7 class (2/3) + 1 coalition.

---

# Synergy — Seed Data (đầy đủ, seed-ready)

> **3 ràng buộc engine (đã verify code):**
> 1. `StatAggregator.STATS` chỉ có **7 key**: `bonus_attack, bonus_defense, bonus_max_hp, bonus_speed, crit_chance, crit_damage, lifesteal`. Không có magic/accuracy/block/heal/pen/haste. → mỗi synergy dùng **vector 2 stat** trong 7 key này (đủ phân biệt 8 tộc + 7 class, không tạo dead-stat).
> 2. `SynergyService.compute` **cộng dồn MỌI mốc đạt** (không phải mốc-cao-nhất). → viết số dạng **increment delta**: `{2:+0.04, 3:+0.03, 4:+0.02, 5:+0.01}` cộng dồn = 4/7/9/10%.
> 3. Coalition (đếm tộc-khác-nhau) + soft-cap **cần thêm code** (không chỉ data) — xem cuối mục.

## Race synergy (8 tộc) — vector primary + minor, giảm dần

Primary (cộng dồn 4/7/9/10%): increments `{2:+0.04, 3:+0.03, 4:+0.02, 5:+0.01}`.
Minor (cộng dồn +3%): increments `{3:+0.02, 5:+0.01}`.

| Tộc | Primary stat | Minor stat | Bản sắc | (hero-stats.md gốc → proxy) |
|---|---|---|---|---|
| Human | `bonus_max_hp` | — (thuần) | Máu nền, baseline lì | HP |
| Elf | `crit_chance` | `bonus_speed` | Nhanh + chí mạng | Crit+Speed ✓ đúng |
| Orc | `bonus_attack` | `bonus_max_hp` | Bruiser đấm nặng | Attack (Accuracy→n/a) |
| Dwarf | `bonus_defense` | `bonus_max_hp` | Pháo đài | Block/Resist→def |
| Undead | `lifesteal` | `bonus_attack` | Hút máu | Lifesteal ✓ đúng |
| Angel | `bonus_defense` | `lifesteal` | Hộ vệ thánh (sustain) | Healing→def+ls proxy |
| Demon | `crit_damage` | `bonus_attack` | Huỷ diệt | Penetration→crit_dmg |
| Dragonkin | `crit_damage` | `bonus_speed` | Kỹ năng bùng | Skill Haste→cd+spd |

*(3 tộc Angel/Demon/Dragonkin dùng proxy vì stat gốc chưa có. Muốn đúng flavor 100% → engine-slice thêm healing/penetration/skill_haste khi BattleSim tiêu thụ chúng — hoãn tránh dead-stat.)*

Ví dụ seed literal (Human & Elf):
```gdscript
_synergy("human_syn", "race", "human",
    {2:{"bonus_max_hp":0.04}, 3:{"bonus_max_hp":0.03}, 4:{"bonus_max_hp":0.02}, 5:{"bonus_max_hp":0.01}})
_synergy("elf_syn", "race", "elf",
    {2:{"crit_chance":0.04}, 3:{"crit_chance":0.03,"bonus_speed":0.02}, 4:{"crit_chance":0.02}, 5:{"crit_chance":0.01,"bonus_speed":0.01}})
```

## Class synergy (7 class) — mốc 2/3, vector primary + minor

Primary (cộng dồn +6%): `{2:+0.03, 3:+0.03}`. Minor (cộng dồn +2%): `{2:+0.01, 3:+0.01}`.

| Class | Primary | Minor |
|---|---|---|
| Tank | `bonus_defense` | `bonus_max_hp` |
| Warrior | `bonus_attack` | `crit_chance` |
| Assassin | `crit_damage` | `crit_chance` |
| Ranger | `bonus_attack` | `bonus_speed` |
| Mage | `crit_damage` | `bonus_attack` |
| Support | `bonus_max_hp` | `lifesteal` |
| Summoner | `bonus_attack` | `bonus_defense` |

*(Pair mỗi class là duy nhất; trùng stat với tộc thì cộng dồn ở trục khác — đúng thiết kế 2-trục-vuông-góc.)*

## Coalition (cổ tức đa dạng) — CẦN CODE

Áp `+%` cho **cả 7 stat**, theo **số tộc khác nhau**. Increments (cộng dồn 2.4/3.6/4.8/6.0%):
`{2:{all:+0.024}, 3:{all:+0.012}, 4:{all:+0.012}, 5:{all:+0.012}}` (mỗi `all` = áp cho cả 7 key).

Code cần thêm:
- `SynergyDef.kind == "coalition"` → trong `SynergyService`: `n = race_count.size()` (đếm tộc khác nhau).
- Helper expand `"all"` → 7 key khi merge (hoặc seed sẵn 7 key).

## Soft-cap (răng của band) — CẦN CODE

Trong `StatAggregator`, layer `synergy`: **clamp tổng percent mỗi key ≤ 0.15** trước `finalize()`. Chặn split stack nhiều mảnh nhỏ vượt rào.

## Ví dụ 3 archetype (vector synergy, minh hoạ profile)

| Đội | Vector synergy (sau cộng dồn) | Hồ sơ |
|---|---|---|
| **Mono-5 Elf** (3 Assassin+2 Ranger) | crit +12%, cd +6%, spd +5%, atk +3% | Nhọn crit, 0 HP/def — **giòn** |
| **3 Human+2 Elf** (2 Tank+2 Mage+1 Sup) | hp +9.4%, crit +6.4%, def +5.4%, cd +5.4%, atk +3.4%, spd +2.4%, ls +2.4% (coalition 2 tộc) | Tròn, nhiều mảnh — **cân** |
| **Rainbow-5** (2+2+1 class) | +6% TOÀN stat + class bits | Đều, lì — **chống counter** |

→ Ba profile khác hẳn nhau; **`SynergyBalanceSim` mới là trọng tài** quy ra win-rate ±8%. Số trên là **khởi điểm để sim tune**, không phải chân lý.

---

# Liên hệ hero-stats.md (nền tảng bên dưới)

Synergy **ngồi TRÊN** hệ stat cá nhân đã zero-sum:
- **Race không cộng net power ở cá nhân** (`hero-stats.md`: race delta tổng = 0%). Nên **synergy là nơi DUY NHẤT race cho "lực"** → phải nhỏ + giảm dần (đúng doc này).
- **Mỗi class có điểm yếu rõ** (class weight, không class dẫn mọi stat). Nên không hero nào "gánh mọi trận" kể cả khi buff synergy.

→ Hai lớp này **cộng hưởng**: cá nhân đã cân (zero-sum), synergy chỉ *reshape đội*, content *chọn winner*.

---

# Ràng buộc thiết kế (checklist synergy mới)

Trước khi thêm/sửa synergy, trả lời "Có":

- Đường cong **giảm dần** (không thưởng stacking vô hạn)?
- Có **≥2 trục vuông góc** để đội trộn bật được nhiều mảnh?
- Rainbow có **bản sắc riêng** (coalition), không chỉ là "mono hỏng"?
- Tổng synergy **≤ soft-cap**, và `SynergyBalanceSim` xác nhận win-rate trong band?
- Có **content** (element/modifier/objective) khiến đội này thua đội kia **tuỳ trận**?
- Buff áp qua `team_context` (tất định, test được), **không** hardcode trong script?

---

# Tunables (sim sẽ chốt)

1. Band mục tiêu: **±8%** win-rate (chốt hiện tại). Nới → dễ tune, kém đa dạng.
2. Synergy total soft-cap: **~15%** effective power. 
3. Coalition per-tộc: **+1.2% toàn stat** (mạnh → rainbow trội; yếu → mono trội).
4. Race curve giảm dần: 4/7/9/10%. Class: 3/6%.
5. Element resist boss: **~50–60%** để mono-element thật sự phải né.
6. Có thêm coalition theo **class khác nhau** không? (hiện chỉ theo tộc — thêm sẽ thưởng flex mạnh hơn nữa).

---

# Motto

> *"Mono để bùng nổ. Rainbow để trường tồn. Split để không có điểm chết. Boss quyết định hôm nay ai đúng."*
