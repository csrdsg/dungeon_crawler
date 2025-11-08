#!/usr/bin/env lua
-- test_magic.lua - Unit tests for magic and abilities system
package.path = package.path .. ";../src/?.lua"

local test = require('test_framework')
local magic = require('magic')

test.describe("Magic System - Spells", function()
    
    test.it("should load all spells", function()
        test.assert_not_nil(magic.spells)
        test.assert_not_nil(magic.spells.magic_missile)
        test.assert_not_nil(magic.spells.fireball)
        test.assert_not_nil(magic.spells.cure_wounds)
    end)
    
    test.it("should cast magic missile successfully", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 1, mp = 10, max_mp = 10}
        local result = magic.cast_spell(wizard, "magic_missile")
        
        test.assert_true(result.success)
        test.assert_equal(wizard.mp, 7, "Should cost 3 mana")
        test.assert_not_nil(result.damage)
        test.assert_greater_than(result.damage, 0)
    end)
    
    test.it("should fail when insufficient mana", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 1, mp = 1, max_mp = 10}
        local result = magic.cast_spell(wizard, "magic_missile")
        
        test.assert_false(result.success)
        test.assert_equal(wizard.mp, 1, "Mana should not be deducted on failure")
    end)
    
    test.it("should heal with cure wounds", function()
        local cleric = {name = "Test Cleric", class = "cleric", level = 1, mp = 10, max_mp = 10}
        local result = magic.cast_spell(cleric, "cure_wounds")
        
        test.assert_true(result.success)
        test.assert_not_nil(result.healing)
        test.assert_greater_than(result.healing, 0)
    end)
    
    test.it("should apply AC bonus with shield", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 1, mp = 10, max_mp = 10}
        local result = magic.cast_spell(wizard, "shield")
        
        test.assert_true(result.success)
        test.assert_equal(result.ac_bonus, 5)
        test.assert_equal(result.duration, 3)
    end)
    
    test.it("should handle saving throws for fireball", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 3, mp = 20, max_mp = 20}
        local target = {dex = 5}  -- High DEX for better save chance
        local result = magic.cast_spell(wizard, "fireball", target)
        
        test.assert_true(result.success)
        test.assert_not_nil(result.damage)
    end)
    
end)

test.describe("Magic System - Abilities", function()
    
    test.it("should load all abilities", function()
        test.assert_not_nil(magic.abilities)
        test.assert_not_nil(magic.abilities.second_wind)
        test.assert_not_nil(magic.abilities.sneak_attack)
    end)
    
    test.it("should use second wind successfully", function()
        local fighter = {name = "Test Fighter", class = "fighter", level = 3}
        local result = magic.use_ability(fighter, "second_wind")
        
        test.assert_true(result.success)
        test.assert_not_nil(result.healing)
        test.assert_greater_than(result.healing, 0)
    end)
    
    test.it("should enforce class requirements", function()
        local rogue = {name = "Test Rogue", class = "rogue", level = 5}
        local result = magic.use_ability(rogue, "second_wind")  -- Fighter ability
        
        test.assert_false(result.success)
    end)
    
    test.it("should enforce level requirements", function()
        local fighter = {name = "Test Fighter", class = "fighter", level = 1}
        local result = magic.use_ability(fighter, "action_surge")  -- Requires level 2
        
        test.assert_false(result.success)
    end)
    
    test.it("should get available spells for character", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 1}
        local spells = magic.get_available_spells(wizard)
        
        test.assert_type(spells, "table")
        test.assert_greater_than(#spells, 0, "Should have some available spells")
    end)
    
    test.it("should get available abilities for character", function()
        local fighter = {name = "Test Fighter", class = "fighter", level = 1}
        local abilities = magic.get_available_abilities(fighter)
        
        test.assert_type(abilities, "table")
        test.assert_greater_than(#abilities, 0, "Should have some available abilities")
    end)
    
end)

test.describe("Magic System - Edge Cases", function()
    
    test.it("should handle unknown spell", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 1, mp = 10, max_mp = 10}
        local result = magic.cast_spell(wizard, "nonexistent_spell")
        
        test.assert_false(result.success)
    end)
    
    test.it("should handle unknown ability", function()
        local fighter = {name = "Test Fighter", class = "fighter", level = 1}
        local result = magic.use_ability(fighter, "nonexistent_ability")
        
        test.assert_false(result.success)
    end)
    
    test.it("should handle zero mana", function()
        local wizard = {name = "Test Wizard", class = "wizard", level = 1, mp = 0, max_mp = 10}
        local result = magic.cast_spell(wizard, "magic_missile")
        
        test.assert_false(result.success)
        test.assert_equal(wizard.mp, 0)
    end)
    
end)

test.describe("Magic System - Spell Types", function()
    
    test.it("should differentiate arcane and divine spells", function()
        local arcane_count = 0
        local divine_count = 0
        
        for _, spell in pairs(magic.spells) do
            if spell.type == "arcane" then
                arcane_count = arcane_count + 1
            elseif spell.type == "divine" then
                divine_count = divine_count + 1
            end
        end
        
        test.assert_greater_than(arcane_count, 0, "Should have arcane spells")
        test.assert_greater_than(divine_count, 0, "Should have divine spells")
    end)
    
    test.it("should have damage spells", function()
        local damage_spells = 0
        
        for _, spell in pairs(magic.spells) do
            if spell.damage then
                damage_spells = damage_spells + 1
            end
        end
        
        test.assert_greater_than(damage_spells, 0, "Should have damage spells")
    end)
    
    test.it("should have healing spells", function()
        local healing_spells = 0
        
        for _, spell in pairs(magic.spells) do
            if spell.healing then
                healing_spells = healing_spells + 1
            end
        end
        
        test.assert_greater_than(healing_spells, 0, "Should have healing spells")
    end)
    
    test.it("should have buff spells", function()
        local buff_spells = 0
        
        for _, spell in pairs(magic.spells) do
            if spell.ac_bonus or spell.bonus or spell.duration then
                buff_spells = buff_spells + 1
            end
        end
        
        test.assert_greater_than(buff_spells, 0, "Should have buff spells")
    end)
    
end)

local success = test.summary()
os.exit(success and 0 or 1)
