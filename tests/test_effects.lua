#!/usr/bin/env lua
-- Unit tests for Effects System

package.path = package.path .. ";../?.lua"

local Effects = require("src.tui_effects")

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

local function assert_false(value, msg)
    if value then
        error(msg or "Expected false")
    end
end

-- Mock roll function for testing
local function mock_roll(dice)
    return 3 -- Always return 3 for predictable tests
end

-- UNIT TESTS

test("Init entity creates effects array", function()
    local entity = {}
    Effects.init_entity(entity)
    assert_true(entity.effects ~= nil, "Effects array exists")
    assert_equals(#entity.effects, 0, "Effects array empty")
end)

test("Apply poison effect works", function()
    local entity = {}
    Effects.init_entity(entity)
    
    local ok, msg = Effects.apply(entity, "poison", 3)
    assert_true(ok, "Effect applied")
    assert_equals(#entity.effects, 1, "One effect")
end)

test("Cannot apply unknown effect", function()
    local entity = {}
    Effects.init_entity(entity)
    
    local ok, msg = Effects.apply(entity, "unknown", 3)
    assert_false(ok, "Should fail")
end)

test("Applying same effect refreshes duration", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 2)
    Effects.apply(entity, "poison", 5)
    
    assert_equals(#entity.effects, 1, "Still one effect")
    assert_equals(entity.effects[1].duration, 5, "Duration refreshed")
end)

test("Has effect check works", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "stunned", 1)
    assert_true(Effects.has_effect(entity, "stunned"), "Has stunned")
    assert_false(Effects.has_effect(entity, "poison"), "Doesn't have poison")
end)

test("Is stunned check works", function()
    local entity = {}
    Effects.init_entity(entity)
    
    assert_false(Effects.is_stunned(entity), "Not stunned initially")
    
    Effects.apply(entity, "stunned", 1)
    assert_true(Effects.is_stunned(entity), "Is stunned")
end)

test("Process turn applies damage", function()
    local entity = {hp = 30, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 3)
    Effects.process_turn(entity, mock_roll)
    
    assert_equals(entity.hp, 27, "HP reduced by 3") -- mock_roll returns 3
end)

test("Process turn applies healing", function()
    local entity = {hp = 20, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "regeneration", 3)
    Effects.process_turn(entity, mock_roll)
    
    assert_equals(entity.hp, 23, "HP increased by 3")
end)

test("Process turn decrements duration", function()
    local entity = {hp = 30, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 3)
    Effects.process_turn(entity, mock_roll)
    
    assert_equals(entity.effects[1].duration, 2, "Duration decreased")
end)

test("Effect expires after duration", function()
    local entity = {hp = 30, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "stunned", 1)
    Effects.process_turn(entity, mock_roll)
    
    assert_equals(#entity.effects, 0, "Effect expired")
end)

test("Get attack modifier works for strength", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "strength", 3)
    local mod = Effects.get_attack_modifier(entity)
    
    assert_equals(mod, 2, "Strength gives +2")
end)

test("Get attack modifier works for curse", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "curse", 3)
    local mod = Effects.get_attack_modifier(entity)
    
    assert_equals(mod, -2, "Curse gives -2")
end)

test("Multiple effects stack modifiers", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "strength", 3)
    Effects.apply(entity, "curse", 3)
    local mod = Effects.get_attack_modifier(entity)
    
    assert_equals(mod, 0, "Strength +2 and Curse -2 = 0")
end)

test("Get display list works", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 3)
    Effects.apply(entity, "strength", 2)
    
    local list = Effects.get_display_list(entity)
    assert_equals(#list, 2, "Two effects in list")
end)

test("Clear all effects works", function()
    local entity = {}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 3)
    Effects.apply(entity, "strength", 2)
    
    Effects.clear_all(entity)
    assert_equals(#entity.effects, 0, "All effects cleared")
end)

test("Healing doesn't exceed max HP", function()
    local entity = {hp = 29, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "regeneration", 3)
    Effects.process_turn(entity, mock_roll) -- Would heal 3
    
    assert_equals(entity.hp, 30, "HP capped at max")
end)

test("Multiple damage effects stack", function()
    local entity = {hp = 30, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 3)
    Effects.apply(entity, "bleeding", 3)
    Effects.process_turn(entity, mock_roll) -- Each deals 3
    
    assert_equals(entity.hp, 24, "Both effects dealt damage")
end)

test("Process turn returns messages", function()
    local entity = {hp = 30, max_hp = 30}
    Effects.init_entity(entity)
    
    Effects.apply(entity, "poison", 1)
    local messages = Effects.process_turn(entity, mock_roll)
    
    assert_true(#messages >= 1, "Got messages")
end)

-- SUMMARY
print("\n" .. string.rep("=", 60))
print("EFFECTS TESTS SUMMARY")
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
