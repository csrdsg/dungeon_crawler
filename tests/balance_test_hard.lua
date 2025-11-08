#!/usr/bin/env lua
-- balance_test_hard.lua - Harder difficulty balance test
package.path = package.path .. ";../src/?.lua"

local stats_db = require('stats_db')
local dice = require('dice')
local magic = require('magic')

print("╔══════════════════════════════════════════════════════════════════════╗")
print("║           HARD MODE BALANCE TEST - CHALLENGING ENCOUNTERS           ║")
print("╚══════════════════════════════════════════════════════════════════════╝")

stats_db.init_db()

-- Test builds (same as before)
local builds = {
    {
        name = "Tank Fighter",
        class = "fighter",
        hp = 55, max_hp = 55, ac = 18, atk = 4, dmg = 3,  -- BUFFED: 50 → 55 HP
        mp = 0, max_mp = 0,
        use_magic = false
    },
    {
        name = "Battle Wizard",
        class = "wizard",
        hp = 30, max_hp = 30, ac = 14, atk = 2, dmg = 1,
        mp = 33, max_mp = 33,
        use_magic = true
    },
    {
        name = "War Cleric",
        class = "cleric",
        hp = 40, max_hp = 40, ac = 16, atk = 3, dmg = 2,
        mp = 20, max_mp = 20,  -- NERFED: 25 → 20 MP (less spell casting)
        use_magic = true
    },
    {
        name = "Sneaky Rogue",
        class = "rogue",
        hp = 42, max_hp = 42, ac = 18, atk = 6, dmg = 4,  -- FINAL BUFF: HP 40→42, AC 17→18, DMG 3→4
        mp = 0, max_mp = 0,
        use_magic = false
    }
}

-- HARDER enemies
local enemies = {
    {name = "Goblin", hp = 15, ac = 13, atk = 3, dmg = 2, xp = 50},
    {name = "Skeleton", hp = 25, ac = 14, atk = 3, dmg = 2, xp = 75, undead = true},
    {name = "Bandit", hp = 22, ac = 14, atk = 4, dmg = 2, xp = 100},
    {name = "Orc", hp = 30, ac = 15, atk = 5, dmg = 3, xp = 150},
    {name = "Ogre", hp = 40, ac = 13, atk = 6, dmg = 4, xp = 200}  -- Boss-tier
}

-- Combat (simplified version)
local function simulate_combat(char, enemy)
    local char_hp = char.hp
    local char_mp = char.mp
    local char_ac = char.ac
    local char_atk = char.atk
    local enemy_hp = enemy.hp
    local rounds = 0
    local spells_cast = 0
    local abilities_used = 0  -- Track ability uses
    local heals_used = 0  -- Track healing uses
    
    -- Pre-combat buffs
    if char.use_magic then
        if char.class == "wizard" and char_mp >= 3 then  -- Shield now costs 3
            char_ac = char_ac + 5
            char_mp = char_mp - 3
            spells_cast = spells_cast + 1
        elseif char.class == "cleric" and char_mp >= 4 then  -- Bless now costs 4
            char_atk = char_atk + 2
            char_mp = char_mp - 4
            spells_cast = spells_cast + 1
        end
    end
    
    while enemy_hp > 0 and char_hp > 0 and rounds < 50 do
        rounds = rounds + 1
        
        -- Player turn
        if char.use_magic and char_mp >= 3 then
            local dmg = 0
            if char.class == "wizard" then
                dmg = dice.roll("2d4+2")  -- Magic missile
                char_mp = char_mp - 3
                spells_cast = spells_cast + 1
            elseif char.class == "cleric" then
                dmg = dice.roll("3d8")  -- Holy smite
                if enemy.undead then dmg = dmg + dice.roll("2d8") end
                char_mp = char_mp - 5
                spells_cast = spells_cast + 1
            end
            enemy_hp = enemy_hp - dmg
        else
            -- Physical attack
            local roll = dice.roll("d20")
            if roll == 20 or (roll + char_atk >= enemy.ac) then
                local dmg = dice.roll("d6") + char.dmg
                if roll == 20 then dmg = dmg * 2 end
                if char.class == "rogue" and math.random(100) <= 50 then
                    dmg = dmg + dice.roll("2d6")  -- Sneak attack
                end
                enemy_hp = enemy_hp - dmg
            end
        end
        
        if enemy_hp <= 0 then break end
        
        -- Enemy turn
        local roll = dice.roll("d20")
        if roll == 20 or (roll + enemy.atk >= char_ac) then
            local dmg = dice.roll("d6") + enemy.dmg
            if roll == 20 then dmg = dmg * 2 end
            char_hp = char_hp - dmg
        end
        
        -- Emergency healing (cleric only) - NERFED MORE  
        if char.class == "cleric" and char_hp < 15 and char_mp >= 5 and heals_used < 1 then  -- Only once per combat
            char_hp = math.min(char_hp + dice.roll("2d4+2"), char.max_hp)  -- Nerfed healing
            char_mp = char_mp - 5  -- Increased cost
            heals_used = heals_used + 1
        end
        
        -- Second wind (fighter only) - BUFFED
        if char.class == "fighter" and char_hp < 20 and abilities_used < 2 then  -- Can use twice now
            char_hp = math.min(char_hp + dice.roll("2d10+3"), char.max_hp)  -- Buffed from 1d10+3
            abilities_used = abilities_used + 1
        end
    end
    
    return {
        victory = enemy_hp <= 0,
        rounds = rounds,
        final_hp = char_hp,
        spells_cast = spells_cast
    }
end

-- Run tests
local runs_per_build = 50  -- More runs for better statistics
print(string.format("\n🎮 Running %d playthroughs (%d builds × %d runs each)",
    #builds * runs_per_build, #builds, runs_per_build))
print(string.rep("─", 70))

local results = {}

for build_idx, build in ipairs(builds) do
    print(string.format("\n[%d/%d] Testing: %s", build_idx, #builds, build.name))
    
    results[build.name] = {
        victories = 0,
        defeats = 0,
        total_chambers = 0,
        total_enemies = 0,
        avg_hp_remaining = 0
    }
    
    for run = 1, runs_per_build do
        local playthrough_id = stats_db.start_playthrough(build.name, build.class, "hard")
        
        local char = {}
        for k, v in pairs(build) do char[k] = v end
        
        local chambers = 0
        local enemies_defeated = 0
        local game_over = false
        
        -- 10 chambers
        for chamber = 1, 10 do
            -- 70% chance of enemy (higher than normal)
            if math.random(100) <= 70 and not game_over then
                local enemy_template = enemies[math.random(#enemies)]
                local enemy = {}
                for k, v in pairs(enemy_template) do enemy[k] = v end
                
                local combat = simulate_combat(char, enemy)
                
                if combat.victory then
                    enemies_defeated = enemies_defeated + 1
                    char.hp = combat.final_hp
                else
                    game_over = true
                    results[build.name].defeats = results[build.name].defeats + 1
                end
            end
            
            if not game_over then
                chambers = chambers + 1
                
                -- Partial mana restore
                if char.use_magic then
                    char.mp = math.min(char.mp + math.floor(char.max_mp * 0.2), char.max_mp)
                end
                
                -- Small HP restore
                char.hp = math.min(char.hp + dice.roll("d6"), char.max_hp)
            else
                break
            end
        end
        
        if not game_over then
            results[build.name].victories = results[build.name].victories + 1
            results[build.name].avg_hp_remaining = results[build.name].avg_hp_remaining + char.hp
        end
        
        results[build.name].total_chambers = results[build.name].total_chambers + chambers
        results[build.name].total_enemies = results[build.name].total_enemies + enemies_defeated
        
        local game_stats = {
            chambers = chambers,
            enemies = enemies_defeated,
            gold = enemies_defeated * 15,
            xp = enemies_defeated * 100,
            potions_used = 0,
            traps = 0,
            deaths = game_over and 1 or 0,
            score = chambers * 50 + enemies_defeated * 100
        }
        
        stats_db.end_playthrough(playthrough_id, game_over and "defeat" or "victory", char, game_stats)
        
        if run % 10 == 0 then
            io.write(string.format("%d ", run))
            io.flush()
        else
            io.write(".")
            io.flush()
        end
    end
    
    print(" ✓")
end

-- Display results
print("\n" .. string.rep("═", 70))
print("📊 HARD MODE BALANCE RESULTS")
print(string.rep("═", 70))

print(string.format("\n%-20s %9s %9s %9s %9s", 
    "Build", "Win Rate", "Avg Chmb", "Avg Enemy", "Avg HP"))
print(string.rep("-", 70))

local all_builds_data = {}

for _, build in ipairs(builds) do
    local r = results[build.name]
    local win_rate = (r.victories / runs_per_build) * 100
    local avg_chambers = r.total_chambers / runs_per_build
    local avg_enemies = r.total_enemies / runs_per_build
    local avg_hp = r.victories > 0 and (r.avg_hp_remaining / r.victories) or 0
    
    table.insert(all_builds_data, {
        name = build.name,
        use_magic = build.use_magic,
        win_rate = win_rate
    })
    
    local status = ""
    if win_rate >= 60 then
        status = "✅"
    elseif win_rate >= 40 then
        status = "⚠️ "
    else
        status = "❌"
    end
    
    print(string.format("%-20s %8.1f%% %9.1f %9.1f %9.1f %s",
        build.name, win_rate, avg_chambers, avg_enemies, avg_hp, status))
end

print(string.rep("═", 70))

-- Comparison
print("\n🎯 MAGIC VS NON-MAGIC COMPARISON")
print(string.rep("─", 70))

local magic_wins = 0
local magic_count = 0
local non_magic_wins = 0
local non_magic_count = 0

for _, data in ipairs(all_builds_data) do
    if data.use_magic then
        magic_wins = magic_wins + data.win_rate
        magic_count = magic_count + 1
    else
        non_magic_wins = non_magic_wins + data.win_rate
        non_magic_count = non_magic_count + 1
    end
end

local magic_avg = magic_wins / magic_count
local non_magic_avg = non_magic_wins / non_magic_count

print(string.format("Magic Users:     %.1f%% average win rate", magic_avg))
print(string.format("Non-Magic Users: %.1f%% average win rate", non_magic_avg))
print(string.format("Difference:      %.1f%%", math.abs(magic_avg - non_magic_avg)))

print("\n💡 BALANCE ASSESSMENT")
print(string.rep("─", 70))

if math.abs(magic_avg - non_magic_avg) <= 10 then
    print("✅ Well balanced! Magic and non-magic users perform similarly.")
elseif magic_avg > non_magic_avg then
    print(string.format("⚠️  Magic users have %.1f%% advantage", magic_avg - non_magic_avg))
    print("   Consider: Increase mana costs or enemy magic resistance")
else
    print(string.format("⚠️  Non-magic users have %.1f%% advantage", non_magic_avg - magic_avg))
    print("   Consider: Reduce mana costs or buff spell damage")
end

-- Difficulty assessment
local overall_avg = (magic_avg + non_magic_avg) / 2
print(string.format("\nOverall win rate: %.1f%%", overall_avg))

if overall_avg > 70 then
    print("💡 Game is TOO EASY - Consider:")
    print("   • Increase enemy HP by 20-30%")
    print("   • Increase enemy AC by 1-2")
    print("   • Increase enemy damage")
elseif overall_avg < 30 then
    print("💡 Game is TOO HARD - Consider:")
    print("   • Decrease enemy HP by 20-30%")
    print("   • Decrease enemy AC by 1-2")
    print("   • Give players more healing opportunities")
else
    print("✅ Good difficulty! Win rate in ideal 30-70% range")
end

print("\n" .. string.rep("═", 70))
print("📈 Detailed data saved to database")
print("   Use: lua quick_analysis.lua")
print(string.rep("═", 70))
