#!/usr/bin/env lua
-- HARD MODE: Aiming for 55% win rate
package.path = package.path .. ";../src/?.lua"

math.randomseed(os.time())

print("🎮 HARD MODE PLAYTHROUGH TEST")
print(string.rep("═", 70))
print("Testing: Harder difficulty (target 55% survival)")
print(string.rep("═", 70))

-- Player stats (unchanged)
local char = {
    name = "Test Hero",
    level = 1,
    xp = 0,
    hp = 30,
    max_hp = 30,
    ac = 14,
    attack_bonus = 3,
    damage_bonus = 2,
    gold = 0,
    potions = 2,  -- HARD MODE: reduced from 3
    chambers_explored = 0,
    enemies_defeated = 0,
    traps_triggered = 0,
    treasure_rooms = 0,
    deaths = 0
}

local chamber_types = {
    "Empty room", "Treasure room", "Monster lair", "Trap room", "Puzzle room",
    "Prison cells", "Armory", "Library", "Throne room", "Boss chamber"
}

-- Enemy stats - HARD MODE
local enemies = {
    {name = "Goblin", hp = 10, ac = 12, dmg_dice = 6, dmg_bonus = 1, atk = 3, xp = 75},
    {name = "Skeleton", hp = 18, ac = 12, dmg_dice = 6, dmg_bonus = 2, atk = 3, xp = 75},
    {name = "Bandit", hp = 16, ac = 12, dmg_dice = 6, dmg_bonus = 1, atk = 3, xp = 100},
    {name = "Cultist", hp = 13, ac = 12, dmg_dice = 4, dmg_bonus = 2, atk = 3, xp = 75},
}

local function roll_dice(sides)
    return math.random(1, sides)
end

local function combat(char, enemy)
    local enemy_hp = enemy.hp
    local rounds = 0
    
    print(string.format("   ⚔️  COMBAT: %s (HP: %d, AC: %d)", enemy.name, enemy.hp, enemy.ac))
    
    while enemy_hp > 0 and char.hp > 0 and rounds < 30 do
        rounds = rounds + 1
        
        -- Player attacks
        local p_attack = roll_dice(20) + char.attack_bonus
        if p_attack >= enemy.ac then
            local p_dmg = roll_dice(6) + char.damage_bonus
            enemy_hp = enemy_hp - p_dmg
            if p_attack == 20 + char.attack_bonus then
                enemy_hp = enemy_hp - p_dmg
                print(string.format("      💥 CRIT! %d damage", p_dmg * 2))
            end
        end
        
        if enemy_hp <= 0 then break end
        
        -- Enemy attacks
        local e_attack = roll_dice(20) + enemy.atk
        if e_attack >= char.ac then
            local e_dmg = roll_dice(enemy.dmg_dice) + enemy.dmg_bonus
            char.hp = char.hp - e_dmg
            if e_attack == 20 + enemy.atk then
                char.hp = char.hp - e_dmg
                print(string.format("      ☠️  Enemy CRIT! %d damage", e_dmg * 2))
            end
        end
    end
    
    if char.hp <= 0 then
        print("      💀 DEFEATED!")
        char.deaths = char.deaths + 1
        return false
    else
        print(string.format("      ✓ Victory! (Rounds: %d, HP: %d/%d)", rounds, char.hp, char.max_hp))
        char.xp = char.xp + enemy.xp
        char.enemies_defeated = char.enemies_defeated + 1
        
        -- Level up check
        if char.xp >= char.level * 1000 then
            char.level = char.level + 1
            char.max_hp = char.max_hp + roll_dice(8) + 4
            char.hp = char.max_hp
            print(string.format("      ✨ LEVEL UP! Now level %d (Max HP: %d)", char.level, char.max_hp))
        end
        
        return true
    end
end

local function rest(char, type)
    if type == "short" then
        local heal = roll_dice(6) + 1  -- HARD MODE: 1d6+1
        char.hp = math.min(char.hp + heal, char.max_hp)
        print(string.format("      🏕️  Short rest: healed %d HP (%d/%d)", heal, char.hp, char.max_hp))
    elseif type == "long" then
        char.hp = char.max_hp
        print(string.format("      🏕️  Long rest: fully healed (%d/%d HP)", char.hp, char.max_hp))
    end
end

local function use_potion(char)
    if char.potions > 0 then
        local heal = roll_dice(4) + roll_dice(4)  -- HARD MODE: 2d4 (no +2 bonus)
        char.hp = math.min(char.hp + heal, char.max_hp)
        char.potions = char.potions - 1
        print(string.format("      💊 Used potion: healed %d HP (%d/%d, %d potions left)", 
            heal, char.hp, char.max_hp, char.potions))
        return true
    end
    return false
end

-- Run 10-chamber dungeon
print("\n📍 Starting dungeon exploration...\n")

for chamber_num = 1, 10 do
    char.chambers_explored = chamber_num
    local chamber_type = math.random(1, 10)
    
    print(string.rep("-", 70))
    print(string.format("📍 CHAMBER %d - %s", chamber_num, chamber_types[chamber_type]))
    print(string.rep("-", 70))
    
    -- HARD MODE: Increased encounter chances
    local encounter_chances = {40, 70, 95, 30, 50, 60, 60, 50, 80, 100}
    local encounter_chance = encounter_chances[chamber_type]
    
    if roll_dice(100) <= encounter_chance then
        local enemy = enemies[roll_dice(#enemies)]
        
        -- Boss chambers have 2 enemies sometimes
        local num_enemies = (chamber_type == 10 and roll_dice(100) <= 50) and 2 or 1
        
        for fight = 1, num_enemies do
            if num_enemies > 1 then
                print(string.format("   Fight %d of %d:", fight, num_enemies))
            end
            
            local victory = combat(char, enemy)
            
            if not victory then
                print("\n☠️  GAME OVER - Defeated in combat!")
                break
            end
            
            -- Heal between multiple fights
            if fight < num_enemies and char.hp < 20 then
                if char.potions > 0 then
                    use_potion(char)
                else
                    rest(char, "short")
                end
            end
        end
        
        if char.hp <= 0 then break end
        
        -- Loot
        local gold = roll_dice(20) + roll_dice(20)
        char.gold = char.gold + gold
        print(string.format("      💰 Looted %d gold", gold))
        
        if chamber_type == 2 then
            char.treasure_rooms = char.treasure_rooms + 1
            local bonus_gold = roll_dice(50) + roll_dice(50)
            char.gold = char.gold + bonus_gold
            print(string.format("      💎 Treasure room bonus: +%d gold!", bonus_gold))
        end
        
    else
        print("   · No encounter")
        
        if chamber_type == 2 then
            char.treasure_rooms = char.treasure_rooms + 1
            local gold = roll_dice(30) + roll_dice(30)
            char.gold = char.gold + gold
            print(string.format("      💰 Found treasure chest: %d gold", gold))
        end
    end
    
    -- HARD MODE: Trap damage increased
    if chamber_type == 4 and roll_dice(100) <= 70 then
        print("   ⚠️  TRAP!")
        local detect = roll_dice(20) + 3
        if detect >= 12 then
            print("      ✓ Trap detected and disarmed")
        else
            local trap_dmg = roll_dice(6) + roll_dice(6) + roll_dice(6)  -- 3d6 instead of 2d6
            char.hp = char.hp - trap_dmg
            char.traps_triggered = char.traps_triggered + 1
            print(string.format("      💥 Trap triggered! %d damage (HP: %d/%d)", trap_dmg, char.hp, char.max_hp))
            
            if char.hp <= 0 then
                print("\n☠️  GAME OVER - Killed by trap!")
                char.deaths = char.deaths + 1
                break
            end
        end
    end
    
    -- Auto-healing logic (more aggressive due to harder difficulty)
    if char.hp < char.max_hp * 0.35 then
        if char.potions > 0 then
            use_potion(char)
        else
            rest(char, "short")
        end
    elseif char.hp < char.max_hp * 0.6 and roll_dice(100) <= 50 then
        rest(char, "short")
    end
    
    -- Long rest after boss chamber
    if chamber_type == 10 and char.hp > 0 then
        rest(char, "long")
    end
end

-- Final statistics
print("\n" .. string.rep("═", 70))
print("📊 FINAL STATISTICS")
print(string.rep("═", 70))
print(string.format("Character: %s (Level %d)", char.name, char.level))
print(string.format("Final HP: %d / %d", char.hp, char.max_hp))
print(string.format("Total XP: %d", char.xp))
print(string.format("Gold Collected: %d gp", char.gold))
print(string.format("\nChambers Explored: %d / 10", char.chambers_explored))
print(string.format("Enemies Defeated: %d", char.enemies_defeated))
print(string.format("Treasure Rooms Found: %d", char.treasure_rooms))
print(string.format("Traps Triggered: %d", char.traps_triggered))
print(string.format("Potions Remaining: %d / 2", char.potions))
print(string.format("\nDeaths: %d", char.deaths))
print(string.format("Status: %s", char.hp > 0 and "✅ SURVIVED" or "☠️  DEFEATED"))

-- Performance rating
local score = 0
score = score + char.chambers_explored * 10
score = score + char.enemies_defeated * 25
score = score + char.treasure_rooms * 50
score = score + (char.hp > 0 and 200 or 0)
score = score + char.gold

print(string.format("\n🏆 Performance Score: %d", score))

if score >= 1000 then
    print("   Rating: ⭐⭐⭐ LEGENDARY!")
elseif score >= 700 then
    print("   Rating: ⭐⭐ EXCELLENT")
elseif score >= 400 then
    print("   Rating: ⭐ GOOD")
else
    print("   Rating: NEEDS IMPROVEMENT")
end

print(string.rep("═", 70))
