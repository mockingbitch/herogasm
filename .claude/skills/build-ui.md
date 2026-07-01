---
name: Build UI
description: Generate a complete pixel-art mobile-first UI system for Herogasm including HUD, panels, popups, view models, notifications, debug UI, tests, and performance rules.
---

# Skill: Build UI

## Goal

Build a clean, readable, mobile-first UI for a living-world idle RPG.

UI must support:

- Town management
- Hero monitoring
- Building interaction
- Inventory
- Quest
- Events
- Boss
- Economy
- Debug tools

The world must remain visible.

---

# UI Philosophy

UI supports gameplay.

UI does not replace the world.

The player should always see heroes moving, hunting, resting, shopping, and returning.

Avoid menu-heavy gameplay.

Prefer lightweight panels over full-screen blocking screens.

---

# Responsibilities

This skill generates:

- UI architecture
- HUD
- Top bar
- Bottom navigation
- Hero panel
- Building panel
- Inventory UI
- Quest UI
- Event UI
- Boss UI
- Notification system
- Tooltip system
- ViewModels
- UI signals
- UI pooling
- UI tests
- Debug UI
- Documentation

Never generate only one `HUD.gd`.

---

# Folder Structure

```text
ui/
├── UIManager.gd
├── UIState.gd
├── UIThemeData.gd
├── UIViewModel.gd
├── layers/
│   ├── GameHUD.tscn
│   ├── PopupLayer.tscn
│   ├── NotificationLayer.tscn
│   ├── TooltipLayer.tscn
│   ├── FullscreenLayer.tscn
│   └── DebugLayer.tscn
├── hud/
│   ├── TopBar.tscn
│   ├── BottomNav.tscn
│   ├── HeroStatusBar.tscn
│   ├── QuestTracker.tscn
│   ├── EventBanner.tscn
│   ├── MiniMap.tscn
│   └── GameSpeedControl.tscn
├── panels/
│   ├── HeroPanel.tscn
│   ├── BuildingPanel.tscn
│   ├── InventoryPanel.tscn
│   ├── QuestPanel.tscn
│   ├── MarketPanel.tscn
│   ├── BossPanel.tscn
│   ├── EventPanel.tscn
│   └── TownOverviewPanel.tscn
├── components/
│   ├── PixelButton.tscn
│   ├── PixelIcon.tscn
│   ├── ResourceCounter.tscn
│   ├── HeroListItem.tscn
│   ├── ItemSlot.tscn
│   ├── ProgressBarPixel.tscn
│   ├── StatRow.tscn
│   ├── Tooltip.tscn
│   └── ConfirmDialog.tscn
├── notifications/
│   ├── NotificationItem.tscn
│   ├── FloatingText.tscn
│   ├── RewardPopup.tscn
│   └── ToastManager.gd
├── viewmodels/
│   ├── HeroViewModel.gd
│   ├── BuildingViewModel.gd
│   ├── InventoryViewModel.gd
│   ├── QuestViewModel.gd
│   ├── EconomyViewModel.gd
│   └── EventViewModel.gd
├── debug/
│   ├── DebugOverlay.tscn
│   ├── DeveloperPanel.tscn
│   ├── EntityInspector.tscn
│   ├── AIInspector.tscn
│   └── PerformanceInspector.tscn
└── tests/
    ├── test_viewmodels.gd
    ├── test_ui_state.gd
    ├── test_inventory_ui_model.gd
    └── test_notification_queue.gd
```

---

# UI Architecture

```text
Gameplay State
↓
ViewModel
↓
UI Component
↓
Player Input
↓
Command
↓
Gameplay Service
```

UI reads state through ViewModels.

UI modifies gameplay only through Commands.

Never mutate gameplay state directly from UI.

---

# UI Layers

```text
CanvasLayer
├── HUD
├── PopupLayer
├── NotificationLayer
├── TooltipLayer
├── FullscreenLayer
└── DebugLayer
```

Layers must remain separate.

---

# HUD

HUD is always visible.

Contains:

```text
TopBar
HeroStatusBar
QuestTracker
EventBanner
MiniMap
GameSpeedControl
BottomNav
```

HUD must not cover more than 40% of the gameplay view.

---

# Top Bar

Top bar shows:

```text
Gold
Gem
Food
Wood
Stone
Ore
Population
Day
Weather
```

Use compact pixel icons.

Avoid long text.

---

# Bottom Navigation

Maximum 5 main buttons:

```text
Town
Heroes
Inventory
Quest
Menu
```

Avoid too many tabs.

---

# Panels

Panels should be:

```text
Side panel
Bottom sheet
Small popup
```

Avoid full-screen panels unless necessary.

World should remain visible behind panels.

---

# Hero Panel

Shows:

```text
Name
Class
Level
HP
MP
Mood
Needs
Current Goal
Current Location
Equipment
Inventory
Skills
Relationship
Recent Activity
```

Hero Panel is read-only except for allowed management commands.

---

# Building Panel

Shows:

```text
Name
Level
Service
Capacity
Queue
Upgrade Cost
Storage
Workers
Visitors
Revenue
Statistics
```

Actions:

```text
Upgrade
Assign Worker
Open Storage
View Queue
```

---

# Inventory Panel

Supports:

```text
Grid
Sort
Filter
Search
Compare
Equip
Sell
Lock
Favorite
Recycle
Batch Sell
```

Use virtualized lists for large inventories.

---

# Quest Panel

Shows:

```text
Available Quests
Active Quests
Completed Quests
Rewards
Recommended Hero
Difficulty
Target Zone
```

---

# Event UI

Shows:

```text
Event Banner
Countdown
Progress
Reward Preview
Participants
Contribution
Event Shop
```

Events must also change world visuals.

---

# Boss UI

Shows:

```text
Boss Health Bar
Phase
Timer
Participants
Contribution
Warning
Rewards
```

Boss UI must be readable and dramatic.

---

# Notifications

Notification types:

```text
Critical
Important
Normal
Low
Debug
```

Examples:

```text
Hero died
Boss spawned
Quest completed
Legendary drop
Building upgraded
Festival started
```

Never spam the player.

---

# Notification Priority

```text
Critical:
Hero death, town attack, boss spawn

Important:
Quest complete, building complete, legendary drop

Normal:
Level up, merchant arrived

Low:
Gold gained, common loot
```

---

# Tooltips

Tooltip contains:

```text
Name
Short description
Stats
Effect
Source
```

Never use long paragraphs.

---

# ViewModel Rules

ViewModels transform gameplay data into UI-ready data.

ViewModel may format:

```text
numbers
percentages
progress
status labels
icons
colors
```

ViewModel must not modify gameplay.

---

# UI Updates

UI updates only when state changes.

Never refresh entire UI every frame.

Use:

```text
signals
dirty flags
view model updates
```

---

# Lists

Long lists must use:

```text
virtual scrolling
item pooling
pagination
filtering
search
```

Especially:

```text
Hero list
Inventory
Market
Quest list
```

---

# Pixel Art UI

Use:

```text
Pixel perfect scaling
No blur
No anti-aliasing
Wood / stone / leather panels
Gold borders
Readable icons
Dark fantasy palette
```

---

# Fonts

Use pixel font.

Minimum readable size:

```text
14 px
```

Avoid tiny text on mobile.

---

# Buttons

Touch target minimum:

```text
48 px
```

Buttons must have states:

```text
normal
hover
pressed
disabled
selected
```

---

# Colors

Use semantic colors:

```text
Green = positive
Red = danger
Yellow = warning
Blue = info
Purple = rare
Orange = legendary
```

Never rely on color only.

---

# Animation

UI animations should be fast:

```text
150~300 ms
```

Avoid animations that delay gameplay.

---

# Popup Rules

Popup must support:

```text
close button
escape/back
outside click when safe
controller/touch
```

Confirmation required only for:

```text
delete
sell rare item
reset
spend premium currency
exit dangerous zone
```

---

# Floating Text

Use for:

```text
damage
heal
exp
gold
critical
level up
```

Floating text must use object pool.

Never instantiate repeatedly.

---

# Mini Map

Update rate:

```text
5 FPS
```

Shows:

```text
Hero
Boss
Town
Quest
Event
Merchant
Danger zone
```

Do not update every frame.

---

# Accessibility

Support:

```text
large text
reduced motion
colorblind friendly
high contrast
touch controls
```

---

# Performance

Target:

```text
60 FPS
large inventory
300 heroes
many notifications
mobile device
```

Rules:

```text
No full UI rebuild every tick
No per-frame list sorting
No repeated scene instantiation
No heavy string formatting in hot loops
Use pooled UI items
Use dirty flags
```

---

# UI Signals

UI may emit user intent signals:

```text
upgrade_requested(building_id)
equip_requested(hero_id, item_id)
sell_requested(item_id)
quest_accept_requested(quest_id)
reward_claim_requested(claim_id)
```

These signals become Commands.

UI does not execute gameplay directly.

---

# Telemetry

Track:

```text
panel_opened
panel_closed
button_clicked
item_sold
quest_accepted
building_upgrade_clicked
reward_claimed
popup_confirmed
popup_cancelled
ui_error
```

Do not track personal data.

---

# Debug UI

Developer UI includes:

```text
DebugOverlay
DeveloperPanel
EntityInspector
AIInspector
EconomyInspector
PerformanceInspector
SaveInspector
EventInspector
```

Debug UI must never ship enabled in release.

---

# Required Tests

Generate tests for:

```text
ViewModel formatting
UI state transitions
Notification priority
Inventory filtering
Reward popup data
Command creation
Panel open/close state
```

---

# Required Test Cases

```text
GivenGoldChanges_WhenEconomyViewModelUpdates_ThenTopBarShowsFormattedGold

GivenInventoryHasManyItems_WhenFilterRare_ThenOnlyRareItemsShown

GivenCriticalNotification_WhenQueueHasNormalNotifications_ThenCriticalDisplaysFirst

GivenUpgradeButtonPressed_WhenBuildingValid_ThenUpgradeCommandCreated

GivenHeroStateChanged_WhenHeroPanelOpen_ThenHeroPanelRefreshesWithoutFullRebuild
```

---

# Documentation Output

Always include:

1. UI overview
2. Folder structure
3. Layer architecture
4. HUD layout
5. Panel behavior
6. ViewModel design
7. Input command flow
8. Notification system
9. Pixel art UI rules
10. Performance notes
11. Debug UI
12. Tests

---

# Required Rules

Follow:

- ui.md
- pixel-art.md
- architecture.md
- coding-style.md
- gdscript.md
- signal-rules.md
- performance.md
- telemetry.md
- debug-tools.md
- testing.md

Never violate project rules.

---

# AI Instructions

When building UI:

- Keep the world visible.
- Use ViewModels.
- Never mutate gameplay directly.
- Use Commands for gameplay actions.
- Update only on state changes.
- Pool repeated UI elements.
- Optimize for mobile.
- Preserve pixel-perfect style.
- Include debug UI only for dev builds.