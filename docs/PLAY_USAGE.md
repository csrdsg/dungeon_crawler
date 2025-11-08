# Play.lua Usage Guide

## Overview
The main game interface has been enhanced with command-line arguments for quick, non-interactive status checks.

## Usage Modes

### 1. Interactive Mode (Default)
Start the full game experience:
```bash
lua play.lua
```

Features:
- Full game loop with user input
- Move between chambers
- Search rooms
- Rest and use potions
- Save/load game
- Complete quest objectives

### 2. Non-Interactive Status Check
Quickly view character status without entering the game:
```bash
lua play.lua status
```

Shows:
- Character name and class
- HP (current/max)
- AC (Armor Class)
- Attack bonus and damage
- Gold
- Potion count
- Inventory items

**Exit:** Automatically exits after displaying status

### 3. Non-Interactive Map View
View dungeon layout without entering the game:
```bash
lua play.lua map
```

Shows:
- All 10 chambers
- Chamber types
- Visited status (✓ or ?)
- Current location (← YOU ARE HERE)

**Exit:** Automatically exits after displaying map

### 4. Help Command
View usage information:
```bash
lua play.lua help
```

## Examples

### Quick Status Check
```bash
$ lua play.lua status

📊 CHARACTER STATUS
══════════════════════════════════════════════════════════════════════
Name: Bimbo the Rogue
HP: 30/30
AC: 14
Attack: +3, Damage: 1d6+2
Gold: 142 gp
Potions: 3

📦 INVENTORY:
   • Silver Key
   • Scroll of Protection from Constructs
══════════════════════════════════════════════════════════════════════
```

### Quick Map Check
```bash
$ lua play.lua map

🗺️  DUNGEON MAP
══════════════════════════════════════════════════════════════════════
Chamber 1: Throne Room ✓
Chamber 2: Library ? ← YOU ARE HERE
Chamber 3: Puzzle Room ✓
...
══════════════════════════════════════════════════════════════════════
```

### Play the Game
```bash
$ lua play.lua

🗺️  BIMBO'S QUEST - DUNGEON CRAWLER
══════════════════════════════════════════════════════════════════════

⚡ ACTIONS:
  [move X] - Move to chamber X
  [search] - Search the room
  [rest]   - Short rest
  [potion] - Use healing potion
  [status] - View status
  [map]    - View map
  [save]   - Save game
  [quit]   - Exit

> 
```

## Scripting with Play.lua

### Check if player is low on health
```bash
#!/bin/bash
hp=$(lua play.lua status | grep "HP:" | awk '{print $2}' | cut -d'/' -f1)
if [ "$hp" -lt 10 ]; then
    echo "⚠️  Warning: Low HP!"
fi
```

### Check current location
```bash
#!/bin/bash
location=$(lua play.lua map | grep "YOU ARE HERE" | awk '{print $2}')
echo "Currently in chamber: $location"
```

### Daily status report
```bash
#!/bin/bash
echo "=== Daily Game Status ===" > status_report.txt
date >> status_report.txt
lua play.lua status >> status_report.txt
lua play.lua map >> status_report.txt
```

## Error Handling

### Invalid Command
```bash
$ lua play.lua invalidcommand

❌ Unknown command: invalidcommand
💡 Try: lua play.lua help
```

### No Save File
```bash
$ lua play.lua status

❌ Error loading save file!
```

## Benefits

✅ **Quick Checks** - No need to enter interactive mode  
✅ **Scriptable** - Can be used in shell scripts  
✅ **Non-Blocking** - Commands exit immediately  
✅ **Backward Compatible** - Interactive mode unchanged  
✅ **User Friendly** - Helpful error messages  

## Technical Details

### Command Detection
The game checks `arg[1]` before entering the main loop:
- If argument exists → Process command and exit
- If no argument → Enter interactive loop

### Supported Arguments
- `status` or `--status` - Character status
- `map` or `--map` - Dungeon map
- `help` or `--help` - Usage information
- Any other value - Error message with help suggestion

### Exit Codes
- `0` - Success (valid command or normal quit)
- Immediate return after non-interactive commands

## Troubleshooting

### Command doesn't work
- Ensure save file exists (`bimbo_quest.txt`)
- Check spelling of command
- Use `lua play.lua help` for valid commands

### Interactive mode not responding
- Press Ctrl+C to force quit
- Type `quit` and press Enter

### Status shows old data
- Game state only updates during interactive play
- Run actual game to make changes

## Related Files

- `play.lua` - Main game file
- `bimbo_quest.txt` - Save file
- `character_bimbo.md` - Character sheet

## Future Enhancements

Potential additional commands:
- `lua play.lua stats` - Detailed statistics
- `lua play.lua quick-save` - Save without entering game
- `lua play.lua inventory` - Full inventory view
- `lua play.lua quest` - Quest log
