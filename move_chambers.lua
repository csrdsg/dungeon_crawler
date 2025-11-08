#!/usr/bin/env lua

-- Simple script to move through chambers sequentially
-- Usage: lua move_chambers.lua <chamber1> <chamber2> <chamber3> ...

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
        local line = f:read("*l")
        if not line then break end
        
        local chamber = {}
        chamber.id = tonumber(line:match("id=(%d+)"))
        chamber.type = tonumber(line:match("type=(%d+)"))
        chamber.visited = line:match("visited=(%w+)") == "true"
        
        local conn_str = line:match("connections=(.*)$")
        chamber.connections = {}
        if conn_str and conn_str ~= "" then
            for conn in conn_str:gmatch("%d+") do
                table.insert(chamber.connections, tonumber(conn))
            end
        end
        
        dungeon.chambers[chamber.id] = chamber
    end
    
    f:close()
    return dungeon
end

local function save_dungeon(filename, dungeon)
    local f = io.open(filename, "w")
    if not f then return false end
    
    f:write("DUNGEON_SAVE_V1\n")
    f:write("player_position=" .. dungeon.player_position .. "\n")
    f:write("num_chambers=" .. dungeon.num_chambers .. "\n")
    f:write("---CHAMBERS---\n")
    
    for i = 1, dungeon.num_chambers do
        local chamber = dungeon.chambers[i]
        if chamber then
            local conn_str = ""
            if #chamber.connections > 0 then
                conn_str = table.concat(chamber.connections, ":")
            end
            f:write("id=" .. chamber.id .. ",type=" .. chamber.type .. ",visited=" .. tostring(chamber.visited) .. ",connections=" .. conn_str .. "\n")
        end
    end
    
    f:close()
    return true
end

-- Chamber type names
local chamber_types = {
    [1] = "Empty room",
    [2] = "Treasure room",
    [3] = "Monster lair",
    [4] = "Trap room",
    [5] = "Puzzle room",
    [6] = "Prison cells",
    [7] = "Armory",
    [8] = "Library",
    [9] = "Throne room",
    [10] = "Boss chamber"
}

-- Main
if #arg < 1 then
    print("Usage: lua move_chambers.lua <chamber1> [chamber2] [chamber3] ...")
    os.exit(1)
end

local dungeon = load_dungeon("bimbo_quest.txt")
if not dungeon then
    print("Error: Could not load dungeon from bimbo_quest.txt")
    os.exit(1)
end

print("Starting from Chamber " .. dungeon.player_position)
print("")

for i, target in ipairs(arg) do
    local target_num = tonumber(target)
    if not target_num then
        print("Error: Invalid chamber number: " .. target)
        os.exit(1)
    end
    
    local current_chamber = dungeon.chambers[dungeon.player_position]
    if not current_chamber then
        print("Error: Current chamber not found")
        os.exit(1)
    end
    
    -- Check if target is connected
    local connected = false
    for _, conn in ipairs(current_chamber.connections) do
        if conn == target_num then
            connected = true
            break
        end
    end
    
    if not connected then
        print("⚠️  ERROR: Chamber " .. target_num .. " is not connected to Chamber " .. dungeon.player_position)
        print("Available connections from Chamber " .. dungeon.player_position .. ": " .. table.concat(current_chamber.connections, ", "))
        os.exit(1)
    end
    
    -- Move to target
    dungeon.player_position = target_num
    local target_chamber = dungeon.chambers[target_num]
    
    print("═══════════════════════════════════════════════════════════════")
    print("🚶 Moving to Chamber " .. target_num .. "...")
    print("")
    print("📍 CHAMBER " .. target_num .. " - " .. (chamber_types[target_chamber.type] or "Unknown"))
    print("═══════════════════════════════════════════════════════════════")
    print("")
    print("Connected to: " .. table.concat(target_chamber.connections, ", "))
    print("")
end

-- Save the new position
if save_dungeon("bimbo_quest.txt", dungeon) then
    print("✅ Game saved! Current position: Chamber " .. dungeon.player_position)
else
    print("⚠️  Warning: Could not save game")
end
