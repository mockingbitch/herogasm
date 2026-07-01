# GDScript Rules

## Engine

Godot 4.x

Language

GDScript 2.0

Always assume the latest stable version.

---

# Philosophy

Write GDScript like native Godot code.

Prefer readability over cleverness.

Follow official Godot conventions.

---

# Class Declaration

Always use class_name.

Good

class_name Hero
extends CharacterBody2D

Avoid anonymous scripts whenever possible.

---

# One Class One File

Each script defines exactly one class.

Never combine multiple classes in one file.

---

# Typed Variables

Everything must be typed.

Good

var hp: int = 100

var speed: float = 120.0

var target: Hero

Avoid

var hp

var target

---

# Typed Arrays

Always type arrays.

Good

var heroes: Array[Hero] = []

var monsters: Array[Monster] = []

var items: Array[ItemData] = []

Avoid

var heroes = []

---

# Dictionaries

Avoid Dictionary as data model.

Dictionary is allowed only for

JSON

Serialization

Temporary parsing

Never store gameplay objects in Dictionary.

---

# Constants

Gameplay values

must be constants

or Resource values.

Good

const MAX_LEVEL := 100

const SEARCH_RADIUS := 250.0

Avoid

speed *= 1.37

---

# Export

Always expose configurable values.

Good

@export var move_speed: float = 80

@export var attack_range: float = 48

@export var sprite: Texture2D

Avoid

var move_speed = 80

---

# Categories

Use export groups.

Example

@export_group("Stats")

@export var hp := 100

@export var attack := 20

@export_group("Movement")

@export var speed := 120

---

# Resources

Configuration belongs in Resources.

Examples

HeroData

MonsterData

SkillData

ItemData

BuildingData

QuestData

LootTable

Never hardcode gameplay values.

---

# @onready

Cache node references.

Good

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var health_bar: ProgressBar = %HealthBar

Never lookup nodes repeatedly.

---

# Node Access

Prefer

%

for unique nodes.

Prefer

$

for direct children.

Avoid

get_node()

inside gameplay.

---

# Signals

Declare at top.

signal died

signal attacked(target)

signal hp_changed(value)

Use emit()

Never manually call connected methods.

---

# Connection

Prefer editor connections

or

code during _ready()

Never reconnect every frame.

---

# _ready()

Only initialize.

Do not perform gameplay.

Allowed

cache references

connect signals

initialize variables

Forbidden

AI

combat

pathfinding

loot

---

# _process()

Avoid.

Only use

camera

animation

visual interpolation

UI effects

---

# _physics_process()

Movement only.

Movement

Navigation

Physics

Collision

Never place UI logic here.

---

# Await

Allowed

animation

timer

scene transition

Forbidden

combat loop

AI loop

main gameplay

Avoid long async chains.

---

# Timer

Prefer Timer node

instead of manual countdowns.

Bad

timer -= delta

Good

Timer.timeout

---

# Navigation

Always use

NavigationAgent2D

Never manually calculate paths.

Never teleport heroes.

---

# Character Movement

CharacterBody2D

move_and_slide()

Never modify global_position directly during movement.

---

# Node Lifecycle

Never assume

_ready()

means world is initialized.

Use GameManager signals if necessary.

---

# Instantiation

Use PackedScene.

Good

var hero := HERO_SCENE.instantiate()

Avoid

load()

during gameplay.

Preload whenever possible.

---

# preload

Use preload for

Scenes

Resources

Audio

Effects

Textures frequently used

Avoid load() inside combat.

---

# Enums

Always use enum.

Example

enum HeroState

IDLE

WALK

REST

SHOP

COMBAT

RETURN

Never use strings.

---

# State Machine

State

must not know UI.

State

must not know Scene Tree.

State only knows owner.

---

# Callable

Use Callable instead of string methods.

Good

button.pressed.connect(open_shop)

Avoid

connect("pressed","open_shop")

---

# Lambda

Avoid long lambdas.

Extract methods.

---

# Animation

AnimationPlayer

or

AnimatedSprite2D

Never mix gameplay logic into animation.

Animation emits signals.

Gameplay listens.

---

# Audio

Never call AudioStreamPlayer everywhere.

Use AudioManager.

---

# Random

Never call

randf()

randi()

RandomNumberGenerator

directly.

Use RandomService.

---

# Resources vs Nodes

Nodes

Runtime

Resources

Configuration

Never mix responsibilities.

---

# Save

Nodes are never serialized.

Only serialize

IDs

Stats

Inventory

Quest Progress

Equipment

Relationships

---

# Scene Changes

Never directly change scenes.

Use

SceneManager

---

# Autoload

Allowed

GameManager

SceneManager

AudioManager

SaveManager

LocalizationManager

TimeManager

EventBus

PoolManager

Avoid putting gameplay into autoloads.

---

# Memory

Pool

Damage Text

Loot

Projectiles

Particles

Effects

Never instantiate repeatedly.

---

# Debug

Use

assert()

push_warning()

push_error()

Debug overlay

Avoid print spam.

---

# Error Handling

Validate input.

Return early.

Fail fast.

---

# Object References

Prefer weak ownership.

Avoid circular references.

If object can disappear

check

is_instance_valid()

before using.

---

# Null Safety

Always verify references.

if target == null:
    return

if not is_instance_valid(target):
    return

---

# Scene Tree

Gameplay never depends on hierarchy.

Never use

../../

../../../

find_parent()

find_child()

inside gameplay.

Inject dependencies instead.

---

# Mobile Optimization

Avoid

dynamic allocations

every frame.

Avoid

creating arrays

inside combat loop.

Reuse collections.

---

# Performance

Never

load()

inside _process()

Never

get_tree().get_nodes_in_group()

every frame.

Cache everything.

---

# Groups

Groups are for

Discovery

Broadcast

Filtering

Never use Groups as gameplay database.

---

# AI Instructions

When generating GDScript:

- Always use typed variables.
- Always use class_name.
- Use @export for configurable values.
- Cache node references with @onready.
- Use NavigationAgent2D for movement.
- Use signals instead of polling.
- Prefer PackedScene + preload.
- Prefer Resources for configuration.
- Never hardcode gameplay values.
- Never depend on scene hierarchy.
- Separate gameplay from presentation.
- Generate idiomatic Godot 4 code.