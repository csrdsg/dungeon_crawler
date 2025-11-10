# Quick Reference - Refactored Architecture

## Files Overview

| File | Size | Purpose | Dependencies |
|------|------|---------|--------------|
| `src/tui_renderer.lua` | 4.4 KB | UI rendering, ANSI codes, components | None |
| `src/game_logic.lua` | 10 KB | Game mechanics, combat, loot | None |
| `src/tui_keymaps.lua` | 1.7 KB | Keyboard configuration | None |
| `game_tui.lua` | 39 KB | Main app, state management | All above |

## Quick Module Reference

### tui_renderer.lua

**Screen Control:**
```lua
Renderer.clear_screen()
Renderer.hide_cursor()
Renderer.show_cursor()
Renderer.move_cursor(row, col)
```

**Components:**
```lua
Renderer.box(x, y, width, height, title)
Renderer.text(x, y, text, color)
Renderer.menu(x, y, options, selected)
Renderer.progress_bar(x, y, current, max, width, label)
Renderer.floating_pane(x, y, width, height, title, content, style)
Renderer.word_wrap(text, width)
Renderer.draw_header()
Renderer.draw_footer(text)
```

**Colors:**
```lua
Renderer.colors.red
Renderer.colors.green
Renderer.colors.yellow
Renderer.colors.blue
Renderer.colors.cyan
Renderer.colors.bold
Renderer.colors.reset
```

### game_logic.lua

**Core Functions:**
```lua
GameLogic.roll("2d6+3")                          -- Dice rolling
GameLogic.get_chamber_type_name(type_id)         -- Chamber names
GameLogic.create_player(class_id, CharClasses)   -- New player
GameLogic.generate_dungeon(num_chambers)         -- New dungeon
```

**Combat:**
```lua
GameLogic.create_enemy(pos, EncData, EnemyStats)
GameLogic.player_attack(player, enemy)           -- Returns: hit, damage, dead
GameLogic.enemy_attack(enemy, player)            -- Returns: hit, damage, dead
GameLogic.cast_spell(spell_id, player, enemy, SpellData)
```

**Items & Search:**
```lua
GameLogic.generate_loot(chamber_type, enemy_defeated, LootData)
GameLogic.search_chamber(chamber, player)        -- Returns: result, reward
GameLogic.use_potion(player, TUIConfig)          -- Returns: heal, success
GameLogic.rest(player, TUIConfig)                -- Returns: heal, encounter
```

### tui_keymaps.lua

**Keymap Tables:**
```lua
Keymaps.main_menu    -- Menu navigation
Keymaps.game         -- In-game actions
Keymaps.combat       -- Combat actions
Keymaps.inventory    -- Inventory actions
Keymaps.navigation   -- Universal navigation
```

**Helper Functions:**
```lua
Keymaps.matches(key, table, action)    -- Check if key matches action
Keymaps.is_up(key, next1, next2)       -- Check for up arrow
Keymaps.is_down(key, next1, next2)     -- Check for down arrow
Keymaps.is_escape_only(key, next1)     -- Check for ESC (not arrow)
```

## Common Tasks

### Change a Keymap
```lua
-- Edit src/tui_keymaps.lua
Keymaps.game = {
    move = "w",  -- Change this line
    -- ...
}
```

### Add a New UI Component
```lua
-- In src/tui_renderer.lua
function Renderer.my_widget(x, y, data)
    Renderer.move_cursor(y, x)
    io.write(data)
end
```

### Add New Game Mechanic
```lua
-- In src/game_logic.lua
function GameLogic.my_mechanic(player, dungeon)
    -- Your code
    return result
end

-- Use in game_tui.lua
function game:do_something()
    local result = GameLogic.my_mechanic(self.player, self.dungeon)
end
```

### Add a New Screen
```lua
-- In game_tui.lua

-- 1. Add draw function
function game:draw_my_screen()
    Renderer.clear_screen()
    Renderer.draw_header()
    -- Your UI
    Renderer.draw_footer("Help text")
end

-- 2. Add input handler
function game:handle_my_screen_input(key)
    -- Handle input
    return false
end

-- 3. Add to main loop
-- In game:run()
elseif self.state == "my_screen" then
    self:draw_my_screen()
-- ...
elseif self.state == "my_screen" then
    quit = self:handle_my_screen_input(key)
```

## Color Reference

```lua
-- Text colors
Renderer.colors.black
Renderer.colors.red
Renderer.colors.green
Renderer.colors.yellow
Renderer.colors.blue
Renderer.colors.magenta
Renderer.colors.cyan
Renderer.colors.white

-- Background colors
Renderer.colors.bg_black
Renderer.colors.bg_red
Renderer.colors.bg_green
Renderer.colors.bg_yellow
Renderer.colors.bg_blue
Renderer.colors.bg_magenta
Renderer.colors.bg_cyan
Renderer.colors.bg_white

-- Modifiers
Renderer.colors.bold
Renderer.colors.dim
Renderer.colors.reset  -- Always use this after colors!
```

## Testing Modules

```bash
# Test individual modules
lua -e "require('src.tui_renderer'); print('OK')"
lua -e "require('src.game_logic'); print('OK')"
lua -e "require('src.tui_keymaps'); print('OK')"

# Test game
./play_tui.sh
```

## Common Patterns

### Drawing a Panel
```lua
Renderer.box(x, y, width, height, "TITLE")
Renderer.text(x+2, y+2, "Content", Renderer.colors.green)
```

### Menu Selection
```lua
local options = {"Option 1", "Option 2", "Option 3"}
Renderer.menu(x, y, options, selected_index)
```

### Colored Message
```lua
local msg = Renderer.colors.yellow .. "Warning!" .. Renderer.colors.reset
Renderer.text(x, y, msg)
```

### Dice Roll
```lua
local damage = GameLogic.roll("1d6+2")  -- Roll 1d6+2
```

### Combat Turn
```lua
local hit, damage, dead = GameLogic.player_attack(player, enemy)
if hit then
    print("Hit for " .. damage .. " damage!")
    if dead then
        print("Enemy defeated!")
    end
end
```

## File Locations

```
dungeon_crawler/
├── game_tui.lua              # Main TUI app
├── game_tui.lua.old          # Original backup
├── src/
│   ├── tui_renderer.lua      # UI rendering
│   ├── game_logic.lua        # Game mechanics  
│   └── tui_keymaps.lua       # Keyboard config
├── TUI_REFACTORING.md        # Architecture guide
├── KEYMAP_GUIDE.md           # Keymap customization
└── CLEANUP_SUMMARY.md        # This refactoring
```

## Need Help?

- Architecture details: See `TUI_REFACTORING.md`
- Keymap customization: See `KEYMAP_GUIDE.md`
- Summary of changes: See `CLEANUP_SUMMARY.md`
- Restore original: `cp game_tui.lua.old game_tui.lua`
