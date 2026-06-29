# Herogasm — Godot project

Project Godot 4.7. Đã validate compile + smoke-test headless (exit code 0).

## Cách chạy
1. Mở **Godot 4.7**, bấm **Import**, chọn `~/Desktop/Herogasm/game/project.godot`.
2. Bấm **▶ (F5)**. Cửa sổ 1152×648 (nội bộ 384×216) hiện ra.

Hoặc chạy nhanh từ terminal:
```bash
~/Downloads/Godot_v4.7-stable_linux.x86_64 --path ~/Desktop/Herogasm/game
```

## Vòng lặp
**Thị trấn (Hub)** → menu mua/bán/nâng cấp/talent → **Vào Dungeon** (farm) hoặc **Đấu Boss** → giết quái, nhặt vàng + đồ (affix ngẫu nhiên) → dọn sạch / hạ boss / chết → **E về thị trấn** → nâng cấp + học talent → lặp lại, mạnh dần. Tiến trình **tự lưu** (offline).

## Điều khiển
| Phím | Hành động |
|------|-----------|
| WASD / mũi tên | Di chuyển 8 hướng |
| J / Space / chuột trái | Đánh thường |
| K / Shift | Né (dodge, i-frame) |
| Q | Uống bình máu |
| E / I | Thị trấn: mở menu · Dungeon (khi kết thúc): về thị trấn |
| Esc / I | Đóng menu |

## Đang có (Phase 1–4) — Vertical Slice
- Pixel-perfect 384×216, renderer GL Compatibility (hợp mobile + máy yếu).
- 7 autoload: `EventBus`, `GameState`, `SaveManager` (lưu atomic + .bak), `Database` (content), `Profile` (hồ sơ bền vững + chỉ số), `AudioManager`/`NetManager` (stub, offline-first).
- Combat "feel": **swing + hit-stop + số sát thương + flash + knockback**, dodge i-frame, **crit + hút máu**.
- **Chỉ số từ trang bị:** ATK/DEF/HP/Tốc/Crit/Lifesteal từ `Profile`; giáp giảm sát thương; bình máu (Q).
- **Affix ngẫu nhiên:** mỗi gear roll affix theo độ hiếm (1–4) → farm có giá trị.
- **Cây talent:** 6 nhánh (Sức mạnh/Sinh lực/Chính xác/Hung tàn/Nhanh nhẹn/Hút máu); lên cấp nhận điểm.
- **Quái data-driven** (`EnemyData`): slime/dơi/bộ xương, rơi **vàng + item theo drop table**, cộng XP.
- **Boss 3 phase** (`Boss`): melee + lao (telegraph) + bắn đạn; thanh máu riêng; **drop đảm bảo** + nhiều gold/xp.
- **Thị trấn (HubMenu):** trang bị · túi đồ (trang bị/bán) · **lò rèn** · **cửa hàng** · **talent** · Vào Dungeon / Đấu Boss.
- **Lưu offline tự động** (gold/xp/level/talent/inventory + affix/equipment).
- Luồng scene: `hub.tscn` (main) ↔ `run.tscn` ↔ `boss_arena.tscn`.

> **Sprite thật:** 0x72 Dungeon Tileset II (CC0) — knight (player), swampy/imp/skelet (quái), big_demon (boss); animation idle/run + lật hướng. Vàng/đồ rơi vẫn là khối nhỏ (sẽ thay icon sau).

## Kiến trúc & lưu ý
- Scene dựng **bằng code** (script `class_name` + `.tscn` tối giản) để robust. Khi thêm art, refactor dần sang scene `.tscn` editor.
- **Combat dùng Area2D Hitbox/Hurtbox** (`systems/combat/`): va chạm chính xác theo hình + collision layer theo phe (không xuyên tường, không friendly-fire), i-frame qua hurtbox. ✅ C1 done.
- **Sprite (0x72, CC0):** dựng qua `systems/visual/sprite_lib.gd`; mỗi entity nạp trong `_build_visual()` (đổi sprite chỉ sửa 1 chỗ). Frame ở `assets/dungeon/`. Combat tách rời hình ảnh.
- Input đăng ký bằng code trong `autoload/game_state.gd` → TODO chuyển sang Project Settings > Input Map.

## Cấu trúc
```
game/
├── project.godot
├── icon.svg
├── autoload/      event_bus · game_state · save_manager · database · profile · audio_manager · net_manager
├── data/          item_data.gd · enemy_data.gd
├── actors/        player/player.gd · enemies/enemy.gd · boss/boss.gd
├── systems/combat/ health.gd · damage_number.gd · hurtbox.gd · hitbox.gd
├── systems/visual/ sprite_lib.gd
├── world/         pickup.gd · projectile.gd
├── ui/            hud.gd · hub_menu.gd · boss_bar.gd
├── assets/dungeon/ sprite 0x72 Dungeon Tileset II (CC0)
└── scenes/        hub.tscn/.gd (main) · run.tscn/.gd · boss_arena.tscn/.gd
```

Tài liệu thiết kế & lộ trình đầy đủ ở `../docs/` (GAME_DESIGN, ROADMAP, ARCHITECTURE, BUILD_PLAN).
