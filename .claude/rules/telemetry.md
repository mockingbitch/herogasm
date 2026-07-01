# Telemetry Rules

## Philosophy

Everything measurable
should be measured.

Do not guess.

Measure first.

Balance later.

Telemetry exists to improve
gameplay decisions.

Not marketing.

---

# Goals

Collect

Gameplay

Economy

Performance

AI

World

Player

Statistics

Automatically.

---

# Principles

Telemetry must be

Lightweight

Anonymous

Configurable

Versioned

Low overhead

Never block gameplay.

---

# Event Flow

Gameplay

↓

Telemetry Event

↓

Buffer

↓

Exporter

↓

Storage

↓

Dashboard

Never write directly
from gameplay.

---

# Event Categories

Player

Hero

Combat

Economy

Inventory

Quest

Building

World

Event

Performance

Error

Save

AI

Navigation

---

# Player Events

Track

Game Start

Game Exit

Session Length

Play Time

Region Unlock

Building Upgrade

Hero Recruit

Hero Death

Quest Complete

Boss Kill

Idle Time

Offline Time

---

# Hero Events

Track

Created

Deleted

Level Up

Death

Revive

Equipment Change

Skill Upgrade

Mood Change

Relationship Change

Quest Accepted

Quest Completed

Travel

Repair

Shopping

Sleeping

Training

---

# AI Events

Track

Goal Selected

Goal Completed

State Changed

Target Changed

Decision Time

Failed Decision

Idle Duration

Retreat

Path Failure

Stuck Recovery

---

# Combat Events

Track

Attack

Skill Cast

Critical

Dodge

Kill

Death

Boss Fight

Potion Use

Damage Taken

Damage Dealt

Healing

Fight Duration

---

# Economy Events

Track

Gold Earned

Gold Spent

Material Gained

Material Consumed

Repair Cost

Craft Cost

Upgrade Cost

Trade

Tax

Market Purchase

Market Sale

---

# Inventory Events

Track

Item Added

Item Removed

Equip

Unequip

Sell

Craft

Recycle

Stack

Split

Destroy

---

# Building Events

Track

Construct

Upgrade

Repair

Production

Visitors

Revenue

Storage

Downtime

---

# Quest Events

Track

Accept

Complete

Fail

Cancel

Reward

Abandon

Average Completion Time

---

# World Events

Track

Weather

Festival

Merchant

Boss Spawn

Boss Kill

Town Attack

Disaster

Region Unlock

---

# Navigation Events

Track

Travel Distance

Travel Time

Path Requests

Failed Paths

Repath Count

Stuck Hero

---

# Save Events

Track

Save Time

Load Time

Save Size

Migration

Autosave

Failed Save

Corrupted Save

---

# Performance Events

Track

FPS

Memory

CPU

Draw Calls

AI Tick

Combat Tick

Navigation Tick

Save Time

Load Time

Pool Usage

---

# Error Events

Track

Crash

Assertion

Exception

Invalid State

Duplicate ID

Missing Resource

Null Reference

Corrupted Save

---

# Session Metrics

Collect

Session Length

Average FPS

Average Hero Count

Average Gold

Boss Kills

Quest Count

Offline Time

Play Style

---

# Funnels

Track funnels.

Example

New Hero

↓

Quest

↓

First Equipment

↓

First Boss

↓

Second Region

↓

Guild

↓

Dungeon

Measure drop-off.

---

# Heatmaps

Generate

Deaths

Boss Kills

Travel

Population

Loot

Building Visits

Path Usage

---

# Economy Dashboard

Display

Gold In

Gold Out

Inflation

Craft Count

Repair Count

Average Wealth

Richest Hero

Poorest Hero

---

# AI Dashboard

Display

Goal Distribution

State Distribution

Decision Time

Idle Heroes

Stuck Heroes

Mood

Relationship

---

# Combat Dashboard

Display

Most Used Skills

Average DPS

Average Fight Time

Critical Rate

Death Rate

Boss Success

Potion Usage

---

# Building Dashboard

Display

Usage Rate

Upgrade Rate

Visitors

Revenue

Storage

Downtime

Unused Buildings

---

# Event Dashboard

Display

Participation

Completion

Reward Claimed

Duration

Popularity

---

# Resource Dashboard

Track

Gold

Ore

Wood

Crystal

Potion

Food

Equipment

Repair

Upgrade

Everything should have
sources and sinks.

---

# Telemetry Buffer

Events should be buffered.

Avoid writing immediately.

Flush periodically.

---

# Sampling

High frequency events

may be sampled.

Examples

Movement

Damage

Pathfinding

Never sample

Boss Kill

Quest Complete

Save Failure

---

# Privacy

Never collect

Player name

Email

IP

Personal data

Telemetry is gameplay only.

---

# Export Format

Support

JSON

CSV

SQLite

Parquet

Version every schema.

---

# Offline Mode

Store locally.

Upload later
if online mode exists.

---

# Versioning

Every event contains

Game Version

Telemetry Version

Timestamp

Build

Session ID

Player ID (anonymous)

---

# Debug

Developer can

View Event Stream

Export Logs

Replay Session

Inspect Metrics

Clear Buffer

---

# Performance Budget

Telemetry must use

<1%

CPU

<10 MB

Memory

Never affect gameplay.

---

# AI Instructions

When generating gameplay systems:

- Emit telemetry for meaningful events.
- Avoid logging every frame.
- Buffer telemetry.
- Keep event schemas versioned.
- Prefer structured events over text logs.
- Measure gameplay, not personal data.
- Support dashboards and replay tools.