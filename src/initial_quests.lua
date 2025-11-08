-- Initial Quest Data for Bimbo's Quest
-- Defines the main and side quests available in the game

local QuestSystem = require("src.quest_system")

-- Load quest data from external file
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"
local quest_definitions = dofile(data_dir .. "quests.lua")

local InitialQuests = {}

-- Define all quests
function InitialQuests.get_default_quests()
    local quests = {}
    
    -- Load quests from data file
    for quest_id, quest_data in pairs(quest_definitions) do
        quests[quest_id] = QuestSystem.create_quest(quest_id, {
            title = quest_data.title,
            description = quest_data.description,
            type = QuestSystem.TYPE[quest_data.type:upper()] or QuestSystem.TYPE.SIDE,
            status = QuestSystem.STATUS.ACTIVE,
            objectives = quest_data.objectives,
            rewards = quest_data.rewards
        })
    end
    
    return quests
end

-- Initialize quest log with default quests
function InitialQuests.init_quest_log()
    local quest_log = QuestSystem.init_quest_log()
    local quests = InitialQuests.get_default_quests()
    
    for _, quest in pairs(quests) do
        QuestSystem.add_quest(quest_log, quest)
    end
    
    return quest_log
end

return InitialQuests
