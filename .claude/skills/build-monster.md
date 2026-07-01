---
name: Build Monster
description: Generate a complete Monster system for Herogasm including data, AI, combat, spawn, loot, save, telemetry, tests, and debug tools.
---

# Skill: Build Monster

## Goal

Build a complete autonomous Monster system.

Monsters are not static targets.

They roam, guard areas, attack heroes, retreat, respawn, migrate, and participate in world events.

---

# Monster Philosophy

Monsters should make hunting zones feel alive.

Monsters exist to create:

- Danger
- Loot
- Progression
- Events
- Boss buildup
- World identity

Every region should have unique monsters.

---

# Responsibilities

This skill generates:

- Architecture
- Scene
- Scripts
- Resources
- Spawn system
- AI
- Combat integration
- Loot integration
- Respawn logic
- Event integration
- Save rules
- Telemetry
- Tests
- Debug tools
- Documentation

Never generate only `Monster.gd`.

---

# Scene Structure

```text
Monster.tscn

MonsterRoot : CharacterBody2D
├── NavigationAgent2D
├── CollisionShape2D
├── AnimatedSprite2D
├── Shadow
├── HealthBar
├── AggroArea
├── AttackArea
├── TargetDetector
├── LootAnchor
├── AnimationPlayer
├── DebugLabel
└── Components
    ├── MonsterBrain
    ├── MovementComponent
    ├── CombatComponent
    ├── AggroComponent
    ├── LootComponent
    ├── SpawnComponent
    ├── StatusEffectComponent
    └── MonsterTelemetryComponent
```

---

# Folder Structure

```text
monsters/
├── Monster.tscn
├── Monster.gd
├── MonsterData.gd
├── MonsterState.gd
├── MonsterRuntimeState.gd
├── MonsterSaveData.gd
├── MonsterSpawnData.gd
├── MonsterLootData.gd
├── components/
│   ├── MonsterBrain.gd
│   ├── MovementComponent.gd
│   ├── CombatComponent.gd
│   ├── AggroComponent.gd
│   ├── LootComponent.gd
│   ├── SpawnComponent.gd
│   ├── StatusEffectComponent.gd
│   └── MonsterTelemetryComponent.gd
├── ai/
│   ├── MonsterGoal.gd
│   ├── MonsterDecisionContext.gd
│   ├── states/
│   │   ├── MonsterIdleState.gd
│   │   ├── MonsterRoamState.gd
│   │   ├── MonsterPatrolState.gd
│   │   ├── MonsterAggroState.gd
│   │   ├── MonsterChaseState.gd
│   │   ├── MonsterAttackState.gd
│   │   ├── MonsterReturnState.gd
│   │   ├── MonsterDeadState.gd
│   │   └── MonsterRespawnState.gd
│   └── goals/
│       ├── RoamGoal.gd
│       ├── GuardGoal.gd
│       ├── ChaseTargetGoal.gd
│       ├── AttackTargetGoal.gd
│       ├── ReturnSpawnGoal.gd
│       └── FleeGoal.gd
├── spawner/
│   ├── MonsterSpawner.gd
│   ├── SpawnPoint.gd
│   ├── SpawnZone.gd
│   ├── SpawnPool.gd
│   └── RespawnScheduler.gd
├── ui/
│   ├── MonsterHealthBar.tscn
│   └── MonsterDebugPanel.tscn
└── tests/
    ├── test_monster_ai.gd
    ├── test_monster_spawn.gd
    ├── test_monster_loot.gd
    ├── test_monster_combat.gd
    └── test_monster_simulation.gd
```

---

# Core Architecture

```text
Monster
↓
MonsterData
↓
MonsterRuntimeState
↓
Components
↓
MonsterBrain
↓
State / Goal
↓
Combat / Loot / Respawn
```

Monster root coordinates components only.

Monster logic must not be hardcoded inside one giant script.

---

# MonsterData

Static Resource configuration:

```text
id
display_name
monster_type
region_id
zone_id
level
rarity
base_stats
skills
loot_table_id
spawn_group_id
aggro_range
attack_range
move_speed
respawn_time
patrol_radius
danger_rating
sprite_set
sound_set
```

No runtime state inside MonsterData.

---

# MonsterRuntimeState

Runtime data:

```text
current_hp
current_mp
current_state
current_target
spawn_position
home_position
current_zone_id
aggro_list
last_attacker
is_elite
is_boss_minion
status_effects
respawn_remaining
```

---

# Monster Types

Minimum types:

```text
Normal
Elite
Rare
MiniBoss
BossMinion
EventMonster
ResourceGuardian
```

World Bosses should use `build-boss.md`.

---

# Monster Families

Examples:

```text
Slime
Goblin
Wolf
Spider
Skeleton
Orc
Golem
Lizard
Demon
Dragonkin
```

Families should share behavior patterns but use different data.

---

# Stats

Core monster stats:

```text
max_hp
max_mp
attack
magic_attack
defense
magic_defense
attack_speed
move_speed
critical_chance
critical_damage
dodge
accuracy
aggro_range
attack_range
vision_range
danger_rating
```

---

# AI States

Required states:

```text
Idle
Roam
Patrol
Aggro
Chase
Attack
Return
Dead
Respawn
Flee
```

---

# Decision Rules

Monsters update through scheduler.

Never think every frame.

Recommended tick rate:

```text
Normal monster AI: 250~500 ms
Combat decision: 100~250 ms
Roam decision: 1~3 sec
Respawn: scheduler-based
```

---

# Aggro Rules

Monster targets heroes based on:

```text
damage_dealt
distance
threat
healing_done
quest_priority
taunt
last_attacker
```

Avoid constant target switching.

---

# Chase Rules

Monster chases target while:

```text
target is valid
target is alive
target is inside leash range
monster is not dead
path is reachable
```

If target leaves leash range, monster returns home.

---

# Leash Rules

Every monster has a home position.

Monster must return home when:

```text
too far from spawn
target invalid
combat timeout
zone boundary reached
event ended
```

---

# Roaming

Roam within:

```text
spawn point
spawn zone
patrol radius
allowed navigation area
```

Never roam into town safe zones unless event allows it.

---

# Combat

Monster combat is autonomous.

Monster decides:

```text
target
attack
skill
chase
retreat
return
```

Combat result must not depend on animation timing.

---

# Skill Usage

Monster skills are data-driven.

Choose skill based on:

```text
cooldown
range
target count
hp threshold
phase
danger
```

Never hardcode monster skills inside `Monster.gd`.

---

# Death Flow

```text
HP reaches 0
↓
State = Dead
↓
Emit monster_died
↓
Drop loot
↓
Grant EXP
↓
Update quests
↓
Return to pool or schedule respawn
```

---

# Loot

Loot is controlled by `LootComponent`.

Drops depend on:

```text
monster_data
zone
event
player progression
drop table
luck
party contribution
```

Never spawn loot directly from combat logic.

---

# Respawn

Normal monsters respawn.

Respawn should feel natural.

Use:

```text
nest
camp
portal
burrow
spawn point
spawn zone
```

Avoid popping into visible player area.

---

# Spawn System

Spawn system controls:

```text
spawn cap
spawn rate
monster pool
zone population
elite chance
rare chance
event modifiers
respawn delay
```

---

# Spawn Zones

Each hunting zone owns spawn zones.

```text
ForestZone
├── GoblinCampSpawn
├── WolfHillSpawn
├── SlimePondSpawn
└── RareSpawnPoint
```

Never hardcode spawn coordinates.

---

# Population Control

Each zone has:

```text
min_population
max_population
target_population
elite_limit
rare_limit
boss_minion_limit
```

Spawner maintains population gradually.

---

# Event Integration

Events may modify:

```text
spawn rate
monster type
elite chance
loot table
aggression
migration
boss minions
weather effects
```

Examples:

```text
Goblin Invasion
Monster Frenzy
Blood Moon
Dragon Migration
Meteor Corruption
```

---

# Region Identity

Every region should have unique monsters.

Example:

```text
Forest:
Slime, Goblin, Wolf, Spider

Mountain:
Golem, Harpy, Stone Lizard

Swamp:
Poison Slime, Lizardman, Mosquito

Volcano:
Fire Imp, Lava Golem, Drake
```

---

# Save Rules

Save only persistent monsters:

```text
Elite
Rare
Named
Event Monster
Boss Minion if event requires
```

Do not save every normal monster.

Normal monsters respawn from zone data.

---

# MonsterSaveData

Save:

```text
monster_id
monster_data_id
zone_id
current_hp
state
position
spawn_point_id
event_id
status_effects
respawn_remaining
```

Never save:

```text
Node
Sprite
AnimationPlayer
NavigationAgent2D
Path
Signal
Timer
```

---

# Signals

Monster may emit:

```text
monster_spawned(monster)
monster_died(monster, killer)
monster_aggro_started(monster, target)
monster_aggro_lost(monster)
monster_returned_home(monster)
monster_respawned(monster)
monster_loot_dropped(monster, loot)
monster_elite_spawned(monster)
```

Do not emit every frame.

---

# Telemetry

Track:

```text
spawn
death
respawn
killer
fight_duration
damage_dealt
damage_taken
loot_dropped
aggro_target
path_failure
leash_return
zone_population
elite_spawn
rare_spawn
```

---

# UI

Monster UI should be minimal.

Show:

```text
health_bar
name
level
elite_marker
status_effects
boss_marker
```

Avoid large UI for normal monsters.

---

# Debug Tools

Monster inspector shows:

```text
id
data_id
family
state
hp
target
aggro_list
spawn_position
home_position
leash_distance
current_zone
loot_table
respawn_time
scheduler_slot
decision_reason
```

Debug commands:

```text
spawn_monster
spawn_elite
spawn_rare
kill_monster
kill_all_monsters
freeze_monsters
force_aggro
force_respawn
show_aggro_radius
show_leash_radius
show_spawn_zones
```

---

# Required Tests

Generate tests for:

```text
spawn
respawn
aggro
chase
leash
death
loot
quest progress
event spawn modifier
save/load persistent monster
population cap
```

---

# Required Test Cases

```text
GivenMonsterSpawnZone_WhenPopulationBelowTarget_ThenSpawnerCreatesMonster

GivenHeroEntersAggroRange_WhenMonsterIdle_ThenMonsterChasesHero

GivenHeroLeavesLeashRange_WhenMonsterChasing_ThenMonsterReturnsHome

GivenMonsterDies_WhenLootTableValid_ThenLootDropsOnce

GivenMonsterDies_WhenQuestTarget_ThenQuestProgressIncreases

GivenNormalMonsterDies_WhenRespawnEnabled_ThenRespawnScheduled

GivenPersistentElite_WhenSaveLoad_ThenEliteStateRestored

GivenZoneAtPopulationCap_WhenSpawnerTicks_ThenNoExtraMonsterSpawns
```

---

# Performance

Target:

```text
1000 Monsters
60 FPS
No per-frame AI thinking
No per-frame target search
No repeated path recalculation
No instant mass spawning
```

Use:

```text
MonsterAIScheduler
RespawnScheduler
ObjectPool
Spawn batches
Cached targets
Collision layers
```

---

# Documentation Output

Always include:

1. Feature overview
2. Folder structure
3. Scene hierarchy
4. Data model
5. Spawn flow
6. AI flow
7. Combat flow
8. Loot flow
9. Save model
10. Signals
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
- world.md
- testing.md
- telemetry.md

Never violate project rules.

---

# AI Instructions

When building Monster features:

- Do not create God Object `Monster.gd`.
- Use components.
- Keep monster behavior data-driven.
- Use AI scheduler.
- Never update monster AI every frame.
- Never hardcode spawn coordinates.
- Never spawn monsters directly inside combat logic.
- Never save normal runtime-only monsters unless required.
- Always support respawn and population caps.
- Always support debug inspection.
- Always support simulation testing.