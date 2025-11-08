# Magic and Abilities System

## Overview
Complete magic and abilities system for the dungeon crawler, featuring spells, class abilities, mana management, and special powers.

## Features

### ✨ Spell System
- **Arcane Spells** (Wizard, Sorcerer)
- **Divine Spells** (Cleric, Paladin)
- **Mana-based casting**
- **Saving throws and resistances**
- **Area effects, buffs, and healing**

### 💪 Ability System
- **Class-specific abilities**
- **Level requirements**
- **Cooldowns and resource management**
- **Passive and active abilities**

## Spell List

### Arcane Spells

#### Level 1
**Magic Missile** (3 MP)
- Damage: 2d4+2
- Auto-hit (never misses)
- Single target
- Perfect for finishing weakened enemies

**Shield** (2 MP)
- +5 AC bonus
- Duration: 3 rounds
- Self-target
- Great defensive spell

**Detect Magic** (2 MP)
- Duration: 10 minutes
- Reveals magical auras
- Useful for finding hidden treasures

#### Level 3
**Fireball** (8 MP)
- Damage: 6d6
- Area effect
- DEX save DC 14 for half damage
- High damage, high cost

**Lightning Bolt** (7 MP)
- Damage: 8d6
- Line effect
- DEX save DC 14 for half damage
- Powerful single-target damage

**Haste** (6 MP)
- Duration: 5 rounds
- 2 attacks per round
- Significantly increases damage output

### Divine Spells

#### Level 1
**Cure Wounds** (3 MP)
- Healing: 2d8+3
- Self-target
- Reliable healing

**Bless** (3 MP)
- +2 to attack rolls and saves
- Duration: 5 rounds
- Versatile buff

#### Level 2
**Holy Smite** (5 MP)
- Damage: 3d8
- Bonus 2d8 vs undead
- Effective against evil creatures

**Turn Undead** (5 MP)
- Forces undead to flee
- WIS save DC 13
- Tactical crowd control

#### Level 3
**Prayer** (7 MP)
- +1 AC, +1 attack, +1 damage
- Duration: 5 rounds
- All-around combat buff

## Abilities List

### Fighter Abilities

**Second Wind** (Level 1)
- Healing: 1d10 + level
- 1 use per rest
- Emergency self-heal

**Power Attack** (Level 1)
- -2 to hit, +5 damage
- Voluntary trade-off
- High risk, high reward

**Action Surge** (Level 2)
- Extra action this turn
- 1 use per rest
- Burst damage potential

### Rogue Abilities

**Sneak Attack** (Level 1)
- Bonus damage: 2d6
- Requires advantage
- Core rogue mechanic

**Cunning Action** (Level 2)
- Bonus dash, disengage, or hide
- Always available
- Tactical mobility

**Evasion** (Level 7)
- No damage on successful DEX save
- Half damage on failed save
- Passive defensive ability

### Wizard Abilities

**Arcane Recovery** (Level 1)
- Recover mana equal to level/2
- 1 use per rest
- Mana sustainability

**Spell Mastery** (Level 5)
- One 1st-level spell free
- Passive ability
- Reduces mana pressure

### Cleric Abilities

**Channel Divinity** (Level 2)
- Special divine power
- 1 use per rest
- Versatile ability

**Divine Intervention** (Level 10)
- Success chance: level%
- Call upon deity
- Last resort power

## Usage

### Basic Spell Casting
```lua
local magic = require('magic')

-- Setup character
local wizard = {
    name = "Gandalf",
    class = "wizard",
    level = 3,
    mp = 25,
    max_mp = 25
}

-- Cast spell
local result = magic.cast_spell(wizard, "magic_missile")
if result.success then
    print("Damage dealt: " .. result.damage)
    print("Mana remaining: " .. wizard.mp)
end
```

### Spell with Saving Throw
```lua
local target = {dex = 2}  -- Target's DEX modifier
local result = magic.cast_spell(wizard, "fireball", target)

if result.success then
    print("Damage: " .. result.damage)
    -- Damage is halved if target makes save
end
```

### Using Abilities
```lua
local fighter = {
    name = "Conan",
    class = "fighter",
    level = 3
}

local result = magic.use_ability(fighter, "second_wind")
if result.success then
    print("Healed: " .. result.healing .. " HP")
end
```

### Get Available Spells
```lua
local spells = magic.get_available_spells(wizard)
for _, entry in ipairs(spells) do
    print(entry.spell.name)
end
```

### Get Available Abilities
```lua
local abilities = magic.get_available_abilities(fighter)
for _, entry in ipairs(abilities) do
    print(entry.ability.name)
end
```

## CLI Commands

```bash
# List all spells
lua magic.lua list

# List all abilities
lua magic.lua abilities

# Test magic system
lua magic.lua test
```

## Integration Example

### Combat with Magic
```lua
local magic = require('magic')
local dice = require('dice')

function combat_with_magic(player, enemy)
    -- Player can choose to attack or cast spell
    if player.mp >= 3 then
        -- Cast magic missile
        local result = magic.cast_spell(player, "magic_missile")
        if result.success then
            enemy.hp = enemy.hp - result.damage
            print("Magic Missile hits for " .. result.damage .. " damage!")
        end
    else
        -- Normal attack
        local attack = dice.roll("d20") + player.atk
        if attack >= enemy.ac then
            local damage = dice.roll("d6+2")
            enemy.hp = enemy.hp - damage
            print("Physical attack for " .. damage .. " damage!")
        end
    end
end
```

### Buff Management
```lua
-- Cast shield before combat
local result = magic.cast_spell(wizard, "shield")
if result.success then
    wizard.ac = wizard.ac + result.ac_bonus
    wizard.shield_rounds = result.duration
end

-- During combat, decrease duration
wizard.shield_rounds = wizard.shield_rounds - 1
if wizard.shield_rounds <= 0 then
    wizard.ac = wizard.ac - 5  -- Remove bonus
end
```

## Mana System

### Mana Calculation
```
Base Mana = 5 + (INT × 2)

Example:
INT 10: 5 + (10 × 2) = 25 MP
INT 14: 5 + (14 × 2) = 33 MP
INT 18: 5 + (18 × 2) = 41 MP
```

### Mana Recovery
- **Long Rest**: Full recovery
- **Short Rest**: Arcane Recovery ability (Wizards only)
- **Potions**: Mana potion restores 2d6+2 MP

## Spell Slots (Alternative System)

For classic D&D-style spell slots instead of mana:

```lua
-- Spell slots by level
local slots = {
    [1] = {1st = 2},
    [2] = {1st = 3},
    [3] = {1st = 4, 2nd = 2},
    [4] = {1st = 4, 2nd = 3},
    [5] = {1st = 4, 2nd = 3, 3rd = 2}
}
```

## Balancing

### Spell Costs
- **Level 1**: 2-3 MP (Basic utility and combat)
- **Level 2**: 4-5 MP (Moderate power)
- **Level 3**: 6-8 MP (High impact)

### Damage Guidelines
- **Level 1**: 2d4 to 2d8 (avg 5-9)
- **Level 2**: 3d6 to 3d8 (avg 10-13)
- **Level 3**: 6d6 to 8d6 (avg 21-28)

### Healing Guidelines
- **Level 1**: 2d8+3 (avg 12)
- **Level 2**: 3d8+3 (avg 16)
- **Level 3**: 4d8+4 (avg 22)

## Testing

Run unit tests:
```bash
lua test_magic.lua
```

**Coverage**: 19 tests
- Spell casting mechanics
- Mana management
- Ability usage
- Class/level requirements
- Edge cases

## Files

- `magic.lua` - Core magic system (450 lines)
- `test_magic.lua` - Unit tests (200 lines)
- `MAGIC_ABILITIES.md` - This documentation

## Future Enhancements

- [ ] More spells (illusion, enchantment, necromancy)
- [ ] Spell upgrade system
- [ ] Metamagic (empower, extend, quicken)
- [ ] Ritual casting
- [ ] Concentration mechanics
- [ ] Spell combinations
- [ ] Custom spell creation
- [ ] Magic items that enhance spells
- [ ] Counterspell mechanics
- [ ] Elemental resistances

## Tips

**For Wizards:**
- Save high-cost spells for tough fights
- Use Magic Missile to finish weak enemies (never misses)
- Shield is excellent value at 2 MP

**For Clerics:**
- Cure Wounds is your bread and butter
- Bless before big fights (+2 to everything)
- Save Turn Undead for undead encounters

**For Fighters:**
- Second Wind is a free heal - use it!
- Power Attack on low-AC enemies
- Action Surge for burst damage

**For Rogues:**
- Sneak Attack is your main damage source
- Cunning Action for hit-and-run tactics
- Save Evasion for traps and area spells

## Examples

### Wizard Combat Rotation
1. Start: Cast Shield (+5 AC for 3 rounds)
2. Turn 1: Magic Missile (guaranteed damage)
3. Turn 2: If multiple enemies, Fireball
4. Turn 3: Lightning Bolt on tough enemy
5. Low mana: Physical attacks

### Cleric Support
1. Pre-combat: Bless (+2 to hit/saves)
2. Combat: Holy Smite on enemies
3. Low HP: Cure Wounds
4. Undead: Turn Undead

### Fighter Tactics
1. Standard: Normal attacks
2. High-value target: Power Attack
3. Low HP: Second Wind
4. Boss fight: Action Surge for double attacks
