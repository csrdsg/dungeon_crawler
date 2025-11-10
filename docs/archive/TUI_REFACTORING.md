# TUI Architecture Refactoring

## Overview

The TUI (Text User Interface) has been refactored to separate concerns and make the codebase more maintainable and tweakable.

## New File Structure

### Core Modules

1. **src/tui_renderer.lua** - UI Rendering
   - All ANSI escape codes and terminal control
   - UI components (boxes, menus, progress bars, text rendering)
   - Screen drawing utilities
   - Header and footer rendering

2. **src/game_logic.lua** - Game Logic
   - Core game mechanics separated from UI
   - Dice rolling
   - Player creation
   - Dungeon generation
   - Enemy creation
   - Loot generation
   - Search mechanics
   - Combat calculations
   - Rest and potion logic

3. **src/tui_keymaps.lua** - Keymap Configuration
   - Centralized keyboard mapping
   - Easy to customize controls
   - Helper functions for key checking
   - Supports arrow keys, ESC, and custom bindings

### Main File

**game_tui.lua** - Main TUI Application
- Game state management
- Screen coordination
- Input routing
- High-level game flow

## Benefits of This Architecture

### 1. Separation of Concerns
- **UI code** is isolated in the renderer
- **Game logic** is independent of display
- **Input handling** is centralized and configurable

### 2. Maintainability
- Each module has a single responsibility
- Changes to UI don't affect game logic
- Changes to game mechanics don't affect rendering

### 3. Customization
- Keymaps can be easily modified in one place
- UI styling is centralized
- Game balance tweaks are isolated

### 4. Testability
- Game logic can be tested without UI
- Rendering can be tested independently
- Input handling is predictable

### 5. Reusability
- Renderer can be used for other screens/views
- Game logic can be used in different interfaces (CLI, web, etc.)
- Keymaps can be shared across modules

## Customizing Keymaps

Edit `src/tui_keymaps.lua` to change controls:

```lua
-- Example: Change move key from 'm' to 'w'
Keymaps.game = {
    move = "w",          -- Changed from "m"
    inventory = "i",
    search = "s",
    rest = "r",
    save = "w",
    quit = "q",
    use_potion = "p"
}
```

## Extending the System

### Adding a New Screen

1. Add drawing function to `game_tui.lua`:
```lua
function game:draw_my_new_screen()
    Renderer.clear_screen()
    Renderer.draw_header()
    Renderer.box(10, 5, 60, 15, "MY SCREEN")
    -- ... your content
    Renderer.draw_footer("Your help text")
end
```

2. Add input handler:
```lua
function game:handle_my_screen_input(key)
    -- Handle input
    return false  -- or true to quit
end
```

3. Add to main loop:
```lua
-- In game:run()
elseif self.state == "my_screen" then
    self:draw_my_new_screen()
```

### Adding New Game Logic

Add functions to `src/game_logic.lua`:

```lua
function GameLogic.my_new_mechanic(player, dungeon)
    -- Your logic here
    return result
end
```

Then use in `game_tui.lua`:

```lua
function game:do_something()
    local result = GameLogic.my_new_mechanic(self.player, self.dungeon)
    self:add_log("Result: " .. result)
end
```

### Adding UI Components

Add to `src/tui_renderer.lua`:

```lua
function Renderer.my_component(x, y, data)
    Renderer.move_cursor(y, x)
    -- Draw your component
end
```

## Module Dependencies

```
game_tui.lua
├── src/tui_renderer.lua (no dependencies)
├── src/game_logic.lua (no dependencies)
└── src/tui_keymaps.lua (no dependencies)
```

All new modules have **no external dependencies** (except Lua standard library).

## Migration Notes

- Original `game_tui.lua` backed up to `game_tui.lua.old`
- All functionality preserved
- No changes to data files required
- Compatible with existing save games

## File Sizes

- `tui_renderer.lua`: ~4 KB (UI only)
- `game_logic.lua`: ~10 KB (mechanics only)
- `tui_keymaps.lua`: ~2 KB (input config)
- `game_tui.lua`: ~40 KB (down from ~65 KB monolithic)

## Future Improvements

1. Move screen drawing functions to separate module
2. Create input handler module
3. Add config file for UI colors/themes
4. Extract AI storyteller integration
5. Create plugin system for encounters

## Testing

Test each module independently:

```bash
# Test renderer
lua -e "local R = require('src.tui_renderer'); print('Renderer OK')"

# Test game logic
lua -e "local G = require('src.game_logic'); print('Logic OK')"

# Test keymaps
lua -e "local K = require('src.tui_keymaps'); print('Keymaps OK')"

# Test full game
./play_tui.sh
```

## Performance

No performance impact - refactoring is purely organizational. All functions are still called the same way, just organized better.
