# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Lua-based tabletop RPG system with procedural dungeon generation, turn-based combat, magic, items, and character progression. Features include:
- Client-server architecture with persistent connections (10x faster than request/response)
- AI Storyteller integration (Ollama/OpenAI) for dynamic narrative generation
- TUI (Text User Interface) mode with ncurses-style rendering
- Comprehensive test suite with 39+ passing tests

**Current Status:** Production-ready v3.5 with multiplayer support and AI storytelling

## Development Commands

### Running the Game

```bash
# Single-player mode
lua play.lua                    # Start new game
lua continue_game.lua           # Load saved game
lua game_tui.lua               # TUI mode with rich interface

# Client-server mode (multiplayer)
lua game_server.lua            # Start server (Terminal 1)
lua game_client.lua -i         # Interactive client (Terminal 2)

# With AI Storyteller
lua game_server.lua --ai-mode ollama --ai-model llama3.2:3b
lua game_server.lua --ai-mode openai --ai-model gpt-4  # Requires OPENAI_API_KEY
```

### Testing

```bash
# Run full test suite
cd tests && ./run_tests.sh

# Run specific test files
lua tests/test_combat.lua
lua tests/test_item_effects.lua
lua tests/test_enhanced_server.lua
lua tests/test_ai_storyteller.lua
lua tests/integration_tests.lua

# Balance testing (automated playthroughs)
lua tests/balance_test_tracked.lua
lua tests/balance_test_magic.lua

# Analysis tools
cd analysis
lua autoplay.lua 100          # Run 100 automated games
lua playtest_analysis.lua     # Analyze results
```

### Testing Individual Systems

```bash
# Test specific modules
lua src/dice.lua d20           # Roll d20
lua src/dungeon_generator.lua 10 test.txt
lua src/combat.lua fight character_bimbo.md goblin 1
lua src/loot.lua generate 3 true
```

## Architecture

### Core Architecture Patterns

**1. Server-Client Architecture** (`src/server_core.lua`, `game_server.lua`, `game_client.lua`)
- `ServerCore`: Low-level async TCP server with session management
- `game_server.lua`: Game logic layer that uses ServerCore
- `game_client.lua`: CLI client with interactive and single-command modes
- Event-driven: `on_connect`, `on_disconnect`, `on_message`, `on_error`
- Sessions: Each client gets unique session ID, state persists across requests
- Non-blocking I/O with 0.01s event loop, supports 10+ concurrent clients

**2. State Management** (`src/state_manager.lua`)
- Central system for serializing/deserializing game state
- Three state types: characters (`data/characters/`), missions (`data/missions/`), sessions (`data/sessions/`)
- Pure Lua serialization (no JSON library needed)
- Used by both server mode and TUI mode for persistence
- Pattern: `StateManager.save_*()` and `StateManager.load_*()`

**3. TUI Architecture** (`game_tui.lua` + `src/tui_*.lua` modules)
- **Separation of concerns:**
  - `game_tui.lua`: Main game loop, state machine, screen router
  - `src/tui_renderer.lua`: All drawing/rendering functions
  - `src/game_logic.lua`: Pure game logic (combat, loot, movement)
  - `src/tui_keymaps.lua`: Input handling and key bindings
  - `src/tui_progression.lua`: XP, leveling, skill trees
  - `src/tui_effects.lua`: Status effects, buffs, debuffs
  - `src/tui_quest_ui.lua`: Quest system UI
- **Data-driven configuration:** `data/tui_config.lua`, `data/character_classes.lua`, `data/enemy_stats.lua`
- **Game state machine:** `main_menu` → `class_select` → `playing` → `combat` → `game_over`

**4. AI Storyteller** (`src/ai_storyteller.lua`, `src/ai_config.lua`)
- Dual provider support: Ollama (local, free) or OpenAI (cloud, paid)
- Smart caching system to avoid redundant API calls (cache key is chamber properties, not player position)
- Fallback to static content if AI unavailable
- Non-blocking with configurable timeout (default 10s)
- Stats tracking: requests, successes, failures, cache hits, latency
- **Integration points:** Called from `game_server.lua` and `game_tui.lua` when entering chambers

### Module Dependencies

**Core Systems** (no dependencies on other game modules):
- `src/dice.lua`: Dice rolling utilities
- `src/test_framework.lua`: Testing utilities

**Game Logic Modules** (depend on core + data files):
- `src/dungeon_generator.lua`: Procedural dungeon generation
- `src/encounter_gen.lua`: Enemy encounters (uses `data/encounters.lua`)
- `src/loot.lua`: Loot generation (uses `data/loot_tables.lua`)
- `src/combat.lua`: Turn-based combat
- `src/magic.lua`: Spell system (uses `data/spells.lua`)
- `src/item_effects.lua`: Item effects system
- `src/inventory.lua`: Inventory management
- `src/progression.lua`: XP and leveling
- `src/effects.lua`: Status effects
- `src/rest.lua`: Rest system
- `src/traps.lua`: Trap system

**Infrastructure Modules:**
- `src/server_core.lua`: Async TCP server (requires `luasocket`)
- `src/state_manager.lua`: State persistence
- `src/ai_storyteller.lua`: AI integration (requires `luasocket`, `dkjson`)

### Data File Conventions

All data files in `data/` return Lua tables:
```lua
-- data/example.lua
return {
  key = "value",
  nested = { ... }
}
```

Loaded with: `local data = dofile("data/example.lua")` or `require("data.example")`

## Code Conventions

### Lua-Specific Patterns

**1. Module Pattern:**
```lua
local MyModule = {}
function MyModule.do_something() ... end
return MyModule
```

**2. Optional Dependencies:**
```lua
local ok, module = pcall(require, "optional_module")
if ok then
  -- Use module
end
```

**3. Safe File Loading:**
```lua
local ok, data = pcall(dofile, "path/to/file.lua")
if ok then return data end
```

### Server Event Handlers

When modifying `game_server.lua`, use event handler pattern:
```lua
server:on("on_connect", function(session_id)
  game_sessions[session_id] = init_new_game()
end)

server:on("on_message", function(session_id, message)
  return handle_command(session_id, message)
end)
```

### AI Storyteller Usage

When calling AI storyteller, always provide cache key:
```lua
-- CORRECT: Use chamber properties for cache key
local cache_key = string.format("chamber_%s_%d_%s",
  chamber.type, chamber.subtype, table.concat(chamber.exits, ","))

local description = ai_storyteller.get_chamber_description(chamber, {
  cache_key = cache_key
})

-- WRONG: Using player position as cache key (causes cache misses)
local cache_key = "chamber_" .. player_position
```

### Test Writing

Tests use custom framework in `src/test_framework.lua`:
```lua
local Test = require("src.test_framework")
Test.start("MyModule Tests")

Test.test("should do something", function()
  Test.assert_eq(result, expected, "Description")
  Test.assert_true(condition, "Description")
end)

Test.summary()
```

## Important Notes

### LuaSocket Dependency

The server and AI features require LuaSocket. If not installed:
```bash
# macOS
brew install luarocks
luarocks install luasocket
luarocks install dkjson  # for AI storyteller

# Or use system Lua with LuaSocket pre-installed
```

### File Paths

All file paths in the codebase are relative to project root. When running commands, ensure you're in `/Users/csrdsg/dungeon_crawler/` or use appropriate relative paths from subdirectories.

### Character Files

Character data is stored as Markdown (`.md`) with embedded stats blocks. Example: `character_bimbo.md`

### Session Data

- **Server mode:** `data/sessions/<name>.lua` (Lua table format)
- **Dungeon saves:** `<name>_quest.txt` (custom text format, legacy)

### Balance Targets

Current game balance (v3.5):
- **Survival Rate:** 64% (target: 55-70%)
- **Average Completion:** 80% (8/10 chambers)
- **Combat Difficulty:** Challenging - every fight matters
- Player AC: 14, Enemy AC: 12
- Player damage: 1d6+2, Enemy damage: 1d4+2 to 1d6+2

When modifying combat stats, re-run balance tests:
```bash
lua tests/balance_test_tracked.lua
cd analysis && lua autoplay.lua 100
```

## Common Tasks

### Adding a New Spell

1. Edit `data/spells.lua` - add spell definition
2. Update `src/magic.lua` if new mechanics needed
3. Add tests in `tests/test_magic.lua`
4. Run `lua tests/test_magic.lua`

### Adding a New Enemy Type

1. Edit `data/encounters.lua` - add enemy stats
2. Optionally add ASCII art in `data/enemy_art.lua`
3. Update `data/enemy_stats.lua` for TUI mode
4. Test with: `lua src/encounter_gen.lua generate 1 5`

### Adding a New Chamber Type

1. Edit `src/dungeon_generator.lua` - add type to `CHAMBER_TYPES`
2. Add ASCII art in `data/chamber_art.lua`
3. Update generation weights in `dungeon_generator.lua:generate_dungeon()`
4. Test: `lua src/dungeon_generator.lua 10 test.txt`

### Modifying Server Protocol

1. Update `src/server_core.lua` for low-level protocol changes
2. Update `game_server.lua` for game command handling
3. Update `game_client.lua` to handle new commands/responses
4. Add tests in `tests/test_enhanced_server.lua`
5. Run `lua tests/test_enhanced_server.lua`

### Debugging Server Issues

```bash
# Check if server is running
ps aux | grep game_server

# Check port usage
lsof -i :9999

# Test connection manually
nc localhost 9999
# Then type: status<ENTER>

# View server logs (if logging added)
tail -f server.log
```

## AI Storyteller Integration

When implementing new features that could benefit from AI narration:

1. Check if AI is available: `if ai_storyteller and ai_storyteller.config.enabled then`
2. Provide fallback static content
3. Use appropriate cache keys based on content, not user state
4. Set reasonable timeouts (5-10s for gameplay, longer for generation)
5. Handle errors gracefully: `if not success then use_fallback() end`

See `game_server.lua:handle_search()` and `game_tui.lua:handle_chamber_entry()` for examples.

## Branch Status

Current branch: `feature/ai-storyteller`
- AI storyteller core implementation complete (Phase 1: 90%)
- Chamber descriptions working with both Ollama and OpenAI
- Combat narration and NPC dialogue planned for Phase 2

Main implementation complete, ready for merge after final testing.
