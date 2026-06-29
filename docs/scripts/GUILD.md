# GUILD.md

# Guild System

> *"A player can be strong alone. But a guild creates legacy."*

---

# Design Philosophy

Guild không chỉ là nhóm người chơi.

Guild là:

* Một cộng đồng chiến đấu
* Một nền kinh tế nhỏ
* Một hệ thống progression riêng
* Một đơn vị cạnh tranh PvE + PvP

Mục tiêu:

* Tạo gắn kết xã hội
* Giữ người chơi lâu dài
* Khuyến khích co-op nội dung khó
* Tạo meta cộng đồng

---

# Guild Structure

```text id="gq8m2c"
Guild
│
├── Leader
├── Officers
├── Members
└── Recruits
```

---

# Guild Features Overview

* Guild Level
* Guild Tech Tree
* Guild Shop
* Guild Boss
* Guild War
* Guild Dungeon
* Guild Events
* Guild Territory (optional)
* Guild Contribution System

---

# Guild Creation

Điều kiện:

* Level 20+
* Gold cost
* Name unique

Quyền lợi:

* Tạo guild emblem
* Guild chat
* Guild storage

---

# Guild Level

Guild tăng level bằng:

* Contribution
* Guild quests
* Guild boss damage
* Guild war participation

---

## Guild Level Benefits

* Mở slot member
* Mở Guild Tech
* Mở Guild Boss difficulty
* Tăng Guild reward multiplier

---

# Contribution System

Người chơi đóng góp:

* Gold
* Guild Quest
* Guild Boss damage
* Guild War participation

---

## Contribution Reward

* Guild Coin
* Personal Rank in Guild
* Weekly reward

---

# Guild Tech Tree

```text id="tx9k3p"
Combat Tech
│
├── Attack Boost
├── Defense Boost
├── HP Boost
│
Support Tech
│
├── Heal Bonus
├── Buff Duration
├── Mana Regen
│
Economy Tech
│
├── Gold Bonus
├── Drop Rate
├── Craft Discount
```

---

# Guild Shop

Dùng Guild Coin để mua:

* Rune Material
* Equipment Material
* Enhancement Items
* Cosmetic Guild Skins

Không bán Hero độc quyền.

---

# Guild Boss

## Concept

Boss riêng của guild.

* HP chung
* Tăng theo guild level
* Reset theo ngày/tuần

---

## Mechanics

* Damage tracking
* Phase-based boss
* Enrage after time limit

---

## Rewards

* Guild Coin
* Legendary material
* Guild ranking rewards

---

# Guild Dungeon

Co-op dungeon cho 3–5 người.

Đặc điểm:

* Difficulty scaling theo guild size
* Mechanics cần teamwork
* Shared reward pool

---

# Guild War

```text id="warflow"
Guild A vs Guild B
│
├── Defense Setup
├── Attack Phase
├── Point Calculation
└── Victory Reward
```

---

## Rules

* Mỗi member có limited attack attempts
* Defense đội hình tự động
* Tính điểm theo performance

---

## Victory Conditions

* Total damage
* Territory control (optional)
* Objective completion

---

# Guild Ranking

Các chỉ số xếp hạng:

* Guild Power
* Guild War Wins
* Guild Boss Damage
* Activity Score

---

# Guild Roles

## Leader

* Quản lý toàn bộ guild
* Phân quyền
* Kick / invite

## Officer

* Quản lý hoạt động
* Set guild war strategy

## Member

* Tham gia hoạt động
* Donate

---

# Guild Chat System

* Global guild chat
* Raid coordination chat
* War planning channel

---

# Guild Economy

Guild có economy riêng:

* Guild Coin
* Guild Storage
* Guild Tax (optional)

---

## Guild Storage

* Shared materials
* Equipment contribution
* Rune donation

---

# Guild Progression Loop

```text id="loop1"
Play game
  ↓
Earn resources
  ↓
Donate to guild
  ↓
Guild level up
  ↓
Unlock content
  ↓
Stronger guild
  ↓
Harder content
```

---

# Guild Events

* Guild Raid Week
* Boss Rush
* Resource Collection Event
* War Season

---

# Guild Territory (Optional Expansion)

Guild có thể:

* Chiếm vùng bản đồ
* Nhận buff khu vực
* Tranh chấp với guild khác

---

# Social Systems

* Friend list integration
* Guild recommendation system
* Active member detection
* Inactive cleanup system

---

# Anti-Abuse Systems

* Prevent alt spam guild farming
* Contribution decay for inactive players
* Cooldown khi rời guild

---

# Design Principles

* Guild phải tạo cảm giác “thuộc về”
* Không ép pay-to-win guild
* Activity quan trọng hơn power
* Co-op quan trọng hơn solo carry
* Guild mạnh = nhiều người hoạt động, không phải 1 whale

---

# Balance Goals

* 70–90% người chơi nên tham gia guild
* Guild activity quyết định reward, không chỉ power
* Guild top không chỉ dựa vào whale
* Guild yếu vẫn có thể phát triển nếu active

---

# Future Expansion

* Guild vs Guild Territory War
* Guild Dungeon Procedural
* Guild Skill System (shared buff tree)
* Guild Raid Boss World Scale
* Cross-server Guild Championship
* Guild Season System

---

# Final Vision

Guild không chỉ là feature.

Guild là:

> một “mini society” trong game, nơi người chơi tạo ra lịch sử, không chỉ farm tài nguyên.
