# Herogasm — Build Plan A→Z (đến bản run & test được)

> Mục tiêu tài liệu này: chuỗi bước **thực thi tuần tự** từ thư mục trống đến một **bản playable test được** (di chuyển → đánh → giết quái → nhặt loot → nâng cấp → đua điểm offline).
> Mỗi bước có cổng **▶ Run & Test** — chỉ qua bước sau khi cổng hiện tại PASS.
>
> **Giả định mặc định (đổi được):** combat melee-first · chết mất một phần (không permadeath ở campaign) · base resolution 384×216 · Godot 4.x · GDScript.

**Quy ước:** mỗi bước = `Mục tiêu` → `Việc làm` → `▶ Run & Test (kết quả kỳ vọng)`.

---

## STAGE A — Môi trường & "Hello, it runs" (≈ nửa ngày)

### A1. Cài đặt & khởi tạo
- **Việc làm:**
  - Tải **Godot 4.x** (bản .NET không cần — ta dùng GDScript).
  - Tạo project mới tại `~/Desktop/Herogasm/game/` (giữ docs ở ngoài).
  - `git init`, thêm `.gitignore` cho Godot (`.godot/`, `export_presets.cfg` chứa key, `*.tmp`). Cài **Git LFS** cho `*.png *.wav *.ogg`.
- **▶ Run & Test:** mở Godot, bấm ▶ — cửa sổ trống hiện ra không lỗi. ✅

### A2. Cấu hình pixel-perfect (làm SỚM, tránh sửa sau đau)
- **Việc làm — Project Settings:**
  - `Display > Window > Viewport Width/Height = 384 / 216`.
  - `Display > Window > Stretch: Mode = canvas_items`, `Aspect = keep`.
  - `Rendering > Textures > Canvas Textures > Default Texture Filter = Nearest`.
  - `Display > Window > Window Width/Height Override = 1152 / 648` (×3 để dev cho dễ nhìn).
- **▶ Run & Test:** đặt 1 sprite pixel test (lấy tạm từ Kenney) — phóng to KHÔNG bị mờ, viền pixel sắc nét. ✅

### A3. Khung scene & autoload rỗng
- **Việc làm:**
  - Tạo cấu trúc thư mục theo `ARCHITECTURE.md`.
  - Tạo 5 autoload **rỗng** (chỉ `extends Node`): `GameState`, `SaveManager`, `AudioManager`, `EventBus`, `NetManager`. Đăng ký ở `Project Settings > Autoload`.
  - `EventBus` khai báo vài signal dùng chung:
    ```gdscript
    extends Node
    signal enemy_died(enemy, position)
    signal player_damaged(amount, current_hp)
    signal loot_dropped(item_id, position)
    signal gold_changed(total)
    ```
  - Tạo `scenes/main.tscn` (Node2D) làm điểm vào; set là Main Scene.
- **▶ Run & Test:** chạy `main.tscn`, không lỗi; in `print` từ một autoload thấy ở Output. ✅

---

## STAGE B — Player chạy được (≈ 1–2 ngày) → **mốc playable đầu tiên**

### B1. InputMap
- **Việc làm:** `Project Settings > Input Map`, tạo action: `move_up/down/left/right`, `attack`, `dodge`, `skill_1`. Gán **bàn phím + gamepad** (mobile thêm sau ở Stage J).
- **▶ Run & Test:** `print(Input.is_action_pressed("attack"))` phản hồi đúng khi bấm. ✅

### B2. Player di chuyển 8 hướng
- **Việc làm:** `actors/player/player.tscn` = `CharacterBody2D` + `Sprite2D` + `CollisionShape2D` + `Camera2D`.
  ```gdscript
  extends CharacterBody2D
  @export var speed: float = 90.0
  func _physics_process(_delta: float) -> void:
      var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
      velocity = dir * speed
      move_and_slide()
  ```
  Đặt player vào `main.tscn`, thêm vài `StaticBody2D` làm tường.
- **▶ Run & Test:** di chuyển 8 hướng mượt, đụng tường thì chặn, camera bám theo. ✅ **(Đây đã là bản run-test được đầu tiên.)**

### B3. Animation state cơ bản
- **Việc làm:** đổi `Sprite2D` → `AnimatedSprite2D` (hoặc `AnimationPlayer`). State: `idle`, `walk` (4 hướng hoặc lật ngang). Tách logic state ra `player_state.gd` đơn giản (enum) để combat sau dễ chèn.
- **▶ Run & Test:** đứng yên = idle, di chuyển = walk đúng hướng. ✅

---

## STAGE C — Combat "đã tay" (≈ 3–5 ngày) → **cột mốc FEEL**

### C1. Pattern Hitbox / Hurtbox (nền tảng cho cả game)
- **Việc làm:** quy ước 2 `Area2D`:
  - **Hurtbox** (vùng *nhận* đòn) — gắn lên mọi thực thể có máu, ở layer riêng.
  - **Hitbox** (vùng *gây* đòn) — bật theo frame đòn đánh, ở layer riêng, mang `damage`.
  - Hitbox phát hiện Hurtbox qua `area_entered`, gọi `take_damage()`.
  ```gdscript
  # hurtbox.gd  (Area2D)
  extends Area2D
  signal hurt(amount: int, source: Node)
  func receive(amount: int, source: Node) -> void:
      hurt.emit(amount, source)
  ```
  ```gdscript
  # hitbox.gd  (Area2D, bật khi đánh)
  extends Area2D
  @export var damage: int = 10
  func _on_area_entered(area: Area2D) -> void:
      if area is Hurtbox: area.receive(damage, owner)
  ```
- **▶ Run & Test:** in log khi hitbox chạm hurtbox; layer/mask cấu hình đúng (player hitbox chỉ chạm enemy hurtbox). ✅

### C2. Đánh thường + cảm giác
- **Việc làm:** action `attack` → bật hitbox theo hướng nhìn trong vài frame; thêm:
  - **Knockback** lên mục tiêu.
  - **Hit-stop** (đóng băng ~0.05s): `Engine.time_scale = 0.0` rồi `await get_tree().create_timer(0.05, true, false, true).timeout` (timer chạy theo real-time) → trả `time_scale = 1.0`.
  - **Screen shake** nhẹ (camera offset random tắt dần).
  - **Số sát thương** bay lên (Label2D pool).
- **▶ Run & Test:** đánh vào 1 ô tập (dummy có hurtbox) → thấy knockback + khựng hình + số damage. Cảm giác "đã". ✅

### C3. Dodge + Skill + cooldown
- **Việc làm:** `dodge` = lướt nhanh + **i-frame** (tắt hurtbox tạm thời). `skill_1` = 1 đòn mạnh có cooldown + UI cooldown nhỏ.
- **▶ Run & Test:** lăn xuyên đòn không mất máu; skill có thời gian hồi đúng. ✅

---

## STAGE D — Quái & vòng chiến đấu (≈ 3–5 ngày)

### D1. Base enemy + state machine
- **Việc làm:** `actors/enemies/base_enemy.tscn` (`CharacterBody2D` + Hurtbox + thanh máu). State: `idle → chase → attack → hurt → die`. Khi hết máu: `EventBus.enemy_died.emit(self, global_position)`.
- **▶ Run & Test:** quái phát hiện player → đuổi → đánh → bị đánh mất máu → chết & biến mất. ✅

### D2. Spawner + nhiều loại quái (data-driven)
- **Việc làm:** định nghĩa quái bằng **custom Resource** `EnemyData` (.tres): `max_hp`, `damage`, `speed`, `sprite`, `drop_table`. Làm 3 loại từ cùng base, khác data. `Spawner` đặt quái trong phòng.
- **▶ Run & Test:** vào phòng có 3 loại quái khác chỉ số/hình; dọn sạch được. ✅

---

## STAGE E — Loot & Inventory (≈ 3–5 ngày)

### E1. Drop table & nhặt đồ
- **Việc làm:** `DropTable` (Resource): danh sách `{item_id, weight, chance}`. Khi `enemy_died` → roll → spawn item rơi ra đất (Area2D, hút về player khi lại gần) → vào kho.
- **▶ Run & Test:** giết quái nhiều lần → đồ rơi theo tỉ lệ hợp lý (test bằng cách set chance=100% trước). ✅

### E2. Item data + Inventory + trang bị
- **Việc làm:** `ItemData` (Resource): `id`, `name`, `type` (weapon/armor/material/consumable), `rarity`, `affixes`. UI inventory (Control + GridContainer). Mặc/cởi trang bị → cập nhật chỉ số player.
- **▶ Run & Test:** mở kho thấy đồ vừa nhặt; mặc vũ khí → ATK tăng → đánh đau hơn thấy rõ. ✅

---

## STAGE F — Hub, kinh tế & SAVE (≈ 3–5 ngày) → **đóng vòng lặp lõi**

### F1. Vàng + Hub + Shop + Lò rèn
- **Việc làm:** `scenes/hub.tscn`: cổng vào vùng, NPC shop (mua/bán), lò rèn (nâng cấp +1/+2 tốn vàng + nguyên liệu). Chuyển cảnh Hub ↔ Run.
- **▶ Run & Test:** vào vùng farm → về hub → bán đồ lấy vàng → nâng cấp vũ khí → vào lại đánh mạnh hơn. ✅

### F2. SaveManager (offline) — **bắt buộc chắc chắn**
- **Việc làm:** lưu JSON ra `user://save_0.json` (ghi file tạm rồi `rename` cho atomic, giữ `.bak`). Lưu: nhân vật, inventory/trang bị, vàng/nguyên liệu, tiến trình, `save_version`.
- **▶ Run & Test:** chơi → thoát → mở lại → tiến trình còn nguyên. Thử làm hỏng file → game không crash, rơi về `.bak`. ✅

> 🎯 **Hết Stage F = vòng lặp lõi offline chơi được trọn vẹn, không cần mạng.** Đây là mốc test nội bộ quan trọng nhất.

---

## STAGE G — Progression & Boss (≈ 1–2 tuần) → **VERTICAL SLICE**

### G1. XP / Level / Talent
- **Việc làm:** giết quái → XP → lên level → tăng chỉ số + điểm talent. Cây talent nhỏ 6–10 node.
- **▶ Run & Test:** farm đủ XP → lên cấp → chọn talent → thấy sức mạnh thay đổi. ✅

### G2. Độ hiếm + affix ngẫu nhiên
- **Việc làm:** roll rarity theo tỉ lệ; mỗi món gắn 1–4 affix ngẫu nhiên (màu theo rarity). Đây là động lực farm.
- **▶ Run & Test:** farm ra nhiều món cùng loại nhưng chỉ số/affix khác nhau, màu khác nhau. ✅

### G3. Boss vùng (đa phase)
- **Việc làm:** boss có ≥2 phase, đòn có telegraph rõ, drop đảm bảo. Hạ boss → mở cờ "biome cleared".
- **▶ Run & Test:** đánh boss cảm thấy "ra trận", thắng có thưởng xứng đáng. ✅

> 🎯 **Hết Stage G = VERTICAL SLICE.** Bản demo 30–60 phút. **Đưa cho 3–5 người chơi thử & lấy phản hồi TRƯỚC khi đầu tư thêm content.**

---

## STAGE H — Chế độ đua rank (offline trước) (≈ 3–5 ngày)

### H1. Trial mode theo seed
- **Việc làm:** chế độ "Trial" dùng **một seed** để sinh map/quái cố định; tính **điểm** = độ sâu + số quái + thời gian. Hiện điểm cuối run. **Chạy hoàn toàn offline trước** (seed tự sinh cục bộ).
- **▶ Run & Test:** chạy Trial 2 lần cùng seed → map/quái giống hệt; điểm cao hơn khi chơi tốt hơn. ✅

> Đến đây bạn đã có **toàn bộ trải nghiệm test được offline**. Phần online (Stage I) chỉ là gắn leaderboard lên trên — game không phụ thuộc nó.

---

## STAGE I — Online (Supabase, lớp 30%) (≈ 1–2 tuần)
> Chi tiết schema/RLS/chống cheat ở `ARCHITECTURE.md`. Tóm tắt thứ tự:
1. Lập project Supabase, tạo bảng + bật RLS.
2. `NetManager`: auth ẩn danh → submit điểm qua **Edge Function** (không insert trực tiếp).
3. Server cấp **seed tuần**; client dùng seed đó cho Trial.
4. Hiện leaderboard top N + hạng của mình.
5. Cloud save: đẩy/kéo, xử lý xung đột (mới nhất thắng + cảnh báo).
- **▶ Run & Test:** submit điểm → thấy trên leaderboard; **tắt mạng → game vẫn chơi bình thường**, chỉ phần rank ẩn/thông báo offline. ✅

---

## STAGE J — Mobile + polish + launch
- Touch input (virtual joystick + nút), UI safe-area, tối ưu hiệu năng (atlas, draw call, 60fps máy thật).
- Audio, settings, localization (VI/EN), achievement/codex.
- Hardening chống cheat (recompute top N), telemetry, store prep.
- (Xem `ROADMAP.md` Phase 6–7.)

---

## Chiến lược test xuyên suốt
- **Manual run-test gate** ở mỗi bước (như trên) — đây là phương pháp chính cho gameplay/feel.
- **Unit test (GUT)** cho logic thuần, dễ vỡ — đáng làm sớm cho:
  - Tính sát thương (crit, def, affix).
  - Roll loot / drop table (tỉ lệ đúng qua N lần).
  - Serialize/deserialize save (round-trip + migration version).
- **Debug toggles** (autoload `Debug`): god-mode, drop 100%, +1000 vàng, spawn item theo id, nhảy thẳng vào boss. Tiết kiệm hàng giờ test.
- **Playtest ngoài** ngay sau VERTICAL SLICE (Stage G) — phản hồi sớm > đoán mò.

## Thứ tự ưu tiên nếu thiếu thời gian
A → B → C → D → E → F → **(dừng được để test vòng lặp)** → G → H → **(test được rank offline)** → I → J.
Có thể phát hành sớm bản PC offline + leaderboard cơ bản (đến hết I), để Stage J cho bản cập nhật.
```
