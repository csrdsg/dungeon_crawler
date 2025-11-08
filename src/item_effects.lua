-- item_effects.lua - Active, Passive, and Negative effects for items
local M = {}

local dice = require('dice')

-- Item effect database
M.item_effects = {
    -- ACTIVE EFFECTS (use to activate)
    -- Weapons
    flaming_sword = {
        name = "Flaming Blade",
        type = "active",
        effect_type = "damage_bonus",
        uses_per_rest = 3,
        damage_bonus = "1d8",
        element = "fire",
        description = "Ignite blade for +1d8 fire damage (3 uses per rest)",
        on_use_message = "🔥 The blade erupts in flames!"
    },
    
    frost_dagger = {
        name = "Freezing Strike",
        type = "active",
        effect_type = "damage_and_debuff",
        uses_per_rest = 3,
        damage_bonus = "1d8",
        element = "ice",
        applies_effect = "slowed",
        description = "Freeze target for +1d8 ice damage and slow (3 uses)",
        on_use_message = "❄️ Ice crystals form on the blade!"
    },
    
    thunderstrike_hammer = {
        name = "Thunder Strike",
        type = "active",
        effect_type = "aoe_damage",
        uses_per_rest = 1,
        damage = "2d8",
        element = "lightning",
        aoe = true,
        description = "Unleash thunder damage to all nearby enemies (1 use)",
        on_use_message = "⚡ Thunder crashes around you!"
    },
    
    -- Armor
    shield_of_valor = {
        name = "Shield Wall",
        type = "active",
        effect_type = "defense_buff",
        uses_per_rest = 3,
        ac_bonus = 2,
        duration = 3,
        description = "Raise shield for +2 AC for 3 rounds (3 uses)",
        on_use_message = "🛡️ You raise your shield defensively!"
    },
    
    boots_of_speed = {
        name = "Haste",
        type = "active",
        effect_type = "buff",
        uses_per_rest = 2,
        buff = "hasted",
        duration = 2,
        description = "Double movement and attacks for 2 rounds (2 uses)",
        on_use_message = "💨 You blur with supernatural speed!"
    },
    
    -- Accessories
    amulet_of_healing = {
        name = "Emergency Heal",
        type = "active",
        effect_type = "heal",
        uses_per_rest = 2,
        healing = "2d8+2",
        description = "Restore health in emergencies (2 uses per rest)",
        on_use_message = "✨ The amulet glows with healing energy!"
    },
    
    ring_of_spell_storing = {
        name = "Spell Release",
        type = "active",
        effect_type = "spell_cast",
        uses_per_rest = 1,
        stored_spell = "magic_missile",
        description = "Release stored Magic Missile (1 use)",
        on_use_message = "🔮 Magical energy releases from the ring!"
    },
    
    -- PASSIVE EFFECTS (always active)
    -- Weapons
    vampire_blade = {
        name = "Life Drain",
        type = "passive",
        effect_type = "lifesteal",
        lifesteal_percent = 20,
        description = "Heal for 20% of damage dealt",
        passive_message = "🩸 Drains life with each strike"
    },
    
    holy_mace = {
        name = "Smite Evil",
        type = "passive",
        effect_type = "bonus_vs_type",
        bonus_damage = "2d8",
        target_types = {"undead", "demon", "devil"},
        description = "+2d8 damage vs undead/demons/devils",
        passive_message = "⚜️ Glows when evil is near"
    },
    
    vorpal_blade = {
        name = "Vorpal Edge",
        type = "passive",
        effect_type = "crit_bonus",
        crit_chance_bonus = 1,  -- Crit on 19-20 instead of 20
        crit_multiplier = 3,    -- 3x damage instead of 2x
        description = "Increased critical hit chance and damage",
        passive_message = "⚔️ The blade hums with deadly precision"
    },
    
    -- Armor
    plate_of_invulnerability = {
        name = "Damage Reduction",
        type = "passive",
        effect_type = "damage_reduction",
        reduction = 2,
        description = "Reduce all incoming damage by 2",
        passive_message = "🛡️ Negates minor attacks"
    },
    
    cloak_of_displacement = {
        name = "Evasion",
        type = "passive",
        effect_type = "miss_chance",
        miss_chance = 15,  -- 15% chance to be missed
        description = "15% chance enemies miss you",
        passive_message = "👻 Your form wavers and shifts"
    },
    
    armor_of_regeneration = {
        name = "Regeneration",
        type = "passive",
        effect_type = "regen",
        regen_per_round = "1d3",
        description = "Regenerate 1d3 HP each round",
        passive_message = "💚 Wounds slowly close"
    },
    
    -- Accessories
    ring_of_protection = {
        name = "Arcane Ward",
        type = "passive",
        effect_type = "ac_bonus",
        ac_bonus = 2,
        description = "+2 AC",
        passive_message = "✨ Surrounded by protective magic"
    },
    
    amulet_of_health = {
        name = "Vitality",
        type = "passive",
        effect_type = "hp_bonus",
        hp_bonus = 8,
        description = "+8 maximum HP",
        passive_message = "💪 You feel more robust"
    },
    
    boots_of_striding = {
        name = "Swift Movement",
        type = "passive",
        effect_type = "initiative_bonus",
        initiative_bonus = 2,
        description = "+2 to initiative",
        passive_message = "🏃 You move with grace"
    },
    
    ring_of_wizardry = {
        name = "Arcane Reservoir",
        type = "passive",
        effect_type = "mana_bonus",
        mana_bonus = 8,
        description = "+8 maximum MP",
        passive_message = "🔮 Arcane power flows through you"
    },
    
    -- CURSED/NEGATIVE EFFECTS
    cursed_sword_of_greed = {
        name = "Greed's Curse",
        type = "cursed",
        effect_type = "damage_bonus_with_penalty",
        damage_bonus = "2d6",
        curse = "cannot_drop",
        hp_drain_per_hit = 1,
        description = "+2d6 damage but drains 1 HP per hit (cannot remove)",
        curse_message = "😈 The sword hungers for blood... even yours!",
        positive_message = "+2d6 damage",
        negative_message = "Drains 1 HP per strike, cannot be removed"
    },
    
    helm_of_madness = {
        name = "Madness",
        type = "cursed",
        effect_type = "buff_and_debuff",
        attack_bonus = 2,
        ac_penalty = 1,
        curse = "cannot_drop",
        description = "+2 attack but -1 AC (cannot remove)",
        curse_message = "🤪 Voices whisper dark secrets...",
        positive_message = "+2 to attack",
        negative_message = "-1 AC, cannot be removed"
    },
    
    ring_of_weakness = {
        name = "Withering",
        type = "cursed",
        effect_type = "stat_drain",
        damage_penalty = 1,
        curse = "cannot_drop",
        description = "-1 to damage (cannot remove)",
        curse_message = "😰 Your strength ebbs away...",
        negative_message = "-1 damage, cannot be removed"
    },
    
    boots_of_slowness = {
        name = "Leaden Steps",
        type = "cursed",
        effect_type = "initiative_penalty",
        initiative_penalty = 3,
        curse = "cannot_drop",
        description = "-3 initiative (cannot remove)",
        curse_message = "⚓ Your feet feel like lead...",
        negative_message = "-3 initiative, cannot be removed"
    },
    
    amulet_of_vulnerability = {
        name = "Weakness",
        type = "cursed",
        effect_type = "damage_amplification",
        damage_multiplier = 1.25,  -- Take 25% more damage
        curse = "cannot_drop",
        description = "Take 25% more damage (cannot remove)",
        curse_message = "💀 Your defenses crumble...",
        negative_message = "+25% damage taken, cannot be removed"
    },
}

-- Status effects that items can apply
M.status_effects = {
    slowed = {
        name = "Slowed",
        duration = 2,
        ac_penalty = 2,
        attack_penalty = 2,
        description = "-2 AC and attack for 2 rounds"
    },
    
    hasted = {
        name = "Hasted",
        duration = 2,
        attacks_per_round = 2,
        description = "Attack twice per round for 2 rounds"
    },
    
    burning = {
        name = "Burning",
        duration = 3,
        damage_per_round = "1d6",
        description = "Take 1d6 fire damage per round for 3 rounds"
    },
    
    blessed = {
        name = "Blessed",
        duration = 5,
        attack_bonus = 1,
        damage_bonus = 1,
        description = "+1 attack and damage for 5 rounds"
    },
    
    stunned = {
        name = "Stunned",
        duration = 1,
        skip_turn = true,
        description = "Cannot act for 1 round"
    }
}

-- Apply active item effect
function M.use_item_effect(item_effect_id, user, target)
    local effect = M.item_effects[item_effect_id]
    if not effect then
        return {success = false, message = "Unknown item effect: " .. item_effect_id}
    end
    
    if effect.type ~= "active" then
        return {success = false, message = "This is not an active effect"}
    end
    
    local result = {
        success = true,
        effect_name = effect.name,
        message = effect.on_use_message,
        effects = {}
    }
    
    -- Handle different effect types
    if effect.effect_type == "damage_bonus" then
        local bonus = dice.roll(effect.damage_bonus)
        result.damage_bonus = bonus
        table.insert(result.effects, string.format("+%d %s damage", bonus, effect.element or ""))
        
    elseif effect.effect_type == "heal" then
        local healing = dice.roll(effect.healing)
        result.healing = healing
        table.insert(result.effects, string.format("Healed %d HP", healing))
        
    elseif effect.effect_type == "defense_buff" then
        result.ac_bonus = effect.ac_bonus
        result.duration = effect.duration
        table.insert(result.effects, string.format("+%d AC for %d rounds", effect.ac_bonus, effect.duration))
        
    elseif effect.effect_type == "damage_and_debuff" then
        local bonus = dice.roll(effect.damage_bonus)
        result.damage_bonus = bonus
        result.applies_effect = effect.applies_effect
        table.insert(result.effects, string.format("+%d %s damage", bonus, effect.element or ""))
        table.insert(result.effects, "Target " .. effect.applies_effect)
        
    elseif effect.effect_type == "aoe_damage" then
        local damage = dice.roll(effect.damage)
        result.aoe_damage = damage
        table.insert(result.effects, string.format("%d %s damage to all enemies", damage, effect.element or ""))
    end
    
    return result
end

-- Check passive effect
function M.apply_passive_effect(item_effect_id, context)
    local effect = M.item_effects[item_effect_id]
    if not effect or effect.type ~= "passive" then
        return nil
    end
    
    local result = {
        effect_name = effect.name,
        modifiers = {}
    }
    
    if effect.effect_type == "lifesteal" then
        result.lifesteal_percent = effect.lifesteal_percent
        
    elseif effect.effect_type == "damage_reduction" then
        result.damage_reduction = effect.reduction
        
    elseif effect.effect_type == "ac_bonus" then
        result.ac_bonus = effect.ac_bonus
        
    elseif effect.effect_type == "hp_bonus" then
        result.hp_bonus = effect.hp_bonus
        
    elseif effect.effect_type == "regen" then
        local regen = dice.roll(effect.regen_per_round)
        result.regen = regen
        
    elseif effect.effect_type == "bonus_vs_type" then
        if context and context.target_type then
            for _, t in ipairs(effect.target_types) do
                if t == context.target_type then
                    result.bonus_damage = dice.roll(effect.bonus_damage)
                    break
                end
            end
        end
    end
    
    return result
end

-- Apply cursed effect
function M.apply_cursed_effect(item_effect_id)
    local effect = M.item_effects[item_effect_id]
    if not effect or effect.type ~= "cursed" then
        return nil
    end
    
    return {
        effect_name = effect.name,
        curse_message = effect.curse_message,
        positive = effect.positive_message,
        negative = effect.negative_message,
        damage_bonus = effect.damage_bonus,
        attack_bonus = effect.attack_bonus,
        ac_penalty = effect.ac_penalty,
        damage_penalty = effect.damage_penalty,
        hp_drain_per_hit = effect.hp_drain_per_hit,
        cannot_remove = effect.curse == "cannot_drop"
    }
end

-- Get item effect info
function M.get_effect_info(item_effect_id)
    return M.item_effects[item_effect_id]
end

-- List all effects by type
function M.list_effects_by_type(effect_type)
    local results = {}
    for id, effect in pairs(M.item_effects) do
        if effect.type == effect_type then
            table.insert(results, {id = id, effect = effect})
        end
    end
    return results
end

-- CLI interface
if arg and arg[1] then
    local command = arg[1]
    
    if command == "list" then
        local filter = arg[2]
        
        print("\n⚔️  ITEM EFFECTS SYSTEM")
        print(string.rep("═", 70))
        
        if not filter or filter == "active" then
            print("\n✨ ACTIVE EFFECTS (Use to activate):")
            print(string.rep("-", 70))
            for id, effect in pairs(M.item_effects) do
                if effect.type == "active" then
                    print(string.format("%-25s %s", effect.name, effect.description))
                    print(string.format("%-25s Uses: %d/rest", "", effect.uses_per_rest))
                end
            end
        end
        
        if not filter or filter == "passive" then
            print("\n💎 PASSIVE EFFECTS (Always active):")
            print(string.rep("-", 70))
            for id, effect in pairs(M.item_effects) do
                if effect.type == "passive" then
                    print(string.format("%-25s %s", effect.name, effect.description))
                end
            end
        end
        
        if not filter or filter == "cursed" then
            print("\n😈 CURSED EFFECTS (Cannot remove):")
            print(string.rep("-", 70))
            for id, effect in pairs(M.item_effects) do
                if effect.type == "cursed" then
                    print(string.format("%-25s %s", effect.name, effect.description))
                end
            end
        end
        
        print(string.rep("═", 70))
        
    elseif command == "test" then
        print("\n🧪 TESTING ITEM EFFECTS")
        print(string.rep("═", 70))
        
        -- Test active effect
        print("\n1. Testing Flaming Sword:")
        local result = M.use_item_effect("flaming_sword", {name = "Warrior"}, {name = "Orc"})
        if result.success then
            print("  " .. result.message)
            for _, eff in ipairs(result.effects) do
                print("  " .. eff)
            end
        end
        
        -- Test passive effect
        print("\n2. Testing Vampire Blade:")
        local passive = M.apply_passive_effect("vampire_blade")
        if passive then
            print(string.format("  Lifesteal: %d%%", passive.lifesteal_percent))
        end
        
        -- Test cursed effect
        print("\n3. Testing Cursed Sword:")
        local cursed = M.apply_cursed_effect("cursed_sword_of_greed")
        if cursed then
            print("  " .. cursed.curse_message)
            print("  Positive: " .. (cursed.positive or "None"))
            print("  Negative: " .. (cursed.negative or "None"))
        end
        
        print(string.rep("═", 70))
        
    else
        print([[
Item Effects System

Usage:
  lua item_effects.lua list [type]  - List all effects (or by type)
  lua item_effects.lua test          - Test effect system

Types: active, passive, cursed

Integration:
  local item_effects = require('item_effects')
  
  -- Use active effect
  local result = item_effects.use_item_effect("flaming_sword", user, target)
  
  -- Check passive effect
  local passive = item_effects.apply_passive_effect("vampire_blade")
  
  -- Get cursed effect
  local cursed = item_effects.apply_cursed_effect("cursed_sword_of_greed")
]])
    end
end

return M
