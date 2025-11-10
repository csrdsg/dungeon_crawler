#!/usr/bin/env lua
-- State Manager CLI Tool
-- Fast command-line interface for character and mission state management

local StateManager = require("src.state_manager")

-- Initialize state directories
StateManager.init()

-- Colors for terminal output
local function color(text, code)
    return string.format("\27[%sm%s\27[0m", code, text)
end

local colors = {
    green = function(t) return color(t, "32") end,
    yellow = function(t) return color(t, "33") end,
    blue = function(t) return color(t, "34") end,
    red = function(t) return color(t, "31") end,
    cyan = function(t) return color(t, "36") end,
    bold = function(t) return color(t, "1") end,
}

-- Print help
local function print_help()
    print(colors.bold("State Manager CLI - Fast Character & Mission State Tracking"))
    print("\nUsage: lua state_manager_cli.lua <command> [options]")
    print("\n" .. colors.cyan("Commands:"))
    print("  " .. colors.green("list") .. "                    List all saved states")
    print("  " .. colors.green("list-characters") .. "         List saved characters")
    print("  " .. colors.green("list-missions") .. "           List saved missions")
    print("  " .. colors.green("list-sessions") .. "           List saved game sessions")
    print("  " .. colors.green("load <session>") .. "          Load a game session")
    print("  " .. colors.green("save <session>") .. "          Save current game (interactive)")
    print("  " .. colors.green("delete <type> <id>") .. "      Delete a character/mission/session")
    print("  " .. colors.green("export <name>") .. "           Export current player as template")
    print("  " .. colors.green("import <template>") .. "       Import character from template")
    print("  " .. colors.green("migrate") .. "                 Migrate old save files to new format")
    print("\n" .. colors.cyan("Examples:"))
    print("  lua state_manager_cli.lua list-sessions")
    print("  lua state_manager_cli.lua load bimbo")
    print("  lua state_manager_cli.lua delete session old_game")
    print("  lua state_manager_cli.lua migrate")
end

-- List all characters
local function list_characters()
    print(colors.bold("\n📋 Saved Characters:"))
    print(string.rep("─", 60))
    
    local chars = StateManager.list_characters()
    if #chars == 0 then
        print(colors.yellow("  No saved characters found"))
    else
        for i, char_id in ipairs(chars) do
            local char = StateManager.load_character(char_id)
            if char then
                print(string.format("  %s. %s%s", 
                    i, 
                    colors.green(char_id),
                    char.template and colors.cyan(" [TEMPLATE]") or ""))
                if char.name then
                    print(string.format("     Name: %s, Level: %s, HP: %s",
                        char.name,
                        char.level or 1,
                        char.max_hp or "?"))
                end
            end
        end
    end
    print(string.rep("─", 60))
end

-- List all missions
local function list_missions()
    print(colors.bold("\n🎯 Saved Missions:"))
    print(string.rep("─", 60))
    
    local missions = StateManager.list_missions()
    if #missions == 0 then
        print(colors.yellow("  No saved missions found"))
    else
        for i, mission_id in ipairs(missions) do
            print(string.format("  %s. %s", i, colors.green(mission_id)))
        end
    end
    print(string.rep("─", 60))
end

-- List all sessions
local function list_sessions()
    print(colors.bold("\n💾 Saved Game Sessions:"))
    print(string.rep("─", 80))
    
    local sessions = StateManager.list_sessions()
    if #sessions == 0 then
        print(colors.yellow("  No saved sessions found"))
    else
        -- Sort by saved_at (most recent first)
        table.sort(sessions, function(a, b) return a.saved_at > b.saved_at end)
        
        for i, session in ipairs(sessions) do
            print(string.format("  %s. %s", i, colors.green(session.id)))
            print(string.format("     Player: %s | Saved: %s",
                colors.cyan(session.player_name),
                colors.yellow(session.saved_date)))
        end
    end
    print(string.rep("─", 80))
end

-- List all states
local function list_all()
    list_characters()
    list_missions()
    list_sessions()
end

-- Load a session and display info
local function load_session(session_id)
    print(colors.bold("\n🔄 Loading session: " .. session_id))
    
    local session, err = StateManager.load_session(session_id)
    if not session then
        print(colors.red("❌ Error: " .. err))
        return false
    end
    
    print(colors.green("✓ Session loaded successfully!"))
    print("\n" .. colors.cyan("Session Info:"))
    print(string.rep("─", 60))
    
    if session.player then
        print(colors.bold("Player:"))
        print(string.format("  Name: %s", session.player.name or "Unknown"))
        print(string.format("  HP: %s/%s", session.player.hp, session.player.max_hp))
        print(string.format("  Gold: %s", session.player.gold))
        print(string.format("  Potions: %s", session.player.potions))
        if session.player.items and #session.player.items > 0 then
            print(string.format("  Items: %s", table.concat(session.player.items, ", ")))
        end
    end
    
    if session.dungeon then
        print("\n" .. colors.bold("Dungeon:"))
        print(string.format("  Chambers: %s", session.dungeon.num_chambers))
        print(string.format("  Current Position: Chamber %s", session.dungeon.player_position))
    end
    
    if session.quest_log then
        print("\n" .. colors.bold("Quests:"))
        local active_count = 0
        local completed_count = 0
        
        if session.quest_log.active then
            for _ in pairs(session.quest_log.active) do
                active_count = active_count + 1
            end
        end
        
        if session.quest_log.completed then
            for _ in pairs(session.quest_log.completed) do
                completed_count = completed_count + 1
            end
        end
        
        print(string.format("  Active: %s", active_count))
        print(string.format("  Completed: %s", completed_count))
    end
    
    print(string.rep("─", 60))
    return true
end

-- Delete a state
local function delete_state(state_type, id)
    print(colors.yellow("\n⚠️  Deleting " .. state_type .. ": " .. id))
    
    local success
    if state_type == "character" then
        success = StateManager.delete_character(id)
    elseif state_type == "session" then
        local filename = StateManager.DIRS.sessions .. id .. ".lua"
        success = os.remove(filename)
    elseif state_type == "mission" then
        local filename = StateManager.DIRS.missions .. id .. ".lua"
        success = os.remove(filename)
    else
        print(colors.red("❌ Invalid state type: " .. state_type))
        print("   Valid types: character, mission, session")
        return false
    end
    
    if success then
        print(colors.green("✓ Deleted successfully"))
        return true
    else
        print(colors.red("❌ Failed to delete (may not exist)"))
        return false
    end
end

-- Migrate old save files
local function migrate_old_saves()
    print(colors.bold("\n🔄 Migrating old save files to new format..."))
    print(string.rep("─", 60))
    
    -- Look for old format files (bimbo_player.txt, bimbo_quest.txt)
    local old_player_file = "bimbo_player.txt"
    local old_quest_file = "bimbo_quest.txt"
    
    local player_file = io.open(old_player_file, "r")
    if not player_file then
        print(colors.yellow("  No old player file found (" .. old_player_file .. ")"))
        return
    end
    
    -- Parse old player format
    print(colors.cyan("  Found old player file, parsing..."))
    local player = {items = {}}
    
    for line in player_file:lines() do
        local key, value = line:match("^([^=]+)=(.+)$")
        if key and value then
            if key == "name" then
                player.name = value
            elseif key == "hp" or key == "max_hp" or key == "ac" or 
                   key == "attack_bonus" or key == "gold" or key == "potions" then
                player[key] = tonumber(value)
            elseif key == "damage" then
                player.damage = value
            elseif key == "items" then
                for item in value:gmatch("[^:]+") do
                    table.insert(player.items, item)
                end
            elseif key == "vault_found" or key == "vault_unlocked" then
                player[key] = (value == "true")
            end
        end
    end
    player_file:close()
    
    -- Parse old dungeon format
    local dungeon_file = io.open(old_quest_file, "r")
    local dungeon = nil
    if dungeon_file then
        print(colors.cyan("  Found old dungeon file, parsing..."))
        dungeon = {chambers = {}}
        
        local line = dungeon_file:read("*l")
        if line == "DUNGEON_SAVE_V1" then
            dungeon.player_position = tonumber(dungeon_file:read("*l"):match("player_position=(%d+)"))
            dungeon.num_chambers = tonumber(dungeon_file:read("*l"):match("num_chambers=(%d+)"))
            dungeon_file:read("*l") -- skip ---CHAMBERS---
            
            for i = 1, dungeon.num_chambers do
                local chamber_line = dungeon_file:read("*l")
                if chamber_line then
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
            end
        end
        dungeon_file:close()
    end
    
    -- Save to new format
    local session_id = (player.name or "migrated"):lower():gsub("%s+", "_")
    
    local success = StateManager.save_session(session_id, {
        player = player,
        dungeon = dungeon,
        quest_log = {active = {}, completed = {}, failed = {}},
        metadata = {
            migrated = true,
            migrated_at = os.time(),
            original_files = {old_player_file, old_quest_file}
        }
    })
    
    if success then
        print(colors.green("✓ Migration successful!"))
        print(colors.cyan("  New session ID: " .. session_id))
        print("\n  Old files have been kept. You can delete them manually if desired:")
        print("    " .. old_player_file)
        print("    " .. old_quest_file)
    else
        print(colors.red("❌ Migration failed"))
    end
    
    print(string.rep("─", 60))
end

-- Main command dispatcher
local command = arg[1]

if not command or command == "help" or command == "--help" or command == "-h" then
    print_help()
elseif command == "list" then
    list_all()
elseif command == "list-characters" then
    list_characters()
elseif command == "list-missions" then
    list_missions()
elseif command == "list-sessions" then
    list_sessions()
elseif command == "load" and arg[2] then
    load_session(arg[2])
elseif command == "delete" and arg[2] and arg[3] then
    delete_state(arg[2], arg[3])
elseif command == "migrate" then
    migrate_old_saves()
else
    print(colors.red("❌ Invalid command or missing arguments"))
    print("\nUse 'lua state_manager_cli.lua help' for usage information")
end
