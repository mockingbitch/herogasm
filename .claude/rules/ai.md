# AI Rules

## Philosophy

Heroes are autonomous.

Player influences heroes.

Player never controls heroes directly.

Heroes should feel alive.

Heroes make decisions.

Heroes have personality.

Heroes have needs.

Heroes have memories.

Heroes have relationships.

Heroes have goals.

---

# AI Hierarchy

World AI

↓

Town AI

↓

Hero AI

↓

Combat AI

↓

Animation

Each layer has one responsibility.

---

# Hero Brain

Every Hero owns

Brain

Memory

Needs

Mood

Relationship

Inventory

Equipment

Quest

Combat

Navigation

---

# Decision Order

Every decision follows

Survival

↓

Safety

↓

Quest

↓

Profit

↓

Relationship

↓

Entertainment

↓

Idle

Heroes never randomly wander.

Everything has purpose.

---

# Hero Needs

Every Hero has

HP

Mana

Stamina

Food

Sleep

Mood

Equipment Durability

Inventory Space

Relationships

Need values

0~100

---

# Need Priority

Critical

HP

Food

Equipment Broken

High

Sleep

Potion

Inventory Full

Medium

Quest

Training

Shopping

Low

Social

Exploration

Idle

---

# Daily Routine

Morning

Eat

↓

Quest

↓

Travel

↓

Hunt

↓

Loot

↓

Return

↓

Repair

↓

Sell

↓

Eat

↓

Rest

↓

Sleep

---

# Decision Interval

Combat

100 ms

Movement

250 ms

Needs

1 sec

Mood

5 sec

Relationship

10 sec

Economy

30 sec

Never think every frame.

---

# Goal System

Every Hero always has

exactly one

Primary Goal

Examples

Reach Inn

Kill Goblin

Return Home

Repair Sword

Buy Potion

Sleep

Train

---

# Secondary Goals

May exist.

Examples

Collect Herbs

Talk Friend

Buy Food

Upgrade Weapon

---

# Mood

Mood changes

combat

death

victory

friendship

festival

food

sleep

weather

Low mood

reduces efficiency.

---

# Personality

Each Hero has traits.

Examples

Brave

Coward

Greedy

Lazy

Hardworking

Friendly

Aggressive

Explorer

Collector

Every decision

is influenced

by personality.

---

# Relationships

Heroes remember

Friends

Enemies

Guild Members

Partner

Teacher

Family

Relationships influence

behavior.

---

# Memory

Heroes remember

Boss Death

Rare Loot

Friend Death

Favorite Shop

Danger Zone

Last Rest

Never behave like goldfish.

---

# Travel

Heroes always walk.

Never teleport.

Route

Town

↓

Gate

↓

Road

↓

Forest

↓

Target

↓

Return

---

# Hunting

Hero chooses hunting area

based on

Level

Equipment

Mood

Quest

Danger

Distance

Competition

---

# Target Selection

Priority

Quest Target

↓

Aggro Monster

↓

Nearest Monster

↓

Weakest Monster

↓

Random

Avoid constant target switching.

---

# Retreat

Hero retreats when

HP Low

Potion Empty

Equipment Broken

Inventory Full

Night (optional)

---

# Shopping

Hero buys

Potion

Food

Repair

Upgrade

Equipment

Based on

Gold

Needs

Mood

---

# Repair

Repair priority

Weapon

Armor

Accessory

Never hunt

with broken equipment.

---

# Inventory

When inventory full

Hero

returns

Town

Sell

Store

Craft

---

# Social

Heroes

Talk

Eat

Celebrate

Sleep

Train

Together

Never stand still forever.

---

# Guild

Heroes

receive quests

share information

join boss fights

help allies

---

# Combat AI

Think

every 100~200 ms

Choose

Target

Skill

Potion

Retreat

Movement

Never spam decisions.

---

# Skill Usage

Choose skills

based on

Distance

Cooldown

Mana

Enemy Count

Priority

Avoid random skill spam.

---

# Boss AI

Boss

changes phase

calls minions

changes attack

changes target

Avoid HP sponge.

---

# Monster AI

Roam

Patrol

Aggro

Chase

Attack

Return

Sleep

Respawn

Simple but efficient.

---

# World AI

Controls

Weather

Festival

Merchant

Boss Spawn

World Event

NPC Schedule

Not individual heroes.

---

# Scheduler

AI is updated

through scheduler.

Never

300 heroes

thinking simultaneously.

---

# Sleep State

Far heroes

may enter

Low Frequency Mode.

Simulation continues

with reduced updates.

---

# Animation

Animation

never controls AI.

AI

requests animation.

---

# Data Driven

AI values

must come from

Resources.

Examples

Aggression

Cowardice

Shopping Chance

Repair Threshold

Sleep Threshold

---

# Randomness

AI uses

RandomService.

Never

randf()

inside AI.

---

# Learning

Future Ready.

AI may learn

preferred hunting zones

favorite shops

dangerous bosses

best routes

---

# Debug

Support

Current State

Current Goal

Need Values

Mood

Relationship

Path

Target

Reason

Always explain

why a Hero

made a decision.

---

# AI Instructions

When generating AI:

- Heroes must always have a purpose.
- Never leave Heroes idle without reason.
- Use Goal-driven decisions.
- Update AI using scheduler.
- Avoid frame-based thinking.
- Separate AI from animation.
- Keep behavior data-driven.
- Make Heroes feel like independent adventurers.