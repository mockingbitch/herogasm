# World Rules

## Philosophy

The world is always alive.

Heroes continue living
even without player interaction.

NPCs follow schedules.

Monsters migrate.

Weather changes.

Time passes.

The world never pauses.

---

# World Structure

World

↓

Regions

↓

Zones

↓

Areas

↓

Buildings

↓

Entities

Everything belongs
to exactly one parent.

---

# World Layers

World

Town

Road

Field

Dungeon

Indoor

Underground

Sky

Each layer
has clear responsibility.

---

# Main World

Contains

Town

Forest

Mountain

Lake

Swamp

Desert

Volcano

Ruins

Dungeon

Castle

Future regions
can be added
without changing code.

---

# Region

Each region has

Theme

Weather

Monsters

Resources

Boss

Music

Lighting

Events

Every region
must feel unique.

---

# Zone

A region contains

multiple hunting zones.

Example

Forest

↓

Beginner Field

↓

Goblin Camp

↓

Wolf Hill

↓

Ancient Tree

↓

Forest Boss

---

# Town

Town is

the player's home.

Contains

Guild

Inn

Blacksmith

Market

Church

Training Ground

Farm

Warehouse

Alchemy

Town Hall

Harbor

Gate

Every building
has gameplay purpose.

---

# Roads

Heroes

always travel

using roads

when possible.

Roads connect

Town

↓

Regions

↓

Zones

↓

Dungeon

Roads improve
world readability.

---

# Gates

Every dangerous area

has gates.

Heroes

leave

and return

through gates.

Avoid teleportation.

---

# Hunting Zones

Every hunting zone

has

Recommended Level

Monster Pool

Resource Nodes

Rare Spawn

Mini Boss

Environment Theme

---

# Safe Zones

Safe zones

contain

No Combat

NPC

Shop

Rest

Storage

Festival

---

# Dangerous Zones

Contain

Aggressive Monsters

Rare Loot

Elite Monsters

Bosses

Resources

Higher Risk

Higher Reward

---

# Dungeon

Dungeon contains

Floors

Rooms

Boss

Treasure

Events

Shortcuts

Respawn Rules

---

# World Progression

Players unlock

new regions

through

Buildings

Hero Level

Story

Boss

Quest

Never unlock
everything immediately.

---

# Navigation

Heroes travel

physically.

Never teleport

unless

Fast Travel

Magic

Event

---

# Travel Time

Distance matters.

Nearby zones

short travel.

Far zones

long travel.

Travel affects

AI decisions.

---

# Resource Distribution

Each region

owns exclusive resources.

Avoid universal drops.

---

# Monster Distribution

Every monster

belongs

to one or more

regions.

Avoid spawning

everything everywhere.

---

# Population

Every region

contains

Heroes

NPC

Monsters

Animals

Merchants

Travelers

The world feels populated.

---

# Dynamic Population

Population changes

based on

Events

Time

Weather

Festival

Danger

---

# Day Night Cycle

Morning

Noon

Evening

Night

Changes

Lighting

NPC Schedule

Hero Behavior

Monster Spawn

Music

Weather

---

# Weather

Weather affects

Visibility

Movement

Fishing

Farming

Mood

Monster Spawn

Loot

Never cosmetic only.

---

# Seasons

Spring

Summer

Autumn

Winter

Each season changes

Plants

Monsters

Events

Weather

Economy

Visuals

---

# Environment

Environment should contain

Trees

Bushes

Flowers

Rocks

Rivers

Bridges

Signs

Campfires

Animals

Decorations

Avoid empty maps.

---

# World Objects

Objects include

Ore

Trees

Fishing Spots

Herbs

Treasure

Broken Cart

Shrines

Camp

Ruins

Objects are interactive.

---

# NPC Schedule

NPCs

work

eat

sleep

shop

travel

celebrate

Avoid static NPCs.

---

# Hero Schedule

Heroes

Quest

Travel

Hunt

Sell

Repair

Eat

Sleep

Repeat

---

# World Events

Events may affect

One Area

One Region

Entire World

---

# Boss

Bosses occupy

real locations.

Players

see boss areas

before combat.

---

# Spawn Rules

Monsters

spawn

naturally.

Avoid popping
into existence

inside player view.

---

# Respawn

Respawn

should feel natural.

Use

Nest

Camp

Portal

Burrow

instead of random appearance.

---

# Exploration

Exploration

should reward

Materials

Lore

Treasure

Recipes

Rare Monsters

Scenic Areas

---

# Visibility

Players should always see

something moving.

Heroes

NPCs

Animals

Flags

Smoke

Water

Wind

The world never feels dead.

---

# Map Design

Readable.

Landmarks

Roads

Rivers

Mountains

Buildings

Help navigation.

---

# World Boundaries

Avoid invisible walls.

Prefer

Cliffs

Mountains

Ocean

Collapsed Roads

Magic Barrier

---

# Performance

Far regions

simulate

using low-frequency updates.

Only nearby regions

run full simulation.

---

# Persistence

World remembers

Destroyed Objects

Boss Death

Unlocked Areas

Town Growth

Running Events

---

# Fast Travel

Unlocked gradually.

Requires

Building

Quest

Magic

Never available immediately.

---

# Data Driven

Regions

Zones

Monsters

Weather

Events

must come from data.

No hardcoded worlds.

---

# Debug

Support

Teleport

Spawn Hero

Spawn Boss

Change Weather

Change Time

Reveal Map

Region Inspector

World State Viewer

---

# AI Instructions

When generating world systems:

- Make the world feel alive.
- Heroes travel physically.
- Every region should feel unique.
- Avoid empty environments.
- Connect systems through the world.
- Keep all world data configurable.
- Design for future expansion.