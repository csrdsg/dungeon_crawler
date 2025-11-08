-- Quest definitions data
-- Separated from game logic for easy modding and campaign creation

return {
    -- Main Quest
    main_theron = {
        title = "Free Captain Theron's Spirit",
        description = "Defeat the Iron Sentinel in Chamber 7 to free the spirit of Captain Theron",
        type = "main",
        objectives = {
            {id = "find_sentinel", text = "Locate the Iron Sentinel in the Armory", completed = true},
            {id = "defeat_sentinel", text = "Defeat the Iron Sentinel", completed = false}
        },
        rewards = {
            gold = 100,
            items = {"Captain's Signet Ring", "Blessed Sword"}
        }
    },
    
    -- Side Quest: Vault
    side_vault = {
        title = "Unlock the Ancient Vault",
        description = "Use the Silver Key to unlock the treasure vault in Chamber 8",
        type = "side",
        objectives = {
            {id = "find_key", text = "Find the Silver Key", completed = true},
            {id = "find_vault", text = "Locate the vault in the Library", completed = true},
            {id = "unlock_vault", text = "Unlock the vault", completed = false}
        },
        rewards = {
            gold = 50,
            items = {"Ancient Tome"}
        }
    },
    
    -- Side Quest: Exploration
    side_explore = {
        title = "Map the Dungeon",
        description = "Explore all chambers in the dungeon",
        type = "side",
        objectives = {
            {id = "explore_10", text = "Explore all 10 chambers", completed = true}
        },
        rewards = {
            gold = 25,
            items = {"Mapper's Compass"}
        }
    },
    
    -- Optional Quest: Treasure Hunter
    optional_treasure = {
        title = "Treasure Hunter",
        description = "Find 100 gold pieces in the dungeon",
        type = "optional",
        objectives = {
            {id = "collect_gold", text = "Collect 100 gold pieces", completed = false}
        },
        rewards = {
            gold = 50
        }
    },
    
    -- Optional Quest: Item Collector
    optional_items = {
        title = "Curious Collector",
        description = "Collect 5 unique items from the dungeon",
        type = "optional",
        objectives = {
            {id = "collect_items", text = "Collect 5 unique items", completed = false}
        },
        rewards = {
            items = {"Collector's Bag"}
        }
    },
    
    -- Optional Quest: Monster Slayer
    optional_slayer = {
        title = "Monster Slayer",
        description = "Defeat 10 enemies in combat",
        type = "optional",
        objectives = {
            {id = "slay_monsters", text = "Defeat 10 enemies", completed = false}
        },
        rewards = {
            gold = 75,
            items = {"Slayer's Badge"}
        }
    }
}
