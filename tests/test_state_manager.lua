#!/usr/bin/env lua
-- Test State Manager functionality

local StateManager = require("src.state_manager")

print("🧪 Testing State Manager\n")
print(string.rep("=", 60))

-- Initialize
StateManager.init()
print("✓ Directories initialized")

-- Test 1: Save and load character
print("\n📋 Test 1: Character save/load")
local test_char = {
    name = "Test Hero",
    max_hp = 100,
    ac = 15,
    level = 5,
    class = "Wizard"
}

local success = StateManager.save_character("test_hero", test_char)
assert(success, "Failed to save character")
print("  ✓ Character saved")

local loaded_char = StateManager.load_character("test_hero")
assert(loaded_char, "Failed to load character")
assert(loaded_char.name == "Test Hero", "Character name mismatch")
assert(loaded_char.level == 5, "Character level mismatch")
print("  ✓ Character loaded correctly")

-- Test 2: Character template
print("\n🎭 Test 2: Character template")
local player = {
    name = "Warrior",
    hp = 50,
    max_hp = 50,
    ac = 18,
    attack_bonus = 5,
    damage = "1d8+3",
    class = "Fighter",
    level = 3,
    gold = 100,
    potions = 5,
    items = {"Sword", "Shield"}
}

success = StateManager.export_character_template(player, "warrior_template")
assert(success, "Failed to export template")
print("  ✓ Template exported")

local new_char = StateManager.import_character_template("warrior_template")
assert(new_char, "Failed to import template")
assert(new_char.name == "Warrior", "Template name mismatch")
assert(new_char.max_hp == 50, "Template HP mismatch")
assert(new_char.gold == 0, "Template should reset gold")
assert(#new_char.items == 0, "Template should reset items")
print("  ✓ Template imported (stats preserved, progress reset)")

-- Test 3: Session save/load
print("\n💾 Test 3: Session save/load")
local session_data = {
    player = {
        name = "TestPlayer",
        hp = 50,
        max_hp = 50,
        gold = 100
    },
    dungeon = {
        num_chambers = 5,
        player_position = 2,
        chambers = {
            [1] = {id = 1, type = 1, visited = true, connections = {2}},
            [2] = {id = 2, type = 2, visited = false, connections = {1, 3}}
        }
    },
    quest_log = {
        active = {},
        completed = {},
        failed = {}
    },
    metadata = {
        test = true
    }
}

success = StateManager.save_session("test_session", session_data)
assert(success, "Failed to save session")
print("  ✓ Session saved")

local loaded_session = StateManager.load_session("test_session")
assert(loaded_session, "Failed to load session")
assert(loaded_session.player.name == "TestPlayer", "Player name mismatch")
assert(loaded_session.dungeon.num_chambers == 5, "Dungeon size mismatch")
assert(loaded_session.metadata.test == true, "Metadata mismatch")
print("  ✓ Session loaded correctly")

-- Test 4: Quick save/load
print("\n⚡ Test 4: Quick save/load")
success = StateManager.quick_save(player, session_data.dungeon, session_data.quest_log, "QuickTest")
assert(success, "Failed to quick save")
print("  ✓ Quick saved")

local quick_session = StateManager.quick_load("quicktest")
assert(quick_session, "Failed to quick load")
assert(quick_session.player.name == "Warrior", "Quick load player mismatch")
print("  ✓ Quick loaded")

-- Test 5: List functions
print("\n📜 Test 5: List functions")
local chars = StateManager.list_characters()
assert(#chars >= 2, "Should have at least 2 characters")
print("  ✓ Listed " .. #chars .. " characters")

local sessions = StateManager.list_sessions()
assert(#sessions >= 2, "Should have at least 2 sessions")
print("  ✓ Listed " .. #sessions .. " sessions")

-- Test 6: Delete
print("\n🗑️  Test 6: Delete operations")
success = StateManager.delete_character("test_hero")
assert(success, "Failed to delete character")
print("  ✓ Character deleted")

-- Cleanup test files
os.remove("data/sessions/test_session.lua")
os.remove("data/sessions/quicktest.lua")
os.remove("data/characters/warrior_template.lua")
print("  ✓ Test files cleaned up")

print("\n" .. string.rep("=", 60))
print("✅ All tests passed!")
print("\n💡 State Manager is ready to use!")
print("   Run: lua state_manager_cli.lua list-sessions")
