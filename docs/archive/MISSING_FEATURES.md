# Missing Features in TUI Version

Based on codebase analysis, the following features exist in the game modules but are **not yet integrated** into the TUI interface (`game_tui.lua`).

## 📊 High Priority Missing Features

### 1. Progression/Leveling System ⭐⭐⭐

**Module:** `src/progression.lua` (EXISTS)  
**Status:** Not integrated into TUI

**What's Missing:**
- Experience points (XP) tracking from combat victories
- Level up notifications and UI
- Stat increases on level up
- Visual XP bar in character panel
- Level-based difficulty scaling

**Current TUI Behavior:**
- Enemies give XP (stored in `enemy.xp`)
- XP is logged but never tracked or accumulated
- No leveling system active
- Players stay level 1 forever

**Integration Needed:**
```lua
-- Add to player state
player.xp = 0
player.level = 1
player.next_level_xp = 1000

-- After combat victory
player.xp = player.xp + enemy.xp
if player.xp >= player.next_level_xp then
    level_up(player)
end

-- Add level display to character panel
-- Add XP progress bar
```

---

### 2. Status Effects System ⭐⭐⭐

**Module:** `src/effects.lua` (EXISTS)  
**Status:** Not integrated into TUI

**Available Effects:**
- `bleeding` - Damage over time
- `stunned` - Cannot act next turn
- `poison` - Poison damage each turn
- `strength` - +2 to attack rolls
- `regeneration` - Heal over time
- `curse` - Penalties to actions

**What's Missing:**
- Effect application in combat
- Effect tracking on player/enemies
- Visual indicators for active effects
- Turn-by-turn effect processing
- Effect icons or symbols in UI

**Current TUI Behavior:**
- No status effects in combat
- Spells can't apply debuffs
- Traps don't cause lingering effects
- Combat is simpler than it could be

**Integration Needed:**
```lua
-- Track effects on player and enemies
player.effects = {}
enemy.effects = {}

-- Process effects each combat turn
-- Display active effects in combat UI
-- Show effect icons/text
```

---

### 3. Quest System UI ⭐⭐

**Module:** `src/quest_system.lua` (EXISTS, partially integrated)  
**Status:** Structure exists but not visible

**What's Missing:**
- Quest log screen/viewer
- Active quest display
- Quest completion notifications
- Quest objectives tracker
- Quest rewards UI
- Quest progress indicators

**Current TUI Behavior:**
- Quest structure exists in code
- No way to view quests in TUI
- Quest log is tracked but invisible
- Players don't know their objectives

**Integration Needed:**
```lua
-- Add quest log screen (press Q)
-- Show active quests in UI
-- Display quest objectives
-- Track completion status
-- Show quest rewards
```

---

## 💬 Medium Priority Missing Features

### 4. Dialogue System ⭐⭐

**Module:** `src/dialogue_system.lua` (EXISTS)  
**Status:** Not integrated into TUI

**What's Missing:**
- NPC conversations
- Dialogue choice menus in TUI
- Story-driven interactions
- Dialogue trees
- Character interactions

**Current Implementation:**
- Dialogue system is fully functional
- Used in CLI/server versions
- Has branching dialogue trees
- Supports conditions and consequences
- Has dialogue data in `data/dialogue_content.lua`

**Integration Needed:**
```lua
-- Add dialogue screen state
-- Create dialogue choice UI
-- Connect friendly encounters to dialogue
-- Add NPC interaction mechanic
```

---

### 5. Statistics Tracking ⭐⭐

**Module:** `src/stats_db.lua` (EXISTS)  
**Status:** Not integrated into TUI

**Features Available:**
- SQLite database tracking
- Session statistics
- Achievement tracking
- Combat statistics
- Death statistics
- Item usage tracking

**What's Missing:**
- No stats saved to database from TUI
- No achievement notifications
- No statistics viewer
- No session history

**Integration Needed:**
```lua
-- Initialize stats_db on game start
-- Track combat events
-- Save session data
-- Add statistics screen (press T)
```

---

## 🎒 Low Priority Missing Features

### 6. Item Effects System ⭐

**Module:** `src/item_effects.lua` (May not exist as standalone)  
**Status:** Partially in inventory/loot

**What's Missing:**
- Special item abilities beyond healing potions
- Equipment stat bonuses
- Consumable item variety
- Item synergies
- Unique item effects

**Current TUI Behavior:**
- Items are stored but mostly decorative
- Only health potions have effects
- No equipment bonuses
- No special consumables

---

### 7. Advanced Trap System ⭐

**Module:** `src/traps.lua` (EXISTS)  
**Status:** Basic integration only

**What's Available in Module:**
- 10 different trap types
- Detection mechanics (DC checks)
- Disarm mechanics
- Variety of damage types
- Trap descriptions

**What's Missing in TUI:**
- Only basic trap trigger on room entry
- No trap detection UI
- No disarm attempts
- No trap variety (just generic damage)
- No skill-based trap interaction

**Current TUI Behavior:**
```lua
-- Simple trap check
if math.random(1, 100) <= TUIConfig.trap.chance then
    local damage = GameLogic.roll(TUIConfig.trap.damage)
    player.hp = player.hp - damage
end
```

**Could Be:**
```lua
-- Show trap type
-- Allow detection attempt
-- Allow disarm attempt
-- Different effects per trap type
```

---

## ✅ Features Already Implemented

For comparison, these ARE working in TUI:

1. ✅ **Combat System** - Full D&D-style combat
2. ✅ **Magic/Spells** - Spell casting with mana
3. ✅ **Dungeon Generation** - Procedural chambers
4. ✅ **Loot System** - Quality-based loot tables
5. ✅ **Search Mechanics** - Chamber searching
6. ✅ **Rest System** - Healing with encounter risk
7. ✅ **Save/Load** - State persistence
8. ✅ **AI Storyteller** - AI descriptions (with floating pane!)
9. ✅ **Inventory** - Item management
10. ✅ **Character Classes** - 6 classes with unique abilities

---

## 🎯 Recommended Implementation Order

Based on player impact and implementation difficulty:

### Phase 1: Core Gameplay Enhancement
1. **Progression System** (High impact, medium effort)
   - Players need progression to feel rewarded
   - Adds long-term engagement
   
2. **Status Effects** (High impact, medium effort)
   - Makes combat more strategic
   - Enables more spell variety

### Phase 2: Content & Engagement
3. **Quest Display** (Medium impact, low effort)
   - System exists, just needs UI
   - Gives players clear objectives

4. **Dialogue System** (Medium impact, high effort)
   - Adds story depth
   - Enables better NPC interactions

### Phase 3: Polish & Depth
5. **Statistics Tracking** (Low impact, low effort)
   - Nice for achievement hunters
   - Provides session replay value

6. **Item Effects** (Low impact, medium effort)
   - Adds variety to items
   - Makes loot more interesting

7. **Advanced Traps** (Low impact, low effort)
   - Enhances dungeon exploration
   - Adds skill-based gameplay

---

## 📋 Quick Integration Checklist

For each feature to add to TUI:

- [ ] Import module into `game_tui.lua`
- [ ] Add state tracking to `game` object
- [ ] Create UI screen/panel for feature
- [ ] Add input handlers
- [ ] Add to main game loop
- [ ] Update footer/help text
- [ ] Add keybind to `src/tui_keymaps.lua`
- [ ] Test integration
- [ ] Update documentation

---

## 🔗 Related Files

- **Progression:** `src/progression.lua`, `docs/GAMEPLAY_SYSTEMS.md`
- **Effects:** `src/effects.lua`
- **Quests:** `src/quest_system.lua`, `docs/QUEST_SYSTEM.md`
- **Dialogue:** `src/dialogue_system.lua`, `data/dialogue_content.lua`
- **Stats:** `src/stats_db.lua`, `docs/DATABASE_TRACKING.md`
- **Traps:** `src/traps.lua`

---

## 💡 Notes

The good news: **All the hard work is done!** The modules exist and are well-tested. Integration is mainly about:
1. Adding UI elements
2. Connecting existing modules
3. Managing state

The TUI architecture refactoring (with separated renderer, logic, and keymaps) makes adding these features much easier than before!
