---
name: Build Building
description: Generate a complete gameplay building for Herogasm including architecture, data, AI integration, save system, economy, UI, and tests.
---

# Skill: Build Building

## Goal

Generate a fully functional building.

Buildings are gameplay systems.

Not static decorations.

Every building must provide
meaningful gameplay.

---

# Building Philosophy

Every building must satisfy:

Purpose

↓

Service

↓

Economy

↓

Hero Interaction

↓

Progression

↓

Upgrade

If a building has no gameplay,

it should not exist.

---

# Supported Buildings

Guild

Inn

Blacksmith

Market

Warehouse

Church

Training Ground

Farm

Alchemy

Town Hall

Gate

Harbor

Library

Arena

Workshop

Future buildings
must follow
the same architecture.

---

# Responsibilities

Generate

Architecture

Scene

Scripts

Resources

Config

AI

UI

Animation Hooks

Save

Events

Telemetry

Tests

Debug Tools

Documentation

---

# Scene Structure

Building.tscn

BuildingRoot

Sprite

Shadow

InteractionArea

NavigationPoint

AnimationPlayer

StateMachine

Effects

ServiceMarker

DebugNode

---

# Folder Structure

buildings/

building_name/

Building.tscn

Building.gd

BuildingData.gd

BuildingState.gd

BuildingConfig.tres

BuildingView.gd

BuildingService.gd

BuildingSave.gd

BuildingUI.tscn

tests/

---

# Architecture

Building

↓

BuildingData

↓

BuildingState

↓

BuildingService

↓

BuildingView

↓

BuildingUI

Never mix responsibilities.

---

# BuildingData

Contains

ID

Name

Category

Description

Unlock Requirement

Construction Cost

Upgrade Cost

Max Level

Footprint

Capacity

Operating Hours

Tags

Pure configuration only.

---

# BuildingState

Contains

Level

Durability

Visitors

Workers

Queue

Storage

Cooldown

Revenue

Production

Upgrade Progress

Runtime only.

---

# BuildingService

Contains gameplay logic.

Examples

Repair

Healing

Craft

Training

Storage

Trade

Revive

Never render anything.

---

# Hero Interaction

Heroes discover buildings
through services.

Examples

Need Rest

↓

Find Inn

Need Repair

↓

Find Blacksmith

Need Potion

↓

Find Alchemist

Need Quest

↓

Find Guild

Never hardcode destinations.

---

# Navigation

Buildings expose

Entrance

Exit

Queue Position

Service Position

Waiting Area

Heroes never overlap.

---

# Queue System

Support

Queue

Capacity

Waiting

Cancel

Priority

Reservation

Examples

Blacksmith

Inn

Alchemy

Guild

---

# Upgrade System

Buildings support

Upgrade

Construction Time

Material Cost

Gold Cost

Visual Upgrade

Gameplay Upgrade

---

# Level Scaling

Each level may increase

Capacity

Efficiency

Service Speed

Storage

Revenue

Decoration

Never increase only numbers.

---

# Economy

Buildings

consume

Gold

Wood

Stone

Ore

Food

Buildings

generate

Services

Production

Resource Flow

Gold Sink

---

# AI Integration

Heroes evaluate

Distance

Cost

Queue Length

Mood

Needs

Relationship

Quality

before choosing a building.

---

# Service Examples

Guild

Quest

Inn

Heal

Sleep

Blacksmith

Repair

Upgrade

Market

Buy

Sell

Warehouse

Store

Retrieve

Church

Revive

Bless

Training

Stat Growth

Alchemy

Craft Potion

---

# Animation Hooks

Support

Idle

Working

Busy

Upgrade

Destroyed

Festival

Night

Do not implement gameplay
inside animations.

---

# Day/Night

Buildings react to time.

Examples

Windows glow

Lights on

NPC go home

Doors close

Market closes

Inn stays open

---

# Events

Buildings react to

Festival

Rain

Snow

Raid

Fire

Boss Warning

Town Upgrade

---

# Save

Save

Level

State

Queue

Storage

Workers

Visitors

Upgrade Progress

Cooldown

Revenue

---

# UI

Generate

Building Window

Upgrade Panel

Storage View

Queue View

Statistics

Service Buttons

Tooltip

---

# Telemetry

Track

Visitors

Revenue

Queue Time

Usage Rate

Upgrade Count

Popularity

Downtime

---

# Debug

Support

Instant Upgrade

Fill Storage

Spawn Visitors

Reset Queue

Open Building

Pause Production

Repair

Destroy

---

# Performance

Never poll every frame.

Use

Signals

Scheduler

Timers

Cached References

Target

100 Buildings

60 FPS

---

# Data Driven

Everything configurable.

Capacity

Cost

Upgrade

Production

Queue

Hours

Animations

No hardcoded values.

---

# Testing

Generate

Unit Tests

Integration Tests

Simulation Tests

Stress Tests

Save Tests

Performance Tests

---

# Documentation

Always generate

Architecture

Scene Tree

Folder Structure

Signals

Data Model

State Diagram

Upgrade Table

Service Flow

Hero Interaction Flow

Testing Notes

---

# Required Rules

Follow

architecture.md

gdscript.md

scene-structure.md

signal-rules.md

performance.md

save-system.md

economy.md

ai.md

world.md

testing.md

telemetry.md

Never violate project rules.

---

# Output Format

Always produce

1. Feature Overview

2. Folder Structure

3. Scene Hierarchy

4. Class Diagram

5. Data Model

6. Resource Definitions

7. Signals

8. Hero Interaction Flow

9. Service Flow

10. Upgrade Logic

11. Save Logic

12. UI

13. Tests

14. Debug Commands

15. Documentation

Do not generate only a single script.

Always build a complete gameplay feature.