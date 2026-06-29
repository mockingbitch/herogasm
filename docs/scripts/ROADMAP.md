# ROADMAP.md

# Development Roadmap

> *"Build small. Validate fun. Scale system. Then expand the world."*

---

# Vision Summary

Game được xây dựng theo hướng:

* Tactical Auto RPG
* Deep Build System (Hero + Rune + Equipment)
* Live Service Dungeon & PvP ecosystem
* Data-driven architecture

Mục tiêu:

* MVP playable trong 3–6 tháng
* Live content trong 6–12 tháng
* Scale long-term 2–5 năm

---

# Phase 0 — Pre-Production (Design Lock)

⏱ Duration: 2–4 tuần

## Goals

* Chốt toàn bộ design docs
* Validate core loop
* Prototype combat feel

## Tasks

* Finalize:

  * HERO.md
  * COMBAT.md
  * SKILLS.md
  * EQUIPMENT.md
  * RUNE.md

* Build paper prototype:

  * Combat flow simulation
  * Damage formula test
  * AI behavior mock

## Output

* Game design locked v1
* Core loop validated

---

# Phase 1 — Core Prototype (Playable Combat)

⏱ Duration: 4–8 tuần

## Goals

* Có trận chiến hoàn chỉnh
* Auto battle hoạt động
* 3–5 Hero test

## Features

### Combat System

* Auto battle real-time
* Target priority system
* Skill casting system
* Basic AI logic

### Hero System

* 3 classes (Tank / Mage / Assassin)
* Basic stats
* 2–3 skills each

### Dungeon Basic

* Story dungeon (linear)
* Simple boss

## Output

* Playable combat loop
* Early fun validation

---

# Phase 2 — Vertical Slice (1 Full Gameplay Loop)

⏱ Duration: 6–10 tuần

## Goals

* Full loop: Farm → Upgrade → Fight → Progress
* Introduce build system

## Features

### Systems

* Equipment system (basic affix)
* Rune system (simple version)
* Leveling system
* Inventory system

### Content

* 10–15 Hero
* 3 Dungeon types
* 1 Boss system
* Basic PvP Arena

## Output

* Full gameplay loop playable
* First retention test (D1 / D7)

---

# Phase 3 — Core Systems Expansion

⏱ Duration: 2–3 tháng

## Goals

* Build depth systems
* Enable build diversity

## Features

### Systems

* Full Equipment system
* Full Rune system
* Skill upgrade + evolution
* Formation system
* AI behavior tree v1

### Content

* 30–50 Hero
* Multiple Boss types
* Endless Tower
* Daily dungeons

## Output

* Meta starts forming
* Build diversity emerges

---

# Phase 4 — Live Service Foundation

⏱ Duration: 2–3 tháng

## Goals

* Add scalable content system
* Prepare for live operations

## Features

### Systems

* Event system framework
* Season system
* Reward pipeline
* Economy system v1
* Balance metrics tracking

### Content

* Guild system
* Guild boss
* Raid dungeon
* Weekly events

## Output

* Game becomes "live service ready"

---

# Phase 5 — PvP & Competitive Layer

⏱ Duration: 2–3 tháng

## Goals

* Build competitive ecosystem
* Create long-term engagement

## Features

### PvP

* Ranked Arena
* Draft Arena
* Guild War
* Tournament system

### Systems

* Matchmaking (MMR)
* Replay system
* Ranking system
* Anti-meta system v1

## Output

* Competitive ecosystem stable
* First meta evolution cycle

---

# Phase 6 — Seasonal Content System

⏱ Duration: Ongoing

## Goals

* Continuous content delivery
* Meta rotation

## Features

* Seasonal Hero releases
* Seasonal Rune pools
* Seasonal Dungeon modifiers
* Seasonal PvP rules
* World Events

## Output

* Live operations loop established

---

# Phase 7 — Endgame Scaling

⏱ Duration: Ongoing

## Goals

* Long-term retention
* High-end content

## Features

* Cross-server PvP
* World Boss system
* Mythic Dungeon
* Chaos Dungeon
* Infinite Tower scaling
* Boss mutation system

## Output

* Long-term ecosystem stability

---

# MVP Definition

Game is considered MVP-ready when:

* 1 full combat loop works
* 10+ Hero available
* 3 dungeon types playable
* 1 PvP mode functional
* Equipment + Rune basic system exists
* Players can:

  * Farm
  * Upgrade
  * Build team
  * Win/lose based on strategy

---

# Success Metrics

## Early Stage

* D1 Retention > 35%
* Session length > 10 min
* Battle completion rate > 70%

## Mid Stage

* D7 Retention > 15–20%
* PvP participation > 40%
* Dungeon replay rate > 60%

## Live Stage

* Monthly active content usage > 70%
* Meta diversity (no Hero > 35% usage)
* Stable economy (no inflation spike)

---

# Development Principles

* Build core fun first, content later
* Systems > Content
* Data-driven design from day 1
* Avoid over-engineering early features
* Always validate combat feel before scaling systems

---

# Risk Control

## Risk: Over-scoping

→ Solution: Lock MVP strictly

## Risk: System complexity explosion

→ Solution: Data-driven + modular design

## Risk: Balance collapse

→ Solution: Early metrics tracking

## Risk: Content burnout

→ Solution: Seasonal rotation + procedural systems

---

# Final Vision

If executed correctly, the game becomes:

* A tactical auto RPG with deep build crafting
* A long-term live service ecosystem
* A meta-evolving PvP environment
* A dungeon-driven progression world
* A system where strategy always beats raw power

> *"The goal is not to build a game. The goal is to build a living system that keeps generating new gameplay for years."*
