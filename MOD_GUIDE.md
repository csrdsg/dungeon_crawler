# Mod Installation Guide

## Overview

The dungeon crawler now supports easy modding through data file replacement. All game content is stored in the `/data` directory.

## Quick Start

### Installing a Mod

1. **Backup Original Files**
   ```bash
   cd dungeon_crawler/data
   cp loot_tables.lua loot_tables_original.lua
   ```

2. **Install Mod**
   ```bash
   cp loot_tables_treasure_hunter.lua loot_tables.lua
   ```

3. **Play!**
   ```bash
   cd ..
   lua src/loot.lua generate 2
   ```

### Uninstalling a Mod

```bash
cd dungeon_crawler/data
cp loot_tables_original.lua loot_tables.lua
```

## Available Example Mods

### 1. Hardcore Mode (`rest_config_hardcore.lua`)

**Changes:**
- Short rest heals less (1d4 instead of 1d6+1)
- Short rest encounter chance increased (60% vs 40%)
- Long rest encounter chance increased (80% vs 60%)
- Long rest costs 2 rations instead of 1

**Installation:**
```bash
cd data
cp rest_config.lua rest_config_original.lua
cp rest_config_hardcore.lua rest_config.lua
```

**For players who want:**
- Higher difficulty
- More dangerous resting
- Resource management challenge

### 2. Treasure Hunter Mode (`loot_tables_treasure_hunter.lua`)

**Changes:**
- Gold amounts doubled
- More items per quality tier
- New unique items added
- Better loot quality in all chambers
- Boss chambers always drop legendary items

**Installation:**
```bash
cd data
cp loot_tables.lua loot_tables_original.lua
cp loot_tables_treasure_hunter.lua loot_tables.lua
```

**For players who want:**
- More generous loot
- Faster progression
- Epic items more frequently

## Creating Your Own Mod

### Step 1: Copy a Data File

```bash
cd data
cp spells.lua spells_custom.lua
```

### Step 2: Edit the Copy

Open `spells_custom.lua` and modify:

```lua
-- Add a new spell
meteor_swarm = {
    name = "Meteor Swarm",
    type = "arcane",
    level = 9,
    mana_cost = 25,
    damage = "40d6",
    description = "Rain of destruction from the sky",
    save_dc = 20,
    save_type = "DEX",
    target = "area"
}
```

### Step 3: Test Your Changes

```bash
cp spells_custom.lua spells.lua
cd ..
lua src/magic.lua list
```

### Step 4: Share Your Mod

1. Keep your custom file (e.g., `spells_custom.lua`)
2. Write a description of changes
3. Share the file with others

## Mod Combinations

You can combine multiple mods:

```bash
# Hardcore mode + treasure hunter = balanced challenge
cp rest_config_hardcore.lua rest_config.lua
cp loot_tables_treasure_hunter.lua loot_tables.lua
```

## Troubleshooting

### Mod Not Working?

1. **Check file name matches exactly**
   - Must be `loot_tables.lua` not `loot_tables_mod.lua`

2. **Verify Lua syntax**
   ```bash
   lua -e "dofile('data/loot_tables.lua')"
   ```

3. **Check for typos in the data structure**

4. **Restore original if broken**
   ```bash
   cp loot_tables_original.lua loot_tables.lua
   ```

### Error Messages

**"module not found"** - Wrong directory, run from project root

**"syntax error"** - Check for missing commas, brackets, quotes

**"nil value"** - Missing required field in data structure

## Best Practices

### Before Installing Mods

✅ Always backup original files
✅ Read mod description carefully
✅ Check compatibility notes
✅ Test in a new game first

### Creating Mods

✅ Use descriptive file names (`_hardcore`, `_easy`, etc.)
✅ Document your changes
✅ Test thoroughly
✅ Keep original balance in mind

### Sharing Mods

✅ Include installation instructions
✅ List all changes made
✅ Note any dependencies
✅ Specify game version

## Example Mod Ideas

### Easy Mode
- More healing from rests
- Less encounter chance
- Better starting loot
- Reduced trap damage

### High Magic
- More spells available
- Lower mana costs
- Stronger spell effects
- Magic items more common

### Monster Hunter
- More hostile encounters
- Tougher enemies
- Better combat loot
- Boss-specific rewards

### Puzzle Master
- More puzzle rooms
- Unique puzzle rewards
- Intelligence-based bonuses
- Rare scrolls and tomes

### Survival Mode
- Harsh rest penalties
- Limited resources
- Deadly traps
- Scarce healing

## Community Mods

### Where to Share

1. Create a `mods/` folder in your repository
2. Document each mod in its own README
3. Share on forums or Discord
4. Submit pull requests with new content

### Mod Template

Create `mods/my_mod/README.md`:

```markdown
# My Awesome Mod

**Version:** 1.0
**Author:** YourName
**Compatibility:** Game v1.0+

## Description
What your mod does

## Changes
- Detailed list of changes
- With specific numbers

## Installation
Step by step instructions

## Uninstallation
How to remove

## Known Issues
Any bugs or limitations
```

## Advanced: Mod Loader

Future enhancement - automatic mod management:

```bash
# Planned feature
./mod_manager.sh install hardcore_mode
./mod_manager.sh list
./mod_manager.sh disable treasure_hunter
```

## Resources

- **Data Format Guide**: See `/data/README.md`
- **Balance Guide**: See game documentation
- **Lua Syntax**: https://www.lua.org/manual/5.4/

## Support

Having trouble with mods?

1. Check `/data/README.md` for data format
2. Verify Lua syntax is correct
3. Test with original files first
4. Ask in community forums

---

Happy Modding! 🎮
