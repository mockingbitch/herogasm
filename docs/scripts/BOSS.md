# BOSS.md

# Boss System

> *"A true boss is not a stronger monster. It is a battle players will remember."*

---

# Design Philosophy

Boss không phải là Elite Monster.

Boss phải:

* Có cá tính riêng.
* Có nhiều giai đoạn chiến đấu.
* Có cơ chế đặc biệt.
* Yêu cầu thay đổi đội hình.
* Khuyến khích phối hợp Hero.

Mỗi Boss phải tạo cảm giác như một "trận đấu" chứ không chỉ là một mục tiêu có nhiều HP.

---

# Boss Categories

```text
Story Boss
│
├── Dungeon Boss
├── Elite Boss
├── Raid Boss
├── Guild Boss
├── World Boss
├── Ancient Boss
├── Seasonal Boss
└── Final Boss
```

---

# Story Boss

Xuất hiện trong Campaign.

Mục tiêu:

* Kết thúc Chapter.
* Giới thiệu cơ chế mới.
* Mở khóa nội dung tiếp theo.

Ví dụ

Chapter 1

↓

Black Knight

---

# Dungeon Boss

Boss của từng Dungeon.

Có:

* 2~3 Skill đặc biệt.
* 2 Phase.

Drop:

* Equipment.
* Material.
* Rune.

---

# Elite Boss

Độ khó cao hơn.

Xuất hiện:

* Hidden Room.
* Elite Dungeon.
* Random Event.

Drop:

* Epic Equipment.
* Rare Rune.

---

# Raid Boss

Boss nhiều giai đoạn.

Ví dụ

```text
100%

↓

Shield Phase

↓

70%

↓

Summon

↓

40%

↓

Destroy Arena

↓

15%

↓

Enrage
```

Raid Boss yêu cầu:

* nhiều Hero.
* nhiều Build.
* nhiều vai trò.

---

# Guild Boss

Toàn Guild cùng đánh.

Boss có HP rất lớn.

Damage của từng thành viên được cộng dồn.

Mỗi ngày chỉ có số lượt thử nhất định.

Phần thưởng dựa trên:

* Damage cá nhân.
* Damage Guild.
* Thứ hạng.

---

# World Boss

Toàn Server tham gia.

Boss xuất hiện theo lịch.

Ví dụ

Monday

Ancient Dragon

Tuesday

Titan

Wednesday

Kraken

Thursday

Phoenix

Friday

Lich King

Saturday

World Tree

Sunday

Azrath Avatar

Boss tồn tại trong thời gian giới hạn.

---

# Ancient Boss

Boss hiếm.

Điều kiện xuất hiện:

* Hoàn thành Quest.
* Kích hoạt Shrine.
* Sự kiện ngẫu nhiên.
* Seasonal Trigger.

Drop:

* Ancient Equipment.
* Legendary Rune.
* Artifact Fragment.

---

# Seasonal Boss

Boss theo Season.

Ví dụ

Season 1

Storm King

---

Season 2

Queen of Frost

---

Season 3

Abyss Leviathan

Season kết thúc.

Boss không còn xuất hiện.

---

# Final Boss

Azrath

Demon King.

Boss cuối cùng của cốt truyện chính.

Có:

* 5 Phase.
* Thay đổi Arena.
* Nhiều dạng kỹ năng.
* Nhiều Ending.

---

# Boss Mechanics

Boss có thể sử dụng:

* Shield.
* Summon.
* Heal.
* Berserk.
* Counter.
* Teleport.
* Charge.
* Arena Control.
* Environmental Damage.
* Time Limit.

Không Boss nào có toàn bộ cơ chế.

---

# Phase System

Boss mạnh dần theo thời gian.

Ví dụ

```text
100%

↓

Normal

↓

75%

↓

Summon

↓

50%

↓

Arena Break

↓

25%

↓

Enrage

↓

10%

↓

Ultimate
```

Mỗi Phase thay đổi AI và Skill.

---

# Weak Point

Một số Boss có điểm yếu.

Ví dụ

Dragon

↓

Wing

↓

Nếu phá cánh

↓

Boss không thể bay.

---

Stone Golem

↓

Crystal Core

↓

Phá Core

↓

Defense giảm.

---

# Break System

Boss có thanh Break.

```text
Boss

HP

Break Gauge
```

Khi Break đầy:

* Boss choáng.
* Nhận thêm Damage.
* Hủy Skill đang thi triển.

Một số Skill chuyên phá Break.

---

# Enrage

Nếu hết thời gian.

Boss:

* Damage +100%.
* Speed +50%.
* Không thể Stun.

Buộc người chơi tối ưu Damage.

---

# Arena Mechanics

Arena có thể thay đổi.

Ví dụ

Lava

↓

Damage theo thời gian.

---

Ice

↓

Hero bị Slow.

---

Poison

↓

Giảm Heal.

---

Darkness

↓

Accuracy giảm.

---

Lightning Storm

↓

Sét đánh ngẫu nhiên.

---

# Summoning

Boss có thể triệu hồi.

Ví dụ

Skeleton.

Wolf.

Totem.

Crystal.

Minion.

Một số Minion phải bị tiêu diệt trước.

---

# Boss AI

Boss có AI riêng.

Ví dụ

```text
Nếu HP < 50%

↓

Triệu hồi

↓

Nếu còn Minion

↓

Buff Minion

↓

Nếu Hero tập trung

↓

AoE

↓

Ultimate
```

Boss không đánh ngẫu nhiên.

---

# Interrupt

Một số Skill Boss có thể bị ngắt.

Ví dụ

Meteor

Cast

5 giây

↓

Interrupt

↓

Boss mất Skill.

Khuyến khích sử dụng Hero Control.

---

# Ultimate Mechanics

Boss Ultimate thường có cảnh báo.

Ví dụ

```text
WARNING

Meteor Incoming

5...

4...

3...

2...

1...
```

Người chơi cần:

* Break Boss.
* Giết Totem.
* Dùng Shield.
* Dùng Ultimate đúng lúc.

---

# Environmental Objects

Trong Arena có thể có:

Crystal.

Ballista.

Healing Fountain.

Bomb Barrel.

Magic Pillar.

Có thể tương tác để tạo lợi thế.

---

# Loot System

Boss có Loot Table riêng.

Ví dụ

Equipment.

Artifact.

Rune.

Material.

Pet Egg.

Cosmetic.

Title.

Mount.

Boss càng khó

↓

Loot càng tốt.

---

# Boss Difficulty

Normal

↓

Hard

↓

Nightmare

↓

Hell

↓

Mythic

↓

Chaos

Khác biệt:

* AI.
* Phase.
* Mechanics.
* Modifier.
* Loot.

Không chỉ tăng HP.

---

# First Clear Rewards

Lần đầu hạ Boss:

* Diamond.
* Title.
* Avatar.
* Achievement.
* Story Unlock.

---

# Weekly Rewards

Boss Reset mỗi tuần.

Người chơi có thể:

* Farm Material.
* Leo Ranking.
* Nhận Guild Reward.

---

# Boss Modifiers

Ví dụ

Burning Soul

↓

Boss miễn nhiễm Burn.

---

Holy Barrier

↓

Heal Boss theo thời gian.

---

Mirror Shield

↓

Phản Damage.

---

Blood Curse

↓

Hero mất HP liên tục.

Modifier thay đổi hàng tuần.

---

# Boss Progression

```text
Story Boss

↓

Dungeon Boss

↓

Elite Boss

↓

Raid Boss

↓

Guild Boss

↓

World Boss

↓

Ancient Boss

↓

Final Boss
```

---

# Balancing Rules

* Boss phải kiểm tra chiến thuật, không chỉ Battle Power.
* Mỗi Boss có ít nhất một cơ chế đặc trưng.
* Hero Control, Tank và Support luôn có vai trò.
* Không Boss nào miễn nhiễm mọi hiệu ứng.
* Boss khó hơn nhờ AI và Mechanics, không chỉ chỉ số.

---

# Future Expansion

Có thể bổ sung:

* Multi-Boss Battle (đánh hai Boss cùng lúc).
* Dynamic Boss AI (AI học theo người chơi).
* Random Mechanics mỗi lần vào.
* Mythic Raid nhiều Guild.
* Cross Server World Boss.
* Puzzle Boss.
* Time Attack Boss.
* Endless Boss Rush.
* Boss Creator cho Event đặc biệt.

Kiến trúc Boss được thiết kế theo hướng dữ liệu (Data-Driven), cho phép bổ sung Boss mới chỉ bằng việc khai báo Skill, AI và Mechanics mà không cần thay đổi Combat Engine.

---

# Boss Design Checklist

Mỗi Boss mới phải trả lời được các câu hỏi sau:

* Boss có câu chuyện và bản sắc riêng không?
* Người chơi có thể nhận biết Boss chỉ qua cách chiến đấu không?
* Boss có ít nhất một cơ chế độc quyền không?
* Có nhiều hơn một cách để vượt qua Boss không?
* Boss có buộc người chơi thay đổi đội hình hoặc Build không?
* Phần thưởng của Boss có xứng đáng với độ khó không?
* Sau khi hạ Boss nhiều lần, người chơi vẫn có lý do để quay lại không?

Nếu tất cả câu trả lời đều là **Có**, Boss đó đạt tiêu chuẩn để đưa vào game.
