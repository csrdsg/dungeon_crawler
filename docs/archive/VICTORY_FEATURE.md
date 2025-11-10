# Victory Scenario Feature

## Overview

The victory scenario feature provides a celebratory end-game experience when the player successfully completes the entire dungeon by visiting all chambers. This is distinct from the "game over" state (which triggers on player death).

## Victory Condition

**The player wins when:**
- All chambers in the dungeon have been visited (100% completion)
- Victory triggers immediately after entering or clearing the final chamber

**Victory is checked:**
1. After moving to a new chamber (`move_to_chamber()`)
2. After completing combat in any chamber (`end_combat()`)

## Implementation Details

### Files Modified

1. **`src/tui_keymaps.lua`**
   - Added `Keymaps.victory` keymap configuration
   - Added victory context descriptions
   - Added "Victory" context name

2. **`game_tui.lua`**
   - Added `victory_stats` to game state object
   - Created `draw_victory()` function for victory screen rendering
   - Created `trigger_victory()` function to transition to victory state
   - Created `check_victory()` function to detect victory condition
   - Created `handle_victory_input()` function for victory screen input
   - Added victory state to main game loop (rendering and input)
   - Integrated victory checks in `move_to_chamber()` and `end_combat()`

### Key Functions

#### `game:trigger_victory()`
Calculates final statistics and transitions to victory state.

**Statistics tracked:**
- Final level reached
- Total chambers explored (should be 100%)
- Total chambers in dungeon
- Enemies defeated
- Gold collected
- Final HP and max HP
- Potions remaining

#### `game:check_victory()`
Checks if all chambers have been visited and triggers victory if true.

**Returns:** `true` if victory triggered, `false` otherwise

#### `game:draw_victory()`
Renders the victory screen with:
- Golden trophy ASCII art
- "VICTORY!" celebration message
- Complete statistics summary
- Navigation options (New Game, Main Menu, Quit)

#### `game:handle_victory_input(key)`
Handles player input on victory screen:
- **N**: Start new game (returns to character creation)
- **M**: Return to main menu
- **Q**: Quit to desktop

## Victory Screen Layout

```
┌─────────────────────────────────────────────────┐
│                                                 │
│            ___________                          │
│           '._==_==_=_.'                         │
│           .-\:      /-.                         │
│          | (|:.     |) |                        │
│           '-|:.     |-'                         │
│             \::.    /                           │
│              '::. .'                            │
│                ) (                              │
│              _.' '._                            │
│             '-------'                           │
│                                                 │
│              VICTORY!                           │
│       You conquered the dungeon!                │
│                                                 │
└─────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  Final Statistics:                               │
│                                                  │
│  Final Level: 3                                  │
│  Chambers Cleared: 20/20 (100%!)                 │
│  Enemies Defeated: 15                            │
│  Gold Collected: 450                             │
│  Remaining HP: 28/40                             │
│  Potions Left: 1                                 │
└──────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  [N]ew Game    [M]ain Menu    [Q]uit to Desktop │
└─────────────────────────────────────────────────┘
```

## State Machine

The victory state integrates into the existing game state machine:

```
main_menu → character_creation → dungeon_size → game
                                                  ↓
                                              combat
                                                  ↓
                                    ┌─────────────┴──────────────┐
                                    ↓                            ↓
                              game_over                      victory
                              (death)                       (success)
                                    ↓                            ↓
                              [N/M/Q options]            [N/M/Q options]
```

## Victory Detection Logic

### Pseudocode
```lua
function check_victory()
    count_visited = 0
    for each chamber in dungeon do
        if chamber.visited then
            count_visited++
        end
    end

    if count_visited >= total_chambers then
        trigger_victory()
        return true
    end

    return false
end
```

### Integration Points

**1. After moving to a chamber:**
```lua
function move_to_chamber(chamber_id)
    -- Mark chamber as visited
    chamber.visited = true

    -- Check for victory immediately
    if check_victory() then
        return  -- Stop processing, victory triggered
    end

    -- Continue with encounters, etc.
end
```

**2. After combat ends:**
```lua
function end_combat(victory)
    if victory then
        -- Award loot, XP, etc.
    else
        trigger_game_over()
        return
    end

    combat_state = nil
    state = "game"

    -- Check for victory after combat
    check_victory()
end
```

## Testing

### Automated Test
Run the victory test script:
```bash
lua test_victory.lua
```

Expected output:
```
=== Testing Victory Scenario ===

Test 1: Creating player...
✓ Player created: Warrior

Test 2: Creating 5-chamber dungeon...
✓ Dungeon created with 5 chambers

Test 3: Simulating chamber exploration...
  Visited Chamber 1 - Boss Chamber
  Visited Chamber 2 - Monster Lair
  [...]

Test 4: Checking victory condition...
✓ VICTORY CONDITION MET!

Test 5: Calculating victory statistics...
✓ Victory stats calculated successfully!

Test 6: Testing partial completion...
✓ Victory correctly NOT triggered (only 3/10 chambers)

=== All Victory Tests Passed! ===
```

### Manual TUI Test

1. Start the game:
   ```bash
   ./play_tui.sh
   # or
   lua game_tui.lua
   ```

2. Create a character (any class)

3. Select **"Small (5 chambers)"** dungeon

4. Play through all 5 chambers:
   - Move between chambers (M key)
   - Fight or avoid encounters
   - Survive until all chambers are visited

5. Victory screen should appear after clearing the 5th chamber

6. Test navigation:
   - Press **N** for new game
   - Press **M** for main menu
   - Press **Q** to quit

### Edge Cases Tested

1. **Partial completion**: Victory does NOT trigger if only some chambers visited
2. **Combat in final chamber**: Victory triggers correctly after combat ends
3. **No combat in final chamber**: Victory triggers immediately upon entering
4. **Stats calculation**: All statistics are correctly captured and displayed
5. **State transition**: Victory state properly routes to character creation or main menu

## Differences from Game Over

| Feature | Game Over (Death) | Victory (Success) |
|---------|------------------|-------------------|
| **Trigger** | Player HP ≤ 0 | All chambers visited |
| **Visual** | Skull ASCII art | Trophy ASCII art |
| **Color** | Red | Yellow/Green |
| **Message** | Death reason | "You conquered the dungeon!" |
| **Stats** | Partial completion | 100% completion |
| **Tone** | Somber | Celebratory |

## Usage Example

### Typical Victory Flow

```lua
-- Player enters final chamber
move_to_chamber(20)
    ↓
-- Chamber marked as visited
chambers[20].visited = true
    ↓
-- Victory check
check_victory()
    ↓
-- All chambers visited!
chambers_visited = 20/20
    ↓
-- Trigger victory
trigger_victory()
    ↓
-- Calculate stats
victory_stats = {
    level = 5,
    chambers_explored = 20,
    total_chambers = 20,
    enemies_defeated = 18,
    gold_collected = 850,
    final_hp = 32,
    max_hp = 45,
    potions_remaining = 3
}
    ↓
-- Change state
state = "victory"
    ↓
-- Render victory screen
draw_victory()
    ↓
-- Wait for player input [N/M/Q]
```

## Future Enhancements

Potential improvements for the victory scenario:

1. **Victory Fanfare**: Play sound effects or ASCII animation
2. **Grade/Rating**: S/A/B/C rank based on performance
3. **Achievements**: Special badges for speedruns, no-damage runs, etc.
4. **Leaderboard**: Save high scores and completion times
5. **Victory Speech**: AI-generated congratulatory message
6. **Rewards**: Unlock new character classes or starting items
7. **Statistics Comparison**: Compare with previous runs
8. **Share Stats**: Export victory stats to file or screenshot

## Troubleshooting

### Victory Not Triggering

**Problem**: Completed dungeon but no victory screen

**Solutions:**
1. Verify all chambers have been visited:
   - Check dungeon progress bar shows 100%
   - Some chambers may have multiple exits
   - Backtrack to ensure no chambers skipped

2. Check for bugs:
   - Ensure `chamber.visited = true` is set
   - Verify `check_victory()` is called after moves
   - Check `chambers_visited >= num_chambers` logic

### Victory Triggers Too Early

**Problem**: Victory screen appears before 100% completion

**Solutions:**
1. Review chamber counting logic
2. Ensure visited counter matches actual visited chambers
3. Check for duplicate chamber IDs

### Victory Stats Incorrect

**Problem**: Statistics don't match actual gameplay

**Solutions:**
1. Verify `player.kills` is incremented in combat
2. Check `player.gold` includes all loot
3. Ensure `player.level` reflects progression system
4. Confirm HP values are current, not initial

## API Reference

### Functions

#### `game:trigger_victory()`
**Description**: Transitions to victory state and calculates final statistics.

**Parameters**: None

**Returns**: None

**Side Effects**:
- Sets `self.state = "victory"`
- Populates `self.victory_stats` table
- Adds victory message to log

---

#### `game:check_victory()`
**Description**: Checks if victory condition is met (all chambers visited).

**Parameters**: None

**Returns**:
- `true` if victory triggered
- `false` if not yet victorious

**Side Effects**:
- Calls `trigger_victory()` if condition met

---

#### `game:draw_victory()`
**Description**: Renders the victory screen with trophy art and statistics.

**Parameters**: None

**Returns**: None

**Side Effects**:
- Clears screen
- Draws header, trophy, stats, and footer
- Displays victory message and options

---

#### `game:handle_victory_input(key)`
**Description**: Handles player input on victory screen.

**Parameters**:
- `key` (string): The key pressed by player

**Returns**:
- `true` if player chose to quit
- `false` otherwise

**Side Effects**:
- May change game state to "character_creation" or "main_menu"
- Clears `victory_stats` when leaving victory screen

---

### Data Structures

#### `victory_stats` Table
```lua
{
    level = 5,                    -- Final player level
    chambers_explored = 20,       -- Number of chambers visited
    total_chambers = 20,          -- Total chambers in dungeon
    enemies_defeated = 18,        -- Total kills
    gold_collected = 850,         -- Total gold collected
    final_hp = 32,                -- Current HP at victory
    max_hp = 45,                  -- Maximum HP
    potions_remaining = 3         -- Potions left
}
```

## Known Limitations

1. **Time Tracking**: Play time is not currently tracked
2. **Difficulty Rating**: No difficulty scaling in victory stats
3. **Quest Completion**: Quest stats not included (quest system exists but not fully integrated)
4. **Score System**: No numerical score calculation
5. **Achievements**: No achievement system integrated

## Compatibility

- **TUI Mode**: Fully supported
- **Server Mode**: Not yet implemented (requires API endpoint)
- **Save/Load**: Victory stats are not persisted to save files
- **State Manager**: Victory state can be tracked but not currently saved

## Conclusion

The victory scenario provides a complete and satisfying conclusion to successful dungeon runs. It properly tracks player accomplishments, displays comprehensive statistics, and offers smooth navigation back to start a new game or return to the menu.

Players can now experience both defeat (game over) and triumph (victory), making the game feel more complete and rewarding.
