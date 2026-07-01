# Save System Rules

## Philosophy

The save system stores game state.

Never store SceneTree.

Never store Nodes.

Never store runtime objects.

Store only data.

---

# Save Architecture

World

↓

Entities

↓

Components

↓

Data

↓

Serializer

↓

Save File

The save system only knows data.

---

# Save Format

Preferred

Binary

or

Compressed JSON

Must support

Versioning

Migration

Validation

Checksum

Compression

---

# Save Manager

Only one SaveManager exists.

Responsibilities

Save

Load

Autosave

Migration

Validation

Backup

Recovery

Nothing else.

---

# Save Timing

Autosave

30~120 sec

Manual Save

Allowed

Exit Game

Always save

Major Events

Save immediately

Examples

Boss defeated

Building upgraded

Quest completed

Hero recruited

---

# Save Granularity

Save

World

Town

Heroes

Buildings

Inventory

Economy

Quest

Relationships

Events

Statistics

Never save

Animation

Particles

Navigation

Temporary effects

---

# Serializable Objects

Allowed

HeroData

MonsterData

TownData

BuildingData

QuestData

ItemData

InventoryData

EquipmentData

RelationshipData

WorldData

EventData

StatisticsData

Forbidden

Node

Sprite

AnimationPlayer

NavigationAgent

Camera

AudioPlayer

Particle

UI

---

# Entity IDs

Every object

must have

persistent ID.

Examples

HeroID

MonsterID

BuildingID

QuestID

ItemID

GuildID

RelationshipID

Never identify objects

using NodePath.

---

# Save Structure

SaveGame

├── Version
├── World
├── Town
├── Heroes
├── Buildings
├── Inventory
├── Economy
├── Quests
├── Events
├── Statistics
├── Settings

---

# Hero Save

Save

ID

Level

Experience

Stats

Equipment

Inventory

Skills

Relationships

Mood

Needs

Current Location

Current Task

Quest Progress

Health

Mana

Fatigue

Do not save

Animation State

Sprite Frame

Current Path

Navigation

---

# Monster Save

Save only

Persistent monsters.

Normal monsters

respawn.

Bosses

Elite

Named monsters

should persist.

---

# Buildings

Save

Level

Upgrade

Storage

Workers

Durability

Production

Visitors

Current Jobs

---

# Inventory

Inventory

contains IDs only.

Example

ItemID

Quantity

Durability

Enchant

Never save UI state.

---

# Equipment

Save

ItemID

Slot

Enchant

Durability

Socket

Owner

---

# Quest

Save

QuestID

Progress

Completed

Reward Claimed

Current Target

---

# Relationships

Save

Hero A

Hero B

Affinity

Friendship

Marriage

Guild

---

# World

Save

Day

Time

Weather

Festival

Boss Status

Unlocked Zones

Destroyed Objects

NPC States

---

# Economy

Save

Gold

Gems

Materials

Taxes

Trade History

Market

Production

---

# Events

Save active events.

Examples

Festival

Town Attack

World Boss

Merchant

Weather

---

# Statistics

Track

Play Time

Monster Kills

Hero Deaths

Boss Kills

Items Crafted

Buildings Built

Gold Earned

Distance Traveled

---

# Versioning

Every save

must contain

Version Number.

Example

Save Version

1

2

3

Support migration.

---

# Migration

Older saves

must be upgradeable.

Migration

should never

break saves.

---

# Validation

Before loading

validate

Version

Checksum

Required Fields

Data Types

Ranges

Never trust save data.

---

# Corrupted Saves

Attempt

Recovery

Backup

Error Message

Never crash.

---

# Autosave

Autosave

must not freeze gameplay.

Run asynchronously

when possible.

---

# Compression

Large saves

should be compressed.

---

# Encryption

Optional.

Used only

to discourage editing.

Never rely on encryption

for security.

---

# Determinism

Loading

must reproduce

exact gameplay state.

---

# References

Never save references.

Save IDs.

Reconnect

after loading.

---

# Reconstruction

Load order

World

↓

Buildings

↓

Heroes

↓

Inventory

↓

Equipment

↓

Relationships

↓

Events

↓

UI

Gameplay starts only after reconstruction.

---

# Save Frequency

Avoid saving

every small change.

Batch changes.

---

# Dirty Flag

Each system

tracks

dirty state.

Only changed data

is written.

---

# Backup

Keep

Previous Save

Autosave

Manual Save

Emergency Save

---

# Cloud Ready

Save format

must support

future cloud sync.

---

# Multiplayer Ready

Save structure

must match

network snapshot.

Offline save

should equal

server state.

---

# Testing

Verify

Save

↓

Load

↓

Save

Produces identical state.

---

# Debug

Support

Export Save

Import Save

Inspect Save

Validate Save

Migration Test

Checksum Test

---

# AI Instructions

When generating save code:

- Never serialize Nodes.
- Serialize only data.
- Use persistent IDs.
- Support version migration.
- Separate runtime state from saved state.
- Keep save format deterministic.
- Validate all loaded data.
- Design save format for future multiplayer compatibility.