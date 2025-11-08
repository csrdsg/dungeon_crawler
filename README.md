# 🎲 Dungeon Crawler RPG System

A Lua-based tabletop RPG system with procedural dungeon generation, turn-based combat, magic, items, and persistent character progression.

**Version:** 3.5 (Enhanced Server Architecture)  
**Status:** ✅ Production Ready with Multiplayer Support

---

## 🚀 Quick Start

### Single Player Mode
```bash
# Start a new game
lua play.lua

# Continue existing game
lua continue_game.lua
```

### Client-Server Mode (NEW! ⚡)
```bash
# Terminal 1: Start the server
lua game_server.lua

# Terminal 2: Connect and play
lua game_client.lua status
lua game_client.lua map
lua game_client.lua search

# Or use interactive mode
lua game_client.lua -i
```

### Run Tests
```bash
cd tests && ./run_tests.sh
```

---

## 📂 Project Structure

```
dungeon_crawler/
├── README.md              # This file
├── play.lua               # Main game launcher
├── continue_game.lua      # Load saved games
├── move_chambers.lua      # Chamber navigation helper
│
├── src/                   # Core game engine
│   ├── dice.lua           # Dice rolling system
│   ├── combat.lua         # Turn-based combat
│   ├── server_core.lua    # 🆕 Async server framework
│   ├── dungeon_generator.lua
│   ├── encounter_gen.lua
│   ├── loot.lua
│   ├── magic.lua
│   ├── item_effects.lua
│   ├── inventory.lua
│   ├── progression.lua
│   ├── effects.lua
│   ├── rest.lua
│   ├── traps.lua
│   ├── stats_db.lua
│   └── test_framework.lua
│
├── game_server.lua        # 🆕 Game server (enhanced)
├── game_client.lua        # 🆕 Game client (interactive)
│
├── tests/                 # Unit & integration tests
│   ├── test_*.lua         # Unit tests
│   ├── balance_test_*.lua # Balance tests
│   ├── integration_tests.lua
│   ├── run_all_tests.lua
│   └── run_tests.sh
│
├── analysis/              # Balance analysis tools
│   ├── autoplay.lua       # Automated playthrough
│   ├── playtest_analysis.lua
│   └── quick_analysis.lua
│
├── docs/                  # Documentation
│   ├── INIT.md            # Session initialization guide
│   ├── SERVER_ARCHITECTURE.md  # 🆕 Enhanced server docs
│   ├── CHARACTER_SHEET.md
│   ├── CHAMBERS.md
│   ├── ENCOUNTERS.md
│   ├── ITEMS.md
│   ├── ITEM_BALANCE_REPORT.md
│   ├── MAGIC_ABILITIES.md
│   ├── GAMEPLAY_SYSTEMS.md
│   ├── INTEGRATION_TESTING.md
│   ├── PLAY_USAGE.md
│   ├── NEW_FEATURES.md
│   └── TESTING.md
│
├── reports/               # Generated analysis reports
│   ├── balance_report.txt
│   ├── balance_summary.txt
│   └── playtest_report.txt
│
├── character_bimbo.md     # Example character
├── bimbo_quest.txt        # Example dungeon save
└── dungeon_stats.db       # Statistics database
```

---

## ✨ Features

### Core Systems
- ✅ **Procedural Dungeon Generation** - Forest-graph structure, 10 chamber types
- ✅ **Turn-Based Combat** - d20 attack rolls, damage, critical hits
- ✅ **Magic System** - 12 spells, MP management, spell effects
- ✅ **Item Effects** - 22 effects (active, passive, cursed)
- ✅ **Character Progression** - XP, leveling, skill trees
- ✅ **Inventory Management** - Weight, encumbrance, item usage
- ✅ **Rest System** - Short/long rests, resource recovery
- ✅ **Status Effects** - Buffs, debuffs, conditions
- ✅ **Trap System** - Detection, disarming, damage
- ✅ **Save/Load** - Persistent dungeons and characters

### Server Features (NEW! 🚀)
- ✅ **Persistent Connections** - 10x faster than request/response
- ✅ **Session Management** - Unique sessions per client
- ✅ **Concurrent Clients** - Support 10+ simultaneous players
- ✅ **Auto-Save** - Periodic saves every 60 seconds
- ✅ **Error Recovery** - Automatic reconnection, graceful failures
- ✅ **Interactive Mode** - REPL-style client interface
- ✅ **Broadcasting** - Ready for multiplayer features
- ✅ **Heartbeat System** - Connection keep-alive (PING/PONG)

### Balance
- 🎯 **64% Survival Rate** (100 test runs)
- 🎯 **80% Average Progress** (8/10 chambers)
- 🎯 **Every Fight Matters** - Resource management critical
- 🎯 **22/22 Item Tests Passing**
- 🎯 **All Magic Balanced** - No overpowered spells
- 🎯 **39/39 Server Tests Passing** - Comprehensive coverage

---

## 🎮 How to Play

### 1. Create a Character
```bash
# Roll attributes (STR, DEX, CON, INT, WIS, CHA)
lua src/dice.lua d6 3  # Run 6 times

# Edit character_bimbo.md as template
# Choose class, skills, equipment
```

### 2. Start Adventure
```bash
# Launch game
lua play.lua

# Follow prompts to:
# - Create new dungeon or load existing
# - Navigate chambers
# - Fight enemies
# - Find loot
# - Level up
```

### 3. Continue Session
```bash
# Load saved game
lua continue_game.lua

# Your progress is auto-saved
```

---

## 🧪 Testing

```bash
# Run all tests
cd tests
./run_tests.sh

# Run specific test
lua test_combat.lua
lua test_item_effects.lua
lua test_magic.lua

# Run balance tests
lua balance_test_tracked.lua
lua balance_test_magic.lua

# Run integration tests
lua integration_tests.lua
```

---

## 📊 Balance Analysis

```bash
# Auto-play 100 games
cd analysis
lua autoplay.lua 100

# Analyze results
lua playtest_analysis.lua

# Quick stats
lua quick_analysis.lua
```

---

## 📖 Documentation

All documentation is in the `docs/` folder:

- **[INIT.md](docs/INIT.md)** - Session initialization & quick reference
- **[GAMEPLAY_SYSTEMS.md](docs/GAMEPLAY_SYSTEMS.md)** - Combat, loot, encounters
- **[ITEMS.md](docs/ITEMS.md)** - Item effects system
- **[ITEM_BALANCE_REPORT.md](docs/ITEM_BALANCE_REPORT.md)** - Balance changes v2.0
- **[MAGIC_ABILITIES.md](docs/MAGIC_ABILITIES.md)** - All 12 spells
- **[CHARACTER_SHEET.md](docs/CHARACTER_SHEET.md)** - Character creation
- **[PLAY_USAGE.md](docs/PLAY_USAGE.md)** - How to use play.lua

---

## 🛠️ Requirements

- **Lua 5.x** (no external dependencies)
- Terminal/shell access
- Text editor (for character files)

---

## 🎯 Game Statistics

### Combat Balance
- Player AC: 14 (leather armor)
- Player Attack: +3 (proficiency)
- Player Damage: 1d6+2
- Enemy AC: 12
- Enemy HP: 8-14 (level 1)
- Enemy Damage: 1d4+2 to 1d6+2

### Survival Rates (100 test runs)
- Overall: 64%
- With magic: 82%
- Pure fighter: 90%
- Rogue: 46%

### Item Effects
- Active: 7 (balanced 4.5-9 value/use)
- Passive: 10 (moderate bonuses +2/+8)
- Cursed: 5 (risk vs reward viable)

---

## 🔄 Recent Updates

### v3.0 (2025-11-08)
- ✅ Rebalanced all 22 item effects
- ✅ Updated documentation structure
- ✅ Organized codebase into folders
- ✅ Created comprehensive balance report
- ✅ All tests passing (100%)

### v2.0 (2025-11-07)
- ✅ Combat system rebalanced
- ✅ Magic system balanced
- ✅ Added 6 new features (inventory, XP, rest, traps, effects, autoplay)
- ✅ Dungeon generator v2.0 (100% connectivity)

---

## 🤝 Contributing

This is a personal project, but feel free to:
- Report bugs
- Suggest features
- Fork and modify
- Use as template for your own RPG

---

## 📝 License

Free to use, modify, and distribute for personal and educational purposes.

---

## 🎲 Happy Adventuring!

May your dice rolls be high and your HP stay above zero! ⚔️🛡️✨
