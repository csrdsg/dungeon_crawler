-- EXAMPLE MOD: Treasure Hunter Mode
-- Increased loot quality and quantity
-- To use: Replace data/loot_tables.lua with this file

return {
    treasure_tables = {
        poor = {
            gold = {min = 10, max = 50},  -- BUFFED (was 5-20)
            items = {
                "Rusty Dagger (1d4 damage, 1gp)",
                "Cracked Potion Bottle (empty)",
                "Torn Scroll (illegible)",
                "Bent Iron Key",
                "Moldy Rations (1 day)",
                "Frayed Rope (20ft)",
                "Worn Torch",
                "Copper Coins (5gp)",  -- NEW
                "Old Map Fragment"      -- NEW
            }
        },
        common = {
            gold = {min = 50, max = 200},  -- BUFFED (was 20-100)
            items = {
                "Healing Potion (Minor, 50gp)",
                "Dagger (1d4, 2gp)",
                "Torch × 3 (3gp)",
                "Rations × 3 (1.5gp)",
                "Rope (50ft, 1gp)",
                "Lockpicks (10gp)",
                "Waterskin (2sp)",
                "Oil Flask (1gp)",
                "Minor Gem (10-50gp)",
                "Silver Pieces (20gp)",  -- NEW
                "Compass (15gp)"         -- NEW
            }
        },
        uncommon = {
            gold = {min = 200, max = 500},  -- BUFFED (was 100-300)
            items = {
                "Healing Potion (Major, 150gp)",
                "Mana Potion (75gp)",
                "Scroll of Fireball (100gp)",
                "Scroll of Healing (75gp)",
                "Standard Gem (50-100gp)",
                "Silver Dagger (1d4, 10gp)",
                "Masterwork Lockpicks (+2 to lockpicking, 50gp)",
                "Antidote Potion (50gp)",
                "Strength Potion (100gp)",
                "Elixir of Speed (120gp)",           -- NEW
                "Ring of Minor Protection (200gp)"   -- NEW
            }
        },
        rare = {
            gold = {min = 500, max = 2000},  -- BUFFED (was 300-1000)
            items = {
                "Ring of Protection +1 (500gp)",
                "Cloak of Elvenkind (+2 Stealth, 1500gp)",
                "Gloves of Thievery (+2 Lockpicking, 750gp)",
                "Boots of Speed (+2 Initiative, 1000gp)",
                "Major Gem (100-500gp)",
                "Magic Sword +1 (500gp)",
                "Amulet of Health (+2 CON, 1000gp)",
                "Invisibility Potion (300gp)",
                "Scroll of Teleport (500gp)",
                "Wand of Fireballs (800gp)",        -- NEW
                "Potion of Giant Strength (600gp)"  -- NEW
            }
        },
        legendary = {
            gold = {min = 2000, max = 10000},  -- BUFFED (was 1000-5000)
            items = {
                "Bag of Holding (2000gp)",
                "Magic Sword +2 (2000gp)",
                "Ring of Protection +2 (2000gp)",
                "Perfect Gem (500-1000gp)",
                "Amulet of the Gods (+3 to all saves, 3000gp)",
                "Cloak of Invisibility (5000gp)",
                "Staff of Power (4000gp)",
                "Crown of Command (+3 CHA, 3500gp)",
                "Vorpal Sword +3 (8000gp)",          -- NEW
                "Deck of Many Things (10000gp)",     -- NEW
                "Wish Ring (9000gp)"                 -- NEW
            }
        }
    },
    
    chamber_loot_quality = {
        [1] = {"common", "common", "uncommon"},           -- BUFFED Empty room
        [2] = {"uncommon", "rare", "rare", "legendary"},  -- BUFFED Treasure room
        [3] = {"common", "uncommon", "rare"},             -- BUFFED Monster lair
        [4] = {"common", "uncommon", "rare"},             -- BUFFED Trap room
        [5] = {"uncommon", "rare", "legendary"},          -- BUFFED Puzzle room
        [6] = {"common", "uncommon", "uncommon"},         -- BUFFED Prison cells
        [7] = {"uncommon", "rare", "rare"},               -- BUFFED Armory
        [8] = {"uncommon", "rare", "legendary"},          -- BUFFED Library
        [9] = {"rare", "legendary", "legendary"},         -- BUFFED Throne room
        [10] = {"legendary", "legendary", "legendary"}    -- BUFFED Boss chamber
    }
}
