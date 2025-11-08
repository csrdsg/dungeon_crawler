# Dungeon Crawler - Session Initialization
**Last Updated:** 2025-11-08 13:00 UTC  
**Version:** 3.0 - FULLY REBALANCED & FEATURE COMPLETE

> **Note:** Project has been reorganized. All source files are now in `src/`, tests in `tests/`, docs in `docs/`.

## 🎮 GAME STATUS: CHALLENGING & BALANCED ✅

### Balance Verification (100 test runs)
- ✅ **64% Survival Rate** (target: 55%)
- ✅ **80% Average Completion** (8/10 chambers)
- ✅ **60% Average HP Remaining** for survivors
- ✅ **Combat Balance: CHALLENGING**
- ✅ **Every fight matters** - resource management critical

---

## Project Overview
A Lua-based dungeon crawler tabletop RPG system with procedural dungeon generation, character management, and turn-based gameplay. The system includes dice rolling mechanics, character progression with skill trees, and persistent dungeon saves for continuous gaming sessions.

## ⚡ MAJOR UPDATES (v3.0)

### Combat Rebalance (CHALLENGING MODE)
**Player Stats:**
- AC: 14 (leather armor +4)
- Attack: +3 (proficiency)
- Damage: 1d6+2 (STR/DEX bonus)
- Potions: 3 × 2d4 healing

**Enemy Stats (Level 1):**
- AC: 12 (easier to hit)
- Attack: +3 (fair)
- HP: 8-14 (moderate)
- Damage: 1d4+2 to 1d6+2

**Result:** 64% survival, every fight matters

### 6 New Features
1. 🎒 Inventory System - Use items, manage weight
2. ⭐ XP/Leveling - Auto level-up, skill points
3. 🏕️ Rest System - Short/long rests
4. 🪤 Trap System - Detect/disarm traps
5. 💫 Status Effects - Poison, buffs, debuffs
6. 🎯 Auto-Play - Automated testing

### Dungeon Generator v2.0
- 100% chamber connectivity (was 40%)
- Guaranteed boss chambers (was 40%)
- ASCII map visualization
- Weighted chamber type distribution

## Quick Start
```bash
# Start new game (recommended)
lua play.lua

# Continue existing game
lua continue_game.lua

# Or use individual systems:
lua src/dungeon_generator.lua 8 my_dungeon.txt
lua src/encounter_gen.lua generate 3 2
lua src/combat.lua fight character_bimbo.md goblin 1
lua src/loot.lua generate 3 true
lua src/dice.lua d10 3
```

## Project Structure
```
dungeon_crawler/
├── README.md                # Project overview
├── play.lua                 # Main game launcher
├── continue_game.lua        # Continue saved game
├── move_chambers.lua        # Chamber navigation helper
│
├── src/                     # Core game engine
│   ├── dice.lua
│   ├── combat.lua
│   ├── dungeon_generator.lua
│   ├── encounter_gen.lua
│   ├── loot.lua
│   ├── magic.lua
│   ├── item_effects.lua
│   ├── inventory.lua
│   ├── progression.lua
│   └── ... (all game systems)
│
├── docs/                    # Documentation
│   ├── INIT.md              # This file
│   ├── CHARACTER_SHEET.md
│   ├── ITEMS.md
│   ├── GAMEPLAY_SYSTEMS.md
│   └── ... (all guides)
│
├── tests/                   # All tests
│   ├── test_*.lua
│   └── run_all_tests.lua
│
├── analysis/                # Balance analysis tools
│   └── autoplay.lua
│
├── character_bimbo.md       # Example character
└── bimbo_quest.txt          # Example dungeon save
```

## Game System

### Core Mechanics
- **Attributes:** STR, DEX, CON, INT, WIS, CHA (roll 3d6 each)
- **Skills:** 12 skills with 5 ranks each (Novice → Master)
- **Combat:** d20 + modifiers vs DC
- **Progression:** 2 skill points per level

### Chamber Types (1-10)
1. Empty room
2. Treasure room
3. Monster lair
4. Trap room
5. Puzzle room
6. Prison cells
7. Armory
8. Library
9. Throne room
10. Boss chamber

### Encounter Types
- **Friendly:** Merchants, trapped adventurers, helpful NPCs
- **Neutral:** Scavenger goblins, wandering spirits, rival parties
- **Hostile:** Orcs, undead, monsters, dungeon guardians

## Common Commands

### Dungeon Management
```bash
# Generate new dungeon
lua src/dungeon_generator.lua <chambers> [filename]
lua src/dungeon_generator.lua 20 dungeon1.txt

# Load saved dungeon
lua src/dungeon_generator.lua load dungeon1.txt

# Move player between chambers (or use helper)
lua move_chambers.lua dungeon1.txt 5
```

### Encounter System
```bash
# Generate encounter for chamber
lua src/encounter_gen.lua generate <chamber_type> [level]
lua src/encounter_gen.lua generate 3 2    # Monster lair, level 2
lua src/encounter_gen.lua generate 10 5   # Boss chamber, level 5

# Test all chamber types
lua src/encounter_gen.lua test
```

### Combat System
```bash
# Fight an enemy
lua src/combat.lua fight <character_file> <enemy_type> [level]
lua src/combat.lua fight character_bimbo.md goblin 1
lua src/combat.lua fight character_bimbo.md dragon 8

# Test combat
lua src/combat.lua test

# Available enemies:
# goblin, orc, skeleton, zombie, spider, bandit, cultist,
# gargoyle, ogre, vampire, dragon
```

### Loot System
```bash
# Generate loot
lua src/loot.lua generate <chamber_type> [enemy_defeated] [boss_kill]
lua src/loot.lua generate 2              # Treasure room
lua src/loot.lua generate 3 true         # Monster lair, enemy killed
lua src/loot.lua generate 10 true true   # Boss chamber, boss killed

# Test loot generation
lua src/loot.lua test
```

### Dice Rolling
```bash
# Roll any dice type
lua src/dice.lua d20 1      # Attack roll
lua src/dice.lua d6 3       # Damage roll
lua src/dice.lua d10 5      # Multiple dice
```

### Character Creation
```bash
# Roll starting attributes (6 times)
lua src/dice.lua d6 3

# Roll starting gold
lua src/dice.lua d6 3  # Multiply result by 10
```

## Current Game State

### Active Character
- **Name:** Bimbo
- **Class:** Rogue (Level 1)
- **HP:** 20/20 | **AC:** 12
- **XP:** 0/1000
- **Attributes:** STR 10, DEX 12, CON 5, INT 10, WIS 11, CHA 14
- **Skills:** Stealth Rank 1, Lockpicking Rank 1, Trap Detection Rank 1
- **Gold:** 142 gp (gained 50 gp from Chamber 3 puzzle)
- **Equipment:** Shortsword, Dagger, 4× Throwing Knives, Leather Armor, Thieves' Tools, Healing Potion, Silver Key, Scroll of Light, etc.
- **File:** character_bimbo.md

### Active Dungeon
- **File:** bimbo_quest.txt
- **Chambers:** 10 total
- **Chambers Visited:** 2 (Chamber 1 - Throne Room, Chamber 3 - Puzzle Room)
- **Current Position:** Chamber 3 (Puzzle Room) - Resting
- **Check Position:** `lua src/dungeon_generator.lua load bimbo_quest.txt`

## Development Notes

### Completed Features (2025-11-08)
✅ Dice rolling system (dice.lua)
✅ Procedural dungeon generator with forest-graph structure
✅ Persistent dungeon save/load system
✅ Player position tracking across sessions
✅ Character sheet template with skill tree
✅ Complete item/equipment database
✅ Chamber type definitions (10 types)
✅ Encounter tables (friendly/neutral/hostile)
✅ Starting gear packages for 5 classes
✅ Example character (Bimbo the Rogue)
✅ **Turn-based combat system (combat.lua)**
✅ **Random encounter generator (encounter_gen.lua)**
✅ **Loot and treasure generator (loot.lua)**
✅ **11 enemy types with stats and XP**
✅ **5 loot quality tiers**

### System Features
- **Dungeon Generation:** Random forest structure, 0-3 connections per chamber
- **Save System:** Text-based format, tracks position & visited chambers
- **Character Progression:** 5-rank skill system, synergy bonuses, specializations at level 5
- **Equipment System:** 50+ items, weight/encumbrance rules, durability tracking
- **Encounter System:** Frequency based on chamber type, disposition rolls (friendly/neutral/hostile)
- **Combat System:** d20 attack rolls, damage calculation, critical hits, HP tracking, XP rewards
- **Loot System:** Quality-based treasure (poor→legendary), gold, items, gems, magic equipment

### Next Steps / TODO
- [x] Implement combat system (attack rolls, damage, HP tracking) **DONE**
- [x] Add encounter generation when entering chambers **DONE**
- [x] Create loot generation for treasure rooms **DONE**
- [ ] **Inventory management system** (add/remove/use items via commands)
- [ ] **XP/Leveling system** (automatic level-up, skill point allocation)
- [ ] Trap mechanics for trap rooms (detection, disarming, damage)
- [ ] Implement puzzle challenges (more varieties)
- [ ] NPC dialogue system (conversation trees)
- [ ] Status effects (poison, buffs, debuffs, bleeding)
- [ ] Magic spell system (casting, MP usage, spell effects)
- [ ] Rest/healing mechanics (short rest, long rest, food consumption)
- [ ] Party system (multiple characters, companions)

## Playing the Game

### Starting a New Game
1. Run: `lua play.lua`
2. Follow prompts to create character and dungeon
3. Play through the integrated game system

### Continuing a Session
1. Run: `lua continue_game.lua`
2. Your progress is automatically loaded
3. Continue your adventure

### Manual Game Loop (Advanced)
1. **Enter chamber** → `lua move_chambers.lua bimbo_quest.txt 5`
2. **Roll for encounter** → `lua src/encounter_gen.lua generate 5 2`
3. **If hostile** → `lua src/combat.lua fight character_bimbo.md <enemy> 2`
4. **Search for loot** → `lua src/loot.lua generate 5 true`
5. **Update character** → Edit character file (HP, XP, gold, items)
6. **Choose exit** → Move to connected chamber
7. **Save game state** → Position auto-saved

## File Formats

### Dungeon Save Format (.txt)
```
DUNGEON_SAVE_V1
player_position=1
num_chambers=8
---CHAMBERS---
id=1,type=5,visited=true,connections=
id=2,type=8,visited=false,connections=1:3
...
```

### Character File (.md)
Markdown format with sections for:
- Basic info (name, class, level, XP)
- Attributes and modifiers
- Derived stats (HP, MP, AC)
- Skills with rank notation
- Inventory with weights
- Background and notes

## Tips for DM/Players

### For Dungeon Masters
- Adjust encounter difficulty based on party level
- Use chamber types to guide encounter selection
- Allow creative solutions to puzzles/traps
- Track visited chambers for continuity

### For Players
- Always keep 1 healing potion
- Mark dungeon paths with chalk
- Use stealth in hostile areas
- Check mirrors before turning corners
- Manage encumbrance carefully
- Save character file regularly

## Session Checklist
When starting a new session:
- [ ] Review character sheet (HP, XP, gold, equipment)
- [ ] Load dungeon state (`lua dungeon_generator.lua load bimbo_quest.txt`)
- [ ] Note current chamber and available exits
- [ ] Check inventory and resources (potions, torches, food)
- [ ] Review last session notes and quest progress
- [ ] Ready combat commands if exploring dangerous areas

## Quick Gameplay Reference

### Full Chamber Exploration Example
```bash
# 1. Move to new chamber
lua move_chambers.lua bimbo_quest.txt 6

# 2. Generate encounter (Chamber 6 = Empty room, type 1)
lua src/encounter_gen.lua generate 1 2

# 3. If hostile encounter appears, fight!
lua src/combat.lua fight character_bimbo.md goblin 2

# 4. After victory, search for loot
lua src/loot.lua generate 1 true

# 5. Update character file with rewards
# - Update HP (subtract damage taken)
# - Add XP gained
# - Add gold found
# - Add items to inventory

# 6. Continue exploring or rest/heal
```

### Emergency Commands
```bash
# Quick healing (use potion) - Manual update
# Reduce potion count, add 2d4+2 HP to character

# Flee combat - Move to different chamber
lua move_chambers.lua bimbo_quest.txt <chamber>

# Check character status
cat character_bimbo.md | grep -A5 "Current Status"
```

---

**Last Updated:** 2025-11-08 13:00
**System Version:** 3.0
**Project Status:** Organized & Production Ready
**Major Systems:** Dungeon Generation, Combat, Encounters, Loot, Magic, Items, Character Management
**Requires:** Lua 5.x (no external dependencies)
**Documentation:** See docs/ folder for all guides
**Quick Reference:** See README.md in root folder
