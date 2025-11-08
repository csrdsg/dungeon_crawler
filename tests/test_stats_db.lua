#!/usr/bin/env lua
-- test_stats_db.lua - Unit tests for stats database module
package.path = package.path .. ";../src/?.lua"

local test = require('test_framework')
local stats = require('stats_db')

-- Use a test database
local test_db = "test_dungeon_stats.db"
stats.set_db_file(test_db)
stats.init_db() -- Initialize schema for the test DB

-- Cleanup before and after
os.execute("rm -f " .. test_db)
stats.init_db()

test.describe("Stats Database Module", function()
    
    test.it("should load stats_db module", function()
        test.assert_not_nil(stats, "Module should load")
    end)
    
    test.it("should have init_db function", function()
        test.assert_type(stats.init_db, "function")
    end)
    
    test.it("should have start_playthrough function", function()
        test.assert_type(stats.start_playthrough, "function")
    end)
    
    test.it("should have end_playthrough function", function()
        test.assert_type(stats.end_playthrough, "function")
    end)
    
    test.it("should have record_combat function", function()
        test.assert_type(stats.record_combat, "function")
    end)
    
    test.it("should have record_chamber function", function()
        test.assert_type(stats.record_chamber, "function")
    end)
    
    test.it("should have record_stats function", function()
        test.assert_type(stats.record_stats, "function")
    end)
    
    test.it("should have get_win_rate function", function()
        test.assert_type(stats.get_win_rate, "function")
    end)
    
    test.it("should have generate_report function", function()
        test.assert_type(stats.generate_report, "function")
    end)
    
    test.it("should have export_csv function", function()
        test.assert_type(stats.export_csv, "function")
    end)
end)

test.describe("Database Operations", function()
    
    test.it("should start a new playthrough and return ID", function()
        local id = stats.start_playthrough("TestChar", "Fighter", "normal")
        test.assert_not_nil(id, "Should return playthrough ID")
        test.assert_type(id, "number", "ID should be a number")
        test.assert_greater_than(id, 0, "ID should be positive")
    end)
    
    test.it("should record character stats", function()
        local id = stats.start_playthrough("TestChar2", "Rogue", "normal")
        local char = {
            level = 1, hp = 30, max_hp = 30, ac = 14,
            atk = 3, dmg = 2, str = 10, dex = 12, con = 10,
            int = 10, wis = 10, cha = 10
        }
        
        -- Should not error
        local ok = pcall(stats.record_stats, id, char)
        test.assert_true(ok, "Should record stats without error")
    end)
    
    test.it("should record combat event", function()
        local id = stats.start_playthrough("TestChar3", "Warrior", "normal")
        
        local ok = pcall(stats.record_combat, id, 1, "Goblin", 10, 3, 15, 5, "victory", 1)
        test.assert_true(ok, "Should record combat without error")
    end)
    
    test.it("should record chamber event", function()
        local id = stats.start_playthrough("TestChar4", "Cleric", "normal")
        
        local ok = pcall(stats.record_chamber, id, 1, "trap_room", "trap", true, 30, 25, "20gp")
        test.assert_true(ok, "Should record chamber without error")
    end)
    
    test.it("should end playthrough with stats", function()
        local id = stats.start_playthrough("TestChar5", "Wizard", "normal")
        local char = {level = 1, hp = 20, max_hp = 30}
        local game_stats = {
            chambers = 5, enemies = 3, gold = 50,
            xp = 150, potions_used = 1, traps = 0,
            deaths = 0, score = 500
        }
        
        local ok = pcall(stats.end_playthrough, id, "victory", char, game_stats)
        test.assert_true(ok, "Should end playthrough without error")
    end)
    
    test.it("should get win rate", function()
        local rate, wins, total = stats.get_win_rate()
        test.assert_type(rate, "number", "Win rate should be a number")
        test.assert_in_range(rate, 0, 100, "Win rate should be 0-100%")
    end)
    
    test.it("should get win rate for specific class", function()
        local rate, wins, total = stats.get_win_rate("Fighter")
        test.assert_type(rate, "number")
        test.assert_in_range(rate, 0, 100, "Win rate should be 0-100%")
    end)
end)

test.describe("Data Validation", function()
    
    test.it("should handle empty database gracefully", function()
        local rate, wins, total = stats.get_win_rate("NonexistentClass")
        test.assert_type(rate, "number")
        -- Should return 0 for non-existent class
        test.assert_true(rate >= 0 and rate <= 100, "Win rate should be valid")
    end)
    
    test.it("should track multiple playthroughs independently", function()
        local id1 = stats.start_playthrough("Char1", "Fighter", "normal")
        local id2 = stats.start_playthrough("Char2", "Rogue", "hard")
        
        test.assert_not_nil(id1)
        test.assert_not_nil(id2)
        test.assert_true(id1 ~= id2, "Should have different IDs")
    end)
end)

test.describe("Performance", function()
    
    test.it("should handle batch inserts efficiently", function()
        local start = os.clock()
        
        for i = 1, 10 do
            local id = stats.start_playthrough("BenchChar" .. i, "Fighter", "normal")
            stats.record_combat(id, 1, "Goblin", 10, 3, 15, 5, "victory", 0)
            
            local char = {level = 1, hp = 20, max_hp = 30}
            local game_stats = {chambers = 5, enemies = 3, gold = 50, xp = 150,
                              potions_used = 1, traps = 0, deaths = 0, score = 500}
            stats.end_playthrough(id, "victory", char, game_stats)
        end
        
        local elapsed = os.clock() - start
        test.assert_less_than(elapsed, 2.0, "Batch operations should be fast")
    end)
end)

-- Cleanup
os.execute("rm -f " .. test_db)

local success = test.summary()
os.exit(success and 0 or 1)
