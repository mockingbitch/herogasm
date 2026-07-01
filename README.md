# Herogasm

> *"A tiny fantasy kingdom that keeps living even when the player does nothing."*

Herogasm là game **living-world idle RPG** (pixel-art 2D) lấy cảm hứng từ **Evil Hunter Tycoon**. Bạn là **chủ thành**, không phải anh hùng: hero **tự sống** — tự rời cổng đi săn, tự về nghỉ / sửa đồ / mua sắm; thành và thế giới vận hành cả khi offline. Bạn xây thành, sưu tập & build hero, để **auto-battle** lo phần đánh đấm, và thế giới đổi thay theo từng **Season gắn với cốt truyện**.

- **Thể loại:** Idle/AFK · Hero-Collection · Base-building · Auto-battle
- **Engine:** Godot 4.x · Typed GDScript
- **Nền tảng:** Mobile-first (Android, portrait, one-handed, 60fps) + PC
- **Online:** Supabase (lớp sync — game vẫn chơi offline trọn vẹn)
- **Bối cảnh:** vương quốc đổ nát *Kingdom of Ashes*, lục địa Azerath, bị Abyss xâm thực

## Tài liệu chuẩn (nguồn sự thật)

| Nguồn | Nội dung |
|-------|----------|
| [CLAUDE.md](CLAUDE.md) | Master instructions: gameplay pillars, kiến trúc, rules/agents/skills, philosophy |
| [.claude/rules/](.claude/rules/) | 24 rule bắt buộc (architecture, ai, world, economy, save-system, testing, simulation, performance…) |
| [docs/scripts/](docs/scripts/) | Design bible: GDD, HERO, COMBAT, SKILLS, EQUIPMENT, RUNE, DUNGEON, BOSS, GUILD, PVP, EVENTS, ECONOMY, BALANCE, STORY, WORLD |
| [PLAN.md](PLAN.md) | **Kế hoạch phát triển chi tiết theo 7 phase** + kiến trúc chung + Phụ lục Season↔Story, công thức combat, chỉ mục Resource |

## Nguyên tắc xuyên suốt

1. **Simulation-first.** Luôn xây *hệ thống*, không xây gameplay rời rạc. Thế giới phải "sống".
2. **Hero tự trị (Utility AI).** Người chơi *ảnh hưởng*, không *điều khiển*. Hành vi phải nổi lên (emergent).
3. **Offline là xương sống.** Game chơi trọn vẹn khi mất mạng; online (Supabase) chỉ là lớp sync/leaderboard/cloud-save.
4. **Data-driven + kỷ luật sản xuất từ đầu.** Test / simulation / telemetry / performance (mục tiêu 300 hero · 1000 monster · 60fps) không để dồn cuối dự án.

## Trạng thái

Repo có sẵn một vertical slice cũ theo hướng **action-RPG** ở `game/` (điều khiển tay, hitbox/hurtbox). Hướng này **đã bị bỏ**; slice sẽ được archive sang branch `archive/action-slice` ở Phase 0. Phần math kinh tế/stat/affix và khung autoload/save được giữ lại tái sử dụng.
