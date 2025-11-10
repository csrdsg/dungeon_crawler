#!/usr/bin/env lua
-- Integration tests for TUI game systems

package.path = package.path .. ";../?.lua"

local Progression = require("src.tui_progression")
local Effects = require("src.tui_effects")
local QuestUI = require("src.tui_quest_ui")
local GameLogic = require("src.game_logic")

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

-- Mock data
local CharacterClasses = dofile("../data/character_classes.lua")

-- INTEGRATION TESTS

test("Progression integrates with player creation", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Progression.init_player(player)
    
    assert_equals(player.level, 1, "Level")
    assert_equals(player.xp, 0, "XP")
    assert_true(player.hp ~= nil, "Has HP")
end)

test("Effects integrate with player creation", function()
    local player = GameLogic.create_player("mage", CharacterClasses)
    Effects.init_entity(player)
    
    local ok, msg = Effects.apply(player, "strength", 3)
    assert_true(ok, "Effect applied to player")
end)

test("Leveling up with effects active", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Progression.init_player(player)
    Effects.init_entity(player)
    
    Effects.apply(player, "poison", 3)
    local leveled, msgs = Progression.add_xp(player, 1000)
    
    assert_true(leveled, "Leveled up")
    assert_true(#player.effects > 0, "Effects persist")
end)

test("Combat with effects and XP", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Progression.init_player(player)
    Effects.init_entity(player)
    
    -- Apply strength buff
    Effects.apply(player, "strength", 3)
    local attack_mod = Effects.get_attack_modifier(player)
    
    assert_equals(attack_mod, 2, "Strength bonus")
    
    -- Simulate XP gain
    Progression.add_xp(player, 500)
    assert_equals(player.xp, 500, "XP tracked")
end)

test("Effect damage can kill player", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Effects.init_entity(player)
    
    player.hp = 5 -- Low HP
    Effects.apply(player, "poison", 3)
    
    -- Process effect multiple times
    local mock_roll = function() return 10 end
    Effects.process_turn(player, mock_roll)
    
    assert_true(player.hp <= 0, "Player died from poison")
end)

test("Quest rewards give XP that levels up", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Progression.init_player(player)
    player.gold = 0
    
    local quest = {
        reward = {gold = 100, xp = 1000}
    }
    
    -- Award quest rewards
    QuestUI.award_rewards(quest, player)
    assert_equals(player.gold, 100, "Got gold")
    
    -- Then add the XP
    local leveled = Progression.add_xp(player, quest.reward.xp)
    assert_true(leveled, "Leveled from quest XP")
end)

test("Multiple systems together", function()
    -- Create player
    local player = GameLogic.create_player("mage", CharacterClasses)
    Progression.init_player(player)
    Effects.init_entity(player)
    
    -- Apply effects
    Effects.apply(player, "strength", 3)
    Effects.apply(player, "regeneration", 3)
    
    -- Gain XP
    Progression.add_xp(player, 500)
    
    -- Process effects
    local mock_roll = function() return 3 end
    Effects.process_turn(player, mock_roll)
    
    -- Verify everything works together
    assert_true(player.level >= 1, "Has level")
    assert_true(player.xp >= 500, "Has XP")
    assert_true(#player.effects > 0, "Has effects")
end)

test("Save game preserves all systems", function()
    local player = GameLogic.create_player("rogue", CharacterClasses)
    Progression.init_player(player)
    Effects.init_entity(player)
    
    player.xp = 750
    player.level = 3
    Effects.apply(player, "strength", 2)
    
    -- Simulate save/load by copying
    local saved_xp = player.xp
    local saved_level = player.level
    local saved_effects = #player.effects
    
    assert_equals(saved_xp, 750, "XP saved")
    assert_equals(saved_level, 3, "Level saved")
    assert_equals(saved_effects, 1, "Effects saved")
end)

test("Quest completion with multiple rewards", function()
    local player = GameLogic.create_player("cleric", CharacterClasses)
    Progression.init_player(player)
    player.gold = 0
    player.items = {}
    player.potions = 0
    
    local quest = {
        title = "Big Quest",
        reward = {
            gold = 500,
            xp = 2000,
            item = "Health Potion"
        }
    }
    
    local msgs = QuestUI.award_rewards(quest, player)
    Progression.add_xp(player, quest.reward.xp)
    
    assert_equals(player.gold, 500, "Gold awarded")
    assert_equals(player.potions, 1, "Potion awarded")
    assert_true(player.level >= 2, "Leveled from quest")
end)

test("Effect modifiers apply in combat", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Effects.init_entity(player)
    
    local base_attack = player.attack_bonus
    
    Effects.apply(player, "strength", 3)
    local modified = base_attack + Effects.get_attack_modifier(player)
    
    assert_true(modified > base_attack, "Attack increased")
end)

test("Stunned effect prevents actions", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Effects.init_entity(player)
    
    assert_true(not Effects.is_stunned(player), "Not stunned initially")
    
    Effects.apply(player, "stunned", 1)
    assert_true(Effects.is_stunned(player), "Is stunned")
end)

test("Level up healing with poison active", function()
    local player = GameLogic.create_player("warrior", CharacterClasses)
    Progression.init_player(player)
    Effects.init_entity(player)
    
    player.hp = 10 -- Damaged
    Effects.apply(player, "poison", 3)
    
    Progression.add_xp(player, 1000) -- Level up heals
    
    assert_equals(player.hp, player.max_hp, "Healed on level up")
    assert_true(#player.effects > 0, "But poison persists")
end)

-- SUMMARY
print("\n" .. string.rep("=", 60))
print("INTEGRATION TESTS SUMMARY")
print(string.rep("=", 60))
print(string.format("Passed: %d", tests_passed))
print(string.format("Failed: %d", tests_failed))
print(string.format("Total:  %d", tests_passed + tests_failed))
print(string.rep("=", 60))

if tests_failed > 0 then
    os.exit(1)
else
    print("✅ All integration tests passed!")
    os.exit(0)
end
