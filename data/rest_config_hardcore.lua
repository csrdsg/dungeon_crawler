-- EXAMPLE MOD: Hardcore Mode
-- This is a sample mod showing how to create harder gameplay
-- To use: Replace data/rest_config.lua with this file

return {
    short_rest = {
        name = "Short Rest",
        duration = "30 minutes",  -- Longer duration
        healing_dice = "1d4",     -- REDUCED healing (was 1d6+1)
        encounter_chance = 60,     -- INCREASED encounter chance (was 40%)
        description = "You catch your breath in this dangerous place..."
    },
    
    long_rest = {
        name = "Long Rest",
        duration = "8 hours",
        healing = "full",
        mana_restore = "full",
        encounter_chance = 80,     -- INCREASED encounter chance (was 60%)
        ration_cost = 2,           -- COSTS MORE rations (was 1)
        description = "You rest fitfully, always on alert..."
    }
}
