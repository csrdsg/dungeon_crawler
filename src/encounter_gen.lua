#!/usr/bin/env lua

-- Encounter Generator for Dungeon Crawler
-- Auto-generates encounters based on chamber type

math.randomseed(os.time())

-- Load encounter data from external file
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"
local encounter_data = dofile(data_dir .. "encounters.lua")

local friendly_encounters = encounter_data.friendly_encounters
local neutral_encounters = encounter_data.neutral_encounters
local hostile_encounters = encounter_data.hostile_encounters
local encounter_chances = encounter_data.encounter_chances
local disposition_weights = encounter_data.disposition_weights

local function roll_dice(sides, count)
    local total = 0
    for i = 1, count do
        total = total + math.random(1, sides)
    end
    return total
end

local function get_disposition(chamber_type)
    local weights = disposition_weights[chamber_type] or {friendly = 2, neutral = 3, hostile = 5}
    local total = weights.friendly + weights.neutral + weights.hostile
    local roll = math.random(1, total)
    
    if roll <= weights.friendly then
        return "friendly"
    elseif roll <= weights.friendly + weights.neutral then
        return "neutral"
    else
        return "hostile"
    end
end

local function parse_count(count_str)
    if not count_str then return 1 end
    local num, sides = count_str:match("(%d+)d(%d+)")
    if num and sides then
        return roll_dice(tonumber(sides), tonumber(num))
    end
    return 1
end

local function generate_encounter(chamber_type, dungeon_level)
    dungeon_level = dungeon_level or 1
    
    -- Check if encounter occurs
    local chance = encounter_chances[chamber_type] or 40
    if math.random(1, 100) > chance then
        return nil -- No encounter
    end
    
    -- Determine disposition
    local disposition = get_disposition(chamber_type)
    
    -- Select encounter
    local encounter_table
    if disposition == "friendly" then
        encounter_table = friendly_encounters
    elseif disposition == "neutral" then
        encounter_table = neutral_encounters
    else
        -- Filter hostile encounters by dungeon level
        encounter_table = {}
        for _, enc in ipairs(hostile_encounters) do
            if not enc.min_dungeon_level or dungeon_level >= enc.min_dungeon_level then
                table.insert(encounter_table, enc)
            end
        end
        
        -- Fallback to weakest enemies if table is empty
        if #encounter_table == 0 then
            encounter_table = {hostile_encounters[1], hostile_encounters[2], hostile_encounters[3]}
        end
    end
    
    local encounter = encounter_table[math.random(1, #encounter_table)]
    
    -- Calculate level for hostile encounters
    local enemy_level = dungeon_level
    if encounter.level_range then
        enemy_level = math.random(encounter.level_range[1], encounter.level_range[2])
    end
    
    -- Calculate count
    local count = parse_count(encounter.count)
    
    return {
        disposition = disposition,
        name = encounter.name,
        description = encounter.desc,
        type = encounter.type or "npc",
        count = count,
        level = enemy_level
    }
end

local function display_encounter(encounter, chamber_name)
    local type_names = {
        "Empty room", "Treasure room", "Monster lair", "Trap room", "Puzzle room",
        "Prison cells", "Armory", "Library", "Throne room", "Boss chamber"
    }
    
    print("\n" .. string.rep("═", 50))
    print("🎲 ENCOUNTER!")
    print(string.rep("═", 50))
    
    if not encounter then
        print("The " .. (chamber_name or "chamber") .. " is quiet and empty.")
        print("No encounters detected.")
        return
    end
    
    local disposition_symbols = {
        friendly = "😊",
        neutral = "😐",
        hostile = "💀"
    }
    
    print(string.format("Disposition: %s %s", 
        disposition_symbols[encounter.disposition] or "?",
        encounter.disposition:upper()))
    
    if encounter.count > 1 then
        print(string.format("Encounter: %d × %s", encounter.count, encounter.name))
    else
        print(string.format("Encounter: %s", encounter.name))
    end
    
    print(string.format("Description: %s", encounter.description))
    
    if encounter.disposition == "hostile" then
        print(string.format("Enemy Level: %d", encounter.level))
        print(string.format("Enemy Type: %s", encounter.type))
        print("\n⚔️  Prepare for combat!")
    elseif encounter.disposition == "neutral" then
        print("\n💬 This encounter may be avoided or negotiated with.")
    else
        print("\n✨ This encounter is friendly and may offer assistance.")
    end
    
    print(string.rep("═", 50))
end

local function save_encounter(encounter, filename)
    local file = io.open(filename, "w")
    if not file then
        print("Error: Could not save encounter to " .. filename)
        return false
    end
    
    file:write("ENCOUNTER_V1\n")
    file:write("disposition=" .. (encounter.disposition or "neutral") .. "\n")
    file:write("name=" .. (encounter.name or "Unknown") .. "\n")
    file:write("description=" .. (encounter.description or "") .. "\n")
    file:write("type=" .. (encounter.type or "npc") .. "\n")
    file:write("count=" .. (encounter.count or 1) .. "\n")
    file:write("level=" .. (encounter.level or 1) .. "\n")
    
    file:close()
    return true
end

-- Command line interface
if arg[1] == "generate" and arg[2] then
    -- lua encounter_gen.lua generate <chamber_type> [dungeon_level]
    local chamber_type = tonumber(arg[2])
    local dungeon_level = tonumber(arg[3]) or 1
    
    local type_names = {
        "Empty room", "Treasure room", "Monster lair", "Trap room", "Puzzle room",
        "Prison cells", "Armory", "Library", "Throne room", "Boss chamber"
    }
    
    print("Generating encounter for: " .. (type_names[chamber_type] or "Unknown"))
    print("Dungeon Level: " .. dungeon_level)
    
    local encounter = generate_encounter(chamber_type, dungeon_level)
    display_encounter(encounter, type_names[chamber_type])
    
    if encounter and arg[4] then
        save_encounter(encounter, arg[4])
        print("\n✓ Encounter saved to: " .. arg[4])
    end
    
elseif arg[1] == "test" then
    -- Test all chamber types
    print("Testing encounter generation for all chamber types...\n")
    for i = 1, 10 do
        local type_names = {
            "Empty room", "Treasure room", "Monster lair", "Trap room", "Puzzle room",
            "Prison cells", "Armory", "Library", "Throne room", "Boss chamber"
        }
        print("\n--- Chamber Type " .. i .. ": " .. type_names[i] .. " ---")
        local encounter = generate_encounter(i, 2)
        if encounter then
            print(string.format("  %s: %s (%d count, level %d)",
                encounter.disposition,
                encounter.name,
                encounter.count,
                encounter.level))
        else
            print("  No encounter")
        end
    end
    
else
    print("Encounter Generator - Dungeon Crawler")
    print("")
    print("Usage:")
    print("  Generate encounter for a chamber:")
    print("    lua encounter_gen.lua generate <chamber_type> [dungeon_level] [save_file]")
    print("")
    print("  Chamber types:")
    print("    1 = Empty room      6 = Prison cells")
    print("    2 = Treasure room   7 = Armory")
    print("    3 = Monster lair    8 = Library")
    print("    4 = Trap room       9 = Throne room")
    print("    5 = Puzzle room    10 = Boss chamber")
    print("")
    print("  Examples:")
    print("    lua encounter_gen.lua generate 3 2")
    print("    lua encounter_gen.lua generate 10 5 boss_encounter.txt")
    print("")
    print("  Test all chamber types:")
    print("    lua encounter_gen.lua test")
end
