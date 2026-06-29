# RUNE.md

# Rune System

> *"Equipment defines a hero's strength. Runes define how that strength is used."*

---

# Design Philosophy

Rune không phải là trang bị.

Rune là hệ thống **tùy biến lối chơi (Build Customization)**.

Mục tiêu:

* Thay đổi cách Hero hoạt động.
* Tạo nhiều hướng build.
* Thay đổi meta theo từng Season.
* Không bắt buộc một Rune duy nhất cho mọi Hero.

Rune phải trả lời câu hỏi:

> "Hero này sẽ chiến đấu theo phong cách nào?"

---

# Rune Overview

Mỗi Hero có:

```text
Hero
│
├── Rune Core
├── Rune Slot 1
├── Rune Slot 2
├── Rune Slot 3
└── Rune Slot 4
```

* **Rune Core**: quyết định hướng build chính.
* **Rune Slots**: bổ sung chỉ số và hiệu ứng.

---

# Rune Categories

## Offensive

Tăng khả năng gây sát thương.

Ví dụ

* Critical
* Attack
* Skill Damage
* Armor Penetration
* Execute

---

## Defensive

Tăng khả năng sống sót.

Ví dụ

* HP
* Defense
* Block
* Shield
* Damage Reduction

---

## Utility

Hỗ trợ chiến thuật.

Ví dụ

* Mana Regen
* Cooldown Reduction
* Speed
* Heal Bonus
* Buff Duration

---

## Control

Tăng khả năng khống chế.

Ví dụ

* Stun Chance
* Freeze Duration
* Silence
* Slow
* Taunt

---

## Summoner

Ảnh hưởng Pet hoặc Minion.

Ví dụ

* Pet Damage
* Summon HP
* Summon Duration

---

# Rune Core

Rune Core quyết định toàn bộ phong cách build.

Ví dụ

## Berserker Core

* +25% Attack
* -15% Defense

---

## Guardian Core

* +30% HP
* +15% Shield Power

---

## Assassin Core

* +40% Crit Damage

---

## Frost Core

* Ice Skill có thêm 20% Freeze Chance

---

## Holy Core

* Heal có thể tạo Shield

---

## Blood Core

* Skill tiêu hao HP
* Damage tăng mạnh

---

# Rune Quality

Common

↓

Rare

↓

Epic

↓

Legend

↓

Ancient

↓

Mythic

Quality quyết định:

* Số dòng chỉ số.
* Hiệu ứng đặc biệt.
* Số lần nâng cấp.

---

# Rune Affixes

Ví dụ

Rune of Precision

+5% Accuracy

+3% Crit

---

Rune of Fury

+6% Attack

+4% Lifesteal

---

Rune of Wisdom

+Mana Regen

+Cooldown

---

# Rune Effects

Một Rune có thể thay đổi gameplay.

Ví dụ

## Chain Rune

Skill đơn mục tiêu

↓

đánh lan thêm 2 mục tiêu.

---

## Echo Rune

20% cơ hội

↓

Skill kích hoạt lần thứ hai.

---

## Vampire Rune

Damage

↓

hồi HP.

---

## Blink Rune

Sau Ultimate

↓

dịch chuyển ra sau.

---

## Guardian Rune

Shield tồn tại lâu hơn.

---

## Execution Rune

Địch dưới 15% HP

↓

Damage tăng 40%.

---

# Rune Sets

Kết hợp nhiều Rune cùng hệ.

## Fire Set

2 Rune

+Burn Damage

4 Rune

Burn lan sang mục tiêu gần.

---

## Ice Set

2 Rune

+Freeze Chance

4 Rune

Địch bị Freeze nhận thêm Damage.

---

## Wind Set

2 Rune

+Speed

4 Rune

Sau khi né thành công

↓

đánh trả.

---

## Shadow Set

2 Rune

+Crit

4 Rune

Sau Crit

↓

Invisible 1 giây.

---

## Holy Set

2 Rune

+Heal

4 Rune

Heal dư

↓

chuyển thành Shield.

---

# Rune Upgrade

Rune có Level.

Level 1

↓

Level 20

Mỗi Level:

* tăng Main Stat
* mở khóa Effect mới ở Level 5 / 10 / 15 / 20

---

# Rune Fusion

3 Rune giống nhau

↓

1 Rune cao cấp hơn.

Ví dụ

3 Rare

↓

1 Epic

Fusion giữ lại:

* Main Effect

Roll lại:

* Affix

---

# Rune Resonance

Nếu Hero trang bị đúng tổ hợp.

Ví dụ

4 Fire Rune

↓

Fire Resonance

+15% Burn Damage

---

6 Holy Rune

↓

Holy Resonance

Heal tăng 25%.

---

# Seasonal Rune

Mỗi Season xuất hiện Rune mới.

Ví dụ

Season 1

Storm Rune

---

Season 2

Blood Rune

---

Season 3

Time Rune

Season kết thúc:

Rune vẫn dùng được.

Chỉ không còn farm.

---

# Rune Crafting

Người chơi có thể:

* Craft
* Upgrade
* Fuse
* Reforge

Không thể tạo Rune mạnh nhất ngay lập tức.

---

# Rune Reforge

Cho phép đổi:

* Secondary Stats
* Affix

Không đổi Core Effect.

---

# Rune Loadout

Một Hero có thể lưu nhiều Build.

Ví dụ

Raid Build

PvP Build

Guild War Build

Tower Build

Chuyển đổi chỉ với một nút bấm.

---

# Synergy

Rune có thể tương tác với:

* Hero
* Equipment
* Talent
* Artifact
* Pet

Ví dụ

Fire Mage

*

Fire Rune

*

Burn Staff

↓

Burn Build

---

Tank

*

Guardian Rune

*

Shield Artifact

↓

Immortal Build

---

# Balance Rules

Không có Rune bắt buộc.

Nếu 80% người chơi đều dùng một Rune

↓

Rune cần được điều chỉnh.

Meta phải luôn đa dạng.

---

# Build Examples

## Glass Cannon

* Berserker Core
* Crit Rune
* Attack Rune
* Execute Rune

Ưu điểm

Damage cực lớn.

Nhược điểm

Rất dễ chết.

---

## Immortal Tank

* Guardian Core
* HP Rune
* Shield Rune
* Heal Rune

Ưu điểm

Sống rất lâu.

Nhược điểm

Damage thấp.

---

## Cooldown Mage

* Mana Rune
* Skill Haste
* Arcane Rune

Ưu điểm

Spam Skill liên tục.

Nhược điểm

Damage mỗi lần thấp hơn.

---

## Vampire Warrior

* Blood Rune
* Lifesteal Rune
* Attack Rune

Ưu điểm

Solo Boss tốt.

Nhược điểm

Yếu trước Burst Damage.

---

# Design Principles

* Rune thay đổi gameplay, không chỉ tăng chỉ số.
* Mỗi Hero có ít nhất 3–5 hướng build khả thi.
* Rune mới phải mở ra chiến thuật mới thay vì thay thế Rune cũ.
* Hệ thống phải dễ mở rộng theo từng Season.
* Không tạo ra "Rune bắt buộc" cho mọi Hero.

---

# Future Expansion

Có thể mở rộng bằng:

* Rune Awakening.
* Rune Evolution.
* Hybrid Rune (kết hợp hai nguyên tố).
* Guild Rune.
* World Rune.
* Boss Rune.
* Corrupted Rune (mạnh hơn nhưng có hiệu ứng bất lợi).
* Legendary Rune chỉ nhận từ World Boss hoặc Raid.

Mục tiêu là xây dựng một hệ thống Rune đủ sâu để người chơi luôn có động lực thử nghiệm các cách build mới mà không làm mất cân bằng toàn bộ trò chơi.
