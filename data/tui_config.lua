-- TUI Game Configuration
-- Tune gameplay parameters without editing code

return {
    -- Encounter chances by chamber type (percentage)
    encounter_chance = {
        [1] = 10,  -- Empty Room
        [2] = 20,  -- Treasure Room  
        [3] = 70,  -- Monster Lair
        [4] = 30,  -- Trap Room
        [5] = 40,  -- Puzzle Room
        [6] = 50,  -- Prison Cells
        [7] = 30,  -- Armory
        [8] = 20,  -- Library
        [9] = 60,  -- Throne Room
        [10] = 100 -- Boss Chamber
    },
    
    -- Trap damage and chance
    trap = {
        chance = 50,      -- % chance trap triggers
        damage = "1d6",   -- Damage dice
        avoid_bonus = 0   -- Bonus to avoid (future: dex modifier)
    },
    
    -- Rest encounter chance
    rest_encounter_chance = 30,
    
    -- Combat escape chance
    escape_chance = 50,
    
    -- Healing amounts
    healing = {
        rest = "1d6+2",        -- Short rest healing
        potion = "2d4+2",      -- Health potion healing
        long_rest = "full"     -- Long rest (future feature)
    },
    
    -- Loot chances
    loot = {
        item_chance = 30,      -- Base % chance for item drop
        bonus_on_kill = 20     -- Extra % if enemy defeated
    },
    
    -- Difficulty multipliers (future feature)
    difficulty = {
        enemy_hp_mult = 1.0,
        enemy_damage_mult = 1.0,
        loot_mult = 1.0,
        xp_mult = 1.0
    },
    
    -- UI refresh rate (if we add animations)
    ui_refresh_ms = 100
}
