# Character Asset Pipeline Rules

## Philosophy

A Hero's identity

and

a Hero's equipment

are two different things.

Identity

is drawn once.

Equipment

is drawn once

and reused

by every compatible Hero.

Never bake equipment

into a Hero's base art.

The economy loop

only works

if players can see

what they equipped.

---

# Four-Layer Model

Layer 1 — Base Body + Identity

Hair, face, build, skin tone.

Unique per Hero.

Layer 2 — Class Default Outfit

One per Class, seven total.

Shown when no Equipment is worn.

Reused by every Hero of that Class.

Layer 3 — Equipment Slot

Weapon, Armor/Chest, Helmet, Cloak.

Reused by every Hero compatible with that Class.

Layer 4 — Skin (cosmetic)

Optional, premium.

Overrides Layers 1-3 visually.

Never touches stats.

Never confuse Layer 4 with Layer 3.

Skin is cosmetic override.

Equipment is gameplay.

---

# Style Lock

Applies to every prompt generated from this file.

```text
Resolution      Character 32x48, Boss 64x64
Perspective     Top-down 3/4, pixel perfect
Rendering       No anti-alias, no blur, no gradient
Outline         1px, dark brown or navy, never pure black
Background      Dark navy, palette swatch box top-left
Layout          Full animation grid, identical to approved reference sheets
Reference lock  "consistent with mage-01/mage-02/mage-03/mage-04 reference style"
```

Every new Hero or Equipment prompt

must cite the Style Lock.

Never drift the palette or outline weight

sheet to sheet.

---

# Template A — Base Hero (Layer 1 + 2)

```text
Pixel art character reference sheet, [NAME], Class: [CLASS], Race: [RACE], Height: [HEIGHT]cm, Style: Pixel Art.
Hair: [HAIR_STYLE_COLOR]. Build: [BODY_BUILD]. Face: [FACE_FEATURES]. Skin tone: [SKIN_TONE].
Wearing plain default [CLASS] starter outfit only in neutral grey-brown tone (no unique weapon or armor
design -- generic/unbranded, meant to be layered later with separate equipment sprites), [ELEMENT_COLOR]
aura and effect accents on skill actions, dark navy background with palette swatch box top-left,
full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/
Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature
Actions: [CLASS_SIGNATURE_ACTIONS], Emotes: Think/Confused/Exclamation/Idle Pose/[CLASS_FLAVOR_EMOTE]/
Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row),
pixel perfect, no anti-alias, no blur, consistent with mage-01/mage-02/mage-03/mage-04 reference style,
weapon/armor kept generic so equipment can be swapped independently.
```

## Class Signature Actions + Flavor Emote

```text
Class      Signature Actions                                            Flavor Emote
Tank       Shield Bash, Taunt, Charge, Block Stance, Guardian Wall       Polish Shield
Warrior    Slash Combo, Charge, Whirlwind, Berserk Rage, Execute         Sharpen Blade
Assassin   Backstab, Shadow Step, Poison Blade, Vanish, Execute          Clean Dagger
Ranger     Rapid Shot, Multi-Shot, Snipe, Trap Set, Evasive Roll         Check Arrow
Mage       Fireball, Ice Spike, Lightning, Arcane Missile,               Read Book
           Arcane Explosion, Meteor, Magic Shield, Teleport
Support    Heal, Group Heal, Buff Aura, Cleanse, Revive                  Pray
Summoner   Summon Beast, Summon Spirit, Command Attack,                  Feed Pet
           Recall Pet, Empower Pet
```

## Race Visual Cue

```text
Race        Visual Cue
Human       none (baseline)
Elf         long pointed ears, slender frame
Orc         green-grey skin, protruding tusks, bulky frame
Dwarf       short, stocky, thick beard, broad shoulders
Undead      pale ashen skin, faint glowing eyes
Angel       small halo or folded wings
Demon       small horns, dark-tinted skin, red eyes
Dragonkin   light scale patches, small tail or curved horns
```

Race must stay readable at a glance.

Never rely on stat sheets alone to sell Race identity.

---

# Template B1 — Equipment: Weapon (Layer 3)

```text
Pixel art equipment sprite, [ITEM_NAME], Type: Weapon ([WEAPON_TYPE]), Rarity: [RARITY],
Style: Pixel Art matching [HERO_HEIGHT]cm hero rig from mage-01/mage-02/mage-03/mage-04 reference.
Standalone held-weapon sprite set, transparent background, drawn in poses matching base hero's
Idle/Walk/Attack1-3/Cast hand position, [RARITY_VISUAL_TREATMENT],
pixel perfect, no anti-alias, no blur, 1px outline consistent weight with base hero sheet,
no background scenery, no character body included -- weapon only.
```

# Template B2 — Equipment: Armor / Overlay (Layer 3)

```text
Pixel art equipment overlay sprite, [ITEM_NAME], Type: Armor ([SLOT: Chest/Helmet/Cloak]),
Rarity: [RARITY], Style: Pixel Art matching [HERO_HEIGHT]cm hero rig from reference sheets.
Overlay-only silhouette sized to sit exactly over base hero's [SLOT] region, transparent background,
drawn across same core frames as base hero (Idle/Walk/Run/Attack/Cast) at matching proportions,
[RARITY_VISUAL_TREATMENT], pixel perfect, no anti-alias, no blur, consistent outline weight,
no background scenery, no character body included -- overlay piece only.
```

## Rarity Visual Treatment

Matches the Rarity ladder in HERO.md (Common -> Elite -> Epic -> Legend -> Mythic).

```text
Rarity    Visual Treatment
Common    Plain iron-grey metal, no glow, no trim
Elite     Green-tinted metal, faint green outline glow
Epic      Blue-tinted metal with engraved trim, soft blue glow
Legend    Purple-gold trim, particle sparkle around edges
Mythic    Orange-red aura, animated flame/energy trail
```

Every item of the same Rarity

uses the same treatment.

Never let two Epic items

read as different tiers.

---

# Equipment Slot Limit

Maximum 4 visible slots.

Weapon,

Armor/Chest,

Helmet,

Cloak.

More slots break silhouette readability

and multiply z-order complexity per facing direction.

New slot types require updating this file first.

---

# Compatibility

Equipment must declare which Class(es) it fits,

matching the Equipment Compatibility table in HERO.md

(Knight: Sword/Shield/Heavy Armor,

Mage: Staff/Orb/Robe,

Assassin: Dagger/Dual Blade/Light Armor,

Archer: Bow/Crossbow/Leather Armor).

Never generate an item usable by every Class at once.

---

# Technical Note

AI image generation produces one flat sheet.

It does not separate layers on its own.

True frame-by-frame paperdoll needs a Skeleton2D rig

with Equipment sprites attached to bones.

That is the long-term path.

Until that rig exists, use the pragmatic path:

Weapon

↓

swap the held-weapon sprite only

Armor

↓

recolor/tint by Rarity, plus one small silhouette accessory

Never redraw a full armor set

for every Hero, every time.

---

# AI Instructions

When generating character or equipment assets:

- Never bake unique weapon or armor art into a Hero's Layer 1 sheet.
- Always generate new Heroes with Template A only.
- Always generate new Equipment with Template B1/B2, tagged to its compatible Class(es).
- Keep Rarity Visual Treatment identical across every item of the same tier.
- Reuse Class Default Outfit and Equipment sprites across every compatible Hero. Never duplicate them per Hero.
- Treat Skin (cosmetic) generation as a separate, later pipeline. Never conflate it with Equipment.
- Cite the Style Lock in every generation prompt.
