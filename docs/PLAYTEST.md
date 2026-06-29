# Herogasm — Playtest & Cân bằng

Dùng khi tự chơi vertical slice (10–15 phút) để cảm nhận và ghi nhận. Mỗi mục: tick + ghi chú số.

## A. Checklist cảm giác (feel)
- [ ] Đánh thường có "đã tay"? (hit-stop, số sát thương, knockback rõ?)
- [ ] Né (dodge) có cứu được mạng? Thời gian i-frame + hồi chiêu hợp lý?
- [ ] Crit có cảm giác phần thưởng? (số crit to/cam có nổi bật?)
- [ ] Quái đuổi/đánh có công bằng? Có bị "vây chết" oan không?
- [ ] Đòn vũ khí trúng đúng tầm nhìn? (không hụt, không trúng sau lưng?)

## B. Checklist vòng lặp (loop)
- [ ] Sau 1 run có cảm thấy "mạnh lên" rõ rệt không?
- [ ] Vàng kiếm được vs giá nâng cấp/mua: quá dư hay quá thiếu?
- [ ] Affix ngẫu nhiên có tạo động lực farm (muốn roll món tốt hơn)?
- [ ] Lên cấp + talent: chọn có ý nghĩa hay vô thưởng vô phạt?
- [ ] Boss: dễ quá / khó quá / vừa? Mất bao lâu để hạ? Phase 2–3 có khác biệt rõ?

## C. Số liệu cần ghi (điền khi chơi)
| Lần | Cấp NV | Thời gian dọn 1 dungeon | Vàng/run | Số lần chết | Hạ được boss? | Ghi chú |
|-----|--------|--------------------------|----------|-------------|---------------|---------|
|     |        |                          |          |             |               |         |

---

## Bảng tuning — chỉnh số ở đâu

| Muốn chỉnh | File | Biến / hàm |
|------------|------|-----------|
| Tốc độ đánh / né của player | `actors/player/player.gd` | `attack_cooldown`, `dodge_*` |
| Chỉ số gốc + tăng theo cấp | `autoload/profile.gd` | `BASE_*`, `ATK/DEF/HP_PER_LEVEL` |
| Crit gốc | `autoload/profile.gd` | `BASE_CRIT_CHANCE`, `BASE_CRIT_DAMAGE` |
| Affix (loại, khoảng giá trị, số lượng) | `autoload/profile.gd` | `AFFIX_POOL`, `_affix_count()` |
| Talent (hiệu lực/cấp, trần) | `autoload/profile.gd` | `TALENTS` |
| Đường cong XP | `autoload/profile.gd` | `xp_to_next()` |
| Kinh tế (giá nâng cấp, markup mua) | `autoload/profile.gd` | `UPGRADE_BASE_COST`, `BUY_MARKUP` |
| Chỉ số / drop của quái | `autoload/database.gd` | `_build_enemies()` |
| Item (giá, bonus, độ hiếm) | `autoload/database.gd` | `_build_items()`, `shop_stock` |
| Loại & số quái mỗi run | `scenes/run.gd` | `_spawns` |
| Boss (máu, sát thương, tốc độ, drop) | `actors/boss/boss.gd` | các `@export` đầu file |

**Quy trình cân bằng:** chơi → ghi bảng C → đổi MỘT nhóm số → chơi lại. Đừng đổi nhiều thứ cùng lúc.

---

## Thêm sprite thật (khi có asset)
Mỗi thực thể đã tách hàm **`_build_visual()`** — đây là điểm DUY NHẤT cần đổi:
1. Lấy asset CC0: [Kenney](https://kenney.nl), itch.io (lọc CC0), hoặc tự vẽ bằng **Aseprite**.
2. Import vào `res://assets/`. Đảm bảo import filter = Nearest (đã set mặc định toàn project).
3. Trong `_build_visual()` của `player.gd` / `enemy.gd` / `boss.gd`: thay 2 dòng `Polygon2D` bằng
   `AnimatedSprite2D` + `SpriteFrames` (idle/walk/attack/hurt/death), giữ nguyên tên biến `_body`
   nếu vẫn muốn dùng cho flash (hoặc đổi `_flash()` sang `modulate` của AnimatedSprite2D).
4. Phần combat (Hitbox/Hurtbox) KHÔNG cần đổi — đã tách khỏi hình ảnh.

> Mình (Claude) có thể wire AnimatedSprite2D giúp khi bạn đã có pack sprite trong `assets/`.

## Giới hạn hiện tại (đã biết)
- Hình ảnh = placeholder Polygon2D (chưa có sprite).
- Chưa có âm thanh (AudioManager là stub).
- Chỉ 1 biome, 3 loại quái, 1 boss — đủ cho vertical slice, mở rộng ở phase sau.
- Online (leaderboard) chưa làm — Phase 5+.
