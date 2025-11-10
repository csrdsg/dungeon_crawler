-- Status Effects System for TUI
-- Handles buffs, debuffs, and status conditions

local Effects = {}

-- Effect definitions
local EFFECT_TYPES = {
    poison = {
        name = "Poisoned",
        icon = "☠️",
        damage = "1d4",
        duration = 3,
        type = "debuff",
        color_code = "\27[35m" -- magenta
    },
    bleeding = {
        name = "Bleeding",
        icon = "🩸",
        damage = "1d6",
        duration = 2,
        type = "debuff",
        color_code = "\27[31m" -- red
    },
    stunned = {
        name = "Stunned",
        icon = "💫",
        damage = "0",
        duration = 1,
        type = "debuff",
        color_code = "\27[33m" -- yellow
    },
    strength = {
        name = "Strength",
        icon = "💪",
        damage = "0",
        duration = 3,
        type = "buff",
        attack_bonus = 2,
        color_code = "\27[32m" -- green
    },
    regeneration = {
        name = "Regenerating",
        icon = "💚",
        healing = "1d6",
        duration = 3,
        type = "buff",
        color_code = "\27[32m" -- green
    },
    curse = {
        name = "Cursed",
        icon = "👿",
        damage = "1d4",
        duration = 4,
        type = "debuff",
        attack_penalty = 2,
        color_code = "\27[35m" -- magenta
    }
}

-- Initialize effects array on entity
function Effects.init_entity(entity)
    entity.effects = entity.effects or {}
    return entity
end

-- Apply effect to entity
-- Returns: success (boolean), message (string)
function Effects.apply(entity, effect_type, duration_override)
    local effect_def = EFFECT_TYPES[effect_type]
    if not effect_def then
        return false, "Unknown effect: " .. effect_type
    end
    
    entity.effects = entity.effects or {}
    
    -- Check if already affected
    for _, active in ipairs(entity.effects) do
        if active.type == effect_type then
            -- Refresh duration
            active.duration = duration_override or effect_def.duration
            return true, string.format("%s %s refreshed!", effect_def.icon, effect_def.name)
        end
    end
    
    -- Add new effect
    local new_effect = {
        type = effect_type,
        name = effect_def.name,
        icon = effect_def.icon,
        duration = duration_override or effect_def.duration,
        damage = effect_def.damage,
        healing = effect_def.healing,
        attack_bonus = effect_def.attack_bonus,
        attack_penalty = effect_def.attack_penalty,
        color_code = effect_def.color_code
    }
    
    table.insert(entity.effects, new_effect)
    
    return true, string.format("%s %s applied! (%d turns)", 
        effect_def.icon, effect_def.name, new_effect.duration)
end

-- Process effects at turn start (damage/healing)
-- Returns: messages (array of strings)
function Effects.process_turn(entity, roll_func)
    local messages = {}
    
    if not entity.effects or #entity.effects == 0 then
        return messages
    end
    
    for i = #entity.effects, 1, -1 do
        local effect = entity.effects[i]
        
        -- Apply damage
        if effect.damage and effect.damage ~= "0" then
            local damage = roll_func(effect.damage)
            entity.hp = entity.hp - damage
            table.insert(messages, string.format("%s %s: -%d HP", 
                effect.icon, effect.name, damage))
        end
        
        -- Apply healing
        if effect.healing then
            local heal = roll_func(effect.healing)
            local old_hp = entity.hp
            entity.hp = math.min(entity.max_hp, entity.hp + heal)
            local actual_heal = entity.hp - old_hp
            if actual_heal > 0 then
                table.insert(messages, string.format("%s %s: +%d HP", 
                    effect.icon, effect.name, actual_heal))
            end
        end
        
        -- Decrement duration
        effect.duration = effect.duration - 1
        
        -- Remove expired effects
        if effect.duration <= 0 then
            table.insert(messages, string.format("%s %s wore off", 
                effect.icon, effect.name))
            table.remove(entity.effects, i)
        end
    end
    
    return messages
end

-- Check if entity has specific effect
function Effects.has_effect(entity, effect_type)
    if not entity.effects then return false end
    
    for _, effect in ipairs(entity.effects) do
        if effect.type == effect_type then
            return true
        end
    end
    return false
end

-- Get attack bonus/penalty from effects
function Effects.get_attack_modifier(entity)
    local modifier = 0
    
    if not entity.effects then return modifier end
    
    for _, effect in ipairs(entity.effects) do
        if effect.attack_bonus then
            modifier = modifier + effect.attack_bonus
        end
        if effect.attack_penalty then
            modifier = modifier - effect.attack_penalty
        end
    end
    
    return modifier
end

-- Check if entity is stunned (can't act)
function Effects.is_stunned(entity)
    return Effects.has_effect(entity, "stunned")
end

-- Get formatted list of active effects for display
function Effects.get_display_list(entity)
    if not entity.effects or #entity.effects == 0 then
        return {}
    end
    
    local list = {}
    for _, effect in ipairs(entity.effects) do
        local display = string.format("%s%s %s (%d)%s", 
            effect.color_code or "",
            effect.icon,
            effect.name,
            effect.duration,
            "\27[0m" -- reset
        )
        table.insert(list, display)
    end
    
    return list
end

-- Remove all effects from entity
function Effects.clear_all(entity)
    entity.effects = {}
end

-- Get all available effect types
function Effects.get_available_effects()
    local types = {}
    for name, _ in pairs(EFFECT_TYPES) do
        table.insert(types, name)
    end
    return types
end

return Effects
