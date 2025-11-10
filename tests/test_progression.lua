#!/usr/bin/env lua
-- Unit tests for Progression System

package.path = package.path .. ";../?.lua"

local Progression = require("src.tui_progression")

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

-- UNIT TESTS

test("Init player sets level to 1", function()
    local player = {}
    Progression.init_player(player)
    assert_equals(player.level, 1, "Level")
    assert_equals(player.xp, 0, "XP")
end)

test("XP calculation correct for level 1", function()
    local xp = Progression.xp_for_level(1)
    assert_equals(xp, 1000, "Level 1 XP")
end)

test("XP calculation correct for level 5", function()
    local xp = Progression.xp_for_level(5)
    assert_equals(xp, 5000, "Level 5 XP")
end)

test("Adding XP below threshold doesn't level up", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    local leveled, msgs = Progression.add_xp(player, 500)
    assert_equals(leveled, false, "Should not level up")
    assert_equals(player.level, 1, "Level unchanged")
    assert_equals(player.xp, 500, "XP added")
end)

test("Adding XP at threshold levels up", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    local leveled, msgs = Progression.add_xp(player, 1000)
    assert_equals(leveled, true, "Should level up")
    assert_equals(player.level, 2, "Level increased")
end)

test("Leveling up increases HP", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    local old_max_hp = player.max_hp
    Progression.add_xp(player, 1000)
    
    if player.max_hp <= old_max_hp then
        error("HP should have increased")
    end
end)

test("Leveling up increases attack", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    local old_attack = player.attack_bonus
    Progression.add_xp(player, 1000)
    
    assert_equals(player.attack_bonus, old_attack + 1, "Attack bonus")
end)

test("Multiple level ups work", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    -- Level thresholds are cumulative:
    -- Level 2: 2000 XP
    -- Level 3: 3000 XP  
    -- Level 4: 4000 XP
    -- So 6000 XP gets you to level 7 (6000/1000 = level 7)
    Progression.add_xp(player, 6000)
    
    assert_equals(player.level, 7, "Should be level 7")
end)

test("Get progress percentage works", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    Progression.add_xp(player, 500) -- 50% to level 2
    local progress = Progression.get_progress(player)
    
    assert_equals(progress, 50, "Progress")
end)

test("Milestone bonus at level 5", function()
    local player = {hp = 30, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    local old_attack = player.attack_bonus
    
    -- XP needed: level*1000, so 5000 XP gets to level 6 (since 5000 >= 5*1000)
    -- To stop at level 5, we need less than 5000
    Progression.add_xp(player, 4999)
    
    assert_equals(player.level, 5, "Should be level 5")
    -- +4 from levels plus +1 from milestone = +5
    assert_equals(player.attack_bonus, old_attack + 5, "Milestone bonus")
end)

test("Mana increases for casters", function()
    local player = {hp = 30, max_hp = 30, mana = 50, max_mana = 50, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    local old_mana = player.max_mana
    Progression.add_xp(player, 1000)
    
    if player.max_mana <= old_mana then
        error("Mana should have increased")
    end
end)

test("Level up restores HP to full", function()
    local player = {hp = 15, max_hp = 30, attack_bonus = 3, ac = 15}
    Progression.init_player(player)
    
    Progression.add_xp(player, 1000)
    
    assert_equals(player.hp, player.max_hp, "HP restored")
end)

-- SUMMARY
print("\n" .. string.rep("=", 60))
print("PROGRESSION TESTS SUMMARY")
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
