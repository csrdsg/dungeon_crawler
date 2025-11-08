-- Encounter tables data
-- Separated from game logic for easy modding and balance changes

return {
    friendly_encounters = {
        {name = "Lost Merchant", desc = "A frightened merchant offering discounted goods"},
        {name = "Trapped Adventurer", desc = "Fellow adventurer caught in a trap, will help if freed"},
        {name = "Hermit Wizard", desc = "Reclusive mage offering magical knowledge"},
        {name = "Escaped Prisoner", desc = "Innocent person who knows secret passages"},
        {name = "Friendly Ghost", desc = "Spirit providing warnings about dangers ahead"},
        {name = "Traveling Healer", desc = "Wandering cleric offering healing services"},
        {name = "Lost Child", desc = "Young person separated from their group"}
    },
    
    neutral_encounters = {
        {name = "Scavenger Goblins", desc = "Small group picking through debris, will trade or flee", count = "1d4"},
        {name = "Ancient Golem", desc = "Magical construct following old orders, ignores unless provoked"},
        {name = "Dungeon Fauna", desc = "Giant rats or bats, avoid unless cornered", count = "1d6"},
        {name = "Wandering Spirit", desc = "Ghostly apparition reliving past events"},
        {name = "Rival Adventuring Party", desc = "Another group of explorers", count = "1d4"},
        {name = "Cursed Knight", desc = "Undead warrior protecting the dungeon"},
        {name = "Underground Trader", desc = "Mysterious merchant dealing in rare goods"},
        {name = "Magical Familiar", desc = "Lost wizard's familiar seeking its master"}
    },
    
    hostile_encounters = {
        -- Early game enemies (dungeon level 1-2)
        {name = "Goblin Scout", type = "goblin", desc = "Small aggressive humanoid", count = "1d2", level_range = {1, 1}, min_dungeon_level = 1},
        {name = "Dungeon Bandits", type = "bandit", desc = "Criminal gang", count = "1d2", level_range = {1, 1}, min_dungeon_level = 1},
        {name = "Dark Cultists", type = "cultist", desc = "Fanatics performing rituals", count = "1d2", level_range = {1, 1}, min_dungeon_level = 1},
        {name = "Skeletal Guards", type = "skeleton", desc = "Undead soldiers", count = "1d2", level_range = {1, 2}, min_dungeon_level = 1},
        
        -- Mid game enemies (dungeon level 2-4)
        {name = "Orc War Band", type = "orc", desc = "Aggressive warriors", count = "1d2", level_range = {1, 2}, min_dungeon_level = 2},
        {name = "Zombie Horde", type = "zombie", desc = "Shambling undead", count = "1d3", level_range = {1, 1}, min_dungeon_level = 2},
        {name = "Giant Spider", type = "spider", desc = "Massive arachnid with poisonous bite", level_range = {1, 3}, min_dungeon_level = 3},
        {name = "Dark Elf Raider", type = "drow", desc = "Deadly assassins from below", count = "1d2", level_range = {2, 3}, min_dungeon_level = 3},
        
        -- Late game enemies (dungeon level 4+)
        {name = "Gargoyles", type = "gargoyle", desc = "Stone creatures guarding important areas", count = "1d2", level_range = {2, 4}, min_dungeon_level = 4},
        {name = "Ogre", type = "ogre", desc = "Massive brute", level_range = {3, 5}, min_dungeon_level = 5},
        {name = "Troll", type = "troll", desc = "Regenerating monster", level_range = {4, 6}, min_dungeon_level = 5},
        
        -- Boss enemies (dungeon level 6+)
        {name = "Vampire Lord", type = "vampire", desc = "Undead noble commanding dark magic", level_range = {5, 7}, min_dungeon_level = 6},
        {name = "Ancient Dragon", type = "dragon", desc = "Powerful wyrm guarding treasure", level_range = {7, 10}, min_dungeon_level = 8},
        {name = "Lich", type = "lich", desc = "Undead sorcerer of immense power", level_range = {6, 9}, min_dungeon_level = 7}
    },
    
    encounter_chances = {
        [1] = 30,  -- Empty room
        [2] = 60,  -- Treasure room
        [3] = 90,  -- Monster lair
        [4] = 20,  -- Trap room
        [5] = 40,  -- Puzzle room
        [6] = 50,  -- Prison cells
        [7] = 50,  -- Armory
        [8] = 40,  -- Library
        [9] = 70,  -- Throne room
        [10] = 100 -- Boss chamber
    },
    
    disposition_weights = {
        [1] = {friendly = 2, neutral = 3, hostile = 5},    -- Empty room
        [2] = {friendly = 1, neutral = 2, hostile = 7},    -- Treasure room
        [3] = {friendly = 0, neutral = 1, hostile = 9},    -- Monster lair
        [4] = {friendly = 1, neutral = 2, hostile = 7},    -- Trap room
        [5] = {friendly = 2, neutral = 5, hostile = 3},    -- Puzzle room
        [6] = {friendly = 3, neutral = 4, hostile = 3},    -- Prison cells
        [7] = {friendly = 2, neutral = 3, hostile = 5},    -- Armory
        [8] = {friendly = 3, neutral = 5, hostile = 2},    -- Library
        [9] = {friendly = 1, neutral = 3, hostile = 6},    -- Throne room
        [10] = {friendly = 0, neutral = 0, hostile = 10}   -- Boss chamber
    }
}
