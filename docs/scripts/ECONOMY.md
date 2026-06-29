# ECONOMY.md

# Economy System

> *"A healthy economy keeps players progressing, not grinding forever."*

---

# Design Philosophy

Mọi tài nguyên trong game phải có:

* Nguồn tạo (Source)
* Nơi tiêu (Sink)
* Giá trị lâu dài
* Giới hạn hợp lý

Không có tài nguyên nào được tạo ra mà không có nơi tiêu thụ.

---

# Economy Layers

```text id="z8m1ga"
Premium Currency
│
├── Soft Currency
├── Hero Resources
├── Equipment Resources
├── Rune Resources
├── Guild Resources
├── Event Resources
└── Collection Resources
```

---

# Currency Overview

| Currency         | Mục đích         |
| ---------------- | ---------------- |
| Gold             | Currency chính   |
| Diamond          | Premium          |
| Crystal          | Enhancement      |
| Essence          | Hero Progression |
| Honor            | PvP Shop         |
| Guild Coin       | Guild Shop       |
| Event Token      | Event Shop       |
| Ancient Fragment | End Game         |
| Soul Stone       | Hero Awakening   |

---

# Gold

Nguồn:

* Dungeon
* Quest
* Boss
* Daily
* Sell Equipment

Tiêu:

* Enhance Equipment
* Craft
* Upgrade Skill
* Reset Talent
* Shop

Gold luôn có nhu cầu sử dụng.

---

# Diamond

Premium Currency.

Nguồn:

* Achievement
* Arena
* Event
* Story
* Battle Pass
* Purchase

Tiêu:

* Summon
* Inventory
* Cosmetic
* Convenience
* Event Pass

Không dùng để mua sức mạnh trực tiếp.

---

# Crystal

Nguồn:

* Dungeon
* Raid
* Salvage

Tiêu:

* Equipment Enhancement
* Reforge
* Artifact Upgrade

---

# Essence

Nguồn:

* Story
* Dungeon
* Hero Trial

Tiêu:

* Hero Level
* Skill Upgrade
* Awakening

---

# Hero Economy

```text id="jlwmzo"
Hero

↓

EXP

↓

Level

↓

Skill

↓

Awakening

↓

Ascension
```

Mỗi giai đoạn dùng tài nguyên khác nhau.

---

# Equipment Economy

```text id="6slmjl"
Loot

↓

Enhance

↓

Refine

↓

Socket

↓

Reforge

↓

Awaken
```

Không dùng chung tài nguyên Hero.

---

# Rune Economy

```text id="njlwmc"
Rune Drop

↓

Upgrade

↓

Fusion

↓

Reforge

↓

Awaken
```

Rune có vòng đời riêng.

---

# Resource Sources

Nguồn tài nguyên được phân bổ:

Daily

Weekly

Monthly

Seasonal

Story

Guild

PvP

Raid

Không phụ thuộc vào một chế độ chơi.

---

# Resource Sinks

Mọi Currency đều phải có nơi tiêu.

Ví dụ

Gold

↓

Upgrade

↓

Craft

↓

Reset

↓

Guild Donation

↓

Auction Fee

---

Diamond

↓

Cosmetic

↓

Convenience

↓

Summon

↓

Event Pass

---

# Inflation Control

Không tăng Gold Reward vô hạn.

Thay vào đó:

* Mở tính năng mới.
* Thêm Sink mới.
* Thêm Collection.

Giữ Gold luôn có giá trị.

---

# Catch-Up Economy

Người chơi mới:

Nhận Bonus.

Ví dụ

EXP x2

Gold x2

Story Reward tăng

Nhưng End Game vẫn cần đầu tư.

---

# Daily Economy

Người chơi mỗi ngày nhận khoảng:

* Gold
* Crystal
* Rune
* Equipment
* Arena Coin
* Guild Coin

Đủ để luôn có tiến bộ.

---

# Weekly Economy

Nguồn chính:

* Raid
* Guild War
* World Boss
* Endless Tower

Reward lớn hơn Daily.

---

# Seasonal Economy

Season thêm:

* Currency mới
* Shop mới
* Collection mới

Season cũ không mất giá.

---

# Crafting Economy

Craft cần:

* Gold
* Material
* Crystal

Không dùng Diamond.

---

# Salvage Economy

Equipment không dùng

↓

Material

↓

Crystal

↓

Essence

↓

Rune Dust

Mọi Loot đều có giá trị.

---

# Auction House (Optional)

Nếu có Trade.

Cho phép:

* Equipment
* Material
* Cosmetic

Không Trade:

* Hero
* Premium Currency
* Quest Item

Có Tax để chống lạm phát.

---

# Guild Economy

Guild có:

Guild Coin

Guild EXP

Guild Resource

Guild Donation

Guild Technology

Guild Store

Khuyến khích hợp tác.

---

# PvP Economy

Arena Coin

↓

Arena Shop

Guild Medal

↓

Guild Shop

Champion Medal

↓

Season Shop

Không ảnh hưởng PvE quá nhiều.

---

# Event Economy

Mỗi Event:

Currency riêng.

Ví dụ

Pumpkin Coin

↓

Halloween Shop

Season kết thúc.

Currency hết hạn.

---

# Monetization Philosophy

Người chơi trả tiền để:

* Tiết kiệm thời gian.
* Mua Cosmetic.
* Battle Pass.
* Skin.
* Convenience.

Không mua chiến thắng.

---

# Premium Shop

Bán:

* Skin
* Mount
* Avatar
* Emote
* Name Card
* Battle Pass

Không bán Hero mạnh độc quyền.

---

# Battle Pass

Free Track

Premium Track

Reward:

* Cosmetic
* Material
* Resource

Không tạo khoảng cách lớn.

---

# First Purchase

Ví dụ

Starter Pack

* Skin
* Avatar
* Gold
* Material

Không có Hero độc quyền.

---

# Whale Protection

Whale mạnh hơn.

Nhưng:

* Không thể mua kỹ năng.
* Không thể mua AI.
* Không thể mua chiến thuật.

Skill vẫn quyết định.

---

# Free-to-Play Philosophy

F2P có thể:

* Thu thập mọi Hero.
* Hoàn thành Story.
* Tham gia PvP.
* Farm End Game.

Chỉ chậm hơn.

---

# Economy Balancing

Theo dõi:

* Gold tạo mỗi ngày.
* Gold tiêu mỗi ngày.
* Tỷ lệ Diamond giữ lại.
* Craft Rate.
* Salvage Rate.

Nếu Source > Sink quá lâu

↓

Lạm phát.

---

# Live Economy Dashboard

Developer theo dõi:

* Gold Inflation
* Item Inflation
* Rune Usage
* Hero Usage
* Shop Purchase
* Auction Volume
* Craft Frequency

Dữ liệu dùng để cân bằng.

---

# Seasonal Reset

Không reset:

* Hero
* Equipment
* Rune
* Story

Chỉ reset:

* Rank
* Leaderboard
* Seasonal Currency
* Seasonal Progress

---

# Economy Principles

* Mọi Currency đều có Source và Sink.
* Không tồn tại tài nguyên vô dụng.
* Không có Pay-to-Win.
* F2P luôn có thể theo kịp nếu chơi đều.
* Whale trả tiền để tiết kiệm thời gian và sưu tập, không phải để phá vỡ cân bằng.

---

# Future Expansion

Có thể mở rộng:

* Player Marketplace.
* Guild Marketplace.
* Trading Caravan.
* Black Market NPC.
* Dynamic Shop.
* Seasonal Investment System.
* City Economy.
* Guild Tax.
* Crafting Professions.
* Resource Exchange.

Kiến trúc Economy được xây dựng theo hướng dữ liệu (Data-Driven), giúp dễ dàng thêm Currency, Shop và hệ thống mới mà không phá vỡ cân bằng hiện có.
