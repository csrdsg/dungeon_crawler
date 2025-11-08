-- Quest Event Handler
-- Decouples quest tracking from game commands

local QuestSystem = require("src.quest_system")

local QuestHandler = {}

-- Check and complete quests based on game events
function QuestHandler.check_quest_completion(session, event_type, event_data)
    if not session or not session.quest_log then
        return {}
    end
    
    local notifications = {}
    local player = session.player
    local dungeon = session.dungeon
    
    -- Gold collection check (Treasure Hunter)
    if event_type == "gold_gained" then
        if player.gold >= 100 then
            local quest = QuestSystem.get_quest(session.quest_log, "optional_treasure")
            if quest and quest.status == QuestSystem.STATUS.ACTIVE then
                QuestSystem.complete_objective(quest, "collect_gold")
                local success, completed_quest = QuestSystem.complete_quest(session.quest_log, "optional_treasure")
                if success then
                    player.gold = player.gold + 50
                    table.insert(notifications, "")
                    table.insert(notifications, "🎉 QUEST COMPLETED: Treasure Hunter!")
                    table.insert(notifications, "💰 Reward: 50 gold pieces!")
                end
            end
        end
    end
    
    -- Item collection check (Curious Collector)
    if event_type == "item_gained" then
        if #player.items >= 5 then
            local quest = QuestSystem.get_quest(session.quest_log, "optional_items")
            if quest and quest.status == QuestSystem.STATUS.ACTIVE then
                QuestSystem.complete_objective(quest, "collect_items")
                local success, completed_quest = QuestSystem.complete_quest(session.quest_log, "optional_items")
                if success then
                    table.insert(player.items, "Collector's Bag")
                    table.insert(notifications, "")
                    table.insert(notifications, "🎉 QUEST COMPLETED: Curious Collector!")
                    table.insert(notifications, "🎁 Reward: Collector's Bag!")
                end
            end
        end
    end
    
    -- Exploration check (Map the Dungeon)
    if event_type == "chamber_entered" then
        local all_visited = true
        for i = 1, dungeon.num_chambers do
            if not dungeon.chambers[i].visited then
                all_visited = false
                break
            end
        end
        
        if all_visited then
            local quest = QuestSystem.get_quest(session.quest_log, "side_explore")
            if quest and quest.status == QuestSystem.STATUS.ACTIVE then
                QuestSystem.complete_objective(quest, "explore_10")
                local success, completed_quest = QuestSystem.complete_quest(session.quest_log, "side_explore")
                if success then
                    player.gold = player.gold + 25
                    table.insert(player.items, "Mapper's Compass")
                    table.insert(notifications, "")
                    table.insert(notifications, "🎉 QUEST COMPLETED: Map the Dungeon!")
                    table.insert(notifications, "💰 Reward: 25 gold pieces!")
                    table.insert(notifications, "🎁 Reward: Mapper's Compass!")
                end
            end
        end
    end
    
    -- Vault unlocked (Unlock the Ancient Vault)
    if event_type == "vault_unlocked" then
        local quest = QuestSystem.get_quest(session.quest_log, "side_vault")
        if quest and quest.status == QuestSystem.STATUS.ACTIVE then
            QuestSystem.complete_objective(quest, "unlock_vault")
            local success, completed_quest = QuestSystem.complete_quest(session.quest_log, "side_vault")
            if success then
                table.insert(notifications, "")
                table.insert(notifications, "🎉 QUEST COMPLETED: Unlock the Ancient Vault!")
                table.insert(notifications, "✨ Quest reward already collected from vault!")
            end
        end
    end
    
    -- Boss defeated (Free Captain Theron's Spirit)
    if event_type == "boss_defeated" then
        local boss_name = event_data and event_data.boss_name
        if boss_name == "Iron Sentinel" then
            local quest = QuestSystem.get_quest(session.quest_log, "main_theron")
            if quest and quest.status == QuestSystem.STATUS.ACTIVE then
                QuestSystem.complete_objective(quest, "defeat_sentinel")
                local success, completed_quest = QuestSystem.complete_quest(session.quest_log, "main_theron")
                if success then
                    player.gold = player.gold + 100
                    table.insert(player.items, "Captain's Signet Ring")
                    table.insert(player.items, "Blessed Sword")
                    table.insert(notifications, "")
                    table.insert(notifications, "🎉 QUEST COMPLETED: Free Captain Theron's Spirit!")
                    table.insert(notifications, "💰 Reward: 100 gold pieces!")
                    table.insert(notifications, "🎁 Reward: Captain's Signet Ring")
                    table.insert(notifications, "🎁 Reward: Blessed Sword")
                    table.insert(notifications, "")
                    table.insert(notifications, "👻 The spirit of Captain Theron appears...")
                    table.insert(notifications, "💬 'Thank you, brave adventurer. You have freed me from my torment.'")
                end
            end
        end
    end
    
    return notifications
end

-- Trigger quest-related discoveries
function QuestHandler.check_discoveries(session, location, search_roll)
    local discoveries = {}
    
    -- Vault discovery in Chamber 8
    if location == 8 and search_roll >= 15 then
        if not session.vault_found then
            session.vault_found = true
            table.insert(discoveries, "")
            table.insert(discoveries, "🔐 *** VAULT DISCOVERED! ***")
            table.insert(discoveries, "You found an ancient vault sealed with a silver lock!")
            table.insert(discoveries, "💡 Use 'unlock vault' with the Silver Key to open it.")
        else
            table.insert(discoveries, "🔐 You see the ancient vault (use 'unlock vault')")
        end
        return discoveries, true -- true = special discovery made
    end
    
    return discoveries, false
end

return QuestHandler
