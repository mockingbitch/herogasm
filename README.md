# Herogasm

Game pixel art 2D, thể loại **action-RPG / adventure**: phiêu lưu thế giới trung cổ, farm quái, săn loot, đánh boss, nâng cấp nhân vật và **đua rank** qua bảng xếp hạng.

- **Tỉ lệ:** ~70% chơi offline (toàn bộ gameplay lõi) / ~30% online (leaderboard, cloud save, sự kiện theo mùa).
- **Engine:** Godot 4 (GDScript)
- **Nền tảng:** PC (Steam / itch.io) + Mobile (Android / iOS)
- **Quy mô:** Solo dev (có kinh nghiệm code)
- **Backend online:** BaaS (đề xuất Supabase — xem `docs/ARCHITECTURE.md`)

## Tài liệu

| File | Nội dung |
|------|----------|
| [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md) | Tầm nhìn, core loop, các hệ thống gameplay, định nghĩa MVP, monetize |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Lộ trình theo giai đoạn, mốc thời gian, checklist |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Kiến trúc kỹ thuật, cấu trúc project Godot, save offline, backend online & chống gian lận |

## Nguyên tắc xuyên suốt

1. **MVP trước, content sau.** Làm 1 biome + 1 boss + 1 chế độ đua rank cho thật "đã tay" rồi mới mở rộng.
2. **Offline là xương sống.** Game phải chơi trọn vẹn khi mất mạng; online chỉ là lớp gia tăng.
3. **Online giữ ở mức async.** Leaderboard + cloud save + sự kiện theo seed — KHÔNG làm multiplayer thời gian thực (vượt xa 30% và rất tốn công).
4. **Scope nhỏ, polish cao.** Một vòng lặp chặt + cảm giác đánh đấm "juicy" hơn là nhiều tính năng dở dang.
