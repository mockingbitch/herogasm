---
name: Build AI
description: Generate a complete autonomous AI system for Herogasm including Hero AI, Monster AI, Goal System, Utility AI, Scheduler, debug tools, simulation tests, and telemetry.
---

# Skill: Build AI

## Goal

Build the complete AI foundation for a living-world idle RPG.

AI is the core gameplay.

Heroes, monsters, NPCs, bosses, buildings, and world events should behave autonomously.

The player influences the world.

The player does not directly control heroes.

---

# AI Philosophy

AI should make the world feel alive.

Every entity should have:

- Purpose
- State
- Goal
- Reason
- Memory
- Reaction
- Recovery

AI must be understandable, inspectable, and testable.

---

# Responsibilities

This skill generates:

- AI architecture
- Hero AI
- Monster AI
- NPC AI
- Goal system
- Utility scoring
- FSM states
- Scheduler
- Decision context
- Memory system
- Needs integration
- Combat integration
- Navigation integration
- Event reaction
- Telemetry
- Debug tools
- Tests
- Simulation framework

Never generate only one `AI.gd`.

---

# Core Architecture

```text
Entity
↓
Brain
↓
Decision Context
↓
Goal Evaluator
↓
Goal
↓
State Machine
↓
Action
↓
Telemetry
```

---

# Folder Structure

```text
ai/
├── core/
│   ├── Brain.gd
│   ├── DecisionContext.gd
│   ├── Goal.gd
│   ├── GoalEvaluator.gd
│   ├── GoalScore.gd
│   ├── StateMachine.gd
│   ├── State.gd
│   ├── Action.gd
│   ├── Blackboard.gd
│   └── Memory.gd
├── scheduler/
│   ├── AIScheduler.gd
│   ├── SchedulerGroup.gd
│   ├── ScheduledTask.gd
│   └── TickBudget.gd
├── utility/
│   ├── UtilityScorer.gd
│   ├── UtilityCurve.gd
│   └── UtilityConsideration.gd
├── hero/
│   ├── HeroBrain.gd
│   ├── HeroDecisionContext.gd
│   ├── HeroGoalEvaluator.gd
│   ├── HeroMemory.gd
│   ├── goals/
│   └── states/
├── monster/
│   ├── MonsterBrain.gd
│   ├── MonsterDecisionContext.gd
│   ├── MonsterGoalEvaluator.gd
│   ├── MonsterMemory.gd
│   ├── goals/
│   └── states/
├── npc/
│   ├── NPCBrain.gd
│   ├── NPCSchedule.gd
│   ├── NPCDecisionContext.gd
│   └── states/
├── debug/
│   ├── AIInspector.tscn
│   ├── AIInspector.gd
│   ├── DecisionDebugger.gd
│   └── AIDebugOverlay.gd
└── tests/
    ├── test_goal_scoring.gd
    ├── test_ai_scheduler.gd
    ├── test_hero_decisions.gd
    ├── test_monster_decisions.gd
    ├── test_ai_memory.gd
    └── test_ai_simulation.gd
```

---

# AI Layers

```text
World AI
Controls weather, events, boss spawn, economy events.

Town AI
Controls building usage, NPC schedules, town activity.

Hero AI
Controls autonomous hero life loop.

Monster AI
Controls hunting zone danger.

Combat AI
Controls targeting, skills, retreat, potion usage.

Animation AI
Visual response only.
```

---

# Brain

Every autonomous entity has a Brain.

Brain owns:

- Current goal
- Current state
- Decision context
- Memory
- Blackboard
- Tick interval
- Last decision reason

Brain does not render.

Brain does not access UI.

---

# Decision Context

DecisionContext gathers information for scoring.

Examples:

```text
current_hp
max_hp
stamina
mood
inventory_full
equipment_broken
nearby_buildings
nearby_monsters
active_quest
current_zone
danger_level
gold
relationship_targets
weather
time_of_day
```

Context is read-only during evaluation.

---

# Goal System

Every entity should have exactly one primary goal.

Examples:

```text
HuntGoal
ReturnTownGoal
RestGoal
RepairGoal
SellLootGoal
BuyPotionGoal
TrainGoal
AcceptQuestGoal
SocializeGoal
SleepGoal
EatGoal
RoamGoal
ChaseTargetGoal
ReturnHomeGoal
```

---

# Utility AI

Goals are selected by score.

Each goal returns:

```text
score
reason
urgency
cost
risk
expected_reward
```

Highest valid score wins.

---

# Goal Score Rules

Score range:

```text
0.0 to 1.0
```

0 means impossible.

1 means urgent.

Never use arbitrary huge numbers.

---

# Hero Decision Priority

```text
Survival
↓
Safety
↓
Maintenance
↓
Quest
↓
Profit
↓
Progression
↓
Relationship
↓
Entertainment
↓
Idle
```

---

# Monster Decision Priority

```text
Survival
↓
Aggro
↓
Attack
↓
Chase
↓
Return Home
↓
Patrol
↓
Roam
↓
Idle
```

---

# NPC Decision Priority

```text
Schedule
↓
Work
↓
Service
↓
Social
↓
Event Reaction
↓
Rest
```

---

# State Machine

AI uses FSM for execution.

Goal decides what to do.

State performs it.

Examples:

```text
Goal: Repair Weapon
States:
TravelToBlacksmith
QueueAtBlacksmith
RepairEquipment
LeaveBuilding
```

---

# State Rules

States must be:

- Small
- Testable
- Interruptible
- Recoverable

State should expose:

```text
enter()
tick(delta)
exit()
can_interrupt()
get_debug_info()
```

---

# Actions

Actions are atomic.

Examples:

```text
MoveTo
AttackTarget
UsePotion
EnterBuilding
BuyItem
RepairItem
SellLoot
Sleep
Eat
```

Actions should be reusable.

---

# Scheduler

AI must never think every frame.

Use centralized scheduler.

Recommended tick rates:

```text
Hero high priority: 100~250 ms
Hero normal: 500~1000 ms
Hero far away: 2~5 sec

Monster combat: 100~250 ms
Monster roam: 1~3 sec

NPC schedule: 5~30 sec

Needs: 1~5 sec
Relationship: 10~60 sec
Economy: 30~120 sec
```

---

# Scheduler Budget

Scheduler must support:

```text
max_tasks_per_frame
max_time_per_frame_ms
priority_queue
entity_groups
sleeping_entities
wake_conditions
```

---

# AI Sleep Mode

Entities far from active regions may enter low-frequency mode.

Sleep mode still simulates:

- Need decay
- Long travel
- Offline behavior
- Event reactions

But at reduced frequency.

---

# Interrupts

AI may interrupt current goal when:

```text
HP critical
Target dead
Path failed
Inventory full
Equipment broken
Town attack
Boss spawned
Event ended
```

---

# Recovery

Every AI failure must have recovery.

Examples:

```text
Path failed -> choose alternative destination
Target invalid -> clear target and rescore goals
Building closed -> find another service
Inventory full -> return town
Combat stuck -> reset combat state
```

---

# Memory

AI Memory stores:

```text
dangerous_zones
favorite_buildings
recent_targets
recent_failures
friends
rivals
last_rest_time
last_repair_time
rare_loot_seen
boss_encounters
```

Memory affects future decisions.

---

# Blackboard

Blackboard stores short-term data.

Examples:

```text
target_id
destination_id
reserved_service_id
current_path_id
last_decision_time
failed_attempts
```

Blackboard is runtime-only.

Do not save temporary blackboard unless required.

---

# Needs Integration

Needs influence goals.

Examples:

```text
Low HP -> Rest / Potion / Retreat
Low stamina -> Rest / Eat / Sleep
Low mood -> Socialize / Tavern / Festival
Broken equipment -> Repair
Inventory full -> Sell / Store / ReturnTown
```

---

# Navigation Integration

AI requests movement through MovementComponent.

Never calculate path inside Brain.

Correct:

```text
Brain -> MovementComponent.move_to(destination)
```

Wrong:

```text
Brain directly manipulates NavigationAgent2D
```

---

# Combat Integration

AI requests combat through CombatComponent.

Correct:

```text
Brain -> CombatComponent.attack(target)
```

Wrong:

```text
Brain changes target HP directly
```

---

# Building Integration

AI discovers services through ServiceRegistry.

Examples:

```text
Find nearest Inn
Find available Blacksmith
Find Guild with quest
Find Market with potion
```

Never hardcode building node paths.

---

# Event Reaction

AI reacts to events.

Examples:

```text
Festival -> social / tavern / market
Town Attack -> defend / hide / flee
Boss Spawn -> join / avoid
Rain -> prefer indoor activities
Night -> sleep / dangerous monsters
```

---

# Personality

Personality modifies scoring.

Examples:

```text
Brave increases dangerous quest score.
Coward increases retreat score.
Greedy increases loot priority.
Lazy increases rest score.
Friendly increases social score.
Explorer increases distant zone score.
```

---

# Determinism

AI decisions must be reproducible with seeded RandomService.

Never use unseeded randomness.

---

# Signals

AI may emit:

```text
goal_changed(entity, old_goal, new_goal)
state_changed(entity, old_state, new_state)
decision_failed(entity, reason)
ai_stuck(entity)
```

Do not emit every tick.

---

# Telemetry

Track:

```text
goal_selected
goal_completed
goal_failed
state_changed
decision_time
decision_score
interrupt
recovery
path_failure
idle_duration
stuck_detected
```

---

# Debug Inspector

AI Inspector shows:

```text
entity_id
brain_type
current_goal
current_state
decision_scores
selected_reason
needs
mood
target
destination
blackboard
memory
scheduler_group
last_tick_time
failure_count
```

---

# Debug Commands

```text
pause_ai
resume_ai
step_ai
force_goal
force_state
clear_goal
show_decision_scores
show_memory
show_blackboard
show_stuck_entities
reset_ai
```

---

# Tests

Generate tests for:

```text
goal_scoring
goal_selection
interrupts
recovery
scheduler_budget
sleep_mode
memory
blackboard
hero_decisions
monster_decisions
npc_schedule
event_reaction
```

---

# Required Test Cases

```text
GivenHeroLowHp_WhenAIScoresGoals_ThenRestGoalWins

GivenHeroInventoryFull_WhenAIScoresGoals_ThenReturnTownGoalWins

GivenHeroWeaponBroken_WhenBlacksmithAvailable_ThenRepairGoalWins

GivenMonsterTargetLeavesLeash_WhenAITicks_ThenReturnHomeGoalWins

GivenPathFailed_WhenAIRecovers_ThenAlternativeGoalSelected

GivenFestivalActive_WhenFriendlyHeroScoresGoals_ThenSocialGoalScoreIncreases

GivenSchedulerBudgetExceeded_WhenManyHeroesTick_ThenWorkSpreadsAcrossFrames
```

---

# Performance

Target:

```text
300 Heroes
1000 Monsters
200 NPC
60 FPS
AI within frame budget
```

Rules:

```text
No per-frame AI thinking
No per-frame SceneTree search
No repeated path recalculation
No unbounded loops
No heavy allocations in tick
```

---

# Documentation Output

Always include:

1. AI architecture
2. Folder structure
3. Core classes
4. Goal system
5. State machine
6. Scheduler
7. Decision scoring
8. Memory model
9. Debug tools
10. Telemetry
11. Tests
12. Performance notes

---

# Required Rules

Follow:

- architecture.md
- coding-style.md
- gdscript.md
- scene-structure.md
- signal-rules.md
- performance.md
- ai.md
- world.md
- testing.md
- telemetry.md
- debug-tools.md

Never violate project rules.

---

# AI Instructions

When building AI systems:

- Never make AI think every frame.
- Use scheduler.
- Use goal scoring.
- Use FSM for execution.
- Keep decisions explainable.
- Keep AI data-driven.
- Separate AI from movement, combat, UI, and animation.
- Always include recovery logic.
- Always include debug inspection.
- Always include simulation tests.