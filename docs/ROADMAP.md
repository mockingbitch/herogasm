# Herogasm — Roadmap

> Ước lượng thời gian giả định solo, làm bán thời gian (~15–20h/tuần). Nếu full-time, chia ~2.5–3. Đừng bám cứng con số — bám **mốc hoàn thành (deliverable)**.

## Tổng quan giai đoạn

| Phase | Tên | Mục tiêu | Thời gian (part-time) |
|-------|-----|----------|----------------------|
| 0 | Pre-production | Chốt GDD, style, dựng skeleton project | 1–2 tuần |
| 1 | Combat prototype | Đánh đấm "đã tay" (gray-box) | 2–4 tuần |
| 2 | Core loop | 1 biome + farm + loot + hub + nâng cấp | 4–6 tuần |
| 3 | Progression & content | Level, gear rarity, craft, boss | 6–8 tuần |
| 4 | Online | Supabase: auth, cloud save, leaderboard | 3–4 tuần |
| 5 | Meta & polish | Mùa giải, juice, audio, UI, settings | 4–6 tuần |
| 6 | Mobile port | Touch input, scaling, tối ưu hiệu năng | 2–4 tuần |
| 7 | Beta & launch | Cân bằng, chống cheat, store prep | 4–6 tuần |

**Tổng quãng: ~6–9 tháng** cho hành trình MVP → bản phát hành nhỏ gọn. Mục tiêu chính: **ra được "vertical slice" chơi vui sau Phase 3**, rồi quyết định scale.

---

## Phase 0 — Pre-production
- [ ] Chốt các mục `TBD` trong GDD (melee/ranged, permadeath?, độ phân giải gốc, palette).
- [ ] Quyết base resolution (đề xuất **384×216**, scale nguyên lần lên 1080p/4K).
- [ ] Cài Godot 4.x, tạo repo git, dựng cấu trúc thư mục (xem `ARCHITECTURE.md`).
- [ ] Thu thập asset tạm: tileset + sprite quái CC0 (Kenney, itch.io) để gray-box nhanh.
- [ ] Dựng 4 autoload rỗng: `GameState`, `SaveManager`, `AudioManager`, `EventBus`.

## Phase 1 — Combat prototype (cột mốc "feel")
> Một phòng xám, 1 người chơi, 1 con quái. Mục tiêu: đánh nhau phải sướng.
- [ ] Player: di chuyển 8 hướng, animation cơ bản, dodge roll (i-frame).
- [ ] Đánh thường: hitbox/hurtbox, damage, knockback, hit-stop (screen freeze nhẹ).
- [ ] 1 enemy: state machine (idle → chase → attack → hurt → die), thanh máu.
- [ ] "Juice": particle khi trúng đòn, rung màn hình nhẹ, số sát thương bay lên.
- [ ] 1 skill có cooldown + UI cooldown.
- **✅ Tiêu chí qua phase:** tự thấy đánh quái "đã tay" mà không cần đồ hoạ đẹp.

## Phase 2 — Core loop
- [ ] 1 biome (Rừng): tileset, 3–4 loại quái, spawn theo phòng.
- [ ] Sinh map thủ tục nhẹ: ghép room template + seed.
- [ ] Hệ loot: drop table, item rơi ra đất, nhặt.
- [ ] Inventory + trang bị (mặc/cởi, ảnh hưởng chỉ số).
- [ ] Hub/thị trấn: cổng vào vùng, NPC bán đồ, lò rèn (khung).
- [ ] Vàng + nguyên liệu, mua/bán cơ bản.
- [ ] **SaveManager:** lưu/đọc tiến trình offline (JSON hoặc `Resource`).
- **✅ Tiêu chí:** chơi trọn vòng farm → về hub → nâng cấp → vào lại, không cần mạng.

## Phase 3 — Progression & content (→ vertical slice)
- [ ] Hệ XP/level + tăng chỉ số.
- [ ] Cây talent nhỏ (6–10 node).
- [ ] Độ hiếm gear + affix ngẫu nhiên + màu sắc.
- [ ] Lò rèn nâng cấp (+1, +2...) tốn vàng/nguyên liệu.
- [ ] Boss vùng đầu tiên (đa phase, telegraph, drop đảm bảo).
- [ ] Cân bằng đường cong sức mạnh sơ bộ.
- **✅ Tiêu chí: VERTICAL SLICE** — bản demo 30–60 phút vui, đem cho người khác chơi thử & lấy phản hồi. **Quyết định scale ở đây.**

## Phase 4 — Online (lớp 30%)
- [ ] Lập project Supabase: bảng `profiles`, `cloud_saves`, `leaderboards`, `runs` (schema ở `ARCHITECTURE.md`).
- [ ] Auth (ẩn danh + email) trong Godot qua HTTPRequest/SDK.
- [ ] Cloud save: đẩy/kéo save, xử lý xung đột (lần ghi mới nhất thắng + cảnh báo).
- [ ] Chế độ **Trial** theo seed tuần.
- [ ] Submit điểm + hiển thị leaderboard top N + thứ hạng của mình.
- [ ] Validate server-side cơ bản (Edge Function: chặn điểm vô lý theo seed).
- **✅ Tiêu chí:** chơi offline vẫn ổn; có mạng thì đồng bộ + đua rank được.

## Phase 5 — Meta & polish
- [ ] Mùa giải (reset + thưởng theo hạng).
- [ ] Audio: nhạc nền theo biome, SFX combat/UI.
- [ ] UI/UX hoàn chỉnh: menu, settings (âm lượng, điều khiển, ngôn ngữ), pause.
- [ ] Bestiary/Codex, achievement.
- [ ] Robust save (chống mất/hỏng file, versioning save).
- [ ] Localization khung (VI + EN).

## Phase 6 — Mobile port
- [ ] Input touch: virtual joystick + nút skill, hoặc tap-to-move (test cả hai).
- [ ] UI co giãn theo nhiều tỉ lệ màn hình + safe area.
- [ ] Tối ưu: giảm draw call, atlas texture, kiểm pin/nhiệt, target 60fps.
- [ ] Export Android (.aab) + iOS (cần Mac/Xcode).

## Phase 7 — Beta & launch
- [ ] Closed beta, thu telemetry (độ khó, tỉ lệ chết, vùng bỏ cuộc).
- [ ] Cân bằng lại theo dữ liệu.
- [ ] Hardening chống cheat leaderboard (xem `ARCHITECTURE.md`).
- [ ] Store: trang Steam (capsule, trailer, mô tả), Google Play, App Store.
- [ ] Wishlist campaign / demo trên Steam Next Fest (nếu nhắm Steam).

---

## Rủi ro lớn cần canh chừng
1. **Chống gian lận leaderboard** — chi phí ẩn lớn nhất. Giữ online async + validate server. Đừng để rank "bẩn" giết động lực.
2. **Art tốn thời gian solo** — dùng asset CC0/mua sẵn lúc đầu, thay dần. Palette chặt che giấu khuyết điểm.
3. **Scope creep nội dung** — mỗi biome/boss/class đều nhân chi phí. Khoá scope tới sau vertical slice.
4. **Save corruption** — versioning + backup file save sớm; người chơi mất tiến trình là mất luôn người chơi.
