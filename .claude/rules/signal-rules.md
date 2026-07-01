# Signal Rules

## Philosophy

Signals are used to notify.

Signals are NOT used to execute business logic.

Emit events.

Do not control systems.

---

# General Rules

Prefer

Signals

↓

EventBus

↓

Direct method calls

Avoid

Deep NodePath

Global lookups

Polling

---

# Signal Direction

Allowed

Component

↓

Owner

Owner

↓

Manager

Manager

↓

UI

Forbidden

UI

↓

Gameplay

Gameplay must never depend on UI.

---

# Signal Naming

Use past tense.

Good

health_changed

hero_died

monster_killed

item_equipped

item_added

quest_completed

building_upgraded

gold_changed

Avoid

on_click

attack

update

refresh

event

---

# Signal Declaration

Always declare at top.

signal hero_died(hero)

signal hp_changed(current_hp)

signal inventory_changed()

Typed arguments whenever possible.

---

# Emit

Emit only when state changes.

Good

hp -= damage

hp_changed.emit(hp)

Bad

hp_changed.emit()

every frame

---

# Frequency

Never emit signals every frame.

Signals should represent meaningful events.

Good

Hero reached destination

Monster died

Quest completed

Bad

Current HP

Current Position

Current FPS

every frame

---

# Ownership

The object that owns the data

must emit the signal.

Hero emits

health_changed

Inventory emits

item_added

Quest emits

completed

Never let unrelated systems emit signals.

---

# Signal Scope

Local signal

Inside scene

Global signal

EventBus only

Avoid global signals unless multiple systems need them.

---

# EventBus Usage

Use EventBus only for

Boss Spawn

Festival

World Event

Hero Death

Town Attack

Economy Changed

Do not send every event through EventBus.

---

# Connections

Connect once.

Usually inside

_ready()

Never reconnect repeatedly.

---

# Disconnect

Disconnect when needed.

Especially

temporary UI

temporary dialogs

temporary effects

Avoid dangling connections.

---

# UI

UI listens.

Gameplay emits.

Correct

Hero

↓

health_changed

↓

HealthBar

Wrong

HealthBar

↓

Hero

---

# Components

Components notify owner.

MovementComponent

↓

arrived

CombatComponent

↓

target_killed

InventoryComponent

↓

item_added

Owner coordinates gameplay.

---

# Chaining

Avoid long chains.

Bad

Hero

↓

Town

↓

GameManager

↓

UIManager

↓

Popup

↓

Inventory

↓

Quest

Good

Hero

↓

EventBus

↓

Interested systems

---

# Payload

Send useful data.

Good

signal hero_died(hero)

signal gold_changed(old_value, new_value)

Avoid

signal changed()

without context.

---

# Arguments

Prefer object references

or IDs.

Avoid sending entire collections.

Good

item_added(item)

Bad

inventory_updated(all_items)

---

# Request vs Notification

Signals notify.

Methods request.

Correct

hero.attack(target)

↓

target_died.emit()

Wrong

hero.attack_requested.emit()

---

# Bidirectional Communication

Avoid circular signals.

Hero

↓

Inventory

↓

Hero

Bad.

---

# Anonymous Callbacks

Avoid large lambdas.

Extract methods.

Good

button.pressed.connect(_on_buy_pressed)

Avoid

button.pressed.connect(func():
    ...
)

---

# UI Connections

UI connects

when opened.

Disconnect

when closed.

---

# Scene Communication

Scenes never know each other.

Communication

↓

Signal

↓

EventBus

↓

Service

Never

../../Town/UI/...

---

# EventBus Events

Examples

hero_spawned

hero_died

monster_spawned

monster_killed

boss_spawned

boss_defeated

festival_started

festival_ended

town_under_attack

weather_changed

economy_updated

---

# Don't Abuse Signals

Don't emit for

getter

setter

constant polling

animation frame

movement update

mouse hover

unless required.

---

# Performance

Signals are lightweight.

Still avoid

thousands of emissions per second.

For high-frequency systems

use direct method calls.

---

# Debugging

Every global event

should support logging.

Example

[EventBus]

HeroDied

Hero ID

Location

Time

---

# AI Instructions

When generating code:

- Prefer signals over polling.
- Connect signals once.
- Emit only on state changes.
- Use descriptive past-tense names.
- Avoid signal chains.
- Keep gameplay independent from UI.
- Use EventBus only for cross-system communication.
- Include typed arguments.
- Never emit signals every frame.