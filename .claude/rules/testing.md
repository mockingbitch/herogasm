# Testing Rules

## Philosophy

Testing ensures
the world behaves correctly.

Gameplay systems

must be testable

without UI.

Logic comes first.

Rendering comes second.

---

# Testing Pyramid

        End-to-End
             ▲
      Integration Tests
             ▲
        Unit Tests

Prefer

many unit tests

few integration tests

very few E2E tests.

---

# Test Categories

Unit

Integration

Simulation

Performance

Regression

Stress

Save/Load

AI

Economy

Balance

---

# Unit Tests

Every pure logic class

must have unit tests.

Examples

Damage Formula

Loot Table

Level Formula

Relationship

Inventory

Economy

Crafting

Quest Progress

Avoid testing Nodes.

---

# Integration Tests

Test

multiple systems

working together.

Examples

Hero

↓

Combat

↓

Loot

↓

Inventory

↓

Quest

---

# Simulation Tests

Run

entire world

without UI.

Examples

100 Heroes

↓

10 Hours

↓

No crashes

↓

Economy stable

Simulation tests
are mandatory.

---

# Save Tests

Verify

Save

↓

Load

↓

Save

Produces

identical state.

Never lose data.

---

# AI Tests

Verify

Hero

always has

Goal

Target

Decision

Movement

Never idle forever.

---

# Navigation Tests

Verify

Hero

can reach

Destination.

Detect

stuck

loop

invalid path

---

# Economy Tests

Track

Gold

Materials

Craft

Repair

Trade

Inflation

Ensure

no infinite growth.

---

# Loot Tests

Verify

Drop Rate

matches

configured values.

Large sample

100000 kills

recommended.

---

# Balance Tests

Verify

Time To Kill

Boss

Dungeon

Hero Progression

Offline Rewards

Never rely

on manual testing only.

---

# Combat Tests

Verify

Damage

Critical

Armor

Death

Healing

Status Effects

Always deterministic.

---

# Performance Tests

Measure

FPS

CPU

Memory

Draw Calls

AI Tick

Pathfinding

Entity Count

Target

300 Heroes

1000 Monsters

60 FPS

---

# Stress Tests

Spawn

500 Heroes

2000 Monsters

100 Bosses

Measure

CPU

Memory

Simulation Stability

---

# Save Stress

Create

100 MB Save

Verify

Load Time

Memory

Integrity

Migration

---

# Long Simulation

Run

24 Hours

72 Hours

1 Week

Verify

Economy

Memory

AI

Events

Save

No leaks.

---

# Regression Tests

Every bug

must produce

a regression test.

Bug

↓

Test

↓

Fix

↓

Never return.

---

# Deterministic Tests

Given

same input

always produce

same result.

No hidden randomness.

---

# Random Tests

Randomness

must use

RandomService.

Seed

should be configurable.

Allows replay.

---

# Event Tests

Verify

Start

Duration

Reward

Cooldown

Persistence

---

# Building Tests

Verify

Construction

Upgrade

Repair

Storage

Production

Workers

---

# Quest Tests

Verify

Accept

Progress

Complete

Reward

Cancel

Persistence

---

# Hero Tests

Verify

Recruit

Level

Death

Revive

Equipment

Relationship

Mood

Needs

---

# Inventory Tests

Verify

Stack

Split

Move

Equip

Sell

Destroy

Craft

---

# UI Tests

Test only

critical flows.

Examples

Open Hero

Upgrade Building

Inventory

Quest

Shop

Avoid pixel-perfect tests.

---

# Data Tests

Validate

Config

Resources

IDs

References

Duplicate IDs

Missing fields

---

# Performance Budget

Loading

<3 sec

Autosave

<500 ms

AI Tick

<5 ms

Combat Tick

<3 ms

UI Update

<2 ms

---

# Logging

Tests should produce

Readable logs.

Failures

must explain

why.

---

# Test Naming

Use

Given

When

Then

Example

GivenHeroLowHP

WhenPotionAvailable

ThenDrinkPotion

---

# Coverage

Target

Logic

90%

Gameplay

80%

UI

Minimal

Generated code

must include

tests

when applicable.

---

# CI

Every Pull Request

runs

Unit Tests

Integration Tests

Data Validation

Formatting

Never merge

failing tests.

---

# Debug Tools

Support

God Mode

Fast Time

Spawn Hero

Spawn Boss

Skip Day

Unlimited Gold

Reveal Map

AI Inspector

Economy Inspector

---

# Bug Reports

Every bug

must include

Steps

Expected

Actual

Version

Save File

Log

Screenshot

---

# AI Instructions

When generating code:

- Make systems testable.
- Separate logic from Nodes.
- Prefer deterministic behavior.
- Include unit tests for pure logic.
- Include regression tests for bug fixes.
- Avoid UI-dependent gameplay logic.
- Validate data before runtime.
- Explain edge cases.