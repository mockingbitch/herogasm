# Debug Tools Rules

## Philosophy

Developer tools
must exist
from the beginning.

Every gameplay system

must be inspectable.

Never debug
by modifying gameplay code.

Build proper tools.

---

# Goals

Debug tools should allow developers to

Inspect

Modify

Spawn

Destroy

Skip Time

Fast Forward

Visualize

Profile

without restarting the game.

---

# Build Types

Release

No debug tools.

Development

All debug tools enabled.

Editor

Everything enabled.

QA

Limited tools.

---

# Debug Overlay

Always available.

Displays

FPS

Frame Time

Memory

CPU

Node Count

Hero Count

Monster Count

NPC Count

Loot Count

Pool Usage

Scheduler

Save Status

Weather

Current Time

Current Region

---

# Debug Menu

Categories

World

Heroes

Monsters

Buildings

Economy

Combat

Events

Weather

Performance

Simulation

Save

Audio

UI

AI

Navigation

---

# World Commands

Support

Pause Time

Resume Time

Skip Hour

Skip Day

Skip Week

Fast Forward

Slow Motion

Change Season

Reveal Map

Fog Of War

World Reset

---

# Hero Commands

Spawn Hero

Delete Hero

Clone Hero

Kill Hero

Revive Hero

Teleport Hero

Heal Hero

Damage Hero

Level Up

Change Class

Change Equipment

Clear Inventory

Fill Inventory

Reset Needs

Reset Mood

Reset Relationships

Force AI State

Force Current Goal

---

# Monster Commands

Spawn Monster

Spawn Elite

Spawn Boss

Kill All

Freeze Monsters

Respawn

Change Aggression

Force Migration

Force Respawn

---

# Building Commands

Instant Build

Instant Upgrade

Destroy Building

Repair Building

Change Level

Change Owner

Reset Storage

Fill Storage

---

# Economy Commands

Add Gold

Remove Gold

Add Gems

Give Materials

Clear Inventory

Spawn Rare Item

Unlock Recipe

Reset Economy

Inflation Test

---

# Combat Commands

God Mode

One Hit Kill

Infinite Mana

Infinite Stamina

Disable Cooldowns

Disable Damage

Spawn Arena

Force Combat

Kill Target

Show Damage Formula

---

# Quest Commands

Complete Quest

Fail Quest

Reset Quest

Unlock Quest

Spawn Quest

Force Reward

Clear Quest Log

---

# Event Commands

Start Festival

End Festival

Spawn Merchant

Spawn Caravan

Start Boss Event

Town Attack

Meteor

Goblin Raid

Double EXP

Double Gold

Weather Event

---

# Weather Commands

Sunny

Rain

Snow

Fog

Storm

Thunder

Wind

Random Weather

Freeze Weather

---

# Save Commands

Manual Save

Load Save

Quick Save

Quick Load

Export Save

Import Save

Validate Save

Repair Save

Show Save Info

---

# Simulation Commands

Start Simulation

Pause Simulation

Stop Simulation

Fast Forward

Run 1 Hour

Run 1 Day

Run 1 Week

Run 30 Days

Run Benchmark

Run AI Test

Run Economy Test

---

# Performance Commands

Enable Profiler

Disable Profiler

Memory Snapshot

Pool Stats

Scheduler Stats

AI Tick Graph

Combat Graph

Navigation Graph

Show Draw Calls

GC Statistics

---

# Navigation Commands

Show Navigation Mesh

Show Paths

Show Current Target

Show Destination

Show Stuck Heroes

Force Repath

Highlight Invalid Paths

---

# AI Commands

Show Current State

Show Goal

Show Needs

Show Mood

Show Personality

Show Target

Show Memory

Show Decision Score

Pause AI

Resume AI

Single Step AI

---

# Relationship Commands

View Relationship Graph

Force Friendship

Force Marriage

Force Rival

Clear Relationships

---

# Loot Commands

Spawn Loot

Force Legendary

Clear Loot

Show Drop Table

Test Drop Rate

---

# Camera Commands

Free Camera

Follow Hero

Follow Monster

Zoom

Grid

Collision

Navigation

Lighting

---

# Visual Debug

Toggle

Collision

Navigation

Hitboxes

Aggro Radius

Detection Radius

Spawn Points

Loot Radius

Interaction Radius

---

# Entity Inspector

Select Entity

Displays

ID

State

Goal

Position

Target

Equipment

Inventory

Needs

Mood

Relationships

Combat Stats

Scheduler Slot

Current Task

---

# Scheduler Inspector

Show

Queue

Tick Time

Pending Jobs

Hero Updates

Monster Updates

Delayed Tasks

---

# Event Inspector

Show

Active Events

Cooldowns

Duration

Rewards

Participants

---

# Economy Inspector

Show

Gold Flow

Material Flow

Repair Cost

Craft Cost

Taxes

Inflation

Production

Consumption

---

# Memory Inspector

Show

Objects

Nodes

Resources

Textures

Pools

Leaks

References

---

# Benchmark Tools

One Click

Run Benchmark

Generate Report

Compare Previous

Export CSV

Export JSON

---

# Developer Shortcuts

F1

Help

F2

Overlay

F3

Profiler

F4

Spawn Menu

F5

Quick Save

F6

Quick Load

F7

Simulation

F8

Benchmark

F9

Pause AI

F10

Entity Inspector

F11

Performance

F12

Debug Console

---

# Debug Console

Support commands

help

spawn

kill

tp

gold

weather

event

save

load

benchmark

simulation

time

hero

monster

building

economy

quest

boss

---

# Logging

Support

Info

Warning

Error

Performance

AI

Economy

Combat

Save

Navigation

Never spam logs.

---

# Reports

Export

Performance

Simulation

Economy

AI

Navigation

Memory

Regression

Save Validation

---

# Safety

Debug tools

must never

be available

in Release builds.

---

# AI Instructions

When generating gameplay systems:

- Every major system should expose debug hooks.
- Every manager should have an inspector.
- Every entity should be inspectable.
- Prefer visual debugging over log spam.
- Include developer console commands.
- Support simulation and benchmarking.
- Keep debug tools modular and removable.