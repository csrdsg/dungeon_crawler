#!/usr/bin/env lua

-- Trap System

math.randomseed(os.time())

-- Load trap data from external file
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"
local traps = dofile(data_dir .. "trap_types.lua")

local function roll_dice(dice_str)
    local count, sides, bonus = dice_str:match("(%d+)d(%d+)([%+%-]?%d*)")
    count = tonumber(count) or 1
    sides = tonumber(sides) or 6
    bonus = tonumber(bonus) or 0
    
    local total = bonus
    for i = 1, count do
        total = total + math.random(1, sides)
    end
    return total
end

local function trigger_trap(trap_id, detect_bonus, disarm_bonus)
    local trap = traps[trap_id] or traps[math.random(1, #traps)]
    
    print("\n" .. string.rep("═", 60))
    print("⚠️  TRAP TRIGGERED!")
    print(string.rep("═", 60))
    print("Trap: " .. trap.name)
    
    -- Detection
    local detect_roll = math.random(1, 20) + detect_bonus
    print(string.format("\nDetection: d20(%d) + %d = %d vs DC %d",
        detect_roll - detect_bonus, detect_bonus, detect_roll, trap.dc))
    
    if detect_roll >= trap.dc then
        print("✓ Trap detected!")
        
        -- Disarm attempt
        local disarm_roll = math.random(1, 20) + disarm_bonus
        print(string.format("Disarm: d20(%d) + %d = %d vs DC %d",
            disarm_roll - disarm_bonus, disarm_bonus, disarm_roll, trap.dc + 2))
        
        if disarm_roll >= trap.dc + 2 then
            print("✓ Trap successfully disarmed!")
            print(string.rep("═", 60))
            return 0  -- No damage
        else
            print("✗ Failed to disarm - trap springs!")
        end
    else
        print("✗ Trap not detected!")
    end
    
    -- Trigger trap
    local damage = roll_dice(trap.damage)
    print(string.format("\n💥 %s damage!", damage))
    print(string.rep("═", 60))
    
    return damage
end

-- CLI
if arg[1] == "trigger" then
    local trap_id = tonumber(arg[2])
    local detect = tonumber(arg[3]) or 0
    local disarm = tonumber(arg[4]) or 0
    trigger_trap(trap_id, detect, disarm)
else
    print("Trap System")
    print("")
    print("Usage:")
    print("  lua traps.lua trigger [trap_id] [detect_bonus] [disarm_bonus]")
    print("")
    print("Available traps:")
    for i, trap in ipairs(traps) do
        print(string.format("  %d. %s (%s dmg, DC %d)", i, trap.name, trap.damage, trap.dc))
    end
end
