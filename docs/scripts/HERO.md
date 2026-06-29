# HERO.md

# Hero System

> *"Heroes are not defined by their rarity, but by the role they play on the battlefield."*

---

# Design Philosophy

Hero là trung tâm của toàn bộ trò chơi.

Mỗi Hero phải có:

* Vai trò rõ ràng
* Điểm mạnh
* Điểm yếu
* Có thể thay thế
* Không có Hero mạnh tuyệt đối

Mục tiêu là tạo ra nhiều cách xây dựng đội hình thay vì tạo Hero "phải sở hữu".

---

# Hero Structure

Mỗi Hero bao gồm:

```text
Hero
│
├── Name
├── Title
├── Race
├── Class
├── Personality
├── Trait
├── Element
├── Rarity
├── Statistics
├── Growth
├── Skills
├── Equipment
├── Rune
├── Talent Tree
├── Awakening
├── Skin
└── Story
```

---

# Hero Classes

## Tank

Vai trò

* Chịu sát thương
* Bảo vệ đồng đội
* Khống chế

Subclass

* Knight
* Paladin
* Guardian
* Shield Bearer

---

## Warrior

Vai trò

* Cận chiến
* Damage ổn định

Subclass

* Berserker
* Gladiator
* Samurai
* Viking

---

## Assassin

Vai trò

* Tiêu diệt tuyến sau
* Damage bùng nổ

Subclass

* Rogue
* Ninja
* Shadow Hunter
* Blade Dancer

---

## Ranger

Vai trò

* DPS tầm xa

Subclass

* Archer
* Hunter
* Gunner
* Elf Archer

---

## Mage

Vai trò

* Damage phép
* AoE

Subclass

* Fire Mage
* Ice Mage
* Lightning Mage
* Necromancer

---

## Support

Vai trò

* Heal
* Buff
* Debuff

Subclass

* Priest
* Bishop
* Oracle
* Druid

---

## Summoner

Vai trò

* Triệu hồi

Subclass

* Beast Master
* Demon Caller
* Spirit Walker

---

# Race

Mỗi Race mang đến lối chơi riêng.

| Race      | Đặc điểm     |
| --------- | ------------ |
| Human     | Cân bằng     |
| Elf       | Crit & Speed |
| Orc       | Attack       |
| Dwarf     | Defense      |
| Undead    | Lifesteal    |
| Angel     | Heal         |
| Demon     | Damage       |
| Dragonkin | Skill Damage |

Race KHÔNG quyết định Hero mạnh hay yếu.

---

# Element

Element chủ yếu ảnh hưởng đến Skill.

Fire

* Burn

Ice

* Freeze

Wind

* Speed

Earth

* Shield

Lightning

* Chain Damage

Holy

* Heal

Dark

* Curse

Poison

* Damage over Time

Arcane

* Pure Magic

Void

* Ignore Defense

---

# Rarity

Đề xuất không dùng SSR.

Thay vào đó:

```text
Common

↓

Elite

↓

Epic

↓

Legend

↓

Mythic
```

Rarity chỉ quyết định:

* Độ khó sở hữu
* Hiệu ứng hình ảnh
* Độ phức tạp của Skill

KHÔNG quyết định Hero mạnh hơn.

---

# Statistics

## Primary

HP

Attack

Defense

Magic Attack

Magic Defense

---

## Secondary

Speed

Critical Rate

Critical Damage

Accuracy

Evasion

Lifesteal

Block

Skill Haste

Healing Bonus

Resistance

Penetration

---

# Growth

Mỗi Hero có chỉ số tăng trưởng.

Ví dụ

HP Growth

★★★★☆

Attack Growth

★★★☆☆

Defense Growth

★★★★★

Magic Growth

★☆☆☆☆

Điều này khiến Hero khác nhau ngay cả khi cùng Class.

---

# Personality

Personality ảnh hưởng đến AI và Guild.

Ví dụ

Brave

* Luôn lao lên trước

Coward

* Luôn giữ khoảng cách

Greedy

+10% Gold

Loyal

+5% chỉ số khi cùng Guild lâu ngày

Hot-headed

Ultimate hồi nhanh hơn

Calm

Ưu tiên bảo vệ Support

---

# Trait

Trait là nội tại đặc biệt.

Ví dụ

Dragon Slayer

+30% Damage lên Dragon

Undead Hunter

+25% Damage lên Undead

Explorer

+10% Drop Rate

Lucky

+5% Rare Loot

Merchant

Giảm giá Shop

Master Blacksmith

Giảm phí nâng cấp Equipment

---

# Equipment Compatibility

Không phải Hero nào cũng dùng được mọi vũ khí.

Ví dụ

Knight

Sword

Shield

Heavy Armor

---

Mage

Staff

Orb

Robe

---

Assassin

Dagger

Dual Blade

Light Armor

---

Archer

Bow

Crossbow

Leather Armor

---

# Hero Skills

Mỗi Hero có:

1 Passive

3 Active

1 Ultimate

Ví dụ

Passive

Battle Instinct

Skill 1

Shield Bash

Skill 2

Charge

Skill 3

Taunt

Ultimate

Guardian Wall

---

# Talent Tree

Mỗi Hero có 3 nhánh.

Ví dụ Warrior

Attack

↓

Defense

↓

Berserk

Người chơi chỉ chọn một hướng phát triển chính.

---

# Awakening

Hero có thể thức tỉnh.

Awakening mở:

* ngoại hình mới
* Passive mới
* Ultimate nâng cấp
* Talent mới

Không tăng chỉ số quá nhiều.

---

# Hero Bond

Một số Hero có quan hệ đặc biệt.

Ví dụ

Knight Roland

*

Priest Elina

↓

Holy Alliance

+5% Heal

---

Dragon Hunter

*

Dragon Mage

↓

Dragon Slayer

+10% Damage Dragon

Bond chỉ là bonus nhỏ.

Không bắt buộc.

---

# AI Behavior

Hero không chỉ Auto đánh.

Mỗi Hero có AI.

Ví dụ

Tank

Ưu tiên:

* Boss
* Elite
* Hero gần nhất

---

Assassin

Ưu tiên:

* Mage
* Archer
* Support

---

Mage

Ưu tiên:

* Nhóm đông nhất

---

Priest

Ưu tiên:

* Đồng minh HP thấp nhất

---

Summoner

Ưu tiên:

* Triệu hồi khi đủ Mana

AI khác nhau giúp Hero có giá trị riêng.

---

# Progression

Hero Progression

```text
Recruit

↓

Level Up

↓

Ascend

↓

Talent

↓

Rune

↓

Equipment

↓

Awakening

↓

Legendary Hero
```

---

# Hero Roles In Content

Không Hero nào giỏi mọi thứ.

Ví dụ

| Hero        | Farm  | Raid  | PvP   | Guild |
| ----------- | ----- | ----- | ----- | ----- |
| Fire Mage   | ★★★★★ | ★★★   | ★★    | ★★★   |
| Ice Mage    | ★★★   | ★★    | ★★★★★ | ★★★   |
| Necromancer | ★★    | ★★★★★ | ★★    | ★★★★  |
| Paladin     | ★★★   | ★★★★★ | ★★★★  | ★★★★★ |

Điều này khuyến khích người chơi xây dựng nhiều đội hình.

---

# Balancing Rules

## Không buff Hero trực tiếp

Ưu tiên:

* Rune
* Equipment
* Talent
* Dungeon Buff
* Seasonal Buff

---

## Không tạo Hero "bắt buộc"

Hero mới phải:

* khác lối chơi
* không mạnh hơn Hero cũ

---

## Counter System

Tank

↓

đỡ Warrior

Warrior

↓

ép Ranger

Ranger

↓

khắc Mage

Mage

↓

diệt Tank

Assassin

↓

hạ Support

Support

↓

giúp Tank sống lâu

Không tồn tại đội hình bất bại.

---

# Long-term Goals

Mỗi Hero đều có thể sử dụng trong End Game.

Người chơi không bỏ Hero cũ chỉ vì Hero mới mạnh hơn.

Giá trị của Hero đến từ:

* Build
* Synergy
* Equipment
* Rune
* Talent
* Chiến thuật

Đây là triết lý cốt lõi của toàn bộ hệ thống Hero.
