#!/usr/bin/env lua
-- Game Server - Enhanced with persistent connections and session management

local ServerCore = require("src.server_core")

-- Parse command-line arguments
local ai_mode = nil
local ai_model = nil

for i = 1, #arg do
    if arg[i] == "--ai-mode" and arg[i+1] then
        ai_mode = arg[i+1]
    elseif arg[i] == "--ai-model" and arg[i+1] then
        ai_model = arg[i+1]
    elseif arg[i] == "--help" or arg[i] == "-h" then
        print("Usage: lua game_server.lua [OPTIONS]")
        print("Options:")
        print("  --ai-mode <ollama|openai>  Enable AI storyteller with specified provider")
        print("  --ai-model <model>         Specify AI model (e.g., llama3.2:3b, gpt-4)")
        print("  --help, -h                 Show this help message")
        os.exit(0)
    end
end

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
local QuestSystem = require("src.quest_system")
local InitialQuests = require("src.initial_quests")
local QuestHandler = require("src.quest_handler")

-- Load AI Storyteller if requested
local ai_storyteller = nil
if ai_mode then
    ai_storyteller = require("src.ai_storyteller")
    local ai_config = require("src.ai_config")
    
    -- Override config with command-line args
    ai_config.enabled = true
    ai_config.provider = ai_mode
    
    if ai_mode == "ollama" then
        if ai_model then
            ai_config.ollama.model = ai_model
        end
        ai_config.model = ai_config.ollama.model
        ai_config.endpoint = ai_config.ollama.endpoint
    elseif ai_mode == "openai" then
        if ai_model then
            ai_config.openai.model = ai_model
        end
        ai_config.model = ai_config.openai.model
        ai_config.endpoint = ai_config.openai.endpoint
        ai_config.api_key = ai_config.openai.api_key
    end
    
    -- Initialize AI
    local ai_enabled = ai_storyteller.init(ai_config)
    if not ai_enabled then
        print("⚠️  AI mode requested but initialization failed, continuing without AI")
        ai_storyteller = nil
    end
end

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

-- Save player state
local function save_player_state(player, filename)
    local f = io.open(filename, "w")
    f:write("PLAYER_SAVE_V1\n")
    f:write("name=" .. player.name .. "\n")
    f:write("hp=" .. player.hp .. "\n")
    f:write("max_hp=" .. player.max_hp .. "\n")
    f:write("ac=" .. player.ac .. "\n")
    f:write("attack_bonus=" .. player.attack_bonus .. "\n")
    f:write("damage=" .. player.damage .. "\n")
    f:write("gold=" .. player.gold .. "\n")
    f:write("potions=" .. player.potions .. "\n")
    f:write("items=" .. table.concat(player.items, ":") .. "\n")
    f:write("vault_found=" .. tostring(player.vault_found or false) .. "\n")
    f:write("vault_unlocked=" .. tostring(player.vault_unlocked or false) .. "\n")
    f:close()
end

-- Save quest log
local function save_quest_log(quest_log, filename)
    local f = io.open(filename, "w")
    local serialized = QuestSystem.serialize(quest_log)
    f:write(serialized)
    f:close()
end

-- Load quest log
local function load_quest_log(filename)
    local f = io.open(filename, "r")
    if not f then return nil end
    
    local data = f:read("*a")
    f:close()
    
    if data and data ~= "" then
        return QuestSystem.deserialize(data)
    end
    
    return nil
end

-- Load player state
local function load_player_state(filename)
    local f = io.open(filename, "r")
    if not f then return nil end
    
    local player = {}
    local line = f:read("*l")
    if not line or line ~= "PLAYER_SAVE_V1" then
        f:close()
        return nil
    end
    
    for line in f:lines() do
        local key, value = line:match("([^=]+)=(.*)")
        if key == "name" then
            player.name = value
        elseif key == "hp" then
            player.hp = tonumber(value)
        elseif key == "max_hp" then
            player.max_hp = tonumber(value)
        elseif key == "ac" then
            player.ac = tonumber(value)
        elseif key == "attack_bonus" then
            player.attack_bonus = tonumber(value)
        elseif key == "damage" then
            player.damage = value
        elseif key == "gold" then
            player.gold = tonumber(value)
        elseif key == "potions" then
            player.potions = tonumber(value)
        elseif key == "items" then
            player.items = {}
            if value ~= "" then
                for item in value:gmatch("[^:]+") do
                    table.insert(player.items, item)
                end
            end
        elseif key == "vault_found" then
            player.vault_found = (value == "true")
        elseif key == "vault_unlocked" then
            player.vault_unlocked = (value == "true")
        end
    end
    
    f:close()
    return player
end

-- Save complete game state
local function save_game_state(session)
    -- Copy vault flags to player for saving
    session.player.vault_found = session.vault_found
    session.player.vault_unlocked = session.vault_unlocked
    
    save_dungeon(session.dungeon, "bimbo_quest.txt")
    save_player_state(session.player, "bimbo_player.txt")
    save_quest_log(session.quest_log, "bimbo_quests.txt")
end

-- Initialize session with game state
local function init_session(session_id)
    local dungeon = load_dungeon("bimbo_quest.txt")
    if not dungeon then
        print("⚠️  Warning: Could not load save file for session " .. session_id)
        return false
    end
    
    -- Load player state from file or create default
    local player = load_player_state("bimbo_player.txt")
    if not player then
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
        }
    end
    
    -- Load quest log from file or create default
    local quest_log = load_quest_log("bimbo_quests.txt")
    if not quest_log then
        quest_log = InitialQuests.init_quest_log()
    end
    
    game_sessions[session_id] = {
        player = player,
        dungeon = dungeon,
        quest_log = quest_log,
        vault_found = player.vault_found or false,
        vault_unlocked = player.vault_unlocked or false,
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
    
    -- Always save to main file after each command for persistence
    save_game_state(session)
    session.last_save = os.time()
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
        
        -- Show active quests count
        if session.quest_log then
            local count = QuestSystem.count_quests(session.quest_log)
            table.insert(response, string.format("\n🎯 Quests: %d active, %d completed", count.active, count.completed))
        end
        
    elseif cmd == "quests" or cmd == "quest" then
        if not session.quest_log then
            table.insert(response, "❌ Quest log not available")
        else
            local count = QuestSystem.count_quests(session.quest_log)
            table.insert(response, "📜 QUEST LOG")
            table.insert(response, string.rep("═", 50))
            
            -- Active quests
            local active = QuestSystem.get_active_quests(session.quest_log)
            if #active > 0 then
                table.insert(response, "\n🎯 ACTIVE QUESTS:")
                for _, quest in ipairs(active) do
                    table.insert(response, QuestSystem.format_quest(quest, true))
                    table.insert(response, "")
                end
            else
                table.insert(response, "\n🎯 No active quests")
            end
            
            -- Completed quests
            local completed = QuestSystem.get_completed_quests(session.quest_log)
            if #completed > 0 then
                table.insert(response, "\n✅ COMPLETED QUESTS:")
                for _, quest in ipairs(completed) do
                    table.insert(response, QuestSystem.format_quest(quest, false))
                end
            end
            
            table.insert(response, string.rep("═", 50))
            table.insert(response, string.format("Total: %d active, %d completed, %d failed", 
                count.active, count.completed, count.failed))
        end
        
    elseif cmd == "map" then
        table.insert(response, "🗺️  DUNGEON MAP:")
        for i = 1, dungeon.num_chambers do
            local c = dungeon.chambers[i]
            local mark = c.visited and "✓" or "?"
            local current_mark = (i == dungeon.player_position) and " ← YOU ARE HERE" or ""
            table.insert(response, string.format("Chamber %d: %s %s%s", i, chamber_types[c.type], mark, current_mark))
        end
        
    elseif cmd == "save" then
        save_game_state(session)
        session.last_save = os.time()
        table.insert(response, "💾 Game saved!")
        
    elseif cmd == "search" then
        table.insert(response, "🔍 Searching the room...")
        local search_roll = roll("1d20") + 3
        table.insert(response, string.format("   Search roll: %d", search_roll))
        
        -- Check for quest-related discoveries
        local discoveries, special = QuestHandler.check_discoveries(session, dungeon.player_position, search_roll)
        for _, msg in ipairs(discoveries) do
            table.insert(response, msg)
        end
        
        -- If no special discovery, do normal loot
        if not special and search_roll >= 15 then
            local find_type = math.random(1, 4)
            if find_type == 1 then
                local gold_found = roll("2d10")
                player.gold = player.gold + gold_found
                table.insert(response, string.format("💰 Found %d gold pieces!", gold_found))
                
                -- Trigger quest check
                local quest_notifications = QuestHandler.check_quest_completion(session, "gold_gained")
                for _, msg in ipairs(quest_notifications) do
                    table.insert(response, msg)
                end
            elseif find_type == 2 then
                player.potions = player.potions + 1
                table.insert(response, "🧪 Found a healing potion!")
            elseif find_type == 3 then
                local items = {"Ancient Coin", "Map Fragment", "Strange Gem", "Rusty Key"}
                local item = items[math.random(#items)]
                table.insert(player.items, item)
                table.insert(response, string.format("✨ Found: %s", item))
                
                -- Trigger quest check
                local quest_notifications = QuestHandler.check_quest_completion(session, "item_gained")
                for _, msg in ipairs(quest_notifications) do
                    table.insert(response, msg)
                end
            else
                table.insert(response, "📜 Found a clue about nearby chambers:")
                for _, conn in ipairs(current.connections) do
                    table.insert(response, string.format("   Chamber %d is a %s", conn, chamber_types[dungeon.chambers[conn].type]))
                end
            end
        elseif not special and search_roll >= 10 then
            table.insert(response, "🔎 Nothing special found, but the room seems clear of traps.")
        elseif not special then
            table.insert(response, "❌ You find nothing of interest.")
        end
    
    elseif cmd == "unlock vault" or cmd == "unlock" then
        if dungeon.player_position ~= 8 then
            table.insert(response, "❌ There's no vault here.")
        elseif not session.vault_found then
            table.insert(response, "❌ You haven't found the vault yet. Try searching!")
        elseif session.vault_unlocked then
            table.insert(response, "🔓 The vault is already open (empty).")
        else
            -- Check if player has Silver Key
            local has_key = false
            for _, item in ipairs(player.items) do
                if item == "Silver Key" then
                    has_key = true
                    break
                end
            end
            
            if not has_key then
                table.insert(response, "❌ You need the Silver Key to unlock this vault!")
            else
                -- Unlock vault!
                session.vault_unlocked = true
                table.insert(response, "")
                table.insert(response, "🔓 *** VAULT UNLOCKED! ***")
                table.insert(response, "The ancient lock clicks open...")
                table.insert(response, "")
                
                -- Vault rewards
                local vault_gold = 50
                player.gold = player.gold + vault_gold
                table.insert(player.items, "Ancient Tome")
                table.insert(player.items, "Mystic Amulet")
                
                table.insert(response, "💰 Found " .. vault_gold .. " gold pieces!")
                table.insert(response, "📖 Found: Ancient Tome")
                table.insert(response, "✨ Found: Mystic Amulet")
                
                -- Trigger quest completion
                local quest_notifications = QuestHandler.check_quest_completion(session, "vault_unlocked")
                for _, msg in ipairs(quest_notifications) do
                    table.insert(response, msg)
                end
            end
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
            
            -- AI narration for chamber entry
            if ai_storyteller then
                local chamber_data = {
                    type = chamber_types[current.type],
                    exits = table.concat(current.connections, ", "),
                    items = "unknown",
                    enemies = "unknown"
                }
                local narration = ai_storyteller.narrate_chamber(chamber_data, {})
                if narration then
                    table.insert(response, "")
                    table.insert(response, "📖 " .. narration)
                end
            end
            
            -- Trigger quest check for exploration
            local quest_notifications = QuestHandler.check_quest_completion(session, "chamber_entered")
            for _, msg in ipairs(quest_notifications) do
                table.insert(response, msg)
            end
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
        -- Save to main persistent files
        save_game_state(session)
        -- Also save session-specific backup
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
