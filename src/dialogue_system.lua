-- Dialogue System - Menu-based conversation mechanics
-- This module handles the display and interaction with dialogue menus

local DialogueSystem = {}

-- Display a dialogue menu and get player choice
-- @param dialogue: dialogue data structure
-- @param context: optional context data (player stats, quest state, etc.)
-- @return selected option table or nil if cancelled
function DialogueSystem.presentMenu(dialogue, context)
    context = context or {}
    
    if not dialogue then
        return nil
    end
    
    -- Display speaker and opening text
    if dialogue.speaker then
        print("\n" .. dialogue.speaker .. ":")
    end
    
    if dialogue.text then
        print('"' .. dialogue.text .. '"')
    end
    
    -- Filter available options based on conditions
    local available_options = DialogueSystem.filterOptions(dialogue.options, context)
    
    if #available_options == 0 then
        return nil
    end
    
    -- Display options
    print("\nWhat do you say?")
    for i, option in ipairs(available_options) do
        local display_text = option.text
        
        -- Add hints if present
        if option.hint then
            display_text = display_text .. " [" .. option.hint .. "]"
        end
        
        print(string.format("  %d) %s", i, display_text))
    end
    
    -- Get player choice
    local choice = tonumber(io.read())
    
    if choice and choice >= 1 and choice <= #available_options then
        return available_options[choice]
    end
    
    return nil
end

-- Filter dialogue options based on conditions
-- @param options: array of dialogue options
-- @param context: context data for condition checking
-- @return filtered array of available options
function DialogueSystem.filterOptions(options, context)
    if not options then
        return {}
    end
    
    local filtered = {}
    
    for _, option in ipairs(options) do
        if DialogueSystem.checkCondition(option.condition, context) then
            table.insert(filtered, option)
        end
    end
    
    return filtered
end

-- Check if a condition is met
-- @param condition: condition table or nil
-- @param context: context data
-- @return true if condition is met or no condition exists
function DialogueSystem.checkCondition(condition, context)
    if not condition then
        return true
    end
    
    -- Check quest requirements
    if condition.quest_active and context.quests then
        local quest_found = false
        for _, quest in ipairs(context.quests) do
            if quest.id == condition.quest_active and quest.status == "active" then
                quest_found = true
                break
            end
        end
        if not quest_found then
            return false
        end
    end
    
    if condition.quest_completed and context.quests then
        local quest_found = false
        for _, quest in ipairs(context.quests) do
            if quest.id == condition.quest_completed and quest.status == "completed" then
                quest_found = true
                break
            end
        end
        if not quest_found then
            return false
        end
    end
    
    -- Check stat requirements
    if condition.min_charisma and context.stats then
        if (context.stats.charisma or 0) < condition.min_charisma then
            return false
        end
    end
    
    if condition.min_intelligence and context.stats then
        if (context.stats.intelligence or 0) < condition.min_intelligence then
            return false
        end
    end
    
    -- Check inventory requirements
    if condition.has_item and context.inventory then
        local has_item = false
        for _, item in ipairs(context.inventory) do
            if item.name == condition.has_item or item.id == condition.has_item then
                has_item = true
                break
            end
        end
        if not has_item then
            return false
        end
    end
    
    -- Check gold requirement
    if condition.min_gold then
        if not context.gold or context.gold < condition.min_gold then
            return false
        end
    end
    
    -- Check flag requirements
    if condition.flag and context.flags then
        if not context.flags[condition.flag] then
            return false
        end
    end
    
    if condition.not_flag and context.flags then
        if context.flags[condition.not_flag] then
            return false
        end
    end
    
    return true
end

-- Execute the result of a dialogue choice
-- @param result: result table from selected option
-- @param context: game context to modify
-- @return modified context
function DialogueSystem.executeResult(result, context)
    if not result then
        return context
    end
    
    context = context or {}
    
    -- Display response text
    if result.response then
        print('\n"' .. result.response .. '"')
    end
    
    -- Start a quest
    if result.start_quest then
        context.quests = context.quests or {}
        table.insert(context.quests, {
            id = result.start_quest,
            status = "active"
        })
        print("\n[Quest started: " .. result.start_quest .. "]")
    end
    
    -- Complete a quest
    if result.complete_quest then
        if context.quests then
            for _, quest in ipairs(context.quests) do
                if quest.id == result.complete_quest then
                    quest.status = "completed"
                    print("\n[Quest completed: " .. result.complete_quest .. "]")
                    break
                end
            end
        end
    end
    
    -- Modify gold
    if result.gold_change then
        context.gold = (context.gold or 0) + result.gold_change
        if result.gold_change > 0 then
            print("\n[Gained " .. result.gold_change .. " gold]")
        else
            print("\n[Lost " .. math.abs(result.gold_change) .. " gold]")
        end
    end
    
    -- Add item
    if result.add_item then
        context.inventory = context.inventory or {}
        table.insert(context.inventory, result.add_item)
        print("\n[Received: " .. (result.add_item.name or "item") .. "]")
    end
    
    -- Remove item
    if result.remove_item then
        if context.inventory then
            for i, item in ipairs(context.inventory) do
                if item.name == result.remove_item or item.id == result.remove_item then
                    table.remove(context.inventory, i)
                    print("\n[Lost: " .. result.remove_item .. "]")
                    break
                end
            end
        end
    end
    
    -- Set flag
    if result.set_flag then
        context.flags = context.flags or {}
        context.flags[result.set_flag] = true
    end
    
    -- Unset flag
    if result.unset_flag then
        context.flags = context.flags or {}
        context.flags[result.unset_flag] = false
    end
    
    -- Modify reputation
    if result.reputation_change then
        context.reputation = context.reputation or {}
        for faction, change in pairs(result.reputation_change) do
            context.reputation[faction] = (context.reputation[faction] or 0) + change
            print(string.format("\n[%s reputation %s%d]", faction, 
                change > 0 and "+" or "", change))
        end
    end
    
    return context
end

-- Run a complete dialogue sequence
-- @param dialogue_tree: dialogue data with potential branches
-- @param context: game context
-- @return final context after dialogue
function DialogueSystem.runDialogue(dialogue_tree, context)
    local current_dialogue = dialogue_tree
    
    while current_dialogue do
        local selected = DialogueSystem.presentMenu(current_dialogue, context)
        
        if not selected then
            break
        end
        
        -- Execute the result of the choice
        if selected.result then
            context = DialogueSystem.executeResult(selected.result, context)
        end
        
        -- Move to next dialogue node
        if selected.next then
            current_dialogue = selected.next
        else
            break
        end
    end
    
    return context
end

return DialogueSystem
