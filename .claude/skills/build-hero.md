---
name: Build Hero
description: Generate a complete autonomous Hero system for Herogasm including data, AI, combat, needs, equipment, save, UI, telemetry, tests, and debug tools.
---

# Skill: Build Hero

## Goal

Build a fully autonomous Hero.

Heroes are not controlled directly by the player.

Heroes live, travel, hunt, fight, loot, shop, rest, train, socialize, and return to town by themselves.

A Hero is the main living unit of the game.

---

# Hero Philosophy

Hero is not a player avatar.

Hero is an autonomous adventurer.

Player manages the town.

Hero makes decisions based on:

- Needs
- Mood
- Personality
- Quest
- Equipment
- Inventory
- Danger
- Reward
- Relationship
- Distance

Heroes must feel alive.

---

# Responsibilities

This skill generates:

- Architecture
- Scene
- Scripts
- Resources
- AI
- FSM / Goal System
- Needs System
- Combat Integration
- Inventory
- Equipment
- Skills
- Relationship
- Mood
- Save Data
- UI
- Telemetry
- Tests
- Debug Tools
- Documentation

Never generate only `Hero.gd`.

---

# Scene Structure

```text
Hero.tscn

HeroRoot : CharacterBody2D
├── NavigationAgent2D
├── CollisionShape2D
├── AnimatedSprite2D
├── Shadow
├── HealthBar
├── SelectionCircle
├── InteractionArea
├── TargetDetector
├── AnimationPlayer
├── AudioAnchor
├── DebugLabel
└── Components
    ├── HeroBrain
    ├── MovementComponent
    ├── CombatComponent
    ├── InventoryComponent
    ├── EquipmentComponent
    ├── SkillComponent
    ├── NeedsComponent
    ├── MoodComponent
    ├── RelationshipComponent
    ├── QuestComponent
    └── SaveComponent
```

---

# Folder Structure

```text
heroes/
├── Hero.tscn
├── Hero.gd
├── HeroData.gd
├── HeroState.gd
├── HeroRuntimeState.gd
├── HeroClassData.gd
├── HeroPersonalityData.gd
├── HeroSaveData.gd
├── components/
│   ├── HeroBrain.gd
│   ├── MovementComponent.gd
│   ├── CombatComponent.gd
│   ├── InventoryComponent.gd
│   ├── EquipmentComponent.gd
│   ├── SkillComponent.gd
│   ├── NeedsComponent.gd
│   ├── MoodComponent.gd
│   ├── RelationshipComponent.gd
│   ├── QuestComponent.gd
│   └── HeroTelemetryComponent.gd
├── ai/
│   ├── HeroGoal.gd
│   ├── HeroGoalEvaluator.gd
│   ├── HeroDecisionContext.gd
│   ├── goals/
│   │   ├── HuntGoal.gd
│   │   ├── RestGoal.gd
│   │   ├── RepairGoal.gd
│   │   ├── SellLootGoal.gd
│   │   ├── BuyPotionGoal.gd
│   │   ├── TrainGoal.gd
│   │   ├── SocializeGoal.gd
│   │   └── ReturnTownGoal.gd
│   └── states/
│       ├── HeroIdleState.gd
│       ├── HeroTravelState.gd
│       ├── HeroHuntState.gd
│       ├── HeroCombatState.gd
│       ├── HeroRestState.gd
│       ├── HeroShopState.gd
│       ├── HeroTrainState.gd
│       ├── HeroDeadState.gd
│       └── HeroReturnState.gd
├── ui/
│   ├── HeroPanel.tscn
│   ├── HeroPanel.gd
│   ├── HeroListItem.tscn
│   └── HeroStatusBadge.tscn
└── tests/
    ├── test_hero_needs.gd
    ├── test_hero_ai_decision.gd
    ├── test_hero_save.gd
    ├── test_hero_combat.gd
    └── test_hero_simulation.gd
```

---

# Core Architecture

```text
Hero
↓
HeroData
↓
HeroRuntimeState
↓
Components
↓
HeroBrain
↓
Goal
↓
Action
```

Hero root coordinates components only.

Business logic belongs to components and pure data classes.

---

# HeroData

Contains static configuration:

- Hero ID
- Display Name
- Class
- Base Stats
- Growth Rate
- Skill Slots
- Equipment Slots
- Personality
- Portrait
- Sprite Set
- Rarity
- Unlock Rules

HeroData is Resource-based.

No runtime state inside HeroData.

---

# HeroRuntimeState

Contains runtime state:

- Current HP
- Current MP
- Stamina
- Mood
- Current Goal
- Current State
- Current Location
- Current Target
- Current Quest
- Inventory
- Equipment
- Relationships
- Current Path
- Current Building
- Current Zone

Runtime state is not configuration.

---

# HeroSaveData

Contains saved state only:

- Hero ID
- Level
- EXP
- Stats
- HP
- MP
- Stamina
- Mood
- Inventory IDs
- Equipment IDs
- Skill IDs
- Relationship IDs
- Current Location ID
- Current Task
- Current Quest ID
- Fatigue
- Personality ID

Never save Node references.

Never save NavigationAgent2D.

Never save AnimationPlayer.

---

# Hero Classes

Minimum classes:

- Knight
- Archer
- Mage
- Priest
- Assassin
- Paladin
- Berserker
- Ranger
- Necromancer

Classes are data-driven.

Do not create:

```text
Knight.gd
Mage.gd
Archer.gd
```

Use:

```text
Hero + HeroClassData
```

---

# Hero Stats

Core stats:

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
luck
stamina
carry_capacity
```

---

# Hero Needs

Every hero has needs:

```text
health
mana
stamina
hunger
sleep
mood
equipment_durability
inventory_space
social
safety
```

Need values range from 0 to 100.

Needs affect AI decisions.

---

# Hero Personality

Personality affects decision scoring.

Examples:

```text
Brave
Coward
Greedy
Lazy
Hardworking
Friendly
Aggressive
Explorer
Collector
Careful
Reckless
```

Personality is data-driven.

---

# Hero AI

Hero AI uses:

- Scheduler
- Goal scoring
- FSM
- Utility AI
- Direct method calls for hot paths
- Signals only for meaningful events

Hero AI must never think every frame.

---

# Decision Priority

```text
Survival
↓
Safety
↓
Quest
↓
Profit
↓
Maintenance
↓
Relationship
↓
Entertainment
↓
Idle
```

---

# Required Goals

Implement these goals:

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
ReviveGoal
EscapeDangerGoal
```

---

# Goal Evaluation

Each goal returns a score.

Example:

```text
RestGoal score increases when:
- HP low
- stamina low
- sleep need high
- inn nearby
- hero has gold

RepairGoal score increases when:
- weapon durability low
- blacksmith available
- hero has gold
- hero is not in danger
```

---

# Movement

Heroes always move physically.

Use:

```text
NavigationAgent2D
```

Never teleport unless using explicit systems:

- Fast Travel
- Portal
- Debug command
- Cutscene

---

# Travel Flow

```text
Town
↓
Road
↓
Gate
↓
Region
↓
Hunting Zone
↓
Target
↓
Return
```

---

# Combat

Combat is autonomous.

Hero decides:

- Target
- Skill
- Potion
- Retreat
- Position
- Loot

Combat should not depend on animation timing.

---

# Retreat Conditions

Hero retreats when:

- HP too low
- No potion
- Equipment broken
- Inventory full
- Dangerous boss nearby
- Quest complete
- Stamina empty

---

# Inventory

Hero inventory supports:

- Add item
- Remove item
- Stack item
- Sell loot
- Lock item
- Favorite item
- Full inventory detection
- Weight or slot capacity

---

# Equipment

Equipment affects stats.

Equipment has:

- Slot
- Durability
- Rarity
- Level
- Enchant
- Socket
- Owner ID

Hero should repair equipment before hunting.

---

# Skills

Skills are data-driven.

Hero chooses skills based on:

- Cooldown
- Mana
- Range
- Enemy count
- Target priority
- Danger
- Role

Never hardcode skill behavior inside Hero.gd.

---

# Relationship

Heroes can have:

- Friend
- Rival
- Mentor
- Student
- Partner
- Guildmate

Relationships affect:

- Mood
- Team preference
- Social behavior
- Rescue behavior
- Combat support

---

# Mood

Mood affects:

- Hunting efficiency
- Shopping behavior
- Social behavior
- Rest priority
- Training efficiency

Low mood should not make hero useless,
but should reduce efficiency.

---

# Signals

Hero may emit:

```text
hero_spawned(hero)
hero_died(hero)
hero_revived(hero)
hero_level_up(hero, level)
hero_goal_changed(hero, old_goal, new_goal)
hero_state_changed(hero, old_state, new_state)
hero_left_town(hero)
hero_returned_town(hero)
hero_inventory_full(hero)
hero_equipment_broken(hero)
hero_needs_changed(hero)
```

Do not emit every frame.

---

# Telemetry

Track:

- Goal selected
- Goal completed
- State changed
- Death
- Level up
- Loot gained
- Potion used
- Repair
- Rest
- Shop
- Travel time
- Combat duration
- Path failure
- Idle duration

---

# Save

Save only data:

```text
HeroSaveData
InventorySaveData
EquipmentSaveData
QuestSaveData
RelationshipSaveData
```

Never save:

```text
Node
Path
Animation
Sprite
NavigationAgent
Signal
Timer
```

---

# UI

Hero UI shows:

- Name
- Class
- Level
- HP
- MP
- Mood
- Needs
- Equipment
- Inventory
- Current Goal
- Current Location
- Current Target
- Relationship
- Quest
- Recent Activity

UI listens to state.

UI never controls Hero directly.

---

# Debug Tools

Hero inspector must show:

- ID
- State
- Goal
- Need values
- Mood
- Personality
- Target
- Path
- Destination
- Equipment
- Inventory
- Quest
- Scheduler slot
- Decision score
- Last decision reason

Debug commands:

```text
spawn_hero
kill_hero
revive_hero
heal_hero
damage_hero
teleport_hero
force_goal
force_state
fill_inventory
break_equipment
set_mood
set_need
level_up
```

---

# Tests

Generate:

- Unit tests
- AI decision tests
- Combat tests
- Inventory tests
- Equipment tests
- Save/load tests
- Simulation tests
- Stress tests
- Regression tests

---

# Required Test Cases

```text
GivenHeroLowHp_WhenPotionAvailable_ThenUsePotion

GivenHeroLowHp_WhenNoPotion_ThenReturnToInn

GivenInventoryFull_WhenHunting_ThenReturnTown

GivenWeaponBroken_WhenNearBlacksmith_ThenRepairWeapon

GivenQuestTargetNearby_WhenHeroHunting_ThenPrioritizeQuestTarget

GivenHeroDead_WhenChurchAvailable_ThenReviveFlowStarts

GivenSaveLoad_WhenHeroHasEquipment_ThenEquipmentRestored

GivenHeroNoGoal_WhenAISchedulerTicks_ThenHeroSelectsGoal
```

---

# Performance

Target:

```text
300 Heroes
60 FPS
AI tick under budget
No per-frame decision making
No per-frame SceneTree search
No repeated path recalculation
```

Use scheduler for AI.

Use cached references.

Use object pools for effects.

---

# Documentation Output

Always include:

1. Feature overview
2. Scene hierarchy
3. Folder structure
4. Data model
5. AI flow
6. State diagram
7. Signals
8. Save model
9. UI behavior
10. Debug tools
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
- save-system.md
- economy.md
- ai.md
- world.md
- testing.md
- telemetry.md

Never violate project rules.

---

# AI Instructions

When building Hero features:

- Do not create God Object Hero.gd.
- Use components.
- Keep AI data-driven.
- Use scheduler.
- Never update AI every frame.
- Never teleport hero.
- Never couple Hero with UI.
- Never save Nodes.
- Always support debug inspection.
- Always support simulation testing.