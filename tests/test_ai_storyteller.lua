#!/usr/bin/env lua

-- Test AI Storyteller Module
-- Tests basic functionality with mocked LLM responses

package.path = package.path .. ";../src/?.lua;./src/?.lua"

local ai_storyteller = require("ai_storyteller")

-- Test framework
local tests_passed = 0
local tests_failed = 0

local function assert_test(condition, test_name)
    if condition then
        print("✅ PASS: " .. test_name)
        tests_passed = tests_passed + 1
    else
        print("❌ FAIL: " .. test_name)
        tests_failed = tests_failed + 1
    end
end

-- Mock LLM for testing (override get_completion)
local original_get_completion = ai_storyteller.get_completion
local mock_enabled = false
local mock_response = nil

local function enable_mock(response)
    mock_enabled = true
    mock_response = response
    ai_storyteller.get_completion = function(prompt, options)
        if mock_enabled and mock_response then
            return mock_response, 0.1
        end
        return original_get_completion(prompt, options)
    end
end

local function disable_mock()
    mock_enabled = false
    mock_response = nil
    ai_storyteller.get_completion = original_get_completion
end

print("\n🧪 Testing AI Storyteller Module")
print("=" .. string.rep("=", 50))

-- Test 1: Module loading
assert_test(ai_storyteller ~= nil, "Module loads successfully")
assert_test(type(ai_storyteller.init) == "function", "init function exists")
assert_test(type(ai_storyteller.narrate_chamber) == "function", "narrate_chamber function exists")
assert_test(type(ai_storyteller.narrate_combat) == "function", "narrate_combat function exists")

-- Test 2: Configuration
print("\n📋 Configuration Tests")
ai_storyteller.init({
    enabled = false,
    provider = "ollama",
    model = "test-model"
})
assert_test(ai_storyteller.config.provider == "ollama", "Configuration sets provider")
assert_test(ai_storyteller.config.model == "test-model", "Configuration sets model")
assert_test(ai_storyteller.config.enabled == false, "Configuration sets enabled flag")

-- Test 3: Prompt building
print("\n📝 Prompt Building Tests")
local template = "The {creature} attacks with {weapon}!"
local context = {creature = "dragon", weapon = "fire breath"}
local prompt = ai_storyteller.build_prompt(template, context)
assert_test(prompt == "The dragon attacks with fire breath!", "Basic prompt substitution")

local template2 = "Items: {items}, Count: {count}"
local context2 = {items = {"sword", "shield"}, count = 2}
local prompt2 = ai_storyteller.build_prompt(template2, context2)
assert_test(prompt2:find("sword") ~= nil, "Array to string conversion")

-- Test 4: Response validation
print("\n✅ Response Validation Tests")
assert_test(ai_storyteller.validate_response(nil) == nil, "Rejects nil response")
assert_test(ai_storyteller.validate_response("") == nil, "Rejects empty response")
assert_test(ai_storyteller.validate_response("   ") == nil, "Rejects whitespace-only response")
assert_test(ai_storyteller.validate_response("short") == nil, "Rejects too-short response")

local valid_text = "This is a perfectly valid response with enough length to pass validation."
local validated = ai_storyteller.validate_response(valid_text)
assert_test(validated ~= nil, "Accepts valid response")
assert_test(validated == valid_text, "Preserves valid content")

local long_text = string.rep("a", 2500)
local truncated = ai_storyteller.validate_response(long_text)
assert_test(#truncated == 2000, "Truncates overly long responses")

-- Test 5: Cache management
print("\n💾 Cache Tests")
ai_storyteller.clear_cache()
assert_test(next(ai_storyteller.cache) == nil, "Cache clears successfully")

ai_storyteller._cache_response("key1", "response1")
assert_test(ai_storyteller.cache["key1"] == "response1", "Cache stores responses")
assert_test(#ai_storyteller.cache_order == 1, "Cache order tracking")

-- Fill cache beyond limit
for i = 1, 105 do
    ai_storyteller._cache_response("key" .. i, "response" .. i)
end
assert_test(#ai_storyteller.cache_order <= 100, "Cache evicts oldest entries")

-- Test 6: Chamber narration with mocked LLM
print("\n🏰 Chamber Narration Tests")
enable_mock("You enter a dark, foreboding chamber with ancient stone walls.")

ai_storyteller.config.enabled = true
local chamber_data = {
    type = "throne_room",
    exits = "north, east",
    items = "golden crown",
    enemies = "skeletal guard"
}

local narration = ai_storyteller.narrate_chamber(chamber_data, {})
assert_test(narration ~= nil, "Chamber narration generates response")
assert_test(type(narration) == "string", "Chamber narration returns string")

-- Test with disabled AI
ai_storyteller.config.enabled = false
local narration_disabled = ai_storyteller.narrate_chamber(chamber_data, {})
assert_test(narration_disabled == nil, "Returns nil when disabled")

ai_storyteller.config.enabled = true

-- Test 7: Combat narration with mocked LLM
print("\n⚔️  Combat Narration Tests")
enable_mock("The warrior's blade cuts deep into the orc's flesh!")

local hit_event = {
    event = "hit",
    attacker = "Player",
    defender = "Orc",
    weapon = "sword",
    damage = 15
}

local combat_narration = ai_storyteller.narrate_combat(hit_event)
assert_test(combat_narration ~= nil, "Combat narration generates response")
assert_test(type(combat_narration) == "string", "Combat narration returns string")

enable_mock("The warrior's swing misses wildly!")
local miss_event = {
    event = "miss",
    attacker = "Player",
    defender = "Goblin",
    weapon = "axe"
}

local miss_narration = ai_storyteller.narrate_combat(miss_event)
assert_test(miss_narration ~= nil, "Miss event generates narration")

enable_mock("A devastating critical strike shatters the enemy's defenses!")
local crit_event = {
    event = "critical",
    attacker = "Player",
    defender = "Dragon",
    weapon = "legendary sword",
    damage = 50
}

local crit_narration = ai_storyteller.narrate_combat(crit_event)
assert_test(crit_narration ~= nil, "Critical hit generates narration")

enable_mock("The enemy falls, defeated.")
local defeat_event = {
    event = "defeat",
    attacker = "Player",
    defender = "Boss"
}

local defeat_narration = ai_storyteller.narrate_combat(defeat_event)
assert_test(defeat_narration ~= nil, "Defeat event generates narration")

-- Test 8: Stats tracking
print("\n📊 Stats Tracking Tests")
local stats = ai_storyteller.get_stats()
assert_test(stats ~= nil, "Stats object exists")
assert_test(stats.enabled ~= nil, "Stats includes enabled status")
assert_test(stats.provider ~= nil, "Stats includes provider")
assert_test(stats.model ~= nil, "Stats includes model")
assert_test(type(stats.requests) == "number", "Stats tracks requests")
assert_test(type(stats.successes) == "number", "Stats tracks successes")

-- Test 9: Error handling
print("\n🛡️  Error Handling Tests")
enable_mock(nil)  -- Simulate failed API call

local failed_narration = ai_storyteller.narrate_chamber({type = "test"}, {})
assert_test(failed_narration == nil, "Returns nil on API failure")
assert_test(ai_storyteller.stats.failures > 0, "Tracks failures in stats")

-- Test 10: Integration readiness
print("\n🔗 Integration Readiness Tests")
assert_test(type(ai_storyteller.test_connection) == "function", "Connection test function exists")
assert_test(type(ai_storyteller.get_stats) == "function", "Stats retrieval function exists")
assert_test(type(ai_storyteller.clear_cache) == "function", "Cache clear function exists")

-- Cleanup
disable_mock()

-- Summary
print("\n" .. string.rep("=", 50))
print(string.format("✅ Tests Passed: %d", tests_passed))
print(string.format("❌ Tests Failed: %d", tests_failed))
print(string.rep("=", 50))

if tests_failed == 0 then
    print("🎉 All tests passed!")
    os.exit(0)
else
    print("⚠️  Some tests failed.")
    os.exit(1)
end
