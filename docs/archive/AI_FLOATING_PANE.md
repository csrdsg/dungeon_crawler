# AI Storyteller Floating Pane Feature

## Overview

The AI-generated chamber descriptions now appear in a floating pane overlay instead of being mixed into the message log. This makes the AI narrative more prominent and easier to read.

## How It Works

When you enter a new chamber with AI Storyteller enabled, the description will appear in a floating overlay panel in the center of the screen.

## Visual Design

```
┌─────────────────────────────────────────┐
│           Main Game Screen              │
│  ╔════════ 🤖 AI Storyteller ═════════╗ │
│  ║                                     ║ │
│  ║  You enter a dimly lit chamber...  ║ │
│  ║  Ancient tapestries line the       ║ │
│  ║  walls, depicting forgotten        ║ │
│  ║  battles. The air is thick with    ║ │
│  ║  mystery...                         ║ │
│  ║                                     ║ │
│  ║  [Press D to dismiss]               ║ │
│  ╚═════════════════════════════════════╝ │
└─────────────────────────────────────────┘
```

## Features

### 🎨 Visual Design
- **Floating overlay** - Appears on top of game screen
- **Shadow effect** - Creates depth with subtle shadow
- **Magenta border** - Distinctive AI storyteller color scheme
- **Word wrapping** - Automatically wraps long descriptions
- **Centered position** - Draws attention to the narrative

### 📝 Content
- **AI-generated descriptions** - When available from Ollama
- **Chamber context** - Based on chamber type and game state
- **Dismissible** - Press 'D' to close the pane
- **Cached** - Description cached per chamber

### ⌨️ Controls
- **D** - Dismiss the AI description pane
- **Move to new chamber** - Shows new AI description
- **Auto-dismiss** - Dismissed when viewing other screens

## When Does It Appear?

The AI floating pane appears when:
1. ✅ AI Storyteller is enabled
2. ✅ You enter a new chamber
3. ✅ AI successfully generates a description
4. ✅ You're on the main game screen

It will NOT appear when:
- ❌ AI Storyteller is disabled
- ❌ AI fails to generate description
- ❌ In menus, inventory, or other screens
- ❌ After you dismiss it with 'D'

## Configuration

Enable/disable AI Storyteller in the game:

```lua
-- In game initialization
local AIStoryteller = load_module_safe("src.ai_storyteller")
if AIStoryteller then
    local ai_enabled = AIStoryteller.init({
        enabled = true,           -- Set to false to disable
        provider = "ollama",
        model = "llama3.2:3b",
        use_static_on_error = true,
        timeout = 5
    })
end
```

## Technical Details

### New Components

**Renderer Module** (`src/tui_renderer.lua`):
- `Renderer.floating_pane(x, y, width, height, title, content, style)` - Draw floating overlay
- `Renderer.word_wrap(text, width)` - Word wrap text to fit width

**Game State** (`game_tui.lua`):
- `game.ai_description` - Stores current AI description
- `game.show_ai_pane` - Controls pane visibility

### Keymap

**New Key** (`src/tui_keymaps.lua`):
```lua
Keymaps.game = {
    ...
    dismiss_ai = "d"  -- Dismiss AI description pane
}
```

## Customization

### Change Pane Size

Edit `game_tui.lua`, function `draw_game_screen()`:

```lua
local pane_width = 60   -- Change width (max 78)
local pane_height = 10  -- Change height (max 20)
```

### Change Pane Position

```lua
local pane_x = math.floor((80 - pane_width) / 2) + 2  -- Centered
local pane_y = 8  -- Vertical position
```

### Change Color Scheme

Edit `src/tui_renderer.lua`, function `floating_pane()`:

```lua
if style == "ai" then
    border_color = Renderer.colors.cyan  -- Change from magenta
end
```

### Disable Auto-Show

To prevent auto-showing on chamber entry, edit `move_to_chamber()`:

```lua
if description then
    self.ai_description = description
    self.show_ai_pane = false  -- Changed from true
    self:add_log("AI description available - press D to view")
end
```

## Example Usage

### In Game Flow

1. Start new game → AI description appears for starting chamber
2. Press 'D' to dismiss and continue playing
3. Move to new chamber → New AI description appears
4. Press 'D' again to dismiss

### For Modders

Create custom floating panes for other purposes:

```lua
-- Custom lore pane
local lore_content = Renderer.word_wrap(lore_text, 56)
local content_lines = {}
for _, line in ipairs(lore_content) do
    table.insert(content_lines, Renderer.colors.yellow .. line)
end

Renderer.floating_pane(10, 6, 60, 12, "📜 Ancient Lore", content_lines, "warning")
```

## Benefits

### For Players
- **More immersive** - AI narratives are highlighted
- **Easy to read** - Word-wrapped and well-formatted
- **Not intrusive** - Can be dismissed quickly
- **Visual distinction** - Clearly separate from game logs

### For Developers
- **Reusable component** - Floating pane for any content
- **Clean separation** - AI content doesn't clutter logs
- **Extensible** - Easy to add more pane types
- **Configurable** - Size, position, style all customizable

## Future Enhancements

Potential improvements:
1. **Multiple panes** - Stack or queue multiple AI messages
2. **Animation** - Fade in/out effects
3. **History** - Press 'H' to view previous AI descriptions
4. **Rich formatting** - Bold, italics in AI text
5. **Interactive choices** - AI-generated decision points
6. **Theme support** - Different color schemes per chamber type

## Troubleshooting

### Pane doesn't appear
- Check if AI Storyteller is enabled
- Verify Ollama is running: `ollama list`
- Check timeout isn't too short (increase in config)

### Text is cut off
- Increase `pane_height` in `draw_game_screen()`
- Or decrease description length in AI config

### Pane looks weird
- Ensure terminal supports Unicode box drawing
- Check terminal size is at least 80x25

## Related Files

- `src/tui_renderer.lua` - Floating pane component
- `src/tui_keymaps.lua` - Dismiss key binding
- `game_tui.lua` - Integration and state management
- `src/ai_storyteller.lua` - AI description generation
