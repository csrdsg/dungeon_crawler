#!/usr/bin/env lua
-- Unit tests for Quest UI System

package.path = package.path .. ";../?.lua"

local QuestUI = require("src.tui_quest_ui")

local tests_passed = 0
local tests_failed = 0

local function test(name, fn)
    io.write(string.format("%-50s", name .. "..."))
    local ok, err = pcall(fn)
    if ok then
        print(" ✅ PASS")
        tests_passed = tests_passed + 1
    else
        print(" ❌ FAIL")
        print("  Error: " .. tostring(err))
        tests_failed = tests_failed + 1
    end
end

local function assert_equals(actual, expected, msg)
    if actual ~= expected then
        error(string.format("%s: expected %s but got %s", msg or "Assertion failed", tostring(expected), tostring(actual)))
    end
end

local function assert_true(value, msg)
    if not value then
        error(msg or "Expected true")
    end
end

-- UNIT TESTS

test("Get counts returns zero for empty log", function()
    local quest_log = {active = {}, completed = {}, failed = {}}
    local counts = QuestUI.get_counts(quest_log)
    
    assert_equals(counts.active, 0, "Active")
    assert_equals(counts.completed, 0, "Completed")
    assert_equals(counts.failed, 0, "Failed")
    assert_equals(counts.total, 0, "Total")
end)

test("Get counts works for active quests", function()
    local quest_log = {
        active = {{title = "Quest 1"}, {title = "Quest 2"}},
        completed = {},
        failed = {}
    }
    local counts = QuestUI.get_counts(quest_log)
    
    assert_equals(counts.active, 2, "Active")
    assert_equals(counts.total, 2, "Total")
end)

test("Get counts handles nil log", function()
    local counts = QuestUI.get_counts(nil)
    assert_equals(counts.total, 0, "Nil log returns 0")
end)

test("Format quest creates lines", function()
    local quest = {
        title = "Test Quest",
        description = "A test quest"
    }
    
    local lines = QuestUI.format_quest(quest)
    assert_true(#lines > 0, "Has lines")
end)

test("Format quest shows objectives", function()
    local quest = {
        title = "Test Quest",
        objectives = {
            {description = "Do thing 1", completed = false},
            {description = "Do thing 2", completed = true}
        }
    }
    
    local lines = QuestUI.format_quest(quest)
    local found_objectives = false
    for _, line in ipairs(lines) do
        if line:find("Objectives") then
            found_objectives = true
            break
        end
    end
    
    assert_true(found_objectives, "Shows objectives")
end)

test("Format quest shows rewards", function()
    local quest = {
        title = "Test Quest",
        reward = {gold = 100, xp = 500}
    }
    
    local lines = QuestUI.format_quest(quest)
    local found_reward = false
    for _, line in ipairs(lines) do
        if line:find("Reward") then
            found_reward = true
            break
        end
    end
    
    assert_true(found_reward, "Shows reward")
end)

test("Get all quests combines categories", function()
    local quest_log = {
        active = {{title = "Q1"}},
        completed = {{title = "Q2"}},
        failed = {{title = "Q3"}}
    }
    
    local all = QuestUI.get_all_quests(quest_log)
    assert_equals(#all, 3, "All quests")
end)

test("Get summary formats correctly", function()
    local quest_log = {
        active = {{title = "Q1"}, {title = "Q2"}},
        completed = {{title = "Q3"}},
        failed = {}
    }
    
    local summary = QuestUI.get_summary(quest_log)
    assert_true(summary:find("2 active"), "Shows active count")
    assert_true(summary:find("1 done"), "Shows completed count")
end)

test("Is quest complete checks all objectives", function()
    local quest = {
        objectives = {
            {completed = true},
            {completed = true}
        }
    }
    
    assert_true(QuestUI.is_quest_complete(quest), "All complete")
end)

test("Is quest complete returns false if incomplete", function()
    local quest = {
        objectives = {
            {completed = true},
            {completed = false}
        }
    }
    
    assert_true(not QuestUI.is_quest_complete(quest), "Not all complete")
end)

test("Award rewards gives gold", function()
    local quest = {reward = {gold = 100}}
    local player = {gold = 0}
    
    QuestUI.award_rewards(quest, player)
    assert_equals(player.gold, 100, "Gold awarded")
end)

test("Award rewards gives potion", function()
    local quest = {reward = {item = "Health Potion"}}
    local player = {potions = 0}
    
    QuestUI.award_rewards(quest, player)
    assert_equals(player.potions, 1, "Potion awarded")
end)

test("Award rewards gives items", function()
    local quest = {reward = {item = "Magic Sword"}}
    local player = {items = {}}
    
    QuestUI.award_rewards(quest, player)
    assert_equals(#player.items, 1, "Item awarded")
end)

test("Award rewards returns messages", function()
    local quest = {reward = {gold = 100, xp = 500}}
    local player = {gold = 0}
    
    local msgs = QuestUI.award_rewards(quest, player)
    assert_true(#msgs >= 2, "Got messages")
end)

test("Format quest shows completion icon", function()
    local quest = {
        title = "Test Quest",
        completed = true
    }
    
    local lines = QuestUI.format_quest(quest)
    local first_line = lines[1]
    assert_true(first_line:find("✅"), "Shows checkmark")
end)

test("Format quest shows failed icon", function()
    local quest = {
        title = "Test Quest",
        failed = true
    }
    
    local lines = QuestUI.format_quest(quest)
    local first_line = lines[1]
    assert_true(first_line:find("❌"), "Shows X")
end)

test("Check objective marks as complete", function()
    local quest = {
        objectives = {
            {id = "obj1", description = "Test", completed = false}
        }
    }
    
    local result = QuestUI.check_objective(quest, "obj1", function() return true end)
    assert_true(result, "Marked complete")
    assert_true(quest.objectives[1].completed, "Objective completed")
end)

-- SUMMARY
print("\n" .. string.rep("=", 60))
print("QUEST UI TESTS SUMMARY")
print(string.rep("=", 60))
print(string.format("Passed: %d", tests_passed))
print(string.format("Failed: %d", tests_failed))
print(string.format("Total:  %d", tests_passed + tests_failed))
print(string.rep("=", 60))

if tests_failed > 0 then
    os.exit(1)
else
    print("✅ All tests passed!")
    os.exit(0)
end
