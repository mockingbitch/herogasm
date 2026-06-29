# Sprite: 0x72 Dungeon Tileset II (CC0)

Nguồn: https://0x72.itch.io/dungeontileset-ii  (Download → có thể đặt giá 0).

## Cần bỏ vào đây
Giải nén zip. Bên trong có thư mục **`frames/`** chứa từng frame animation rời
(vd `knight_m_idle_anim_f0.png`, `skelet_run_anim_f0.png`, `big_demon_idle_anim_f0.png`...).

➜ Copy nguyên thư mục `frames/` vào đây, sao cho thành:
```
game/assets/dungeon/frames/*.png
```
(Tuỳ chọn) copy luôn file tilesheet lớn `0x72_DungeonTilesetII_v1.x.png` vào `game/assets/dungeon/` nếu sau này muốn làm tile nền.

## Map sprite (Claude sẽ wire, có thể đổi)
| Trong game | Sprite 0x72 (dự kiến) |
|------------|------------------------|
| Player     | `knight_m` (idle/run) |
| Slime      | `swampy` / `tiny_zombie` |
| Dơi        | `imp` |
| Bộ xương   | `skelet` |
| Boss       | `big_demon` |

> License CC0 → không cần ghi nguồn, nhưng nên giữ file này để nhớ xuất xứ.
