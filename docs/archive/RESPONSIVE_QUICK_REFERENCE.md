# Responsive TUI - Quick Reference

Fast reference for implementing responsive layouts in the Dungeon Crawler TUI.

## Quick Start

```lua
-- Initialize screen detection (do this once at startup)
local Renderer = require("src.tui_renderer")
Renderer.init_screen()

-- Get screen info
local screen_info = Renderer.get_screen_info()
local layout = Renderer.get_layout()

-- Use responsive functions
Renderer.responsive_header()
Renderer.responsive_footer("Help text", "Context")
Renderer.responsive_box("center", "center", 60, 20, "Title")
```

## Common Functions

### Screen Info
```lua
local screen_info = Renderer.get_screen_info()
-- screen_info.cols          (terminal columns)
-- screen_info.rows          (terminal rows)
-- screen_info.size_class    ("tiny", "small", "medium", "large", "xlarge")
-- screen_info.is_small      (boolean)
-- screen_info.is_medium     (boolean)
-- ... etc
```

### Layout Config
```lua
local layout = Renderer.get_layout()
-- layout.show_ascii_art
-- layout.show_borders
-- layout.show_shadows
-- layout.text_wrap_width
-- layout.max_log_lines
-- layout.floating_pane_max_width
-- ... etc
```

### Responsive Components

#### Header & Footer
```lua
Renderer.responsive_header()
Renderer.responsive_footer("Press Q to quit", "Main Menu")
```

#### Box
```lua
-- Centered with absolute size
Renderer.responsive_box("center", "center", 60, 20, "Title")

-- Percentage-based (75% width, 60% height)
Renderer.responsive_box("center", "center", 0.75, 0.6, "Title")

-- Explicit position
Renderer.responsive_box(10, 5, 50, 15, "Title")
```

#### Floating Pane
```lua
local content = {"Line 1", "Line 2", "Line 3"}
Renderer.responsive_floating_pane("Title", content, "ai", "Status text")
```

#### Menu
```lua
local options = {"Option 1", "Option 2", "Option 3"}
Renderer.responsive_menu(x, y, options, selected_index)
```

#### Progress Bar
```lua
Renderer.responsive_progress_bar(x, y, current, max, "Label: ")
```

### Helper Functions

```lua
-- Check features
if Renderer.should_show_ascii_art() then
    -- Draw ASCII art
end

-- Get dimensions
local max_lines = Renderer.get_max_log_lines()
local wrap_width = Renderer.get_text_wrap_width()

-- Word wrap
local wrapped = Renderer.word_wrap(long_text, wrap_width)

-- Truncate
local truncated = Renderer.truncate_text(text, max_width)

-- Column layout
local columns = Renderer.get_columns(2)  -- 2-column layout
for i, col in ipairs(columns) do
    -- col.x, col.width
end
```

## Size Classes

| Class    | Columns | Rows  | Description          |
|----------|---------|-------|----------------------|
| tiny     | < 80    | < 24  | Minimal (warning)    |
| small    | 80-99   | 24-29 | Compact (no art)     |
| medium   | 100-139 | 30-44 | Standard             |
| large    | 140-179 | 45-59 | Expanded             |
| xlarge   | 180+    | 60+   | Ultra-wide           |

## Common Patterns

### Centered Dialog
```lua
local screen_info = Renderer.get_screen_info()
local width = math.min(60, screen_info.cols - 10)
local height = math.min(20, screen_info.rows - 8)
local x = math.floor((screen_info.cols - width) / 2)
local y = math.floor((screen_info.rows - height) / 2)

Renderer.responsive_box(x, y, width, height, "Dialog")
```

### Conditional ASCII Art
```lua
if Renderer.should_show_ascii_art() then
    draw_fancy_ascii_art()
else
    draw_simple_text()
end
```

### Adaptive Text
```lua
local layout = Renderer.get_layout()
local wrapped = Renderer.word_wrap(description, layout.text_wrap_width)

for i = 1, math.min(#wrapped, layout.max_log_lines) do
    Renderer.text(x, y + i, wrapped[i])
end
```

### Two-Column Layout
```lua
local columns = Renderer.get_columns(2)

-- Left panel
Renderer.responsive_box(columns[1].x, 5, columns[1].width, 20, "Left")

-- Right panel
Renderer.responsive_box(columns[2].x, 5, columns[2].width, 20, "Right")
```

## Testing

```bash
# Run test suite
lua test_responsive.lua

# Or just run the game and resize terminal
./play_tui.sh
```

## Tips

1. **Always initialize** at startup: `Renderer.init_screen()`
2. **Cache layout config** outside loops
3. **Use responsive functions** instead of fixed versions
4. **Check layout config** for feature flags
5. **Test at different sizes** using test suite
6. **Provide fallbacks** for small screens

## File Locations

- **Module**: `/Users/csrdsg/dungeon_crawler/src/tui_screen_size.lua`
- **Renderer**: `/Users/csrdsg/dungeon_crawler/src/tui_renderer.lua`
- **Main Game**: `/Users/csrdsg/dungeon_crawler/game_tui.lua`
- **Tests**: `/Users/csrdsg/dungeon_crawler/test_responsive.lua`
- **Full Docs**: `/Users/csrdsg/dungeon_crawler/RESPONSIVE_TUI.md`

## Common Issues

**Problem**: UI elements overlap
**Solution**: Use `math.min()` to clamp sizes, use responsive functions

**Problem**: Text truncated
**Solution**: Use `Renderer.word_wrap()` with `layout.text_wrap_width`

**Problem**: ASCII art doesn't show
**Solution**: Check `Renderer.should_show_ascii_art()`, provide text fallback

**Problem**: Screen size not detected
**Solution**: Falls back to 80x24, check `tput` and `stty` availability
