---
name: Build Town System
description: Design and implement a complete living town system for Herogasm.
---

# Skill: Build Town

## Goal

Build a living medieval town.

The town is the heart of the game.

Heroes live here.

NPCs work here.

Buildings provide services.

The player manages the town,
not individual heroes.

---

# Design Philosophy

The town is never static.

Something is always happening.

Heroes

walk

talk

eat

repair

shop

sleep

train

receive quests

leave town

return home

The player should feel

the town is alive.

---

# Responsibilities

This skill generates

Architecture

Scenes

Scripts

Resources

UI

AI

Events

Save

Tests

Documentation

Never generate only one script.

---

# Required Systems

Town

Building System

Hero Housing

Navigation

Road Network

NPC Schedule

Town Economy

Services

Events

Weather

Lighting

Decoration

Population

Town Save

Town Simulation

---

# Buildings

Minimum buildings

Guild

Inn

Blacksmith

Market

Warehouse

Alchemy

Training Ground

Church

Town Hall

Gate

Farm

Every building
must provide gameplay.

---

# Building Responsibilities

Guild

Quest Provider

Inn

Rest

Recover

Blacksmith

Repair

Upgrade

Market

Buy

Sell

Alchemy

Potion

Training

Stats

Warehouse

Storage

Town Hall

Unlock

Upgrade

Management

Church

Revive

Blessing

Farm

Food Production

Gate

World Transition

---

# Scene Structure

Town.tscn

TownManager

Navigation

Roads

Buildings

NPC

Heroes

Spawn Points

Lighting

Weather

Decorations

Effects

Camera Bounds

---

# Folder Structure

world/

town/

Town.tscn

TownManager.gd

TownData.gd

TownConfig.tres

buildings/

npc/

roads/

navigation/

services/

events/

---

# Hero Behaviour

Inside town

Heroes

Walk

Shop

Repair

Eat

Train

Rest

Talk

Sleep

Receive Quest

Leave Town

Return Town

Heroes never stand idle forever.

---

# NPC Behaviour

NPCs

Work

Sleep

Walk

Eat

Trade

Celebrate

React to events

---

# Navigation

Heroes use

NavigationAgent2D

Roads

Entrances

Building Doors

Never teleport.

---

# Population

Town contains

Heroes

NPC

Merchant

Children

Animals

Guards

Visitors

Travelers

Population changes over time.

---

# Town Needs

Food

Storage

Defense

Economy

Reputation

Housing

Production

Research

Population

---

# Economy

Buildings consume

Gold

Wood

Stone

Ore

Food

Buildings produce

Services

Resources

Crafting

Storage

Progression

---

# Events

Town supports

Festival

Merchant

Fire

Raid

Wedding

Construction

Celebration

Weather

Boss Warning

---

# Save

Save

Building Levels

Storage

Population

NPC State

Town Reputation

Economy

Decoration

Unlocked Buildings

---

# UI

Town UI

Building Panel

Construction

Upgrade

Town Overview

Population

Economy

Storage

Event Banner

Notification

---

# AI

Heroes

choose buildings
based on

Needs

Mood

Quest

Equipment

Relationships

Gold

Distance

---

# Performance

Target

300 Heroes

100 NPC

100 Buildings

60 FPS

Use

Scheduler

Object Pool

Cached Navigation

---

# Data Driven

Everything configurable.

Buildings

Production

Costs

Unlock

NPC

Roads

Population

Events

No hardcoded values.

---

# Required Resources

TownData

BuildingData

RoadData

PopulationData

DecorationData

WeatherData

FestivalData

TownEconomyData

---

# Tests

Generate

Unit Tests

Simulation Tests

Stress Tests

Town Benchmark

Navigation Tests

Economy Tests

---

# Debug

Support

Spawn Building

Upgrade Building

Spawn Hero

Spawn NPC

Fill Storage

Trigger Festival

Skip Day

Pause Town

Show Navigation

Show Economy

---

# Deliverables

Generate

✓ Scene Tree

✓ Folder Structure

✓ Scripts

✓ Resources

✓ Save Data

✓ UI

✓ AI

✓ Tests

✓ Debug Tools

✓ Documentation

---

# Coding Rules

Follow

architecture.md

gdscript.md

scene-structure.md

performance.md

save-system.md

economy.md

ai.md

testing.md

Never violate project rules.

---

# Output Format

Always generate:

1. Architecture overview

2. Folder structure

3. Scene hierarchy

4. Data model

5. Resource definitions

6. Signals

7. Managers

8. Components

9. GDScript implementation

10. Unit tests

11. Simulation tests

12. Documentation

Never skip architecture explanation.
