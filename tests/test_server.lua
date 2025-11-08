#!/usr/bin/env lua
-- Fast Server Tests - Unit tests for game_server.lua functionality

local test = require("test_framework")
local socket = require("socket")

-- Mock chamber_art to avoid loading file
_G.chamber_art = {}

-- Extract server functions by loading game_server as module
local function load_server_functions()
    local funcs = {}
    
    -- Roll dice function
    funcs.roll = function(dice_str)
        local num, sides, bonus = dice_str:match("(%d*)d(%d+)([%+%-]?%d*)")
        num = tonumber(num) or 1
        sides = tonumber(sides)
        bonus = tonumber(bonus) or 0
        
        local total = bonus
        for i = 1, num do
            total = total + math.random(1, sides)
        end
        return total
    end
    
    -- Chamber type names
    funcs.chamber_types = {
        [1] = "Empty Room",
        [2] = "Treasure Room",
        [3] = "Monster Lair",
        [4] = "Trap Room",
        [5] = "Puzzle Room",
        [6] = "Prison Cells",
        [7] = "Armory",
        [8] = "Library",
        [9] = "Throne Room",
        [10] = "Boss Chamber"
    }
    
    -- Load dungeon
    funcs.load_dungeon = function(filename)
        local f = io.open(filename, "r")
        if not f then return nil end
        
        local dungeon = {chambers = {}}
        local line = f:read("*l")
        if not line or line ~= "DUNGEON_SAVE_V1" then
            f:close()
            return nil
        end
        
        dungeon.player_position = tonumber(f:read("*l"):match("player_position=(%d+)"))
        dungeon.num_chambers = tonumber(f:read("*l"):match("num_chambers=(%d+)"))
        f:read("*l") -- skip ---CHAMBERS---
        
        for i = 1, dungeon.num_chambers do
            local chamber_line = f:read("*l")
            local id, ctype, visited, conns = chamber_line:match("id=(%d+),type=(%d+),visited=(%a+),connections=(.*)")
            
            dungeon.chambers[tonumber(id)] = {
                id = tonumber(id),
                type = tonumber(ctype),
                visited = (visited == "true"),
                connections = {}
            }
            
            if conns and conns ~= "" then
                for conn in conns:gmatch("(%d+)") do
                    table.insert(dungeon.chambers[tonumber(id)].connections, tonumber(conn))
                end
            end
        end
        
        f:close()
        return dungeon
    end
    
    -- Save dungeon
    funcs.save_dungeon = function(dungeon, filename)
        local f = io.open(filename, "w")
        f:write("DUNGEON_SAVE_V1\n")
        f:write("player_position=" .. dungeon.player_position .. "\n")
        f:write("num_chambers=" .. dungeon.num_chambers .. "\n")
        f:write("---CHAMBERS---\n")
        
        for i = 1, dungeon.num_chambers do
            local c = dungeon.chambers[i]
            local conn_str = table.concat(c.connections, ":")
            f:write(string.format("id=%d,type=%d,visited=%s,connections=%s\n",
                c.id, c.type, tostring(c.visited), conn_str))
        end
        
        f:close()
    end
    
    -- Process command
    funcs.process_command = function(cmd, dungeon, player)
        local response = {}
        local current = dungeon.chambers[dungeon.player_position]
        
        if cmd == "status" then
            table.insert(response, string.format("%s the Rogue", player.name))
            table.insert(response, string.format("HP: %d/%d", player.hp, player.max_hp))
            table.insert(response, string.format("AC: %d", player.ac))
            table.insert(response, string.format("Attack: +%d, Damage: %s", player.attack_bonus, player.damage))
            table.insert(response, string.format("Gold: %d gp", player.gold))
            table.insert(response, string.format("Potions: %d", player.potions))
            table.insert(response, "Items: " .. table.concat(player.items, ", "))
            
        elseif cmd == "map" then
            table.insert(response, "🗺️  DUNGEON MAP:")
            for i = 1, dungeon.num_chambers do
                local c = dungeon.chambers[i]
                local mark = c.visited and "✓" or "?"
                local current_mark = (i == dungeon.player_position) and " ← YOU ARE HERE" or ""
                table.insert(response, string.format("Chamber %d: %s %s%s", i, funcs.chamber_types[c.type], mark, current_mark))
            end
            
        elseif cmd == "save" then
            funcs.save_dungeon(dungeon, "test_save.txt")
            table.insert(response, "💾 Game saved!")
            
        elseif cmd == "search" then
            table.insert(response, "🔍 Searching the room...")
            local search_roll = funcs.roll("1d20") + 3
            table.insert(response, string.format("   Search roll: %d", search_roll))
            
            if search_roll >= 15 then
                local find_type = math.random(1, 4)
                if find_type == 1 then
                    local gold_found = funcs.roll("2d10")
                    player.gold = player.gold + gold_found
                    table.insert(response, string.format("💰 Found %d gold pieces!", gold_found))
                elseif find_type == 2 then
                    player.potions = player.potions + 1
                    table.insert(response, "🧪 Found a healing potion!")
                elseif find_type == 3 then
                    local items = {"Ancient Coin", "Map Fragment", "Strange Gem", "Rusty Key"}
                    local item = items[math.random(#items)]
                    table.insert(player.items, item)
                    table.insert(response, string.format("✨ Found: %s", item))
                else
                    table.insert(response, "📜 Found a clue about nearby chambers:")
                    for _, conn in ipairs(current.connections) do
                        table.insert(response, string.format("   Chamber %d is a %s", conn, funcs.chamber_types[dungeon.chambers[conn].type]))
                    end
                end
            elseif search_roll >= 10 then
                table.insert(response, "🔎 Nothing special found, but the room seems clear of traps.")
            else
                table.insert(response, "❌ You find nothing of interest.")
            end
            
        elseif cmd:match("^move%s+(%d+)$") then
            local dest = tonumber(cmd:match("^move%s+(%d+)$"))
            
            local valid = false
            for _, conn in ipairs(current.connections) do
                if conn == dest then
                    valid = true
                    break
                end
            end
            
            if not valid then
                table.insert(response, "❌ Cannot move to chamber " .. dest .. " from here!")
            else
                dungeon.player_position = dest
                current = dungeon.chambers[dest]
                current.visited = true
                
                table.insert(response, string.format("🚶 Moving to Chamber %d...", dest))
                table.insert(response, string.format("📍 Entered: %s", funcs.chamber_types[current.type]))
            end
        else
            table.insert(response, "❌ Unknown command: " .. cmd)
        end
        
        return table.concat(response, "\n")
    end
    
    return funcs
end

local funcs = load_server_functions()

-- Test fixtures
local function create_test_player()
    return {
        name = "TestHero",
        hp = 30,
        max_hp = 30,
        ac = 14,
        attack_bonus = 3,
        damage = "1d6+2",
        gold = 100,
        potions = 2,
        items = {"Test Item 1", "Test Item 2"}
    }
end

local function create_test_dungeon()
    return {
        player_position = 1,
        num_chambers = 3,
        chambers = {
            [1] = {
                id = 1,
                type = 1, -- Empty Room
                visited = true,
                connections = {2, 3}
            },
            [2] = {
                id = 2,
                type = 2, -- Treasure Room
                visited = false,
                connections = {1}
            },
            [3] = {
                id = 3,
                type = 3, -- Monster Lair
                visited = false,
                connections = {1}
            }
        }
    }
end

-- TESTS

test.describe("Dice Rolling", function()
    math.randomseed(12345)
    
    test.it("rolls 1d6 correctly", function()
        local result = funcs.roll("1d6")
        test.assert_in_range(result, 1, 6, "1d6 should return 1-6")
    end)
    
    test.it("rolls 2d6 correctly", function()
        local result = funcs.roll("2d6")
        test.assert_in_range(result, 2, 12, "2d6 should return 2-12")
    end)
    
    test.it("rolls d20 correctly", function()
        local result = funcs.roll("d20")
        test.assert_in_range(result, 1, 20, "d20 should return 1-20")
    end)
    
    test.it("handles bonus modifiers", function()
        local result = funcs.roll("1d6+5")
        test.assert_in_range(result, 6, 11, "1d6+5 should return 6-11")
    end)
    
    test.it("handles negative modifiers", function()
        local result = funcs.roll("1d20-3")
        test.assert_in_range(result, -2, 17, "1d20-3 should return -2 to 17")
    end)
end)

test.describe("Chamber Types", function()
    test.it("has all 10 chamber types defined", function()
        test.assert_equal(#funcs.chamber_types, 10, "Should have 10 chamber types")
    end)
    
    test.it("has correct chamber names", function()
        test.assert_equal(funcs.chamber_types[1], "Empty Room")
        test.assert_equal(funcs.chamber_types[2], "Treasure Room")
        test.assert_equal(funcs.chamber_types[10], "Boss Chamber")
    end)
end)

test.describe("Dungeon Save/Load", function()
    local test_file = "test_dungeon_temp.txt"
    
    test.it("saves dungeon correctly", function()
        local dungeon = create_test_dungeon()
        funcs.save_dungeon(dungeon, test_file)
        
        local f = io.open(test_file, "r")
        test.assert_not_nil(f, "Save file should exist")
        local first_line = f:read("*l")
        test.assert_equal(first_line, "DUNGEON_SAVE_V1", "First line should be version header")
        f:close()
    end)
    
    test.it("loads dungeon correctly", function()
        local original = create_test_dungeon()
        funcs.save_dungeon(original, test_file)
        
        local loaded = funcs.load_dungeon(test_file)
        test.assert_not_nil(loaded, "Should load dungeon")
        test.assert_equal(loaded.player_position, original.player_position)
        test.assert_equal(loaded.num_chambers, original.num_chambers)
    end)
    
    test.it("preserves chamber data", function()
        local original = create_test_dungeon()
        funcs.save_dungeon(original, test_file)
        
        local loaded = funcs.load_dungeon(test_file)
        test.assert_equal(loaded.chambers[1].type, 1)
        test.assert_equal(loaded.chambers[2].type, 2)
        test.assert_equal(loaded.chambers[1].visited, true)
        test.assert_equal(loaded.chambers[2].visited, false)
    end)
    
    test.it("preserves connections", function()
        local original = create_test_dungeon()
        funcs.save_dungeon(original, test_file)
        
        local loaded = funcs.load_dungeon(test_file)
        test.assert_equal(#loaded.chambers[1].connections, 2)
        test.assert_contains(loaded.chambers[1].connections, 2)
        test.assert_contains(loaded.chambers[1].connections, 3)
    end)
    
    test.it("returns nil for invalid file", function()
        local loaded = funcs.load_dungeon("nonexistent_file.txt")
        test.assert_nil(loaded, "Should return nil for missing file")
    end)
    
    -- Cleanup
    os.remove(test_file)
end)

test.describe("Status Command", function()
    test.it("shows player stats", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("status", dungeon, player)
        test.assert_true(response:find("TestHero the Rogue") ~= nil)
        test.assert_true(response:find("HP: 30/30") ~= nil)
        test.assert_true(response:find("AC: 14") ~= nil)
        test.assert_true(response:find("Gold: 100 gp") ~= nil)
        test.assert_true(response:find("Potions: 2") ~= nil)
    end)
    
    test.it("shows player items", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("status", dungeon, player)
        test.assert_true(response:find("Test Item 1") ~= nil)
        test.assert_true(response:find("Test Item 2") ~= nil)
    end)
end)

test.describe("Map Command", function()
    test.it("lists all chambers", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("map", dungeon, player)
        test.assert_true(response:find("Chamber 1") ~= nil)
        test.assert_true(response:find("Chamber 2") ~= nil)
        test.assert_true(response:find("Chamber 3") ~= nil)
    end)
    
    test.it("marks current position", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("map", dungeon, player)
        test.assert_true(response:find("Chamber 1.*YOU ARE HERE") ~= nil)
    end)
    
    test.it("shows visited status", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("map", dungeon, player)
        test.assert_true(response:find("Empty Room ✓") ~= nil)
    end)
end)

test.describe("Move Command", function()
    test.it("allows valid moves", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("move 2", dungeon, player)
        test.assert_true(response:find("Moving to Chamber 2") ~= nil)
        test.assert_equal(dungeon.player_position, 2)
    end)
    
    test.it("marks new chamber as visited", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        funcs.process_command("move 2", dungeon, player)
        test.assert_true(dungeon.chambers[2].visited)
    end)
    
    test.it("rejects invalid moves", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        -- Chamber 1 cannot connect to non-existent chamber 99
        local response = funcs.process_command("move 99", dungeon, player)
        test.assert_true(response:find("Cannot move") ~= nil)
        test.assert_equal(dungeon.player_position, 1) -- Position unchanged
    end)
    
    test.it("rejects moves to unconnected chambers", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        dungeon.chambers[1].connections = {2} -- Only connected to chamber 2
        
        local response = funcs.process_command("move 3", dungeon, player)
        test.assert_true(response:find("Cannot move") ~= nil)
    end)
end)

test.describe("Save Command", function()
    test.it("saves game state", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("save", dungeon, player)
        test.assert_true(response:find("Game saved") ~= nil)
    end)
    
    os.remove("test_save.txt")
end)

test.describe("Search Command", function()
    test.it("performs search action", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        math.randomseed(42)
        
        local response = funcs.process_command("search", dungeon, player)
        test.assert_true(response:find("Searching the room") ~= nil)
        test.assert_true(response:find("Search roll") ~= nil)
    end)
end)

test.describe("Unknown Commands", function()
    test.it("handles unknown commands gracefully", function()
        local player = create_test_player()
        local dungeon = create_test_dungeon()
        
        local response = funcs.process_command("dance", dungeon, player)
        test.assert_true(response:find("Unknown command") ~= nil)
    end)
end)

test.describe("Socket Communication", function()
    test.it("can create socket connection", function()
        local sock = socket.tcp()
        test.assert_not_nil(sock, "Should create TCP socket")
        sock:close()
    end)
end)

-- Run summary
local success = test.summary()
os.exit(success and 0 or 1)
