#!/usr/bin/env lua

print("=================================================")
print("TESTING GAME SERVER MODULE INTEGRATION")
print("=================================================")
print("")

-- Set up proper paths
package.path = package.path .. ';./src/?.lua;./?.lua'

local function test_module(name, path)
    local status, module = pcall(require, path)
    if status then
        print(string.format("✅ %s loaded successfully", name))
        return true, module
    else
        print(string.format("❌ %s FAILED: %s", name, tostring(module)))
        return false, nil
    end
end

print("Core Systems:")
print("-------------------------------------------------")
local ok1, quest_sys = test_module("Quest System", "src.quest_system")
local ok2, init_quests = test_module("Initial Quests", "src.initial_quests")
local ok3, magic = test_module("Magic System", "src.magic")
local ok4, combat = test_module("Combat System", "src.combat")
local ok5, dice = test_module("Dice Roller", "src.dice")

print("")
print("Generator Systems:")
print("-------------------------------------------------")
local ok6, dungeon = test_module("Dungeon Generator", "src.dungeon_generator")
local ok7, chamber_art = test_module("Chamber Art", "src.chamber_art")

print("")
print("Content Systems:")
print("-------------------------------------------------")
local ok8 = test_module("Loot System", "src.loot")
local ok9 = test_module("Encounter System", "src.encounter_gen")
local ok10 = test_module("Trap System", "src.traps")
local ok11 = test_module("Rest System", "src.rest")

print("")
print("Utility Systems:")
print("-------------------------------------------------")
local ok12 = test_module("Inventory", "src.inventory")
local ok13 = test_module("Effects", "src.effects")
local ok14 = test_module("Progression", "src.progression")

print("")
print("=================================================")

-- Count loaded modules
local total = 14
local loaded = 0
for i = 1, 14 do
    if _G["ok" .. i] then loaded = loaded + 1 end
end

print(string.format("RESULTS: %d/%d modules loaded successfully", loaded, total))

if loaded == total then
    print("✅ ALL SYSTEMS OPERATIONAL")
    
    -- Additional verification
    print("")
    print("System Details:")
    print("-------------------------------------------------")
    if init_quests then
        local quests = init_quests.get_default_quests()
        local count = 0
        for _ in pairs(quests) do count = count + 1 end
        print(string.format("  Quests available: %d", count))
    end
    
    if magic then
        local spell_count = 0
        local ability_count = 0
        for _ in pairs(magic.spells) do spell_count = spell_count + 1 end
        for _ in pairs(magic.abilities) do ability_count = ability_count + 1 end
        print(string.format("  Spells: %d, Abilities: %d", spell_count, ability_count))
    end
    
    os.exit(0)
else
    print("❌ SOME SYSTEMS FAILED TO LOAD")
    os.exit(1)
end
