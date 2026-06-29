# SKILLS.md

# Skill System

> *"A hero is remembered not by their stats, but by the way they change the battlefield."*

---

# Design Philosophy

Skill không chỉ gây Damage.

Skill phải tạo ra quyết định chiến thuật.

Một Hero mạnh vì:

* cách dùng Skill
* thời điểm dùng Skill
* sự kết hợp với đồng đội

không phải vì Damage cao.

---

# Skill Structure

Mỗi Hero gồm:

```text
Passive
│
├── Active Skill 1
├── Active Skill 2
├── Active Skill 3
│
└── Ultimate Skill
```

---

# Skill Categories

## Passive

Luôn hoạt động.

Ví dụ

* +Attack
* +Crit
* Tăng Mana
* Hồi HP
* Giảm Cooldown
* Counter Attack

Passive không cần kích hoạt.

---

## Active

Tiêu hao Mana.

Có Cooldown.

Tự động sử dụng theo AI.

---

## Ultimate

Skill mạnh nhất.

Điều kiện:

* Full Mana
* Không bị Silence
* Không bị Stun

Ultimate có animation riêng.

---

# Skill Types

## Damage

Gây sát thương.

Ví dụ

Fireball

Slash

Arrow Rain

---

## Heal

Hồi máu.

Ví dụ

Holy Light

Nature Blessing

---

## Shield

Tạo lá chắn.

Ví dụ

Magic Barrier

Divine Protection

---

## Buff

Tăng sức mạnh.

Ví dụ

Attack Up

Crit Up

Speed Up

Mana Regen

---

## Debuff

Giảm sức mạnh đối phương.

Ví dụ

Armor Break

Slow

Curse

Weakness

---

## Crowd Control

Khống chế.

Ví dụ

Freeze

Fear

Sleep

Knock Up

Taunt

Root

Silence

---

## Summon

Triệu hồi.

Ví dụ

Wolf

Skeleton

Phoenix

Spirit

---

## Transformation

Biến hình.

Ví dụ

Werewolf

Dragon Form

Demon Form

---

## Utility

Skill đặc biệt.

Ví dụ

Teleport

Dash

Swap Position

Invisible

Clone

Reflect

Mana Burn

---

# Target Types

Một Skill có thể chọn:

Single Target

Random Target

Nearest Enemy

Lowest HP

Highest Attack

Backline

Frontline

All Enemy

All Ally

Area

Self

---

# Area of Effect

Single

Line

Circle

Cone

Cross

Global

Aura

Chain

Explosion

---

# Damage Elements

Fire

Ice

Wind

Earth

Lightning

Holy

Dark

Poison

Arcane

Void

Physical

True Damage

---

# Status Effects

## Fire

Burn

* Damage theo thời gian

---

## Ice

Freeze

* Không thể hành động

---

## Wind

Haste

* Tăng Speed

---

## Earth

Shield

* Tăng phòng thủ

---

## Lightning

Shock

* Có thể lan sang mục tiêu gần

---

## Holy

Blessing

* Hồi máu
* Xóa Debuff

---

## Dark

Curse

* Giảm chỉ số

---

## Poison

Poison

* Damage theo % HP

---

## Void

Rift

* Bỏ qua Defense

---

# Skill Scaling

Skill không chỉ scale theo Attack.

Ví dụ

Warrior

Attack

Tank

HP

Mage

Magic Attack

Priest

Healing Power

Summoner

Level Pet

Điều này tạo ra nhiều hướng build.

---

# Cooldown

Skill có:

Base Cooldown

↓

Skill Haste

↓

Cooldown thực tế

Ví dụ

Fireball

10s

Skill Haste

20%

Cooldown còn

8s

---

# Mana Cost

Ví dụ

Skill 1

20 Mana

Skill 2

35 Mana

Skill 3

50 Mana

Ultimate

100 Mana

Mana giúp cân bằng sức mạnh của Skill.

---

# Combo System

Một Skill có thể tương tác với Skill khác.

Ví dụ

Burn

*

Wind

↓

Fire Storm

---

Freeze

*

Lightning

↓

Shatter

---

Poison

*

Explosion

↓

Poison Explosion

---

Wet

*

Lightning

↓

Chain Lightning

---

Holy

*

Shield

↓

Holy Barrier

---

Dark

*

Curse

↓

Death Mark

---

# Skill Tags

Mỗi Skill có nhiều Tag.

Ví dụ

Fireball

* Fire
* Magic
* AoE
* Burn

---

Shield Bash

* Physical
* Tank
* Stun

---

Healing Rain

* Heal
* Holy
* Area

Tag giúp Equipment, Rune và Talent tương tác dễ dàng.

---

# Skill Levels

Level 1

↓

Level 2

↓

Level 3

↓

Level 4

↓

Level 5

Mỗi cấp:

* tăng Damage
* giảm Cooldown
* tăng Duration

Không thay đổi cơ chế.

---

# Skill Evolution

Sau Awakening

Skill có thể tiến hóa.

Ví dụ

Fireball

↓

Meteor

↓

Inferno

↓

World Flame

Không chỉ tăng Damage.

Có thể:

* đổi phạm vi
* thêm Burn
* thêm Explosion

---

# Passive Design

Passive nên thay đổi gameplay.

Không nên chỉ:

+20 Attack

Ví dụ

Sau mỗi 5 đòn đánh

↓

đòn tiếp theo gây True Damage

---

Hoặc

Mỗi khi đồng minh chết

↓

+10% Attack

---

Hoặc

Khi HP dưới 30%

↓

miễn nhiễm CC trong 5 giây

---

# Ultimate Design

Ultimate phải:

* đẹp
* dễ nhận biết
* thay đổi trận đấu

Ví dụ

Phoenix Rebirth

↓

Hồi sinh toàn đội

---

Black Hole

↓

Hút toàn bộ quái

---

Dragon Fury

↓

Rồng xuất hiện tấn công toàn màn hình

---

Time Stop

↓

Dừng thời gian 3 giây

---

# AI Priority

Ultimate

↓

Skill hỗ trợ

↓

Skill Damage

↓

Basic Attack

Nếu điều kiện không phù hợp

↓

AI sẽ bỏ qua Skill.

Ví dụ

Heal

↓

Không dùng nếu toàn đội đầy máu.

---

# Interrupt

Một số Skill có thể:

* ngắt Ultimate
* phá Shield
* xóa Buff
* xóa Debuff

Điều này tạo chiều sâu PvP.

---

# Skill Synergy

Ví dụ

Tank

↓

Taunt

↓

Mage

↓

Meteor

↓

Assassin

↓

Finish Target

↓

Priest

↓

Heal

Không Hero nào mạnh nếu đứng một mình.

---

# Boss Skills

Boss sử dụng cơ chế riêng.

Ví dụ

Meteor

Toàn bản đồ

---

Summon

Triệu hồi Elite

---

Enrage

+100% Damage

---

Destroy Arena

Thay đổi địa hình

---

# Skill Balancing

Ưu tiên cân bằng bằng:

* Mana Cost
* Cooldown
* Casting Time
* Range
* AI Priority
* Effect Duration

Không chỉ giảm Damage.

---

# Design Rules

✅ Mỗi Hero phải có ít nhất một Skill tạo dấu ấn riêng.

✅ Không có hai Hero trùng bộ kỹ năng hoàn toàn.

✅ Skill mới phải mở ra cách chơi mới, không chỉ có hệ số Damage lớn hơn.

✅ Ultimate phải đủ mạnh để thay đổi cục diện, nhưng không được quyết định thắng thua ngay lập tức.

✅ Mọi hiệu ứng (Buff, Debuff, CC, Heal, Shield...) đều phải có giới hạn và cách đối phó để tránh tạo meta mất cân bằng.

---

# Future Expansion

Hệ thống Skill được thiết kế để dễ mở rộng:

* Thêm nguyên tố mới (Blood, Time, Metal...)
* Thêm loại hiệu ứng mới.
* Thêm Combo giữa nhiều Hero.
* Thêm Rune thay đổi hành vi Skill.
* Thêm Artifact biến đổi Skill.
* Thêm Hero có cơ chế hoàn toàn mới mà không cần thay đổi Combat System.

Mục tiêu là có thể phát triển hàng nghìn Hero trong nhiều năm mà vẫn giữ được sự đa dạng và cân bằng của gameplay.
