# Scene Structure Rules

## Philosophy

Scenes are modular.

Each scene represents one reusable entity.

A scene must have one responsibility.

Scenes should be composable.

Avoid giant scenes.

---

# Scene Hierarchy

World

├── Environment
├── Navigation
├── Town
├── HuntingZones
├── Dungeon
├── Entities
├── UI
├── Camera
└── Effects

Every major system is isolated.

---

# One Scene = One Entity

Good

Hero.tscn

Monster.tscn

Building.tscn

Projectile.tscn

Loot.tscn

NPC.tscn

Avoid

Gameplay.tscn

Objects.tscn

Everything.tscn

---

# Maximum Depth

Recommended

5 levels

Maximum

7 levels

Avoid

World
    Town
        Building
            Interior
                Furniture
                    Decoration
                        Item
                            Sprite

Too deep.

---

# Root Node

Use meaningful root nodes.

Hero

CharacterBody2D

Monster

CharacterBody2D

Projectile

Area2D

Building

Node2D

UI

CanvasLayer

Avoid

Node

unless absolutely necessary.

---

# Scene Composition

Large objects should be composed.

Hero

Hero
├── Sprite
├── Shadow
├── Animation
├── Navigation
├── HealthBar
├── InteractionArea

Not

Hero
├── Everything

---

# Visual Separation

Visual nodes

must never contain gameplay.

Allowed

Sprite

Animation

Particles

Light

Forbidden

Combat

Inventory

Quest

AI

---

# Gameplay Components

Gameplay lives in components.

Hero

Hero
├── MovementComponent
├── CombatComponent
├── InventoryComponent
├── EquipmentComponent
├── AIComponent
├── NeedsComponent
├── RelationshipComponent

Each component owns one responsibility.

---

# UI Separation

Gameplay

never owns UI.

Correct

CanvasLayer

↓

HUD

↓

HeroPanel

↓

Inventory

Wrong

Hero

↓

InventoryWindow

↓

QuestWindow

↓

Popup

---

# Effects

Effects are temporary.

Effects

DamageText

Explosion

HealEffect

BuffEffect

ProjectileTrail

Always spawned through EffectManager.

Never permanently attached.

---

# Managers

Managers belong to World.

Game

├── TimeManager
├── SpawnManager
├── EventManager
├── SaveManager
├── AudioManager
├── PoolManager

Managers never appear inside Hero.

---

# Hero Scene

Hero

CharacterBody2D

├── NavigationAgent2D
├── CollisionShape2D
├── AnimatedSprite2D
├── Shadow
├── HealthBar
├── SelectionCircle
├── InteractionArea
├── TargetDetector
├── AnimationPlayer
└── Audio

Hero script controls components only.

---

# Monster Scene

Monster

CharacterBody2D

├── NavigationAgent2D
├── AnimatedSprite2D
├── CollisionShape2D
├── AggroArea
├── HealthBar
├── Shadow
├── LootAnchor
└── AnimationPlayer

---

# Building Scene

Building

Node2D

├── Sprite
├── Collision
├── Entrance
├── ServiceArea
├── AnimationPlayer
└── Label

Buildings expose services.

Buildings do not execute gameplay.

---

# Hunting Zone

HuntingZone

Node2D

├── NavigationRegion2D
├── SpawnPoints
├── Monsters
├── Resources
├── Decoration
├── ExitPoints

Each zone is independent.

---

# Town Scene

Town

Node2D

├── Navigation
├── Buildings
├── Roads
├── Decorations
├── NPC
├── Heroes
├── Gates
├── SpawnPoints
├── CameraBounds
└── Lighting

Town never contains combat logic.

---

# Dungeon Scene

Dungeon

Node2D

├── Navigation
├── Rooms
├── Monsters
├── Boss
├── Loot
├── Exit

Dungeon should be reusable.

---

# UI Structure

CanvasLayer

├── HUD
├── TopBar
├── Minimap
├── HeroList
├── QuestPanel
├── BuildingPanel
├── PopupLayer
├── NotificationLayer
└── DebugOverlay

Never attach UI to gameplay nodes.

---

# Popups

PopupLayer

├── ItemPopup

├── RewardPopup

├── ConfirmDialog

├── ErrorPopup

Destroy after close.

---

# World Structure

World

├── Town
├── Forest
├── Desert
├── Snow
├── Volcano
├── Dungeon
├── BossArena

World is persistent.

Player never changes scenes unnecessarily.

---

# Open World

Heroes physically travel.

Town

↓

Road

↓

Forest

↓

Mountain

↓

Dungeon

Do not teleport.

Travel is visible.

---

# Navigation

Each map owns

NavigationRegion2D.

Never mix navigation regions.

---

# Spawn Points

Separate nodes.

SpawnPoints

├── HeroSpawn

├── NPCSpawn

├── MonsterSpawn

├── BossSpawn

Never hardcode coordinates.

---

# Loot

Loot

Area2D

├── Sprite

├── Shadow

├── PickupArea

Loot disappears after timeout.

---

# Camera

Camera2D

Own scene.

Never embedded into Hero.

Supports

Zoom

Shake

Follow

Transition

---

# Audio

Dedicated Audio nodes.

Do not place AudioPlayers everywhere.

AudioManager handles playback.

---

# Particles

Particles belong to Effect scene.

Never inside Hero.

---

# Lighting

Lighting is environmental.

Never tied to Hero.

---

# Groups

Use Groups only for discovery.

Examples

hero

monster

building

npc

loot

projectile

Avoid using groups as storage.

---

# Naming

Nodes

PascalCase

Sprite

NavigationAgent

HealthBar

SelectionCircle

Avoid

Sprite2

Node3

TestNode

---

# Ownership

Every spawned object has owner.

Spawner

↓

Entity

↓

Components

Never orphan nodes.

---

# Reusability

A scene must be usable in another project
without modification.

Avoid hidden dependencies.

---

# Scene Communication

Scenes communicate only through

Signals

EventBus

Service

Never through deep NodePath.

---

# AI Instructions

When creating scenes:

- Keep scenes small.
- Separate visuals from gameplay.
- Use reusable components.
- Never create giant scene trees.
- Never duplicate scene structures.
- Prefer composition.
- Keep scene hierarchy shallow.
- Support object pooling.
- Support future multiplayer.