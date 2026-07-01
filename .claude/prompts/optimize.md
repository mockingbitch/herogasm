---
description: Optimization prompt for Herogasm.
---

# Optimize Prompt

You are optimizing **Herogasm**, a living-world idle RPG inspired by Evil Hunter Tycoon.

Do not optimize by guessing.

Measure first.

Optimize only after identifying the bottleneck.

---

# Step 1 — Problem Summary

Summarize:

- What is slow
- Where it happens
- Device / platform
- Scene / feature
- Entity counts
- Current FPS
- Target FPS
- Memory usage
- Reproduction steps

---

# Step 2 — Baseline Metrics

Collect or request:

```text
FPS avg
FPS min
Frame time
Script time
Physics time
Rendering time
AI tick
Combat tick
Navigation tick
UI update time
Memory
Node count
Draw calls
Pool usage
Save/load time
```

Never optimize without baseline metrics.

---

# Step 3 — Bottleneck Analysis

Classify the bottleneck:

```text
AI
Combat
Navigation
Rendering
UI
Save/Load
Memory
Signals
SceneTree
Object Pool
Telemetry
```

Explain why this is likely the bottleneck.

---

# Step 4 — Optimization Plan

Propose changes in priority order:

```text
Algorithm
Update frequency
Scheduler
Caching
Pooling
Batching
Data structure
Rendering
Micro-optimization
```

Do not rewrite everything.

Change one major thing at a time.

---

# Step 5 — Implementation Rules

Optimization must not:

```text
Change gameplay behavior
Break save compatibility
Break determinism
Remove tests
Bypass architecture
Move gameplay into UI
Hide bugs
```

---

# Step 6 — Hot Path Rules

Never introduce:

```text
_process AI
Per-frame allocations
SceneTree traversal in hot loops
Repeated instantiate()
Repeated load()
Path recalculation every frame
Signal spam
Full UI rebuild
```

---

# Step 7 — Preferred Fixes

Prefer:

```text
AI Scheduler
Tick budgets
Sleep mode
Object pooling
Dirty flags
Spatial partitioning
Cached lookups
Virtual lists
Batch spawn
Incremental save
LOD
```

---

# Step 8 — Measurement After Change

After each optimization, compare:

```text
Before
After
Difference
Risk
Side effects
```

Example:

```text
Before:
AI tick 8.4 ms

After:
AI tick 2.6 ms

Improvement:
-69%

Risk:
Low-priority heroes react slower.
```

---

# Step 9 — Regression Protection

Add or update:

```text
Performance regression test
Simulation test
Stress test
Unit test if logic changed
Save/load test if persistence changed
```

---

# Step 10 — Documentation

Document:

- Bottleneck
- Fix
- Metrics
- Tradeoffs
- New limits
- Follow-up tasks

---

# Required Output Format

Always answer:

1. Problem Summary
2. Baseline Metrics
3. Bottleneck Analysis
4. Optimization Plan
5. Code Changes
6. Before / After Metrics
7. Tests
8. Regression Protection
9. Risks / Tradeoffs
10. Follow-up Recommendations

---

# Definition of Done

Optimization is complete only when:

```text
✓ Baseline measured
✓ Bottleneck identified
✓ One major optimization applied
✓ Metrics improved
✓ Behavior unchanged
✓ Save compatibility preserved
✓ Tests pass
✓ Regression protection added
✓ Documentation updated
```

---

# Forbidden

Never:

```text
Optimize blindly
Rewrite whole system without profiling
Sacrifice correctness for FPS
Silently change balance
Delete tests
Hide errors
Add global hacks
Break save compatibility
```

---

# Required Rules

Follow:

- optimize.md
- performance.md
- profiling.md
- stress-test.md
- regression.md
- simulation.md
- architecture.md
- gdscript.md
- testing.md
- debug-tools.md
- telemetry.md