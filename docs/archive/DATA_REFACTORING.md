# Data Separation Refactoring

## Overview

This refactoring separated hard-coded game content from the game logic code. All game data (monsters, items, spells, traps, etc.) has been moved to dedicated data files in the `/data` directory.

## What Was Refactored

### Files Created in `/data` Directory

1. **`abilities.lua`** - Character class abilities
   - Fighter, Rogue, Wizard, Cleric abilities
   - Healing, damage, buffs, and special powers
   - Cooldowns and usage limits

2. **`chamber_art.lua`** - ASCII art for chamber types
   - All 10 chamber type visuals
   - Easy to customize dungeon appearance

3. **`encounters.lua`** - Encounter tables
   - Friendly, neutral, and hostile encounters
   - Monster types and difficulty scaling
   - Encounter chances and disposition weights

4. **`loot_tables.lua`** - Treasure generation
   - 5 quality tiers (poor to legendary)
   - Items, gold ranges, gems
   - Chamber-specific loot mappings

5. **`rest_config.lua`** - Rest system configuration
   - Short rest and long rest settings
   - Healing amounts and encounter chances

6. **`spells.lua`** - Magic spell database
   - Arcane spells (Wizard)
   - Divine spells (Cleric)
   - Costs, damage, healing, durations

7. **`trap_types.lua`** - Trap definitions
   - 10 different trap types
   - Damage, DCs, ability checks

### Modified Source Files in `/src` Directory

All source files were updated to load data from external files:

- **`src/abilities.lua`** → loads from `data/abilities.lua`
- **`src/chamber_art.lua`** → loads from `data/chamber_art.lua`
- **`src/encounter_gen.lua`** → loads from `data/encounters.lua`
- **`src/loot.lua`** → loads from `data/loot_tables.lua`
- **`src/magic.lua`** → loads from `data/spells.lua` and `data/abilities.lua`
- **`src/rest.lua`** → loads from `data/rest_config.lua`
- **`src/traps.lua`** → loads from `data/trap_types.lua`

## Benefits

### 1. **Easy Modding**
   - Players can modify game content without touching code
   - Create custom campaigns by swapping data files
   - Share mods easily

### 2. **Balance Changes**
   - Adjust numbers without risking code bugs
   - Quick iteration on game balance
   - A/B test different configurations

### 3. **Content Expansion**
   - Add new items, spells, monsters easily
   - Create themed content packs
   - Build expansion content

### 4. **Code Maintainability**
   - Logic separated from data
   - Smaller, cleaner code files
   - Easier to understand and debug

### 5. **Collaboration**
   - Game designers can edit data
   - Programmers focus on logic
   - No merge conflicts between data and code

## Technical Implementation

### Data Loading Pattern

Each source file uses this pattern to load data:

```lua
-- Detect script location
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")

-- Calculate data directory path
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"

-- Load data file
local data = dofile(data_dir .. "filename.lua")
```

This works whether the script is run from:
- Root directory: `lua src/script.lua`
- Src directory: `cd src && lua script.lua`

### Data File Format

All data files return a Lua table:

```lua
return {
    key = value,
    nested_table = {
        item1 = "value",
        item2 = "value"
    }
}
```

## Usage Examples

### Modifying Loot Tables

Edit `/data/loot_tables.lua`:

```lua
rare = {
    gold = {min = 500, max = 2000},  -- Increased gold
    items = {
        "Magic Sword +2 (750gp)",  -- Changed from +1
        -- Add new items here
    }
}
```

### Adding New Spells

Edit `/data/spells.lua`:

```lua
meteor_swarm = {
    name = "Meteor Swarm",
    type = "arcane",
    level = 9,
    mana_cost = 20,
    damage = "20d6",
    description = "Devastating cosmic bombardment",
    save_dc = 18,
    save_type = "DEX",
    target = "area"
}
```

### Creating New Monsters

Edit `/data/encounters.lua`:

```lua
-- In hostile_encounters array:
{
    name = "Beholder", 
    type = "aberration", 
    desc = "Many-eyed floating terror", 
    level_range = {8, 10}, 
    min_dungeon_level = 7
}
```

### Adjusting Difficulty

Edit `/data/rest_config.lua`:

```lua
short_rest = {
    name = "Short Rest",
    duration = "15 minutes",
    healing_dice = "2d6+2",  -- Increased healing
    encounter_chance = 20,    -- Reduced from 40%
    description = "You take a moment to catch your breath..."
}
```

## Testing

All refactored systems have been tested:

✅ Loot generation works correctly
✅ Trap system loads trap types
✅ Encounter generation functions properly
✅ Magic system loads spells and abilities
✅ Rest system uses configuration data
✅ Chamber art displays correctly

## Backward Compatibility

The external interface of all modules remains the same. Existing code that uses these modules doesn't need to change.

## Future Enhancements

Potential future improvements:

1. **JSON/YAML Support** - For easier editing by non-programmers
2. **Hot Reloading** - Change data files without restarting
3. **Data Validation** - Check data files for errors on load
4. **Mod Manager** - System to enable/disable different data packs
5. **Campaign Editor** - GUI tool to edit data files
6. **Data Versioning** - Track changes to data files
7. **Import/Export** - Convert between formats

## Documentation

- **`/data/README.md`** - Comprehensive modding guide
- Inline comments in data files
- Example modifications documented

## Migration Notes

For developers integrating these changes:

1. Update any code that directly accessed hard-coded tables
2. Test with custom data files
3. Document any new data file fields added
4. Maintain backward compatibility with old save files

## Performance

Data files are loaded once at module initialization. No performance impact during gameplay.

## File Organization

```
dungeon_crawler/
├── data/              # Game content data
│   ├── README.md      # Modding documentation
│   ├── abilities.lua
│   ├── chamber_art.lua
│   ├── encounters.lua
│   ├── loot_tables.lua
│   ├── rest_config.lua
│   ├── spells.lua
│   └── trap_types.lua
└── src/               # Game logic code
    ├── chamber_art.lua
    ├── encounter_gen.lua
    ├── loot.lua
    ├── magic.lua
    ├── rest.lua
    └── traps.lua
```

## Summary

This refactoring successfully separated game content from game logic, making the dungeon crawler much more moddable and maintainable. All hard-coded features now have their own data files with comprehensive documentation for modders and game designers.
