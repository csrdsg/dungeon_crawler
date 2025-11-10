# Keymap Customization Guide

## Overview

All keyboard controls are configured in `src/tui_keymaps.lua`. This makes it easy to customize controls to your preference.

## Current Default Keymaps

### Main Menu
- **Up Arrow**: Navigate up
- **Down Arrow**: Navigate down
- **Enter**: Select option
- **Q**: Quit

### Game Screen
- **M**: Move to another chamber
- **I**: Open inventory
- **S**: Search current chamber
- **R**: Rest (heal but risk encounter)
- **W**: Write/Save game
- **Q**: Quit to main menu
- **P**: Use health potion
- **D**: Dismiss AI description pane

### Combat
- **A**: Attack enemy
- **C**: Cast spell
- **P**: Use potion
- **R**: Run away

### Inventory
- **I**: Close inventory
- **P**: Use potion
- **Esc**: Close inventory

### Navigation (Universal)
- **Up Arrow**: Navigate up in menus
- **Down Arrow**: Navigate down in menus
- **Enter**: Select/Confirm
- **Esc**: Cancel/Go back

## How to Customize

### Example 1: WASD Movement Style

If you prefer WASD controls:

```lua
-- In src/tui_keymaps.lua
Keymaps.game = {
    move = "w",          -- Changed from "m"
    inventory = "i",
    search = "f",        -- Changed from "s" to avoid conflict
    rest = "r",
    save = "s",          -- Changed from "w"
    quit = "q",
    use_potion = "p"
}
```

### Example 2: Vim-Style Navigation

If you prefer Vim keys:

```lua
Keymaps.combat = {
    attack = "j",        -- Down/close combat
    cast_spell = "k",    -- Up/magic
    use_potion = "p",
    run = "h"           -- Left/away
}
```

### Example 3: Multiple Key Bindings

You can assign multiple keys to the same action:

```lua
Keymaps.game = {
    move = {"m", "w"},   -- Both 'm' and 'w' work
    inventory = {"i", "b"}, -- 'i' or 'b' for bag
    search = "s",
    rest = "r",
    save = {"w", "ctrl+s"}, -- Multiple save keys
    quit = "q",
    use_potion = "p"
}
```

### Example 4: Gaming Keyboard Layout

For dedicated gaming keyboards:

```lua
Keymaps.combat = {
    attack = "1",        -- Number keys
    cast_spell = "2",
    use_potion = "3",
    run = "4"
}

Keymaps.game = {
    move = "1",
    inventory = "2",
    search = "3",
    rest = "4",
    save = "F5",        -- Function key for save
    quit = "q",
    use_potion = "5"
}
```

## Key Codes Reference

### Regular Keys
- Letters: `"a"`, `"b"`, `"c"`, etc. (lowercase)
- Numbers: `"1"`, `"2"`, `"3"`, etc.
- Special: `"/"`, `"."`, `","`, etc.

### Special Keys
- Enter: `"\n"` or `"\r"`
- Escape: `"\27"`
- Space: `" "`

### Arrow Keys
- Up: `"\27[A"`
- Down: `"\27[B"`
- Right: `"\27[C"`
- Left: `"\27[D"`

## Helper Functions

The keymaps module provides helper functions:

```lua
-- Check if key matches an action
if Keymaps.matches(key, Keymaps.game, "move") then
    -- Do move action
end

-- Check for arrow keys
if Keymaps.is_up(key, next1, next2) then
    -- Handle up arrow
end

if Keymaps.is_down(key, next1, next2) then
    -- Handle down arrow
end

-- Check for ESC (not arrow)
if Keymaps.is_escape_only(key, next1) then
    -- Handle escape
end
```

## Tips

1. **Test Your Changes**: After modifying keymaps, test all screens to ensure no conflicts
2. **Avoid Conflicts**: Don't use the same key for different actions in the same screen
3. **Keep It Intuitive**: Use keys that make sense for the action (A for Attack, I for Inventory)
4. **Document Changes**: If you customize heavily, keep notes of your changes
5. **Backup Original**: Keep a copy of the original keymaps file

## Common Customizations

### Left-Handed Layout
```lua
Keymaps.combat = {
    attack = "j",
    cast_spell = "k",
    use_potion = "l",
    run = "i"
}
```

### Numpad Combat
```lua
Keymaps.combat = {
    attack = "8",    -- Numpad up
    cast_spell = "4", -- Numpad left
    use_potion = "6", -- Numpad right
    run = "2"        -- Numpad down
}
```

### Speed Runner Layout (Single Hand)
```lua
Keymaps.game = {
    move = "1",
    inventory = "2",
    search = "3",
    rest = "4",
    save = "5",
    quit = "q",
    use_potion = "p"
}
```

## Resetting to Defaults

If you mess up the keymaps, restore from the original:

```bash
git checkout src/tui_keymaps.lua
```

Or manually reset to these defaults:

```lua
Keymaps.game = {
    move = "m",
    inventory = "i",
    search = "s",
    rest = "r",
    save = "w",
    quit = "q",
    use_potion = "p"
}

Keymaps.combat = {
    attack = "a",
    cast_spell = "c",
    use_potion = "p",
    run = "r"
}
```
