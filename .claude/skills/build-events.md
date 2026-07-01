---
name: Build Events
description: Generate a complete world event system including scheduling, weather, festivals, boss events, merchant events, town attacks, rewards, telemetry, debug tools, save/load, and tests.
---

# Skill: Build Events

## Goal

Build a complete event system for a living-world idle RPG.

Events make the world feel alive.

Events should create temporary changes, stories, risks, rewards, and reasons for heroes to react.

---

# Event Philosophy

Events are not just popups.

Events must affect:

- World
- Town
- Heroes
- NPCs
- Monsters
- Economy
- Weather
- Combat
- Buildings
- Rewards

The player should notice an event without opening a menu.

---

# Responsibilities

This skill generates:

- Event architecture
- Event manager
- Scheduler
- Event lifecycle
- Event data
- Event state
- Rewards
- UI
- AI reactions
- Save/load
- Telemetry
- Debug tools
- Tests
- Documentation

Never generate only `EventManager.gd`.

---

# Folder Structure

```text
events/
├── EventManager.gd
├── EventScheduler.gd
├── EventRegistry.gd
├── EventData.gd
├── EventRuntimeState.gd
├── EventSaveData.gd
├── EventRewardData.gd
├── EventConditionData.gd
├── EventModifierData.gd
├── lifecycle/
│   ├── EventLifecycle.gd
│   ├── EventPhase.gd
│   ├── EventStartHandler.gd
│   ├── EventEndHandler.gd
│   └── EventCleanupHandler.gd
├── types/
│   ├── WeatherEvent.gd
│   ├── FestivalEvent.gd
│   ├── MerchantEvent.gd
│   ├── TownAttackEvent.gd
│   ├── WorldBossEvent.gd
│   ├── EconomyEvent.gd
│   ├── MonsterFrenzyEvent.gd
│   └── DisasterEvent.gd
├── rewards/
│   ├── EventRewardService.gd
│   ├── EventContributionTracker.gd
│   └── EventRewardClaim.gd
├── ui/
│   ├── EventBanner.tscn
│   ├── EventPanel.tscn
│   ├── EventRewardPopup.tscn
│   └── EventCountdownBadge.tscn
├── debug/
│   ├── EventInspector.tscn
│   └── EventDebugCommands.gd
└── tests/
    ├── test_event_lifecycle.gd
    ├── test_event_scheduler.gd
    ├── test_event_rewards.gd
    ├── test_event_save.gd
    └── test_event_simulation.gd
```

---

# Event Categories

Supported categories:

```text
World
Town
Hero
Guild
Weather
Season
Festival
Combat
Economy
Boss
Merchant
Disaster
Invasion
```

---

# Event Lifecycle

Every event follows this lifecycle:

```text
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
Cleanup
↓
Cooldown
```

Events must have clear start and end.

---

# EventData

Static configuration:

```text
id
display_name
description
category
duration
preparation_time
cooldown
priority
conditions
modifiers
rewards
visual_theme
music_id
notification_text
```

No runtime state inside EventData.

---

# EventRuntimeState

Runtime data:

```text
event_id
phase
start_time
end_time
remaining_time
participants
progress
contribution
reward_claimed
active_modifiers
affected_regions
affected_buildings
affected_entities
```

---

# EventSaveData

Save:

```text
event_id
phase
remaining_time
progress
participants
contribution
reward_claimed
cooldown_remaining
active_modifiers
```

Never save Nodes, Timers, Signals, or UI.

---

# Event Conditions

Events may start based on:

```text
time
season
weather
town_level
region_unlocked
boss_defeated
monster_kill_count
hero_death_count
economy_state
random_weight
manual_debug
```

---

# Event Modifiers

Events may modify:

```text
monster_spawn_rate
elite_spawn_chance
loot_rate
gold_rate
exp_rate
shop_prices
repair_cost
hero_mood
npc_schedule
weather
lighting
music
building_service_speed
```

Modifiers must be temporary and reversible.

---

# Event Overlap Rules

Allowed:

```text
1 major event
2 medium events
many minor events
```

Do not create unreadable event chaos.

EventManager resolves conflicts by priority.

---

# Event Priority

```text
Critical
Major
Medium
Minor
Ambient
```

Critical events can interrupt lower priority events.

---

# AI Reactions

Heroes react to events based on:

```text
level
mood
personality
danger
reward
quest
equipment
relationship
distance
```

Examples:

```text
Festival -> Socialize
World Boss -> Join or Avoid
Town Attack -> Defend or Hide
Merchant -> Shop
Rain -> Prefer Indoor Activities
```

---

# Town Reactions

Town should visually react:

```text
Festival decorations
Merchant stall appears
Raid alarms
NPC panic
Building lights
Weather particles
Boss warning banners
```

---

# Weather Events

Weather affects gameplay.

Examples:

```text
Rain:
- movement speed reduced
- fire damage reduced
- herb growth increased

Storm:
- ranged accuracy reduced
- lightning hazard
- NPCs go indoors

Snow:
- movement speed reduced
- ice monsters spawn
```

Weather is never cosmetic only.

---

# Festival Events

Festival includes:

```text
special decorations
special music
special shop
temporary currency
special quests
mood bonus
relationship bonus
```

Festival ends automatically.

---

# Merchant Events

Merchant event includes:

```text
merchant NPC
limited shop
rare recipes
discount
stock limit
departure time
```

Merchant must leave when event ends.

---

# Town Attack Events

Town attack includes:

```text
enemy waves
defense points
hero participation
building damage
rewards
failure consequence
```

---

# World Boss Events

World Boss event includes:

```text
announcement
preparation
boss spawn
fight timer
contribution tracking
reward distribution
cooldown
```

Use `build-boss.md` for boss implementation.

---

# Economy Events

Economy event may affect:

```text
shop discount
repair discount
craft bonus
tax increase
market festival
double gold
material shortage
```

Economy modifiers must be temporary.

---

# Disaster Events

Disaster should create gameplay, not only punishment.

Examples:

```text
Fire -> repair buildings
Flood -> road blocked
Plague -> church demand
Earthquake -> mine closed
Bandits -> caravan attacked
```

---

# Event Rewards

Rewards may include:

```text
gold
exp
materials
event_currency
recipe
cosmetic
title
building_skin
pet
town_reputation
boss_token
```

Avoid gold-only rewards.

---

# Reward Protection

Prevent:

```text
duplicate reward
save/load exploit
offline exploit
rejoin exploit
claim after expired unless allowed
```

---

# Event Currency

Temporary event currencies should:

```text
expire
convert
or be removed
```

Never accumulate forever unless explicitly designed.

---

# Chain Events

Events may trigger follow-up events.

Example:

```text
Heavy Rain
↓
Flood
↓
Bridge Broken
↓
Merchant Delayed
↓
Potion Price Increase
```

Chain events must be data-driven.

---

# Dynamic Events

Events may respond to player/world state.

Examples:

```text
Too many goblins killed -> Goblin King appears
Too much town wealth -> Bandit Raid
Many hero deaths -> Church Donation Event
Low food -> Harvest Crisis
```

---

# UI

Event UI includes:

```text
Event banner
Countdown
Event panel
Reward preview
Contribution
Event notification
Event log
```

UI listens to event state.

UI never starts events directly except through debug tools.

---

# Signals

Events may emit:

```text
event_scheduled(event_id)
event_announced(event_id)
event_started(event_id)
event_phase_changed(event_id, old_phase, new_phase)
event_progress_changed(event_id, progress)
event_ended(event_id)
event_reward_claimed(event_id, participant_id)
event_cleanup_completed(event_id)
```

Do not emit every frame.

---

# Telemetry

Track:

```text
event_scheduled
event_started
event_ended
event_duration
participants
completion_rate
reward_claimed
failure_rate
currency_earned
currency_spent
event_shop_usage
boss_participation
```

---

# Debug Tools

Event inspector shows:

```text
event_id
category
phase
remaining_time
progress
participants
modifiers
rewards
cooldown
affected_regions
affected_entities
```

Debug commands:

```text
start_event
end_event
force_event_phase
skip_event_time
claim_event_reward
reset_event_cooldown
show_active_events
show_event_modifiers
trigger_festival
trigger_merchant
trigger_town_attack
trigger_world_boss
```

---

# Required Tests

Generate tests for:

```text
event lifecycle
scheduler
conditions
modifiers
reward claim
duplicate reward prevention
save/load
cleanup
event overlap
AI reaction
telemetry
```

---

# Required Test Cases

```text
GivenEventScheduled_WhenPreparationEnds_ThenEventBecomesActive

GivenEventActive_WhenDurationEnds_ThenEventMovesToRewardPhase

GivenEventRewardClaimed_WhenClaimedAgain_ThenSecondClaimRejected

GivenEventModifierApplied_WhenEventEnds_ThenModifierRemoved

GivenSaveLoad_WhenEventActive_ThenRemainingTimeAndProgressRestored

GivenTownAttackStarted_WhenHeroesAvailable_ThenEligibleHeroesJoinDefense

GivenFestivalActive_WhenHeroMoodUpdates_ThenMoodBonusApplied

GivenMerchantEventEnded_WhenCleanupRuns_ThenMerchantNPCRemoved
```

---

# Performance

Target:

```text
Many minor events
1 major event
300 heroes reacting
60 FPS
```

Rules:

```text
No per-frame event polling
No repeated scene tree search
No permanent temporary modifiers
No unbounded participant lists
No UI rebuild every tick
```

Use scheduler and state changes.

---

# Documentation Output

Always include:

1. Event overview
2. Folder structure
3. Event lifecycle
4. Data model
5. Scheduler
6. Modifier system
7. Reward system
8. AI reactions
9. Save model
10. UI
11. Telemetry
12. Debug tools
13. Tests
14. Performance notes

---

# Required Rules

Follow:

- architecture.md
- coding-style.md
- gdscript.md
- scene-structure.md
- signal-rules.md
- performance.md
- save-system.md
- economy.md
- ai.md
- events.md
- world.md
- testing.md
- telemetry.md
- debug-tools.md

Never violate project rules.

---

# AI Instructions

When building event systems:

- Events must affect gameplay, not just show popups.
- Every event must have lifecycle.
- Every modifier must be reversible.
- Every reward must be protected from duplication.
- Save active events correctly.
- Include AI and town reactions.
- Include debug commands.
- Include simulation tests.
- Keep all event data configurable.