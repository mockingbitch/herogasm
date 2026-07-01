---
name: Build Network
description: Generate a multiplayer-ready network architecture for Herogasm including client-server boundaries, commands, sync, persistence, security, telemetry, tests, and future live-service support.
---

# Skill: Build Network

## Goal

Build a network-ready foundation.

The game is offline-first for MVP.

However, all gameplay systems must be designed so they can later support:

- Cloud save
- Guild
- World Boss
- Market
- Rankings
- PvP
- Events
- Account sync
- Anti-cheat
- LiveOps

Do not force online multiplayer in MVP.

Design for future server authority.

---

# Network Philosophy

Godot client is presentation and local simulation.

Server is future authority.

Gameplay logic should be portable between:

```text
LocalGameService
RemoteGameService
ServerGameService
```

Offline mode and online mode should share the same:

- Commands
- Events
- Data models
- Save snapshots
- Validation rules

---

# Responsibilities

This skill generates:

- Network architecture
- Client-server boundaries
- Command system
- Event sync
- Snapshot model
- Cloud save model
- Sync strategy
- Security rules
- Offline-first flow
- Reconnect flow
- Telemetry
- Debug tools
- Tests
- Documentation

Never generate only `NetworkManager.gd`.

---

# Supported Modes

```text
Offline
Local Simulation
Cloud Save
Async Online
Server Assisted
Server Authoritative
```

MVP uses:

```text
Offline + Local Simulation
```

Future live version can use:

```text
Server Assisted + Server Authoritative
```

---

# High Level Architecture

```text
Godot Client
↓
GameService Interface
↓
LocalGameService / RemoteGameService
↓
Command Bus
↓
Game Simulation
↓
Event Stream
↓
Snapshot / Save
```

Future server:

```text
Godot Client
↓
API Gateway
↓
Game Server
↓
Simulation Services
↓
Database / Redis
```

---

# Folder Structure

```text
network/
├── NetworkManager.gd
├── ConnectionState.gd
├── NetworkConfig.gd
├── GameService.gd
├── LocalGameService.gd
├── RemoteGameService.gd
├── ServerClock.gd
├── SyncState.gd
├── commands/
│   ├── GameCommand.gd
│   ├── CommandBus.gd
│   ├── CommandResult.gd
│   ├── CommandValidator.gd
│   ├── MoveHeroCommand.gd
│   ├── AcceptQuestCommand.gd
│   ├── EquipItemCommand.gd
│   ├── UpgradeBuildingCommand.gd
│   ├── ClaimRewardCommand.gd
│   ├── BuyItemCommand.gd
│   ├── SellItemCommand.gd
│   └── StartEventCommand.gd
├── events/
│   ├── NetworkEvent.gd
│   ├── EventStream.gd
│   ├── EventSerializer.gd
│   ├── HeroEvent.gd
│   ├── EconomyEvent.gd
│   ├── InventoryEvent.gd
│   ├── BossEvent.gd
│   └── WorldEvent.gd
├── sync/
│   ├── Snapshot.gd
│   ├── SnapshotDiff.gd
│   ├── SnapshotSerializer.gd
│   ├── SyncManager.gd
│   ├── ConflictResolver.gd
│   └── ReconnectHandler.gd
├── cloud_save/
│   ├── CloudSaveService.gd
│   ├── SaveUploadRequest.gd
│   ├── SaveDownloadRequest.gd
│   └── SaveConflictPolicy.gd
├── security/
│   ├── AntiCheatValidator.gd
│   ├── RateLimiter.gd
│   ├── IntegrityCheck.gd
│   └── ReplayProtection.gd
├── debug/
│   ├── NetworkInspector.tscn
│   └── NetworkDebugCommands.gd
└── tests/
    ├── test_command_serialization.gd
    ├── test_snapshot_diff.gd
    ├── test_conflict_resolution.gd
    ├── test_reconnect.gd
    └── test_cloud_save.gd
```

---

# Core Architecture

```text
UI
↓
Command
↓
GameService
↓
Validator
↓
Simulation
↓
State Changed
↓
Event Stream
↓
UI Update
```

UI never changes gameplay state directly.

---

# GameService Interface

All gameplay actions go through GameService.

Examples:

```text
accept_quest(command)
equip_item(command)
upgrade_building(command)
claim_reward(command)
buy_item(command)
sell_item(command)
start_boss_event(command)
```

LocalGameService executes locally.

RemoteGameService sends commands to server.

---

# Commands

All player actions should be commands.

A command must be:

```text
serializable
validatable
replayable
idempotent when required
timestamped
identified by command_id
```

---

# Command Data

Every command contains:

```text
command_id
command_type
player_id
session_id
timestamp
payload
client_version
schema_version
```

Never use Node references in commands.

Use IDs only.

---

# Command Examples

```text
AcceptQuestCommand
EquipItemCommand
UpgradeBuildingCommand
ClaimRewardCommand
BuyItemCommand
SellItemCommand
StartCraftCommand
CancelCraftCommand
JoinBossEventCommand
```

---

# Command Validation

Commands must validate:

```text
player owns entity
entity exists
resource available
cooldown valid
item valid
quest valid
building valid
reward not claimed
version compatible
```

Never trust client in online mode.

---

# Events

Gameplay emits events.

Events are facts.

Examples:

```text
hero_level_up
item_equipped
gold_spent
building_upgraded
quest_completed
boss_spawned
reward_claimed
save_uploaded
```

Events should be serializable.

---

# Event Stream

EventStream stores important state changes.

Uses:

```text
Replay
Debug
Telemetry
Network sync
Save reconstruction
```

Do not stream visual-only effects.

---

# Snapshot

Snapshot represents current game state.

Snapshot includes:

```text
world
town
heroes
buildings
inventory
economy
quests
events
statistics
```

Snapshot does not include:

```text
UI
Animation
Particles
Camera
Audio
Temporary VFX
```

---

# Snapshot Diff

For sync, send changed data only.

Diff includes:

```text
changed_entities
removed_entities
new_events
updated_resources
updated_progress
```

Avoid full snapshot every tick.

---

# Offline First

Offline mode must work fully.

Local save is primary for MVP.

Cloud sync is optional.

If server unavailable:

```text
continue offline
queue commands
sync later
resolve conflicts
```

---

# Cloud Save

Cloud save should support:

```text
upload
download
version
checksum
conflict detection
backup
restore
migration
```

---

# Conflict Resolution

When local and cloud saves conflict:

Policies:

```text
latest_timestamp
highest_progress
manual_choice
merge_if_safe
server_authority
```

Never silently overwrite valuable progress.

---

# Reconnect Flow

```text
Disconnected
↓
Queue commands
↓
Reconnect
↓
Authenticate
↓
Download server state
↓
Compare snapshot
↓
Resolve conflict
↓
Replay pending commands
↓
Resume
```

---

# Server Clock

Never trust client wall time for online rewards.

Use:

```text
server_time
monotonic_tick
signed_timestamp
```

Offline mode uses local GameTime but validates when syncing.

---

# Offline Progression

Offline rewards must be:

```text
capped
deterministic
validated
anti-cheat ready
```

Future server can recalculate offline progression.

---

# Multiplayer Ready Features

Design for:

```text
Guild
World Boss
Leaderboard
Market
Friend Visit
PvP Arena
Chat
Mail
Season Events
```

Do not implement all in MVP unless requested.

---

# World Boss Sync

World Boss requires:

```text
server boss state
participants
contribution
reward protection
timer
phase
```

Client displays state.

Server validates rewards.

---

# Market Sync

Market requires:

```text
listing_id
seller_id
item_id
price
tax
status
transaction_id
history
```

Never trust client inventory changes.

---

# PvP Sync

PvP should use:

```text
server validated teams
deterministic combat replay
rank update
reward protection
anti-cheat validation
```

---

# Guild Sync

Guild data includes:

```text
guild_id
members
roles
storage
donations
boss_progress
events
permissions
```

---

# Chat

Chat is separate from gameplay.

Never block gameplay on chat.

---

# Security

Online mode must protect:

```text
gold
premium currency
items
rewards
market
ranking
boss contribution
guild storage
save files
```

---

# Anti Cheat

Validate:

```text
unreasonable gold gain
impossible item count
invalid quest completion
offline time abuse
duplicate reward claim
modified save checksum
speed hack indicators
```

---

# Rate Limiting

Limit:

```text
commands per second
market actions
reward claims
save uploads
chat messages
boss join requests
```

---

# Idempotency

Important commands must be idempotent.

Example:

```text
ClaimRewardCommand
```

Calling twice must not duplicate reward.

---

# Replay Protection

Commands include:

```text
command_id
nonce
timestamp
signature future-ready
```

Reject duplicate command IDs.

---

# Serialization

Use stable schema.

Every network object has:

```text
schema_version
type
id
payload
```

Never serialize raw Nodes.

---

# Compression

Use compression for:

```text
save upload
snapshot sync
large event logs
```

---

# Telemetry

Track:

```text
connection_state
command_sent
command_failed
command_latency
snapshot_size
sync_duration
conflict_detected
cloud_save_upload
cloud_save_download
reconnect_success
reconnect_failed
anti_cheat_flag
```

---

# Debug Tools

Network inspector shows:

```text
mode
connection_state
latency
queued_commands
last_snapshot_version
sync_state
cloud_save_status
conflicts
server_time_offset
command_failures
```

Debug commands:

```text
simulate_disconnect
simulate_reconnect
force_cloud_upload
force_cloud_download
clear_command_queue
show_pending_commands
show_snapshot_diff
simulate_conflict
validate_save_integrity
```

---

# Tests

Generate tests for:

```text
command serialization
command validation
idempotency
snapshot serialization
snapshot diff
event stream replay
cloud save conflict
reconnect queue
reward duplication prevention
anti-cheat validation
```

---

# Required Test Cases

```text
GivenClaimRewardCommand_WhenExecutedTwice_ThenRewardGrantedOnce

GivenCommandSerialized_WhenDeserialized_ThenPayloadMatches

GivenLocalSaveNewerThanCloud_WhenConflictDetected_ThenConflictPolicyApplies

GivenDisconnected_WhenCommandSubmitted_ThenCommandQueued

GivenReconnect_WhenPendingCommandsExist_ThenCommandsReplaySafely

GivenModifiedSaveChecksum_WhenCloudUploadAttempted_ThenIntegrityCheckFails

GivenSnapshotDiff_WhenOnlyGoldChanges_ThenDiffContainsOnlyEconomyChange
```

---

# Performance

Network layer must not affect gameplay.

Rules:

```text
No blocking network calls on main thread
No full snapshot every frame
No JSON parsing in hot loops
No gameplay waiting for telemetry upload
No UI freeze during cloud save
```

---

# Documentation Output

Always include:

1. Network overview
2. Client-server boundary
3. Folder structure
4. Command model
5. Event model
6. Snapshot model
7. Cloud save model
8. Conflict resolution
9. Security rules
10. Telemetry
11. Debug tools
12. Tests
13. Future server roadmap

---

# Required Rules

Follow:

- architecture.md
- multiplayer.md
- save-system.md
- telemetry.md
- debug-tools.md
- testing.md
- performance.md
- economy.md
- events.md
- ai.md

Never violate project rules.

---

# AI Instructions

When building network-ready systems:

- Keep MVP offline-first.
- Use commands for gameplay actions.
- Use IDs, never Nodes.
- Keep gameplay serializable.
- Validate all commands.
- Protect rewards from duplication.
- Support cloud save later.
- Never block gameplay on network.
- Keep chat separate from gameplay.
- Design for future server authority.