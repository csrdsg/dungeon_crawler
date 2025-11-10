# Responsive TUI Design System

Complete guide to the responsive design system for the Dungeon Crawler TUI.

## Overview

The game now automatically adapts to different terminal sizes, providing an optimal experience from small 80x24 terminals to ultra-wide displays (180+ columns). The responsive system uses breakpoints, layout configurations, and adaptive rendering to ensure the game remains playable and visually appealing across all screen sizes.

## Features

- **Automatic screen size detection** - Detects terminal dimensions at startup
- **Responsive layouts** - UI components adjust based on available space
- **Breakpoint system** - 5 size classes from tiny to xlarge
- **Adaptive ASCII art** - Hides complex art on small screens
- **Dynamic text wrapping** - Adjusts text width based on screen size
- **Centered components** - All UI elements properly centered
- **Graceful degradation** - Game remains playable even on minimum size terminals

## Architecture

### Core Modules

1. **`src/tui_screen_size.lua`** - Screen size detection and management
2. **`src/tui_renderer.lua`** - Enhanced with responsive functions
3. **`game_tui.lua`** - Updated to use responsive layouts

### Screen Size Detection

The system uses two methods for detecting terminal size:

1. **Primary: `tput`** - Most reliable cross-platform method
2. **Fallback: `stty`** - Alternative if tput fails
3. **Default: 80x24** - Safe fallback if both methods fail

```lua
local ScreenSize = require("src.tui_screen_size")
local cols, rows = ScreenSize.detect()
```

### Caching

Screen size is cached for 5 seconds to avoid expensive shell calls. You can force refresh:

```lua
local cols, rows = ScreenSize.detect(true)  -- Force refresh
```

## Breakpoint System

### Size Classes

| Class    | Columns      | Rows        | Description                           |
|----------|-------------|-------------|---------------------------------------|
| `tiny`   | < 80        | < 24        | Minimal support (warning shown)       |
| `small`  | 80-99       | 24-29       | Compact mode (no ASCII art)           |
| `medium` | 100-139     | 30-44       | Standard mode (default experience)    |
| `large`  | 140-179     | 45-59       | Expanded mode (extra details)         |
| `xlarge` | 180+        | 60+         | Ultra-wide (multi-column layouts)     |

### Classification

```lua
local screen_info = ScreenSize.get_info()
print(screen_info.size_class)  -- "small", "medium", "large", etc.
print(screen_info.cols, screen_info.rows)
```

## Layout Configurations

Each size class has a specific layout configuration that controls:

- Header/footer heights
- Content area dimensions
- Border visibility
- ASCII art display
- Shadow effects
- Panel widths
- Text wrap width
- Log line limits
- Menu padding

### Example Configuration (Medium)

```lua
{
    header_height = 3,
    footer_height = 2,
    content_area_height = 25,
    show_borders = true,
    show_ascii_art = true,
    show_shadows = true,
    box_padding = 2,
    character_panel_width = 40,
    dungeon_panel_width = 50,
    text_wrap_width = 90,
    max_log_lines = 8,
    combat_log_lines = 4,
    floating_pane_max_width = 80,
    floating_pane_max_height = 15
}
```

### Accessing Layout Config

```lua
local Renderer = require("src.tui_renderer")
local layout = Renderer.get_layout()

if layout.show_ascii_art then
    -- Draw ASCII art
end
```

## Responsive Functions

### Renderer Functions

#### `Renderer.responsive_header()`
Draws a header that spans the full screen width.

```lua
Renderer.responsive_header()
```

#### `Renderer.responsive_footer(text, context_name)`
Draws a footer that adapts to screen width and truncates text if needed.

```lua
Renderer.responsive_footer("Press Q to quit", "Main Menu")
```

#### `Renderer.responsive_box(x, y, width, height, title)`
Creates a box that adjusts to screen size. Supports percentage-based dimensions.

```lua
-- Absolute dimensions
Renderer.responsive_box(10, 5, 60, 20, "Inventory")

-- Percentage-based (0.0 to 1.0)
Renderer.responsive_box("center", "center", 0.75, 0.6, "Character")

-- Auto-centered
Renderer.responsive_box("center", "center", 50, 15, "Menu")
```

#### `Renderer.responsive_floating_pane(title, content, style, status_text)`
Creates a floating pane that automatically sizes and centers based on screen size.

```lua
local content_lines = {
    "This is line 1",
    "This is line 2",
    "This is line 3"
}
Renderer.responsive_floating_pane("AI Storyteller", content_lines, "ai", "Press D to dismiss")
```

#### `Renderer.responsive_menu(x, y, options, selected)`
Menu with adaptive padding based on screen size.

```lua
local options = {"New Game", "Load Game", "Quit"}
Renderer.responsive_menu(10, 8, options, 1)
```

#### `Renderer.responsive_progress_bar(x, y, current, max, label)`
Progress bar that calculates optimal width based on available space.

```lua
Renderer.responsive_progress_bar(10, 15, player.hp, player.max_hp, "HP: ")
```

### Helper Functions

#### Get Current Screen Info
```lua
local screen_info = Renderer.get_screen_info()
print(screen_info.cols)        -- Terminal columns
print(screen_info.rows)        -- Terminal rows
print(screen_info.size_class)  -- "small", "medium", etc.
print(screen_info.is_small)    -- boolean
```

#### Get Layout Config
```lua
local layout = Renderer.get_layout()
print(layout.show_ascii_art)
print(layout.text_wrap_width)
```

#### Check Features
```lua
if Renderer.should_show_ascii_art() then
    -- Draw ASCII art
end

if Renderer.should_show_shadows() then
    -- Draw shadows
end

local max_lines = Renderer.get_max_log_lines()
local wrap_width = Renderer.get_text_wrap_width()
```

#### Column Layouts
```lua
local columns = Renderer.get_columns(2)  -- Get 2-column layout
-- Returns: {{x=2, width=38}, {x=44, width=38}}

for i, col in ipairs(columns) do
    Renderer.box(col.x, 5, col.width, 20, "Column " .. i)
end
```

#### Truncate Text
```lua
local text = "This is a very long piece of text that needs truncation"
local truncated = Renderer.truncate_text(text, 30)
-- Result: "This is a very long piece o..."
```

## Screen Size Warning

If the terminal is too small (< 80x24), a warning is automatically displayed:

```lua
-- Check and show warning if needed
if Renderer.check_screen_size() then
    -- User was shown warning, wait for key
    game:get_key()
end
```

The warning explains the issue and allows users to:
- Continue anyway
- Resize their terminal and restart

## Best Practices

### 1. Initialize Screen at Startup

```lua
local Renderer = require("src.tui_renderer")
Renderer.init_screen()
```

### 2. Use Responsive Functions

Always use responsive versions of rendering functions:

```lua
-- Good
Renderer.responsive_header()
Renderer.responsive_footer(text, context)
Renderer.responsive_box("center", "center", 60, 20, "Title")

-- Avoid (unless you have specific requirements)
Renderer.draw_header()  -- Fixed 80-col width
Renderer.box(10, 5, 60, 20, "Title")  -- Fixed position
```

### 3. Check Layout Config for Features

```lua
local layout = Renderer.get_layout()

if layout.show_ascii_art then
    -- Draw complex ASCII art
else
    -- Use simple text representation
end

local max_log_lines = layout.max_log_lines
for i = 1, math.min(#log, max_log_lines) do
    -- Display log entry
end
```

### 4. Use Percentage-Based Sizing

For boxes that should scale with screen size:

```lua
-- 75% of screen width, 60% of screen height
Renderer.responsive_box("center", "center", 0.75, 0.6, "Large Dialog")
```

### 5. Calculate Positions Dynamically

```lua
local screen_info = Renderer.get_screen_info()

-- Center a box
local box_width = 50
local box_x = math.floor((screen_info.cols - box_width) / 2)
local box_y = math.floor((screen_info.rows - 20) / 2)

Renderer.responsive_box(box_x, box_y, box_width, 20, "Centered")
```

### 6. Adapt Content to Screen Size

```lua
local layout = Renderer.get_layout()

-- Adjust text wrapping
local wrapped = Renderer.word_wrap(description, layout.text_wrap_width)

-- Limit displayed items
local max_items = layout.is_small and 5 or 10
for i = 1, math.min(#items, max_items) do
    -- Display item
end
```

### 7. Handle Tiny Screens Gracefully

```lua
local screen_info = Renderer.get_screen_info()

if screen_info.is_tiny then
    -- Show minimal UI
    Renderer.box_minimal(x, y, width, height, title)
else
    -- Show full UI
    Renderer.box(x, y, width, height, title)
end
```

## Testing Responsive Layouts

### Manual Testing

Resize your terminal window and run the game:

```bash
./play_tui.sh
```

The game will automatically detect and adapt to the new size.

### Test Specific Sizes

Use the test utility to quickly test different sizes:

```bash
lua test_responsive.lua
```

This will cycle through different terminal sizes and show how the UI adapts.

### Terminal Size Commands

```bash
# Set terminal to specific size (macOS/Linux)
printf '\e[8;24;80t'   # 80x24 (small)
printf '\e[8;30;100t'  # 100x30 (medium)
printf '\e[8;45;140t'  # 140x45 (large)

# Or use resize command (if available)
resize -s 24 80
```

### Debug Screen Info

Add this to any draw function to see current screen info:

```lua
Renderer.show_screen_debug()
```

This displays: `Screen: 100x30 | Class: medium | Layout: Standard`

## Common Patterns

### Responsive Dialog Box

```lua
function draw_dialog(title, content)
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    local width = math.min(60, screen_info.cols - 10)
    local height = math.min(20, screen_info.rows - 8)
    local x = math.floor((screen_info.cols - width) / 2)
    local y = math.floor((screen_info.rows - height) / 2)

    Renderer.responsive_box(x, y, width, height, title)

    -- Wrap content
    local wrapped = Renderer.word_wrap(content, width - 4)
    for i, line in ipairs(wrapped) do
        Renderer.text(x + 2, y + 1 + i, line)
    end
end
```

### Responsive Two-Panel Layout

```lua
function draw_two_panels()
    local columns = Renderer.get_columns(2)
    local layout = Renderer.get_layout()

    -- Left panel
    Renderer.responsive_box(columns[1].x, 5, columns[1].width, 20, "Panel 1")

    -- Right panel
    Renderer.responsive_box(columns[2].x, 5, columns[2].width, 20, "Panel 2")
end
```

### Conditional ASCII Art

```lua
function draw_chamber(chamber)
    if Renderer.should_show_ascii_art() then
        -- Draw full ASCII art
        draw_chamber_art(chamber)
    else
        -- Draw simple text representation
        Renderer.text(10, 8, "Chamber Type: " .. chamber.type)
    end
end
```

### Responsive List with Scrolling

```lua
function draw_inventory(items, offset)
    local layout = Renderer.get_layout()
    local max_items = layout.max_log_lines

    for i = 1, math.min(#items - offset, max_items) do
        local item = items[i + offset]
        Renderer.text(10, 8 + i, item.name)
    end

    if #items > max_items then
        Renderer.text(10, 8 + max_items + 1,
            Renderer.colors.dim .. "...more items..." .. Renderer.colors.reset)
    end
end
```

## Troubleshooting

### Screen Size Not Detected

If screen size detection fails:
1. The system falls back to 80x24
2. Check if `tput` is installed: `which tput`
3. Check if `stty` is available: `which stty`
4. Both commands should be available on most Unix-like systems

### UI Elements Overlapping

If UI elements overlap:
1. Check that you're using responsive functions
2. Verify box positions are calculated dynamically
3. Ensure widths/heights don't exceed screen size
4. Use `math.min()` to clamp values

### Text Truncated Unexpectedly

If text is cut off:
1. Use `Renderer.word_wrap()` for long text
2. Check `layout.text_wrap_width`
3. Ensure boxes are wide enough for content
4. Use responsive box sizing

### ASCII Art Not Showing

If ASCII art doesn't display:
1. Check `Renderer.should_show_ascii_art()`
2. Small screens disable ASCII art by default
3. Use `layout.show_ascii_art` to check
4. Provide text fallback for small screens

## Performance

### Screen Detection Overhead

- **First call**: ~10ms (shell command execution)
- **Cached calls**: < 1ms (returns cached value)
- **Cache duration**: 5 seconds
- **Cache refresh**: Automatic on timeout or forced

### Optimization Tips

1. **Initialize once at startup**: `Renderer.init_screen()`
2. **Cache layout config**: `local layout = Renderer.get_layout()`
3. **Avoid detection in loops**: Cache screen_info outside loops
4. **Force refresh only when needed**: Use `force_refresh=true` sparingly

```lua
-- Good: Cache outside loop
local layout = Renderer.get_layout()
for i = 1, 100 do
    if layout.show_ascii_art then
        -- Use cached value
    end
end

-- Bad: Detect every iteration
for i = 1, 100 do
    local layout = Renderer.get_layout()  -- Wasteful
end
```

## Configuration

### Customize Breakpoints

Edit `/Users/csrdsg/dungeon_crawler/src/tui_screen_size.lua`:

```lua
ScreenSize.breakpoints = {
    tiny = {min_cols = 0, max_cols = 79, min_rows = 0, max_rows = 23},
    small = {min_cols = 80, max_cols = 99, min_rows = 24, max_rows = 29},
    -- ... customize as needed
}
```

### Customize Layout Configs

Edit the `get_layout_config()` function in `tui_screen_size.lua` to adjust:

- Panel widths
- Text wrapping
- Log line limits
- ASCII art visibility
- Border styles

### Cache Timeout

Change cache duration (in seconds):

```lua
ScreenSize.cache_timeout = 10  -- 10 seconds instead of 5
```

## Examples

### Full Responsive Screen Example

```lua
function game:draw_custom_screen()
    Renderer.clear_screen()
    Renderer.responsive_header()

    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    -- Main content box (centered, 80% width)
    local box_width = math.floor(screen_info.cols * 0.8)
    local box_height = screen_info.rows - 10
    local box_x = math.floor((screen_info.cols - box_width) / 2)
    local box_y = 5

    Renderer.responsive_box(box_x, box_y, box_width, box_height, "Title")

    -- Content with word wrapping
    local content = "Long text that needs wrapping..."
    local wrapped = Renderer.word_wrap(content, box_width - 4)

    for i, line in ipairs(wrapped) do
        Renderer.text(box_x + 2, box_y + 1 + i, line)
    end

    -- Conditional ASCII art
    if Renderer.should_show_ascii_art() then
        draw_fancy_art(box_x + 2, box_y + 10)
    end

    -- Footer
    Renderer.responsive_footer("Press Q to quit", "Custom Screen")
end
```

## API Reference

### ScreenSize Module

| Function | Description |
|----------|-------------|
| `detect(force_refresh)` | Detect terminal size (cols, rows) |
| `get_info(force_refresh)` | Get full screen info with classification |
| `classify(cols, rows)` | Classify size into breakpoint category |
| `get_layout_config(size_class)` | Get layout config for size class |
| `get_centered_box(width, height, screen_info)` | Calculate centered box dimensions |
| `get_column_layout(num_columns, screen_info)` | Get multi-column layout |
| `is_below_minimum()` | Check if terminal is too small |
| `show_size_warning()` | Display warning for small terminals |

### Renderer Responsive Functions

| Function | Description |
|----------|-------------|
| `init_screen(force_refresh)` | Initialize screen detection |
| `get_screen_info()` | Get current screen info |
| `get_layout()` | Get layout config for current size |
| `responsive_header()` | Draw full-width header |
| `responsive_footer(text, context)` | Draw adaptive footer |
| `responsive_box(x, y, w, h, title)` | Draw adaptive box |
| `responsive_floating_pane(...)` | Draw adaptive floating pane |
| `responsive_menu(x, y, opts, sel)` | Draw adaptive menu |
| `responsive_progress_bar(...)` | Draw adaptive progress bar |
| `should_show_ascii_art()` | Check if ASCII art should display |
| `should_show_shadows()` | Check if shadows should display |
| `get_max_log_lines()` | Get max log lines for current size |
| `get_text_wrap_width()` | Get text wrap width for current size |
| `check_screen_size()` | Check and warn if screen too small |

## Migration Guide

### Converting Fixed Layouts to Responsive

**Before (Fixed):**
```lua
Renderer.clear_screen()
Renderer.draw_header()
Renderer.box(10, 5, 60, 20, "Title")
Renderer.menu(15, 8, options, selected)
Renderer.draw_footer("Press Q to quit", "Menu")
```

**After (Responsive):**
```lua
Renderer.clear_screen()
Renderer.responsive_header()

local screen_info = Renderer.get_screen_info()
local box_width = math.min(60, screen_info.cols - 10)
local box_x = math.floor((screen_info.cols - box_width) / 2)

Renderer.responsive_box(box_x, 5, box_width, 20, "Title")
Renderer.responsive_menu(box_x + 5, 8, options, selected)
Renderer.responsive_footer("Press Q to quit", "Menu")
```

## Support

For issues or questions about responsive design:

1. Check this documentation
2. Run `lua test_responsive.lua` to test different sizes
3. Use `Renderer.show_screen_debug()` to debug screen info
4. Review `/Users/csrdsg/dungeon_crawler/src/tui_screen_size.lua`

## Version History

- **v1.0** - Initial responsive design implementation
  - Screen size detection
  - Breakpoint system
  - Responsive renderer functions
  - Layout configurations
  - Automatic adaptation
