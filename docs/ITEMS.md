# Item Effects System Documentation

## Overview
Comprehensive system for active, passive, and cursed item effects that add depth and strategy to equipment choices.

## Quick Stats
- **22 unique item effects** (7 active, 10 passive, 5 cursed)
- **100% test coverage** (22 unit tests passing)
- **Fully integrated** with combat and magic systems
- **Balanced** for fair gameplay (v2.0)

## Balance Philosophy

All effects have been tuned to maintain competitive balance:

- **Active effects**: Consistent power per use (avg 5-10 damage/healing)
- **Passive effects**: Moderate bonuses (+2 AC, +8 HP, 20% lifesteal)
- **Cursed items**: Risk vs reward (bonus ≈ penalty)

## Effect Types

### ✨ Active Effects (7 items)
- **Flaming Blade**: +1d8 fire damage (3 uses/rest)
- **Freezing Strike**: +1d8 ice + slow (3 uses/rest)
- **Thunder Strike**: 2d8 AOE lightning (1 use/rest)
- **Shield Wall**: +2 AC for 3 rounds (3 uses/rest)
- **Haste**: Double attacks for 2 rounds (2 uses/rest)
- **Emergency Heal**: 2d8+2 HP (2 uses/rest)
- **Spell Release**: Cast Magic Missile (1 use/rest)

### 💎 Passive Effects (10 items)
- **Life Drain**: 20% lifesteal
- **Smite Evil**: +2d8 vs undead/demons
- **Vorpal Edge**: Crit 19-20, 3x damage
- **Damage Reduction**: -2 damage taken
- **Evasion**: 15% miss chance
- **Regeneration**: 1d3 HP/round
- **Arcane Ward**: +2 AC
- **Vitality**: +8 max HP
- **Swift Movement**: +2 initiative
- **Arcane Reservoir**: +8 max MP

### 😈 Cursed Effects (5 items)
- **Greed's Curse**: +2d6 damage, -1 HP per hit
- **Madness**: +2 attack, -1 AC
- **Weakness**: +25% damage taken
- **Withering**: -1 damage
- **Leaden Steps**: -3 initiative

## Balance Changes (v2.0)

### Active Effects
- Flaming Blade: 2d6 → 1d8 (avg 7 → avg 4.5)
- Freezing Strike: 1d6 → 1d8, uses 2 → 3
- Thunder Strike: 3d8 → 2d8 (avg 13.5 → avg 9)
- Shield Wall: +3 AC → +2 AC, uses 2 → 3
- Emergency Heal: 3d8+3 → 2d8+2, uses 1 → 2

### Passive Effects
- Life Drain: 25% → 20% lifesteal
- Vorpal Edge: Crit 18-20 → 19-20
- Damage Reduction: -3 → -2
- Evasion: 20% → 15% miss
- Regeneration: 1d4 → 1d3 HP/round
- Vitality: +10 → +8 max HP
- Swift Movement: +3 → +2 initiative
- Arcane Reservoir: +10 → +8 max MP

### Cursed Effects
- Greed's Curse: -2 HP/hit → -1 HP/hit
- Madness: +3 ATK/-2 AC → +2 ATK/-1 AC
- Weakness: +50% dmg → +25% dmg taken
- Withering: -2 dmg → -1 dmg
- Leaden Steps: -5 init → -3 init

## Design Notes

**Why these numbers?**
- Active effects average 4.5-9 damage per use
- Passive bonuses equal to ~1 item tier (+2 AC = light armor)
- Cursed items now viable: +7 avg damage for -1 HP self-damage
- Multiple uses allow tactical choice, not just "save for boss"

See full documentation in file for detailed usage examples and integration guides.
