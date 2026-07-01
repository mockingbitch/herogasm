# Unit Testing Rules

## Philosophy

Unit tests verify pure gameplay logic.

Unit tests should be:

- Fast
- Deterministic
- Isolated
- Repeatable
- UI-free

Never depend on rendering.

Never depend on scenes unless required.

---

# What To Unit Test

Always test:

- Damage formulas
- Critical chance
- Armor reduction
- Healing
- EXP formula
- Level up
- Loot tables
- Drop rates
- Inventory logic
- Equipment stats
- Crafting cost
- Upgrade cost
- Repair cost
- Quest progress
- Economy transactions
- Offline reward calculation
- Relationship changes
- Mood changes
- Need decay
- AI decision scoring

---

# What Not To Unit Test

Do not unit test:

- Pixel-perfect UI
- Animation frames
- Visual effects
- Camera shake
- Particle effects
- Audio playback
- Godot editor setup
- Asset import settings

These belong to manual, visual, or integration tests.

---

# Test Scope

Each unit test should test one behavior.

Bad:

Test hero combat, loot, quest, inventory together.

Good:

Test damage calculation only.

---

# Test Naming

Use Given / When / Then.

Example:

```text
GivenHeroHasLowHp_WhenPotionAvailable_ThenHeroChoosesDrinkPotion
```

---

# Determinism

All tests must be deterministic.

Randomness must use seeded RandomService.

Never call:

```gdscript
randf()
randi()
randomize()
```

directly inside tests.

---

# Test Data

Use small test fixtures.

Avoid huge real game data.

Good:

```text
TestSword
TestGoblin
TestHeroLevel1
TestPotionSmall
```

Bad:

```text
FullProductionDatabase
```

---

# Pure Logic First

Prefer testing pure classes and Resources.

Good:

```text
DamageCalculator
LootRoller
LevelFormula
InventoryModel
EconomyTransaction
QuestProgress
```

Avoid testing large Node scenes directly.

---

# Godot Nodes

If a Node is required, keep it minimal.

Do not load the whole world.

Do not instantiate Town.tscn for a unit test.

---

# Assertions

Every test must assert expected result.

Bad:

```gdscript
calculator.calculate_damage(hero, monster)
```

Good:

```gdscript
assert_eq(result.damage, 25)
```

---

# Floating Point

Use approximate assertions.

Example:

```gdscript
assert_almost_eq(actual, expected, 0.001)
```

Never compare floats directly.

---

# Edge Cases

Always test edge cases.

Examples:

- HP below zero
- Zero damage
- Negative values
- Empty inventory
- Full inventory
- Missing item
- Invalid ID
- Level max
- Drop rate 0%
- Drop rate 100%
- Quest already completed
- Equipment broken
- Offline time 0 seconds
- Offline time above cap

---

# Boundary Tests

For formulas, test boundaries.

Examples:

- Level 1
- Level 2
- Max level
- Min attack
- Max armor
- Crit chance 0%
- Crit chance 100%

---

# Economy Tests

Every economy transaction must verify:

- Source balance reduced
- Target balance increased
- Cost applied correctly
- Transaction cannot go negative
- Invalid transaction is rejected
- Currency type is correct

---

# Inventory Tests

Inventory tests must verify:

- Add item
- Remove item
- Stack item
- Split stack
- Full inventory
- Equip item
- Unequip item
- Sell item
- Lock item
- Favorite item

---

# Combat Tests

Combat tests must verify:

- Damage
- Armor
- Critical
- Dodge
- Healing
- Death
- Status effect
- Cooldown
- Skill cost
- Target validity

---

# Loot Tests

Loot tests must verify:

- Valid item IDs
- Drop table weight
- Guaranteed drops
- Rare drops
- Empty table
- Seeded result
- No invalid items

For probability tests, use large samples.

---

# AI Unit Tests

AI tests should verify decision logic only.

Examples:

- Low HP chooses retreat
- Broken weapon chooses repair
- Full inventory chooses return town
- Hungry hero chooses eat
- Quest target has priority
- Coward hero avoids high danger zone
- Greedy hero prefers high reward zone

Do not test pathfinding here.

---

# Quest Tests

Quest tests must verify:

- Accept quest
- Kill count progress
- Collect item progress
- Complete quest
- Claim reward
- Prevent duplicate reward
- Expired quest
- Invalid target

---

# Offline Progression Tests

Test:

- 0 seconds offline
- 1 minute offline
- 1 hour offline
- Above offline cap
- Low HP during offline
- Inventory full during offline
- No stamina during offline
- Event active during offline

---

# Save Data Unit Tests

Test serializers using data only.

Verify:

- Serialize
- Deserialize
- Version
- Missing fields
- Invalid values
- Migration
- Round trip equality

Never serialize Nodes.

---

# Test Isolation

Tests must not depend on execution order.

Every test creates its own data.

Never share mutable state.

---

# Cleanup

Every test must clean up temporary data.

No persistent files unless testing save logic.

---

# Performance

Unit tests should be fast.

Target:

- Single test < 10 ms
- Full unit suite < 10 seconds

---

# Regression Tests

Every fixed bug must add a test.

Bug format:

```text
Bug:
Hero stayed in combat after monster died.

Regression Test:
GivenMonsterDies_WhenHeroTargetInvalid_ThenHeroClearsTarget
```

---

# CI Requirements

CI must run:

- Unit tests
- Data validation tests
- Formula tests
- Save serialization tests

Fail CI on any broken test.

---

# AI Instructions

When generating unit tests:

- Test pure logic first.
- Avoid loading scenes.
- Use deterministic seeded randomness.
- Include edge cases.
- Use Given / When / Then names.
- Add regression tests for bugs.
- Never test visual-only behavior.
- Keep tests fast and isolated.