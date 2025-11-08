-- Quest System Module
-- Handles quest tracking, objectives, and progression

local QuestSystem = {}

-- Quest status constants
QuestSystem.STATUS = {
    ACTIVE = "active",
    COMPLETED = "completed",
    FAILED = "failed"
}

-- Quest types
QuestSystem.TYPE = {
    MAIN = "main",
    SIDE = "side",
    OPTIONAL = "optional"
}

-- Create a new quest
function QuestSystem.create_quest(id, data)
    return {
        id = id,
        title = data.title or "Untitled Quest",
        description = data.description or "",
        type = data.type or QuestSystem.TYPE.SIDE,
        status = data.status or QuestSystem.STATUS.ACTIVE,
        objectives = data.objectives or {},
        rewards = data.rewards or {},
        started_at = os.time(),
        completed_at = nil,
        progress = {}
    }
end

-- Initialize quest log
function QuestSystem.init_quest_log()
    return {
        active = {},
        completed = {},
        failed = {}
    }
end

-- Add quest to log
function QuestSystem.add_quest(quest_log, quest)
    if not quest_log or not quest then return false end
    
    if quest.status == QuestSystem.STATUS.ACTIVE then
        quest_log.active[quest.id] = quest
    elseif quest.status == QuestSystem.STATUS.COMPLETED then
        quest_log.completed[quest.id] = quest
    elseif quest.status == QuestSystem.STATUS.FAILED then
        quest_log.failed[quest.id] = quest
    end
    
    return true
end

-- Get quest by ID
function QuestSystem.get_quest(quest_log, quest_id)
    if not quest_log then return nil end
    
    return quest_log.active[quest_id] or 
           quest_log.completed[quest_id] or 
           quest_log.failed[quest_id]
end

-- Complete quest
function QuestSystem.complete_quest(quest_log, quest_id)
    if not quest_log or not quest_log.active[quest_id] then
        return false
    end
    
    local quest = quest_log.active[quest_id]
    quest.status = QuestSystem.STATUS.COMPLETED
    quest.completed_at = os.time()
    
    quest_log.completed[quest_id] = quest
    quest_log.active[quest_id] = nil
    
    return true, quest
end

-- Fail quest
function QuestSystem.fail_quest(quest_log, quest_id)
    if not quest_log or not quest_log.active[quest_id] then
        return false
    end
    
    local quest = quest_log.active[quest_id]
    quest.status = QuestSystem.STATUS.FAILED
    quest.completed_at = os.time()
    
    quest_log.failed[quest_id] = quest
    quest_log.active[quest_id] = nil
    
    return true, quest
end

-- Update quest progress
function QuestSystem.update_progress(quest_log, quest_id, key, value)
    local quest = quest_log.active[quest_id]
    if not quest then return false end
    
    quest.progress[key] = value
    return true
end

-- Check if objective is complete
function QuestSystem.check_objective(quest, objective_id)
    if not quest or not quest.objectives then return false end
    
    for _, obj in ipairs(quest.objectives) do
        if obj.id == objective_id then
            return obj.completed or false
        end
    end
    
    return false
end

-- Complete objective
function QuestSystem.complete_objective(quest, objective_id)
    if not quest or not quest.objectives then return false end
    
    for _, obj in ipairs(quest.objectives) do
        if obj.id == objective_id then
            obj.completed = true
            return true
        end
    end
    
    return false
end

-- Format quest for display
function QuestSystem.format_quest(quest, show_details)
    if not quest then return "" end
    
    local lines = {}
    local status_icon = {
        [QuestSystem.STATUS.ACTIVE] = "🎯",
        [QuestSystem.STATUS.COMPLETED] = "✅",
        [QuestSystem.STATUS.FAILED] = "❌"
    }
    
    local type_label = {
        [QuestSystem.TYPE.MAIN] = "[MAIN]",
        [QuestSystem.TYPE.SIDE] = "[SIDE]",
        [QuestSystem.TYPE.OPTIONAL] = "[OPTIONAL]"
    }
    
    local icon = status_icon[quest.status] or "📜"
    local label = type_label[quest.type] or ""
    
    table.insert(lines, string.format("%s %s %s", icon, label, quest.title))
    
    if show_details then
        if quest.description and quest.description ~= "" then
            table.insert(lines, "   " .. quest.description)
        end
        
        if quest.objectives and #quest.objectives > 0 then
            table.insert(lines, "   Objectives:")
            for _, obj in ipairs(quest.objectives) do
                local check = obj.completed and "✓" or "○"
                table.insert(lines, string.format("     %s %s", check, obj.text))
            end
        end
        
        if quest.status == QuestSystem.STATUS.COMPLETED and quest.rewards then
            if quest.rewards.gold and quest.rewards.gold > 0 then
                table.insert(lines, string.format("   💰 Reward: %d gold", quest.rewards.gold))
            end
            if quest.rewards.items then
                for _, item in ipairs(quest.rewards.items) do
                    table.insert(lines, "   🎁 Reward: " .. item)
                end
            end
        end
    end
    
    return table.concat(lines, "\n")
end

-- Get all active quests
function QuestSystem.get_active_quests(quest_log)
    if not quest_log then return {} end
    
    local quests = {}
    for _, quest in pairs(quest_log.active) do
        table.insert(quests, quest)
    end
    
    -- Sort by type (main first) then by title
    table.sort(quests, function(a, b)
        if a.type ~= b.type then
            if a.type == QuestSystem.TYPE.MAIN then return true end
            if b.type == QuestSystem.TYPE.MAIN then return false end
        end
        return a.title < b.title
    end)
    
    return quests
end

-- Get all completed quests
function QuestSystem.get_completed_quests(quest_log)
    if not quest_log then return {} end
    
    local quests = {}
    for _, quest in pairs(quest_log.completed) do
        table.insert(quests, quest)
    end
    
    table.sort(quests, function(a, b)
        return (a.completed_at or 0) > (b.completed_at or 0)
    end)
    
    return quests
end

-- Count quests by type
function QuestSystem.count_quests(quest_log)
    if not quest_log then 
        return {active = 0, completed = 0, failed = 0}
    end
    
    local count = {active = 0, completed = 0, failed = 0}
    
    for _ in pairs(quest_log.active) do
        count.active = count.active + 1
    end
    
    for _ in pairs(quest_log.completed) do
        count.completed = count.completed + 1
    end
    
    for _ in pairs(quest_log.failed) do
        count.failed = count.failed + 1
    end
    
    return count
end

-- Serialize quest log for saving
function QuestSystem.serialize(quest_log)
    if not quest_log then return "" end
    
    local lines = {}
    
    -- Save active quests
    for _, quest in pairs(quest_log.active) do
        local obj_str = ""
        if quest.objectives then
            local objs = {}
            for _, obj in ipairs(quest.objectives) do
                table.insert(objs, string.format("%s:%s:%s", 
                    obj.id, obj.text:gsub(":", "\\c"), obj.completed and "true" or "false"))
            end
            obj_str = table.concat(objs, "|")
        end
        
        table.insert(lines, string.format("QUEST:%s:%s:%s:%s:%s:%d:%s",
            quest.id,
            quest.title:gsub(":", "\\c"),
            quest.description:gsub(":", "\\c"),
            quest.type,
            quest.status,
            quest.started_at or 0,
            obj_str
        ))
    end
    
    -- Save completed quests
    for _, quest in pairs(quest_log.completed) do
        table.insert(lines, string.format("QUEST:%s:%s:%s:%s:%s:%d:",
            quest.id,
            quest.title:gsub(":", "\\c"),
            quest.description:gsub(":", "\\c"),
            quest.type,
            quest.status,
            quest.completed_at or 0
        ))
    end
    
    return table.concat(lines, "\n")
end

-- Deserialize quest log from save
function QuestSystem.deserialize(data)
    local quest_log = QuestSystem.init_quest_log()
    
    if not data or data == "" then
        return quest_log
    end
    
    for line in data:gmatch("[^\n]+") do
        -- Split manually to handle escaped colons
        local parts = {}
        local current = ""
        local i = 1
        while i <= #line do
            if line:sub(i, i+1) == "\\c" then
                current = current .. ":"
                i = i + 2
            elseif line:sub(i, i) == ":" then
                table.insert(parts, current)
                current = ""
                i = i + 1
            else
                current = current .. line:sub(i, i)
                i = i + 1
            end
        end
        table.insert(parts, current) -- Add last part
        
        if parts[1] == "QUEST" and #parts >= 6 then
            local quest = {
                id = parts[2],
                title = parts[3],
                description = parts[4],
                type = parts[5],
                status = parts[6],
                started_at = tonumber(parts[7]) or os.time(),
                completed_at = tonumber(parts[7]) or os.time(),
                objectives = {}
            }
            
            -- Parse objectives if present
            if parts[8] and parts[8] ~= "" then
                for obj_str in parts[8]:gmatch("[^|]+") do
                    -- Parse objective parts (id:text:completed)
                    local obj_parts = {}
                    local obj_current = ""
                    local j = 1
                    while j <= #obj_str do
                        if obj_str:sub(j, j+1) == "\\c" then
                            obj_current = obj_current .. ":"
                            j = j + 2
                        elseif obj_str:sub(j, j) == ":" then
                            table.insert(obj_parts, obj_current)
                            obj_current = ""
                            j = j + 1
                        else
                            obj_current = obj_current .. obj_str:sub(j, j)
                            j = j + 1
                        end
                    end
                    table.insert(obj_parts, obj_current)
                    
                    if #obj_parts >= 3 then
                        table.insert(quest.objectives, {
                            id = obj_parts[1],
                            text = obj_parts[2],
                            completed = obj_parts[3] == "true"
                        })
                    end
                end
            end
            
            QuestSystem.add_quest(quest_log, quest)
        end
    end
    
    return quest_log
end

return QuestSystem
