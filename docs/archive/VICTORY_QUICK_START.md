# Victory Feature - Quick Start Guide

## What Was Implemented

A complete "you won" victory scenario for the Dungeon Crawler game that triggers when players complete all chambers in the dungeon (100% completion).

## Key Features

- Victory condition: Complete all chambers in dungeon
- Celebratory victory screen with trophy ASCII art
- Comprehensive statistics display
- Navigation options: New Game, Main Menu, Quit
- Victory detection after both chamber movement and combat
- Distinct from "game over" (death) state

## How to Test

### Quick Test (5 minutes)

1. Start the game:
   ```bash
   lua game_tui.lua
   ```

2. Create a character (any class)

3. Select **"Small (5 chambers)"** dungeon

4. Play through all 5 chambers

5. Victory screen appears after clearing the final chamber!

### Automated Test

```bash
lua test_victory.lua
```

All tests should pass with green checkmarks.

## Files Modified

### 1. `/Users/csrdsg/dungeon_crawler/src/tui_keymaps.lua`

Added victory keymaps and context:
- Victory key bindings (N/M/Q)
- Victory context descriptions
- Victory state name

### 2. `/Users/csrdsg/dungeon_crawler/game_tui.lua`

**New State Variables:**
```lua
victory_stats = nil  -- Stores final statistics
```

**New Functions:**
- `game:trigger_victory()` - Transitions to victory state with stats
- `game:check_victory()` - Checks if all chambers visited
- `game:draw_victory()` - Renders victory screen
- `game:handle_victory_input(key)` - Handles victory screen input

**Modified Functions:**
- `game:move_to_chamber()` - Added victory check after chamber visit
- `game:end_combat()` - Added victory check after combat
- `game:run()` - Added victory state to main game loop

### 3. New Test File: `/Users/csrdsg/dungeon_crawler/test_victory.lua`

Automated test script that validates:
- Player creation
- Dungeon generation
- Chamber visiting simulation
- Victory condition detection
- Statistics calculation
- Partial completion (should NOT trigger victory)

## Victory Screen Preview

```
       ___________
      '._==_==_=_.'
      .-\:      /-.
     | (|:.     |) |
      '-|:.     |-'
        \::.    /
         '::. .'
           ) (
         _.' '._
        '-------'

              VICTORY!
       You conquered the dungeon!

┌──────────────────────────────────────────────┐
│  Final Statistics:                           │
│                                              │
│  Final Level: 3                              │
│  Chambers Cleared: 20/20 (100%!)             │
│  Enemies Defeated: 15                        │
│  Gold Collected: 450                         │
│  Remaining HP: 28/40                         │
│  Potions Left: 1                             │
└──────────────────────────────────────────────┘

[N]ew Game    [M]ain Menu    [Q]uit to Desktop
```

## Victory Controls

| Key | Action |
|-----|--------|
| **N** | Start New Game (character creation) |
| **M** | Return to Main Menu |
| **Q** | Quit to Desktop |

## Victory Detection Logic

Victory triggers when:
```lua
chambers_visited >= total_chambers
```

Checks happen at:
1. After entering a new chamber
2. After winning combat

## Statistics Tracked

- **Level**: Final character level (with progression system)
- **Chambers Explored**: Count of visited chambers / total chambers (100%)
- **Enemies Defeated**: Total kill count
- **Gold Collected**: Total gold accumulated
- **Final HP**: Remaining health / max health
- **Potions Remaining**: Unused healing potions

## State Machine Flow

```
main_menu → character_creation → dungeon_size → game → combat
                                                          ↓
                                                    game_over (death)
                                                          or
                                                     victory (success)
                                                          ↓
                                                    [N] → character_creation
                                                    [M] → main_menu
                                                    [Q] → quit
```

## Integration Points

### Victory Check in Movement
```lua
function game:move_to_chamber(chamber_id)
    chamber.visited = true

    -- Victory check
    if self:check_victory() then
        return  -- Stop processing, show victory screen
    end

    -- Continue with encounters...
end
```

### Victory Check After Combat
```lua
function game:end_combat(victory)
    -- Award loot, XP, etc.

    self.combat_state = nil
    self.state = "game"

    -- Check for victory
    self:check_victory()
end
```

## Troubleshooting

### Victory Not Appearing?

1. Make sure you visited ALL chambers (check progress bar = 100%)
2. Some dungeons have branching paths - backtrack if needed
3. Victory triggers after the final chamber is visited

### Stats Look Wrong?

- Kill count may be 0 if you avoided combat
- Gold depends on loot found and enemies defeated
- HP reflects damage taken during adventure
- Level depends on whether progression system is active

## Next Steps

The victory feature is fully implemented and tested. You can:

1. **Play through a dungeon** to experience the victory screen
2. **Customize the trophy art** in `game_tui.lua` → `draw_victory()`
3. **Add more stats** to `victory_stats` table
4. **Extend functionality** (see VICTORY_FEATURE.md for ideas)

## Quick Reference: Code Locations

| Feature | File | Line (approx) |
|---------|------|---------------|
| Victory state var | `game_tui.lua` | ~79 |
| draw_victory() | `game_tui.lua` | ~732-815 |
| trigger_victory() | `game_tui.lua` | ~921-945 |
| check_victory() | `game_tui.lua` | ~947-967 |
| handle_victory_input() | `game_tui.lua` | ~1575-1593 |
| Victory keymaps | `src/tui_keymaps.lua` | ~111-116, ~195-199 |
| Victory detection | `game_tui.lua` | ~1213, ~1183 |

## Performance Notes

- Victory check is O(n) where n = number of chambers
- Runs once per chamber visit (minimal overhead)
- Stats calculation is lightweight
- No performance impact on gameplay

## Documentation

- **Full Documentation**: `VICTORY_FEATURE.md`
- **Test Script**: `test_victory.lua`
- **This Guide**: `VICTORY_QUICK_START.md`

---

**Victory Feature Status: COMPLETE AND TESTED**

Enjoy conquering dungeons and achieving victory!
