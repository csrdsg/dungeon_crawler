# Dungeon Crawler - Project Structure

## Overview

This document provides an overview of the project structure after the TUI refactoring.

## Core Application Files

### Main Application
- `game_tui.lua` - Main TUI application (refactored)
- `game_tui.lua.old` - Original monolithic version (backup)
- `game_server.lua` - Server mode for remote play
- `game_client.lua` - Client for connecting to server
- `play.lua` - Command-line interface

### Startup Scripts
- `play_tui.sh` - Launch TUI interface
- `play_persistent.sh` - Launch with persistent state
- `game_session.sh` - Session management

## New Module Architecture (src/)

### TUI Modules (NEW - Refactored)
- `src/tui_renderer.lua` - UI rendering and ANSI terminal control
- `src/game_logic.lua` - Pure game mechanics (no UI)
- `src/tui_keymaps.lua` - Keyboard configuration

### Game Systems
- `src/state_manager.lua` - Save/load game state
- `src/combat.lua` - Combat system
- `src/dungeon_generator.lua` - Procedural dungeon generation
- `src/quest_system.lua` - Quest management
- `src/quest_handler.lua` - Quest event handling
- `src/inventory.lua` - Inventory management
- `src/loot.lua` - Loot generation
- `src/magic.lua` - Spell system
- `src/progression.lua` - Character advancement
- `src/traps.lua` - Trap mechanics
- `src/rest.lua` - Rest system
- `src/dialogue_system.lua` - NPC conversations

### Utilities
- `src/dice.lua` - Dice rolling utilities
- `src/effects.lua` - Status effects
- `src/item_effects.lua` - Item effects
- `src/stats_db.lua` - Statistics tracking
- `src/encounter_gen.lua` - Encounter generation

### AI & Narrative
- `src/ai_storyteller.lua` - AI-generated narratives
- `src/ai_config.lua` - AI configuration
- `src/initial_quests.lua` - Starting quests

## Data Files (data/)

### Configuration
- `data/tui_config.lua` - TUI settings
- `data/rest_config.lua` - Rest system config
- `data/rest_config_hardcore.lua` - Hardcore mode config

### Game Content
- `data/character_classes.lua` - Player classes
- `data/spells.lua` - Spell definitions
- `data/abilities.lua` - Special abilities
- `data/encounters.lua` - Encounter templates
- `data/enemy_stats.lua` - Enemy statistics
- `data/quests.lua` - Quest definitions
- `data/loot_tables.lua` - Loot generation tables
- `data/trap_types.lua` - Trap definitions

### Visual Assets
- `data/chamber_art.lua` - ASCII art for chambers
- `data/enemy_art.lua` - ASCII art for enemies
- `data/dialogue_content.lua` - Dialogue trees

### Persistent Data
- `data/sessions/` - Saved game sessions
- `data/characters/` - Character saves
- `data/missions/` - Mission progress

## Documentation

### Refactoring Documentation (NEW)
- `TUI_REFACTORING.md` - Architecture overview and extension guide
- `KEYMAP_GUIDE.md` - How to customize keyboard controls
- `CLEANUP_SUMMARY.md` - Summary of refactoring changes
- `QUICK_REFERENCE.md` - Developer API reference

### General Documentation
- `README.md` - Project overview
- `MOD_GUIDE.md` - Modding guide
- `CHANGELOG.md` - Version history
- `RELEASE_NOTES.md` - Release information

### System Documentation (docs/)
- `docs/SERVER_ARCHITECTURE.md` - Server design
- `docs/QUEST_SYSTEM.md` - Quest system guide
- `docs/STATE_MANAGER_GUIDE.md` - Save system guide
- `docs/GAMEPLAY_SYSTEMS.md` - Game mechanics
- `docs/MAGIC_ABILITIES.md` - Magic system
- `docs/CHAMBERS.md` - Chamber types
- `docs/ENCOUNTERS.md` - Encounter system
- `docs/ITEMS.md` - Item system

### Development Guides
- `docs/TESTING.md` - Testing guide
- `docs/INTEGRATION_TESTING.md` - Integration tests
- `docs/OLLAMA_USAGE.md` - AI integration
- `docs/PLAY_USAGE.md` - How to play

## Tests (tests/)

### Unit Tests
- `tests/test_dice.lua` - Dice rolling tests
- `tests/test_combat.lua` - Combat tests
- `tests/test_inventory.lua` - Inventory tests
- `tests/test_magic.lua` - Magic system tests
- `tests/test_state_manager.lua` - Save/load tests

### Integration Tests
- `tests/integration_tests.lua` - Full system tests
- `tests/test_integrated_playthrough.lua` - Complete game flow
- `tests/test_server_integration.lua` - Server tests

### Balance Tests
- `tests/balance_test_hard.lua` - Difficulty testing
- `tests/balance_test_magic.lua` - Magic balance
- `tests/balance_test_tracked.lua` - Tracked metrics

### Scripts
- `tests/run_tests.sh` - Run all tests
- `tests/run_all_tests.lua` - Lua test runner

## Analysis & Reports (analysis/, reports/)

### Analysis Tools
- `analysis/playtest_analysis.lua` - Playtest analyzer
- `analysis/quick_analysis.lua` - Quick stats
- `analysis/autoplay.lua` - Automated testing

### Reports
- `reports/balance_report.txt` - Balance analysis
- `reports/STATS_SUMMARY.txt` - Statistical summary
- `reports/playtest_report.txt` - Playtest results

## Module Dependency Graph

```
game_tui.lua
├── src/tui_renderer.lua (UI components)
├── src/game_logic.lua (game mechanics)
├── src/tui_keymaps.lua (keyboard config)
└── src/state_manager.lua (save/load)
    ├── src/combat.lua
    ├── src/quest_system.lua
    ├── src/inventory.lua
    ├── src/magic.lua
    ├── src/dungeon_generator.lua
    └── ... (other game systems)
```

## Quick Start

1. **Play the game**: `./play_tui.sh`
2. **Customize keymaps**: Edit `src/tui_keymaps.lua`
3. **Modify game logic**: Edit `src/game_logic.lua`
4. **Change UI**: Edit `src/tui_renderer.lua`
5. **Run tests**: `cd tests && ./run_tests.sh`

## Architecture Highlights

### Clean Separation
- **Renderer**: Pure UI, no game logic
- **Game Logic**: Pure mechanics, no UI
- **Keymaps**: Centralized configuration
- **Main App**: Coordinates everything

### No Circular Dependencies
- All new modules are self-contained
- Clear dependency hierarchy
- Easy to test and maintain

### Extensible Design
- Add new screens easily
- Plug in new game mechanics
- Customize keyboard controls
- Theme support ready

## File Size Summary

| Component | Size | Purpose |
|-----------|------|---------|
| tui_renderer.lua | 4.4 KB | UI rendering |
| game_logic.lua | 10 KB | Game mechanics |
| tui_keymaps.lua | 1.7 KB | Keyboard config |
| game_tui.lua | 39 KB | Main coordinator |
| **Total** | **~55 KB** | **Well organized!** |

## Next Steps for Developers

1. Read `TUI_REFACTORING.md` for architecture details
2. Read `KEYMAP_GUIDE.md` for customization
3. Check `QUICK_REFERENCE.md` for API usage
4. Explore `src/` modules
5. Run tests to verify everything works

## Version History

- **v1.0** - Original monolithic TUI (52 KB)
- **v2.0** - Refactored modular architecture (current)
  - Separated UI, logic, and input
  - Improved maintainability
  - Better testability
  - Easier customization
