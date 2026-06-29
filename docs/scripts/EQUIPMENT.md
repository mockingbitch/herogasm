# EQUIPMENT.md

# Equipment System

> *"Heroes become legends through the weapons they wield."*

---

# Design Philosophy

Equipment là hệ thống phát triển lâu dài của Hero.

Mục tiêu:

* Tạo động lực farm.
* Đa dạng cách build.
* Không có "best item" cho mọi Hero.
* Trang bị phải thay đổi lối chơi, không chỉ tăng chỉ số.

---

# Equipment Slots

Mỗi Hero có 8 ô trang bị.

```text
Hero
│
├── Weapon
├── Helmet
├── Armor
├── Gloves
├── Boots
├── Ring
├── Necklace
└── Artifact
```

*Mỗi Hero chỉ có thể sử dụng các loại trang bị phù hợp với Class và Profession.*

---

# Equipment Types

## Weapon

Quyết định phần lớn sức mạnh.

Ví dụ

* Sword
* Axe
* Spear
* Dagger
* Bow
* Staff
* Wand
* Orb
* Hammer

---

## Helmet

Tăng:

* HP
* Defense
* Resistance

---

## Armor

Tăng:

* HP
* Armor
* Magic Defense

---

## Gloves

Tăng:

* Attack Speed
* Critical Rate
* Accuracy

---

## Boots

Tăng:

* Speed
* Dodge
* Move Speed

---

## Ring

Trang bị thiên về sức mạnh.

Ví dụ

* Crit
* Lifesteal
* Mana Regen
* Skill Damage

---

## Necklace

Trang bị hỗ trợ.

Ví dụ

* Healing
* Cooldown
* Resistance
* Shield Power

---

## Artifact

Trang bị hiếm.

Không chỉ tăng chỉ số.

Có thể thay đổi cơ chế Skill.

Ví dụ

Phoenix Feather

↓

Ultimate hồi sinh thêm 1 Hero.

---

# Weapon Compatibility

Knight

* Sword
* Shield
* Spear

---

Warrior

* Sword
* Axe
* Hammer

---

Assassin

* Dagger
* Dual Blade

---

Mage

* Staff
* Wand
* Orb

---

Ranger

* Bow
* Crossbow

---

Support

* Staff
* Book
* Orb

---

# Equipment Rarity

```text
Common
↓
Uncommon
↓
Rare
↓
Epic
↓
Legend
↓
Mythic
↓
Ancient
```

Rarity quyết định:

* Số dòng chỉ số.
* Số ô nâng cấp.
* Hiệu ứng đặc biệt.

Không quyết định chiến thắng.

---

# Item Level

Mỗi trang bị có Item Level (iLv).

Ví dụ

iLv 10

↓

iLv 50

↓

iLv 100

↓

iLv 200

Item Level ảnh hưởng:

* Base Stats
* Roll giới hạn
* Yêu cầu Level Hero

---

# Equipment Quality

Ngay cả cùng một Item cũng có Quality.

Poor

Normal

Fine

Excellent

Perfect

Quality tăng Base Stats.

---

# Affixes

Mỗi trang bị có:

## Prefix

Ví dụ

* Strong
* Holy
* Frozen
* Burning

---

## Suffix

Ví dụ

* of Fury
* of Wisdom
* of Protection
* of Precision

Ví dụ

```text
Holy Sword of Fury
```

---

# Main Stats

Ví dụ

Weapon

+Attack

---

Armor

+Defense

---

Boots

+Speed

---

Helmet

+HP

---

# Secondary Stats

Có thể roll ngẫu nhiên.

Ví dụ

* Crit Rate
* Crit Damage
* Lifesteal
* Mana Regen
* Skill Haste
* Healing Bonus
* Block
* Accuracy
* Evasion
* Resistance
* Armor Penetration
* Magic Penetration

---

# Random Affix

Ví dụ

Epic Sword

Attack +320

Random

+8% Crit

+15 Speed

+5% Lifesteal

---

Legend Sword

Attack +340

Random

+12% Crit

+15% Skill Damage

+Burn Chance

---

# Legendary Effects

Một số Equipment có hiệu ứng riêng.

Ví dụ

Dragon Slayer

↓

+30% Damage lên Dragon.

---

Frozen Crown

↓

Freeze kẻ địch sau 10 đòn đánh.

---

Blood Ring

↓

Lifesteal tăng theo HP bị mất.

---

# Set Equipment

Một Set gồm nhiều món.

Ví dụ

Guardian Set

2 món

+10% Defense

4 món

+15% HP

6 món

Tạo Shield khi vào trận.

---

Shadow Set

2 món

+Crit

4 món

+Speed

6 món

Invisible trong 3 giây đầu.

---

# Enhancement

Trang bị có thể nâng cấp.

+1

↓

+5

↓

+10

↓

+15

↓

+20

Chỉ tăng Base Stats.

Không thay đổi hiệu ứng.

---

# Refinement

Refinement dùng để:

* Roll lại Secondary Stats.
* Không thay đổi Main Stats.

Giúp người chơi tối ưu build.

---

# Reforging

Reforge thay đổi:

* Prefix
* Suffix
* Hiệu ứng phụ

Có thể khóa một số dòng trước khi Reforge.

---

# Socket System

Một số Equipment có Socket.

Ví dụ

```text
Sword

Socket 1

Socket 2
```

Socket dùng để gắn:

* Rune
* Gem
* Crystal

---

# Durability

Không sử dụng hệ thống giảm độ bền.

Người chơi không cần sửa Equipment.

---

# Artifact

Artifact cực hiếm.

Ví dụ

Phoenix Feather

↓

Hồi sinh Hero đầu tiên tử trận.

---

Chrono Crystal

↓

Ultimate hồi nhanh hơn.

---

Dragon Heart

↓

Skill Fire mạnh hơn.

---

Void Core

↓

Bỏ qua 20% Defense.

Artifact thay đổi cách build Hero.

---

# Loot Sources

Equipment nhận từ:

* Dungeon
* Raid
* World Boss
* Guild Boss
* Event
* Crafting
* Shop
* Quest

Không có nguồn duy nhất.

---

# Crafting

Người chơi có thể:

* Ghép nguyên liệu.
* Chế tạo Equipment.
* Nâng cấp Rarity.
* Tạo Artifact.

Crafting không tạo ra Equipment mạnh hơn đồ rơi hiếm.

---

# Salvage

Equipment không dùng có thể phân rã.

Nhận:

* Gold
* Material
* Crystal
* Essence

Dùng cho Enhancement.

---

# Lock System

Trang bị quan trọng có thể khóa.

Không thể:

* Bán.
* Phân rã.
* Dùng làm nguyên liệu.

---

# Inventory

Trang bị được lọc theo:

* Class
* Rarity
* Level
* Set
* Stats
* Favorite

Giúp quản lý dễ dàng.

---

# Economy

Equipment là một phần của nền kinh tế.

Gold

↓

Enhancement

Material

↓

Crafting

Crystal

↓

Reforge

Essence

↓

Awakening Equipment

Mỗi tài nguyên đều có giá trị.

---

# Balancing Rules

Không tồn tại Equipment mạnh nhất.

Ví dụ

Sword A

Damage cao.

---

Sword B

Damage thấp hơn.

Nhưng

↓

Cooldown giảm.

↓

Skill mạnh hơn.

↓

Tốt hơn với Mage.

---

# Progression

```text
Loot
   │
   ▼
Identify
   │
   ▼
Equip
   │
   ▼
Enhance
   │
   ▼
Refine
   │
   ▼
Socket
   │
   ▼
Reforge
   │
   ▼
Awaken
```

---

# Design Principles

* Mỗi Equipment đều có nhiều hướng sử dụng.
* Trang bị hiếm không luôn tốt hơn nếu không phù hợp build.
* Người chơi luôn có mục tiêu farm tiếp.
* Không tạo khoảng cách quá lớn giữa người chơi mới và người chơi lâu năm.
* Build Equipment là một phần quan trọng của chiến thuật.

---

# Future Expansion

Hệ thống được thiết kế để mở rộng dễ dàng.

Có thể bổ sung:

* Equipment Fusion.
* Ancient Set.
* Seasonal Equipment.
* Cursed Equipment (mạnh nhưng có nhược điểm).
* Equipment Evolution.
* Hero Signature Weapon.
* Mythic Artifact.
* Equipment Transmogrification (đổi ngoại hình mà giữ chỉ số).

Mục tiêu là tạo ra hàng triệu tổ hợp Equipment khác nhau mà vẫn dễ cân bằng và dễ mở rộng trong nhiều năm phát triển.
