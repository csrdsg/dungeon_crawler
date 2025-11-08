-- Loot tables data
-- Separated from game logic for easy modding and balance changes

return {
    treasure_tables = {
        poor = {
            gold = {min = 5, max = 20},
            items = {
                "Rusty Dagger (1d4 damage, 1gp)",
                "Cracked Potion Bottle (empty)",
                "Torn Scroll (illegible)",
                "Bent Iron Key",
                "Moldy Rations (1 day)",
                "Frayed Rope (20ft)",
                "Worn Torch"
            }
        },
        common = {
            gold = {min = 20, max = 100},
            items = {
                "Healing Potion (Minor, 50gp)",
                "Dagger (1d4, 2gp)",
                "Torch × 3 (3gp)",
                "Rations × 3 (1.5gp)",
                "Rope (50ft, 1gp)",
                "Lockpicks (10gp)",
                "Waterskin (2sp)",
                "Oil Flask (1gp)",
                "Minor Gem (10-50gp)"
            }
        },
        uncommon = {
            gold = {min = 100, max = 300},
            items = {
                "Healing Potion (Major, 150gp)",
                "Mana Potion (75gp)",
                "Scroll of Fireball (100gp)",
                "Scroll of Healing (75gp)",
                "Standard Gem (50-100gp)",
                "Silver Dagger (1d4, 10gp)",
                "Masterwork Lockpicks (+2 to lockpicking, 50gp)",
                "Antidote Potion (50gp)",
                "Strength Potion (100gp)"
            }
        },
        rare = {
            gold = {min = 300, max = 1000},
            items = {
                "Ring of Protection +1 (500gp)",
                "Cloak of Elvenkind (+2 Stealth, 1500gp)",
                "Gloves of Thievery (+2 Lockpicking, 750gp)",
                "Boots of Speed (+2 Initiative, 1000gp)",
                "Major Gem (100-500gp)",
                "Magic Sword +1 (500gp)",
                "Amulet of Health (+2 CON, 1000gp)",
                "Invisibility Potion (300gp)",
                "Scroll of Teleport (500gp)"
            }
        },
        legendary = {
            gold = {min = 1000, max = 5000},
            items = {
                "Bag of Holding (2000gp)",
                "Magic Sword +2 (2000gp)",
                "Ring of Protection +2 (2000gp)",
                "Perfect Gem (500-1000gp)",
                "Amulet of the Gods (+3 to all saves, 3000gp)",
                "Cloak of Invisibility (5000gp)",
                "Staff of Power (4000gp)",
                "Crown of Command (+3 CHA, 3500gp)"
            }
        }
    },
    
    chamber_loot_quality = {
        [1] = {"poor", "poor", "common"},              -- Empty room
        [2] = {"common", "uncommon", "uncommon", "rare"}, -- Treasure room
        [3] = {"poor", "common", "common"},            -- Monster lair
        [4] = {"poor", "common", "uncommon"},          -- Trap room
        [5] = {"common", "uncommon", "rare"},          -- Puzzle room
        [6] = {"poor", "poor", "common"},              -- Prison cells
        [7] = {"common", "uncommon", "uncommon"},      -- Armory
        [8] = {"common", "uncommon", "rare"},          -- Library
        [9] = {"uncommon", "rare", "rare"},            -- Throne room
        [10] = {"rare", "rare", "legendary"}           -- Boss chamber
    }
}
