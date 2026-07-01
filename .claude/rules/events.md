# Event System Rules

## Philosophy

Events make the world feel alive.

The world should change
even without player interaction.

Events should create
stories,
choices,
and opportunities.

Events are temporary.

Their consequences may be permanent.

---

# Event Categories

World

Town

Hero

Guild

Season

Weather

Combat

Economy

Festival

Disaster

Boss

Community

---

# Event Lifecycle

Scheduled

↓

Announced

↓

Preparation

↓

Active

↓

Ending

↓

Reward

↓

Cooldown

Every event has a beginning
and an end.

---

# Event Manager

Only EventManager
controls events.

Responsibilities

Schedule

Start

Stop

Broadcast

Reward

Persistence

Never let gameplay systems
start events directly.

---

# World Events

Examples

World Boss

Meteor Shower

Goblin Invasion

Dragon Migration

Lost Caravan

Magic Storm

Ancient Ruins

Plague

Solar Eclipse

These affect
the whole world.

---

# Town Events

Examples

Harvest Festival

Market Day

Wedding

Fire

Bandit Raid

Merchant Visit

Building Contest

Hero Tournament

These affect
only one town.

---

# Hero Events

Examples

Hero Birthday

Hero Retirement

Hero Marriage

Hero Promotion

Hero Injury

Hero Betrayal

Hero Lost

Hero Discovery

These affect
specific heroes.

---

# Weather Events

Sunny

Rain

Storm

Snow

Fog

Heat Wave

Thunderstorm

Weather changes

AI

Visibility

Movement

Loot

Mood

Fishing

Crop Growth

---

# Seasonal Events

Spring

Summer

Autumn

Winter

Each season changes

Resources

Monsters

Shops

Weather

Festivals

Quests

Visuals

---

# Festival Events

Festival

creates

Special NPC

Special Shop

Special Currency

Special Decorations

Special Quests

Festival ends automatically.

---

# Economy Events

Double Gold

Market Discount

Inflation

Merchant Caravan

Trade Fair

Blacksmith Week

Auction Festival

Economy should feel dynamic.

---

# Combat Events

Monster Frenzy

Elite Spawn

Dungeon Surge

Boss Rage

Double EXP

Rare Drop

These encourage hunting.

---

# Guild Events

Guild War

Guild Expedition

Guild Boss

Guild Race

Guild Festival

Guild Donation Week

Future ready.

---

# Disaster Events

Earthquake

Fire

Flood

Locust

Plague

Bandits

Magic Corruption

Disasters

create new gameplay

instead of punishment only.

---

# Event Duration

Small

5~15 minutes

Medium

30~60 minutes

Large

Several hours

Seasonal

Days

Never permanent
unless intended.

---

# Event Rewards

Rewards should include

Gold

Materials

Titles

Cosmetics

Recipes

Buildings

Pets

Reputation

Avoid only giving gold.

---

# Event Currency

Temporary.

Used only

during event.

Removed afterward.

Never accumulate forever.

---

# Event Difficulty

Events scale with

Player Progress

Town Level

Hero Level

World Tier

Avoid impossible events.

---

# World Boss Event

Announcement

↓

Spawn

↓

Fight

↓

Victory / Failure

↓

Rewards

↓

Cooldown

Bosses should feel important.

---

# Merchant Event

Traveling Merchant

arrives

randomly.

Offers

Rare Items

Recipes

Cosmetics

Discounts

Leaves after time expires.

---

# Dynamic Events

Triggered by

Player Actions

Examples

Too many wolves killed

↓

Wolf Alpha appears

Many heroes die

↓

Priest requests donations

Town wealth increases

↓

Bandits attack

---

# Chain Events

Events may trigger
other events.

Example

Storm

↓

Flood

↓

Bridge Destroyed

↓

Road Closed

↓

Merchant Delayed

---

# Hero Participation

Heroes decide

whether to join events

based on

Level

Mood

Quest

Personality

Reward

Danger

---

# Town Reaction

NPCs react

to active events.

Examples

Hide

Celebrate

Shop Closed

Run Away

Dance

Repair

Pray

The town must change visually.

---

# Event Persistence

Save

Running Events

Remaining Time

Rewards

State

Progress

---

# Event Scheduler

Events

must not overlap excessively.

Maximum

1 Major Event

2 Medium Events

Several Minor Events

Maintain readability.

---

# Event Frequency

Small

Several times/day

Medium

Daily

Large

Weekly

Season

Monthly

Avoid event spam.

---

# Visual Feedback

Every event changes

Music

Sky

Lighting

NPC Behavior

Decorations

Particles

Announcements

The player should notice
without opening menus.

---

# Notifications

Notify player

Before

Start

Ending Soon

Finished

Reward Ready

Never spam.

---

# Multiplayer Ready

Events

must support

Shared State

Progress

Contribution

Ranking

Rewards

---

# Data Driven

Every event

must be defined

through data.

Configurable

without code changes.

---

# Debug

Support

Force Start

Force End

Skip Time

Change Weather

Spawn Event

Inspect State

---

# AI Instructions

When generating events:

- Make the world feel alive.
- Events must change gameplay.
- Prefer temporary mechanics over permanent buffs.
- Include visual changes.
- Include AI reactions.
- Include meaningful rewards.
- Keep all event data configurable.