#!/usr/bin/env lua
-- Game Server - Enhanced with persistent connections and session management

local ServerCore = require("src.server_core")

-- Server configuration
local HOST = "127.0.0.1"
local PORT = 9999

print("🎮 Dungeon Crawler Server starting on " .. HOST .. ":" .. PORT)

-- Create server instance
local server = ServerCore.new(HOST, PORT)
server.max_clients = 10
server.client_timeout = 600 -- 10 minutes

-- Load game modules
dofile("src/chamber_art.lua")

-- Initialize RNG
math.randomseed(os.time())
for i = 1, 10 do math.random() end

-- Session state storage
local game_sessions = {}

-- Helper: Roll dice
local function roll(dice_str)
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
local chamber_types = {
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
local function load_dungeon(filename)
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
local function save_dungeon(dungeon, filename)
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

-- Initialize session with game state
local function init_session(session_id)
    local dungeon = load_dungeon("bimbo_quest.txt")
    if not dungeon then
        print("⚠️  Warning: Could not load save file for session " .. session_id)
        return false
    end
    
    game_sessions[session_id] = {
        player = {
            name = "Bimbo",
            hp = 30,
            max_hp = 30,
            ac = 14,
            attack_bonus = 3,
            damage = "1d6+2",
            gold = 142,
            potions = 3,
            items = {
                "Silver Key",
                "Scroll of Protection from Constructs"
            }
        },
        dungeon = dungeon,
        last_save = os.time()
    }
    
    return true
end

-- Get session state
local function get_session(session_id)
    return game_sessions[session_id]
end

-- Auto-save session periodically
local function auto_save_session(session_id)
    local session = game_sessions[session_id]
    if not session then return end
    
    if os.time() - session.last_save > 60 then -- Save every minute
        save_dungeon(session.dungeon, "bimbo_quest_" .. session_id .. ".txt")
        session.last_save = os.time()
    end
end

-- Process command and return response
local function process_command(session_id, cmd)
    local session = get_session(session_id)
    if not session then
        return "ERROR: Session not found. Reconnect required."
    end
    
    local dungeon = session.dungeon
    local player = session.player
    local response = {}
    local current = dungeon.chambers[dungeon.player_position]
    
    auto_save_session(session_id)
    
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
            table.insert(response, string.format("Chamber %d: %s %s%s", i, chamber_types[c.type], mark, current_mark))
        end
        
    elseif cmd == "save" then
        save_dungeon(dungeon, "bimbo_quest_" .. session_id .. ".txt")
        session.last_save = os.time()
        table.insert(response, "💾 Game saved!")
        
    elseif cmd == "search" then
        table.insert(response, "🔍 Searching the room...")
        local search_roll = roll("1d20") + 3
        table.insert(response, string.format("   Search roll: %d", search_roll))
        
        if search_roll >= 15 then
            local find_type = math.random(1, 4)
            if find_type == 1 then
                local gold_found = roll("2d10")
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
                    table.insert(response, string.format("   Chamber %d is a %s", conn, chamber_types[dungeon.chambers[conn].type]))
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
            table.insert(response, string.format("📍 Entered: %s", chamber_types[current.type]))
        end
    else
        table.insert(response, "❌ Unknown command: " .. cmd)
    end
    
    return table.concat(response, "\n")
end

-- Event handlers
server:on("on_connect", function(session_id)
    print(string.format("🎮 New game session: %s", session_id))
    if not init_session(session_id) then
        print(string.format("❌ Failed to initialize session: %s", session_id))
    end
end)

server:on("on_disconnect", function(session_id, reason)
    print(string.format("💾 Saving session before disconnect: %s", session_id))
    local session = get_session(session_id)
    if session then
        save_dungeon(session.dungeon, "bimbo_quest_" .. session_id .. ".txt")
        game_sessions[session_id] = nil
    end
end)

server:on("on_message", function(session_id, message)
    print(string.format("📥 [%s] %s", session_id, message))
    local response = process_command(session_id, message)
    print(string.format("📤 [%s] Response sent", session_id))
    return response
end)

server:on_error(function(session_id, error)
    print(string.format("💥 Error in session %s: %s", session_id, tostring(error)))
end)

-- Start server
local success, err = server:start()
if not success then
    print("❌ " .. err)
    os.exit(1)
end

print("🎮 Server ready! Waiting for connections...")
print("📊 Max clients: " .. server.max_clients)
print("⏱️  Client timeout: " .. server.client_timeout .. "s")

-- Graceful shutdown handler
local function shutdown()
    print("\n🛑 Shutting down gracefully...")
    server:stop()
    os.exit(0)
end

-- Run server loop
server:run_loop()
