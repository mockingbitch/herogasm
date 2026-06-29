# Herogasm — Game Design Document (GDD)

> Tài liệu sống. Cập nhật khi thiết kế thay đổi. Phần nào chưa chốt thì đánh dấu `TBD`.

## 1. Tầm nhìn (Vision)

Một game **action-RPG pixel art top-down** trong thế giới trung cổ giả tưởng. Người chơi điều khiển một anh hùng đi qua các vùng đất (dungeon/biome), **farm quái để lấy loot và nguyên liệu**, **nâng cấp nhân vật + trang bị**, **hạ boss**, và **đua rank** với người chơi khác qua các chế độ tính điểm.

**Câu thần chú (design pillar):**
- *Farm là vui* — đánh quái phải đã tay, drop loot phải gây nghiện.
- *Tiến bộ rõ rệt* — mỗi phiên chơi nhân vật mạnh lên thấy được.
- *Có lý do để quay lại* — bảng xếp hạng + mùa giải tạo mục tiêu dài hạn.

**Tham chiếu (reference):** Soul Knight, Moonlighter, Death's Door, Vampire Survivors (vòng lặp farm/scaling), Hades (cảm giác combat + meta-progression), Brotato (run ngắn + đua điểm).

## 2. Thể loại & góc nhìn

- **Góc nhìn:** Top-down 2D (dễ làm tile-based dungeon trung cổ, dễ port mobile).
- **Combat:** Real-time, hành động. Di chuyển 8 hướng, đánh thường + né/lăn (dodge roll) + 1–2 kỹ năng (skill) có cooldown.
- **Cấu trúc chơi:** Hub (thị trấn) → chọn vùng đất → vào "run" farm/khám phá → quay về hub nâng cấp → lặp lại, độ khó tăng dần.

## 3. Core Loop (vòng lặp lõi)

```
        ┌──────────────────────────────────────────────┐
        │                                                │
        ▼                                                │
  [Hub/Thị trấn] ──chọn vùng──► [Vào Run] ──farm quái──► [Loot + Vàng + XP]
        ▲                                                │
        │                                                ▼
  [Nâng cấp NV + trang bị] ◄──tiêu vàng/nguyên liệu── [Về Hub]
        │                                                
        └──► [Đủ mạnh] ──► [Đánh Boss vùng] ──► [Mở vùng mới / leo rank]
```

- **Vòng ngắn (giây–phút):** đánh 1 nhóm quái → nhặt drop → mạnh hơn một chút.
- **Vòng vừa (1 run = 10–20 phút):** vào vùng, dọn quái, gặp elite/mini-boss, lấy chiến lợi phẩm, rút lui hoặc chết.
- **Vòng dài (nhiều phiên):** lên cấp, ráp bộ trang bị, hạ boss vùng, mở vùng mới, leo bảng xếp hạng mùa.

## 4. Các hệ thống chính

### 4.1 Nhân vật & chỉ số
- **Chỉ số gốc:** HP, ATK (sát thương), DEF (giáp), Crit %, Crit Dmg, Tốc đánh, Tốc chạy, Hút máu (lifesteal — tuỳ chọn).
- **Lên cấp:** nhận XP từ giết quái → lên level → tăng chỉ số gốc + điểm kỹ năng.
- **Cây kỹ năng / talent:** vài nhánh (ví dụ: Sát thương / Sinh tồn / Tiện ích). Giữ nhỏ ở MVP (6–10 node).
- **(Mở rộng sau)** Nhiều class/anh hùng để mở khoá → tăng replay.

### 4.2 Trang bị & độ hiếm (gear)
- **Slot:** Vũ khí, Giáp, Mũ, Phụ kiện (nhẫn/bùa).
- **Độ hiếm:** Common → Uncommon → Rare → Epic → Legendary (màu sắc rõ ràng kiểu Diablo).
- **Affix ngẫu nhiên:** mỗi món có 1–4 thuộc tính phụ (vd: +ATK, +Crit, +%HP, hiệu ứng cháy/băng). Đây là động lực farm chính.
- **Nâng cấp:** dùng vàng + nguyên liệu để +1, +2... tại Lò rèn.

### 4.3 Items & collection (sưu tầm)
- **Trang bị** (như trên).
- **Nguyên liệu** (drop từ quái/boss → crafting & nâng cấp).
- **Tiêu hao:** bình máu, buff tạm thời, cuộn dịch chuyển.
- **Sưu tầm/Codex:** Bestiary (đồ giám quái), bộ sưu tập công thức, achievement → thưởng nhẹ + động lực 100%.

### 4.4 Farm quái & vùng đất (biome)
- **Biome trung cổ:** Rừng → Hang động → Hầm mộ → Lâu đài (mỗi biome 1 tông màu + bộ quái + boss riêng).
- **Spawn & độ khó:** mỗi vùng có "tier"; quái scale theo tier. Có **quái elite** (mạnh hơn, drop xịn hơn, viền sáng).
- **Drop table:** mỗi loại quái có bảng rơi đồ riêng (tỉ lệ %); boss có drop đảm bảo (guaranteed) + hiếm.
- **Sinh thủ tục nhẹ (procedural):** layout phòng ráp từ các "room template" + seed → tăng replay mà vẫn kiểm soát được thiết kế.

### 4.5 Boss
- **Boss vùng:** mỗi biome 1 boss "cổng" — hạ để mở biome kế tiếp (nội dung offline/cốt truyện).
- **Boss đua rank (time-attack):** boss riêng cho chế độ tính giờ → nền tảng cho leaderboard "hạ boss nhanh nhất".
- Thiết kế boss: nhiều phase, telegraph đòn rõ, thưởng cao.

### 4.6 Kinh tế (economy)
- **Vàng:** tiền tệ chính, dùng nâng cấp/mua đồ ở hub. Drop offline.
- **Nguyên liệu:** craft & nâng cấp.
- **(Mobile F2P, mở rộng)** tiền tệ cao cấp (premium) cho cosmetic — KHÔNG bán sức mạnh (tránh pay-to-win làm hỏng leaderboard).

### 4.7 Đua rank / Online (lớp 30%)
Giữ ở dạng **bất đồng bộ (async)** — không cần server thời gian thực:

- **Chế độ Trial / Endless:** một màn chơi tính điểm theo **seed cố định mỗi tuần** (mọi người chơi cùng map/quái) → công bằng để so điểm. Điểm = độ sâu + số quái + thời gian.
- **Boss Rush time-attack:** xếp hạng theo thời gian hạ boss.
- **Mùa giải (Season):** reset định kỳ (vd hàng tháng), thưởng cosmetic/danh hiệu theo thứ hạng.
- **So sánh bạn bè:** xem điểm bạn bè/khu vực.
- **Cloud save:** đồng bộ tiến trình giữa PC ↔ mobile.

> Vì điểm được tính ở máy người chơi (offline), **chống gian lận** là rủi ro lớn nhất của lớp online — xử lý ở `docs/ARCHITECTURE.md` (validate server-side theo seed + giới hạn hợp lý + cờ outlier).

## 5. Định nghĩa MVP (bản chơi được đầu tiên)

Mục tiêu: chứng minh "farm + nâng cấp + đua rank" vui, với scope nhỏ nhất.

**Phải có:**
- 1 anh hùng, combat đầy đủ (di chuyển, đánh thường, dodge, 1 skill).
- 1 biome (Rừng) với 3–4 loại quái + 1 elite + 1 boss vùng.
- ~10–15 món trang bị + hệ độ hiếm + affix cơ bản.
- Lên cấp + 1 cây talent nhỏ + Lò rèn nâng cấp.
- Hub đơn giản (NPC bán đồ + lò rèn + cổng vào vùng).
- Save offline ổn định.
- **1 leaderboard online:** chế độ Trial theo seed tuần.

**Chưa cần (để sau):** nhiều class, nhiều biome, cốt truyện sâu, mùa giải, mobile port hoàn chỉnh, monetize.

## 6. Monetize (định hướng, quyết sau)
- **PC:** bán đứt (premium) trên Steam/itch.io — hợp cộng đồng pixel art.
- **Mobile:** F2P + cosmetic/battle pass, **tuyệt đối không bán sức mạnh** ảnh hưởng rank. Cân nhắc quảng cáo thưởng (rewarded ad) tự nguyện.
- Quyết định cuối phụ thuộc thị trường mục tiêu — chưa cần chốt ở giai đoạn này.

## 7. Câu hỏi mở (TBD)
- Tên/lore thế giới, nhân vật chính.
- Combat thiên melee, ranged hay hybrid?
- Run có "permadeath" kiểu roguelite hay chết chỉ mất một phần?
- Style pixel: độ phân giải gốc (đề xuất 320×180 hoặc 384×216), palette.
