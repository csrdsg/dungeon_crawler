-- Progression System for TUI
-- Handles XP tracking and leveling up

local Progression = {}

-- Calculate XP needed for next level
function Progression.xp_for_level(level)
    return level * 1000
end

-- Initialize progression on player
function Progression.init_player(player)
    player.xp = player.xp or 0
    player.level = player.level or 1
    player.next_level_xp = Progression.xp_for_level(player.level)
    return player
end

-- Add XP and check for level up
-- Returns: leveled_up (boolean), messages (array)
function Progression.add_xp(player, amount)
    local messages = {}
    local old_level = player.level
    
    player.xp = player.xp + amount
    table.insert(messages, string.format("Gained %d XP!", amount))
    
    local leveled_up = false
    
    -- Check for level up (can level multiple times)
    while player.xp >= Progression.xp_for_level(player.level) do
        player.level = player.level + 1
        leveled_up = true
        
        -- Stat increases on level up
        local hp_gain = math.random(4, 8)
        player.max_hp = player.max_hp + hp_gain
        player.hp = player.max_hp -- Heal on level up
        
        -- Mana gain for casters
        if player.max_mana and player.max_mana > 0 then
            local mana_gain = math.random(2, 5)
            player.max_mana = player.max_mana + mana_gain
            player.mana = player.max_mana
        end
        
        -- Stat improvements
        player.attack_bonus = player.attack_bonus + 1
        
        table.insert(messages, string.format("⭐ LEVEL UP! Now level %d!", player.level))
        table.insert(messages, string.format("HP +%d (now %d)", hp_gain, player.max_hp))
        table.insert(messages, "Attack +1")
        
        if player.max_mana and player.max_mana > 0 then
            table.insert(messages, "Fully restored HP and Mana!")
        else
            table.insert(messages, "Fully restored HP!")
        end
        
        -- Milestones
        if player.level == 5 then
            table.insert(messages, "🌟 MILESTONE: You feel more powerful!")
            player.attack_bonus = player.attack_bonus + 1
        elseif player.level == 10 then
            table.insert(messages, "🌟 MILESTONE: Master tier reached!")
            player.ac = player.ac + 1
        elseif player.level == 15 then
            table.insert(messages, "🌟 MILESTONE: Legendary power unlocked!")
            player.max_hp = player.max_hp + 10
        end
    end
    
    player.next_level_xp = Progression.xp_for_level(player.level)
    
    return leveled_up, messages
end

-- Get XP progress percentage
function Progression.get_progress(player)
    local current_level_xp = Progression.xp_for_level(player.level - 1)
    local next_level_xp = Progression.xp_for_level(player.level)
    local xp_in_level = player.xp - current_level_xp
    local xp_needed = next_level_xp - current_level_xp
    
    return math.floor((xp_in_level / xp_needed) * 100)
end

-- Get XP in current level
function Progression.get_current_level_xp(player)
    local current_level_xp = Progression.xp_for_level(player.level - 1)
    return player.xp - current_level_xp
end

-- Get XP needed for next level
function Progression.get_xp_needed(player)
    local current_level_xp = Progression.xp_for_level(player.level - 1)
    local next_level_xp = Progression.xp_for_level(player.level)
    return next_level_xp - current_level_xp
end

return Progression
