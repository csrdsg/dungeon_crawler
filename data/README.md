# Data Directory

This directory contains all modifiable game data separated from the game logic. This allows for easy customization, modding, and balance changes without touching the core code.

## Files

### `abilities.lua`
Character class abilities (Fighter, Rogue, Wizard, Cleric)
- Special powers and skills
- Cooldowns and usage limits
- Level requirements
- Healing, damage, and buff effects

**Example modifications:**
- Change healing amounts
- Add new class abilities
- Adjust cooldowns or uses per rest
- Modify level requirements

### `chamber_art.lua`
ASCII art for the 10 different chamber types
- Empty room, Treasure room, Monster lair, etc.

**Example modifications:**
- Replace ASCII art with custom designs
- Add new chamber type artwork
- Create themed dungeon sets

### `encounters.lua`
Encounter tables and chances
- Friendly encounters (merchants, helpers)
- Neutral encounters (traders, wanderers)
- Hostile encounters (monsters, bosses)
- Encounter chances per chamber type
- Disposition weights

**Example modifications:**
- Add new monster types
- Adjust encounter rates
- Change difficulty scaling by dungeon level
- Add unique boss encounters

### `loot_tables.lua`
Treasure generation tables
- Quality tiers: poor, common, uncommon, rare, legendary
- Gold ranges per tier
- Item lists per tier
- Chamber-specific loot quality mappings

**Example modifications:**
- Add new items
- Adjust gold amounts
- Change item rarities
- Add themed loot sets

### `quests.lua`
Campaign quest definitions
- Main story quests
- Side quests
- Optional quests
- Quest objectives and rewards

**Example modifications:**
- Create new quest lines
- Adjust rewards
- Add branching storylines
- Create themed campaigns

### `rest_config.lua`
Rest system configuration
- Short rest: duration, healing, encounter chance
- Long rest: duration, full heal, ration cost, encounter chance

**Example modifications:**
- Adjust healing amounts
- Change encounter probabilities
- Modify rest durations
- Add new rest types (e.g., meditation)

### `spells.lua`
Magic spell database
- Arcane spells (Wizard)
- Divine spells (Cleric)
- Mana costs, damage, healing
- Save DCs and durations

**Example modifications:**
- Add new spells
- Balance mana costs
- Adjust damage/healing values
- Create new spell schools

### `trap_types.lua`
Trap definitions
- Trap names and damage
- Difficulty checks (DC)
- Ability type (DEX, STR, INT, etc.)

**Example modifications:**
- Add new trap types
- Adjust damage values
- Change difficulty checks
- Add special trap effects

## Modding Guide

### How to Modify Data

1. **Backup the original file** before making changes
2. **Edit the Lua table** with your changes
3. **Test your changes** by running the game
4. **Share your mod** by distributing the modified data file

### File Format

All data files are Lua tables that return a data structure:

```lua
return {
    key = value,
    nested = {
        data = "here"
    }
}
```

### Example: Adding a New Spell

Edit `spells.lua`:

```lua
ice_storm = {
    name = "Ice Storm",
    type = "arcane",
    level = 4,
    mana_cost = 10,
    damage = "8d8",
    description = "Freezing hail and ice",
    save_dc = 16,
    save_type = "DEX",
    target = "area"
},
```

### Example: Adding a New Monster

Edit `encounters.lua`:

```lua
-- In hostile_encounters array:
{name = "Shadow Demon", type = "demon", desc = "Creature of pure darkness", 
 level_range = {4, 6}, min_dungeon_level = 5},
```

### Example: Creating Custom Loot

Edit `loot_tables.lua`:

```lua
epic = {
    gold = {min = 5000, max = 10000},
    items = {
        "Legendary Sword +3 (5000gp)",
        "Dragon Scale Armor (8000gp)",
        -- Add more items
    }
}
```

## Balance Testing

After modifying data files:

1. Test with different character levels
2. Check if gold/XP gains are reasonable
3. Verify difficulty curve is appropriate
4. Ensure no game-breaking combinations

## Contributing

If you create interesting mods or balance improvements:
1. Document your changes
2. Share the modified data file
3. Explain the reasoning behind changes
4. Test thoroughly before sharing

## Version Compatibility

Data files are designed to be forward-compatible. When updating the game:
- Back up your custom data files
- Compare with new default data files
- Merge your changes if needed
- Test after updates

## Technical Details

Data files are loaded using Lua's `dofile()` function at runtime. The source files automatically detect the data directory relative to their location:

```lua
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"
local data = dofile(data_dir .. "filename.lua")
```

This allows the game to work whether run from the root directory or from within the src/ directory.
