#!/usr/bin/env lua

-- Better seeding: warmup prevents patterns
math.randomseed(os.time())
for i = 1, 10 do math.random() end

local M = {}

-- Parse dice notation like "3d6+2" or "d20-1"
function M.roll(notation)
    if not notation then return nil end
    
    -- Parse notation: XdY+Z or XdY-Z or dY+Z
    local num_dice, sides, modifier = notation:match("(%d*)d(%d+)([%+%-]?%d*)")
    
    num_dice = tonumber(num_dice) or 1
    sides = tonumber(sides)
    modifier = tonumber(modifier) or 0
    
    if not sides or sides < 1 then
        return nil
    end
    
    local total = 0
    for i = 1, num_dice do
        total = total + math.random(1, sides)
    end
    
    return total + modifier
end

-- Legacy function for CLI compatibility
local function roll_dice(dice_type, num_dice)
    if not dice_type or not num_dice then
        print("Usage: lua dice.lua <dice_type> <number_of_dice>")
        print("Example: lua dice.lua d20 3")
        return nil
    end
    
    local sides = tonumber(dice_type:match("d(%d+)"))
    if not sides then
        print("Error: Invalid dice format. Use format like 'd20' or 'd6'")
        return nil
    end
    
    local count = tonumber(num_dice)
    if not count or count < 1 then
        print("Error: Number of dice must be a positive number")
        return nil
    end
    
    local total = 0
    local rolls = {}
    
    for i = 1, count do
        local roll = math.random(1, sides)
        table.insert(rolls, roll)
        total = total + roll
    end
    
    print(string.format("Rolling %dx%s:", count, dice_type))
    print("Rolls: " .. table.concat(rolls, ", "))
    print("Total: " .. total)
    
    return total
end

-- CLI interface
if arg and arg[1] and arg[2] then
    roll_dice(arg[1], arg[2])
elseif arg and arg[1] and not arg[2] then
    print("Usage: lua dice.lua <dice_type> <number_of_dice>")
    print("Example: lua dice.lua d20 3")
    print("         lua dice.lua d10 5")
end

return M
