---
name: Build Combat
description: Generate a complete autonomous combat system for Herogasm including formulas, targeting, skills, damage, status effects, loot hooks, telemetry, tests, and debug tools.
---

# Skill: Build Combat

## Goal

Build a scalable autonomous combat system.

Combat is not directly controlled by the player.

Heroes and monsters decide:

- target
- attack
- skill
- potion
- retreat
- loot
- reposition

Combat must be readable, deterministic, data-driven, and performant.

---

# Combat Philosophy

Combat should feel alive but not chaotic.

The player watches heroes fight automatically.

Good combat has:

- clear damage
- readable skills
- visible danger
- meaningful retreat
- useful roles
- fair rewards
- no random nonsense

Boss fights should feel important.

Normal fights should be fast.

---

# Responsibilities

This skill generates:

- Combat architecture
- Damage formula
- Targeting
- Attack system
- Skill system
- Status effects
- Threat / aggro
- Death flow
- Loot hooks
- Quest hooks
- Telemetry
- Debug tools
- Tests
- Documentation

Never generate only `Combat.gd`.

---

# Folder Structure

```text
combat/
├── CombatService.gd
├── CombatContext.gd
├── CombatResult.gd
├── DamageCalculator.gd
├── TargetingService.gd
├── ThreatTable.gd
├── CombatRegistry.gd
├── AttackRequest.gd
├── SkillRequest.gd
├── DeathHandler.gd
├── components/
│   ├── CombatComponent.gd
│   ├── HealthComponent.gd
│   ├── ManaComponent.gd
│   ├── ThreatComponent.gd
│   ├── StatusEffectComponent.gd
│   └── CombatTelemetryComponent.gd
├── skills/
│   ├── SkillData.gd
│   ├── SkillRuntimeState.gd
│   ├── SkillExecutor.gd
│   ├── SkillTargeting.gd
│   └── effects/
│       ├── DamageEffect.gd
│       ├── HealEffect.gd
│       ├── BuffEffect.gd
│       ├── DebuffEffect.gd
│       ├── SummonEffect.gd
│       └── AreaEffect.gd
├── status/
│   ├── StatusEffectData.gd
│   ├── StatusEffectInstance.gd
│   ├── StatusEffectRegistry.gd
│   ├── PoisonEffect.gd
│   ├── BurnEffect.gd
│   ├── StunEffect.gd
│   ├── SlowEffect.gd
│   └── ShieldEffect.gd
├── projectiles/
│   ├── Projectile.tscn
│   ├── Projectile.gd
│   └── ProjectilePool.gd
├── ui/
│   ├── DamageNumber.tscn
│   ├── CombatFloatingText.tscn
│   └── CombatDebugPanel.tscn
└── tests/
    ├── test_damage_formula.gd
    ├── test_targeting.gd
    ├── test_skill_execution.gd
    ├── test_status_effects.gd
    ├── test_death_flow.gd
    └── test_combat_simulation.gd
```

---

# Combat Architecture

```text
Entity AI
↓
CombatComponent
↓
CombatService
↓
DamageCalculator
↓
CombatResult
↓
HealthComponent
↓
DeathHandler
↓
Loot / Quest / Telemetry
```

Combat logic must be independent from animation and UI.

---

# Core Rule

Animation does not decide combat result.

Combat result happens first.

Animation visualizes result afterward.

---

# CombatComponent

Each combat entity owns a CombatComponent.

Responsibilities:

- validate target
- request attack
- request skill
- manage cooldowns
- expose combat stats
- notify death
- notify damage taken

CombatComponent does not calculate everything alone.

---

# HealthComponent

Owns:

```text
current_hp
max_hp
shield
is_dead
```

Emits:

```text
health_changed
damage_taken
healed
died
```

Never update HP directly outside HealthComponent.

---

# Damage Formula

Damage formula must be simple and stable.

Recommended base:

```text
raw_damage = attacker_attack * skill_multiplier

defense_reduction = defender_defense / (defender_defense + 100)

final_damage = raw_damage * (1 - defense_reduction)
```

Clamp final damage:

```text
minimum_damage = 1
maximum_damage = configurable
```

No negative damage.

---

# Critical

Critical uses:

```text
critical_chance
critical_damage
luck
```

Rules:

```text
critical_chance max = 80%
critical_damage default = 150%
critical_damage max = 300%
```

Critical must be visible.

---

# Dodge

Dodge should be limited.

Rules:

```text
dodge max = 40%
never allow 100% dodge
boss attacks may ignore part of dodge
```

Avoid frustrating miss spam.

---

# Accuracy

Accuracy affects dodge counter.

Recommended:

```text
effective_dodge = defender_dodge - attacker_accuracy_bonus
```

Clamp effective dodge.

---

# Attack Request

AttackRequest contains:

```text
attacker_id
target_id
attack_type
skill_id
timestamp
source_position
target_position
seed
```

Requests must be serializable.

---

# Combat Result

CombatResult contains:

```text
attacker_id
target_id
damage
is_critical
is_dodged
is_blocked
is_killing_blow
status_applied
threat_generated
loot_triggered
```

---

# Targeting

TargetingService supports:

```text
nearest
lowest_hp
highest_threat
quest_target
boss
elite
support
random_valid
```

Never scan all monsters every frame.

Use cached nearby targets and collision areas.

---

# Target Validity

Target must be:

```text
alive
reachable
inside range or chaseable
enemy
not despawned
not invalid
```

Clear invalid target immediately.

---

# Threat / Aggro

ThreatTable tracks:

```text
damage_dealt
healing_done
taunt
proximity
special_effect
```

Boss and elite monsters should use threat.

Normal monsters may use simple targeting.

---

# Skill System

Skills are data-driven.

SkillData includes:

```text
id
name
description
type
range
cooldown
mana_cost
cast_time
targeting_rule
effects
animation_id
vfx_id
sound_id
```

Never hardcode skill behavior inside Hero or Monster.

---

# Skill Types

Supported:

```text
Melee
Ranged
Magic
Heal
Buff
Debuff
Area
Summon
Dash
Shield
Taunt
Revive
```

---

# Skill Execution Flow

```text
AI selects skill
↓
CombatComponent validates
↓
SkillExecutor consumes cost
↓
Skill effect resolves
↓
CombatResult generated
↓
Animation/VFX triggered
↓
Telemetry emitted
```

---

# Cooldowns

Cooldowns are runtime state.

Do not store cooldown inside SkillData.

Cooldown must survive save/load only when necessary.

---

# Status Effects

Status effects are data-driven.

Supported:

```text
Poison
Burn
Stun
Slow
Bleed
Shield
Regen
AttackBuff
DefenseBuff
Silence
Fear
Taunt
```

---

# Status Effect Rules

Each effect has:

```text
duration
tick_interval
stack_rule
max_stacks
source_id
target_id
```

Effects must be removable.

---

# Death Flow

```text
HP reaches 0
↓
Entity marked dead
↓
Cancel current action
↓
Clear target
↓
Emit died
↓
Grant EXP
↓
Drop loot
↓
Update quest
↓
Telemetry
↓
Respawn / revive logic
```

Death must happen once only.

---

# Loot Hook

Combat does not create loot directly.

Combat emits death result.

Loot system handles drops.

---

# Quest Hook

Combat does not update quests directly.

Quest system listens to monster killed events.

---

# Retreat

Hero may retreat when:

```text
HP low
stamina low
potion empty
equipment broken
inventory full
danger too high
```

Retreat is AI decision, not combat formula.

---

# Potion Usage

Potion usage is requested by AI.

Combat validates:

```text
potion exists
cooldown available
hero alive
need valid
```

---

# Boss Combat

Boss combat requires:

```text
phase system
threat table
skill rotation
warning areas
minions
contribution tracking
reward protection
```

Use `build-boss.md` for full boss systems.

---

# Performance

Target:

```text
300 Heroes
1000 Monsters
200 active combats
60 FPS
```

Rules:

```text
No per-frame full target search
No combat via signals every tick
No repeated allocations
No string operations in hot loop
No scene tree traversal
Use scheduler
Use object pools
Use cached targets
```

---

# Object Pool

Pool:

```text
DamageNumber
Projectile
HitEffect
HealEffect
StatusIcon
FloatingText
```

Never instantiate these repeatedly during combat.

---

# Signals

Combat may emit:

```text
damage_applied(result)
entity_died(entity, killer)
skill_cast(caster, skill)
status_applied(target, status)
threat_changed(entity)
```

Do not emit high-frequency debug signals.

---

# Telemetry

Track:

```text
attack
skill_cast
damage_dealt
damage_taken
critical
dodge
heal
death
fight_duration
potion_used
retreat
status_applied
target_switch
```

---

# Debug Tools

Combat inspector shows:

```text
attacker
target
current_hp
damage_formula
last_damage
critical_roll
dodge_roll
active_status
cooldowns
threat_table
fight_duration
```

Debug commands:

```text
god_mode
one_hit_kill
disable_damage
disable_cooldowns
force_critical
force_dodge
spawn_combat
show_hitboxes
show_aggro
show_damage_formula
clear_status_effects
```

---

# Required Tests

Generate tests for:

```text
damage formula
critical
dodge
armor
healing
death once
target validity
skill cooldown
mana cost
status effect tick
loot trigger once
quest hook
threat table
```

---

# Required Test Cases

```text
GivenAttackerAndDefender_WhenDamageCalculated_ThenDamageIsPositive

GivenCriticalChanceOneHundred_WhenAttackHits_ThenCriticalDamageApplied

GivenTargetDead_WhenAttackRequested_ThenAttackRejected

GivenEntityHpReachesZero_WhenDamageAppliedTwice_ThenDeathEmittedOnce

GivenSkillOnCooldown_WhenCastRequested_ThenCastRejected

GivenPoisonApplied_WhenTickIntervalPasses_ThenDamageOverTimeApplied

GivenMonsterKilled_WhenDeathFlowRuns_ThenLootTriggeredOnce

GivenHeroLowHp_WhenPotionAvailable_ThenAIRequestsPotion
```

---

# Documentation Output

Always include:

1. Combat overview
2. Folder structure
3. Core classes
4. Damage formula
5. Targeting rules
6. Skill system
7. Status effects
8. Death flow
9. Loot/quest hooks
10. Telemetry
11. Debug tools
12. Tests
13. Performance notes

---

# Required Rules

Follow:

- architecture.md
- coding-style.md
- gdscript.md
- scene-structure.md
- signal-rules.md
- performance.md
- balancing.md
- ai.md
- testing.md
- telemetry.md
- debug-tools.md

Never violate project rules.

---

# AI Instructions

When building combat systems:

- Keep combat independent from animation.
- Keep combat independent from UI.
- Use data-driven skills.
- Use deterministic formulas.
- Avoid per-frame target scanning.
- Prevent duplicate death events.
- Prevent duplicate loot rewards.
- Include tests for formulas and edge cases.
- Include debug tools for damage calculation.
- Include telemetry for balance analysis.