---
name: Optimize
description: Analyze, profile, and optimize Herogasm systems without breaking architecture, gameplay correctness, or readability.
---

# Skill: Optimize

## Goal

Optimize performance safely.

This skill is used when a system is:

- Slow
- Laggy
- Memory heavy
- Causing FPS drops
- Creating frame spikes
- Allocating too much
- Scaling poorly
- Failing stress tests

Never optimize blindly.

---

# Optimization Philosophy

Measure first.

Optimize second.

Verify third.

Do not guess.

Do not rewrite working systems without profiling evidence.

---

# Golden Workflow

```text
Reproduce issue
↓
Measure baseline
↓
Identify bottleneck
↓
Choose optimization
↓
Change one thing
↓
Measure again
↓
Compare result
↓
Add regression / performance test
```

---

# Never Do

Never:

```text
Optimize without profiler data
Break architecture for small gains
Remove tests
Hide bugs with caching
Use global state as shortcut
Make gameplay non-deterministic
Move gameplay into UI
Save Nodes
Bypass services
```

---

# Optimization Targets

Target platform:

```text
Android mid-range
60 FPS
45 FPS minimum
Memory <= 512 MB
Autosave < 500 ms
Load < 3 sec
```

---

# Required Inputs

Before optimizing, collect:

```text
System name
Scene name
Entity count
Device
Build version
Average FPS
Minimum FPS
Frame time
Memory
Script time
Physics time
AI tick time
Combat tick time
Navigation tick time
Save/load time
```

---

# Common Bottlenecks

Check first:

```text
Too many _process callbacks
AI thinking every frame
Monster target search every frame
Navigation path recalculated too often
get_tree().get_nodes_in_group() in loops
find_child / find_parent in gameplay
Repeated instantiate()
Repeated load()
UI full rebuild
Inventory sorting every tick
Signals emitted every frame
Too many Timer nodes
Unbounded arrays
Memory leaks
Large save writes
```

---

# Optimization Priority

Optimize in this order:

```text
1. Algorithm
2. Update frequency
3. Scheduling
4. Data structure
5. Caching
6. Object pooling
7. Batching
8. Rendering
9. Micro-optimization
```

Do not start with micro-optimization.

---

# AI Optimization

For Hero / Monster / NPC AI:

Use:

```text
AIScheduler
tick groups
priority queues
sleep mode
distance-based LOD
decision caching
goal cooldowns
```

Avoid:

```text
AI decision every frame
full world scans
constant target switching
path recalculation loops
```

---

# Scheduler Rules

Spread work across frames.

Example:

```text
Frame 1: Heroes 1-30
Frame 2: Heroes 31-60
Frame 3: Heroes 61-90
```

Support:

```text
max_tasks_per_frame
max_time_per_frame_ms
priority
wake conditions
sleeping entities
```

---

# Combat Optimization

Use:

```text
cached targets
collision areas
combat registry
direct calls for hot path
pooled projectiles
pooled damage numbers
batched status ticks
```

Avoid:

```text
search all monsters every attack
signals for every damage tick
instantiating VFX during combat
string formatting in combat loop
```

---

# Navigation Optimization

Use:

```text
NavigationAgent2D
path request queue
destination cache
repath cooldown
stuck detection
alternative route recovery
```

Avoid:

```text
set_target_position every frame
pathfinding for all heroes at once
teleport fallback
repath loops
```

---

# UI Optimization

Use:

```text
ViewModels
dirty flags
virtual lists
pooled list items
event-driven updates
cached formatted strings
```

Avoid:

```text
full panel rebuild
sorting every frame
formatting large numbers every tick
recreating item slots
updating hidden panels
```

---

# Loot Optimization

Use:

```text
LootPool
batch spawn
pickup radius cache
expiration scheduler
rarity-based visual priority
```

Avoid:

```text
thousands of active loot timers
loot _process
instantiating loot during mass combat
```

---

# Save Optimization

Use:

```text
dirty modules
atomic writes
background serialization when safe
compressed modular files
incremental save
```

Avoid:

```text
saving full world every time
saving every small change immediately
serializing Nodes
blocking main thread
```

---

# Memory Optimization

Check:

```text
orphan nodes
unreleased resources
large arrays
duplicate textures
unbounded pools
dangling signal connections
persistent debug objects
```

Use:

```text
object pools
resource reuse
scene cleanup
weak references where needed
```

---

# Rendering Optimization

Use:

```text
visibility culling
reduced animation for offscreen entities
limited particles
pixel-perfect simple shaders
batched tilemaps
LOD for far entities
```

Avoid:

```text
too many lights
too many particles
large transparent overlays
animated offscreen sprites
```

---

# Signal Optimization

Signals are for events.

Do not use signals for hot loops.

Use direct calls for:

```text
combat damage
AI tick
movement tick
status effect tick
```

Use signals for:

```text
death
level up
quest complete
building upgraded
event started
```

---

# Data Structure Optimization

Use ID lookup maps for hot paths.

Good:

```text
heroes_by_id
monsters_by_id
items_by_id
buildings_by_id
```

Avoid repeated linear search in large arrays.

---

# Allocation Rules

Avoid allocations in hot loops.

Do not create:

```text
new Array
new Dictionary
new String
new Callable
new temporary objects
```

inside frequent ticks unless necessary.

Reuse buffers.

---

# Benchmark Requirement

Every optimization must be tested in:

```text
BenchmarkWorld.tscn
```

Minimum scenarios:

```text
100 Heroes / 500 Monsters
300 Heroes / 1000 Monsters
Boss Event active
Festival active
Large inventory
Autosave during gameplay
```

---

# Regression Protection

After optimization, add or update:

```text
performance regression test
simulation test
unit test if logic changed
save/load test if persistence changed
```

---

# Profiling Report

Every optimization output should include:

```text
Before metrics
After metrics
Change made
Risk
Files changed
Test results
Recommendation
```

Example:

```text
Before:
AI tick 7.8 ms

After:
AI tick 2.1 ms

Change:
Split Hero AI into scheduler batches.

Risk:
Delayed reactions for low-priority heroes.

Test:
300 Hero simulation passed.
```

---

# Acceptable Tradeoffs

Allowed:

```text
Slightly delayed AI decisions
Reduced far entity update rate
Less frequent minimap updates
Lower offscreen animation frequency
Batched visual effects
```

Not allowed:

```text
Wrong combat result
Lost save data
Duplicated rewards
Teleporting heroes unexpectedly
Broken AI recovery
Non-deterministic balance
```

---

# Documentation Output

Always include:

1. Problem summary
2. Baseline metrics
3. Bottleneck analysis
4. Optimization plan
5. Implementation steps
6. Risk assessment
7. Tests required
8. Before/after comparison
9. Follow-up recommendations

---

# Required Rules

Follow:

- performance.md
- profiling.md
- stress-test.md
- regression.md
- architecture.md
- gdscript.md
- signal-rules.md
- testing.md
- debug-tools.md
- telemetry.md

Never violate project architecture for short-term performance.

---

# AI Instructions

When optimizing:

- Ask for or collect metrics first.
- Do not guess bottlenecks.
- Change one major thing at a time.
- Keep behavior deterministic.
- Preserve save compatibility.
- Add regression protection.
- Explain tradeoffs.
- Prefer scheduler, batching, pooling, and caching.
- Never sacrifice correctness for FPS.