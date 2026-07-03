# FLOW.md

# Kịch bản hành trình người chơi (A → Z, Offline-First)

> *"Tài liệu này không mô tả một hệ thống. Nó mô tả cả một đời chơi — từ giây đầu tiên mở game đến khi trở thành huyền thoại."*

---

# Vai trò của tài liệu này

Các doc khác (`HERO.md`, `BOSS.md`, `DUNGEON.md`, `ECONOMY.md`, `EVENTS.md`...) mô tả **từng hệ thống theo chiều dọc**.

`FLOW.md` là **mô liên kết theo chiều ngang** — nó trả lời một câu hỏi duy nhất:

> "Người chơi trải nghiệm những hệ thống đó **theo trình tự nào**, và **tại sao** trình tự đó khiến họ quay lại mỗi ngày?"

Đây là tài liệu **bắt đầu đọc** cho bất kỳ ai muốn hiểu game vận hành ra sao đối với một người chơi thật.

Mọi con số trong tài liệu này là **đề xuất khởi điểm để tune**, không phải hằng số cứng. Chúng phải sống trong Resource/data (theo `rules/balancing.md` + `rules/economy.md`), không hardcode.

---

# Nguyên tắc tối thượng: Offline-First

Toàn bộ game **chơi trọn vẹn offline**. Online là **một lớp đồng bộ dán lên sau**, không phải gameplay mới.

Luật thiết kế:

* Mọi tính năng "online" phải có **bản offline thay thế** dùng chung Combat Engine + data.
* Khi đấu nối online, ta **thay nguồn dữ liệu** (bot → người thật, snapshot local → server), **không viết lại luật chơi**.
* Người chơi offline không bao giờ thấy một tính năng "bị khoá vì chưa online". Họ thấy **bản offline của nó**.

| Tính năng | Bản Offline (có ngay) | Nâng cấp khi Online |
| --- | --- | --- |
| Đấu Trường (Arena) | Đấu **bot** dùng snapshot đội hình do AI sinh | Đối thủ là người thật |
| World Boss | Boss **solo scale theo lực**, xếp hạng vs **bot leaderboard** | Toàn server cùng đánh 1 boss |
| Guild / Guild Boss | "Hội" NPC do game cấp; Guild Boss = damage-race vs mốc cố định | Guild người thật, damage cộng dồn |
| Bảng xếp hạng | Bảng vs bot theo phân vị lực | Bảng server thật |
| Chợ / Trade | Chợ NPC (mua/bán vật phẩm, giá động) | Auction giữa người chơi |
| Sự kiện cộng đồng | Mốc cá nhân giả lập "toàn server" | Tiến độ cộng dồn thật |

Nguồn sự thật kỹ thuật cho luật này: `rules/multiplayer.md` (đồng bộ **data**, không đồng bộ node; mọi hành động = Command tuần tự hoá được; RNG qua `RandomService` seeded).

---

# Nhân vật LÃNH CHÚA (Lord) — người chơi là ai

Người chơi **không** điều khiển một Hero. Người chơi tạo và nhập vai **Lãnh Chúa** — chủ thành, nhà chiến thuật.

* Lãnh Chúa **không ra trận, không có chỉ số combat**. Đây là avatar quản lý.
* Lãnh Chúa có **Cấp Lãnh Chúa (Lord Level)** = cấp tài khoản, là **cổng mở khoá chính** cho building / chế độ / độ khó.
* Cấp Lãnh Chúa lên nhờ **hoàn thành quest & story**, không phải nhờ combat trực tiếp → tiến trình gắn với "chơi đủ rộng" chứ không phải "cày một chỗ".
* Lãnh Chúa có **Đặc Ân (Lord Perks)**: buff toàn thành nhẹ (tốc hồi ở Nhà Trọ, +% vàng loot, +1 lượt expedition...) — mở dần theo cấp. **Không bán bằng tiền thật, không phải sức mạnh hero** (giữ luật no-P2W của `ECONOMY.md`).

Thuật ngữ: mọi nhân vật chiến đấu gọi chung là **Hero** (đã chốt — xem quyết định dự án). Lãnh Chúa là người triệu hồi/chỉ huy chúng, khớp lore "The Summoner of Fragments" trong `STORY.md`.

---

# Cấu trúc hành trình tổng thể

```text
A. Màn Mở (0–15 phút)      → Tạo Lãnh Chúa, hero đầu, trận đầu, triệu hồi đầu
      ↓
B. Tân Thủ (Lord 1–15)     → Chuỗi nhiệm vụ mở dần từng tính năng ẩn
      ↓
C. Tốt Nghiệp Tân Thủ      → Lord 15 + mở hết tính năng lõi → bỏ chuỗi tân thủ
      ↓
D. Vận Hành (Lord 15+)     → Nhịp ngày/tuần: daily, weekly, boss mốc, minigame
      ↓
E. Chiều Sâu (mid game)    → Hoàn thiện build, leo mode khó, sưu tập hero bậc cao
      ↓
F. Hậu Game (end game)     → Endless, Ancient/Season Boss, tối ưu meta, thành tựu
```

Mỗi giai đoạn dưới đây mô tả: **người chơi làm gì**, **mở khoá gì**, **được thưởng gì**, **vì sao tiếp tục**.

---

# A. MÀN MỞ — First Session (mục tiêu: 0–15 phút, "một hơi thở")

Đây là 15 phút quyết định người chơi ở lại hay rời đi. Mọi bước phải **thắng nhanh, thưởng ngay, hé lộ tiếp theo**.

| Bước | Người chơi làm | Dạy điều gì | Kết quả |
| --- | --- | --- | --- |
| A0 | Splash → chạm để bắt đầu | — | Vào game |
| A1 | **Tạo Lãnh Chúa**: tên, chân dung, huy hiệu/cờ | Đây là "bạn" | Hồ sơ Lãnh Chúa |
| A2 | Cutscene Prologue (tỉnh dậy giữa thành đổ nát — theo `STORY.md`) | Bối cảnh + động lực | Cảm xúc |
| A3 | **Nhận Hero đầu tiên** (kịch bản, đảm bảo là Tank/Warrior dễ dùng) | "Hero thuộc về bạn" | 1 Hero |
| A4 | **Trận auto-battle đầu** ở Bãi Săn/stage 1-1 | Luật vàng: **xem, không điều khiển** | Thắng chắc |
| A5 | Nhặt loot đầu → **nâng cấp đầu** (level/trang bị) | Vòng loot→mạnh hơn | Cảm giác tiến bộ |
| A6 | Chạm building đầu (Nhà Trọ) — hero mệt tự về nghỉ | Thế giới sống, tự vận hành | Hiểu meta |
| A7 | **Triệu hồi đầu** (x10 miễn phí, có rate-up đảm bảo ≥1 hero hiếm) | Sự phấn khích gacha | Đội hình 5+ |
| A8 | **Sắp đội hình 5 người** → clear stage 1-2/1-3 | Vị trí Front/Mid/Back + synergy | Đội hình thật |
| A9 | Xem trước **Nhiệm vụ hàng ngày** + **mốc kế tiếp** | Lý do quay lại mai | Hook giữ chân |

**Điểm chốt cảm xúc:** kết màn mở, người chơi phải đã (1) thấy hero của mình đánh nhau, (2) nhận một hero "ngon" từ gacha, (3) hiểu rằng mình xây thành chứ không cầm hero, (4) biết ngày mai có gì để làm.

---

# B. TÂN THỦ — Chuỗi nhiệm vụ mở dần (Lord 1 → 15)

Đây là **xương sống early game**. Nguyên tắc: **progressive disclosure** — không bao giờ hiện một tính năng trước khi quest tân thủ dạy nó.

## Cấu trúc chuỗi tân thủ

* Trình bày dạng **checklist dẫn dắt** (có mũi tên trỏ, không khoá cứng thao tác khác).
* **Mỗi bước tân thủ mở khoá đúng MỘT tính năng ẩn** + trả **một phần thưởng cụ thể**.
* Không bước nào bị chặn sau "grind" — chỉ chặn sau **hành động học được** (đánh 1 trận, nâng 1 cấp, xây 1 building).

## Bảng chuỗi tân thủ (đề xuất)

| Lord Lv | Nhiệm vụ tân thủ | Mở khoá (tính năng ẩn) | Thưởng |
| --- | --- | --- | --- |
| 1 | Thắng trận đầu | Bãi Săn / Story 1-x | Gold, Essence |
| 2 | Nâng 1 hero lên Lv.5 | Màn hình chi tiết Hero | Essence |
| 3 | Trang bị 1 món đồ | Hệ **Trang Bị 8 ô** (`EQUIPMENT.md`) | Rương đồ Common |
| 4 | Nâng cấp Nhà Trọ | Hệ **Building & nâng cấp** (`ECONOMY.md`) | Gold |
| 5 | Triệu hồi x10 | Banner **Triệu Hồi** thường + pity bar | Diamond, vé triệu hồi |
| 6 | Phái 1 **Expedition** | Hệ **Expedition idle** + offline reward | Crystal |
| 7 | Gắn 1 **Rune** | Hệ **Rune core+4** (`RUNE.md`) | Rune Common |
| 8 | Đạt 1 **Synergy** (vd 3 Human) | Bảng **Synergy** hiển thị | Gold, Essence |
| 9 | Clear 1 **Resource Dungeon** | Hệ **Dungeon** + rotation ngày (`DUNGEON.md`) | Crystal, đồ |
| 10 | Mở Region 2 trên **World Map** | **Bản đồ thế giới** + gating sao | Diamond |
| 11 | Tiêu 1 **Talent point** | **Talent Tree** + respec | Essence |
| 12 | Đánh **Story Boss** Chapter 1 | Hệ **Boss theo mốc** (`BOSS.md`) | Soul Stone, title |
| 13 | Chơi 1 **Minigame** | Hệ **Minigame** (chống nhàm) | Event/soft currency |
| 14 | Vào **Đấu Trường** (bot) | **Arena offline** + Honor | Honor, Arena Coin |
| 15 | **Awaken** 1 hero (nếu đủ shard) | **Awakening** (`ECONOMY.md` Soul Stone) | Diamond, khung avatar |

> Các tính năng in đậm đều **đã tồn tại trong code** (Phase 0–3): Trang bị 8 ô, Rune, Synergy, Expedition, Gacha+pity, Awaken/Respec, 7 building, World Map. Chuỗi tân thủ chỉ là **lớp dẫn dắt** phủ lên chúng — không phải hệ thống mới.

## Điều kiện TỐT NGHIỆP (bỏ chuỗi tân thủ)

Chuỗi tân thủ **tự động lược bỏ** khi thoả **cả hai**:

1. **Lord Level ≥ 15**, VÀ
2. **Đã mở hết tính năng lõi** (7 building + Dungeon + Expedition + Gacha + Trang bị + Rune + Talent + Awaken + Boss + Arena + Minigame).

Khi tốt nghiệp:

* Panel tân thủ **biến mất khỏi HUD**.
* Thay bằng **Sổ Mục Tiêu (Advanced Objectives)** + **Thành Tựu** — track dài hạn, không dẫn dắt từng bước.
* Người chơi chuyển hẳn sang **nhịp Vận Hành** (mục D).

> Thiết kế phòng thủ: nếu người chơi mở tính năng "vượt cấp" (vd nhờ event), chuỗi tân thủ **bỏ qua bước đã hoàn thành** thay vì bắt làm lại. Tân thủ là *tiến độ*, không phải *rào cản*.

---

# C. NHỊP VẬN HÀNH — Session Loop hàng ngày (Lord 15+)

Sau tốt nghiệp, mỗi phiên chơi "khoẻ mạnh" ≈ **10–20 phút active** + phần còn lại chạy nền (idle/offline).

## Trình tự một phiên điển hình

```text
1. Nhận thưởng OFFLINE   (offline progression, trần ≤ 80% hiệu suất active)
      ↓
2. Nhận NHIỆM VỤ NGÀY    (điểm hoạt động → rương ngày)
      ↓
3. Tiêu ENERGY           (Expedition + Dungeon khó theo rotation ngày)
      ↓
4. Đánh BOSS (nếu tới mốc)  (Story boss / World Boss tuần / Ancient tháng)
      ↓
5. MINIGAME              (đổi nhịp, thưởng có trần ngày)
      ↓
6. NÂNG CẤP & TRIỆU HỒI  (tiêu tài nguyên vừa kiếm)
      ↓
7. "Set-and-forget"      (giao field-hunt/expedition rồi thoát → thế giới tự chạy)
```

## Energy — cổng gì, không cổng gì

Theo `DUNGEON.md` (không gate toàn bộ game bằng energy):

* **KHÔNG tốn energy:** field-hunt tự trị ở Bãi Săn (thế giới sống chạy nền), story stage đã clear (quick-clear).
* **TỐN energy:** Expedition idle, Resource/Equipment/Rune Dungeon (nguồn tài nguyên đậm).
* **Dùng vé riêng:** Event Dungeon (Event Ticket), lượt Boss (Boss Ticket/ngày).

Energy hồi theo `TimeService`; trần offline reward hard-cap ≤ 0.8 (đã có trong code — `IDLE_REWARD_FACTOR`).

---

# D. HỆ NHIỆM VỤ — Cadence & Phần thưởng

Nhiệm vụ là **nhịp tim** giữ người chơi quay lại. Phân loại:

| Loại | Reset | Mục đích | Thưởng chính |
| --- | --- | --- | --- |
| **Tân Thủ** | Một lần | Dẫn dắt, mở tính năng | Tài nguyên + unlock (mục B) |
| **Hàng Ngày** | Mỗi ngày (giờ cố định) | Tạo thói quen | Gold, Essence, Crystal, **Điểm HĐ ngày** |
| **Hàng Tuần** | Mỗi tuần | Mục tiêu trung hạn | Rune, đồ Epic, Diamond, **Điểm HĐ tuần** |
| **Mốc (Milestone)** | Một lần | Thưởng cột mốc lớn | Soul Stone, hero shard, title |
| **Thành Tựu** | Một lần | Track dài hạn hậu-tân-thủ | Diamond, cosmetic, collection |
| **Sự Kiện** | Theo event | Nội dung sống (`EVENTS.md`) | Event currency (hết hạn theo event) |
| **Nhân Vật (Hero Quest)** | Theo hero | Chiều sâu lore (`STORY.md`) | Skill/rune synergy unlock |

## Nhiệm vụ ngày (ví dụ)

* Đăng nhập.
* Thắng 5 trận (field-hunt tính).
* Hoàn thành 1 Dungeon.
* Phái 1 Expedition.
* Chơi 1 Minigame.
* Tiêu X Gold (đảm bảo có **sink**).

→ Mỗi nhiệm vụ ngày cho **Điểm Hoạt Động**; đủ mốc điểm → mở **Rương Ngày** (giống EHT/battle-pass daily). Cơ chế "điểm → rương" giữ người chơi làm **đủ nhóm việc**, không chỉ 1 việc.

## Nhiệm vụ tuần (ví dụ)

* Clear 10 Dungeon.
* Đánh World Boss 3 lần.
* Thắng 10 trận Arena.
* Awaken/nâng 1 hero.

→ Đủ **Điểm HĐ tuần** → **Rương Tuần** (thưởng đậm hơn ngày, theo `ECONOMY.md` weekly).

## Triết lý phần thưởng (bám `ECONOMY.md`)

* Thưởng phải **consumable** và có **nơi tiêu ngay**: Gold → nâng đồ; Essence → nâng hero; Crystal → enhance; Soul Stone → awaken; Diamond → triệu hồi/tiện ích.
* **Không** phát trang bị "tốt nhất" trực tiếp — đồ mạnh đến từ **loot + craft + boss**, giữ vòng lặp farm có nghĩa.
* Không tăng gold-reward vô hạn để chống lạm phát → thay bằng **mở sink mới / collection mới**.

---

# E. NHIỆM VỤ BOSS THEO MỐC (mốc cố định)

Boss là **cao trào định kỳ** phá vỡ sự đều đều của farm. Ba tầng nhịp:

| Tầng | Khi nào (mốc cố định) | Bản Offline | Thưởng đặc trưng |
| --- | --- | --- | --- |
| **Story Boss** | Cuối mỗi Chapter (~mỗi 10 stage) | Solo, kịch bản (`BOSS.md` Story Boss) | Mở Chapter sau + hero/rune + first-clear diamond |
| **World Boss (tuần)** | Xoay theo ngày trong tuần (`BOSS.md` lịch 7 boss) | Solo **scale theo lực**, xếp hạng vs **bot** theo phân vị | Material đậm, Ancient Fragment, xếp hạng thưởng |
| **Ancient / Season Boss** | Theo tháng / theo Season (`BOSS.md`, `EVENTS.md`) | Trigger bằng quest/shrine, solo | Ancient Equipment, Legendary Rune, Artifact Fragment |

Nguyên tắc boss (bám `BOSS.md`): **nhiều phase**, có **Break gauge**, **Enrage** khi hết giờ, **cơ chế độc quyền** buộc đổi đội hình — không phải "cục HP to". Boss test **chiến thuật**, không test Battle Power thuần.

**Kết nối vòng lặp:** drop boss (shard, fragment, material) là **nguyên liệu bậc cao** feed thẳng vào Triệu hồi bậc cao + Awaken + nâng cả đội — đúng "nhiệm vụ xuyên suốt" mà bạn mô tả.

---

# F. VẬT PHẨM ĐẶC BIỆT TỪ QUÁI — Drop Tiers

Theo `BOSS.md` + `ECONOMY.md` (Salvage: mọi loot đều có giá trị):

| Nguồn | Drop thường | "Vật phẩm đặc biệt" |
| --- | --- | --- |
| Quái thường | Gold, Common material | — |
| Quái Elite | Rare material, **Rune shard** | Đôi khi Epic đồ |
| Dungeon Boss | Equipment, Rune, Material | **Set piece**, Crystal đậm |
| Elite/Raid Boss | Epic Equipment, Rare Rune | **Artifact Fragment**, **Hero Shard** |
| Ancient/Season Boss | — | **Ancient Equipment**, **Legendary Rune**, **Soul Stone** đậm |

"Vật phẩm đặc biệt" = **nguyên liệu chốt chặn tiến trình** (shard để triệu hồi/awaken bậc cao, fragment để ghép artifact). Chúng là lý do farm quái *có đích đến*, không phải farm cho vui.

---

# G. NHIỆM VỤ XUYÊN SUỐT — The Through-Line

Toàn bộ game quy về một vòng lặp lớn:

```text
KIẾM TÀI NGUYÊN  (quest + farm quái + dungeon + boss + expedition + minigame)
      ↓
        ├─→ TIÊU VÀO SỰ KIỆN        (Event currency, Event shop — EVENTS.md)
        ├─→ NÂNG CẤP NHÂN VẬT       (level, skill, trang bị, rune, talent)
        ├─→ TRIỆU HỒI BẬC CAO       (gacha bằng Diamond/vé; shard → hero hiếm)
        └─→ NÂNG CẤP TOÀN ĐỘI HÌNH  (awaken, synergy, set-bonus, formation)
      ↓
MẠNH HƠN → mở Region/Difficulty mới → tài nguyên xịn hơn → LẶP LẠI (không power-creep vô hạn)
```

Ba **track tiến trình song song** để người chơi luôn có việc:

1. **Bề rộng roster** — sưu tập hero (gacha, shard, codex).
2. **Chiều sâu build** — trang bị/rune/talent/awaken/synergy cho hero đã có.
3. **Thành & Lãnh Chúa** — nâng building, lên Lord Level, mở Đặc Ân.

Khi một track "nghẽn" (hết tài nguyên loại A), người chơi chuyển sang track khác → **không bao giờ hết việc**.

---

# H. CHỐNG NHÀM CHÁN — Raid Dungeon & Minigame

Vấn đề bạn nêu: tránh vòng lặp "treo farm quái" nhàm chán. Hai đối trọng:

## Raid Dungeon (khác hẳn farm)

* Theo `DUNGEON.md` Raid: **nhiều boss, nhiều phase**, yêu cầu **nhiều đội hình / nhiều vai trò** — không thể auto bằng 1 đội "one-size-fits-all".
* **Bản Offline:** solo với "**hero hỗ trợ**" (bot đồng đội do game cấp/hoặc mượn từ roster của chính mình). Online sau: co-op người thật.
* **Nhịp:** mở theo tuần (rotation), có leaderboard damage (offline = vs bot).
* Mục đích: buổi chơi "đậm chiến thuật" tương phản với farm nhẹ nhàng.

## Minigame (đổi nhịp, thưởng có trần ngày)

Theo `EVENTS.md` (Fishing, Card, Treasure Hunt, Puzzle...). Đề xuất **gắn minigame vào building** để nó là một phần của thành sống:

| Minigame | Gắn ở | Cơ chế ngắn | Thưởng (trần ngày) |
| --- | --- | --- | --- |
| **Câu Cá** | Bến Cảng/Ao | Timing bar, cá hiếm theo giờ | Food, gold, material hiếm |
| **Xúc Xắc/Bài Quán Trọ** | Nhà Trọ | Push-your-luck nhẹ | Gold, Essence, vé nhỏ |
| **Rèn Nhịp (Forge)** | Xưởng Rèn | Nhấn đúng nhịp → +% enhance | Crystal, giảm phí enhance |
| **Đào Kho Báu** | Bản đồ | Chọn ô, tránh bẫy | Rương, shard, cosmetic |

Luật vàng cho minigame: **thưởng có trần/ngày** → là *gia vị*, không thay thế farm chính; **không** biến thành "job" bắt buộc. Đủ để đổi nhịp, không đủ để phá kinh tế.

## Nguyên tắc chống nhàm tổng quát

* Rotation ngày (Dungeon/Event) đảm bảo **hôm nay khác hôm qua** (`DUNGEON.md`, `EVENTS.md`).
* Modifier tuần (Boss/Challenge Dungeon) buộc **đổi build định kỳ**.
* Không để người chơi làm **cùng một việc 3 phiên liên tiếp mà không có mục tiêu mới** — luôn có mốc/quest/event kế treo sẵn.

---

# I. BẢN ĐỒ HIỆN THỰC HOÁ — ánh xạ vào lộ trình 7 phase

Kịch bản này **actionable**, không phải viễn tưởng. Đối chiếu trạng thái code hiện tại:

| Phần kịch bản | Trạng thái | Phase |
| --- | --- | --- |
| Thế giới sống + hero tự trị + field-hunt + offline | **XONG** | P1 |
| 7 building + vòng đời hero + world map + expedition | **XONG** | P2 |
| Trang bị 8 ô + Rune + Synergy + Talent + Awaken + Gacha+pity | **XONG** | P3 |
| Boss theo mốc (World Boss xoay ngày) + Break/Enrage/phase + Stage 3/3 + Arena bot | **XONG** | P4 |
| Story campaign (Prologue→Ch1-10→Arc) + Season/Event framework + WorldEvolution | **XONG** | P5 |
| Online layer (Net/MockBackend, Arena/Guild/Leaderboard, CloudSave, AntiCheat) — offline-first | **XONG (core)** | P6 |
| **Tạo Lãnh Chúa + Lord Level + Đặc Ân** | *Chưa* — greenfield | **P7** |
| **Chuỗi tân thủ + progressive disclosure + tốt nghiệp** | *Chưa* — greenfield | **P7** |
| **Hệ nhiệm vụ ngày/tuần/mốc/thành tựu + rương điểm HĐ** | *Chưa* — greenfield | **P7** |
| **Màn Mở first-session + Dialogue Runner/View** | *Chưa* (DialogueDef data có, chưa runner) | **P7** |
| **Minigame (Câu Cá + Rèn Nhịp)** | *Chưa* — greenfield | **P7** |
| **Raid Dungeon** (composition trên Boss/Stage đã có) | *Chưa* | **P7 (S6)** |

> **Cập nhật (2026-07-03):** P4–P6 thực tế đã HOÀN THÀNH (bộ máy sim + nội dung + online). Thứ *người chơi thật chạm đầu tiên* — **tầng cửa trước** (Lãnh Chúa + tân thủ + hệ quest + minigame) — là phần **greenfield duy nhất còn lại**, đã tách thành **Phase 7**. Plan chi tiết tới từng unit: **`docs/PHASE7.md`**.

---

# J. CÁC QUYẾT ĐỊNH CẦN BẠN CHỐT (tunables)

Tôi đã đặt **default hợp lý** ở trên; đây là các điểm bạn nên xác nhận/điều chỉnh:

1. **Ngưỡng tốt nghiệp tân thủ** — đề xuất **Lord 15 + mở hết lõi**. Cao hơn (20) = dạy kỹ hơn nhưng dài; thấp hơn (10) = thả sớm.
2. **Lãnh Chúa có Đặc Ân không, và mạnh cỡ nào** — đề xuất buff *tiện ích* nhẹ, không đụng sức mạnh hero (giữ no-P2W).
3. **Cadence Boss mốc** — đề xuất Story mỗi ~10 stage / World Boss xoay theo ngày / Ancient theo tháng.
4. **Bộ minigame khởi điểm** — đề xuất 2 cái trước (Câu Cá + Rèn Nhịp) cho MVP onboarding, thêm sau.
5. **Team size** — memory ghi 5 combat / 4 expedition. Xác nhận giữ nguyên.
6. **Energy gate cái gì** — đề xuất gate Expedition + Dungeon-khó, KHÔNG gate field-hunt/quick-clear.

---

# K. Checklist thiết kế cho mọi tính năng mới thêm vào flow

Trước khi thêm bất kỳ nội dung nào vào hành trình, nó phải trả lời "Có" cho:

* Có **bản offline** dùng chung engine/data không? (Offline-First)
* Có **nguồn (source) và nơi tiêu (sink)** rõ ràng không? (`ECONOMY.md`)
* Nó **mở khoá qua tân thủ** hay xuất hiện sau tốt nghiệp? (progressive disclosure)
* Nó nằm ở nhịp nào: **ngày / tuần / mốc / event**?
* Nó **đổi nhịp** hay lặp lại thứ đã có? (chống nhàm)
* Phần thưởng **tương xứng** và **có nơi tiêu ngay** không?
* Nó buộc/khuyến khích **chiến thuật** hay chỉ tăng số? (`BALANCE.md`: Strategy > Power)

Nếu tất cả là "Có", tính năng đó xứng đáng vào hành trình.

---

# Motto

> *"Người chơi mở game để làm Lãnh Chúa một buổi sáng — và rời đi với cảm giác vương quốc vẫn đang sống khi họ không nhìn."*
