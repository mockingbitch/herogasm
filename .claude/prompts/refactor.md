---
description: Refactoring prompt for Herogasm.
---

# Refactor Prompt

You are refactoring code in **Herogasm**, a living-world idle RPG inspired by Evil Hunter Tycoon.

Refactor means improving structure without changing gameplay behavior.

Behavior must remain the same unless explicitly requested.

---

# Step 1 — Understand Current Code

Before changing code, summarize:

- Current responsibility
- Current behavior
- Current dependencies
- Current data flow
- Current save impact
- Current performance risk
- Current test coverage

Do not refactor what you do not understand.

---

# Step 2 — Identify Code Smells

Look for:

```text
God Object
Duplicate logic
Long functions
Deep inheritance
Hardcoded values
UI/gameplay coupling
SceneTree traversal
Save logic in entities
AI inside _process
Combat inside animation
Magic numbers
Untyped GDScript
```

---

# Step 3 — Refactor Goal

Clearly state the goal.

Examples:

```text
Extract CombatComponent from Hero.gd

Move upgrade costs into BuildingData

Replace direct UI mutation with Command

Move save logic into SaveModule

Split long AI decision chain into Utility Goals
```

---

# Step 4 — Safety Rules

Preserve:

```text
Gameplay behavior
Save compatibility
Telemetry events
Debug tools
Tests
Performance budget
Public APIs where needed
```

Never change balance numbers accidentally.

---

# Step 5 — Refactor Plan

Refactor in small steps:

```text
Add tests
Extract data
Extract methods
Extract components
Replace direct calls
Update references
Run tests
Document
```

Avoid full rewrites.

---

# Step 6 — Architecture Target

Prefer:

```text
Component
Service
Resource
Command
ViewModel
SaveModule
Scheduler
ObjectPool
```

Avoid:

```text
Singleton abuse
God Object
Deep NodePath
Circular dependency
Duplicate manager
```

---

# Step 7 — Save Compatibility

If saved data changes:

```text
Add migration
Increment save version
Add save/load regression test
Validate old saves
Document migration
```

Never silently break old saves.

---

# Step 8 — Performance Check

Ensure refactor does not introduce:

```text
_process AI
Per-frame allocations
Repeated get_node
SceneTree scans
Repeated load
New Timer per entity
Full UI rebuild
```

---

# Step 9 — Tests

Before and after refactor:

```text
Unit tests
Regression tests
Save/load tests
Simulation tests if AI/world affected
Performance tests if hot path affected
```

---

# Step 10 — Documentation

Update:

```text
Architecture notes
Folder structure
Data model
Save model
Debug commands
Tests
Migration notes
```

---

# Required Output Format

Always answer:

1. Current Problem
2. Refactor Goal
3. Behavior To Preserve
4. Refactor Plan
5. New Architecture
6. Files Changed
7. Code Changes
8. Tests
9. Save Compatibility
10. Performance Notes
11. Risks
12. Verification Checklist

---

# Definition of Done

Refactor is complete only when:

```text
✓ Behavior preserved
✓ Tests pass
✓ No architecture violation
✓ No save break
✓ No performance regression
✓ No duplicated logic
✓ Documentation updated
✓ Regression coverage exists
```

---

# Forbidden

Never:

```text
Rewrite everything without reason
Change gameplay balance silently
Delete tests
Break save files
Move gameplay into UI
Introduce global state
Add hardcoded values
Optimize and refactor at the same time unless requested
```

---

# Required Rules

Follow:

- refactor.md
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
- debug-tools.md