#!/usr/bin/env lua
-- Detailed playtest with full logging

math.randomseed(os.time())

local char = {
    hp = 30, max_hp = 30, ac = 12, attack = 2,
    potions = 3, gold = 0, xp = 0, level = 1
}

local stats = {
    attacks_made = 0, attacks_hit = 0, attacks_crit = 0,
    enemy_attacks = 0, enemy_hits = 0, enemy_crits = 0,
    damage_dealt = 0, damage_taken = 0,
    potions_used = 0, rests_taken = 0
}

print("🔬 DETAILED PLAYTEST ANALYSIS\n")

local function combat_round(enemy_name, enemy_hp, enemy_ac)
    local e_hp = enemy_hp
    local rounds = 0
    
    while e_hp > 0 and char.hp > 0 and rounds < 30 do
        rounds = rounds + 1
        
        -- Player attack
        stats.attacks_made = stats.attacks_made + 1
        local p_roll = math.random(1, 20)
        local p_total = p_roll + char.attack
        
        if p_total >= enemy_ac or p_roll == 20 then
            stats.attacks_hit = stats.attacks_hit + 1
            local dmg = math.random(1, 6)
            if p_roll == 20 then
                stats.attacks_crit = stats.attacks_crit + 1
                dmg = dmg * 2
            end
            stats.damage_dealt = stats.damage_dealt + dmg
            e_hp = e_hp - dmg
        end
        
        if e_hp <= 0 then break end
        
        -- Enemy attack
        stats.enemy_attacks = stats.enemy_attacks + 1
        local e_roll = math.random(1, 20)
        local e_total = e_roll + 4
        
        if e_total >= char.ac or e_roll == 20 then
            stats.enemy_hits = stats.enemy_hits + 1
            local dmg = math.random(1, 6)
            if e_roll == 20 then
                stats.enemy_crits = stats.enemy_crits + 1
                dmg = dmg * 2
            end
            stats.damage_taken = stats.damage_taken + dmg
            char.hp = char.hp - dmg
        end
    end
    
    return char.hp > 0
end

-- Simulate 5 fights
for fight = 1, 5 do
    print(string.format("Fight %d: Goblin (HP: 10, AC: 13)", fight))
    local victory = combat_round("Goblin", 10, 13)
    
    if victory then
        char.xp = char.xp + 75
        print(string.format("  ✓ Victory! HP: %d/%d", char.hp, char.max_hp))
    else
        print(string.format("  ☠️  Defeated! HP: %d/%d", char.hp, char.max_hp))
        break
    end
    
    -- Healing logic
    if char.hp < 15 and char.potions > 0 then
        local heal = math.random(2,4) + math.random(2,4) + 2
        char.hp = math.min(char.hp + heal, char.max_hp)
        char.potions = char.potions - 1
        stats.potions_used = stats.potions_used + 1
        print(string.format("  💊 Used potion: +%d HP (now %d/%d)", heal, char.hp, char.max_hp))
    elseif char.hp < char.max_hp - 5 then
        local heal = math.random(1,6) + math.random(1,6)
        char.hp = math.min(char.hp + heal, char.max_hp)
        stats.rests_taken = stats.rests_taken + 1
        print(string.format("  🏕️  Rested: +%d HP (now %d/%d)", heal, char.hp, char.max_hp))
    end
    
    print()
end

print(string.rep("═", 60))
print("COMBAT STATISTICS")
print(string.rep("═", 60))
print(string.format("Player Attacks: %d", stats.attacks_made))
print(string.format("  Hits: %d (%.0f%%)", stats.attacks_hit, (stats.attacks_hit/stats.attacks_made)*100))
print(string.format("  Crits: %d (%.0f%%)", stats.attacks_crit, (stats.attacks_crit/stats.attacks_made)*100))
print(string.format("  Damage Dealt: %d (avg %.1f/hit)", stats.damage_dealt, stats.damage_dealt/math.max(1,stats.attacks_hit)))

print(string.format("\nEnemy Attacks: %d", stats.enemy_attacks))
print(string.format("  Hits: %d (%.0f%%)", stats.enemy_hits, (stats.enemy_hits/stats.enemy_attacks)*100))
print(string.format("  Crits: %d (%.0f%%)", stats.enemy_crits, (stats.enemy_crits/stats.enemy_attacks)*100))
print(string.format("  Damage Taken: %d (avg %.1f/hit)", stats.damage_taken, stats.damage_taken/math.max(1,stats.enemy_hits)))

print(string.format("\nResources Used:"))
print(string.format("  Potions: %d / 3", stats.potions_used))
print(string.format("  Rests: %d", stats.rests_taken))

print(string.format("\nFinal HP: %d / %d (%.0f%%)", char.hp, char.max_hp, (char.hp/char.max_hp)*100))
print(string.format("Status: %s", char.hp > 0 and "✅ ALIVE" or "☠️  DEAD"))
print(string.rep("═", 60))
