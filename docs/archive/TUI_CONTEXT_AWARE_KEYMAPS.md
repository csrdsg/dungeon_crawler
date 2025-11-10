# TUI Context-Aware Keymaps Implementation

## Overview

This implementation adds **context-aware keymaps** and **status lines for floating panes** to make the Dungeon Crawler TUI more intuitive. Users now see only the relevant keybindings for their current screen, making navigation clearer and reducing cognitive load.

## Features Implemented

### 1. Context-Aware Keymaps

Each game state now has its own dedicated keymap and context name:

| Context | Name | Key Actions |
|---------|------|-------------|
| `main_menu` | Main Menu | Navigate, Select, Quit |
| `character_creation` | Character Creation | Browse Classes, Select, Back |
| `dungeon_size` | Dungeon Setup | Choose Size, Start, Back |
| `load_menu` | Load Game | Browse Saves, Load, Back |
| `game` | Exploring | Move, Inventory, Search, Rest, Potion, Quest Log, Save, Quit |
| `combat` | Combat | Attack, Cast Spell, Use Potion, Run Away |
| `spell_select` | Spell Selection | Select Spell, Cast, Cancel |
| `move` | Movement | Select Chamber, Move, Cancel |
| `inventory` | Inventory | Use Potion, Close |
| `search` | Search Chamber | Search, Close |
| `quest_log` | Quest Log | Close |
| `game_over` | Game Over | New Game, Main Menu, Quit |

### 2. Status Lines for Floating Panes

Floating panes (like the AI Storyteller pane) now display status lines at the bottom showing:
- Current context/pane name
- Available actions in that context
- Navigation hints

Example:
```
╔═══════════════ 🤖 AI Storyteller ═══════════════╗
║                                                  ║
║  You enter a dark chamber. The walls are       ║
║  covered in ancient runes that glow faintly...  ║
║                                                  ║
║  Press D to dismiss                             ║
╚══════════════════════════════════════════════════╝
```

### 3. Dynamic Footer Updates

The footer now dynamically updates based on the current game state:

**Before:**
```
────────────────────────────────────────────────────
Keys: M/I/S/R/W/Q | P: Use Potion
```

**After:**
```
────────────────────────────────────────────────────
[Exploring]  M:Move | I:Inventory | S:Search | R:Rest | P:Use Potion | L:Quest Log | W:Save Game | Q:Main Menu
```

## API Reference

### Keymaps Module (`src/tui_keymaps.lua`)

#### `Keymaps.get_context_name(state)`
Returns the human-readable name for a game state.

**Parameters:**
- `state` (string): Game state identifier (e.g., "game", "combat")

**Returns:**
- (string): Display name for the context

**Example:**
```lua
local name = Keymaps.get_context_name("combat")
-- Returns: "Combat"
```

#### `Keymaps.get_context_help(context, compact)`
Returns formatted help text for a context's keybindings.

**Parameters:**
- `context` (string): Context identifier
- `compact` (boolean, optional): If true, returns compact format (key:action)

**Returns:**
- (string): Formatted help text

**Examples:**
```lua
-- Full format
local help = Keymaps.get_context_help("combat")
-- Returns: "[A] Attack  [C] Cast Spell  [P] Use Potion  [R] Run Away"

-- Compact format
local help = Keymaps.get_context_help("combat", true)
-- Returns: "A:Attack | C:Cast Spell | P:Use Potion | R:Run Away"
```

#### `Keymaps.descriptions`
Table containing all context descriptions. Each entry is an array of `{key, desc}` tables.

**Structure:**
```lua
Keymaps.descriptions = {
    combat = {
        {key = "A", desc = "Attack"},
        {key = "C", desc = "Cast Spell"},
        {key = "P", desc = "Use Potion"},
        {key = "R", desc = "Run Away"}
    },
    -- ... more contexts
}
```

### Renderer Module (`src/tui_renderer.lua`)

#### `Renderer.draw_footer(text, context_name)`
Draws the footer with optional context name.

**Parameters:**
- `text` (string): Help text to display
- `context_name` (string, optional): Context name to display in brackets

**Example:**
```lua
local context_name = Keymaps.get_context_name("combat")
local help_text = Keymaps.get_context_help("combat")
Renderer.draw_footer(help_text, context_name)
```

#### `Renderer.floating_pane(x, y, width, height, title, content, style, status_text)`
Draws a floating pane with optional status line.

**Parameters:**
- `x`, `y` (number): Position
- `width`, `height` (number): Dimensions
- `title` (string): Pane title
- `content` (table): Array of content lines
- `style` (string): Border style ("normal", "ai", "warning", "error")
- `status_text` (string, optional): **NEW** Status line text to display at bottom

**Example:**
```lua
local content = {"Line 1", "Line 2", "Line 3"}
local status = "Press Esc to close"
Renderer.floating_pane(10, 5, 50, 10, "My Pane", content, "normal", status)
```

#### `Renderer.status_line(x, y, width, context_name, keybindings)`
Draws a status line within boxes/panes.

**Parameters:**
- `x`, `y` (number): Position
- `width` (number): Maximum width
- `context_name` (string, optional): Context name to display
- `keybindings` (string|table): Keybinding text or table of {key, desc} pairs

**Example:**
```lua
Renderer.status_line(5, 20, 70, "Inventory", "P:Use Potion | Esc:Close")
```

## Usage Examples

### Adding Context-Aware Footer to a New Screen

```lua
function game:draw_my_new_screen()
    Renderer.clear_screen()
    Renderer.draw_header()

    -- ... draw screen content ...

    -- Add context-aware footer
    local context_name = Keymaps.get_context_name("my_screen")
    local help_text = Keymaps.get_context_help("my_screen")
    Renderer.draw_footer(help_text, context_name)
end
```

### Adding New Context with Keymaps

1. Define keymaps in `src/tui_keymaps.lua`:

```lua
-- Add to keymaps section
Keymaps.my_screen = {
    action1 = "a",
    action2 = "b",
    cancel = "\27"
}

-- Add descriptions
Keymaps.descriptions.my_screen = {
    {key = "A", desc = "Do Action 1"},
    {key = "B", desc = "Do Action 2"},
    {key = "Esc", desc = "Cancel"}
}

-- Add context name (in get_context_name function)
-- Update the context_names table:
my_screen = "My Screen"
```

2. Use in your screen drawing function:

```lua
function game:draw_my_screen()
    -- ... drawing code ...

    local context_name = Keymaps.get_context_name("my_screen")
    local help_text = Keymaps.get_context_help("my_screen")
    Renderer.draw_footer(help_text, context_name)
end
```

### Creating a Floating Pane with Status Line

```lua
-- Prepare content
local content_lines = {
    "This is a floating pane",
    "with multiple lines of content",
    "and a status line at the bottom"
}

-- Define status text
local status = "Press D to dismiss | Esc to close"

-- Draw the pane
Renderer.floating_pane(
    15, 8,           -- x, y position
    50, 12,          -- width, height
    "Information",   -- title
    content_lines,   -- content
    "normal",        -- style
    status           -- status line text
)
```

## Testing

Run the test suite to verify the implementation:

```bash
lua test_tui_context_keymaps.lua
```

## Benefits

### User Experience
- **Reduced Cognitive Load**: Users only see relevant keybindings
- **Faster Learning Curve**: Context names help users understand where they are
- **Better Navigation**: Clear action labels reduce mistakes
- **Professional Feel**: Context-aware UI feels polished and intentional

### Developer Experience
- **Centralized Configuration**: All keymaps in one place
- **Easy to Extend**: Adding new contexts is straightforward
- **Maintainable**: Changes to keybindings update everywhere automatically
- **Testable**: Helper functions make testing easy

### Code Quality
- **Separation of Concerns**: Keymaps separated from game logic
- **DRY Principle**: No duplicate keymap definitions
- **Consistent API**: Uniform way to handle keybindings across all screens
- **Type-Safe**: Table-based configuration reduces string typos

## Architecture

```
┌─────────────────────────────────────────────────┐
│              game_tui.lua (Main)                │
│  - Game state machine                           │
│  - Screen drawing functions                     │
│  - Input handling                               │
└────────────┬────────────────────────┬───────────┘
             │                        │
             ▼                        ▼
   ┌─────────────────┐    ┌─────────────────────┐
   │ tui_keymaps.lua │    │  tui_renderer.lua   │
   │                 │    │                     │
   │ - Keymaps       │    │ - Drawing functions │
   │ - Descriptions  │    │ - Status lines      │
   │ - Context names │    │ - Floating panes    │
   │ - Helpers       │    │ - Footer rendering  │
   └─────────────────┘    └─────────────────────┘
```

## Future Enhancements

Possible improvements for the future:

1. **Dynamic Keybindings**: Allow keybindings to change based on player state
2. **Custom Key Remapping**: Let users customize their keybindings
3. **Tooltips**: Add hover-style tooltips for actions
4. **Multi-Page Help**: F1 key to show comprehensive help overlay
5. **Keybinding History**: Show recently used keys
6. **Visual Indicators**: Highlight valid actions with colors
7. **Gamepad Support**: Extend to support controller input

## Compatibility

- **Lua Version**: 5.1+ (tested with 5.1, 5.2, 5.3, 5.4)
- **Terminal**: Any ANSI-compatible terminal
- **Dependencies**: None (uses only standard Lua libraries)

## Summary

This implementation provides a solid foundation for intuitive, context-aware navigation in the TUI. The separation of keymaps, descriptions, and rendering logic ensures maintainability while providing a better user experience through clear, context-specific guidance.
