#!/usr/bin/env lua

math.randomseed(os.time())

-- Simple save/load functions (no external dependencies)
local function save_dungeon(dungeon, filename, player_pos)
    local file = io.open(filename, "w")
    if not file then
        print("Error: Could not save dungeon to " .. filename)
        return false
    end
    
    file:write("DUNGEON_SAVE_V1\n")
    file:write("player_position=" .. (player_pos or 1) .. "\n")
    file:write("num_chambers=" .. #dungeon .. "\n")
    file:write("---CHAMBERS---\n")
    
    for i, chamber in ipairs(dungeon) do
        file:write(string.format("id=%d,type=%d,visited=%s,connections=%s\n",
            chamber.id,
            chamber.type,
            chamber.visited and "true" or "false",
            table.concat(chamber.connections, ":")))
    end
    
    file:close()
    print("\n✓ Dungeon saved to: " .. filename)
    print("✓ Player position: Chamber " .. (player_pos or 1))
    return true
end

function load_dungeon(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Error: Could not load dungeon from " .. filename)
        return nil
    end
    
    local data = {
        chambers = {},
        player_position = 1,
        num_chambers = 0
    }
    
    local line = file:read("*line")
    if line ~= "DUNGEON_SAVE_V1" then
        print("Error: Invalid dungeon file format")
        file:close()
        return nil
    end
    
    -- Read metadata
    data.player_position = tonumber(file:read("*line"):match("player_position=(%d+)"))
    data.num_chambers = tonumber(file:read("*line"):match("num_chambers=(%d+)"))
    file:read("*line") -- Skip ---CHAMBERS--- line
    
    -- Read chambers
    for line in file:lines() do
        local id = tonumber(line:match("id=(%d+)"))
        local type = tonumber(line:match("type=(%d+)"))
        local visited = line:match("visited=(%w+)") == "true"
        local conn_str = line:match("connections=([^%s]*)")
        
        local connections = {}
        if conn_str and conn_str ~= "" then
            for num in conn_str:gmatch("%d+") do
                table.insert(connections, tonumber(num))
            end
        end
        
        table.insert(data.chambers, {
            id = id,
            type = type,
            visited = visited,
            connections = connections
        })
    end
    
    file:close()
    print("\n✓ Dungeon loaded from: " .. filename)
    print("✓ Number of chambers: " .. data.num_chambers)
    print("✓ Player position: Chamber " .. data.player_position)
    
    return data
end

function get_chamber_type_name(type_id)
    local type_names = {
        "Empty room",
        "Treasure room",
        "Monster lair",
        "Trap room",
        "Puzzle room",
        "Prison cells",
        "Armory",
        "Library",
        "Throne room",
        "Boss chamber"
    }
    return type_names[type_id] or "Unknown"
end

local function display_current_chamber(chamber, all_chambers)
    local type_names = {
        "Empty room",
        "Treasure room",
        "Monster lair",
        "Trap room",
        "Puzzle room",
        "Prison cells",
        "Armory",
        "Library",
        "Throne room",
        "Boss chamber"
    }
    
    print("\n" .. string.rep("═", 50))
    print("📍 CURRENT LOCATION: CHAMBER " .. chamber.id)
    print(string.rep("═", 50))
    print("Type: " .. type_names[chamber.type])
    print("Status: " .. (chamber.visited and "Previously visited" or "New area"))
    
    if #chamber.connections > 0 then
        print("\nAvailable exits:")
        for _, conn_id in ipairs(chamber.connections) do
            local conn_chamber = all_chambers[conn_id]
            print(string.format("  → Chamber %d [Type %d: %s] %s", 
                conn_id, 
                conn_chamber.type,
                type_names[conn_chamber.type],
                conn_chamber.visited and "(visited)" or "(unexplored)"))
        end
    else
        print("\n⚠ No exits from this chamber! (Dead end)")
    end
    print(string.rep("═", 50))
end

local function update_player_position(filename, new_position)
    local data = load_dungeon(filename)
    if not data then
        return false
    end
    
    if new_position < 1 or new_position > #data.chambers then
        print("Error: Invalid chamber number")
        return false
    end
    
    -- Mark chamber as visited
    data.chambers[new_position].visited = true
    
    -- Check if chambers are connected
    local current_pos = data.player_position
    local valid_move = false
    
    if new_position == current_pos then
        valid_move = true
    else
        -- Check if new position is connected to current
        for _, conn in ipairs(data.chambers[current_pos].connections) do
            if conn == new_position then
                valid_move = true
                break
            end
        end
        -- Check reverse connection
        for _, conn in ipairs(data.chambers[new_position].connections) do
            if conn == current_pos then
                valid_move = true
                break
            end
        end
    end
    
    if not valid_move then
        print("⚠ Warning: Chambers " .. current_pos .. " and " .. new_position .. " are not connected!")
        print("Moving anyway...")
    end
    
    data.player_position = new_position
    save_dungeon(data.chambers, filename, new_position)
    print("\n➤ Player moved to Chamber " .. new_position)
    display_current_chamber(data.chambers[new_position], data.chambers)
    return true
end

local function generate_dungeon(num_chambers, save_file)
    if not num_chambers then
        print("Usage: lua dungeon_generator.lua <number_of_chambers>")
        print("Example: lua dungeon_generator.lua 20")
        return nil
    end
    
    local chambers = tonumber(num_chambers)
    if not chambers or chambers < 1 then
        print("Error: Number of chambers must be a positive number")
        return nil
    end
    
    print(string.format("Generating dungeon with %d chambers...\n", chambers))
    
    local dungeon = {}
    local has_boss = false
    
    -- Weighted chamber type distribution
    local type_weights = {
        [1] = 12,  -- Empty room
        [2] = 10,  -- Treasure room
        [3] = 10,  -- Monster lair
        [4] = 8,   -- Trap room
        [5] = 10,  -- Puzzle room
        [6] = 8,   -- Prison cells
        [7] = 10,  -- Armory
        [8] = 8,   -- Library
        [9] = 12,  -- Throne room
        [10] = 12  -- Boss chamber
    }
    
    local function weighted_random_type(chamber_id)
        -- Force boss chamber in last 3 chambers if not yet generated
        if chamber_id >= chambers - 2 and not has_boss then
            has_boss = true
            return 10
        end
        
        local total_weight = 0
        for _, weight in pairs(type_weights) do
            total_weight = total_weight + weight
        end
        
        local rand = math.random(1, total_weight)
        local cumulative = 0
        
        for type_id, weight in pairs(type_weights) do
            cumulative = cumulative + weight
            if rand <= cumulative then
                if type_id == 10 then has_boss = true end
                return type_id
            end
        end
        
        return 1 -- Fallback to empty room
    end
    
    for i = 1, chambers do
        local chamber = {
            id = i,
            type = weighted_random_type(i),
            connections = {},
            visited = (i == 1)  -- Mark first chamber as visited
        }
        
        if i > 1 then
            -- Ensure at least 1 connection for non-first chambers
            local num_connections = math.max(1, math.random(0, math.min(3, i - 1)))
            local possible_targets = {}
            for j = 1, i - 1 do
                table.insert(possible_targets, j)
            end
            
            for c = 1, num_connections do
                if #possible_targets > 0 then
                    local idx = math.random(1, #possible_targets)
                    local target = table.remove(possible_targets, idx)
                    table.insert(chamber.connections, target)
                end
            end
            
            table.sort(chamber.connections)
        end
        
        dungeon[i] = chamber
    end
    
    -- Ensure full connectivity via breadth-first search
    local function is_reachable(from, to)
        if from == to then return true end
        
        local visited = {[from] = true}
        local queue = {from}
        
        while #queue > 0 do
            local current = table.remove(queue, 1)
            
            -- Check outgoing connections
            for _, neighbor in ipairs(dungeon[current].connections) do
                if neighbor == to then return true end
                if not visited[neighbor] then
                    visited[neighbor] = true
                    table.insert(queue, neighbor)
                end
            end
            
            -- Check incoming connections (reverse)
            for id, chamber in ipairs(dungeon) do
                if not visited[id] then
                    for _, conn in ipairs(chamber.connections) do
                        if conn == current then
                            if id == to then return true end
                            visited[id] = true
                            table.insert(queue, id)
                            break
                        end
                    end
                end
            end
        end
        
        return false
    end
    
    -- Connect isolated chambers to ensure full connectivity
    for i = 2, chambers do
        if not is_reachable(1, i) then
            -- Find a reachable chamber to connect to
            local reachable_targets = {}
            for j = 1, i - 1 do
                if is_reachable(1, j) then
                    table.insert(reachable_targets, j)
                end
            end
            
            if #reachable_targets > 0 then
                local target = reachable_targets[math.random(1, #reachable_targets)]
                table.insert(dungeon[i].connections, target)
                table.sort(dungeon[i].connections)
            end
        end
    end
    
    print("=" .. string.rep("=", 50))
    print("DUNGEON MAP")
    print("=" .. string.rep("=", 50))
    
    for i, chamber in ipairs(dungeon) do
        local conn_str = ""
        if #chamber.connections > 0 then
            conn_str = " -> Connected to: " .. table.concat(chamber.connections, ", ")
        else
            conn_str = " -> No connections"
        end
        
        print(string.format("Chamber %d [Type: %d]%s", 
            chamber.id, chamber.type, conn_str))
    end
    
    print("=" .. string.rep("=", 50))
    print("\nChamber Types:")
    print("  1 = Empty room")
    print("  2 = Treasure room")
    print("  3 = Monster lair")
    print("  4 = Trap room")
    print("  5 = Puzzle room")
    print("  6 = Prison cells")
    print("  7 = Armory")
    print("  8 = Library")
    print("  9 = Throne room")
    print(" 10 = Boss chamber")
    
    -- Save to file if requested
    if save_file then
        save_dungeon(dungeon, save_file, 1)
        print("\n📍 Starting at Chamber 1")
        display_current_chamber(dungeon[1], dungeon)
    end
    
    return dungeon
end

function print_dungeon_map(dungeon)
    print_ascii_map(dungeon)
end

function print_ascii_map(dungeon)
    print("\n" .. string.rep("═", 60))
    print("ASCII DUNGEON MAP")
    print(string.rep("═", 60))
    
    local type_symbols = {
        [1] = "·",   -- Empty room
        [2] = "$",   -- Treasure room
        [3] = "M",   -- Monster lair
        [4] = "^",   -- Trap room
        [5] = "?",   -- Puzzle room
        [6] = "P",   -- Prison cells
        [7] = "⚔",   -- Armory
        [8] = "B",   -- Library
        [9] = "♔",   -- Throne room
        [10] = "☠"   -- Boss chamber
    }
    
    -- Display legend
    print("\nLegend:")
    print("  [#]  = Chamber number")
    print("  ·    = Empty room    $  = Treasure    M  = Monster")
    print("  ^    = Trap          ?  = Puzzle      P  = Prison")
    print("  ⚔    = Armory        B  = Library     ♔  = Throne")
    print("  ☠    = Boss          →  = Connection  *  = Visited")
    print("")
    
    -- Build adjacency matrix for visualization
    local connections_map = {}
    for i = 1, #dungeon do
        connections_map[i] = {}
        for _, conn in ipairs(dungeon[i].connections) do
            connections_map[i][conn] = true
        end
        -- Add reverse connections for display
        for j = 1, #dungeon do
            if connections_map[j] and connections_map[j][i] then
                connections_map[i][j] = true
            end
        end
    end
    
    -- Simple grid layout (5 chambers per row)
    local chambers_per_row = 5
    local rows = math.ceil(#dungeon / chambers_per_row)
    
    for row = 0, rows - 1 do
        -- Print chamber row
        for col = 0, chambers_per_row - 1 do
            local idx = row * chambers_per_row + col + 1
            if idx <= #dungeon then
                local chamber = dungeon[idx]
                local symbol = type_symbols[chamber.type] or "?"
                local visited = chamber.visited and "*" or " "
                io.write(string.format("[%2d%s]%s  ", idx, visited, symbol))
            end
        end
        print()
        
        -- Print connections row
        if row < rows - 1 then
            for col = 0, chambers_per_row - 1 do
                local idx = row * chambers_per_row + col + 1
                local below = idx + chambers_per_row
                if idx <= #dungeon and below <= #dungeon then
                    if connections_map[idx][below] or connections_map[below][idx] then
                        io.write("  ↓       ")
                    else
                        io.write("          ")
                    end
                end
            end
            print()
        end
    end
    
    print("\n" .. string.rep("═", 60))
    
    -- Print detailed connections
    print("\nDetailed Connections:")
    for i, chamber in ipairs(dungeon) do
        if #chamber.connections > 0 then
            print(string.format("  Chamber %2d → %s", i, table.concat(chamber.connections, ", ")))
        end
    end
    
    print(string.rep("═", 60))
end

-- Command line interface
if arg[1] == "load" and arg[2] then
    -- Load existing dungeon
    local data = load_dungeon(arg[2])
    if data then
        display_current_chamber(data.chambers[data.player_position], data.chambers)
    end
elseif arg[1] == "map" and arg[2] then
    -- Display ASCII map of dungeon
    local data = load_dungeon(arg[2])
    if data then
        print_ascii_map(data.chambers)
    end
elseif arg[1] == "move" and arg[2] and arg[3] then
    -- Move player to new chamber
    update_player_position(arg[2], tonumber(arg[3]))
elseif arg[1] and tonumber(arg[1]) then
    -- Generate new dungeon
    local save_file = arg[2]
    if not save_file then
        save_file = "dungeon_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    end
    generate_dungeon(arg[1], save_file)
else
    print("Dungeon Crawler - Dungeon Generator")
    print("")
    print("Usage:")
    print("  Generate new dungeon:")
    print("    lua dungeon_generator.lua <chambers> [filename]")
    print("    Example: lua dungeon_generator.lua 20 my_dungeon.txt")
    print("")
    print("  Load existing dungeon:")
    print("    lua dungeon_generator.lua load <filename>")
    print("    Example: lua dungeon_generator.lua load my_dungeon.txt")
    print("")
    print("  Display ASCII map:")
    print("    lua dungeon_generator.lua map <filename>")
    print("    Example: lua dungeon_generator.lua map my_dungeon.txt")
    print("")
    print("  Move player:")
    print("    lua dungeon_generator.lua move <filename> <chamber_number>")
    print("    Example: lua dungeon_generator.lua move my_dungeon.txt 3")
end
