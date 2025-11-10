-- Quest UI System for TUI
-- Handles quest display and tracking

local QuestUI = {}

-- Format quest for display
function QuestUI.format_quest(quest)
    local lines = {}
    
    -- Title
    local icon = quest.completed and "✅" or (quest.failed and "❌" or "📜")
    table.insert(lines, string.format("%s %s", icon, quest.title or "Unknown Quest"))
    
    -- Description
    if quest.description then
        table.insert(lines, "  " .. quest.description)
    end
    
    -- Objectives
    if quest.objectives and #quest.objectives > 0 then
        table.insert(lines, "  Objectives:")
        for i, obj in ipairs(quest.objectives) do
            local check = obj.completed and "☑" or "☐"
            table.insert(lines, string.format("    %s %s", check, obj.description or "???"))
        end
    end
    
    -- Progress
    if quest.progress then
        table.insert(lines, string.format("  Progress: %s", quest.progress))
    end
    
    -- Reward
    if quest.reward and not quest.completed then
        local reward_text = ""
        if quest.reward.gold then
            reward_text = reward_text .. string.format("%d gold ", quest.reward.gold)
        end
        if quest.reward.xp then
            reward_text = reward_text .. string.format("%d XP ", quest.reward.xp)
        end
        if quest.reward.item then
            reward_text = reward_text .. quest.reward.item
        end
        if reward_text ~= "" then
            table.insert(lines, "  Reward: " .. reward_text)
        end
    end
    
    return lines
end

-- Get quest counts
function QuestUI.get_counts(quest_log)
    local counts = {
        active = 0,
        completed = 0,
        failed = 0,
        total = 0
    }
    
    if not quest_log then return counts end
    
    if quest_log.active then
        counts.active = #quest_log.active
    end
    if quest_log.completed then
        counts.completed = #quest_log.completed
    end
    if quest_log.failed then
        counts.failed = #quest_log.failed
    end
    
    counts.total = counts.active + counts.completed + counts.failed
    
    return counts
end

-- Get all quests for display
function QuestUI.get_all_quests(quest_log)
    local all_quests = {}
    
    if not quest_log then return all_quests end
    
    -- Add active quests
    if quest_log.active then
        for _, quest in ipairs(quest_log.active) do
            quest.status = "active"
            table.insert(all_quests, quest)
        end
    end
    
    -- Add completed quests
    if quest_log.completed then
        for _, quest in ipairs(quest_log.completed) do
            quest.status = "completed"
            quest.completed = true
            table.insert(all_quests, quest)
        end
    end
    
    -- Add failed quests
    if quest_log.failed then
        for _, quest in ipairs(quest_log.failed) do
            quest.status = "failed"
            quest.failed = true
            table.insert(all_quests, quest)
        end
    end
    
    return all_quests
end

-- Get quest summary for character panel
function QuestUI.get_summary(quest_log)
    local counts = QuestUI.get_counts(quest_log)
    return string.format("Quests: %d active, %d done", counts.active, counts.completed)
end

-- Check if player has completed quest objective
function QuestUI.check_objective(quest, objective_id, condition)
    if not quest or not quest.objectives then return false end
    
    for _, obj in ipairs(quest.objectives) do
        if obj.id == objective_id then
            if condition and condition() then
                obj.completed = true
                return true
            end
        end
    end
    
    return false
end

-- Check if quest is fully completed
function QuestUI.is_quest_complete(quest)
    if not quest or not quest.objectives then return false end
    
    for _, obj in ipairs(quest.objectives) do
        if not obj.completed then
            return false
        end
    end
    
    return true
end

-- Award quest rewards
function QuestUI.award_rewards(quest, player)
    local messages = {}
    
    if not quest or not quest.reward then
        return messages
    end
    
    local reward = quest.reward
    
    -- Gold reward
    if reward.gold then
        player.gold = player.gold + reward.gold
        table.insert(messages, string.format("Received %d gold!", reward.gold))
    end
    
    -- XP reward
    if reward.xp then
        table.insert(messages, string.format("Received %d XP!", reward.xp))
        -- Note: Caller should handle XP with progression system
    end
    
    -- Item reward
    if reward.item then
        if reward.item == "Health Potion" then
            player.potions = player.potions + 1
            table.insert(messages, "Received a Health Potion!")
        else
            table.insert(player.items, reward.item)
            table.insert(messages, string.format("Received: %s", reward.item))
        end
    end
    
    -- Special rewards
    if reward.special then
        table.insert(messages, reward.special)
    end
    
    return messages
end

return QuestUI
