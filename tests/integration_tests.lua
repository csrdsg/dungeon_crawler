#!/usr/bin/env lua
-- integration_tests.lua - Integration tests for dungeon crawler systems
package.path = package.path .. ";../src/?.lua"

local test = require('test_framework')
local dice = require('dice')
local stats_db = require('stats_db')

print("╔══════════════════════════════════════════════════════════════════════╗")
print("║                       INTEGRATION TESTS                              ║")
print("╚══════════════════════════════════════════════════════════════════════╝")

-- Test data
local test_character = {
    name = "Integration Test Hero",
    class = "Fighter",
    level = 1,
    hp = 30,
    max_hp = 30,
    ac = 14,
    atk = 3,
    dmg = 2,
    potions = 3,
    gold = 0,
    str = 12, dex = 10, con = 12, int = 10, wis = 10, cha = 10
}

test.describe("Combat + Dice Integration", function()
    
    test.it("should simulate complete combat encounter", function()
        local char_hp = 30
        local enemy_hp = 15
        local rounds = 0
        
        while enemy_hp > 0 and char_hp > 0 and rounds < 20 do
            rounds = rounds + 1
            
            -- Player attacks
            local attack_roll = dice.roll("d20")
            if attack_roll >= 12 then  -- Enemy AC 12
                local damage = dice.roll("d6+2")
                enemy_hp = enemy_hp - damage
            end
            
            -- Enemy attacks if alive
            if enemy_hp > 0 then
                attack_roll = dice.roll("d20")
                if attack_roll >= 14 then  -- Player AC 14
                    local damage = dice.roll("d6+1")
                    char_hp = char_hp - damage
                end
            end
        end
        
        test.assert_greater_than(rounds, 0, "Combat should take at least 1 round")
        test.assert_less_than(rounds, 20, "Combat should not infinite loop")
        test.assert_true(enemy_hp <= 0 or char_hp <= 0, "Someone should be defeated")
    end)
    
    test.it("should handle critical hits in combat", function()
        local damage_normal = dice.roll("d6+2")
        local damage_crit = dice.roll("d6+2") * 2
        
        test.assert_greater_than(damage_crit, damage_normal, "Crit should do more damage")
    end)
    
end)

test.describe("Inventory + Combat Integration", function()
    
    test.it("should use potion during low HP", function()
        local hp = 8
        local max_hp = 30
        local potions = 3
        
        -- Use potion when HP < 30%
        if hp < max_hp * 0.3 and potions > 0 then
            local healing = dice.roll("2d4")
            hp = math.min(hp + healing, max_hp)
            potions = potions - 1
        end
        
        test.assert_greater_than(hp, 8, "HP should increase")
        test.assert_equal(potions, 2, "Potion count should decrease")
    end)
    
    test.it("should track weight and capacity", function()
        local str = 12
        local capacity = str * 5  -- 60 lbs
        
        local items = {
            {name = "Sword", weight = 5},
            {name = "Shield", weight = 10},
            {name = "Armor", weight = 20},
            {name = "Potion", weight = 0.5}
        }
        
        local total_weight = 0
        for _, item in ipairs(items) do
            total_weight = total_weight + item.weight
        end
        
        test.assert_equal(total_weight, 35.5)
        test.assert_true(total_weight < capacity, "Should be under capacity")
    end)
    
end)

test.describe("Complete Playthrough Integration", function()
    
    test.it("should complete a mini dungeon run", function()
        local char = {
            hp = 30,
            max_hp = 30,
            ac = 14,
            atk = 3,
            dmg = 2,
            potions = 2,
            gold = 0,
            xp = 0
        }
        
        local chambers_cleared = 0
        local enemies_defeated = 0
        
        -- Simulate 5 chambers
        for chamber = 1, 5 do
            -- 60% chance of enemy
            if math.random(100) <= 60 then
                local enemy_hp = 10 + math.random(1, 10)
                local rounds = 0
                
                while enemy_hp > 0 and char.hp > 0 and rounds < 50 do
                    rounds = rounds + 1
                    
                    -- Combat simulation
                    if dice.roll("d20") + char.atk >= 12 then
                        enemy_hp = enemy_hp - dice.roll("d6+2")
                    end
                    
                    if enemy_hp > 0 and dice.roll("d20") + 2 >= char.ac then
                        char.hp = char.hp - dice.roll("d6+1")
                    end
                end
                
                if enemy_hp <= 0 then
                    enemies_defeated = enemies_defeated + 1
                    char.gold = char.gold + math.random(5, 20)
                    char.xp = char.xp + 75
                end
                
                if char.hp <= 0 then
                    break
                end
            end
            
            chambers_cleared = chambers_cleared + 1
            
            -- Rest if low HP
            if char.hp < char.max_hp * 0.5 then
                char.hp = math.min(char.hp + dice.roll("d6+1"), char.max_hp)
            end
            
            -- Use potion if very low
            if char.hp < char.max_hp * 0.3 and char.potions > 0 then
                char.hp = math.min(char.hp + dice.roll("2d4"), char.max_hp)
                char.potions = char.potions - 1
            end
        end
        
        test.assert_greater_than(chambers_cleared, 0, "Should clear at least 1 chamber")
        test.assert_greater_than(char.gold, 0, "Should earn some gold")
        test.assert_greater_than(char.xp, 0, "Should earn some XP")
    end)
    
end)

test.describe("Database + Combat Integration", function()
    
    test.it("should track full playthrough in database", function()
        -- Start playthrough
        local playthrough_id = stats_db.start_playthrough("IntegrationTest", "Fighter", "normal")
        test.assert_not_nil(playthrough_id)
        
        -- Record initial stats
        stats_db.record_stats(playthrough_id, test_character)
        
        -- Simulate combat
        stats_db.record_combat(playthrough_id, 1, "Goblin", 10, 3, 18, 5, "victory", 1)
        stats_db.record_combat(playthrough_id, 2, "Skeleton", 18, 5, 25, 8, "victory", 0)
        
        -- Record chamber events
        stats_db.record_chamber(playthrough_id, 1, "monster_lair", "combat", true, 30, 25, "15gp")
        stats_db.record_chamber(playthrough_id, 2, "treasure", "exploration", true, 25, 25, "50gp")
        
        -- End playthrough
        local final_char = {level = 1, hp = 22, max_hp = 30}
        local game_stats = {
            chambers = 2,
            enemies = 2,
            gold = 65,
            xp = 150,
            potions_used = 0,
            traps = 0,
            deaths = 0,
            score = 365
        }
        
        stats_db.end_playthrough(playthrough_id, "victory", final_char, game_stats)
        
        -- Verify data was recorded
        local rate, wins, total = stats_db.get_win_rate("Fighter")
        test.assert_type(rate, "number")
    end)
    
end)

test.describe("Multi-System Scenario: Boss Fight", function()
    
    test.it("should survive boss encounter with all systems", function()
        local char = {
            hp = 30,
            max_hp = 30,
            ac = 14,
            atk = 3,
            dmg = 2,
            potions = 3,
            gold = 100
        }
        
        local boss = {
            hp = 40,
            ac = 13,
            atk = 4,
            dmg = 3
        }
        
        local rounds = 0
        local potions_used = 0
        local critical_hits = 0
        
        while boss.hp > 0 and char.hp > 0 and rounds < 50 do
            rounds = rounds + 1
            
            -- Player turn
            local attack = dice.roll("d20")
            if attack == 20 then
                critical_hits = critical_hits + 1
                boss.hp = boss.hp - (dice.roll("d6") + char.dmg) * 2
            elseif attack + char.atk >= boss.ac then
                boss.hp = boss.hp - (dice.roll("d6") + char.dmg)
            end
            
            if boss.hp <= 0 then break end
            
            -- Boss turn
            attack = dice.roll("d20")
            if attack + boss.atk >= char.ac then
                char.hp = char.hp - (dice.roll("d6") + boss.dmg)
            end
            
            -- Emergency potion use
            if char.hp < 10 and char.potions > 0 then
                char.hp = math.min(char.hp + dice.roll("2d4"), char.max_hp)
                char.potions = char.potions - 1
                potions_used = potions_used + 1
            end
        end
        
        test.assert_less_than(rounds, 50, "Fight should not timeout")
        test.assert_true(boss.hp <= 0 or char.hp <= 0, "Fight should have winner")
        
        if boss.hp <= 0 then
            -- Victory rewards
            local loot_gold = dice.roll("10d10")
            char.gold = char.gold + loot_gold
            test.assert_greater_than(char.gold, 100, "Should gain loot")
        end
    end)
    
end)

test.describe("Persistence Integration", function()
    
    test.it("should save and restore character state", function()
        local original = {
            name = "TestChar",
            hp = 25,
            max_hp = 30,
            gold = 150,
            xp = 275
        }
        
        -- Simulate save
        local saved_data = string.format("%s|%d|%d|%d|%d", 
            original.name, original.hp, original.max_hp, original.gold, original.xp)
        
        -- Simulate load
        local name, hp, max_hp, gold, xp = saved_data:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)")
        
        test.assert_equal(name, "TestChar")
        test.assert_equal(tonumber(hp), 25)
        test.assert_equal(tonumber(max_hp), 30)
        test.assert_equal(tonumber(gold), 150)
        test.assert_equal(tonumber(xp), 275)
    end)
    
end)

test.describe("Edge Case Integration", function()
    
    test.it("should handle simultaneous death scenario", function()
        local char_hp = 5
        local enemy_hp = 5
        
        -- Both deal lethal damage
        char_hp = char_hp - 10
        enemy_hp = enemy_hp - 10
        
        test.assert_true(char_hp <= 0 and enemy_hp <= 0, "Both should be defeated")
        
        -- Player loses on tie
        local result = (char_hp <= 0) and "defeat" or "victory"
        test.assert_equal(result, "defeat")
    end)
    
    test.it("should prevent HP overflow", function()
        local hp = 28
        local max_hp = 30
        local healing = dice.roll("2d4")  -- Could be 2-8
        
        hp = math.min(hp + healing, max_hp)
        
        test.assert_true(hp <= max_hp, "HP should not exceed maximum")
    end)
    
    test.it("should handle zero gold transactions", function()
        local gold = 50
        local item_cost = 60
        
        local can_buy = gold >= item_cost
        test.assert_false(can_buy, "Cannot buy item without enough gold")
        
        if can_buy then
            gold = gold - item_cost
        end
        
        test.assert_equal(gold, 50, "Gold should be unchanged")
    end)
    
end)

local success = test.summary()

print("\n" .. string.rep("═", 70))
print("💡 Integration Test Tips:")
print("   - These tests verify multiple systems working together")
print("   - They simulate real gameplay scenarios")
print("   - Slower than unit tests but catch cross-system bugs")
print(string.rep("═", 70))

os.exit(success and 0 or 1)
