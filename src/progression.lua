#!/usr/bin/env lua

-- XP and Leveling System
-- Track XP, auto level-up, skill point allocation

local function load_character_stats(filename)
    local file = io.open(filename, "r")
    if not file then return nil end
    
    local char = {
        name = "Unknown",
        level = 1,
        xp = 0,
        next_level_xp = 1000,
        skill_points = 0,
        hp = 30,
        max_hp = 30,
        str = 10, dex = 10, con = 10, int = 10, wis = 10, cha = 10
    }
    
    for line in file:lines() do
        local level = line:match("%*%*Level:%*%* (%d+)")
        if level then char.level = tonumber(level) end
        
        local xp = line:match("%*%*XP:%*%* (%d+)")
        if xp then char.xp = tonumber(xp) end
        
        local hp_match = line:match("%((%d+)/(%d+) HP%)")
        if hp_match then
            local current, max = hp_match:match("(%d+)/(%d+)")
            if current and max then
                char.hp = tonumber(current)
                char.max_hp = tonumber(max)
            end
        end
        
        local str = line:match("%*%*Strength %(STR%):%*%* (%d+)")
        if str then char.str = tonumber(str) end
    end
    
    file:close()
    return char
end

local function calculate_xp_for_level(level)
    return level * 1000
end

local function add_xp(char, amount)
    print(string.rep("═", 60))
    print("⭐ EXPERIENCE GAINED")
    print(string.rep("═", 60))
    
    local old_xp = char.xp
    local old_level = char.level
    char.xp = char.xp + amount
    
    print(string.format("+ %d XP", amount))
    print(string.format("Total XP: %d → %d", old_xp, char.xp))
    
    -- Check for level up
    local leveled_up = false
    while char.xp >= calculate_xp_for_level(char.level) do
        char.level = char.level + 1
        char.skill_points = char.skill_points + 2
        char.max_hp = char.max_hp + math.random(4, 8)
        leveled_up = true
        
        print("\n" .. string.rep("✨", 30))
        print(string.format("🎉 LEVEL UP! You are now level %d!", char.level))
        print(string.rep("✨", 30))
        print(string.format("+ Max HP increased to %d", char.max_hp))
        print(string.format("+ Gained 2 skill points (total: %d)", char.skill_points))
        
        if char.level == 5 then
            print("\n🌟 MILESTONE: Unlocked skill specializations!")
        elseif char.level == 10 then
            print("\n🌟 MILESTONE: Master tier unlocked!")
        end
    end
    
    local next_level_xp = calculate_xp_for_level(char.level)
    local progress = ((char.xp % next_level_xp) / next_level_xp) * 100
    
    print(string.format("\nProgress to Level %d: %.0f%% (%d / %d XP)",
        char.level + 1, progress, char.xp % next_level_xp, next_level_xp))
    
    print(string.rep("═", 60))
    
    return leveled_up
end

local function display_progression(char)
    print("\n" .. string.rep("═", 60))
    print("📊 CHARACTER PROGRESSION - " .. (char.name or "Unknown"))
    print(string.rep("═", 60))
    
    print(string.format("Level: %d", char.level))
    print(string.format("Experience: %d XP", char.xp))
    
    local next_xp = calculate_xp_for_level(char.level)
    local current_progress = char.xp % next_xp
    local progress_pct = (current_progress / next_xp) * 100
    
    print(string.format("Next Level: %d / %d XP (%.0f%%)", current_progress, next_xp, progress_pct))
    
    -- Progress bar
    local bar_length = 40
    local filled = math.floor((progress_pct / 100) * bar_length)
    local bar = "[" .. string.rep("█", filled) .. string.rep("░", bar_length - filled) .. "]"
    print(bar)
    
    print(string.format("\nSkill Points Available: %d", char.skill_points))
    print(string.format("Max HP: %d", char.max_hp))
    
    -- Level milestones
    print("\n📜 Milestones:")
    local milestones = {
        {level = 5, text = "Skill Specializations", achieved = char.level >= 5},
        {level = 10, text = "Master Tier Skills", achieved = char.level >= 10},
        {level = 15, text = "Epic Abilities", achieved = char.level >= 15},
        {level = 20, text = "Legendary Status", achieved = char.level >= 20}
    }
    
    for _, milestone in ipairs(milestones) do
        local status = milestone.achieved and "✓" or " "
        print(string.format("  [%s] Level %2d - %s", status, milestone.level, milestone.text))
    end
    
    print(string.rep("═", 60))
end

local function simulate_xp_gain(char, encounters)
    local xp_values = {
        goblin = 75,
        skeleton = 75,
        bandit = 100,
        cultist = 75,
        orc = 125,
        zombie = 75,
        spider = 125,
        gargoyle = 200,
        ogre = 450,
        vampire = 2300,
        dragon = 5000
    }
    
    local total_xp = 0
    for enemy, count in pairs(encounters) do
        local xp = (xp_values[enemy] or 50) * count
        total_xp = total_xp + xp
        print(string.format("  %d × %s = %d XP", count, enemy, xp))
    end
    
    return total_xp
end

-- Command line interface
if arg[1] == "show" and arg[2] then
    local char = load_character_stats(arg[2])
    if char then
        display_progression(char)
    end
    
elseif arg[1] == "add" and arg[2] and arg[3] then
    local char = load_character_stats(arg[2])
    if char then
        local xp = tonumber(arg[3])
        add_xp(char, xp)
        display_progression(char)
    end
    
elseif arg[1] == "levelup" and arg[2] then
    local char = load_character_stats(arg[2])
    if char then
        local xp_needed = calculate_xp_for_level(char.level) - (char.xp % calculate_xp_for_level(char.level))
        add_xp(char, xp_needed)
        display_progression(char)
    end
    
else
    print("XP and Leveling System")
    print("")
    print("Usage:")
    print("  Show progression:")
    print("    lua progression.lua show <character_file>")
    print("")
    print("  Add XP:")
    print("    lua progression.lua add <character_file> <xp_amount>")
    print("    Example: lua progression.lua add character_bimbo.md 150")
    print("")
    print("  Force level up:")
    print("    lua progression.lua levelup <character_file>")
end
