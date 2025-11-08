-- balance_test_tracked.lua - Balance testing with database tracking
math.randomseed(os.time())
package.path = package.path .. ";../src/?.lua"
for i=1,10 do math.random() end -- Warm up RNG

local stats_db = require('stats_db')

-- Test configurations
local configs = {
    {name = "Warrior", class = "Fighter", hp = 40, ac = 16, atk = 4, dmg = 3, potions = 2},
    {name = "Rogue", class = "Rogue", hp = 30, ac = 14, atk = 3, dmg = 2, potions = 3},
    {name = "Tank", class = "Fighter", hp = 50, ac = 18, atk = 3, dmg = 2, potions = 3},
    {name = "Glass Cannon", class = "Barbarian", hp = 25, ac = 12, atk = 5, dmg = 4, potions = 2},
}

-- Enemy templates (HP, attack_bonus, AC, damage_bonus)
local enemies = {
    {name = "Goblin", hp = 10, atk = 2, ac = 12, dmg = 1, xp = 50},
    {name = "Bandit", hp = 16, atk = 3, ac = 12, dmg = 2, xp = 75},
    {name = "Skeleton", hp = 18, atk = 2, ac = 12, dmg = 1, xp = 100},
    {name = "Orc", hp = 22, atk = 4, ac = 13, dmg = 2, xp = 150},
}

-- Chamber types
local chamber_types = {"empty", "monster_lair", "trap_room", "treasure", "puzzle"}

-- Simulate combat
local function simulate_combat(char, enemy)
    local e_hp = enemy.hp
    local c_hp = char.hp
    local rounds = 0
    local dmg_dealt = 0
    local dmg_taken = 0
    local crits = 0
    
    while e_hp > 0 and c_hp > 0 and rounds < 50 do
        rounds = rounds + 1
        
        -- Character attacks
        local attack_roll = math.random(1, 20)
        if attack_roll == 20 then
            crits = crits + 1
            local dmg = (math.random(1, 6) + char.dmg) * 2
            e_hp = e_hp - dmg
            dmg_dealt = dmg_dealt + dmg
        elseif attack_roll + char.atk >= enemy.ac then
            local dmg = math.random(1, 6) + char.dmg
            e_hp = e_hp - dmg
            dmg_dealt = dmg_dealt + dmg
        end
        
        if e_hp <= 0 then break end
        
        -- Enemy attacks
        local enemy_attack = math.random(1, 20)
        if enemy_attack == 20 then
            local dmg = (math.random(1, 6) + enemy.dmg) * 2
            c_hp = c_hp - dmg
            dmg_taken = dmg_taken + dmg
        elseif enemy_attack + enemy.atk >= char.ac then
            local dmg = math.random(1, 6) + enemy.dmg
            c_hp = c_hp - dmg
            dmg_taken = dmg_taken + dmg
        end
    end
    
    local result = e_hp <= 0 and "victory" or "defeat"
    return result, rounds, dmg_dealt, dmg_taken, c_hp, crits
end

-- Run playthrough
local function run_playthrough(config, difficulty)
    local playthrough_id = stats_db.start_playthrough(config.name, config.class, difficulty)
    
    local char = {
        hp = config.hp,
        max_hp = config.hp,
        ac = config.ac,
        atk = config.atk,
        dmg = config.dmg,
        potions = config.potions,
        level = 1,
        str = 12, dex = 12, con = 12, int = 10, wis = 10, cha = 10
    }
    
    stats_db.record_stats(playthrough_id, char)
    
    local chambers_explored = 0
    local enemies_defeated = 0
    local gold_collected = 0
    local xp_gained = 0
    local potions_used = 0
    local traps_triggered = 0
    local deaths = 0
    
    for chamber = 1, 10 do
        chambers_explored = chambers_explored + 1
        local chamber_type = chamber_types[math.random(#chamber_types)]
        local hp_before = char.hp
        
        -- 60% chance of enemy encounter
        if math.random(100) <= 60 then
            local enemy = enemies[math.random(#enemies)]
            local result, rounds, dmg_dealt, dmg_taken, hp_after, crits = simulate_combat(char, enemy)
            
            char.hp = hp_after
            
            stats_db.record_combat(playthrough_id, chamber, enemy.name, enemy.hp, 
                                  rounds, dmg_dealt, dmg_taken, result, crits)
            
            if result == "victory" then
                enemies_defeated = enemies_defeated + 1
                xp_gained = xp_gained + enemy.xp
                gold_collected = gold_collected + math.random(5, 20)
            else
                deaths = deaths + 1
                break
            end
        end
        
        -- Use potion if needed
        if char.hp < char.max_hp * 0.3 and char.potions > 0 then
            char.hp = math.min(char.hp + math.random(2, 8), char.max_hp)
            char.potions = char.potions - 1
            potions_used = potions_used + 1
        end
        
        -- Random rest
        if char.hp < char.max_hp * 0.7 and math.random(100) <= 40 then
            char.hp = math.min(char.hp + math.random(2, 7), char.max_hp)
        end
        
        stats_db.record_chamber(playthrough_id, chamber, chamber_type, "exploration", 
                               char.hp > 0, hp_before, char.hp, "")
        
        if char.hp <= 0 then
            deaths = deaths + 1
            break
        end
    end
    
    local result = char.hp > 0 and "victory" or "defeat"
    local score = chambers_explored * 50 + enemies_defeated * 100 + gold_collected
    
    local stats_table = {
        chambers = chambers_explored,
        enemies = enemies_defeated,
        gold = gold_collected,
        xp = xp_gained,
        potions_used = potions_used,
        traps = traps_triggered,
        deaths = deaths,
        score = score
    }
    
    stats_db.end_playthrough(playthrough_id, result, char, stats_table)
    
    return result, chambers_explored, enemies_defeated, score
end

-- Main test runner
print("🎮 BALANCE TEST WITH DATABASE TRACKING")
print(string.rep("=", 70))

local runs_per_config = 25
local difficulty = "normal"

for _, config in ipairs(configs) do
    print(string.format("\n🧪 Testing: %s (%s) - HP:%d AC:%d ATK:+%d DMG:+%d",
          config.name, config.class, config.hp, config.ac, config.atk, config.dmg))
    print(string.rep("-", 70))
    
    local victories = 0
    local total_chambers = 0
    local total_enemies = 0
    local total_score = 0
    
    for run = 1, runs_per_config do
        local result, chambers, enemies, score = run_playthrough(config, difficulty)
        
        if result == "victory" then
            victories = victories + 1
        end
        total_chambers = total_chambers + chambers
        total_enemies = total_enemies + enemies
        total_score = total_score + score
        
        -- Progress indicator
        if run % 5 == 0 then
            io.write(string.format("  Run %d/%d: Win rate: %.1f%%\r", 
                     run, runs_per_config, victories/run*100))
            io.flush()
        end
    end
    
    print(string.format("\n  ✅ Win Rate: %d/%d (%.1f%%)", victories, runs_per_config, victories/runs_per_config*100))
    print(string.format("  📊 Avg Chambers: %.1f | Avg Enemies: %.1f | Avg Score: %.0f",
          total_chambers/runs_per_config, total_enemies/runs_per_config, total_score/runs_per_config))
    
    -- Record balance metric
    stats_db.record_metric(config.name .. "_winrate", victories/runs_per_config*100, "balance_test")
end

print("\n" .. string.rep("=", 70))
print("📊 GENERATING COMPREHENSIVE REPORT...")
print(string.rep("=", 70))

stats_db.generate_report()

print("\n💡 TIP: Use 'lua stats_db.lua report' to view stats anytime")
print("💡 TIP: Use 'lua stats_db.lua export data.csv' to export for analysis")
