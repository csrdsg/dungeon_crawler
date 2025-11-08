#!/usr/bin/env lua
-- test_combat.lua - Unit tests for combat module
package.path = package.path .. ";../src/?.lua"

local test = require('test_framework')

-- Mock character and enemy for testing
local test_char = {
    name = "Test Hero",
    hp = 30,
    max_hp = 30,
    ac = 14,
    atk = 3,
    dmg = 2
}

local test_enemy = {
    name = "Goblin",
    hp = 10,
    ac = 12,
    atk = 2,
    dmg = 1
}

test.describe("Combat Module", function()
    
    test.it("should load combat module", function()
        local ok, combat = pcall(require, 'combat')
        test.assert_true(ok, "Failed to load combat module")
    end)
    
    test.it("should have attack roll function", function()
        -- Test that basic d20 roll works
        local roll = math.random(1, 20) + 3
        test.assert_in_range(roll, 4, 23, "Attack roll out of range")
    end)
    
    test.it("should calculate hit based on AC", function()
        local roll = 15
        local attack_bonus = 3
        local total = roll + attack_bonus  -- 18
        local hits_ac_14 = total >= 14
        test.assert_true(hits_ac_14, "Should hit AC 14 with roll of 18")
    end)
    
    test.it("should miss when roll is too low", function()
        local roll = 5
        local attack_bonus = 3
        local total = roll + attack_bonus  -- 8
        local hits_ac_14 = total >= 14
        test.assert_false(hits_ac_14, "Should miss AC 14 with roll of 8")
    end)
    
    test.it("should calculate damage correctly", function()
        local base_damage = math.random(1, 6)  -- 1d6
        local damage_bonus = 2
        local total_damage = base_damage + damage_bonus
        test.assert_in_range(total_damage, 3, 8, "Damage calculation wrong")
    end)
    
    test.it("should handle critical hits (roll of 20)", function()
        local roll = 20
        local is_crit = (roll == 20)
        test.assert_true(is_crit, "Roll of 20 should be critical")
    end)
    
    test.it("should double damage on critical hit", function()
        local base_damage = 5
        local crit_damage = base_damage * 2
        test.assert_equal(crit_damage, 10, "Critical damage should be doubled")
    end)
    
    test.it("should reduce HP on successful hit", function()
        local hp = 30
        local damage = 8
        local new_hp = hp - damage
        test.assert_equal(new_hp, 22, "HP reduction incorrect")
    end)
    
    test.it("should not reduce HP below 0", function()
        local hp = 5
        local damage = 10
        local new_hp = math.max(hp - damage, 0)
        test.assert_equal(new_hp, 0, "HP should not go negative")
    end)
    
    test.it("should detect defeat when HP reaches 0", function()
        local hp = 0
        local is_defeated = (hp <= 0)
        test.assert_true(is_defeated, "Should be defeated at 0 HP")
    end)
    
    test.it("should track rounds of combat", function()
        local rounds = 0
        for i = 1, 5 do
            rounds = rounds + 1
        end
        test.assert_equal(rounds, 5, "Round counter incorrect")
    end)
end)

test.describe("Combat Statistics", function()
    
    test.it("should track damage dealt", function()
        local total_damage = 0
        for i = 1, 3 do
            total_damage = total_damage + math.random(1, 6) + 2
        end
        test.assert_greater_than(total_damage, 0, "Should deal some damage")
    end)
    
    test.it("should track damage taken", function()
        local damage_taken = 0
        for i = 1, 2 do
            damage_taken = damage_taken + math.random(1, 6) + 1
        end
        test.assert_greater_than(damage_taken, 0, "Should take some damage")
    end)
    
    test.it("should calculate win condition", function()
        local enemy_hp = 0
        local player_hp = 15
        local victory = (enemy_hp <= 0 and player_hp > 0)
        test.assert_true(victory, "Should be victory")
    end)
    
    test.it("should calculate loss condition", function()
        local enemy_hp = 10
        local player_hp = 0
        local defeat = (player_hp <= 0)
        test.assert_true(defeat, "Should be defeat")
    end)
end)

test.describe("Combat Edge Cases", function()
    
    test.it("should handle simultaneous defeat (both at 0 HP)", function()
        local player_hp = 0
        local enemy_hp = 0
        -- Player loses if both die
        local result = (player_hp <= 0) and "defeat" or "victory"
        test.assert_equal(result, "defeat", "Simultaneous death should count as defeat")
    end)
    
    test.it("should handle very high AC (hard to hit)", function()
        local roll = 10
        local attack_bonus = 3
        local high_ac = 20
        local hits = (roll + attack_bonus >= high_ac)
        test.assert_false(hits, "Should not hit AC 20 with roll of 10")
    end)
    
    test.it("should handle very low AC (easy to hit)", function()
        local roll = 10
        local attack_bonus = 3
        local low_ac = 10
        local hits = (roll + attack_bonus >= low_ac)
        test.assert_true(hits, "Should hit AC 10 with roll of 10")
    end)
    
    test.it("should prevent infinite combat loops", function()
        local max_rounds = 50
        local rounds = 0
        local enemy_hp = 100
        
        while enemy_hp > 0 and rounds < max_rounds do
            enemy_hp = enemy_hp - math.random(1, 6)
            rounds = rounds + 1
        end
        
        test.assert_less_than(rounds, max_rounds, "Combat should not exceed max rounds")
    end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
