---
name: Build Boss
description: Generate a complete Boss and World Boss system including phases, AI, combat, rewards, events, telemetry, debug tools, and tests.
---

# Skill: Build Boss

## Goal

Build a complete boss system.

Bosses are not big monsters with more HP.

Bosses are major world events with:

- Unique mechanics
- Phases
- Minions
- Rewards
- Participation
- Telemetry
- Progression impact

---

# Boss Philosophy

A boss must create a memorable moment.

Every boss should require:

- Preparation
- Strong heroes
- Proper equipment
- Potion supply
- Tactical AI
- Town economy support

Boss fights should affect the world.

---

# Responsibilities

This skill generates:

- Boss architecture
- Boss scene
- Boss data
- Boss AI
- Phase system
- Skill system
- Minion system
- Boss event flow
- Reward system
- Contribution system
- Save logic
- Telemetry
- UI
- Debug tools
- Tests
- Documentation

Never generate only `Boss.gd`.

---

# Scene Structure

```text
Boss.tscn

BossRoot : CharacterBody2D
├── NavigationAgent2D
├── CollisionShape2D
├── AnimatedSprite2D
├── Shadow
├── BossHealthBarAnchor
├── AggroArea
├── AttackArea
├── SkillArea
├── MinionSpawnPoints
├── PhaseController
├── AnimationPlayer
├── LootAnchor
├── VFXAnchor
├── DebugLabel
└── Components
    ├── BossBrain
    ├── BossPhaseComponent
    ├── BossCombatComponent
    ├── BossSkillComponent
    ├── BossAggroComponent
    ├── BossMinionComponent
    ├── BossRewardComponent
    ├── BossTelemetryComponent
    └── BossSaveComponent
```

---

# Folder Structure

```text
bosses/
├── Boss.tscn
├── Boss.gd
├── BossData.gd
├── BossRuntimeState.gd
├── BossSaveData.gd
├── BossPhaseData.gd
├── BossSkillData.gd
├── BossRewardData.gd
├── components/
│   ├── BossBrain.gd
│   ├── BossPhaseComponent.gd
│   ├── BossCombatComponent.gd
│   ├── BossSkillComponent.gd
│   ├── BossAggroComponent.gd
│   ├── BossMinionComponent.gd
│   ├── BossRewardComponent.gd
│   └── BossTelemetryComponent.gd
├── ai/
│   ├── BossDecisionContext.gd
│   ├── BossGoalEvaluator.gd
│   ├── states/
│   │   ├── BossIdleState.gd
│   │   ├── BossIntroState.gd
│   │   ├── BossCombatState.gd
│   │   ├── BossPhaseTransitionState.gd
│   │   ├── BossSummonState.gd
│   │   ├── BossEnrageState.gd
│   │   ├── BossDeadState.gd
│   │   └── BossDespawnState.gd
├── events/
│   ├── BossEvent.gd
│   ├── WorldBossEvent.gd
│   ├── BossSpawnScheduler.gd
│   └── BossContributionTracker.gd
├── ui/
│   ├── BossBar.tscn
│   ├── BossPanel.tscn
│   ├── BossRewardPopup.tscn
│   └── BossWarningBanner.tscn
└── tests/
    ├── test_boss_phase.gd
    ├── test_boss_ai.gd
    ├── test_boss_rewards.gd
    ├── test_boss_event.gd
    └── test_boss_simulation.gd
```

---

# Boss Types

Supported types:

```text
MiniBoss
RegionBoss
DungeonBoss
WorldBoss
EventBoss
GuildBoss
RaidBoss
StoryBoss
```

---

# BossData

Static configuration:

```text
id
display_name
boss_type
region_id
zone_id
level
difficulty
base_stats
phase_list
skill_list
minion_pool
reward_table_id
spawn_rule_id
respawn_time
arena_id
danger_rating
sprite_set
music_id
intro_text
```

No runtime state inside BossData.

---

# BossRuntimeState

Runtime data:

```text
current_hp
current_mp
current_phase
current_state
current_target
aggro_table
participants
damage_contribution
healing_contribution
minions_alive
enrage_active
spawn_time
despawn_time
event_id
```

---

# Boss Is Event

Every World Boss should be represented as an event.

Flow:

```text
Announcement
↓
Preparation Time
↓
Boss Spawn
↓
Active Fight
↓
Victory / Failure
↓
Reward Distribution
↓
Cooldown
```

---

# Phase System

Boss must support phases.

Examples:

```text
Phase 1: Normal attacks
Phase 2: Summon minions
Phase 3: Area damage
Phase 4: Enrage
```

Phases are data-driven.

---

# Phase Triggers

Allowed triggers:

```text
HP threshold
Time elapsed
Minion count
Event progress
Hero count
Damage taken
Weather
Special condition
```

---

# Phase Rules

Each phase can modify:

```text
skills
stats
speed
aggro
minions
arena hazards
loot bonus
music
visuals
```

Avoid HP-only phase changes.

---

# Skill System

Boss skills must be data-driven.

Skill selection based on:

```text
cooldown
range
target count
phase
danger
aggro
hero positioning
```

Never hardcode skills inside `Boss.gd`.

---

# Boss Mechanics

Recommended mechanics:

```text
AoE warning
Summon minions
Charge attack
Poison zone
Shield phase
Healing phase
Enrage timer
Target mark
Knockback
Split phase
Weak point
```

Mechanics should be readable.

---

# Aggro

Boss uses aggro table.

Aggro sources:

```text
damage_dealt
healing_done
taunt
proximity
special mechanics
```

Avoid random target switching.

---

# Minions

Boss can summon minions.

Minions should:

```text
Protect boss
Attack healers
Block path
Explode
Heal boss
Carry loot
```

Minions are spawned by BossMinionComponent.

---

# Boss Arena

Boss arena includes:

```text
Entrance
Exit
Safe Zone
Hazard Areas
Minion Spawn Points
Boss Spawn Point
NavigationRegion2D
Camera Bounds
```

Never hardcode coordinates.

---

# Participation

Track contribution:

```text
damage
healing
tank time
minions killed
buffs applied
revives
survival time
```

Rewards can scale by contribution.

---

# Reward Rules

Rewards should include:

```text
Gold
EXP
Rare Materials
Boss Token
Unique Equipment
Recipe
Cosmetic
Title
Town Reputation
```

Avoid gold-only rewards.

---

# Reward Distribution

Reward once only.

Prevent:

```text
duplicate reward
rejoin exploit
save/load exploit
offline exploit
```

---

# Failure

Boss event may fail.

Failure consequences:

```text
Boss escapes
Town morale decreases
Merchant prices rise
Boss returns stronger
Region danger increases
```

Failure should create story, not only punishment.

---

# Spawn Rules

Boss spawns by:

```text
Schedule
Event
Quest
Region progress
Player action
World condition
```

---

# Despawn Rules

Boss despawns when:

```text
event ends
timeout
boss escapes
all participants dead
region resets
```

---

# Save Rules

Save:

```text
boss_id
boss_data_id
current_hp
current_phase
participants
contribution
event_state
spawn_time
despawn_time
reward_claimed
```

Never save:

```text
Node
AnimationPlayer
NavigationAgent2D
Signal
Timer
Path
```

---

# UI

Boss UI includes:

```text
Boss health bar
Phase indicator
Timer
Participants
Contribution
Warning banner
Reward preview
Event status
```

UI listens to state.

UI never modifies boss directly.

---

# Telemetry

Track:

```text
boss_spawned
boss_phase_changed
boss_skill_cast
boss_minion_spawned
boss_defeated
boss_failed
fight_duration
participant_count
damage_contribution
death_count
reward_claimed
```

---

# Debug Tools

Boss inspector shows:

```text
id
boss_data_id
type
state
phase
hp
target
aggro_table
participants
contribution
active_skills
cooldowns
minions_alive
event_state
timer
decision_reason
```

Debug commands:

```text
spawn_boss
kill_boss
start_world_boss
end_world_boss
force_phase
set_boss_hp
spawn_minions
clear_minions
show_aggro_table
show_contribution
claim_rewards
reset_boss_event
```

---

# Required Tests

Generate tests for:

```text
phase transition
skill selection
aggro table
minion spawn
reward distribution
duplicate reward prevention
event start/end
save/load
failure
telemetry
```

---

# Required Test Cases

```text
GivenBossHpBelowThreshold_WhenPhaseComponentTicks_ThenBossChangesPhase

GivenBossDefeated_WhenRewardsDistributed_ThenEachParticipantReceivesRewardOnce

GivenRewardAlreadyClaimed_WhenPlayerClaimsAgain_ThenClaimIsRejected

GivenWorldBossEventStarted_WhenPreparationEnds_ThenBossSpawns

GivenBossTimeout_WhenNotDefeated_ThenBossEscapesAndEventFails

GivenBossSaveLoad_WhenBossInPhaseTwo_ThenPhaseAndHpRestored

GivenHealerContributesHealing_WhenBossDefeated_ThenHealerReceivesContributionCredit
```

---

# Performance

Target:

```text
1 World Boss
200 Heroes
1000 Monsters nearby
60 FPS
```

Rules:

```text
No per-frame heavy AI
No per-frame contribution recalculation
No unbounded aggro table growth
No repeated scene tree searches
No mass minion spawn in one frame
```

Use scheduler and batching.

---

# Documentation Output

Always include:

1. Boss overview
2. Folder structure
3. Scene hierarchy
4. Data model
5. Phase system
6. Skill system
7. Aggro system
8. Minion system
9. Reward system
10. Event flow
11. Save model
12. UI
13. Telemetry
14. Debug tools
15. Tests
16. Performance notes

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

When building boss systems:

- Never make boss a simple high-HP monster.
- Always include phases.
- Always include mechanics.
- Always include event flow.
- Always prevent duplicate rewards.
- Always track contribution.
- Always support save/load.
- Always support debug inspection.
- Always support simulation testing.
- Keep all boss data configurable.