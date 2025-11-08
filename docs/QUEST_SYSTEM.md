# Quest System Documentation

## Overview
The quest tracking system allows the game to manage main quests, side quests, and optional objectives with full persistence across game sessions.

## Features
- **Quest Types**: Main, Side, Optional
- **Quest Status**: Active, Completed, Failed
- **Objectives**: Track individual quest objectives with completion status
- **Rewards**: Gold and items
- **Persistence**: Quests save/load with game state
- **Quest Log**: View all active and completed quests

## Commands

### `quests` or `quest`
View your full quest log with all active and completed quests.

**Example:**
```
> quests
📜 QUEST LOG
══════════════════════════════════════════════════
🎯 ACTIVE QUESTS:
🎯 [MAIN] Free Captain Theron's Spirit
   Defeat the Iron Sentinel in Chamber 7
   Objectives:
     ✓ Locate the Iron Sentinel in the Armory
     ○ Defeat the Iron Sentinel
...
```

### `status`
Shows quest summary in character status.

## Current Quests

### Main Quests
1. **Free Captain Theron's Spirit**
   - Defeat the Iron Sentinel in Chamber 7
   - Rewards: 100 gold, Captain's Signet Ring, Blessed Sword

### Side Quests
1. **Unlock the Ancient Vault**
   - Use the Silver Key to unlock the treasure vault in Chamber 8
   - Rewards: 50 gold, Ancient Tome

2. **Map the Dungeon**
   - Explore all 10 chambers in the dungeon
   - Rewards: 25 gold, Mapper's Compass

### Optional Quests
1. **Treasure Hunter**
   - Find 100 gold pieces in the dungeon
   - Rewards: 50 gold

2. **Curious Collector**
   - Collect 5 unique items from the dungeon
   - Rewards: Collector's Bag

## Quest Progress Tracking

The system automatically tracks:
- ✓ Completed objectives (shown with checkmark)
- ○ Pending objectives (shown with circle)
- Quest completion time
- Rewards earned

## Icons & Symbols

- 🎯 Active Quest
- ✅ Completed Quest
- ❌ Failed Quest
- ✓ Completed Objective
- ○ Pending Objective
- 💰 Gold Reward
- 🎁 Item Reward

## Technical Details

### Files
- `src/quest_system.lua` - Core quest system module
- `src/initial_quests.lua` - Quest definitions
- Quest data integrated into `game_server.lua`

### Quest Data Structure
```lua
{
    id = "unique_id",
    title = "Quest Title",
    description = "Quest description",
    type = "main" | "side" | "optional",
    status = "active" | "completed" | "failed",
    objectives = {
        {id = "obj1", text = "Description", completed = false}
    },
    rewards = {
        gold = 100,
        items = {"Item Name"}
    }
}
```

### Future Enhancements
- Quest chains (quests that unlock other quests)
- Dynamic quest generation
- Quest turn-in NPCs
- Quest item tracking
- Time-limited quests
- Branching quest paths
- Quest reputation system
- Daily/weekly quests
