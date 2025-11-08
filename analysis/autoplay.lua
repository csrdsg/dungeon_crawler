#!/usr/bin/env lua
-- Auto-Play Mode - Automated dungeon run

math.randomseed(os.time())

print("🎮 AUTO-PLAY MODE - Simulating dungeon run...")
print(string.rep("═", 60))

local chambers_explored = 0
local enemies_defeated = 0
local treasure_found = 0
local damage_taken = 0
local hp = 30
local max_hp = 30

for chamber = 1, 10 do
    print(string.format("\n�� Chamber %d", chamber))
    chambers_explored = chambers_explored + 1
    
    -- Random encounter (50% chance)
    if math.random(1, 100) <= 50 then
        local enemy_hp = math.random(5, 15)
        print(string.format("   ⚔️  Combat! Enemy HP: %d", enemy_hp))
        
        while enemy_hp > 0 and hp > 0 do
            -- Player attack
            local player_dmg = math.random(1, 6)
            enemy_hp = enemy_hp - player_dmg
            
            if enemy_hp > 0 then
                -- Enemy attack
                local enemy_dmg = math.random(1, 6)
                hp = hp - enemy_dmg
                damage_taken = damage_taken + enemy_dmg
            end
        end
        
        if hp > 0 then
            print("   ✓ Victory!")
            enemies_defeated = enemies_defeated + 1
            
            -- Loot
            local gold = math.random(10, 50)
            treasure_found = treasure_found + gold
            print(string.format("   💰 Found %d gold", gold))
        else
            print("   ☠️  Defeated!")
            break
        end
    else
        print("   · No encounter")
    end
    
    -- Rest if low HP
    if hp < max_hp / 2 and math.random() < 0.5 then
        local heal = math.random(2, 12)
        hp = math.min(hp + heal, max_hp)
        print(string.format("   🏕️  Rested, healed %d HP", heal))
    end
end

print("\n" .. string.rep("═", 60))
print("📊 RUN SUMMARY")
print(string.rep("═", 60))
print(string.format("Chambers Explored: %d", chambers_explored))
print(string.format("Enemies Defeated: %d", enemies_defeated))
print(string.format("Treasure Found: %d gp", treasure_found))
print(string.format("Damage Taken: %d", damage_taken))
print(string.format("Final HP: %d / %d", hp, max_hp))
print(string.format("Status: %s", hp > 0 and "✓ SURVIVED" or "☠️  DIED"))
print(string.rep("═", 60))
