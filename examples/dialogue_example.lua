-- Example usage of the Dialogue System
-- Run this with: lua examples/dialogue_example.lua

local DialogueSystem = require("src.dialogue_system")
local DialogueContent = require("data.dialogue_content")

print("=== Dialogue System Demo ===\n")

-- Create a test game context
local context = {
    gold = 150,
    inventory = {},
    quests = {},
    stats = {
        charisma = 12,
        intelligence = 16
    },
    flags = {},
    reputation = {}
}

-- Example 1: Merchant interaction
print("\n--- Example 1: Meeting a Merchant ---")
local merchant_dialogue = DialogueContent.get("merchant_greeting")
context = DialogueSystem.runDialogue(merchant_dialogue, context)

print("\n[Current gold: " .. context.gold .. "]")
print("[Inventory items: " .. #context.inventory .. "]")

-- Example 2: Quest Giver
print("\n\n--- Example 2: Quest Giver ---")
local quest_dialogue = DialogueContent.get("quest_giver_initial")
context = DialogueSystem.runDialogue(quest_dialogue, context)

print("\n[Active quests: " .. #context.quests .. "]")

-- Example 3: Mysterious Stranger (with charisma check)
print("\n\n--- Example 3: Mysterious Stranger ---")
local stranger_dialogue = DialogueContent.get("mysterious_stranger")
context = DialogueSystem.runDialogue(stranger_dialogue, context)

-- Example 4: Show how conditions filter options
print("\n\n--- Example 4: Context-Dependent Options ---")
print("Adding Sacred Amulet to inventory...")
table.insert(context.inventory, { id = "sacred_amulet", name = "Sacred Amulet" })

-- Mark quest as active
table.insert(context.quests, { id = "retrieve_amulet", status = "active" })

-- Now the quest turn-in option should appear
context = DialogueSystem.runDialogue(quest_dialogue, context)

-- Show final state
print("\n\n=== Final Context State ===")
print("Gold: " .. context.gold)
print("Inventory items: " .. #context.inventory)
print("Active quests: ")
for _, quest in ipairs(context.quests) do
    print("  - " .. quest.id .. " [" .. quest.status .. "]")
end
print("\nFlags set:")
for flag, value in pairs(context.flags) do
    if value then
        print("  - " .. flag)
    end
end
print("\nReputation:")
for faction, rep in pairs(context.reputation) do
    print("  - " .. faction .. ": " .. rep)
end
