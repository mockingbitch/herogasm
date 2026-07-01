# UI Rules

## Philosophy

UI exists to support gameplay.

UI should never overwhelm the player.

Gameplay is the focus.

UI must feel lightweight.

The world should always remain visible.

---

# Design Goals

Simple

Readable

Minimal

Pixel Perfect

Responsive

Mobile First

Information Rich

Low Interaction Cost

---

# Reference

Inspired by

Evil Hunter Tycoon

Dungeon Village

Ragnarok

Guardian Tales

Loop Hero

---

# UI Architecture

Gameplay

↓

Game State

↓

ViewModel

↓

UI

UI never reads gameplay directly.

UI never modifies gameplay directly.

---

# UI Layers

CanvasLayer

├── HUD
├── Popup
├── Notification
├── Tooltip
├── Dialog
├── FullScreen
├── Debug

Never mix layers.

---

# HUD

HUD is always visible.

Contains

Top Resource Bar

Hero Status

Quest Status

Event Banner

Mini Map

Game Speed

Notification

Nothing else.

---

# Top Bar

Always visible.

Contains

Gold

Gem

Wood

Stone

Food

Population

Day

Weather

FPS (Debug)

Keep compact.

---

# Bottom Navigation

Maximum

5 buttons.

Recommended

Town

Heroes

World

Inventory

Menu

Avoid long navigation bars.

---

# Popup Rules

Popup

must block

only related interaction.

Never freeze entire game

unless necessary.

---

# Dialog Rules

Dialogs

must support

Close

Escape

Outside Click

Controller

Touch

---

# Hero Window

Shows

Portrait

Class

Level

HP

MP

Equipment

Skills

Mood

Needs

Relationship

Current Task

Target

Location

Never show debug information.

---

# Building Window

Contains

Level

Workers

Visitors

Services

Upgrade

Storage

Production

Repair

Simple.

---

# Tooltip

Appears

<200ms

Contains

Name

Description

Stats

Effects

Never large paragraphs.

---

# Notifications

Small

Auto disappear

Stack vertically.

Examples

Hero leveled up

Boss spawned

Quest completed

Festival started

---

# Floating Text

Allowed

Damage

Heal

EXP

Gold

Critical

Avoid

Long messages.

---

# UI Update

Update only

when state changes.

Never

every frame.

Use

Signals

ViewModels

Bindings

---

# Lists

Virtualize long lists.

Support

Sorting

Filtering

Searching

---

# Hero List

Display

Portrait

Class

Level

Mood

HP

Task

Location

Never load every hero widget at once.

---

# Minimap

Update

5 FPS

Support

Hero icons

Boss

Town

Events

Quest

Avoid

Real-time animation.

---

# Inventory

Grid

Auto sort

Filter

Search

Compare

Lock

Favorite

Batch Sell

Never scroll horizontally.

---

# Shop

Display

Item

Price

Stock

Discount

Compare

Purchase

Keep interactions minimal.

---

# Buttons

Minimum size

48 px

Touch friendly.

Visual feedback

Hover

Pressed

Disabled

Selected

---

# Color

Green

Positive

Red

Danger

Yellow

Warning

Blue

Information

Purple

Rare

Orange

Legendary

Never rely on color alone.

---

# Icons

Always prefer icons

before text.

Consistent style.

Pixel art only.

---

# Fonts

Pixel font

High readability

No anti alias

Minimum size

14 px

---

# Animation

Fast

150~300 ms

Never delay gameplay.

---

# Transitions

Fade

Slide

Scale

Simple.

Avoid excessive effects.

---

# Screen Shake

Gameplay only.

Never shake UI.

---

# Loading

Show

Progress

Tips

Pixel animation

Never freeze screen.

---

# Error Messages

Clear

Short

Actionable

Never technical.

---

# Confirmation

Require confirmation

only for

Delete

Sell Rare

Reset

Exit Dungeon

Avoid confirmation spam.

---

# Accessibility

Support

Large Text

Color Blind

Reduced Motion

High Contrast

Touch Controls

---

# Mobile

One thumb friendly.

Important buttons

reachable from bottom.

Avoid tiny buttons.

---

# Landscape

Primary orientation.

Support tablets.

---

# Performance

Reuse widgets.

Virtual scrolling.

Object Pool

for floating texts.

Never recreate UI every update.

---

# Debug UI

Separate layer.

Never ship enabled.

Contains

FPS

Memory

AI

Pathfinding

Entities

---

# Pixel Art Rules

Integer scaling only.

No blur.

No smooth filtering.

Pixel perfect camera.

Consistent palette.

---

# Notification Priority

Critical

Boss

Town Attack

Low HP

Inventory Full

Medium

Quest

Hero Return

Building Complete

Low

Loot

Gold

EXP

---

# World Visibility

Never allow UI

to hide

more than

40%

of gameplay.

The player should always see

the living world.

---

# AI Instructions

When generating UI:

- Keep gameplay visible.
- Use event-driven updates.
- Minimize clicks.
- Prefer icons over text.
- Design for mobile first.
- Reuse widgets.
- Separate UI from gameplay.
- Support pixel-perfect rendering.