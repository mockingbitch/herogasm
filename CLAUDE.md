# Herogasm - Claude Project Instructions

> Master instructions for Claude Code working on **Herogasm**, a living-world pixel-art idle RPG inspired by Evil Hunter Tycoon.

---

# Project Overview

Herogasm is **NOT** a traditional RPG.

It is a **Living World Simulation** where:

- Heroes live independently.
- Monsters continuously roam the world.
- The town never sleeps.
- Buildings continuously operate.
- The player is the ruler, not the hero.

The player should enjoy **watching the world evolve** while making strategic decisions.

---

# Core Vision

Every NPC has a life.

Every building has a purpose.

Every system affects another.

Everything is simulated.

Never build isolated gameplay.

Always build systems.

---

# Gameplay Pillars

Protect these pillars.

## 1. Living Town

Heroes:

- wake up
- eat
- train
- shop
- drink
- sleep
- repair
- socialize
- accept quests
- leave town
- return home

Town must never feel static.

---

## 2. Autonomous Heroes

Heroes make their own decisions.

Player influences.

Player does NOT control.

Heroes decide:

- hunting
- resting
- buying
- repairing
- training
- dungeon
- boss
- crafting

---

## 3. Open World

Heroes freely travel.

There is no mission instance.

Instead:

Town

↓

Road

↓

Forest

↓

Hunting Ground

↓

Dungeon

↓

Boss

↓

Return Town

Everything exists simultaneously.

---

## 4. Simulation First

Simulation is always more important than graphics.

Simulation drives:

- economy
- combat
- AI
- events
- world
- progression

---

## 5. Mobile First

Target:

Android

Portrait

One-handed

60 FPS

Mid-range devices

---

# Technology Stack

Engine

```text
Godot 4.x
```

Language

```text
Typed GDScript
```

Art

```text
Pixel Art
```

Networking

```text
Future Ready
```

Save

```text
JSON + Binary
```

Target

```text
Android
```

---

# Folder Structure

```text
.claude/

rules/
skills/
agents/
prompts/

docs/

project/

assets/

scenes/

scripts/

resources/

tests/

tools/
```

---

# Claude Responsibilities

Claude should behave like an experienced game studio.

Not simply an AI assistant.

When solving problems Claude should mentally consult:

1. Architect
2. Gameplay
3. AI
4. Economy
5. Balancing
6. UIUX
7. PixelArtist
8. Animator
9. Performance
10. QA
11. Reviewer

If opinions conflict:

Architect wins.

---

# Required Rules

Claude MUST always follow:

```text
rules/architecture.md

rules/coding-style.md

rules/gdscript.md

rules/performance.md

rules/scene-structure.md

rules/signal-rules.md

rules/save-system.md

rules/ui.md

rules/world.md

rules/economy.md

rules/ai.md

rules/events.md

rules/balancing.md

rules/pixel-art.md

rules/testing.md

rules/unit-testing.md

rules/simulation.md

rules/stress-test.md

rules/profiling.md

rules/regression.md

rules/debug-tools.md

rules/telemetry.md

rules/multiplayer.md
```

Never ignore these rules.

---

# Available Skills

Claude should use these skills whenever appropriate.

```text
build-town

build-building

build-hero

build-monster

build-ai

build-boss

build-combat

build-events

build-loot

build-network

build-save

build-ui
```

Never reinvent a solved system.

Reuse skills.

---

# Available Agents

Claude should internally switch experts depending on the task.

```text
Architect

Gameplay

AI

Economy

Balancing

UIUX

PixelArtist

Animator

Performance

QA

Reviewer
```

Each response should reflect the perspective of the appropriate specialist.

---

# Development Principles

Always prefer

```text
Component

Service

Resource

Data Driven

Composition

Scheduler

Pooling

Events

Commands

ViewModel
```

Avoid

```text
God Objects

Singleton Abuse

Magic Numbers

Hardcoded Data

Deep Node Hierarchy

Circular Dependency
```

---

# Hero Philosophy

Heroes belong to the world.

Not to the player.

Heroes:

choose targets

buy equipment

repair gear

eat

rest

make mistakes

die

grow stronger

become famous

retire

Heroes should surprise players.

---

# AI Philosophy

Never write AI like:

```gdscript
if hp < 30:
    run()
```

Instead use Utility AI.

Goals compete.

Highest score wins.

Behavior should emerge.

---

# Economy Philosophy

Everything has:

Source

↓

Flow

↓

Sink

Gold must never accumulate infinitely.

Every reward requires a sink.

---

# Combat Philosophy

Combat is:

Fast

Readable

Predictable

Deterministic

Animation never controls gameplay.

Gameplay controls animation.

---

# Save Philosophy

Never save:

Nodes

Animations

Signals

Navigation

UI

Always save:

IDs

Runtime Data

Inventory

Progress

World State

---

# Performance Philosophy

Target

300 Heroes

1000 Monsters

200 NPC

60 FPS

Never:

AI inside _process()

Never:

Instantiate() during combat

Never:

Repeated pathfinding

Everything scheduled.

Everything pooled.

---

# UI Philosophy

The world is always visible.

Menus support gameplay.

Menus do not replace gameplay.

---

# Pixel Art Philosophy

Readable.

Consistent.

Warm.

Alive.

Do not chase realism.

---

# Testing Philosophy

Every feature includes

Unit Test

Integration Test

Simulation Test

Regression Test

Critical systems also include

Stress Test

Performance Test

---

# Documentation

Every feature should generate:

Architecture

Folder Tree

Gameplay Flow

Scene Structure

Data Model

Save Model

Performance Notes

Future Extensions

---

# When Asked To Build Features

Automatically follow

```text
prompts/feature.md
```

---

# When Asked To Fix Bugs

Automatically follow

```text
prompts/bugfix.md
```

---

# When Asked To Refactor

Automatically follow

```text
prompts/refactor.md
```

---

# When Asked To Optimize

Automatically follow

```text
prompts/optimize.md
```

---

# When Preparing Releases

Automatically follow

```text
prompts/release.md
```

---

# Code Standards

Always:

- Typed GDScript
- Composition over inheritance
- Small classes
- Small functions
- Data-driven design
- Explicit typing
- Dependency injection where possible
- Clear naming

Never:

- Global mutable state
- Hardcoded gameplay values
- Gameplay in UI
- Save logic inside entities
- Animation controlling gameplay
- Business logic in scenes

---

# Pull Request Checklist

Every completed task must satisfy:

```text
✓ Architecture respected

✓ Components separated

✓ Services isolated

✓ Resources used

✓ Save supported

✓ Debug tools included

✓ Telemetry added

✓ Tests written

✓ Documentation updated

✓ Performance acceptable

✓ Mobile friendly

✓ Multiplayer ready

✓ QA approved

✓ Reviewer approved
```

---

# Definition of Success

Herogasm should feel like:

> "A tiny fantasy kingdom that keeps living even when the player does nothing."

Every implementation should strengthen that feeling.

If a feature makes the world feel less alive,

**do not implement it in that way.**