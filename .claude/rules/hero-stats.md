# Hero Stat Formula Rules

## Philosophy

No Hero stat

is ever

hand-typed.

Every number

must trace back

to Rank,

Class,

Race,

and Growth.

Same Rank

never means

same shape.

Same Class

never means

same power.

Race

reshapes.

Race

never inflates.

---

# Four-Layer Model

Rank

↓

decides total Power Budget

Class

↓

decides how that Budget is shaped

Race

↓

reshapes the Class shape, zero-sum

Growth Star

↓

decides how fast each stat rises per level

Each layer answers one question only.

Never merge layers.

Never skip a layer.

---

# Primary Stats

Budget is distributed across

HP

Attack

Defense

Magic Attack

Magic Defense

Secondary stats

(Speed, Critical Rate, Critical Damage, Accuracy, Evasion,

Lifesteal, Block, Skill Haste, Healing Bonus, Resistance, Penetration)

are never part of the Budget.

They come from Race Secondary Signature and Trait/Personality only.

---

# Rank Budget

Rank decides total Power Budget at Lv.1

and the Growth Budget added per level.

```text
Rank   Budget   Growth/Level (8% of Budget)   vs Rank D
S      290      23.2                          2.9x
A      220      17.6                          2.2x
B      170      13.6                          1.7x
C      130      10.4                          1.3x
D      100      8.0                           1.0x (baseline)
```

Gap between ranks stays ~30%.

Never let one Rank leap exponentially over the next.

---

# Stat Scale

Converts Budget Points into real stat values.

Global constant.

Never changes per Rank, Class, or Race.

```text
HP             x 8
Attack         x 1.2
Defense        x 1.0
Magic Attack   x 1.2
Magic Defense  x 1.0
```

---

# Class Weight

Percentage of Budget each Class allocates to each Primary stat.

Every row must sum to 100%.

```text
Class       HP   ATK   DEF   MAG   MDEF
Tank        34   13    32    6     15
Warrior     24   38    21    5     12
Assassin    20   50    8     7     15
Ranger      25   38    15    7     15
Mage        18   5     8     50    19
Support     28   5     17    32    18
Summoner    15   8     10    42    25
```

Every Class must keep at least one clear strength

and at least one clear weakness.

No Class may lead in every stat.

---

# Race Modifier

Percentage-point delta added on top of Class Weight.

Every row must sum to 0%.

Race reshapes.

Race never adds net power.

```text
Race         HP    ATK   DEF   MAG   MDEF
Human        0     0     0     0     0
Elf          -3    0     -2    +2    +3
Orc          +4    +3    0     -4    -3
Dwarf        -2    -3    +5    -3    +3
Undead       +3    +2    -2    +1    -4
Angel        -1    -4    -3    +5    +3
Demon        -2    +4    -3    +4    -3
Dragonkin    0     -4    -2    +3    +3
```

Human carries no delta.

Human is the neutral, beginner-friendly baseline.

---

# Race Secondary Signature

Flat bonus, outside the Budget system entirely.

This is where each Race's flavor text actually lives.

```text
Race         Secondary Signature
Human        (none)
Elf          Critical Rate, Speed
Orc          Accuracy, slight Evasion penalty
Dwarf        Block, Resistance
Undead       Lifesteal
Angel        Healing Bonus
Demon        Penetration
Dragonkin    Skill Haste, Resistance
```

Treat these like Personality/Trait bonuses.

Small.

Situational.

Never raw power.

---

# Growth Star

Per-Hero, per-stat multiplier on Growth/Level.

Already exists as the "Growth" field in HERO.md.

```text
Stars        Multiplier
1 star       0.6
2 stars      0.8
3 stars      1.0  (default)
4 stars      1.2
5 stars      1.4
```

Two Heroes with identical Rank, Class, and Race

still diverge over levels

if their Growth Star spread differs.

This is the last layer of individuality.

---

# Formulas

```text
FinalWeight(class, race, stat) = ClassWeight(class, stat) + RaceDelta(race, stat)

BaseStat(hero, stat)      = RankBudget(rank) x FinalWeight%(stat) x StatScale(stat)

GrowthUnit(rank)          = 8% x RankBudget(rank)

GrowthPerLevel(hero, stat) = GrowthUnit(rank) x FinalWeight%(stat) x StatScale(stat)
                             x GrowthStar(hero, stat)
```

---

# Validation Rules

Every ClassWeight row

must sum to exactly 100%.

Every RaceModifier row

must sum to exactly 0%.

If a FinalWeight value falls below a 1% floor,

clamp it to 1%

and redistribute the deficit proportionally

across the remaining stats

so the row still sums to 100%.

Reject any Rank/Class/Race data

that fails these checks

at load time.

Never patch it silently at runtime.

---

# Data Ownership

RankBudget

lives in

RankData resource.

ClassWeight

lives in

ClassWeightData resource.

RaceModifier and Secondary Signature

live in

RaceModifierData resource.

Growth Star

lives on

HeroData, per stat.

Never hardcode any of these tables

inside a script.

Never assign a raw stat number

directly to a Hero instance.

---

# Adding New Content

A new Rank

needs a full Budget + Growth/Level row.

A new Class

needs a full Class Weight row summing to 100%.

A new Race

needs a full Race Modifier row summing to 0%

plus a Secondary Signature.

Never add a partial row.

Never let a new Rank/Class/Race skip validation.

---

# Narrative Reference

docs/scripts/HERO.md

and

docs/scripts/BALANCE.md

hold the player-facing description of this system.

This file holds the enforceable formula.

Keep both in sync.

---

# AI Instructions

When creating or balancing a Hero:

- Never assign raw stats by hand. Always compute through Rank x Class x Race x Growth Star.
- Never let Race change total power. Race deltas must always sum to 0%.
- Never let a Class dominate every stat. Every Class keeps a clear weakness.
- Keep RankBudget, ClassWeight, and RaceModifier as Resources, never inline constants.
- Validate every new Rank/Class/Race row before accepting it.
- Update docs/scripts/HERO.md and docs/scripts/BALANCE.md whenever a table here changes.
