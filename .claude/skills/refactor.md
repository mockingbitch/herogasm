---
name: Refactor
description: Safely improve code structure, readability, architecture, and maintainability without changing gameplay behavior.
---

# Skill: Refactor

## Goal

Improve code quality without changing player-facing behavior.

Refactor when code is:

- Too large
- Duplicated
- Hard to test
- Hard to extend
- Too coupled
- Violating architecture rules
- Mixing UI with gameplay
- Mixing data with runtime state

---

# Refactor Philosophy

Behavior must remain the same.

Structure improves.

Tests protect behavior.

Never refactor blindly.

---

# Golden Workflow

```text
Understand current behavior
↓
Add or verify tests
↓
Identify code smell
↓
Refactor in small steps
↓
Run tests
↓
Run simulation if gameplay changed
↓
Document changes
```

---

# Never Do

Never:

```text
Change gameplay balance accidentally
Delete regression tests
Break save compatibility
Move gameplay into UI
Serialize Nodes
Introduce global state
Hardcode values
Rewrite entire systems without reason
Optimize during refactor unless requested
```

---

# Refactor Targets

Refactor when you see:

```text
God Object
Large function
Duplicate logic
Deep inheritance
Deep scene dependency
Hardcoded values
Long if/else state chains
SceneTree traversal in gameplay
UI mutating gameplay directly
Save logic inside entity
Combat logic inside animation
AI thinking inside _process
```

---

# God Object Refactor

Bad:

```text
Hero.gd handles:
movement
combat
inventory
AI
quest
save
UI
animation
```

Good:

```text
Hero.gd coordinates:
MovementComponent
CombatComponent
InventoryComponent
EquipmentComponent
HeroBrain
QuestComponent
SaveComponent
```

---

# Component Extraction

Extract when one script has multiple responsibilities.

Examples:

```text
HealthComponent
MovementComponent
CombatComponent
InventoryComponent
EquipmentComponent
NeedsComponent
MoodComponent
RelationshipComponent
SaveComponent
TelemetryComponent
```

---

# Data Extraction

Move configuration into Resources.

Bad:

```text
var attack = 25
var move_speed = 90
var drop_rate = 0.12
```

Good:

```text
HeroData
MonsterData
SkillData
LootTableData
BuildingData
```

---

# State Machine Refactor

Replace long state chains.

Bad:

```text
if state == "idle":
elif state == "walk":
elif state == "combat":
elif state == "dead":
```

Good:

```text
StateMachine
HeroIdleState
HeroTravelState
HeroCombatState
HeroDeadState
```

---

# UI Refactor

UI must not modify gameplay directly.

Bad:

```text
gold -= cost
building.level += 1
```

Good:

```text
UpgradeBuildingCommand
↓
GameService
↓
BuildingService
↓
State Changed
↓
UI Updates
```

---

# Save Refactor

Save only data.

Move save logic into Save Modules.

Bad:

```text
Hero.gd writes save file
```

Good:

```text
HeroSaveModule serializes HeroSaveData
```

---

# Signal Refactor

Use signals for events, not hot loops.

Bad:

```text
damage_tick.emit() every frame
```

Good:

```text
damage_applied(result)
entity_died(entity, killer)
```

---

# Performance-Safe Refactor

Do not add:

```text
extra _process
extra Timer per entity
extra SceneTree search
extra allocations in tick
```

Refactor must not make performance worse.

---

# Save Compatibility

If refactor changes saved data:

```text
add migration
update SaveVersion
add regression test
validate old save
```

Never break existing saves silently.

---

# Tests Required

Before refactor:

```text
unit tests
regression tests
save/load tests
simulation tests if AI/world affected
```

After refactor:

```text
all tests pass
behavior unchanged
performance not worse
```

---

# Refactor Report

Always output:

```text
What changed
What did not change
Why refactor was needed
Risks
Tests added/updated
Migration required?
Performance impact
Follow-up suggestions
```

---

# Safe Refactor Types

Allowed:

```text
Extract method
Extract class
Extract component
Rename for clarity
Move data to Resource
Replace duplicate logic with service
Introduce interface
Introduce command
Introduce ViewModel
Introduce scheduler
```

---

# Risky Refactor Types

Require extra caution:

```text
Save data structure change
Combat formula change
AI goal scoring change
Economy transaction change
Inventory ownership change
Quest progress change
Navigation flow change
Event lifecycle change
```

---

# Documentation Output

Always include:

1. Current problem
2. Refactor goal
3. Files affected
4. New structure
5. Behavior preserved
6. Tests required
7. Migration notes
8. Risks
9. Follow-up cleanup

---

# Required Rules

Follow:

- architecture.md
- coding-style.md
- gdscript.md
- scene-structure.md
- signal-rules.md
- save-system.md
- performance.md
- testing.md
- regression.md
- telemetry.md

---

# AI Instructions

When refactoring:

- Preserve behavior.
- Refactor in small steps.
- Keep tests passing.
- Extract responsibilities.
- Prefer composition over inheritance.
- Keep save compatibility.
- Do not mix optimization unless requested.
- Do not rewrite whole systems unnecessarily.
- Explain risks clearly.