#!/usr/bin/env lua

-- Initialize RNG
math.randomseed(os.time())
for i = 1, 10 do math.random() end

-- Load chamber art module
local chamber_art_module = dofile("src/chamber_art.lua")

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

-- Player stats
local player = {
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

-- Load game
print("🗺️  BIMBO'S QUEST - DUNGEON CRAWLER")
print(string.rep("═", 70))

local dungeon = load_dungeon("bimbo_quest.txt")
if not dungeon then
    print("❌ Error loading save file!")
    return
end

print("\n✅ GAME LOADED")
print(string.rep("-", 70))
print(string.format("HP: %d/%d | AC: %d | Gold: %d gp | Potions: %d",
    player.hp, player.max_hp, player.ac, player.gold, player.potions))
print(string.rep("-", 70))

print("\n🎯 ACTIVE QUEST:")
print("  Free Captain Theron's Spirit (Defeat Iron Sentinel in Chamber 7)")

print("\n📍 Current Location: Chamber " .. dungeon.player_position)
local current = dungeon.chambers[dungeon.player_position]
print("   Type: " .. chamber_types[current.type])

-- Display ASCII art for the chamber
local art = chamber_art_module.get_chamber_art(current.type)
print(art[1])

-- Check if command-line argument provided (non-interactive mode)
if arg[1] then
    local command = arg[1]
    
    if command == "status" or command == "--status" then
        print("\n" .. string.rep("═", 70))
        print("📊 CHARACTER STATUS")
        print(string.rep("═", 70))
        print(string.format("Name: %s the Rogue", player.name))
        print(string.format("HP: %d/%d", player.hp, player.max_hp))
        print(string.format("AC: %d", player.ac))
        print(string.format("Attack: +%d, Damage: %s", player.attack_bonus, player.damage))
        print(string.format("Gold: %d gp", player.gold))
        print(string.format("Potions: %d", player.potions))
        print("\n📦 INVENTORY:")
        for _, item in ipairs(player.items) do
            print("   • " .. item)
        end
        print(string.rep("═", 70))
        return
        
    elseif command == "map" or command == "--map" then
        print("\n" .. string.rep("═", 70))
        print("🗺️  DUNGEON MAP")
        print(string.rep("═", 70))
        for i = 1, dungeon.num_chambers do
            local c = dungeon.chambers[i]
            local mark = c.visited and "✓" or "?"
            local current_mark = (i == dungeon.player_position) and " ← YOU ARE HERE" or ""
            print(string.format("Chamber %d: %s %s%s", i, chamber_types[c.type], mark, current_mark))
        end
        print(string.rep("═", 70))
        return
        
    elseif command == "help" or command == "--help" then
        print("\n" .. string.rep("═", 70))
        print("📖 COMMAND LINE USAGE")
        print(string.rep("═", 70))
        print("  lua play.lua           - Start interactive game")
        print("  lua play.lua status    - View character status (non-interactive)")
        print("  lua play.lua map       - View dungeon map (non-interactive)")
        print("  lua play.lua help      - Show this help")
        print(string.rep("═", 70))
        return
        
    else
        print("\n❌ Unknown command: " .. command)
        print("💡 Try: lua play.lua help")
        return
    end
end

-- Game loop (interactive mode)
while true do
    print("\n" .. string.rep("═", 70))
    print("⚡ ACTIONS:")
    print("  [move X] - Move to chamber X")
    print("  [search] - Search the room")
    print("  [rest]   - Short rest (heal 1d6+1, 50% encounter)")
    print("  [potion] - Use healing potion (2d4)")
    print("  [status] - View status")
    print("  [map]    - View map")
    print("  [save]   - Save game")
    print("  [quit]   - Exit")
    
    -- Show available exits
    if #current.connections > 0 then
        print("\n📂 Available exits:")
        for _, conn in ipairs(current.connections) do
            local dest = dungeon.chambers[conn]
            local mark = dest.visited and "✓" or "?"
            print(string.format("   Chamber %d (%s) %s", conn, chamber_types[dest.type], mark))
        end
    end
    
    io.write("\n> ")
    local input = io.read()
    
    if input == "quit" then
        print("👋 Goodbye!")
        break
        
    elseif input == "status" then
        print(string.format("\n%s the Rogue", player.name))
        print(string.format("HP: %d/%d", player.hp, player.max_hp))
        print(string.format("AC: %d", player.ac))
        print(string.format("Attack: +%d, Damage: %s", player.attack_bonus, player.damage))
        print(string.format("Gold: %d gp", player.gold))
        print(string.format("Potions: %d", player.potions))
        print("Items: " .. table.concat(player.items, ", "))
        
    elseif input == "map" then
        print("\n🗺️  DUNGEON MAP:")
        for i = 1, dungeon.num_chambers do
            local c = dungeon.chambers[i]
            local mark = c.visited and "✓" or "?"
            local current_mark = (i == dungeon.player_position) and " ← YOU ARE HERE" or ""
            print(string.format("Chamber %d: %s %s%s", i, chamber_types[c.type], mark, current_mark))
        end
        
    elseif input == "save" then
        save_dungeon(dungeon, "bimbo_quest.txt")
        print("💾 Game saved!")
        
    elseif input == "potion" then
        if player.potions > 0 then
            local heal = roll("2d4")
            player.hp = math.min(player.max_hp, player.hp + heal)
            player.potions = player.potions - 1
            print(string.format("🧪 Healed %d HP! Now at %d/%d HP (%d potions left)",
                heal, player.hp, player.max_hp, player.potions))
        else
            print("❌ No potions left!")
        end
        
    elseif input == "rest" then
        print("\n😴 Taking a short rest...")
        local heal = roll("1d6+1")
        player.hp = math.min(player.max_hp, player.hp + heal)
        print(string.format("Healed %d HP! Now at %d/%d HP", heal, player.hp, player.max_hp))
        
        if math.random(100) <= 50 then
            print("\n⚔️  ENCOUNTER while resting!")
            -- Simple encounter
        else
            print("✅ Rest completed safely.")
        end
        
    elseif input == "search" then
        print("\n🔍 Searching the room...")
        local search_roll = roll("1d20") + 3  -- +3 for rogue search bonus
        print(string.format("   Search roll: %d", search_roll))
        
        if search_roll >= 15 then
            local find_type = math.random(1, 4)
            if find_type == 1 then
                local gold_found = roll("2d10")
                player.gold = player.gold + gold_found
                print(string.format("💰 Found %d gold pieces!", gold_found))
            elseif find_type == 2 then
                player.potions = player.potions + 1
                print("🧪 Found a healing potion!")
            elseif find_type == 3 then
                local items = {"Ancient Coin", "Map Fragment", "Strange Gem", "Rusty Key"}
                local item = items[math.random(#items)]
                table.insert(player.items, item)
                print(string.format("✨ Found: %s", item))
            else
                print("📜 Found a clue about nearby chambers:")
                for _, conn in ipairs(current.connections) do
                    print(string.format("   Chamber %d is a %s", conn, chamber_types[dungeon.chambers[conn].type]))
                end
            end
        elseif search_roll >= 10 then
            print("🔎 Nothing special found, but the room seems clear of traps.")
        else
            print("❌ You find nothing of interest.")
        end
        
    elseif input:match("^move%s+(%d+)$") then
        local dest = tonumber(input:match("^move%s+(%d+)$"))
        
        -- Check if valid connection
        local valid = false
        for _, conn in ipairs(current.connections) do
            if conn == dest then
                valid = true
                break
            end
        end
        
        if not valid then
            print("❌ Cannot move to chamber " .. dest .. " from here!")
        else
            dungeon.player_position = dest
            current = dungeon.chambers[dest]
            current.visited = true
            
            print(string.format("\n🚶 Moving to Chamber %d...", dest))
            print(string.format("📍 Entered: %s", chamber_types[current.type]))
            
            -- Generate encounter based on chamber type
            if current.type == 7 then
                print("\n⚔️  IRON SENTINEL DETECTED!")
                print("💀 Boss fight! (Not yet implemented)")
            elseif current.type == 8 then
                print("\n🔑 You see a locked vault...")
                if player.items[1] == "Silver Key" then
                    print("✅ You have the Silver Key!")
                end
            end
        end
        
    else
        print("❌ Unknown command!")
    end
end
