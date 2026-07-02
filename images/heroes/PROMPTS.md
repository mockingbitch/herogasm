# Herogasm - Hero Generation Prompts (hero-01 ... hero-10)

> Auto-generated theo **Template A** (Layer 1 Identity + Layer 2 Class Default Outfit) trong
> [.claude/rules/character-asset-pipeline.md](../../.claude/rules/character-asset-pipeline.md),
> lay du lieu tu [characters_manifest.json](characters_manifest.json).
> Moi prompt da qua 1 luot **adversarial verify** khop rule (allowed Class/Race, Class Signature Actions,
> Race Visual Cue, element color, Style Lock 32x48, tach Layer-3 equipment).
>
> **Cach dung:** copy nguyen khoi trong moi code block, dan vao cong cu sinh anh, kem anh
> mage-01/02/03/04.png lam reference phong cach. Luu output dung ten `images/heroes/<id>.png`.
>
> Day la **base sheet** - KHONG bake vu khi/giap; Equipment sinh rieng (Template B1/B2).

## hero-01 - Asha  |  Ranger / Elf  |  verified

```text
Pixel art character reference sheet, Asha, Class: Ranger, Race: Elf, Height: 169cm, Style: Pixel Art, character 32x48 pixels, top-down 3/4 perspective, pixel perfect. Hair: ash brown side braid. Build: slender, long-limbed with a lithe elven frame. Face: soft cheeks, sharp focused eyes, long pointed elven ears. Skin tone: warm fair. Wearing plain default Ranger starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), emerald green aura and effect accents on skill actions, 1px dark brown or navy outline never pure black, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Rapid Shot, Multi-Shot, Snipe, Trap Set, Evasive Roll, Emotes: Think/Confused/Exclamation/Idle Pose/Check Arrow/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect, no anti-alias, no blur, no gradient, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-02 - Borin  |  Tank / Dwarf  |  auto-fixed

```text
Pixel art character reference sheet, Borin, Class: Tank, Race: Dwarf, Height: 158cm, Style: Pixel Art. Hair: black short crop. Build: short, stocky, broad shoulders. Face: thick beard, determined brow. Skin tone: ruddy tan. Wearing plain default Tank starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), steel blue aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Shield Bash, Taunt, Charge, Block Stance, Guardian Wall, Emotes: Think/Confused/Exclamation/Idle Pose/Polish Shield/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), character 32x48 pixels, top-down 3/4 perspective, pixel perfect, no anti-alias, no blur, no gradient, 1px dark brown or navy outline never pure black, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

<details><summary>Verifier da sua</summary>

- Item 9 (data match) — Face field FAILS: draft reads "Face: thick beard, determined brow, classic dwarf features" but the hero data face is exactly "thick beard, determined brow". The appended "classic dwarf features" is invented prose not present in the source data. Fixed by restoring Face to exactly "thick beard, determined brow".
- Item 10 (Template A structure/wording) — Build field deviates: draft pads it with "unmistakably dwarven with a squat powerful frame" beyond the [BODY_BUILD] slot value "short, stocky, broad shoulders". Template A's Build/Face slots take the raw hero-data values (as the sibling mage prompts show), so this editorializing breaks template consistency. The Dwarf race cue (item 5: short, stocky, thick beard, broad shoulders) is already fully carried by the plain data, so the padding is redundant. Fixed by restoring Build to exactly "short, stocky, broad shoulders".
- Note (no change needed): items 1-8 pass. The Style Lock additions the draft made over bare Template A — "character 32x48 pixels, top-down 3/4 perspective, no gradient, 1px dark brown or navy outline never pure black" — are correct and required (item 8 needs 32x48), so they are preserved.

</details>

## hero-03 - Cyra  |  Mage / Human  |  verified

```text
Pixel art character reference sheet, Cyra, Class: Mage, Race: Human, Height: 166cm, Style: Pixel Art, character sprite 32x48 pixels, top-down 3/4 perspective. Hair: silver wavy bob. Build: average, agile, natural human proportions. Face: bright eyes, curious smile, ordinary human features. Skin tone: olive. Wearing plain default Mage starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), arcane purple aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Fireball, Ice Spike, Lightning, Arcane Missile, Arcane Explosion, Meteor, Magic Shield, Teleport, Emotes: Think/Confused/Exclamation/Idle Pose/Read Book/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), 1px dark brown or navy outline never pure black, pixel perfect, no anti-alias, no blur, no gradient, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-04 - Drevan  |  Warrior / Orc  |  verified

```text
Pixel art character reference sheet, Drevan, Class: Warrior, Race: Orc, Height: 179cm, Style: Pixel Art. Hair: dark green mohawk. Build: bulky, muscular heavy Orc frame with broad shoulders. Face: protruding lower tusks and a scar on cheek. Skin tone: green-grey. Wearing plain default Warrior starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), blood red aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Slash Combo, Charge, Whirlwind, Berserk Rage, Execute, Emotes: Think/Confused/Exclamation/Idle Pose/Sharpen Blade/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), 32x48 pixel character, top-down 3/4 perspective, 1px dark brown or navy outline never pure black, pixel perfect, no anti-alias, no blur, no gradient, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-05 - Elowen  |  Support / Angel  |  verified

```text
Pixel art character reference sheet, Elowen, Class: Support, Race: Angel, Height: 172cm, Style: Pixel Art, character 32x48 pixels, top-down 3/4 perspective. Hair: golden long straight. Build: tall, gentle posture with a small softly glowing golden halo hovering above the head and delicate folded feathered wings resting at the back. Face: calm smile, serene eyes with a faint angelic radiance. Skin tone: pale warm. Wearing plain default Support starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), sun gold aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Heal, Group Heal, Buff Aura, Cleanse, Revive, Emotes: Think/Confused/Exclamation/Idle Pose/Pray/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), 1px dark brown or navy outline never pure black, no gradient, pixel perfect, no anti-alias, no blur, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-06 - Fenn  |  Assassin / Undead  |  verified

```text
Pixel art character reference sheet, Fenn, Class: Assassin, Race: Undead, Height: 171cm, Style: Pixel Art, character 32x48 pixels, top-down 3/4 perspective, pixel perfect. Hair: white messy spikes. Build: lean, wiry, gaunt undead frame. Face: ashen skin, faint glowing eyes (undead visual cue). Skin tone: pale ashen. Wearing plain default Assassin starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), shadow violet aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Backstab, Shadow Step, Poison Blade, Vanish, Execute, Emotes: Think/Confused/Exclamation/Idle Pose/Clean Dagger/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect, no anti-alias, no blur, no gradient, 1px dark brown or navy outline never pure black, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-07 - Garrick  |  Tank / Human  |  verified

```text
Pixel art character reference sheet, Garrick, Class: Tank, Race: Human, Height: 177cm, Style: Pixel Art, character 32x48 pixels, top-down 3/4 perspective, pixel perfect. Hair: brown undercut. Build: broad, sturdy human frame with grounded ordinary human proportions. Face: square jaw, stern look, baseline human features with no non-human traits. Skin tone: tan. Wearing plain default Tank starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), steel blue aura and effect accents on skill actions, 1px dark brown or navy outline (never pure black), no gradient, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Shield Bash, Taunt, Charge, Block Stance, Guardian Wall, Emotes: Think/Confused/Exclamation/Idle Pose/Polish Shield/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect, no anti-alias, no blur, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-08 - Hikari  |  Ranger / Human  |  verified

```text
Pixel art character reference sheet, Hikari, Class: Ranger, Race: Human, Height: 165cm, Style: Pixel Art, character 32x48 pixels, top-down 3/4 perspective, pixel perfect with no anti-alias, no blur, no gradient, 1px dark brown or navy outline never pure black. Hair: black high ponytail. Build: athletic, compact human physique with natural human proportions. Face: confident grin on a light east-asian human face. Skin tone: light east-asian. Wearing plain default Ranger starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), forest green aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Rapid Shot, Multi-Shot, Snipe, Trap Set, Evasive Roll, Emotes: Think/Confused/Exclamation/Idle Pose/Check Arrow/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect, no anti-alias, no blur, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-09 - Ivo  |  Summoner / Dragonkin  |  verified

```text
Pixel art character reference sheet, Ivo, Class: Summoner, Race: Dragonkin, Height: 174cm, Style: Pixel Art, character sprite 32x48 pixels, top-down 3/4 perspective, pixel perfect. Hair: teal swept-back. Build: lean, poised, with a slender dragonkin frame carrying a small curved tail and subtle light scale patches along the forearms. Face: scale patches on cheeks, focused eyes, framed by small curved horns swept back over the hairline. Skin tone: warm tan. Wearing plain default Summoner starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), teal cyan aura and effect accents on skill actions, 1px dark brown or navy outline never pure black, no gradient, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Summon Beast, Summon Spirit, Command Attack, Recall Pet, Empower Pet, Emotes: Think/Confused/Exclamation/Idle Pose/Feed Pet/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), pixel perfect, no anti-alias, no blur, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```

## hero-10 - Juna  |  Mage / Elf  |  verified

```text
Pixel art character reference sheet, Juna, Class: Mage, Race: Elf, Height: 170cm, Style: Pixel Art, character 32x48 pixels, top-down 3/4 perspective, pixel perfect. Hair: lavender twin braids. Build: slender elven frame. Face: long pointed ears, calm eyes. Skin tone: fair. Wearing plain default Mage starter outfit only in neutral grey-brown tone (no unique weapon or armor design -- generic/unbranded, meant to be layered later with separate equipment sprites), arcane purple aura and effect accents on skill actions, dark navy background with palette swatch box top-left, full animation grid identical layout to reference (Basic Actions: Idle/Walk/Run/Dash/Backstep/Jump/Fall/Land, Combat Actions: Attack1-3/Cast or Skill Start-Loop-End/Damage(Hit)/Knockback/Get Up, Class Signature Actions: Fireball, Ice Spike, Lightning, Arcane Missile, Arcane Explosion, Meteor, Magic Shield, Teleport, Emotes: Think/Confused/Exclamation/Idle Pose/Read Book/Victory/Cheer/Sit/Sleep, Damage & Death: Hit/Heavy Hit/Knockdown/Get Up/Die/Dead, turn-around row), 1px dark brown or navy outline never pure black, pixel perfect, no anti-alias, no blur, no gradient, consistent with mage-01/mage-02/mage-03/mage-04 reference style, weapon/armor kept generic so equipment can be swapped independently.
```
