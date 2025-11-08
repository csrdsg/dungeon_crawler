# Quest System Architecture

## Overview
The quest system has been refactored to decouple quest logic from game commands, making it easier to add new quests and track progress.

## Architecture

### 1. **QuestSystem** (`src/quest_system.lua`)
Core quest management module:
- Quest data structures
- Quest CRUD operations
- Objective tracking
- Quest serialization/deserialization
- Quest formatting for display

### 2. **QuestHandler** (`src/quest_handler.lua`)
Event-driven quest completion logic:
- Listens for game events
- Checks completion conditions
- Awards rewards
- Generates notifications
- **Decoupled from game commands**

### 3. **InitialQuests** (`src/initial_quests.lua`)
Quest definitions:
- Defines all available quests
- Sets objectives and rewards
- Initializes quest log

### 4. **Game Server** (`game_server.lua`)
Triggers quest events:
- Fires events when actions occur
- Passes events to QuestHandler
- Displays quest notifications

## Event System

### Game Events → Quest Completion

| Event Type | Trigger | Quest(s) Affected |
|------------|---------|-------------------|
| `gold_gained` | Player finds gold | Treasure Hunter |
| `item_gained` | Player finds item | Curious Collector |
| `chamber_entered` | Player enters chamber | Map the Dungeon |
| `vault_unlocked` | Player unlocks vault | Unlock the Ancient Vault |
| `boss_defeated` | Player defeats boss | Free Captain Theron's Spirit |

### How It Works

1. **Command Execution**: Player runs command (search, move, etc.)
2. **Event Trigger**: Command triggers game event
3. **Quest Check**: QuestHandler checks if event completes quests
4. **Reward Grant**: If quest completed, rewards granted automatically
5. **Notification**: Player sees quest completion message

## Adding New Quests

### Step 1: Define Quest (`src/initial_quests.lua`)

```lua
quests.my_quest = QuestSystem.create_quest("my_quest_id", {
    title = "My Quest Title",
    description = "Quest description",
    type = QuestSystem.TYPE.SIDE, -- or MAIN, OPTIONAL
    status = QuestSystem.STATUS.ACTIVE,
    objectives = {
        {id = "obj1", text = "Do something", completed = false}
    },
    rewards = {
        gold = 100,
        items = {"Reward Item"}
    }
})
```

### Step 2: Add Completion Logic (`src/quest_handler.lua`)

```lua
-- In check_quest_completion function
if event_type == "my_event" then
    local quest = QuestSystem.get_quest(session.quest_log, "my_quest_id")
    if quest and quest.status == QuestSystem.STATUS.ACTIVE then
        QuestSystem.complete_objective(quest, "obj1")
        local success, completed_quest = QuestSystem.complete_quest(session.quest_log, "my_quest_id")
        if success then
            -- Grant rewards
            player.gold = player.gold + 100
            table.insert(player.items, "Reward Item")
            -- Add notifications
            table.insert(notifications, "🎉 QUEST COMPLETED: My Quest Title!")
            table.insert(notifications, "💰 Reward: 100 gold!")
        end
    end
end
```

### Step 3: Trigger Event (in `game_server.lua`)

```lua
-- In command handler
local quest_notifications = QuestHandler.check_quest_completion(session, "my_event", event_data)
for _, msg in ipairs(quest_notifications) do
    table.insert(response, msg)
end
```

## Benefits

### ✅ Separation of Concerns
- Quest logic separated from game commands
- Easy to modify quest conditions
- No server code changes for new quests

### ✅ Event-Driven
- Quests react to game events
- Multiple quests can trigger from same event
- Flexible completion conditions

### ✅ Maintainability
- All quest definitions in one file
- Quest completion logic centralized
- Easy to debug

### ✅ Extensibility
- Add new event types easily
- Create complex quest chains
- Support for prerequisites

## Future Enhancements

- **Quest Chains**: Quests that unlock other quests
- **Quest Prerequisites**: Require other quests completed first
- **Dynamic Quests**: Generate quests at runtime
- **Quest NPCs**: Turn in quests to NPCs for rewards
- **Quest Items**: Special items needed for quests
- **Time Limits**: Quests that must be completed within time
- **Quest Persistence**: Save/load quest state (TODO)
- **Quest Notifications**: Better UI for quest updates
- **Quest Journal**: Full quest history and lore

## Current Quests

### Main
- **Free Captain Theron's Spirit** - Defeat Iron Sentinel

### Side
- **Unlock the Ancient Vault** - Use Silver Key in Chamber 8
- **Map the Dungeon** - Visit all 10 chambers

### Optional
- **Treasure Hunter** - Collect 100 gold
- **Curious Collector** - Collect 5 unique items

## Example Workflow

```
Player: search
  ↓
Server: Found 10 gold
  ↓
Event: "gold_gained"
  ↓
QuestHandler: Check if player has >= 100 gold
  ↓
QuestHandler: Complete "Treasure Hunter" quest
  ↓
Server: Award 50 gold reward
  ↓
Player: "🎉 QUEST COMPLETED: Treasure Hunter! 💰 Reward: 50 gold!"
```

## File Structure

```
src/
├── quest_system.lua      # Core quest management
├── quest_handler.lua     # Event-driven completion logic
└── initial_quests.lua    # Quest definitions

game_server.lua           # Triggers events
```
