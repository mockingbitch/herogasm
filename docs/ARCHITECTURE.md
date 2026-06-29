# Herogasm — Kiến trúc kỹ thuật

## 1. Engine & cấu hình pixel art (Godot 4)

- **Engine:** Godot 4.x, **GDScript** (đủ cho solo; chỉ chuyển C#/GDExtension nếu profiler chỉ ra hot path thật sự).
- **Độ phân giải gốc:** đề xuất **384×216** (16:9), scale nguyên lần lên 1080p (×5) / 4K.
- **Project Settings cần đặt:**
  - `display/window/stretch/mode = canvas_items` (hoặc `viewport` nếu muốn pixel-perfect tuyệt đối), `aspect = keep`.
  - `rendering/textures/canvas_textures/default_texture_filter = Nearest` (chống mờ pixel).
  - Tắt mipmap cho sprite; bật **pixel snap** (`rendering/2d/snap/...`) nếu thấy sprite rung.
  - Import sprite: filter = Off, mipmaps = Off.
- **Camera:** dùng `Camera2D` có giới hạn + smoothing nhẹ; cân nhắc pixel-perfect camera (snap theo lưới) để tránh "jitter".

## 2. Cấu trúc thư mục đề xuất

```
res://
├── autoload/            # Singleton (Project Settings > Autoload)
│   ├── game_state.gd     # tiến trình, vàng, level hiện tại
│   ├── save_manager.gd   # đọc/ghi save offline
│   ├── audio_manager.gd  # nhạc + SFX
│   ├── event_bus.gd      # signal toàn cục (giảm coupling)
│   └── net_manager.gd     # giao tiếp Supabase (auth, leaderboard, cloud save)
├── actors/
│   ├── player/           # player.tscn + player.gd + state machine
│   └── enemies/          # base_enemy + từng loại quái
├── systems/
│   ├── combat/           # hitbox, hurtbox, damage, status effect
│   ├── loot/             # drop_table.gd (Resource), item rơi
│   ├── inventory/
│   └── progression/      # xp, level, talent
├── data/                 # Custom Resource (.tres): item, quái, drop table, biome
│   ├── items/
│   ├── enemies/
│   └── biomes/
├── world/
│   ├── rooms/            # room template để ghép procedural
│   └── biomes/
├── ui/                   # HUD, inventory, shop, leaderboard, menu
├── assets/               # sprite, tileset, sfx, music, font
└── scenes/               # main.tscn, hub.tscn, run.tscn
```

**Nguyên tắc kiến trúc:**
- **Data-driven:** quái, item, drop table, affix... định nghĩa bằng **custom `Resource` (.tres)** chứ không hard-code → dễ cân bằng & thêm content.
- **Tách hệ thống bằng `EventBus`** (autoload phát signal) để UI/audio/gameplay ít phụ thuộc nhau.
- **State machine** cho player & enemy (mỗi state 1 file/node) để combat dễ mở rộng.

## 3. Save system (offline — lõi 70%)

- **Định dạng:** JSON (`user://save_*.json`) cho dễ debug/versioning, hoặc `ResourceSaver` nếu muốn gọn.
- **Versioning:** mỗi save ghi `save_version`; viết migration khi đổi cấu trúc.
- **An toàn:** ghi ra file tạm rồi rename (atomic) để tránh hỏng giữa chừng; giữ 1 bản backup `.bak`.
- **Nội dung save:** nhân vật (level/xp/stats/talent), inventory + trang bị, vàng/nguyên liệu, tiến trình biome, settings, `last_synced_at` (cho cloud).
- **KHÔNG** phụ thuộc mạng để chơi — cloud chỉ là bản đồng bộ.

## 4. Backend online (lớp 30%) — Supabase

Vì là solo + BaaS, **Supabase** là lựa chọn tốt: Postgres + Auth + RLS + Edge Functions (Deno/TypeScript), free tier hào phóng, kiểm soát bằng SQL.
(So sánh: *Firebase* hợp mobile/realtime nhưng NoSQL khó cho leaderboard SQL; *PlayFab* chuyên game-economy/leaderboard nhưng ít linh hoạt & khoá vào Microsoft.)

**Godot ↔ Supabase:** dùng node `HTTPRequest` gọi REST/RPC, hoặc addon cộng đồng `godot-supabase`. Bọc tất cả trong `net_manager.gd`.

### Schema gợi ý (Postgres)

```sql
-- Hồ sơ người chơi (1-1 với auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz default now()
);

-- Cloud save (đồng bộ PC <-> mobile)
create table cloud_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null,          -- nội dung save (nén/encode tuỳ ý)
  save_version int not null,
  updated_at timestamptz default now()
);

-- Bảng xếp hạng theo mùa/seed
create table leaderboards (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  mode text not null,              -- 'trial_weekly' | 'boss_rush'
  season text not null,            -- '2026-W26' ...
  seed bigint not null,            -- seed của tuần (Trial)
  score bigint not null,           -- điểm (Trial) hoặc -time_ms (boss rush)
  run_id uuid,                     -- trỏ tới replay/log để verify
  created_at timestamptz default now()
);
create index on leaderboards (mode, season, score desc);

-- Log run để validate top scores (tuỳ chọn nhưng nên có)
create table runs (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  seed bigint not null,
  inputs jsonb,                    -- input/sự kiện đủ để recompute điểm
  reported_score bigint not null,
  created_at timestamptz default now()
);
```

### RLS (Row Level Security) — bật cho MỌI bảng
- `profiles` / `cloud_saves`: user chỉ đọc/ghi dòng `id = auth.uid()`.
- `leaderboards`: **đọc công khai**; **insert** chỉ qua Edge Function (service role), KHÔNG cho client insert trực tiếp → tránh nhét điểm bừa.

## 5. Luồng submit điểm & chống gian lận

> Điểm tính ở máy client (offline) ⇒ phải coi mọi client là không đáng tin. Chiến lược thực dụng cho game nhỏ:

1. **Seed do server cấp:** mỗi tuần server công bố `seed` cho chế độ Trial. Mọi người chơi cùng map/quái → so điểm công bằng.
2. **Submit qua Edge Function** (không insert trực tiếp): client gửi `{seed, score, inputs/run_log}`. Function:
   - Kiểm `seed` khớp tuần hiện tại.
   - **Sanity bounds:** chặn điểm > trần lý thuyết, tốc độ tăng điểm bất khả thi, thời gian run quá ngắn.
   - Lưu `runs.inputs` để có thể **recompute** điểm bằng simulation headless (làm cho top N).
3. **Verify top entries:** chỉ cần re-simulate top ~50–100 (server-side hoặc job định kỳ) — chi phí thấp, hiệu quả cao.
4. **Cờ outlier / thống kê:** đánh dấu điểm lệch chuẩn để review.
5. **Ký + obfuscate nhẹ ở client** chống sửa bộ nhớ ngây thơ (không phải bảo mật thật, chỉ nâng rào).

> Mức độ đầu tư chống cheat **tỉ lệ với số người chơi**. Ở MVP: chỉ cần bounds-check + seed server. Hardening (recompute/replay) để Phase 7. Đừng over-engineer sớm.

## 6. Đa nền tảng (PC + Mobile từ một project)

- **Input trừu tượng hoá:** map hành động qua `InputMap` (move/attack/dodge/skill), thêm lớp **virtual joystick + nút cảm ứng** cho mobile. Tự động ẩn/hiện theo `DisplayServer`/loại thiết bị.
- **UI co giãn:** dùng `Control` + anchor + `CanvasLayer`; xử lý **safe area** (tai thỏ) trên mobile.
- **Hiệu năng mobile:** atlas hoá texture, gộp draw call, giới hạn particle, tránh `_process` nặng — đo bằng profiler trên máy thật. Target 60fps, fallback 30fps máy yếu.
- **Export:** PC (Windows/Linux/macOS), Android (.aab cho Google Play), iOS (cần macOS + Xcode + tài khoản Apple Developer).

## 7. Addon/tool gợi ý
- **Aseprite** — vẽ pixel art + animation (import vào Godot qua plugin).
- **Tiled** hoặc TileMapLayer của Godot 4 — dựng map.
- **godot-supabase** (addon cộng đồng) hoặc tự bọc `HTTPRequest`.
- **Git + Git LFS** cho asset nhị phân (sprite/audio).
- **GUT** (Godot Unit Test) — test logic combat/loot/save (đáng làm cho hệ thống dễ vỡ).

## 8. Thứ tự dựng kỹ thuật (khớp Roadmap)
1. Autoloads rỗng + InputMap + cấu hình pixel (Phase 0).
2. Player state machine + combat hitbox/hurtbox (Phase 1).
3. Resource cho enemy/item/drop + spawner + loot (Phase 2).
4. SaveManager + inventory + hub (Phase 2).
5. Progression (xp/talent) + boss (Phase 3).
6. NetManager + Supabase (Phase 4).
7. Mobile input/UI/tối ưu (Phase 6).
