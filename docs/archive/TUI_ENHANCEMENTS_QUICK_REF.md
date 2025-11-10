# TUI Enhancements - Quick Reference

## What Was Implemented

### 1. Local Keymaps for Floating Panes and Screens
Every screen/pane now has context-specific keybindings that display only relevant actions.

### 2. Status Lines for Floating Panes
Floating panes show status information at the bottom with available actions.

### 3. Context-Aware Footers
The footer updates dynamically to show the current context and its keybindings.

## Quick Test

```bash
# Run the comprehensive test
lua test_tui_context_keymaps.lua

# Launch the game to see it in action
lua game_tui.lua
```

## What You'll Notice

### Before
- Generic footer: "Keys: M/I/S/R/W/Q | P: Use Potion"
- All keybindings shown at once
- No context indication

### After
- Context-aware footer: "[Exploring] M:Move | I:Inventory | S:Search | R:Rest | P:Use Potion | L:Quest Log | W:Save Game | Q:Main Menu"
- Only relevant keybindings shown
- Clear context name in brackets

## Context Names by Screen

| Screen | Context Name | Example Keybindings |
|--------|--------------|---------------------|
| Main Menu | Main Menu | Navigate, Select, Quit |
| Character Creation | Character Creation | Browse Classes, Select, Back |
| Exploring | Exploring | Move, Inventory, Search, Rest, Potion, Log, Save, Quit |
| Combat | Combat | Attack, Cast Spell, Use Potion, Run Away |
| Inventory | Inventory | Use Potion, Close |
| Movement | Movement | Select Chamber, Move, Cancel |
| Spell Select | Spell Selection | Select Spell, Cast, Cancel |
| Search | Search Chamber | Search, Close |
| Quest Log | Quest Log | Close |
| Game Over | Game Over | New Game, Main Menu, Quit |

## Modified Files

1. **src/tui_keymaps.lua**
   - Added context descriptions for all screens
   - Added `get_context_help()` function
   - Added `get_context_name()` function
   - Expanded keymap definitions

2. **src/tui_renderer.lua**
   - Updated `draw_footer()` to support context names
   - Updated `floating_pane()` to support status lines
   - Added `status_line()` function for inline status displays

3. **game_tui.lua**
   - Updated all `draw_*()` functions to use context-aware footers
   - Updated AI pane to show status line
   - All screens now display context-specific help

## Code Patterns

### Pattern 1: Add Context-Aware Footer to Screen
```lua
function game:draw_my_screen()
    Renderer.clear_screen()
    Renderer.draw_header()

    -- ... screen content ...

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("my_screen")
    local help_text = Keymaps.get_context_help("my_screen")
    Renderer.draw_footer(help_text, context_name)
end
```

### Pattern 2: Floating Pane with Status Line
```lua
local content = {"Line 1", "Line 2"}
local status = "Press Esc to close"
Renderer.floating_pane(x, y, width, height, "Title", content, "normal", status)
```

### Pattern 3: Define New Context
```lua
-- In src/tui_keymaps.lua

-- 1. Add keymaps
Keymaps.my_context = {
    action = "a",
    cancel = "\27"
}

-- 2. Add descriptions
Keymaps.descriptions.my_context = {
    {key = "A", desc = "Do Action"},
    {key = "Esc", desc = "Cancel"}
}

-- 3. Add context name (in get_context_name function)
-- Update the context_names table:
my_context = "My Context"
```

## Visual Examples

### Main Menu
```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          🏰 DUNGEON CRAWLER 🏰                                ║
╚═══════════════════════════════════════════════════════════════════════════════╝
┌──────────────────────── MAIN MENU ────────────────────────┐
│                                                            │
│    ▶ New Game                                             │
│      Load Game                                            │
│      Character Templates                                  │
│      Statistics                                           │
│      Quit                                                 │
└────────────────────────────────────────────────────────────┘
────────────────────────────────────────────────────────────
[Main Menu]  [↑↓] Navigate  [Enter] Select  [Q] Quit
```

### Combat Screen
```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          🏰 DUNGEON CRAWLER 🏰                                ║
╚═══════════════════════════════════════════════════════════════════════════════╝
┌──────────────────────── ENEMY ─────────────────────────┐
│     /\     /\                                          │
│    |  \   /  |                                         │
│    |   \ /   |                                         │
│     \  |||  /          Goblin                         │
│      \ ||| /                                           │
│       \|||/           HP: [████████░░] 80/100         │
└────────────────────────────────────────────────────────┘
────────────────────────────────────────────────────────────
[Combat]  [A] Attack  [C] Cast Spell  [P] Use Potion  [R] Run Away
```

### Inventory Screen
```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                          🏰 DUNGEON CRAWLER 🏰                                ║
╚═══════════════════════════════════════════════════════════════════════════════╝
┌────────────────────────── INVENTORY ───────────────────────────┐
│  Resources:                                                    │
│    Gold: 150                                                   │
│    Potions: 3 [Press P to use]                               │
│                                                                │
│  Items:                                                        │
│    • Ancient Sword                                            │
│    • Magic Shield                                             │
└────────────────────────────────────────────────────────────────┘
────────────────────────────────────────────────────────────
[Inventory]  [P] Use Potion  [I/Esc] Close
```

### AI Storyteller Pane (with Status Line)
```
         ╔═════════════ 🤖 AI Storyteller ══════════════╗
         ║                                              ║
         ║  You enter a dark chamber. The walls are    ║
         ║  covered in ancient runes that glow         ║
         ║  faintly in the torchlight. The air is      ║
         ║  thick with the scent of incense and old    ║
         ║  magic. In the center of the room...        ║
         ║                                              ║
         ║  Press D to dismiss                          ║
         ╚══════════════════════════════════════════════╝
```

## Key Improvements

1. **Intuitive Navigation**: Users always know what keys are available
2. **Reduced Clutter**: No overwhelming list of all possible keys
3. **Better Learning**: Context names help users understand where they are
4. **Professional Polish**: Dynamic help system feels responsive and modern
5. **Easy Maintenance**: Adding new screens/contexts is straightforward

## Testing Checklist

- [x] All screens show context names
- [x] Footer updates based on current screen
- [x] Floating panes support status lines
- [x] AI pane shows dismiss hint
- [x] All keymaps function correctly
- [x] Context help displays properly
- [x] No syntax errors in modified files
- [x] Test suite passes all checks

## Performance

- **No Performance Impact**: All context lookups are simple table reads
- **Memory Efficient**: Descriptions are static tables, not generated dynamically
- **Fast Rendering**: No additional rendering overhead

## Compatibility

- Works with existing TUI architecture
- No breaking changes to existing code
- Backward compatible with old screen rendering
- All existing keybindings still work
