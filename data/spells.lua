-- Spell database
-- Separated from game logic for easy modding and balance changes

return {
    -- Arcane Spells
    magic_missile = {
        name = "Magic Missile",
        type = "arcane",
        level = 1,
        mana_cost = 3,
        damage = "2d4+2",
        description = "Unerring bolts of magical force",
        auto_hit = true,
        target = "single"
    },
    
    fireball = {
        name = "Fireball",
        type = "arcane",
        level = 3,
        mana_cost = 8,
        damage = "6d6",
        description = "Explosive ball of flame",
        save_dc = 14,
        save_type = "DEX",
        target = "area"
    },
    
    lightning_bolt = {
        name = "Lightning Bolt",
        type = "arcane",
        level = 3,
        mana_cost = 7,
        damage = "8d6",
        description = "Line of crackling electricity",
        save_dc = 14,
        save_type = "DEX",
        target = "line"
    },
    
    shield = {
        name = "Shield",
        type = "arcane",
        level = 1,
        mana_cost = 3,
        duration = 3,
        ac_bonus = 5,
        description = "Invisible barrier of force (+5 AC for 3 rounds)",
        target = "self"
    },
    
    detect_magic = {
        name = "Detect Magic",
        type = "arcane",
        level = 1,
        mana_cost = 2,
        duration = 10,
        description = "Sense magical auras nearby",
        target = "self"
    },
    
    haste = {
        name = "Haste",
        type = "arcane",
        level = 3,
        mana_cost = 6,
        duration = 5,
        description = "Double attack speed (2 attacks per round)",
        target = "self"
    },
    
    -- Divine Spells
    cure_wounds = {
        name = "Cure Wounds",
        type = "divine",
        level = 1,
        mana_cost = 5,
        healing = "2d4+2",
        description = "Restore health with divine energy",
        target = "self",
        max_uses_per_combat = 1
    },
    
    bless = {
        name = "Bless",
        type = "divine",
        level = 1,
        mana_cost = 4,
        duration = 5,
        bonus = 2,
        description = "+2 to attack rolls and saving throws",
        target = "self"
    },
    
    turn_undead = {
        name = "Turn Undead",
        type = "divine",
        level = 2,
        mana_cost = 5,
        save_dc = 13,
        save_type = "WIS",
        description = "Force undead to flee",
        target = "undead"
    },
    
    holy_smite = {
        name = "Holy Smite",
        type = "divine",
        level = 2,
        mana_cost = 5,
        damage = "3d8",
        description = "Divine radiance damages evil",
        bonus_vs_undead = "2d8",
        target = "single"
    },
    
    prayer = {
        name = "Prayer",
        type = "divine",
        level = 3,
        mana_cost = 7,
        duration = 5,
        description = "+1 AC, +1 attack, +1 damage",
        target = "self"
    },
}
