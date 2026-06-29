# DUNGEON.md

# Dungeon System

> *"Every dungeon tells a story. Every victory builds a legend."*

---

# Design Philosophy

Dungeon không chỉ là nơi farm.

Mỗi Dungeon phải có:

* Cơ chế riêng
* Phần thưởng riêng
* Giá trị lâu dài
* Khuyến khích nhiều đội hình khác nhau

Người chơi không nên chỉ dùng một đội hình để vượt qua toàn bộ nội dung.

---

# Dungeon Categories

```text
Story Dungeon
│
├── Resource Dungeon
├── Equipment Dungeon
├── Rune Dungeon
├── Endless Tower
├── Elite Dungeon
├── Raid Dungeon
├── Guild Dungeon
├── Event Dungeon
├── Challenge Dungeon
└── World Dungeon
```

---

# Story Dungeon

Mục đích:

* Khám phá cốt truyện
* Mở bản đồ
* Mở Hero
* Mở tính năng

Mỗi Chapter gồm:

* 10~20 Stage
* Elite Stage
* Boss Stage

Ví dụ

```text
Chapter 1

1-1
1-2
1-3
...
1-10

↓

Boss
```

---

# Resource Dungeon

Dungeon farm tài nguyên.

## Gold Mine

Phần thưởng

* Gold

---

## EXP Temple

Phần thưởng

* Hero EXP

---

## Crystal Cave

Phần thưởng

* Crystal

---

## Enhancement Forge

Phần thưởng

* Equipment Material

---

## Awakening Shrine

Phần thưởng

* Awakening Stone

---

Mỗi ngày có số lượt miễn phí.

---

# Equipment Dungeon

Farm Equipment.

Boss thay đổi mỗi ngày.

Ví dụ

Monday

Sword

Tuesday

Armor

Wednesday

Helmet

Thursday

Boots

Friday

Ring

Saturday

Artifact

Sunday

All Equipment

---

# Rune Dungeon

Farm Rune.

Ví dụ

Fire Temple

↓

Fire Rune

---

Ice Temple

↓

Ice Rune

---

Holy Temple

↓

Holy Rune

---

Shadow Temple

↓

Shadow Rune

---

# Endless Tower

Leo tầng vô hạn.

Ví dụ

```text
Floor 1

↓

Floor 2

↓

Floor 3

↓

...

↓

Floor 999
```

Mỗi tầng:

* Buff khác nhau
* Quái khác nhau
* Boss khác nhau

Reset theo Season.

---

# Elite Dungeon

Độ khó cao.

Boss mạnh.

Không thể Auto ngay.

Drop:

* Epic Equipment
* Legendary Material

---

# Raid Dungeon

Nhiều Boss.

Boss có nhiều Phase.

Ví dụ

```text
Phase 1

↓

Destroy Shield

↓

Phase 2

↓

Summon

↓

Phase 3

↓

Enrage
```

Raid yêu cầu:

* nhiều Hero
* nhiều đội hình

---

# Guild Dungeon

Toàn Guild tham gia.

Guild cùng đánh Boss.

Boss có HP toàn server.

Phần thưởng:

* Guild Coin
* Guild EXP
* Guild Equipment

---

# Event Dungeon

Xuất hiện theo Event.

Ví dụ

Halloween

↓

Pumpkin Castle

---

Christmas

↓

Snow Fortress

---

Summer

↓

Ocean Temple

---

Phần thưởng:

* Skin
* Avatar
* Limited Equipment
* Event Currency

---

# Challenge Dungeon

Dungeon có luật riêng.

Ví dụ

## Mage Only

Chỉ Mage được vào.

---

## No Healing

Không được hồi máu.

---

## Double Speed

Toàn bộ Hero đánh nhanh gấp đôi.

---

## Poison Field

Toàn map bị Poison.

---

## One Life

Hero chết không hồi.

---

Mỗi tuần thay đổi.

---

# World Dungeon

Dungeon lớn.

Toàn server mở khóa.

Ví dụ

```text
Server

↓

World Event

↓

Open Dungeon

↓

Everyone joins

↓

Boss

↓

Reward
```

---

# Dungeon Difficulty

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

Độ khó ảnh hưởng:

* AI Boss
* Mechanics
* Loot Quality

Không chỉ tăng HP.

---

# Dungeon Modifiers

Mỗi Dungeon có Modifier.

Ví dụ

## Burning Land

Fire Damage +50%

---

## Frozen Ground

Hero di chuyển chậm.

---

## Darkness

Accuracy giảm.

---

## Holy Blessing

Heal mạnh hơn.

---

## Blood Moon

Toàn bộ Hero mất HP theo thời gian.

Modifier buộc người chơi thay đổi đội hình.

---

# Dungeon Random Events

Trong Dungeon có thể xảy ra:

Merchant

↓

Heal Shrine

↓

Treasure Room

↓

Hidden Boss

↓

Trap

↓

Puzzle

↓

Secret Door

Mỗi lần chơi đều khác nhau.

---

# Hidden Rooms

Có phòng bí mật.

Ví dụ

Phá tường

↓

Tìm Chest

↓

Mini Boss

↓

Legendary Chest

Khuyến khích khám phá.

---

# Boss Mechanics

Boss không chỉ mạnh hơn.

Boss có:

* Shield Phase
* Rage
* Weak Point
* Area Attack
* Summon
* Interrupt
* Environment Attack

Ví dụ

Dragon

↓

Bay lên

↓

Không thể đánh

↓

Đợi phá cánh

↓

Tiếp tục chiến đấu

---

# Dungeon Objectives

Không phải Dungeon nào cũng:

"Giết toàn bộ quái."

Ví dụ

Escort NPC

---

Protect Crystal

---

Destroy Totem

---

Collect Artifact

---

Escape

---

Survive

---

Kill Elite

---

Defend Base

---

# Rewards

Dungeon có Loot Table riêng.

Ví dụ

Equipment

Rune

Gold

Crystal

Material

Artifact Fragment

Pet Egg

Avatar

Skin

Title

Mỗi Dungeon đều có lý do để chơi.

---

# Energy System

Đề xuất:

Không giới hạn thời gian chơi bằng Energy.

Thay vào đó:

* Dungeon khó giới hạn số lượt mỗi ngày.
* Dungeon thường chơi không giới hạn.
* Event Dungeon dùng Event Ticket.

Giúp người chơi chủ động hơn.

---

# Auto Battle

Điều kiện mở:

* Đạt 3 sao.
* Hoàn thành lần đầu.

Có thể:

* Auto
* Auto Repeat
* Quick Clear (với Dungeon cũ)

---

# Difficulty Scaling

Không chỉ:

+200% HP

Mà còn:

* AI thông minh hơn.
* Boss thêm kỹ năng.
* Modifier mới.
* Phase mới.
* Cơ chế mới.

Ví dụ

Hard

Boss có thêm Summon.

---

Nightmare

Boss có thêm Shield.

---

Hell

Boss có thêm Enrage.

---

Chaos

Boss thay đổi Skill ngẫu nhiên.

---

# Seasonal Dungeon

Mỗi Season có Dungeon riêng.

Ví dụ

Season 1

Forgotten Castle

---

Season 2

Sky Temple

---

Season 3

Dragon Nest

Season kết thúc.

Dungeon biến mất.

Reward trở thành Collection.

---

# Daily Rotation

Ví dụ

Monday

Equipment

Tuesday

Rune

Wednesday

Gold

Thursday

EXP

Friday

Artifact

Saturday

Raid

Sunday

World Boss

Giúp nội dung luôn mới.

---

# Dungeon Progression

```text
Story

↓

Daily Dungeon

↓

Elite Dungeon

↓

Raid

↓

Guild Dungeon

↓

Endless Tower

↓

Mythic Dungeon

↓

Chaos Dungeon
```

Người chơi luôn có mục tiêu tiếp theo.

---

# Balancing Principles

* Không có Dungeon bắt buộc phải dùng một Hero duy nhất.
* Mỗi Dungeon khuyến khích nhiều đội hình khác nhau.
* Cơ chế quan trọng hơn việc tăng HP và Damage.
* Phần thưởng phải tương xứng với độ khó.
* Dungeon cũ vẫn có giá trị thông qua Crafting và Progression.

---

# Future Expansion

Hệ thống Dungeon được thiết kế để mở rộng liên tục.

Có thể bổ sung:

* Procedural Dungeon (bản đồ ngẫu nhiên).
* Rogue-like Dungeon (mỗi lượt chọn Buff).
* Puzzle Dungeon.
* Time Attack Dungeon.
* Survival Dungeon.
* Infinite Labyrinth.
* Cross Server Dungeon.
* Guild Expedition.
* Treasure Hunt.

Mỗi nội dung mới đều sử dụng chung Combat System và Hero System mà không cần thay đổi kiến trúc, giúp game có thể phát triển nhiều năm theo mô hình Live Service.
