#!/usr/bin/env lua

-- Inventory Management System
-- Add/remove items, use consumables, equip gear, manage weight

local function load_character(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Error: Could not load character from " .. filename)
        return nil
    end
    
    local char = {
        name = "Unknown",
        hp = 30,
        max_hp = 30,
        items = {},
        weapons = {},
        armor = {},
        gold = 0,
        weight = 0,
        max_weight = 50,
        filename = filename
    }
    
    local in_weapons = false
    local in_armor = false
    local in_items = false
    
    for line in file:lines() do
        if line:match("### Weapons") then in_weapons = true; in_armor = false; in_items = false
        elseif line:match("### Armor") then in_armor = true; in_weapons = false; in_items = false
        elseif line:match("### Items") then in_items = true; in_weapons = false; in_armor = false
        elseif line:match("^##") or line:match("^%*%*Gold") then in_weapons = false; in_armor = false; in_items = false end
        
        if in_weapons and line:match("^%d+%.") then
            table.insert(char.weapons, line:match("%d+%. (.+)"))
        elseif in_armor and line:match("^%d+%.") then
            table.insert(char.armor, line:match("%d+%. (.+)"))
        elseif in_items and line:match("^%d+%.") then
            table.insert(char.items, line:match("%d+%. (.+)"))
        end
        
        local gold = line:match("%*%*Gold:%*%* (%d+)")
        if gold then char.gold = tonumber(gold) end
        
        local weight = line:match("%*%*Current Weight:%*%* ([%d%.]+)")
        if weight then char.weight = tonumber(weight) end
    end
    
    file:close()
    return char
end

local function display_inventory(char)
    print("\n" .. string.rep("═", 60))
    print("📦 INVENTORY - " .. char.name)
    print(string.rep("═", 60))
    print(string.format("💰 Gold: %d gp", char.gold))
    print(string.format("⚖️  Weight: %.1f / %.1f lbs (%.0f%% capacity)", 
        char.weight, char.max_weight, (char.weight/char.max_weight)*100))
    
    print("\n⚔️  WEAPONS:")
    if #char.weapons > 0 then
        for i, weapon in ipairs(char.weapons) do
            print(string.format("  %d. %s", i, weapon))
        end
    else
        print("  (none)")
    end
    
    print("\n🛡️  ARMOR:")
    if #char.armor > 0 then
        for i, armor in ipairs(char.armor) do
            print(string.format("  %d. %s", i, armor))
        end
    else
        print("  (none)")
    end
    
    print("\n🎒 ITEMS:")
    if #char.items > 0 then
        for i, item in ipairs(char.items) do
            print(string.format("  %d. %s", i, item))
        end
    else
        print("  (none)")
    end
    
    print(string.rep("═", 60))
end

local function use_item(char, item_name)
    print("\n🔮 Using: " .. item_name)
    
    -- Check if item exists
    local found = false
    local item_index = 0
    
    for i, item in ipairs(char.items) do
        if item:lower():find(item_name:lower()) then
            found = true
            item_index = i
            break
        end
    end
    
    if not found then
        print("❌ Item not found in inventory!")
        return false
    end
    
    local item = char.items[item_index]
    
    -- Handle different item types
    if item:lower():find("healing potion") then
        local heal = math.random(2, 4) + math.random(2, 4) + 2 -- 2d4+2
        local old_hp = char.hp
        char.hp = math.min(char.hp + heal, char.max_hp)
        print(string.format("✨ Healed %d HP! (%d → %d)", heal, old_hp, char.hp))
        
        -- Remove or decrease count
        if item:match("× (%d+)") then
            local count = tonumber(item:match("× (%d+)"))
            if count > 1 then
                char.items[item_index] = item:gsub("× %d+", "× " .. (count - 1))
            else
                table.remove(char.items, item_index)
            end
        else
            table.remove(char.items, item_index)
        end
        
        print("✓ Potion consumed")
        return true, "hp_restored", heal
        
    elseif item:lower():find("scroll") then
        print("📜 Scroll activated! (Effect would be applied in combat)")
        table.remove(char.items, item_index)
        return true, "scroll_used", item
        
    elseif item:lower():find("rations") then
        print("🍖 Ate rations. Feels good!")
        
        if item:match("× (%d+)") then
            local count = tonumber(item:match("× (%d+)"))
            if count > 1 then
                char.items[item_index] = item:gsub("× %d+", "× " .. (count - 1))
            else
                table.remove(char.items, item_index)
            end
        else
            table.remove(char.items, item_index)
        end
        return true, "fed"
        
    else
        print("⚠️  This item cannot be used (equipment or quest item)")
        return false
    end
end

local function add_item(char, item_desc, weight)
    weight = weight or 0.5
    
    if char.weight + weight > char.max_weight then
        print("❌ Cannot add item: Inventory full!")
        print(string.format("   Need %.1f lbs, have %.1f / %.1f lbs available", 
            weight, char.max_weight - char.weight, char.max_weight))
        return false
    end
    
    table.insert(char.items, item_desc)
    char.weight = char.weight + weight
    print(string.format("✓ Added: %s (%.1f lbs)", item_desc, weight))
    return true
end

local function drop_item(char, item_name)
    for i, item in ipairs(char.items) do
        if item:lower():find(item_name:lower()) then
            local weight_str = item:match("%(Weight: ([%d%.]+)")
            local weight = weight_str and tonumber(weight_str) or 0.5
            
            table.remove(char.items, i)
            char.weight = char.weight - weight
            print(string.format("✓ Dropped: %s (freed %.1f lbs)", item, weight))
            return true
        end
    end
    
    print("❌ Item not found!")
    return false
end

-- Command line interface
if arg[1] == "show" and arg[2] then
    local char = load_character(arg[2])
    if char then
        display_inventory(char)
    end
    
elseif arg[1] == "use" and arg[2] and arg[3] then
    local char = load_character(arg[2])
    if char then
        use_item(char, arg[3])
        display_inventory(char)
    end
    
elseif arg[1] == "add" and arg[2] and arg[3] then
    local char = load_character(arg[2])
    if char then
        local weight = tonumber(arg[4]) or 0.5
        add_item(char, arg[3], weight)
        display_inventory(char)
    end
    
elseif arg[1] == "drop" and arg[2] and arg[3] then
    local char = load_character(arg[2])
    if char then
        drop_item(char, arg[3])
        display_inventory(char)
    end
    
else
    print("Inventory Management System")
    print("")
    print("Usage:")
    print("  Show inventory:")
    print("    lua inventory.lua show <character_file>")
    print("    Example: lua inventory.lua show character_bimbo.md")
    print("")
    print("  Use item:")
    print("    lua inventory.lua use <character_file> <item_name>")
    print("    Example: lua inventory.lua use character_bimbo.md \"healing potion\"")
    print("")
    print("  Add item:")
    print("    lua inventory.lua add <character_file> <item_desc> [weight]")
    print("    Example: lua inventory.lua add character_bimbo.md \"Magic Sword +1\" 3.0")
    print("")
    print("  Drop item:")
    print("    lua inventory.lua drop <character_file> <item_name>")
    print("    Example: lua inventory.lua drop character_bimbo.md rope")
end
