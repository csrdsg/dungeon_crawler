#!/usr/bin/env lua
-- balance_test_magic.lua - Balance testing with magic-using characters
package.path = package.path .. ";../src/?.lua"

local stats_db = require('stats_db')
local dice = require('dice')
local magic = require('magic')

print("╔══════════════════════════════════════════════════════════════════════╗")
print("║              BALANCE TEST - MAGIC VS NON-MAGIC CLASSES               ║")
print("╚══════════════════════════════════════════════════════════════════════╝")

-- Initialize database
stats_db.init_db()

-- Test builds
local builds = {
    {
        name = "Tank Fighter",
        class = "fighter",
        hp = 50, max_hp = 50, ac = 18, atk = 4, dmg = 3,
        mp = 0, max_mp = 0,
        str = 16, dex = 10, con = 16, int = 8, wis = 10, cha = 10,
        use_magic = false,
        abilities = {"second_wind", "power_attack"}
    },
    {
        name = "Battle Wizard",
        class = "wizard",
        hp = 30, max_hp = 30, ac = 14, atk = 2, dmg = 1,
        mp = 33, max_mp = 33,  -- INT 14
        str = 8, dex = 14, con = 12, int = 14, wis = 10, cha = 10,
        use_magic = true,
        spells = {"magic_missile", "shield", "fireball"}
    },
    {
        name = "War Cleric",
        class = "cleric",
        hp = 40, max_hp = 40, ac = 16, atk = 3, dmg = 2,
        mp = 25, max_mp = 25,  -- INT 10
        str = 14, dex = 10, con = 14, int = 10, wis = 14, cha = 12,
        use_magic = true,
        spells = {"cure_wounds", "bless", "holy_smite"}
    },
    {
        name = "Sneaky Rogue",
        class = "rogue",
        hp = 30, max_hp = 30, ac = 15, atk = 4, dmg = 2,
        mp = 0, max_mp = 0,
        str = 10, dex = 16, con = 12, int = 10, wis = 10, cha = 12,
        use_magic = false,
        abilities = {"sneak_attack"}
    }
}

-- Enemy templates
local enemies = {
    {name = "Goblin", hp = 10, ac = 12, atk = 2, dmg = 1, xp = 50},
    {name = "Skeleton", hp = 18, ac = 12, atk = 2, dmg = 1, xp = 75, undead = true},
    {name = "Bandit", hp = 16, ac = 13, atk = 3, dmg = 2, xp = 100},
    {name = "Orc", hp = 22, ac = 14, atk = 4, dmg = 2, xp = 150}
}

-- Combat simulation
local function simulate_combat(char, enemy)
    local char_hp = char.hp
    local char_mp = char.mp
    local enemy_hp = enemy.hp
    local rounds = 0
    local damage_dealt = 0
    local damage_taken = 0
    local spells_cast = 0
    local abilities_used = 0
    
    -- Pre-combat buffs
    if char.use_magic then
        -- Wizard casts shield
        if char.class == "wizard" and char_mp >= 2 then
            local result = magic.cast_spell({mp = char_mp, max_mp = char.max_mp}, "shield")
            if result.success then
                char.ac = char.ac + 5  -- Shield bonus
                char_mp = char_mp - 2
                spells_cast = spells_cast + 1
            end
        end
        
        -- Cleric casts bless
        if char.class == "cleric" and char_mp >= 3 then
            local result = magic.cast_spell({mp = char_mp, max_mp = char.max_mp}, "bless")
            if result.success then
                char.atk = char.atk + 2  -- Bless bonus
                char_mp = char_mp - 3
                spells_cast = spells_cast + 1
            end
        end
    end
    
    while enemy_hp > 0 and char_hp > 0 and rounds < 50 do
        rounds = rounds + 1
        
        -- Player turn
        local used_magic = false
        
        if char.use_magic and char_mp >= 3 then
            -- Magic users prefer spells
            if char.class == "wizard" then
                -- Use magic missile (never misses)
                local spell_char = {mp = char_mp, max_mp = char.max_mp}
                local result = magic.cast_spell(spell_char, "magic_missile")
                if result.success then
                    enemy_hp = enemy_hp - result.damage
                    damage_dealt = damage_dealt + result.damage
                    char_mp = spell_char.mp
                    spells_cast = spells_cast + 1
                    used_magic = true
                end
            elseif char.class == "cleric" then
                -- Use holy smite
                local spell_char = {mp = char_mp, max_mp = char.max_mp}
                local result = magic.cast_spell(spell_char, "holy_smite")
                if result.success then
                    local dmg = result.damage
                    if enemy.undead then
                        dmg = dmg + dice.roll("2d8")  -- Bonus vs undead
                    end
                    enemy_hp = enemy_hp - dmg
                    damage_dealt = damage_dealt + dmg
                    char_mp = spell_char.mp
                    spells_cast = spells_cast + 1
                    used_magic = true
                end
            end
        end
        
        -- Physical attack if no magic or out of mana
        if not used_magic then
            local attack_roll = dice.roll("d20")
            local is_crit = (attack_roll == 20)
            
            -- Sneak attack bonus for rogue
            local bonus_dmg = 0
            if char.class == "rogue" and math.random(100) <= 50 then
                bonus_dmg = dice.roll("2d6")
                abilities_used = abilities_used + 1
            end
            
            if is_crit or (attack_roll + char.atk >= enemy.ac) then
                local dmg = dice.roll("d6") + char.dmg + bonus_dmg
                if is_crit then dmg = dmg * 2 end
                enemy_hp = enemy_hp - dmg
                damage_dealt = damage_dealt + dmg
            end
        end
        
        if enemy_hp <= 0 then break end
        
        -- Enemy turn
        local attack_roll = dice.roll("d20")
        if attack_roll == 20 or (attack_roll + enemy.atk >= char.ac) then
            local dmg = dice.roll("d6") + enemy.dmg
            if attack_roll == 20 then dmg = dmg * 2 end
            char_hp = char_hp - dmg
            damage_taken = damage_taken + dmg
        end
        
        -- Emergency healing for cleric
        if char.class == "cleric" and char_hp < char.max_hp * 0.3 and char_mp >= 3 then
            local spell_char = {mp = char_mp, max_mp = char.max_mp}
            local result = magic.cast_spell(spell_char, "cure_wounds")
            if result.success then
                char_hp = math.min(char_hp + result.healing, char.max_hp)
                char_mp = spell_char.mp
                spells_cast = spells_cast + 1
            end
        end
        
        -- Second wind for fighter
        if char.class == "fighter" and char_hp < char.max_hp * 0.3 and abilities_used == 0 then
            local result = magic.use_ability({class = "fighter", level = 3}, "second_wind")
            if result.success then
                char_hp = math.min(char_hp + result.healing, char.max_hp)
                abilities_used = abilities_used + 1
            end
        end
    end
    
    return {
        victory = enemy_hp <= 0,
        rounds = rounds,
        char_hp_final = char_hp,
        damage_dealt = damage_dealt,
        damage_taken = damage_taken,
        spells_cast = spells_cast,
        abilities_used = abilities_used
    }
end

-- Run tests
local runs_per_build = 25
local total_runs = #builds * runs_per_build

print(string.format("\n🎮 Running %d playthroughs (%d builds × %d runs each)", 
    total_runs, #builds, runs_per_build))
print(string.rep("─", 70))

local results = {}

for build_idx, build in ipairs(builds) do
    print(string.format("\n[%d/%d] Testing: %s (%s)", 
        build_idx, #builds, build.name, build.class))
    
    results[build.name] = {
        victories = 0,
        total_damage = 0,
        total_rounds = 0,
        total_spells = 0,
        total_abilities = 0,
        hp_remaining = 0
    }
    
    for run = 1, runs_per_build do
        -- Start playthrough
        local playthrough_id = stats_db.start_playthrough(build.name, build.class, "balance")
        stats_db.record_stats(playthrough_id, build)
        
        -- Create character copy
        local char = {}
        for k, v in pairs(build) do char[k] = v end
        
        local chambers_cleared = 0
        local enemies_defeated = 0
        
        -- Simulate 10 chambers
        for chamber = 1, 10 do
            -- 60% chance of enemy
            if math.random(100) <= 60 and char.hp > 0 then
                local enemy_template = enemies[math.random(#enemies)]
                local enemy = {}
                for k, v in pairs(enemy_template) do enemy[k] = v end
                
                local combat = simulate_combat(char, enemy)
                
                -- Record to database
                stats_db.record_combat(playthrough_id, chamber, enemy.name,
                    enemy_template.hp, combat.rounds, combat.damage_dealt,
                    combat.damage_taken, combat.victory and "victory" or "defeat", 0)
                
                if combat.victory then
                    enemies_defeated = enemies_defeated + 1
                    results[build.name].total_damage = results[build.name].total_damage + combat.damage_dealt
                    results[build.name].total_rounds = results[build.name].total_rounds + combat.rounds
                    results[build.name].total_spells = results[build.name].total_spells + combat.spells_cast
                    results[build.name].total_abilities = results[build.name].total_abilities + combat.abilities_used
                else
                    break  -- Defeated
                end
            end
            
            if char.hp <= 0 then break end
            chambers_cleared = chambers_cleared + 1
            
            -- Rest and restore some mana
            if char.use_magic then
                char.mp = math.min(char.mp + math.floor(char.max_mp * 0.3), char.max_mp)
            end
        end
        
        -- Record result
        local victory = char.hp > 0
        if victory then
            results[build.name].victories = results[build.name].victories + 1
            results[build.name].hp_remaining = results[build.name].hp_remaining + char.hp
        end
        
        -- End playthrough
        local game_stats = {
            chambers = chambers_cleared,
            enemies = enemies_defeated,
            gold = enemies_defeated * 10,
            xp = enemies_defeated * 75,
            potions_used = 0,
            traps = 0,
            deaths = victory and 0 or 1,
            score = chambers_cleared * 50 + enemies_defeated * 100
        }
        
        stats_db.end_playthrough(playthrough_id, victory and "victory" or "defeat", char, game_stats)
        
        io.write(".")
        io.flush()
    end
    
    print(" ✓")
end

-- Display results
print("\n" .. string.rep("═", 70))
print("📊 BALANCE TEST RESULTS")
print(string.rep("═", 70))

print(string.format("\n%-20s %8s %8s %8s %8s %8s", 
    "Build", "Win %", "Avg DMG", "Avg Rnds", "Spells", "Abilities"))
print(string.rep("-", 70))

for _, build in ipairs(builds) do
    local r = results[build.name]
    local win_rate = (r.victories / runs_per_build) * 100
    local avg_damage = r.victories > 0 and (r.total_damage / r.victories) or 0
    local avg_rounds = r.victories > 0 and (r.total_rounds / r.victories) or 0
    local avg_spells = r.victories > 0 and (r.total_spells / r.victories) or 0
    local avg_abilities = r.victories > 0 and (r.total_abilities / r.victories) or 0
    
    print(string.format("%-20s %7.1f%% %8.1f %8.1f %8.1f %8.1f",
        build.name, win_rate, avg_damage, avg_rounds, avg_spells, avg_abilities))
end

print(string.rep("═", 70))

-- Get database stats
print("\n📈 DETAILED STATISTICS FROM DATABASE")
print(string.rep("─", 70))

os.execute([[sqlite3 dungeon_stats.db "
SELECT 
    character_name,
    printf('Win Rate: %.1f%%', SUM(CASE WHEN result='victory' THEN 1 ELSE 0 END)*100.0/COUNT(*)) as win_rate,
    printf('Avg Score: %.0f', AVG(score)) as avg_score,
    printf('Enemies: %.1f', AVG(enemies_defeated)) as avg_enemies
FROM playthroughs 
WHERE difficulty='balance'
GROUP BY character_name
ORDER BY SUM(CASE WHEN result='victory' THEN 1 ELSE 0 END)*100.0/COUNT(*) DESC;
"]])

print("\n🎯 KEY INSIGHTS")
print(string.rep("─", 70))

-- Calculate insights
local magic_users = {}
local non_magic = {}

for _, build in ipairs(builds) do
    local r = results[build.name]
    local win_rate = (r.victories / runs_per_build) * 100
    
    if build.use_magic then
        table.insert(magic_users, {name = build.name, win_rate = win_rate})
    else
        table.insert(non_magic, {name = build.name, win_rate = win_rate})
    end
end

local magic_avg = 0
for _, m in ipairs(magic_users) do magic_avg = magic_avg + m.win_rate end
magic_avg = magic_avg / #magic_users

local non_magic_avg = 0
for _, m in ipairs(non_magic) do non_magic_avg = non_magic_avg + m.win_rate end
non_magic_avg = non_magic_avg / #non_magic

print(string.format("Magic Users Average Win Rate:     %.1f%%", magic_avg))
print(string.format("Non-Magic Users Average Win Rate: %.1f%%", non_magic_avg))
print(string.format("Difference:                        %.1f%%", magic_avg - non_magic_avg))

print("\n💡 RECOMMENDATIONS")
print(string.rep("─", 70))

if magic_avg > non_magic_avg + 10 then
    print("⚠️  Magic users significantly outperform non-magic users")
    print("   Consider: Increase mana costs or reduce spell damage")
elseif non_magic_avg > magic_avg + 10 then
    print("⚠️  Non-magic users significantly outperform magic users")
    print("   Consider: Reduce mana costs or increase spell power")
else
    print("✅ Good balance between magic and non-magic users!")
end

print("\n" .. string.rep("═", 70))
print("💾 Full statistics saved to database: dungeon_stats.db")
print("   View with: lua quick_analysis.lua")
print(string.rep("═", 70))
