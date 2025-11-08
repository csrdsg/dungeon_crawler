-- Rest system configuration
-- Separated from game logic for easy balance changes

return {
    short_rest = {
        name = "Short Rest",
        duration = "15 minutes",
        healing_dice = "1d6+1",
        encounter_chance = 40,  -- 40% chance of encounter
        description = "You take a moment to catch your breath..."
    },
    
    long_rest = {
        name = "Long Rest",
        duration = "8 hours",
        healing = "full",
        mana_restore = "full",
        encounter_chance = 60,  -- 60% chance of encounter
        ration_cost = 1,
        description = "You set up camp and rest for the night..."
    }
}
