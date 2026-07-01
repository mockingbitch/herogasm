# Coding Style Guide

## General Principles

Code should be:

- Readable
- Predictable
- Reusable
- Modular
- Easy to debug
- Easy to maintain

Code is read far more often than written.

Always optimize for readability first.

---

# Language

Engine

Godot 4.x

Language

GDScript 2.0

Always use typed GDScript.

Bad

var hp = 100

Good

var hp: int = 100

---

# Naming

## Classes

PascalCase

Hero

Monster

QuestManager

DamageCalculator

---

## Scenes

PascalCase

Hero.tscn

Town.tscn

InventoryUI.tscn

---

## Scripts

Match scene names.

Hero.gd

Monster.gd

Inventory.gd

---

## Variables

snake_case

move_speed

attack_speed

critical_damage

max_hp

---

## Constants

UPPER_CASE

MAX_LEVEL

MAX_PARTY_SIZE

DEFAULT_ATTACK_RANGE

---

## Functions

snake_case

take_damage()

find_target()

move_to()

equip_item()

update_state()

---

## Signals

Past tense

health_changed

item_added

hero_died

quest_completed

monster_spawned

Avoid

on_damage

on_click

---

## Enums

PascalCase

enum HeroState

enum MonsterType

enum BuildingType

---

# File Size

Maximum

300 lines

Ideal

150~250 lines

Split large files.

Never create God Objects.

---

# Functions

Each function should do one thing.

Ideal

10~30 lines

Maximum

50 lines

Extract repeated logic.

---

# Comments

Write comments explaining WHY.

Avoid comments explaining WHAT.

Bad

# Increase HP
hp += 10

Good

# Reward bonus after completing tutorial
hp += tutorial_bonus

---

# Magic Numbers

Never hardcode values.

Bad

damage *= 1.35

Good

damage *= CRITICAL_DAMAGE_MULTIPLIER

or

damage *= weapon.critical_multiplier

---

# Early Return

Prefer early return.

Bad

if hero != null:
    if hero.hp > 0:
        attack()

Good

if hero == null:
    return

if hero.hp <= 0:
    return

attack()

---

# Nesting

Maximum nesting

3

Avoid

if
    if
        if
            if

Extract helper methods.

---

# Variables

Declare near usage.

Avoid large variable blocks.

Bad

var a
var b
var c
var d

...

Good

var target := find_target()

attack(target)

---

# Boolean Names

Use readable names.

Good

is_dead

is_alive

has_target

can_attack

can_move

Avoid

dead

alive

flag

value

---

# Collections

Always type collections.

Good

var heroes: Array[Hero]

var monsters: Array[Monster]

var loot: Array[LootItem]

Avoid

Array

Dictionary

without type hints.

---

# Dictionaries

Prefer Resources or custom classes.

Use Dictionary only for

JSON

Serialization

Configuration

Never use Dictionary as object replacement.

---

# Resources

Configuration belongs in Resources.

Examples

HeroData

SkillData

MonsterData

BuildingData

ItemData

QuestData

---

# Export Variables

Always use export.

@export var attack_speed: float = 1.2

@export var max_hp: int = 100

Never expose internal variables.

---

# Node References

Use @onready

Good

@onready var sprite: AnimatedSprite2D = $Sprite

Avoid

get_node()

inside _process()

---

# Signals

Prefer signals over polling.

Good

health_changed.emit()

Bad

UI checks HP every frame

---

# Process Functions

Avoid

_process()

Use only when necessary.

Prefer

Timer

Signal

Animation callback

Physics callback

---

# Physics

Movement

_physics_process()

UI

_process()

Never mix them.

---

# Null Safety

Always check.

if target == null:
    return

Never assume.

---

# Error Handling

Fail fast.

assert(data != null)

push_error()

push_warning()

Never silently ignore errors.

---

# Logging

Use helper methods.

Debug.log()

Debug.warning()

Debug.error()

Never spam print()

---

# Duplication

Never duplicate logic.

Extract

Utility

Component

Helper

Service

---

# Utilities

Allowed

MathUtils

StringUtils

RandomUtils

TimeUtils

Avoid

GameUtils

CommonUtils

Helper

Generic names.

---

# Components

One responsibility.

HealthComponent

MovementComponent

CombatComponent

InventoryComponent

EquipmentComponent

AIComponent

NeedsComponent

MoodComponent

RelationshipComponent

---

# State Machines

Never use long if chains.

Bad

if idle

if walking

if combat

if dead

Good

FSM

State Pattern

---

# Random

Never call

randi()

randf()

directly.

Use

RandomService

---

# Time

Never use magic timers.

Bad

if timer > 2.73

Good

const REST_TIME := 3.0

---

# Strings

Never hardcode UI strings.

Use Localization.

---

# Save Data

Never save Nodes.

Save IDs only.

Good

hero_id

item_id

building_id

quest_id

---

# Performance

Avoid

find_child()

get_children()

every frame

Avoid

Node lookup

inside combat

Cache references.

---

# Memory

Reuse objects.

Pool

Projectiles

Damage text

Effects

Loot

---

# Style

Prefer composition.

Avoid inheritance chains.

Maximum inheritance depth

2

---

# Dependency

Gameplay

must not depend on

UI

Animation

Sound

Networking

---

# Testing

Every important feature should be testable.

Separate

Logic

Presentation

---

# Code Review Checklist

Before generating code verify:

✓ Typed variables

✓ Typed arrays

✓ No duplicated logic

✓ No magic numbers

✓ No deep nesting

✓ Uses signals

✓ Reusable

✓ Readable

✓ Data Driven

✓ Performance friendly

✓ Mobile friendly

✓ Easy to extend

---

# AI Instructions

When generating code:

- Always generate typed GDScript.
- Prefer small reusable functions.
- Avoid duplicated code.
- Explain non-obvious decisions.
- Follow SOLID where applicable.
- Prefer composition over inheritance.
- Never hardcode gameplay values.
- Always think about scalability.
- Consider future multiplayer compatibility.
- Assume this project will continue for years.