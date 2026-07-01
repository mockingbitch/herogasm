# Multiplayer Rules

## Philosophy

This project is offline-first.

However,

all gameplay systems

must be designed

to support future multiplayer.

Never tightly couple gameplay

with local player logic.

---

# Authority

Every gameplay action

must have an owner.

Examples

Hero

Monster

Item

Quest

Building

Guild

Boss

Every entity owns its state.

---

# Client / Server

Architecture

Client

↓

Server

↓

Database

Gameplay logic should never assume

it runs locally.

---

# Single Source of Truth

Each gameplay state

has exactly one authority.

Examples

Hero HP

Inventory

Gold

Equipment

Quest Progress

Guild

Market

Never duplicate state.

---

# Deterministic Logic

Gameplay should produce

the same result

given the same input.

Avoid hidden randomness.

Random numbers

must come from

RandomService.

---

# Entity IDs

Every entity

must have

persistent unique ID.

HeroID

MonsterID

ItemID

QuestID

GuildID

BuildingID

Never use

NodePath

Node Name

Array Index

as identifiers.

---

# Data Model

Runtime

↓

Entity

↓

Component

↓

Data

Network

should synchronize

data

not nodes.

---

# Save Model

Save data

must match

network data.

Offline save

=

online snapshot.

---

# Commands

Gameplay actions

should be commands.

Examples

MoveHeroCommand

AttackCommand

EquipItemCommand

AcceptQuestCommand

UpgradeBuildingCommand

Commands

are serializable.

---

# Events

Gameplay emits events.

Examples

HeroKilled

MonsterSpawned

QuestCompleted

ItemDropped

BossSpawned

Events

can be replayed.

---

# Simulation

Simulation

must not depend

on FPS.

Simulation

runs by ticks.

Example

Combat

10 Tick/sec

Need System

1 Tick/sec

Economy

0.2 Tick/sec

---

# Hero

Hero never reads keyboard.

Hero only receives

Orders

AI

Quest

Movement Target

Combat Target

Player never controls Hero directly.

---

# Movement

Movement

always uses

Destination

Never

Input

This works

both offline

and online.

---

# Combat

Combat

must not depend

on animation timing.

Animation

plays after

combat result.

---

# Inventory

Inventory

is pure data.

Never

store UI

inside inventory.

---

# UI

UI

only displays state.

UI

never changes gameplay directly.

Correct

Button

↓

Command

↓

Gameplay

↓

State Changed

↓

UI Updated

Wrong

Button

↓

HP += 100

---

# Time

Never use

OS time

inside gameplay.

Always use

Game Time.

---

# Economy

Economy

must support

Server Authority.

Never trust client.

---

# Trading

Trading

must use

transaction objects.

Trade

Player A

↓

Offer

↓

Accept

↓

Commit

Never modify inventory directly.

---

# Guild

Guild

is data.

Members

Permissions

Buildings

War

Storage

Never depend on UI.

---

# Chat

Chat

is isolated.

Never couple

chat

with gameplay.

---

# Market

Market

is service.

Items

Listings

Purchase

History

Transactions

Everything

identified by ID.

---

# World Boss

Boss

owns state.

HP

Target

Aggro

Loot

Phase

Never duplicate boss state.

---

# AI

AI

runs

independently

from networking.

Networking

only synchronizes

results.

---

# Serialization

Everything important

must support serialization.

Hero

Inventory

Equipment

Quest

Relationship

Town

Guild

---

# Prediction

Gameplay

must allow

future client prediction.

Movement

Combat

Loot

Commands

---

# Rollback

Never use

frame-dependent logic.

Gameplay

must support replay.

---

# Floating Objects

Damage Number

Particles

Camera Shake

Screen Flash

are client only.

Never synchronize.

---

# Audio

Client only.

Never synchronize sounds.

---

# Animation

Client only.

Gameplay

must work

without animation.

---

# Network Messages

Small

Deterministic

ID-based

Never send

entire objects.

Good

HeroID

TargetID

SkillID

Bad

Whole Hero Object

---

# Bandwidth

Synchronize

only changed data.

Avoid

full snapshots

every tick.

---

# Security

Never trust client.

Server validates

Damage

Gold

Items

Equipment

Trades

Quests

Everything.

---

# Testing

Every gameplay feature

should work

without UI.

Every gameplay feature

should be serializable.

Every gameplay feature

should survive

save/load.

---

# AI Instructions

When generating code:

- Separate gameplay from presentation.
- Never assume local authority.
- Use IDs instead of Node references.
- Design commands to be serializable.
- Keep gameplay deterministic.
- Separate state from visualization.
- Assume future server authority.
- Never couple gameplay with networking implementation.