#!/usr/bin/env lua

-- Rest System - Healing between adventures

math.randomseed(os.time())

local function short_rest()
    print("\n" .. string.rep("═", 60))
    print("🏕️  SHORT REST (15 minutes)")
    print(string.rep("═", 60))
    
    local heal = math.random(1, 6) + 1  -- 1d6+1 (HARD MODE: reduced from 2d6)
    print("You take a moment to catch your breath...")
    print(string.format("✨ Restored %d HP", heal))
    
    -- 40% chance of encounter during short rest (HARD MODE: increased from 30%)
    if math.random(1, 100) <= 40 then
        print("\n⚠️  Interrupted! A wandering creature appears!")
        return heal, true  -- healed, encounter
    else
        print("✓ Rest completed successfully")
        return heal, false
    end
end

local function long_rest()
    print("\n" .. string.rep("═", 60))
    print("🏕️  LONG REST (8 hours)")
    print(string.rep("═", 60))
    
    print("You set up camp and rest for the night...")
    print("✨ Fully restored HP and MP")
    print("🍖 Consumed 1 day of rations")
    
    -- 60% chance of encounter during long rest
    if math.random(1, 100) <= 60 then
        print("\n⚠️  Night encounter! Something disturbs your sleep!")
        return "full", true  -- full heal, encounter
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
