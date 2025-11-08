#!/usr/bin/env lua

-- Combat System for Dungeon Crawler
-- Handles attack rolls, damage, HP tracking, and combat flow

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

local function calculate_modifier(attribute)
    if attribute <= 4 then return -3
    elseif attribute <= 6 then return -2
    elseif attribute <= 8 then return -1
    elseif attribute <= 12 then return 0
    elseif attribute <= 14 then return 1
    elseif attribute <= 16 then return 2
    else return 3 end
end

local function load_character(filename)
    local char = {
        name = "Unknown",
        hp = 30,
        max_hp = 30,
        ac = 14,  -- BUFFED: Default AC
        str = 10,
        dex = 10,
        con = 10,
        attack_bonus = 3,  -- BUFFED: Proficiency +3
        damage_dice = {sides = 6, count = 1, bonus = 2}  -- BUFFED: +2 damage
    }
    
    local file = io.open(filename, "r")
    if not file then
        print("Warning: Could not load character from " .. filename)
        return char
    end
    
    for line in file:lines() do
        local name = line:match("%*%*Name:%*%* (.+)")
        if name then char.name = name end
        
        local hp = line:match("%*%*Health Points %(HP%):%*%* .+ = %*%*(%d+) HP%*%*")
        if hp then 
            char.hp = tonumber(hp)
            char.max_hp = tonumber(hp)
        end
        
        local ac = line:match("%*%*Armor Class %(AC%):%*%* .+ = %*%*(%d+) AC%*%*")
        if ac then char.ac = tonumber(ac) end
        
        local str = line:match("%*%*Strength %(STR%):%*%* (%d+)")
        if str then char.str = tonumber(str) end
        
        local dex = line:match("%*%*Dexterity %(DEX%):%*%* (%d+)")
        if dex then char.dex = tonumber(dex) end
        
        local con = line:match("%*%*Constitution %(CON%):%*%* (%d+)")
        if con then char.con = tonumber(con) end
        
        local atk = line:match("%*%*Attack Bonus:%*%* %+?(%d+)")
        if atk then char.attack_bonus = tonumber(atk) end
        
        -- Try to parse damage bonus
        local dmg_bonus = line:match("%*%*Damage Bonus:%*%* %+?(%d+)")
        if dmg_bonus then char.damage_dice.bonus = tonumber(dmg_bonus) end
    end
    
    file:close()
    return char
end

local function create_enemy(name, level, type_name)
    local enemies = {
        -- HARD MODE v2: Fine-tuned for 55% win rate (reduced HP slightly)
        goblin = {hp = 8, ac = 12, attack_bonus = 3, damage = "1d6+1", xp = 75},
        orc = {hp = 18, ac = 13, attack_bonus = 4, damage = "1d8+1", xp = 125},
        skeleton = {hp = 14, ac = 12, attack_bonus = 3, damage = "1d6+2", xp = 75},
        zombie = {hp = 20, ac = 9, attack_bonus = 3, damage = "1d6+1", xp = 75},
        spider = {hp = 22, ac = 14, attack_bonus = 4, damage = "1d8+1", xp = 125},
        bandit = {hp = 13, ac = 12, attack_bonus = 3, damage = "1d6+1", xp = 100},
        cultist = {hp = 11, ac = 12, attack_bonus = 3, damage = "1d4+2", xp = 75},
        gargoyle = {hp = 55, ac = 15, attack_bonus = 5, damage = "1d10+2", xp = 200},
        ogre = {hp = 65, ac = 13, attack_bonus = 6, damage = "2d8+3", xp = 450},
        vampire = {hp = 85, ac = 16, attack_bonus = 8, damage = "1d10+3", xp = 2300},
        dragon = {hp = 140, ac = 18, attack_bonus = 10, damage = "2d10+5", xp = 5000}
    }
    
    local template = enemies[type_name] or enemies["goblin"]
    local enemy = {
        name = name or (type_name:sub(1,1):upper() .. type_name:sub(2)),
        type = type_name,
        hp = template.hp + (level * 3),
        max_hp = template.hp + (level * 3),
        ac = template.ac + math.floor(level / 2),
        attack_bonus = template.attack_bonus + math.floor(level / 3),
        damage = template.damage,
        xp = template.xp + (level * 25),
        level = level
    }
    
    return enemy
end

local function parse_damage(damage_str)
    local count, sides, bonus = damage_str:match("(%d+)d(%d+)([%+%-]?%d*)")
    count = tonumber(count) or 1
    sides = tonumber(sides) or 6
    bonus = tonumber(bonus) or 0
    return {count = count, sides = sides, bonus = bonus}
end

local function attack_roll(attacker, target, attacker_name, target_name)
    local roll, rolls = roll_dice(20, 1)
    local total = roll + attacker.attack_bonus
    
    print(string.format("%s attacks %s!", attacker_name, target_name))
    print(string.format("  Roll: %d + %d (bonus) = %d vs AC %d", 
        roll, attacker.attack_bonus, total, target.ac))
    
    if roll == 20 then
        print("  💥 CRITICAL HIT! Double damage!")
        return true, true -- hit, critical
    elseif roll == 1 then
        print("  ❌ CRITICAL MISS!")
        return false, false
    elseif total >= target.ac then
        print("  ✓ Hit!")
        return true, false
    else
        print("  ✗ Miss!")
        return false, false
    end
end

local function damage_roll(damage_dice, critical)
    local multiplier = critical and 2 or 1
    local total, rolls = roll_dice(damage_dice.sides, damage_dice.count * multiplier)
    total = total + damage_dice.bonus
    
    print(string.format("  Damage: %dd%d%s%d = %d damage",
        damage_dice.count * multiplier,
        damage_dice.sides,
        damage_dice.bonus >= 0 and "+" or "",
        damage_dice.bonus,
        total))
    
    return total
end

local function apply_damage(target, damage, target_name)
    target.hp = target.hp - damage
    if target.hp < 0 then target.hp = 0 end
    
    print(string.format("  %s takes %d damage! (%d/%d HP remaining)", 
        target_name, damage, target.hp, target.max_hp))
    
    if target.hp <= 0 then
        print(string.format("  ☠️  %s is defeated!", target_name))
        return true -- target defeated
    end
    return false
end

local function combat_round(player, enemy, round_num)
    print("\n" .. string.rep("─", 50))
    print(string.format("ROUND %d", round_num))
    print(string.rep("─", 50))
    
    -- Player attacks
    local hit, critical = attack_roll(player, enemy, player.name, enemy.name)
    if hit then
        local damage = damage_roll(player.damage_dice, critical)
        local enemy_dead = apply_damage(enemy, damage, enemy.name)
        if enemy_dead then
            return "player_win"
        end
    end
    
    print("")
    
    -- Enemy attacks
    local enemy_dmg = parse_damage(enemy.damage)
    hit, critical = attack_roll(enemy, player, enemy.name, player.name)
    if hit then
        local damage = damage_roll(enemy_dmg, critical)
        local player_dead = apply_damage(player, damage, player.name)
        if player_dead then
            return "player_dead"
        end
    end
    
    return "continue"
end

local function run_combat(player, enemy)
    print("\n" .. string.rep("═", 50))
    print("⚔️  COMBAT INITIATED!")
    print(string.rep("═", 50))
    print(string.format("%s (HP: %d, AC: %d) vs %s (HP: %d, AC: %d)",
        player.name, player.hp, player.ac,
        enemy.name, enemy.hp, enemy.ac))
    
    local round = 1
    while true do
        local result = combat_round(player, enemy, round)
        
        if result == "player_win" then
            print("\n" .. string.rep("═", 50))
            print("🎉 VICTORY!")
            print(string.rep("═", 50))
            print(string.format("You defeated %s and gained %d XP!", enemy.name, enemy.xp))
            return "victory", enemy.xp
        elseif result == "player_dead" then
            print("\n" .. string.rep("═", 50))
            print("💀 YOU DIED!")
            print(string.rep("═", 50))
            print("Your adventure ends here...")
            return "defeat", 0
        end
        
        round = round + 1
        
        if round > 20 then
            print("\n⚠️  Combat lasted too long! Stalemate.")
            return "flee", 0
        end
    end
end

-- Command line interface
math.randomseed(os.time())

if arg[1] == "fight" and arg[2] and arg[3] then
    -- lua combat.lua fight character_bimbo.md goblin
    local char = load_character(arg[2])
    local enemy_type = arg[3]
    local enemy_level = tonumber(arg[4]) or 1
    
    local enemy = create_enemy(nil, enemy_level, enemy_type)
    run_combat(char, enemy)
    
elseif arg[1] == "test" then
    -- Test combat with default values
    local player = {
        name = "Test Hero",
        hp = 20,
        max_hp = 20,
        ac = 12,
        attack_bonus = 2,
        damage_dice = {count = 1, sides = 6, bonus = 0}
    }
    local enemy = create_enemy("Goblin Scout", 1, "goblin")
    run_combat(player, enemy)
    
else
    print("Combat System - Dungeon Crawler")
    print("")
    print("Usage:")
    print("  Fight an enemy:")
    print("    lua combat.lua fight <character_file> <enemy_type> [enemy_level]")
    print("")
    print("  Example:")
    print("    lua combat.lua fight character_bimbo.md goblin 1")
    print("    lua combat.lua fight character_bimbo.md orc 2")
    print("")
    print("  Available enemies:")
    print("    goblin, orc, skeleton, zombie, spider, bandit, cultist,")
    print("    gargoyle, ogre, vampire, dragon")
    print("")
    print("  Test combat:")
    print("    lua combat.lua test")
end
