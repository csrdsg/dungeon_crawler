#!/usr/bin/env lua

-- Loot Generator for Dungeon Crawler
-- Generates random treasure and items

math.randomseed(os.time())

local function roll_dice(sides, count)
    local total = 0
    local rolls = {}
    for i = 1, count do
        local roll = math.random(1, sides)
        table.insert(rolls, roll)
        total = total + roll
    end
    return total, rolls
end

-- Loot tables by chamber type and quality
local treasure_tables = {
    poor = {
        gold = {min = 5, max = 20},
        items = {
            "Rusty Dagger (1d4 damage, 1gp)",
            "Cracked Potion Bottle (empty)",
            "Torn Scroll (illegible)",
            "Bent Iron Key",
            "Moldy Rations (1 day)",
            "Frayed Rope (20ft)",
            "Worn Torch"
        }
    },
    common = {
        gold = {min = 20, max = 100},
        items = {
            "Healing Potion (Minor, 50gp)",
            "Dagger (1d4, 2gp)",
            "Torch × 3 (3gp)",
            "Rations × 3 (1.5gp)",
            "Rope (50ft, 1gp)",
            "Lockpicks (10gp)",
            "Waterskin (2sp)",
            "Oil Flask (1gp)",
            "Minor Gem (10-50gp)"
        }
    },
    uncommon = {
        gold = {min = 100, max = 300},
        items = {
            "Healing Potion (Major, 150gp)",
            "Mana Potion (75gp)",
            "Scroll of Fireball (100gp)",
            "Scroll of Healing (75gp)",
            "Standard Gem (50-100gp)",
            "Silver Dagger (1d4, 10gp)",
            "Masterwork Lockpicks (+2 to lockpicking, 50gp)",
            "Antidote Potion (50gp)",
            "Strength Potion (100gp)"
        }
    },
    rare = {
        gold = {min = 300, max = 1000},
        items = {
            "Ring of Protection +1 (500gp)",
            "Cloak of Elvenkind (+2 Stealth, 1500gp)",
            "Gloves of Thievery (+2 Lockpicking, 750gp)",
            "Boots of Speed (+2 Initiative, 1000gp)",
            "Major Gem (100-500gp)",
            "Magic Sword +1 (500gp)",
            "Amulet of Health (+2 CON, 1000gp)",
            "Invisibility Potion (300gp)",
            "Scroll of Teleport (500gp)"
        }
    },
    legendary = {
        gold = {min = 1000, max = 5000},
        items = {
            "Bag of Holding (2000gp)",
            "Magic Sword +2 (2000gp)",
            "Ring of Protection +2 (2000gp)",
            "Perfect Gem (500-1000gp)",
            "Amulet of the Gods (+3 to all saves, 3000gp)",
            "Cloak of Invisibility (5000gp)",
            "Staff of Power (4000gp)",
            "Crown of Command (+3 CHA, 3500gp)"
        }
    }
}

-- Loot quality by chamber type
local chamber_loot_quality = {
    [1] = {"poor", "poor", "common"},              -- Empty room
    [2] = {"common", "uncommon", "uncommon", "rare"}, -- Treasure room
    [3] = {"poor", "common", "common"},            -- Monster lair
    [4] = {"poor", "common", "uncommon"},          -- Trap room
    [5] = {"common", "uncommon", "rare"},          -- Puzzle room
    [6] = {"poor", "poor", "common"},              -- Prison cells
    [7] = {"common", "uncommon", "uncommon"},      -- Armory
    [8] = {"common", "uncommon", "rare"},          -- Library
    [9] = {"uncommon", "rare", "rare"},            -- Throne room
    [10] = {"rare", "rare", "legendary"}           -- Boss chamber
}

local function get_loot_quality(chamber_type)
    local qualities = chamber_loot_quality[chamber_type] or {"poor", "common"}
    return qualities[math.random(1, #qualities)]
end

local function generate_gold(quality)
    local table_data = treasure_tables[quality]
    if not table_data then return 0 end
    
    local amount = math.random(table_data.gold.min, table_data.gold.max)
    return amount
end

local function generate_items(quality, count)
    local table_data = treasure_tables[quality]
    if not table_data or not table_data.items then return {} end
    
    local items = {}
    local available = {}
    for _, item in ipairs(table_data.items) do
        table.insert(available, item)
    end
    
    for i = 1, math.min(count, #available) do
        local idx = math.random(1, #available)
        table.insert(items, table.remove(available, idx))
    end
    
    return items
end

local function generate_loot(chamber_type, enemy_defeated, boss_kill)
    chamber_type = chamber_type or 1
    local quality = get_loot_quality(chamber_type)
    
    -- Boss kills upgrade quality
    if boss_kill then
        if quality == "common" then quality = "uncommon"
        elseif quality == "uncommon" then quality = "rare"
        elseif quality == "rare" then quality = "legendary" end
    end
    
    -- Determine how many items
    local item_count = 0
    if quality == "poor" then item_count = math.random(0, 1)
    elseif quality == "common" then item_count = math.random(1, 2)
    elseif quality == "uncommon" then item_count = math.random(1, 3)
    elseif quality == "rare" then item_count = math.random(2, 3)
    elseif quality == "legendary" then item_count = math.random(2, 4) end
    
    -- Enemy defeats may drop additional items
    if enemy_defeated then
        item_count = item_count + math.random(0, 1)
    end
    
    local loot = {
        quality = quality,
        gold = generate_gold(quality),
        items = generate_items(quality, item_count),
        gems = {}
    }
    
    -- Chance for gems in better quality loot
    if quality == "uncommon" or quality == "rare" or quality == "legendary" then
        local gem_chance = quality == "uncommon" and 30 or (quality == "rare" and 60 or 80)
        if math.random(1, 100) <= gem_chance then
            local gem_value = 0
            if quality == "uncommon" then gem_value = math.random(50, 100)
            elseif quality == "rare" then gem_value = math.random(100, 500)
            else gem_value = math.random(500, 1000) end
            
            table.insert(loot.gems, {value = gem_value, quality = quality})
        end
    end
    
    return loot
end

local function display_loot(loot)
    print("\n" .. string.rep("═", 50))
    print("💰 LOOT FOUND!")
    print(string.rep("═", 50))
    print(string.format("Quality: %s", loot.quality:upper()))
    
    if loot.gold > 0 then
        print(string.format("\n💰 Gold: %d gp", loot.gold))
    end
    
    if #loot.items > 0 then
        print("\n📦 Items:")
        for i, item in ipairs(loot.items) do
            print(string.format("  %d. %s", i, item))
        end
    end
    
    if #loot.gems > 0 then
        print("\n💎 Gems:")
        for i, gem in ipairs(loot.gems) do
            print(string.format("  %d. %s Gem (worth %d gp)", i, gem.quality:sub(1,1):upper() .. gem.quality:sub(2), gem.value))
        end
    end
    
    if loot.gold == 0 and #loot.items == 0 and #loot.gems == 0 then
        print("\nThe container is empty...")
    end
    
    print(string.rep("═", 50))
end

local function save_loot(loot, filename)
    local file = io.open(filename, "w")
    if not file then
        print("Error: Could not save loot to " .. filename)
        return false
    end
    
    file:write("LOOT_V1\n")
    file:write("quality=" .. loot.quality .. "\n")
    file:write("gold=" .. loot.gold .. "\n")
    file:write("---ITEMS---\n")
    for _, item in ipairs(loot.items) do
        file:write(item .. "\n")
    end
    file:write("---GEMS---\n")
    for _, gem in ipairs(loot.gems) do
        file:write(string.format("quality=%s,value=%d\n", gem.quality, gem.value))
    end
    
    file:close()
    return true
end

-- Command line interface
if arg[1] == "generate" and arg[2] then
    -- lua loot.lua generate <chamber_type> [enemy_defeated] [boss_kill]
    local chamber_type = tonumber(arg[2])
    local enemy_defeated = arg[3] == "true" or arg[3] == "1"
    local boss_kill = arg[4] == "true" or arg[4] == "1"
    
    local type_names = {
        "Empty room", "Treasure room", "Monster lair", "Trap room", "Puzzle room",
        "Prison cells", "Armory", "Library", "Throne room", "Boss chamber"
    }
    
    print("Generating loot for: " .. (type_names[chamber_type] or "Unknown"))
    if enemy_defeated then print("Enemy was defeated") end
    if boss_kill then print("Boss was killed!") end
    
    local loot = generate_loot(chamber_type, enemy_defeated, boss_kill)
    display_loot(loot)
    
    if arg[5] then
        save_loot(loot, arg[5])
        print("\n✓ Loot saved to: " .. arg[5])
    end
    
elseif arg[1] == "test" then
    -- Test loot generation
    print("Testing loot generation...\n")
    
    print("=== Poor Quality ===")
    display_loot(generate_loot(1, false, false))
    
    print("\n=== Common Quality ===")
    display_loot(generate_loot(2, false, false))
    
    print("\n=== Uncommon Quality ===")
    display_loot(generate_loot(7, true, false))
    
    print("\n=== Rare Quality ===")
    display_loot(generate_loot(9, true, false))
    
    print("\n=== Legendary Quality (Boss Kill) ===")
    display_loot(generate_loot(10, true, true))
    
else
    print("Loot Generator - Dungeon Crawler")
    print("")
    print("Usage:")
    print("  Generate loot:")
    print("    lua loot.lua generate <chamber_type> [enemy_defeated] [boss_kill] [save_file]")
    print("")
    print("  Chamber types:")
    print("    1 = Empty room      6 = Prison cells")
    print("    2 = Treasure room   7 = Armory")
    print("    3 = Monster lair    8 = Library")
    print("    4 = Trap room       9 = Throne room")
    print("    5 = Puzzle room    10 = Boss chamber")
    print("")
    print("  Examples:")
    print("    lua loot.lua generate 2")
    print("    lua loot.lua generate 3 true")
    print("    lua loot.lua generate 10 true true boss_loot.txt")
    print("")
    print("  Test loot generation:")
    print("    lua loot.lua test")
end
