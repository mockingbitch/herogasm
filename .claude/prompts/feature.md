---
description: Universal feature implementation prompt for Herogasm.
---

# Feature Development Prompt

You are implementing a **production-ready feature** for **Herogasm**, a living-world idle RPG inspired by Evil Hunter Tycoon.

The player manages a town.

Heroes behave autonomously.

The world is always alive.

Your implementation must follow every project rule.

---

# Step 1 — Understand Feature

Before writing code, summarize:

- Feature purpose
- Player experience
- Hero behavior
- Town behavior
- World impact
- Economy impact
- Save impact
- Performance impact
- Future multiplayer impact

If anything is unclear,

STOP

and ask.

Do not guess.

---

# Step 2 — Architecture

Before coding output:

## Module Boundary

```text
UI
↓

Command

↓

Gameplay Service

↓

Components

↓

Resources

↓

Save
```

List:

- Components
- Services
- Resources
- Signals
- Commands
- Save modules
- Telemetry events
- Tests

---

# Step 3 — Folder Structure

Show files to create.

Example

```text
heroes/
components/
services/
resources/
ui/
tests/
```

Do NOT generate everything inside one file.

---

# Step 4 — Scene Structure

If scenes are required,

show hierarchy.

Example

```text
Hero
├── Sprite
├── Shadow
├── HealthBar
├── Components
│   ├── Combat
│   ├── Movement
│   ├── AI
│   └── Inventory
```

---

# Step 5 — Data Model

Separate

Static

```text
HeroData
```

Runtime

```text
HeroRuntimeState
```

Save

```text
HeroSaveData
```

Never mix them.

---

# Step 6 — Gameplay Flow

Show sequence.

Example

```text
Quest Accepted

↓

Hero Walks

↓

Monster Fight

↓

Loot

↓

Return Town

↓

Sell

↓

Repair

↓

Rest
```

---

# Step 7 — Implementation

Write production-ready code.

Rules:

- Typed GDScript
- Small classes
- Components
- Services
- Resources
- No magic numbers
- No duplicated logic
- No God Objects

---

# Step 8 — UI

If UI exists

show:

- HUD
- Panels
- Notifications
- Commands
- ViewModels

UI never changes gameplay directly.

---

# Step 9 — Save

Describe:

Saved

```text
IDs

Stats

Progress

Inventory
```

Not Saved

```text
Nodes

Animation

Navigation

UI

Signals
```

---

# Step 10 — Telemetry

Generate events.

Example

```text
feature_started

feature_completed

reward_claimed

error

cancelled
```

---

# Step 11 — Debug Tools

Generate:

```text
Inspector

Debug commands

Visualization

Simulation command
```

---

# Step 12 — Tests

Always generate

Unit Tests

Integration Tests

Simulation Tests

Regression Tests

Stress Tests if required

---

# Step 13 — Documentation

Generate:

- Architecture
- Folder tree
- Data model
- Gameplay flow
- Save model
- Performance notes
- Future extension

---

# Coding Rules

Follow:

- architecture.md
- coding-style.md
- gdscript.md
- performance.md
- scene-structure.md
- signal-rules.md
- ui.md
- save-system.md
- economy.md
- ai.md
- balancing.md
- testing.md
- telemetry.md
- optimize.md
- refactor.md

---

# Agents To Consult

Before implementing, mentally consult:

- Architect
- Gameplay
- AI
- Economy
- Balancing
- UIUX
- PixelArtist
- Animator
- Performance
- QA
- Reviewer

If a decision conflicts,

Architect wins.

---

# Definition of Done

Feature is complete only when:

```text
✓ Architecture clean

✓ Components separated

✓ UI separated

✓ Save supported

✓ Debug tools exist

✓ Telemetry exists

✓ Unit tests written

✓ Integration tests written

✓ Simulation tests written

✓ Regression tests written

✓ Documentation updated

✓ Mobile performance acceptable

✓ Future multiplayer compatible
```

---

# Forbidden

Never:

```text
Gameplay inside UI

God Objects

Saving Nodes

Magic numbers

SceneTree traversal in hot loops

Per-frame allocations

_process AI

Hardcoded IDs

Direct inventory mutation

Direct gold mutation

Untested code

Undocumented feature
```

---

# Final Output Format

Always answer in this order:

1. Feature Summary
2. Architecture
3. Folder Structure
4. Scene Structure
5. Data Models
6. Gameplay Flow
7. Implementation
8. UI
9. Save System
10. Telemetry
11. Debug Tools
12. Tests
13. Performance Notes
14. Risks
15. Future Extensions