# Performance Rules

## Performance Philosophy

Performance is a feature.

Every system must be designed for scalability.

Assume the game will eventually have:

- 300 Heroes
- 1000 Monsters
- 200 NPC
- 500 Loot
- 100 Buildings
- 10000+ Path Requests per minute

Always optimize architecture before optimizing code.

Never optimize blindly.

Profile first.

---

# Performance Targets

Platform

Android Mid-range (2022+)

Target FPS

60 FPS

Minimum FPS

45 FPS

Maximum Memory

512 MB

Loading Time

< 3 seconds

Save Time

< 500 ms

---

# Golden Rules

Never

- Allocate memory every frame
- Search SceneTree every frame
- Instantiate repeatedly
- Poll unnecessarily
- Load Resources during gameplay

Always

- Cache
- Reuse
- Pool
- Batch
- Schedule

---

# Processing

Avoid _process()

Allowed

Camera

Animation

UI interpolation

Effects

Forbidden

AI

Inventory

Economy

Quest

Combat

---

# Physics

Use _physics_process()

Only for

Movement

Collision

Navigation

Physics

Nothing else.

---

# AI Update

Never update every Hero every frame.

Instead

AI Scheduler

Frame 1

Hero 1~20

Frame 2

Hero 21~40

Frame 3

Hero 41~60

...

Distribute CPU load.

---

# AI Tick Rate

Movement

60 FPS

Combat

10 FPS

Need System

1 FPS

Mood

0.5 FPS

Relationship

0.2 FPS

Economy

0.1 FPS

Festival

0.02 FPS

Not everything needs 60 FPS.

---

# Object Pool

Always pool

Damage Numbers

Projectiles

Blood Effects

Heal Effects

Loot

Floating Text

Particles

Never instantiate during combat.

---

# Node Lookup

Forbidden

get_node()

find_child()

find_parent()

inside gameplay loops.

Cache references.

Good

@onready var sprite := $Sprite

---

# Groups

Do not call

get_tree().get_nodes_in_group()

every frame.

Cache results.

Use Group only

for discovery.

---

# SceneTree

Never traverse SceneTree
during combat.

No

../../..

No

find_parent()

No

find_child()

---

# Arrays

Reuse arrays.

Avoid

var targets := []

every frame.

Instead

targets.clear()

Reuse allocated memory.

---

# Dictionaries

Avoid Dictionary

inside gameplay.

Prefer

class

Resource

Struct-like objects

---

# Resources

Always preload

Scenes

Textures

Audio

Animation

Never load()

inside gameplay.

---

# Signals

Signals are events.

Do not emit

every frame.

Use direct calls

for

Combat

Movement

AI

Navigation

---

# Timers

Prefer Timer

or Scheduler.

Avoid

manual countdowns

inside every entity.

---

# Visibility

Entities outside camera

should reduce workload.

Allowed

Disable animation

Reduce AI frequency

Disable particles

Reduce update interval

---

# Distance Optimization

Far entities

↓

No animation

↓

Low AI tick

↓

No particles

↓

No shadows

↓

No combat effects

---

# LOD (Logic Level of Detail)

Near Player

Full simulation

Medium Distance

Reduced AI

Far Distance

Very low AI

Outside Active Region

Background simulation only

---

# Navigation

NavigationAgent2D only.

Do not recalculate paths

every frame.

Only when

Target changes

Blocked

Destination changes

---

# Pathfinding

Cache destination.

Avoid

set_target_position()

every frame.

---

# Combat

Avoid expensive searches.

Bad

Find nearest monster every frame.

Good

Target only every

500 ms

---

# Collision

Use layers.

Avoid

checking every object.

Never

loop through all monsters.

---

# Animation

Stop animations

when invisible.

Avoid

AnimatedSprite

running

off-screen.

---

# UI

Update only

when data changes.

Bad

HP Bar updates every frame.

Good

health_changed signal.

---

# Minimap

Update

5 FPS

Not 60 FPS.

---

# Economy

Run economy

once every second.

Never

every frame.

---

# Needs System

Hunger

Mood

Fatigue

Relationship

Update every few seconds.

---

# Save

Never save every frame.

Autosave

every

30~120 sec.

---

# Spawn

Spawn gradually.

Never create

200 monsters

in one frame.

Spread workload.

---

# Despawn

Pool objects.

Never destroy

unless necessary.

---

# Audio

Reuse AudioPlayers.

AudioManager controls playback.

---

# Memory

Avoid temporary allocations.

Reuse

Arrays

Objects

Path buffers

Damage structures

---

# Strings

Avoid string concatenation

inside loops.

---

# Logging

Disable debug logging

in release.

---

# Debug Drawing

Compile-time switch.

Never debug draw

in production.

---

# Mobile Optimization

Limit

Particles

Lights

Shadows

Screen Shake

Dynamic Lighting

---

# Multithreading

Allowed

Save

Loading

World Generation

Path Preprocessing

Forbidden

SceneTree manipulation

outside main thread.

---

# Scheduler

Prefer centralized schedulers.

Hero AI Scheduler

Monster AI Scheduler

Need Scheduler

Relationship Scheduler

Economy Scheduler

Avoid

300 Timers.

---

# Managers

Managers should batch work.

Good

CombatManager updates

50 combats

Bad

Each Hero updates itself.

---

# Database

Lookup by ID.

Avoid linear search.

Good

Dictionary<int, Hero>

Bad

Loop every Hero.

---

# Profiling

Before optimizing

measure

CPU

Memory

Draw Calls

Physics

Script Time

Never guess.

---

# Code Review Checklist

✓ No SceneTree traversal in loops

✓ No allocations every frame

✓ Cached references

✓ Object Pool used

✓ Typed arrays

✓ Scheduler used

✓ AI distributed

✓ UI event-driven

✓ No repeated loading

✓ Mobile friendly

✓ Scalable to 300+ Heroes

---

# AI Instructions

When generating gameplay systems:

- Always think about CPU cost.
- Avoid per-frame updates.
- Batch similar work.
- Prefer schedulers over timers.
- Reuse objects.
- Cache everything.
- Design for hundreds of entities.
- Optimize architecture before micro-optimizations.
- Explain any performance-sensitive decisions.