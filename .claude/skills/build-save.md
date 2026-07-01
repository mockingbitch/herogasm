---
name: Build Save
description: Generate a complete save/load system for Herogasm including serialization, versioning, migration, autosave, offline progression, cloud-ready structure, tests, telemetry, and debug tools.
---

# Skill: Build Save

## Goal

Build a robust save system for a living-world idle RPG.

The save system stores game state.

It never stores scenes, nodes, UI, animation, audio, particles, or temporary effects.

Save/load must support:

- Offline play
- Autosave
- Migration
- Backup
- Recovery
- Offline progression
- Future cloud save
- Future server sync

---

# Save Philosophy

Save data is not runtime data.

Runtime world can be reconstructed from save data.

Save only what is required to restore meaningful gameplay state.

Never save Godot Nodes.

Never save NodePaths.

Use IDs only.

---

# Responsibilities

This skill generates:

- Save architecture
- SaveManager
- Serialization
- Deserialization
- Save data models
- Versioning
- Migration
- Autosave
- Backup
- Validation
- Recovery
- Offline progression
- Save inspector
- Telemetry
- Tests
- Documentation

Never generate only `SaveManager.gd`.

---

# Folder Structure

```text
save/
├── SaveManager.gd
├── SaveConfig.gd
├── SaveGameData.gd
├── SaveMetadata.gd
├── SaveResult.gd
├── SaveValidator.gd
├── SaveChecksum.gd
├── SaveCompressor.gd
├── SaveEncryption.gd
├── SaveSerializer.gd
├── SaveDeserializer.gd
├── SaveRepository.gd
├── AutosaveService.gd
├── BackupService.gd
├── RecoveryService.gd
├── migration/
│   ├── SaveMigration.gd
│   ├── SaveMigrationRegistry.gd
│   ├── Migration_001_To_002.gd
│   └── Migration_002_To_003.gd
├── modules/
│   ├── WorldSaveModule.gd
│   ├── TownSaveModule.gd
│   ├── HeroSaveModule.gd
│   ├── BuildingSaveModule.gd
│   ├── InventorySaveModule.gd
│   ├── EquipmentSaveModule.gd
│   ├── QuestSaveModule.gd
│   ├── EventSaveModule.gd
│   ├── EconomySaveModule.gd
│   ├── RelationshipSaveModule.gd
│   ├── StatisticsSaveModule.gd
│   └── SettingsSaveModule.gd
├── offline/
│   ├── OfflineProgressionService.gd
│   ├── OfflineProgressionContext.gd
│   ├── OfflineRewardResult.gd
│   └── OfflineCapRules.gd
├── debug/
│   ├── SaveInspector.tscn
│   ├── SaveDebugCommands.gd
│   └── SaveDiffViewer.gd
└── tests/
    ├── test_save_roundtrip.gd
    ├── test_save_validation.gd
    ├── test_save_migration.gd
    ├── test_save_recovery.gd
    ├── test_autosave.gd
    └── test_offline_progression.gd
```

---

# Save Architecture

```text
Runtime World
↓
Save Modules
↓
SaveGameData
↓
Validator
↓
Serializer
↓
Compressor
↓
Checksum
↓
Repository
↓
Disk
```

Load flow:

```text
Disk
↓
Repository
↓
Checksum
↓
Decompress
↓
Deserialize
↓
Validate
↓
Migrate
↓
Reconstruct Runtime World
```

---

# SaveGameData

Contains:

```text
metadata
world
town
heroes
buildings
inventory
equipment
quests
events
economy
relationships
statistics
settings
```

Does not contain:

```text
nodes
sprites
animation
navigation agents
audio
particles
ui
temporary vfx
debug panels
```

---

# SaveMetadata

Must contain:

```text
save_id
save_version
game_version
created_at
updated_at
play_time
last_online_time
checksum
profile_id
device_id_optional
schema_version
```

---

# Save Format

Preferred MVP format:

```text
Compressed JSON
```

Future-ready formats:

```text
Binary
SQLite
Cloud snapshot
```

Save format must be versioned.

---

# Modular Save Files

Prefer modular saves for large worlds.

```text
saves/profile_001/
├── meta.json
├── world.dat
├── town.dat
├── heroes.dat
├── buildings.dat
├── inventory.dat
├── quests.dat
├── events.dat
├── economy.dat
├── relationships.dat
├── statistics.dat
└── settings.dat
```

Benefits:

- Faster autosave
- Easier debugging
- Smaller writes
- Better cloud sync
- Better corruption recovery

---

# Save Modules

Each system owns its save module.

Examples:

```text
HeroSaveModule
BuildingSaveModule
InventorySaveModule
QuestSaveModule
EventSaveModule
EconomySaveModule
```

SaveManager orchestrates.

Modules serialize only their own data.

---

# Entity IDs

Every persistent object must have stable ID:

```text
hero_id
item_id
building_id
quest_id
event_id
relationship_id
zone_id
region_id
```

Never use:

```text
NodePath
Node name
Array index
Object instance ID
```

as persistent identity.

---

# Hero Save

Save:

```text
hero_id
data_id
level
exp
stats
hp
mp
stamina
mood
needs
personality_id
inventory_item_ids
equipment_item_ids
skill_ids
relationship_ids
current_location_id
current_goal_id
current_task
current_quest_id
```

Never save:

```text
NavigationAgent2D
AnimationPlayer
AnimatedSprite2D
current_path
signal connections
```

---

# Building Save

Save:

```text
building_id
building_data_id
level
durability
storage
queue
workers
visitors
upgrade_progress
production_state
cooldowns
```

---

# Inventory Save

Save:

```text
item_instance_id
item_data_id
quantity
durability
rarity
enchant
socket_ids
owner_id
locked
favorite
created_at
```

---

# Quest Save

Save:

```text
quest_id
quest_data_id
status
progress
targets
accepted_at
completed_at
reward_claimed
```

---

# Event Save

Save:

```text
event_id
event_data_id
phase
remaining_time
progress
participants
contribution
reward_claimed
active_modifiers
cooldown_remaining
```

---

# Economy Save

Save:

```text
gold
gems
materials
tokens
market_state
production
taxes
trade_history_summary
```

---

# Relationship Save

Save:

```text
relationship_id
hero_a_id
hero_b_id
type
affinity
history_summary
last_interaction_time
```

---

# World Save

Save:

```text
world_time
day
season
weather
unlocked_regions
unlocked_zones
boss_states
persistent_world_objects
destroyed_objects
```

---

# Serialization Rules

All saved objects must implement:

```text
to_save_dict()
from_save_dict(data)
validate()
get_schema_version()
```

Do not serialize raw Resources unless intentionally supported.

Prefer IDs referencing Resources.

---

# Validation

Validate before saving and after loading.

Check:

```text
required fields
data types
valid IDs
range limits
duplicate IDs
missing references
negative currency
invalid quest states
invalid item ownership
```

Invalid saves must not crash the game.

---

# Checksum

Every save must include checksum.

Detect:

```text
corruption
partial writes
tampering
truncated files
```

---

# Atomic Write

Save writes must be atomic.

Flow:

```text
write temp file
flush
validate temp
rename temp to final
backup old save
```

Never overwrite good save directly.

---

# Backup

Keep:

```text
latest
previous
autosave
manual
emergency
```

At minimum:

```text
current + previous
```

---

# Recovery

If current save fails:

```text
try previous save
try autosave
try emergency save
show clear error
never crash
```

---

# Autosave

Autosave triggers:

```text
time interval
major event complete
building upgraded
boss defeated
hero recruited
quest completed
app background
app exit
```

Recommended interval:

```text
30~120 seconds
```

Autosave must not freeze gameplay.

---

# Dirty Flags

Each save module tracks dirty state.

Only dirty modules should be written.

Examples:

```text
heroes_dirty
inventory_dirty
economy_dirty
events_dirty
```

---

# Versioning

Every save has version.

Migration path must be explicit:

```text
1 -> 2
2 -> 3
3 -> 4
```

Never skip migrations unless intentionally supported.

---

# Migration

Migrations must:

```text
preserve player progress
set defaults for new fields
remove deprecated fields safely
validate after migration
log changes
```

Never delete player-owned items unless unavoidable.

---

# Offline Progression

On load, calculate offline progress.

Inputs:

```text
last_save_time
current_time
offline_cap
hero_state
town_state
events
economy
stamina
inventory
danger
```

Do not simulate every second for long offline periods.

Use aggregate formulas.

---

# Offline Cap

Offline rewards must be capped.

Recommended:

```text
8 hours default cap
60%~80% active efficiency
inventory limit applies
stamina limit applies
danger limit applies
```

---

# Offline Reward Result

Contains:

```text
offline_duration
gold_earned
exp_earned
items_found
materials_found
hero_deaths
durability_loss
events_completed
warnings
```

---

# Cloud Ready

Save system must support future cloud sync.

Requirements:

```text
profile_id
save_id
version
updated_at
checksum
conflict policy
snapshot diff
upload/download hooks
```

---

# Conflict Policy

Future cloud conflict options:

```text
latest_timestamp
highest_progress
manual_choice
merge_if_safe
server_authority
```

Never silently overwrite valuable progress.

---

# Telemetry

Track:

```text
save_started
save_completed
save_failed
load_started
load_completed
load_failed
save_size
save_time
load_time
migration_started
migration_completed
migration_failed
checksum_failed
recovery_used
offline_progression_applied
```

---

# Debug Tools

Save inspector shows:

```text
save_version
game_version
save_size
last_saved
play_time
modules_dirty
checksum_status
backup_count
migration_history
offline_duration
```

Debug commands:

```text
save_now
load_save
quick_save
quick_load
export_save
import_save
validate_save
corrupt_save_test
run_migration
show_save_diff
clear_save
simulate_offline
```

---

# Tests

Generate tests for:

```text
roundtrip save/load
missing fields
invalid IDs
duplicate IDs
checksum failure
atomic write
backup recovery
migration
offline progression
dirty modules
autosave trigger
```

---

# Required Test Cases

```text
GivenHeroWithEquipment_WhenSaveLoad_ThenEquipmentRestored

GivenSaveVersionOne_WhenLoaded_ThenMigrationToCurrentVersionRuns

GivenCorruptedCurrentSave_WhenLoadRequested_ThenPreviousBackupLoads

GivenDuplicateItemIds_WhenValidateSave_ThenValidationFails

GivenAutosaveIntervalReached_WhenDirtyModulesExist_ThenAutosaveWritesOnlyDirtyModules

GivenOfflineForEightHours_WhenLoad_ThenOfflineRewardsApplyWithinCap

GivenRewardAlreadyClaimed_WhenSaveLoad_ThenRewardCannotBeClaimedAgain
```

---

# Performance

Targets:

```text
Autosave < 500 ms
Load < 3 sec
No frame freeze
Save size controlled
Dirty modules only
```

Rules:

```text
Do not save every frame
Do not serialize Nodes
Do not serialize full Resource database
Do not rebuild the world before validation
Do not block UI unnecessarily
```

---

# Documentation Output

Always include:

1. Save overview
2. Folder structure
3. Save file structure
4. Data model
5. Serialization rules
6. Validation rules
7. Versioning and migration
8. Autosave
9. Backup and recovery
10. Offline progression
11. Cloud-ready design
12. Telemetry
13. Debug tools
14. Tests
15. Performance notes

---

# Required Rules

Follow:

- architecture.md
- save-system.md
- multiplayer.md
- performance.md
- telemetry.md
- debug-tools.md
- testing.md
- regression.md

Never violate project rules.

---

# AI Instructions

When building save systems:

- Never save Nodes.
- Never save scene tree.
- Use stable IDs.
- Use modular save modules.
- Validate save data.
- Use atomic writes.
- Keep backups.
- Support migration.
- Support offline progression.
- Track telemetry.
- Add regression tests for save bugs.