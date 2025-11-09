-- Comprehensive test suite for the Dialogue System
-- Run with: lua tests/test_dialogue_system.lua

local DialogueSystem = require("src.dialogue_system")
local DialogueContent = require("data.dialogue_content")

-- Test counter
local tests_passed = 0
local tests_failed = 0

-- Helper function to run a test
local function test(name, fn)
    io.write("Testing: " .. name .. " ... ")
    local success, error_msg = pcall(fn)
    if success then
        print("✓ PASSED")
        tests_passed = tests_passed + 1
    else
        print("✗ FAILED")
        print("  Error: " .. tostring(error_msg))
        tests_failed = tests_failed + 1
    end
end

-- Helper function to assert
local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error(message or string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
    end
end

local function assert_true(value, message)
    if not value then
        error(message or "Expected true, got false")
    end
end

local function assert_false(value, message)
    if value then
        error(message or "Expected false, got true")
    end
end

print("=== Dialogue System Test Suite ===\n")

-- =============================================================================
-- Test 1: Basic condition checking
-- =============================================================================

test("Quest active condition - should pass", function()
    local context = {
        quests = {
            { id = "test_quest", status = "active" }
        }
    }
    local condition = { quest_active = "test_quest" }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Quest active condition - should fail", function()
    local context = {
        quests = {
            { id = "test_quest", status = "completed" }
        }
    }
    local condition = { quest_active = "test_quest" }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

test("Quest completed condition - should pass", function()
    local context = {
        quests = {
            { id = "test_quest", status = "completed" }
        }
    }
    local condition = { quest_completed = "test_quest" }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

-- =============================================================================
-- Test 2: Stat requirements
-- =============================================================================

test("Charisma check - should pass", function()
    local context = {
        stats = { charisma = 15 }
    }
    local condition = { min_charisma = 15 }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Charisma check - should fail", function()
    local context = {
        stats = { charisma = 10 }
    }
    local condition = { min_charisma = 15 }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

test("Intelligence check - should pass", function()
    local context = {
        stats = { intelligence = 18 }
    }
    local condition = { min_intelligence = 15 }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

-- =============================================================================
-- Test 3: Item requirements
-- =============================================================================

test("Has item condition - should pass", function()
    local context = {
        inventory = {
            { id = "iron_key", name = "Iron Key" },
            { id = "sword", name = "Rusty Sword" }
        }
    }
    local condition = { has_item = "iron_key" }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Has item condition - should fail", function()
    local context = {
        inventory = {
            { id = "sword", name = "Rusty Sword" }
        }
    }
    local condition = { has_item = "iron_key" }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

-- =============================================================================
-- Test 4: Gold requirements
-- =============================================================================

test("Gold check - should pass", function()
    local context = { gold = 100 }
    local condition = { min_gold = 50 }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Gold check - should fail", function()
    local context = { gold = 30 }
    local condition = { min_gold = 50 }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

-- =============================================================================
-- Test 5: Flag system
-- =============================================================================

test("Flag set - should pass", function()
    local context = {
        flags = { test_flag = true }
    }
    local condition = { flag = "test_flag" }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Flag not set - should fail", function()
    local context = {
        flags = { other_flag = true }
    }
    local condition = { flag = "test_flag" }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

test("Not flag - should pass when flag absent", function()
    local context = {
        flags = { other_flag = true }
    }
    local condition = { not_flag = "test_flag" }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Not flag - should fail when flag present", function()
    local context = {
        flags = { test_flag = true }
    }
    local condition = { not_flag = "test_flag" }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

-- =============================================================================
-- Test 6: Filter options
-- =============================================================================

test("Filter options - all conditions met", function()
    local context = {
        gold = 100,
        stats = { charisma = 15 }
    }
    local options = {
        { text = "Option 1", condition = { min_gold = 50 } },
        { text = "Option 2", condition = { min_charisma = 10 } },
        { text = "Option 3" }
    }
    local filtered = DialogueSystem.filterOptions(options, context)
    assert_equal(#filtered, 3, "All 3 options should be available")
end)

test("Filter options - some conditions not met", function()
    local context = {
        gold = 30,
        stats = { charisma = 5 }
    }
    local options = {
        { text = "Option 1", condition = { min_gold = 50 } },
        { text = "Option 2", condition = { min_charisma = 10 } },
        { text = "Option 3" }
    }
    local filtered = DialogueSystem.filterOptions(options, context)
    assert_equal(#filtered, 1, "Only 1 option should be available")
end)

-- =============================================================================
-- Test 7: Execute results - quest management
-- =============================================================================

test("Start quest", function()
    local context = { quests = {} }
    local result = { start_quest = "new_quest" }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(#context.quests, 1, "Should have 1 quest")
    assert_equal(context.quests[1].id, "new_quest", "Quest ID should match")
    assert_equal(context.quests[1].status, "active", "Quest should be active")
end)

test("Complete quest", function()
    local context = {
        quests = {
            { id = "test_quest", status = "active" }
        }
    }
    local result = { complete_quest = "test_quest" }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(context.quests[1].status, "completed", "Quest should be completed")
end)

-- =============================================================================
-- Test 8: Execute results - gold transactions
-- =============================================================================

test("Gain gold", function()
    local context = { gold = 100 }
    local result = { gold_change = 50 }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(context.gold, 150, "Should have 150 gold")
end)

test("Lose gold", function()
    local context = { gold = 100 }
    local result = { gold_change = -30 }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(context.gold, 70, "Should have 70 gold")
end)

-- =============================================================================
-- Test 9: Execute results - inventory
-- =============================================================================

test("Add item to inventory", function()
    local context = { inventory = {} }
    local result = {
        add_item = { id = "potion", name = "Health Potion" }
    }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(#context.inventory, 1, "Should have 1 item")
    assert_equal(context.inventory[1].id, "potion", "Item ID should match")
end)

test("Remove item from inventory", function()
    local context = {
        inventory = {
            { id = "key", name = "Old Key" },
            { id = "potion", name = "Health Potion" }
        }
    }
    local result = { remove_item = "key" }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(#context.inventory, 1, "Should have 1 item left")
    assert_equal(context.inventory[1].id, "potion", "Wrong item removed")
end)

-- =============================================================================
-- Test 10: Execute results - flags
-- =============================================================================

test("Set flag", function()
    local context = { flags = {} }
    local result = { set_flag = "test_flag" }
    context = DialogueSystem.executeResult(result, context)
    assert_true(context.flags.test_flag, "Flag should be set")
end)

test("Unset flag", function()
    local context = { flags = { test_flag = true } }
    local result = { unset_flag = "test_flag" }
    context = DialogueSystem.executeResult(result, context)
    assert_false(context.flags.test_flag, "Flag should be unset")
end)

-- =============================================================================
-- Test 11: Execute results - reputation
-- =============================================================================

test("Increase reputation", function()
    local context = { reputation = {} }
    local result = {
        reputation_change = { village = 25 }
    }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(context.reputation.village, 25, "Reputation should be 25")
end)

test("Decrease reputation", function()
    local context = { reputation = { thieves_guild = 50 } }
    local result = {
        reputation_change = { thieves_guild = -20 }
    }
    context = DialogueSystem.executeResult(result, context)
    assert_equal(context.reputation.thieves_guild, 30, "Reputation should be 30")
end)

-- =============================================================================
-- Test 12: Dialogue content validation
-- =============================================================================

test("All dialogues are accessible", function()
    for _, dialogue_id in ipairs(DialogueContent.all_dialogues) do
        local dialogue = DialogueContent.get(dialogue_id)
        assert_true(dialogue ~= nil, "Dialogue " .. dialogue_id .. " should exist")
        assert_true(dialogue.speaker ~= nil, "Dialogue should have speaker")
        assert_true(dialogue.options ~= nil, "Dialogue should have options")
    end
end)

test("Merchant dialogue structure", function()
    local dialogue = DialogueContent.get("merchant_greeting")
    assert_equal(dialogue.speaker, "Merchant")
    assert_true(#dialogue.options >= 3, "Should have at least 3 options")
end)

test("Quest giver dialogue has conditional options", function()
    local dialogue = DialogueContent.get("quest_giver_initial")
    local has_conditional = false
    for _, option in ipairs(dialogue.options) do
        if option.condition then
            has_conditional = true
            break
        end
    end
    assert_true(has_conditional, "Should have at least one conditional option")
end)

-- =============================================================================
-- Test 13: Complex condition combinations
-- =============================================================================

test("Multiple conditions - all met", function()
    local context = {
        gold = 100,
        stats = { charisma = 15 },
        inventory = { { id = "key", name = "Key" } },
        flags = { talked_to_guard = true }
    }
    local condition = {
        min_gold = 50,
        min_charisma = 10,
        has_item = "key",
        flag = "talked_to_guard"
    }
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Multiple conditions - one not met", function()
    local context = {
        gold = 100,
        stats = { charisma = 5 },
        inventory = { { id = "key", name = "Key" } },
        flags = { talked_to_guard = true }
    }
    local condition = {
        min_gold = 50,
        min_charisma = 10,
        has_item = "key",
        flag = "talked_to_guard"
    }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

-- =============================================================================
-- Test 14: Edge cases
-- =============================================================================

test("Empty context - no conditions", function()
    local context = {}
    local condition = nil
    assert_true(DialogueSystem.checkCondition(condition, context))
end)

test("Empty inventory check", function()
    local context = { inventory = {} }
    local condition = { has_item = "key" }
    assert_false(DialogueSystem.checkCondition(condition, context))
end)

test("Nil context - should handle gracefully", function()
    local condition = { min_gold = 50 }
    -- Should not crash, should return false
    assert_false(DialogueSystem.checkCondition(condition, {}))
end)

test("Execute result on nil result", function()
    local context = { gold = 100 }
    local original_gold = context.gold
    context = DialogueSystem.executeResult(nil, context)
    assert_equal(context.gold, original_gold, "Context should be unchanged")
end)

-- =============================================================================
-- Print results
-- =============================================================================

print("\n" .. string.rep("=", 60))
print("TEST RESULTS")
print(string.rep("=", 60))
print(string.format("✓ Passed: %d", tests_passed))
print(string.format("✗ Failed: %d", tests_failed))
print(string.format("Total:    %d", tests_passed + tests_failed))

if tests_failed == 0 then
    print("\n🎉 All tests passed!")
    os.exit(0)
else
    print("\n❌ Some tests failed!")
    os.exit(1)
end
