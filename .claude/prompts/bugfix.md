---
description: Bug fixing prompt for Herogasm.
---

# Bug Fix Prompt

You are fixing a bug in **Herogasm**, a living-world idle RPG inspired by Evil Hunter Tycoon.

Fix the root cause.

Do not hide symptoms.

Every bug fix must add regression protection.

---

# Step 1 — Bug Summary

Summarize:

- Bug title
- Affected system
- Expected behavior
- Actual behavior
- Severity
- Reproduction steps
- Suspected impact

---

# Step 2 — Reproduce First

Before fixing:

```text
Reproduce bug
↓
Create failing test
↓
Confirm test fails
↓
Fix bug
↓
Confirm test passes
```

Never fix serious bugs without a regression test.

---

# Step 3 — Root Cause Analysis

Identify:

- Where bug happens
- Why it happens
- Why tests missed it
- Whether save data is affected
- Whether economy is affected
- Whether performance is affected

Do not patch randomly.

---

# Step 4 — Scope Check

Check if bug affects:

```text
AI
Combat
Loot
Economy
Inventory
Quest
Save
Events
UI
Navigation
Performance
Telemetry
```

---

# Step 5 — Fix Rules

The fix must:

- Preserve architecture
- Preserve save compatibility
- Preserve deterministic behavior
- Avoid new global state
- Avoid hardcoded values
- Avoid UI/gameplay coupling
- Avoid performance regression

---

# Step 6 — Regression Test

Add a permanent regression test.

Test name format:

```text
GivenCondition_WhenAction_ThenExpectedResult
```

Example:

```text
GivenMonsterDiesBeforeHeroAttack_WhenCombatTicks_ThenHeroClearsTarget
```

---

# Step 7 — Save Compatibility

If save data is affected:

- Add migration if required
- Validate old saves
- Add save/load regression test
- Prevent corrupted state from loading

Never silently break saves.

---

# Step 8 — Economy Safety

If bug affects rewards, gold, items, crafting, market, or loot:

Verify:

```text
No duplication
No negative currency
No free reward
No infinite sell loop
No overflow
```

---

# Step 9 — AI Safety

If bug affects AI:

Verify:

```text
No idle forever
No loop between goals
No stuck state
No invalid target
No path retry spam
Recovery exists
```

---

# Step 10 — Performance Safety

If fix touches hot path:

Measure:

```text
AI tick
Combat tick
Navigation tick
Memory
Allocations
Frame time
```

No fix should introduce per-frame expensive logic.

---

# Step 11 — Telemetry

If bug is important, add telemetry:

```text
bug_detected
invalid_state_recovered
duplicate_claim_rejected
path_failure_recovered
save_recovered
```

---

# Step 12 — Debug Support

Add or improve debug tools if needed:

```text
Inspector field
Debug command
Validation warning
Log category
Replay marker
```

---

# Step 13 — Documentation

Document:

- Root cause
- Fix approach
- Regression test added
- Risk
- Follow-up actions

---

# Required Output Format

Always answer:

1. Bug Summary
2. Reproduction
3. Root Cause
4. Affected Systems
5. Fix Plan
6. Code Changes
7. Regression Tests
8. Save/Economy/AI Safety
9. Performance Notes
10. Telemetry / Debug Updates
11. Risks
12. Verification Checklist

---

# Definition of Done

A bug fix is complete only when:

```text
✓ Bug reproduced
✓ Failing regression test added
✓ Root cause fixed
✓ Test passes
✓ No architecture violation
✓ Save compatibility checked
✓ Economy safety checked
✓ AI safety checked
✓ Performance checked
✓ Telemetry/debug added if useful
✓ Documentation updated
```

---

# Forbidden

Never:

```text
Fix without reproduction
Patch symptoms only
Delete failing tests
Ignore save impact
Ignore economy exploits
Add hardcoded workaround
Move gameplay into UI
Silence errors without recovery
Skip regression test for serious bugs
```

---

# Required Rules

Follow:

- regression.md
- testing.md
- unit-testing.md
- simulation.md
- save-system.md
- economy.md
- ai.md
- performance.md
- telemetry.md
- debug-tools.md
- architecture.md
- gdscript.md