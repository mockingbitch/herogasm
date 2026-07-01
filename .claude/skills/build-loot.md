---
name: Build Loot
description: Generate a complete loot, drop table, item reward, pickup, inventory hook, telemetry, tests, and debug system.
---

# Skill: Build Loot

## Goal

Build a scalable loot system for Herogasm.

Loot must support:

- Monster drops
- Boss rewards
- Quest rewards
- Event rewards
- Resource drops
- Treasure chests
- Crafting materials
- Equipment drops
- Offline rewards

Loot should feel rewarding but controlled.

---

# Loot Philosophy

Loot is progression.

Every drop should have purpose.

Avoid useless trash.

Every item should either be:

- Used
- Sold
- Crafted
- Upgraded
- Recycled
- Collected

Nothing should be meaningless.

---

# Responsibilities

This skill generates:

- Loot architecture
- Drop table system
- Weighted random
- Rarity system
- Item generation
- Loot ownership
- Pickup rules
- Inventory integration
- Quest hooks
- Boss reward hooks
- Event modifiers
- Save/load
- Telemetry
- Debug tools
- Tests
- Documentation

Never generate only `Loot.gd`.

---

# Folder Structure

```text
loot/
├── LootService.gd
├── LootContext.gd
├── LootResult.gd
├── LootRoller.gd
├── LootTableData.gd
├── LootEntryData.gd
├── LootModifierData.gd
├── LootOwnershipData.gd
├── LootSaveData.gd
├── LootPickupService.gd
├── LootValueCalculator.gd
├── components/
│   ├── LootDropComponent.gd
│   ├── LootPickupComponent.gd
│   ├── LootMagnetComponent.gd
│   └── LootTelemetryComponent.gd
├── world/
│   ├── LootWorldItem.tscn
│   ├── LootWorldItem.gd
│   ├── LootSpawner.gd
│   └── LootPool.gd
├── rewards/
│   ├── RewardBundleData.gd
│   ├── RewardService.gd
│   ├── RewardClaim.gd
│   └── RewardProtection.gd
├── ui/
│   ├── LootPopup.tscn
│   ├── RewardPopup.tscn
│   ├── DropPreviewPanel.tscn
│   └── LootLogItem.tscn
├── debug/
│   ├── LootInspector.tscn
│   └── LootDebugCommands.gd
└── tests/
    ├── test_loot_roll.gd
    ├── test_drop_table.gd
    ├── test_loot_pickup.gd
    ├── test_reward_protection.gd
    └── test_loot_simulation.gd
```

---

# Core Architecture

```text
Death / Reward Trigger
↓
LootContext
↓
LootService
↓
LootRoller
↓
LootResult
↓
World Loot / Direct Reward
↓
Inventory / Reward Claim
↓
Telemetry
```

Combat does not create loot directly.

Combat emits death result.

Loot system handles drops.

---

# LootContext

Contains:

```text
source_id
source_type
killer_id
party_id
zone_id
region_id
event_id
monster_level
player_progress
luck
difficulty
drop_bonus
seed
```

Loot rolling must be deterministic with seed.

---

# LootTableData

Static Resource config:

```text
id
display_name
entries
guaranteed_entries
roll_count
rarity_weights
level_range
region_id
event_modifier_ids
```

No runtime state inside LootTableData.

---

# LootEntryData

Contains:

```text
item_id
weight
min_quantity
max_quantity
rarity
conditions
unique_limit
drop_once
bind_rule
```

---

# LootResult

Contains:

```text
source_id
receiver_id
items
gold
exp
materials
currency
was_modified_by_event
seed
```

---

# Rarity

Supported rarity:

```text
Common
Uncommon
Rare
Epic
Legendary
Mythic
Unique
Event
```

Rarity affects:

```text
drop chance
visual effect
sound
notification
telemetry
value
```

---

# Drop Rules

Normal monsters drop:

```text
gold
common material
low chance equipment
low chance rare material
```

Elite monsters drop:

```text
more gold
rare material
better equipment chance
```

Bosses drop:

```text
unique material
rare equipment
boss token
recipe
title/cosmetic chance
```

Events drop:

```text
event currency
event material
limited recipe
cosmetic
```

---

# Weighted Random

Use weighted random.

Never use ad-hoc random logic.

All randomness goes through `RandomService`.

---

# Guaranteed Drops

Support guaranteed drops.

Examples:

```text
Boss token
Quest item
Event currency
First clear reward
```

---

# Drop Protection

Support:

```text
pity counter
first kill bonus
duplicate protection
daily limit
weekly limit
unique item limit
```

Use carefully.

---

# Ownership

Loot can be:

```text
Private
Party
Guild
Public
ContributionBased
```

Default for normal hunting:

```text
Private to killer hero
```

World boss:

```text
ContributionBased
```

---

# Pickup Rules

Hero can pick up loot when:

```text
alive
near loot
inventory has space
ownership valid
not expired
item valid
```

If inventory full:

```text
return town
store
sell
or ignore based on AI
```

---

# Loot Expiration

World loot expires after configurable time.

Examples:

```text
Common: 60 sec
Rare: 180 sec
Legendary: 600 sec
Boss reward: claim-based, not world drop
```

---

# Inventory Integration

Loot system sends items to InventoryService.

Never directly mutate inventory arrays.

Correct:

```text
InventoryService.add_item(hero_id, item)
```

Wrong:

```text
hero.inventory.append(item)
```

---

# Quest Hook

Quest items are handled by loot or quest systems based on config.

Quest progress must not depend on visual loot pickup unless designed.

---

# Reward Bundles

RewardBundleData supports:

```text
gold
exp
items
materials
currency
recipes
titles
cosmetics
pets
```

Used by:

```text
quests
events
bosses
achievements
daily rewards
offline rewards
```

---

# Reward Protection

Prevent:

```text
duplicate claim
save/load exploit
offline exploit
boss reward exploit
event rejoin exploit
```

Every claim must have:

```text
claim_id
receiver_id
source_id
timestamp
reward_hash
```

---

# Offline Loot

Offline rewards should be simulated using aggregate rates.

Do not simulate every kill if offline for hours.

Apply:

```text
offline_efficiency
inventory_limit
stamina_limit
danger_limit
drop_cap
```

---

# Event Modifiers

Events may modify:

```text
drop_rate
gold_rate
exp_rate
rarity_weight
specific_item_chance
boss_token_amount
```

Modifiers must be temporary and reversible.

---

# Economy Balance

Loot must support economy sinks.

Avoid flooding:

```text
gold
legendary items
upgrade stones
rare materials
```

Track flow through telemetry.

---

# World Loot

World loot scene:

```text
LootWorldItem : Area2D
├── Sprite
├── Shadow
├── PickupArea
├── ExpireTimer
├── RarityGlow
└── DebugLabel
```

World loot must use object pool.

Never instantiate thousands of loot nodes directly.

---

# Visual Feedback

Loot feedback:

```text
small popup
rarity glow
pickup sound
floating text
loot log
```

Legendary drops may trigger notification.

Avoid excessive popup spam.

---

# Signals

Loot may emit:

```text
loot_rolled(result)
loot_spawned(world_item)
loot_picked_up(hero_id, item_id)
loot_expired(world_item)
reward_claimed(claim_id, receiver_id)
rare_drop_obtained(receiver_id, item_id)
```

Do not emit every frame.

---

# Telemetry

Track:

```text
loot_rolled
item_dropped
item_picked_up
item_expired
rare_drop
legendary_drop
reward_claimed
duplicate_claim_rejected
drop_rate_actual
gold_generated
material_generated
```

---

# Debug Tools

Loot inspector shows:

```text
loot_table_id
source_id
roll_seed
roll_result
rarity
ownership
expiration
pickup_status
drop_modifiers
```

Debug commands:

```text
roll_loot
spawn_loot
force_legendary
test_drop_table
clear_loot
give_reward
claim_reward
reset_pity
show_loot_table
simulate_kills
```

---

# Required Tests

Generate tests for:

```text
weighted random
guaranteed drops
rarity weights
ownership
pickup
inventory full
expiration
reward claim
duplicate protection
event modifiers
offline rewards
```

---

# Required Test Cases

```text
GivenLootTableWithGuaranteedDrop_WhenRolled_ThenGuaranteedItemAppears

GivenSameSeed_WhenLootRolledTwice_ThenResultsAreIdentical

GivenInventoryFull_WhenHeroPicksLoot_ThenPickupRejectedAndHeroReturnsTown

GivenRewardClaimed_WhenClaimedAgain_ThenSecondClaimRejected

GivenEventDropModifier_WhenLootRolled_ThenDropRateModified

GivenWorldLootExpired_WhenPickupAttempted_ThenPickupRejected

GivenBossReward_WhenMultipleParticipants_ThenRewardsDistributedByContribution
```

---

# Performance

Target:

```text
300 Heroes
1000 Monsters
3000 Loot Items
60 FPS
```

Rules:

```text
Use object pool
Batch loot spawning
Do not spawn all loot in one frame
Do not update all loot every frame
Do not rebuild loot UI every drop
Avoid string operations in hot loops
```

---

# Documentation Output

Always include:

1. Loot overview
2. Folder structure
3. Data model
4. Drop table design
5. Rarity system
6. Ownership rules
7. Pickup flow
8. Reward protection
9. Offline loot
10. Event modifiers
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
- balancing.md
- testing.md
- telemetry.md
- debug-tools.md

Never violate project rules.

---

# AI Instructions

When building loot systems:

- Never create loot directly inside combat logic.
- Use LootService.
- Use deterministic seeded rolls.
- Use weighted drop tables.
- Protect all rewards from duplication.
- Integrate with InventoryService, not raw arrays.
- Support event modifiers and offline rewards.
- Pool world loot objects.
- Include drop-rate tests and simulations.