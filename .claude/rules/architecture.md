# Architecture Rules

## Project Vision

This project is a living-world idle RPG inspired by Evil Hunter Tycoon.

The player does NOT directly control heroes.

The player manages the town.

Heroes are autonomous AI characters.

The world must always feel alive.

---

# Core Principles

1. Living World
2. Data Driven
3. Composition over Inheritance
4. Reusable Systems
5. Modular Scenes
6. Event Driven
7. Performance First
8. Mobile First

---

# High Level Architecture

Player
    │
    ▼
Town
    │
    ├── Buildings
    ├── NPC
    ├── Heroes
    ├── Economy
    ├── Events
    │
    ▼
World
    │
    ├── Hunting Zones
    ├── Monsters
    ├── Resources
    ├── Bosses
    └── Dungeons

---

# Gameplay Loop

Town

↓

Hero receives quest

↓

Hero prepares

↓

Hero walks to exit gate

↓

Travel to hunting field

↓

Search monsters

↓

Fight

↓

Loot

↓

Continue hunting

↓

Inventory full
or
Low HP
or
Broken equipment

↓

Return town

↓

Rest

↓

Upgrade

↓

Repeat

---

# Project Layers

Presentation

UI

Animation

VFX

Sound

------------------------

Gameplay

Combat

AI

Skills

Quest

Economy

Loot

Events

------------------------

World

Navigation

Buildings

Maps

Spawn

NPC

------------------------

Data

Resources

Configs

Save

Localization

---

# Folder Structure

res://

autoload/

core/

data/

entities/

heroes/

monsters/

npc/

world/

town/

buildings/

combat/

skills/

items/

events/

ui/

audio/

effects/

save/

debug/

---

# Scene Structure

One scene

One responsibility

Never place multiple unrelated systems inside one scene.

Example

Town.tscn

contains

Navigation

Buildings

Spawn Points

NPC

Hero Manager

Weather

Camera

Only.

---

# Single Responsibility

Each node should have one purpose.

Bad

Hero.gd

Movement

Combat

Inventory

Quest

Save

Animation

UI

Networking

Good

Hero

↓

MovementComponent

CombatComponent

InventoryComponent

EquipmentComponent

QuestComponent

AIComponent

AnimationComponent

---

# Composition

Always prefer composition.

Never create

KnightHero

MageHero

ArcherHero

using inheritance.

Instead

Hero

+

ClassData

+

SkillData

+

Equipment

+

AI

---

# Data Driven

Everything configurable.

Hero stats

Monster stats

Items

Buildings

Loot

Quest

Events

must come from Resources or JSON.

Never hardcode values.

Bad

damage = 127

Good

damage = weapon.damage

---

# IDs

Every object must have ID.

Hero ID

Monster ID

Quest ID

Item ID

Building ID

Save ID

Never depend on node names.

---

# Managers

Only global systems become managers.

Allowed

GameManager

SaveManager

AudioManager

TimeManager

EventManager

PoolManager

LocalizationManager

Not allowed

HeroManagerSingleton

MonsterManagerSingleton

CombatManagerSingleton

unless absolutely necessary.

---

# Communication

Preferred

Signals

Callable

Event Bus

Avoid

NodePath

Deep node traversal

../../../../Player

Never.

---

# Dependencies

Allowed

UI

↓

Gameplay

↓

Data

Forbidden

Gameplay

↓

UI

Gameplay should never know UI.

---

# State Machines

Every AI entity uses FSM.

Hero

Idle

Walk

Rest

Train

Shopping

Craft

Travel

Hunt

Combat

Dead

Return

Monster

Idle

Roam

Aggro

Chase

Attack

Dead

Respawn

---

# Navigation

All movement

NavigationAgent2D

No teleporting.

Heroes must physically walk.

Even when returning town.

---

# Buildings

Buildings are services.

Guild

Quest Provider

Inn

Recovery

Blacksmith

Upgrade

Storage

Inventory

Market

Trading

Portal

Transportation

Buildings never contain gameplay logic.

They expose services.

---

# Hero Autonomy

Player never moves heroes.

Heroes decide

where to hunt

when to rest

when to repair

when to shop

when to eat

when to return

Player only influences them.

---

# Combat

Combat is fully autonomous.

Heroes

Find target

Attack

Cast

Loot

Retreat

using AI.

---

# Events

Everything important should emit events.

HeroEnteredTown

HeroLeftTown

HeroLevelUp

MonsterKilled

BossSpawned

ItemDropped

QuestCompleted

---

# Save System

Never save Nodes.

Save only data.

Bad

Node

AnimationPlayer

Sprite

NavigationAgent

Good

HeroData

InventoryData

EquipmentData

QuestData

BuildingData

---

# Performance

Target

200 Heroes

1000 Monsters

60 FPS

Rules

Avoid _process()

Prefer timers

Prefer signals

Use pooling

Disable offscreen processing

Reuse objects

---

# Object Pool

Pool

Damage Numbers

Projectiles

Hit Effects

Loot Effects

Floating Text

Never instantiate repeatedly.

---

# Update Frequency

Every frame

Animation

Movement

Combat

Every second

Needs

Mood

Economy

Quest Check

Every minute

World Events

Boss Rotation

Merchant

Festival

---

# Randomness

All RNG

must go through

RandomService.

Never call randomize()

inside gameplay.

---

# Debug

Every major system

must support

debug logging

debug visualization

performance metrics

---

# Scalability

Architecture must support

New Hero Classes

New Buildings

New Maps

New Monsters

New Skills

New Equipment

without modifying existing systems.

Open for extension.

Closed for modification.

---

# Coding Philosophy

Readable

Reusable

Predictable

Data Driven

Testable

Maintainable

Performance First

Never optimize prematurely.

Never sacrifice readability unless profiling proves necessary.

---

# AI Assistant Instructions

When generating code:

- Follow this architecture strictly.
- Prefer reusable systems over shortcuts.
- Never introduce duplicate logic.
- Explain architectural decisions.
- Suggest improvements when appropriate.
- Refuse solutions that violate these rules.