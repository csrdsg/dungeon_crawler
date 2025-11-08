#!/usr/bin/env lua

-- Rest System - Healing between adventures

math.randomseed(os.time())

-- Load rest configuration from external file
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"
local rest_config = dofile(data_dir .. "rest_config.lua")

local function short_rest()
    local config = rest_config.short_rest
    print("\n" .. string.rep("═", 60))
    print("🏕️  " .. config.name:upper() .. " (" .. config.duration .. ")")
    print(string.rep("═", 60))
    
    local heal = math.random(1, 6) + 1
    print(config.description)
    print(string.format("✨ Restored %d HP", heal))
    
    if math.random(1, 100) <= config.encounter_chance then
        print("\n⚠️  Interrupted! A wandering creature appears!")
        return heal, true
    else
        print("✓ Rest completed successfully")
        return heal, false
    end
end

local function long_rest()
    local config = rest_config.long_rest
    print("\n" .. string.rep("═", 60))
    print("🏕️  " .. config.name:upper() .. " (" .. config.duration .. ")")
    print(string.rep("═", 60))
    
    print(config.description)
    print("✨ Fully restored HP and MP")
    print("🍖 Consumed " .. config.ration_cost .. " day of rations")
    
    if math.random(1, 100) <= config.encounter_chance then
        print("\n⚠️  Night encounter! Something disturbs your sleep!")
        return "full", true
    else
        print("✓ Restful sleep, no interruptions")
        return "full", false
    end
end

-- CLI
if arg[1] == "short" then
    short_rest()
elseif arg[1] == "long" then
    long_rest()
else
    print("Rest System")
    print("")
    print("Usage:")
    print("  lua rest.lua short   - Short rest (heal 1d6+1 HP, 40% encounter) - HARD MODE")
    print("  lua rest.lua long    - Long rest (full heal, 60% encounter)")
end
