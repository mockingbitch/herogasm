# Herogasm

> *Build your guild. Forge your legends. Conquer the darkness.*

Herogasm là một game **living-world Idle RPG / Hero Collection / Base-building** (lấy cảm hứng Evil Hunter Tycoon) được phát triển bằng **Godot 4**, nơi người chơi vào vai **Guild Master / chủ thành** thay vì điều khiển một anh hùng duy nhất. Bối cảnh: vương quốc đổ nát **Kingdom of Ashes**.

Người chơi sẽ tuyển mộ, huấn luyện và quản lý một đội quân lính đánh thuê, xây dựng đội hình chiến thuật để vượt qua dungeon, săn boss, tham gia Guild War, PvP Arena và các sự kiện theo mùa.

---

# Vision

Mục tiêu của dự án là tạo ra một game mobile có khả năng vận hành lâu dài (Live Service), trong đó:

* Không Pay to Win
* Meta thay đổi theo từng Season
* Mỗi Hero đều có giá trị
* Chiến thuật quan trọng hơn Battle Power
* Người chơi được tự do sáng tạo đội hình

---

# Core Gameplay

```
Login
   │
   ▼
Collect Resources
   │
   ▼
Accept Missions
   │
   ▼
Build Team
   │
   ▼
Auto Battle
   │
   ▼
Loot Equipment
   │
   ▼
Upgrade Heroes
   │
   ▼
Unlock New Areas
   │
   ▼
Boss / Guild / Arena
   │
   ▼
Repeat
```

---

# Core Features

## Hero Collection

* Nhiều Class
* Nhiều Race
* Passive & Active Skills
* Talent Tree
* Awakening
* Equipment
* Rune
* Pet

---

## Team Building

Không tồn tại đội hình mạnh nhất.

Người chơi phải:

* lựa chọn Hero
* kết hợp Race
* kết hợp Class
* build Equipment
* build Rune
* build Talent

để tạo ra đội hình phù hợp với từng chế độ chơi.

---

## PvE

* Story Campaign
* Dungeon
* Endless Tower
* Equipment Dungeon
* Rune Dungeon
* Raid Boss
* World Boss
* Hidden Boss

---

## PvP

* Arena
* Ranked Arena
* Guild War
* Draft Battle
* Seasonal League

---

## Guild

* Guild Level
* Guild Technology
* Guild Shop
* Guild Boss
* Guild War
* Guild Missions

---

## Seasonal Content

Mỗi Season sẽ bổ sung:

* Hero mới
* Boss mới
* Dungeon mới
* Rune mới
* Event
* Battle Pass
* Skin

---

# Design Philosophy

## Strategy > Power

Battle Power chỉ phản ánh sức mạnh tổng thể.

Không quyết định thắng thua.

Một đội hình thông minh luôn có thể đánh bại đội hình có Battle Power cao hơn.

---

## No Mandatory Hero

Không tồn tại Hero mạnh nhất.

Mỗi Hero đều mạnh trong một tình huống nhất định.

Ví dụ:

* Farm
* PvP
* Raid
* Guild War
* Endless Tower

---

## No Power Creep

Không liên tục tạo Hero mạnh hơn.

Meta sẽ thay đổi bằng cách:

* Buff Rune
* Buff Equipment
* Buff Synergy
* Buff Dungeon
* Buff Seasonal Mechanics

---

## Long-Term Progression

Người chơi luôn có mục tiêu mới:

* Sưu tập Hero
* Farm Equipment
* Hoàn thiện Build
* Leo Rank
* Guild War
* Seasonal Challenge
* Achievement
* Collection

---

# Documentation

| File         | Description                 |
| ------------ | --------------------------- |
| FLOW.md      | **Kịch bản hành trình người chơi A→Z (offline-first) — bắt đầu đọc ở đây** |
| FEATURES.md  | **Danh mục toàn bộ chức năng theo timeline + trạng thái (backlog thiết kế)** |
| TEAMBUILD.md | **Synergy & deckbuild đa dạng-mà-cân-bằng (thay §11 GDD)** |
| STORY.md     | Thế giới và cốt truyện      |
| WORLD.md     | Quốc gia, bản đồ, chủng tộc |
| HERO.md      | Hero, Class, Race           |
| COMBAT.md    | Combat System               |
| SKILLS.md    | Skill System                |
| EQUIPMENT.md | Equipment                   |
| RUNE.md      | Rune & Talent               |
| DUNGEON.md   | Dungeon                     |
| BOSS.md      | Boss Design                 |
| GUILD.md     | Guild System                |
| PVP.md       | PvP & Ranking               |
| EVENTS.md    | Seasonal Event              |
| ECONOMY.md   | Currency & Shop             |
| BALANCE.md   | Công thức cân bằng          |
| ROADMAP.md   | Development Roadmap         |
| CHANGELOG.md | Lịch sử cập nhật            |

---

# Technical Stack

## Engine

Godot 4.x

## Language

GDScript

(Có thể bổ sung module C++ hoặc Rust nếu cần tối ưu hiệu năng.)

## Target Platform

* Android
* iOS

---

# Project Structure

```
docs/
assets/
scenes/
scripts/
ui/
audio/
effects/
data/
addons/

README.md
LICENSE
```

---

# Future Goals

* Multiplayer Guild War
* Cross Server Arena
* Real-time Raid
* Seasonal World Events
* AI Generated Dungeon
* Hero Relationship System
* Dynamic World Map
* Procedural Dungeon

---

# Development Principles

* Modular Architecture
* Data Driven Design
* Easy Balancing
* Easy Localization
* Easy Expansion
* Live Service Ready

---

# Status

Current Stage

> Pre-production

Đang thiết kế:

* Game Design
* World Building
* Hero System
* Combat System
* Economy
* UI/UX
* Art Direction

Sau khi hoàn thiện GDD sẽ bắt đầu phát triển MVP.

---

# Motto

> "A legend is not born alone. It is built by the guild behind them."
