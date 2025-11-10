# Game Over Screen Feature

## Overview

A proper game over screen has been added to the TUI, replacing the old behavior where defeat would just restart or reduce HP/gold.

## What Was Added

### Visual Elements

**Game Over Screen:**
- Skull ASCII art in red
- "GAME OVER" title
- Death reason (e.g., "Slain by Goblin Warlord")
- Final statistics summary:
  - Level reached
  - Chambers explored
  - Enemies defeated
  - Gold collected
- Three options: New Game, Main Menu, or Quit

**Visual Example:**
```
╔══════════════════════════════════════╗
║          ___________                  ║
║         /           \                 ║
║        |  X     X   |                 ║
║        |     ^      |                 ║
║        |   \___/    |                 ║
║         \_________/                   ║
║                                       ║
║         GAME OVER                     ║
║   Slain by Goblin Warlord            ║
║                                       ║
║   Final Statistics:                  ║
║     Level Reached: 5                 ║
║     Chambers Explored: 23            ║
║     Enemies Defeated: 15             ║
║     Gold Collected: 450              ║
║                                       ║
║  [N]ew Game  [M]ain Menu  [Q]uit     ║
╚══════════════════════════════════════╝
```

### Death Triggers

**Combat Death:**
- Player defeated by enemy
- Reason: "Slain by [Enemy Name]"

**Effect Death:**
- Died from poison damage
- Reason: "Died from poison"
- Died from bleeding
- Reason: "Bled to death"

**General Death:**
- HP reaches 0 from any source
- Reason: "Succumbed to wounds"

### Statistics Tracking

**New Player Stats:**
- `kills` - Number of enemies defeated (tracked)
- Chambers explored (calculated from visited chambers)
- Gold collected (from player.gold)
- Level reached (from player.level)

### Game Flow

**Old Behavior:**
```
Defeat → HP/Gold reduced → Continue playing
```

**New Behavior:**
```
Defeat → Game Over Screen → Choose:
  - [N] Start new character
  - [M] Return to main menu  
  - [Q] Quit to desktop
```

## Implementation Details

### New Functions

**game:trigger_game_over(reason)**
- Sets game_over_reason
- Calculates final statistics
- Changes state to "game_over"

**game:check_player_death()**
- Returns true if player HP <= 0
- Determines death reason from effects
- Triggers game over
- Called after effect processing

**game:draw_game_over()**
- Renders the game over screen
- Shows skull art, reason, stats
- Displays options

**game:handle_game_over_input(key)**
- N: New game (character creation)
- M: Main menu
- Q: Quit to desktop

### Modified Functions

**game:end_combat(victory)**
- On defeat: triggers game_over instead of reducing stats
- On victory: tracks kill count

**game:player_attack()**
- Checks for player death after effects
- Triggers game over if dead

### State Management

**New Game State Fields:**
```lua
game_over_reason = nil    -- String: death reason
game_over_stats = nil     -- Table: final statistics
```

**New State:**
- "game_over" - Shows game over screen

## Features

### ✅ Multiple Death Reasons
- Combat deaths show enemy name
- Poison/bleeding show specific cause
- Generic "succumbed to wounds" fallback

### ✅ Comprehensive Stats
- Level achieved
- Exploration progress
- Combat performance
- Wealth accumulated

### ✅ Player Choice
- Start fresh with new character
- Return to menu to load different save
- Exit game cleanly

### ✅ No Cheating
- Can't continue after death
- Must start over or load save
- Stats are final

## Controls

**Game Over Screen:**
- **N** - New Game (go to character creation)
- **M** - Main Menu (can load different save)
- **Q** - Quit to Desktop

## Technical Details

### Files Modified

1. **game_tui.lua**
   - Added game_over_reason and game_over_stats to state
   - Added draw_game_over() function
   - Added trigger_game_over() function
   - Added check_player_death() function
   - Added handle_game_over_input() function
   - Modified end_combat() to trigger game over
   - Modified player_attack() to check death
   - Added "game_over" to main loop
   - Track kills on victory

### Integration Points

- Triggered on combat defeat
- Triggered on HP <= 0
- Triggered on death from effects
- Prevents resurrection exploits
- Clean state transitions

## Death Messages

### Combat Deaths
```
"Slain by Goblin"
"Slain by Dragon"
"Slain by Dark Wizard"
```

### Effect Deaths
```
"Died from poison"
"Bled to death"
```

### Generic
```
"Succumbed to wounds"
```

## Statistics Display

All stats color-coded:
- Level: **Cyan**
- Chambers: **Green**
- Enemies: **Yellow**
- Gold: **Yellow**

## Benefits

### For Players
- Clear end to failed run
- See what they accomplished
- Easy to start over
- No confusion about state

### For Game
- Proper difficulty (no resurrection)
- Encourages careful play
- Stats show player progress
- Professional game feel

## Future Enhancements

Possible additions:
- [ ] High score tracking
- [ ] Death statistics (most common causes)
- [ ] Achievements based on stats
- [ ] Hall of fame for best runs
- [ ] Share stats to file
- [ ] Compare with previous runs
- [ ] Revenge mode (restart at same level)

## Testing

```bash
# Test game over trigger
lua game_tui.lua
# Lose a fight intentionally
# Verify game over screen appears
# Test N/M/Q options
```

## Notes

- Game over is **permanent** - no continuing
- Stats are calculated at time of death
- Kill tracking added in this update
- Compatible with save/load system
- Clean state management

---

**Status:** ✅ Complete and tested
**Impact:** Proper game endings, better player experience
**Difficulty:** Medium (state management)

The game now has proper endings instead of soft failures!
