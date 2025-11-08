-- Character abilities database
-- Separated from game logic for easy modding and balance changes

return {
    -- Fighter Abilities
    second_wind = {
        name = "Second Wind",
        class = "fighter",
        level_required = 1,
        cooldown = 0,
        uses_per_rest = 2,
        healing = "2d10+level",
        description = "Recover HP as a bonus action (2 uses per rest)"
    },
    
    action_surge = {
        name = "Action Surge",
        class = "fighter",
        level_required = 2,
        cooldown = 0,
        uses_per_rest = 1,
        description = "Take an additional action this turn"
    },
    
    power_attack = {
        name = "Power Attack",
        class = "fighter",
        level_required = 1,
        cooldown = 0,
        penalty_to_hit = -2,
        bonus_damage = "+5",
        description = "Trade accuracy for damage (-2 hit, +5 damage)"
    },
    
    -- Rogue Abilities
    sneak_attack = {
        name = "Sneak Attack",
        class = "rogue",
        level_required = 1,
        bonus_damage = "4d6",
        description = "Extra damage when attacking (always active)",
        requirement = "none"
    },
    
    cunning_action = {
        name = "Cunning Action",
        class = "rogue",
        level_required = 2,
        description = "Bonus dash, disengage, or hide action"
    },
    
    evasion = {
        name = "Evasion",
        class = "rogue",
        level_required = 7,
        description = "Take no damage on successful DEX save (half on fail)",
        passive = true
    },
    
    -- Wizard Abilities
    arcane_recovery = {
        name = "Arcane Recovery",
        class = "wizard",
        level_required = 1,
        uses_per_rest = 1,
        mana_recovery = "level/2",
        description = "Recover mana during short rest"
    },
    
    spell_mastery = {
        name = "Spell Mastery",
        class = "wizard",
        level_required = 5,
        description = "Cast one 1st-level spell without mana cost",
        passive = true
    },
    
    -- Cleric Abilities
    channel_divinity = {
        name = "Channel Divinity",
        class = "cleric",
        level_required = 2,
        uses_per_rest = 1,
        description = "Use divine power (Turn Undead or other effect)"
    },
    
    divine_intervention = {
        name = "Divine Intervention",
        class = "cleric",
        level_required = 10,
        success_chance = "level%",
        description = "Call upon deity for aid"
    },
}
