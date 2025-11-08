-- magic.lua - Magic and spell system for dungeon crawler
local M = {}

local dice = require('dice')

-- Spell database
M.spells = {
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
        mana_cost = 3,  -- NERFED: 2 → 3 (still strong but more expensive)
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
        mana_cost = 5,  -- NERFED MORE: 4 → 5 (expensive!)
        healing = "2d4+2",  -- NERFED MORE: 2d6+2 → 2d4+2 (avg 7 HP)
        description = "Restore health with divine energy",
        target = "self",
        max_uses_per_combat = 1  -- NEW: Can only use once per combat
    },
    
    bless = {
        name = "Bless",
        type = "divine",
        level = 1,
        mana_cost = 4,  -- NERFED: 3 → 4 (more expensive)
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

-- Ability database
M.abilities = {
    -- Fighter Abilities
    second_wind = {
        name = "Second Wind",
        class = "fighter",
        level_required = 1,
        cooldown = 0,  -- Per rest
        uses_per_rest = 2,  -- BUFFED: 1 → 2 uses
        healing = "2d10+level",  -- BUFFED: 1d10 → 2d10 (more healing)
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
        bonus_damage = "4d6",  -- BUFFED MORE: 3d6 → 4d6 (significant damage)
        description = "Extra damage when attacking (always active)",
        requirement = "none"  -- Always active
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

-- Cast a spell
function M.cast_spell(caster, spell_name, target)
    local spell = M.spells[spell_name]
    if not spell then
        return {success = false, message = "Unknown spell: " .. spell_name}
    end
    
    -- Check mana
    if caster.mp < spell.mana_cost then
        return {success = false, message = "Not enough mana! Need " .. spell.mana_cost}
    end
    
    -- Deduct mana
    caster.mp = caster.mp - spell.mana_cost
    
    local result = {
        success = true,
        spell = spell.name,
        mana_used = spell.mana_cost,
        effects = {}
    }
    
    -- Handle different spell types
    if spell.damage then
        local damage = dice.roll(spell.damage)
        
        -- Handle saves
        if spell.save_dc and target then
            local save_roll = dice.roll("d20")
            local save_mod = target[spell.save_type:lower()] or 0
            
            if save_roll + save_mod >= spell.save_dc then
                damage = math.floor(damage / 2)
                table.insert(result.effects, "Target saved! Half damage")
            else
                table.insert(result.effects, "Target failed save!")
            end
        end
        
        result.damage = damage
        table.insert(result.effects, string.format("Dealt %d damage", damage))
    end
    
    if spell.healing then
        local healing = dice.roll(spell.healing)
        result.healing = healing
        table.insert(result.effects, string.format("Healed %d HP", healing))
    end
    
    if spell.ac_bonus then
        result.ac_bonus = spell.ac_bonus
        result.duration = spell.duration
        table.insert(result.effects, string.format("+%d AC for %d rounds", spell.ac_bonus, spell.duration))
    end
    
    if spell.auto_hit then
        table.insert(result.effects, "Automatically hits target!")
    end
    
    return result
end

-- Use an ability
function M.use_ability(character, ability_name)
    local ability = M.abilities[ability_name]
    if not ability then
        return {success = false, message = "Unknown ability: " .. ability_name}
    end
    
    -- Check class requirement
    if ability.class and character.class:lower() ~= ability.class then
        return {success = false, message = "This ability is for " .. ability.class .. " only"}
    end
    
    -- Check level requirement
    if ability.level_required and character.level < ability.level_required then
        return {success = false, message = "Requires level " .. ability.level_required}
    end
    
    local result = {
        success = true,
        ability = ability.name,
        effects = {}
    }
    
    -- Handle specific abilities
    if ability.healing then
        local heal_formula = ability.healing:gsub("level", tostring(character.level))
        local healing = dice.roll(heal_formula)
        result.healing = healing
        table.insert(result.effects, string.format("Healed %d HP", healing))
    end
    
    if ability.bonus_damage then
        result.bonus_damage = ability.bonus_damage
        table.insert(result.effects, "Bonus damage: " .. ability.bonus_damage)
    end
    
    if ability.mana_recovery then
        local recovery_formula = ability.mana_recovery:gsub("level", tostring(character.level))
        local mana = math.floor(character.level / 2)
        result.mana_recovery = mana
        table.insert(result.effects, string.format("Recovered %d mana", mana))
    end
    
    return result
end

-- Get available spells for character
function M.get_available_spells(character)
    local available = {}
    local magic_type = character.class == "wizard" and "arcane" or "divine"
    
    for spell_id, spell in pairs(M.spells) do
        if spell.type == magic_type and spell.level <= character.level then
            table.insert(available, {id = spell_id, spell = spell})
        end
    end
    
    return available
end

-- Get available abilities for character
function M.get_available_abilities(character)
    local available = {}
    
    for ability_id, ability in pairs(M.abilities) do
        if (not ability.class or ability.class == character.class:lower()) and
           (not ability.level_required or ability.level_required <= character.level) then
            table.insert(available, {id = ability_id, ability = ability})
        end
    end
    
    return available
end

-- CLI interface
if arg and arg[1] then
    local command = arg[1]
    
    if command == "list" or command == "spells" then
        print("\n🔮 AVAILABLE SPELLS")
        print(string.rep("═", 70))
        
        print("\n⚡ ARCANE SPELLS:")
        for id, spell in pairs(M.spells) do
            if spell.type == "arcane" then
                print(string.format("  %s (Lvl %d, %d MP) - %s",
                    spell.name, spell.level, spell.mana_cost, spell.description))
            end
        end
        
        print("\n✨ DIVINE SPELLS:")
        for id, spell in pairs(M.spells) do
            if spell.type == "divine" then
                print(string.format("  %s (Lvl %d, %d MP) - %s",
                    spell.name, spell.level, spell.mana_cost, spell.description))
            end
        end
        
    elseif command == "abilities" then
        print("\n💪 AVAILABLE ABILITIES")
        print(string.rep("═", 70))
        
        local by_class = {}
        for id, ability in pairs(M.abilities) do
            local class = ability.class or "universal"
            if not by_class[class] then by_class[class] = {} end
            table.insert(by_class[class], {id = id, ability = ability})
        end
        
        for class, abilities in pairs(by_class) do
            print(string.format("\n🎭 %s:", class:upper()))
            for _, entry in ipairs(abilities) do
                local ability = entry.ability
                print(string.format("  %s (Lvl %d) - %s",
                    ability.name, ability.level_required or 1, ability.description))
            end
        end
        
    elseif command == "test" then
        print("\n🧪 TESTING MAGIC SYSTEM")
        print(string.rep("═", 70))
        
        -- Test character
        local wizard = {
            name = "Test Wizard",
            class = "wizard",
            level = 3,
            mp = 25,
            max_mp = 25
        }
        
        print("\nCasting Magic Missile...")
        local result = M.cast_spell(wizard, "magic_missile")
        if result.success then
            print("  ✅ Success!")
            for _, effect in ipairs(result.effects) do
                print("  " .. effect)
            end
            print(string.format("  Mana: %d/%d", wizard.mp, wizard.max_mp))
        end
        
        print("\nCasting Fireball...")
        local target = {dex = 2}
        result = M.cast_spell(wizard, "fireball", target)
        if result.success then
            print("  ✅ Success!")
            for _, effect in ipairs(result.effects) do
                print("  " .. effect)
            end
            print(string.format("  Mana: %d/%d", wizard.mp, wizard.max_mp))
        end
        
    else
        print([[
Magic & Abilities System

Usage:
  lua magic.lua list       - List all spells
  lua magic.lua abilities  - List all abilities
  lua magic.lua test       - Test magic system

Integration:
  local magic = require('magic')
  
  -- Cast spell
  local result = magic.cast_spell(character, "magic_missile", target)
  
  -- Use ability
  local result = magic.use_ability(character, "second_wind")
  
  -- Get available spells/abilities
  local spells = magic.get_available_spells(character)
  local abilities = magic.get_available_abilities(character)
]])
    end
end

return M
