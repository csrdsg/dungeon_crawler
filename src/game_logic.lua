-- Game Logic Module
-- Core game logic separated from UI

local GameLogic = {}

-- Chamber type names
local CHAMBER_TYPES = {
    "Empty Room", "Treasure Room", "Monster Lair", "Trap Room",
    "Puzzle Room", "Prison Cells", "Armory", "Library",
    "Throne Room", "Boss Chamber"
}

-- Initialize RNG
math.randomseed(os.time())
for i = 1, 10 do math.random() end

-- Dice rolling utility
function GameLogic.roll(dice_str)
    local num, sides, bonus = dice_str:match("(%d*)d(%d+)([%+%-]?%d*)")
    num = tonumber(num) or 1
    sides = tonumber(sides)
    bonus = tonumber(bonus) or 0
    
    local total = bonus
    for i = 1, num do
        total = total + math.random(1, sides)
    end
    return total
end

-- Get chamber type name
function GameLogic.get_chamber_type_name(type_id)
    return CHAMBER_TYPES[type_id] or "Unknown"
end

-- Create new player from class data
function GameLogic.create_player(class_id, CharacterClasses)
    if not CharacterClasses or not CharacterClasses[class_id] then
        return nil
    end
    
    local class_data = CharacterClasses[class_id]
    
    local player = {
        name = class_data.name,
        class = class_id,
        hp = class_data.hp,
        max_hp = class_data.max_hp,
        mana = class_data.mana,
        max_mana = class_data.max_mana,
        ac = class_data.ac,
        attack_bonus = class_data.attack_bonus,
        damage = class_data.damage,
        gold = class_data.gold,
        potions = class_data.potions,
        items = {},
        spells = {}
    }
    
    -- Copy items
    for _, item in ipairs(class_data.items) do
        table.insert(player.items, item)
    end
    
    -- Copy spells
    for _, spell in ipairs(class_data.spells) do
        table.insert(player.spells, spell)
    end
    
    return player
end

-- Generate dungeon
function GameLogic.generate_dungeon(num_chambers)
    local dungeon = {
        player_position = 1,
        num_chambers = num_chambers,
        chambers = {}
    }
    
    -- Generate chambers
    for i = 1, num_chambers do
        dungeon.chambers[i] = {
            id = i,
            type = math.random(1, 10),
            visited = (i == 1),
            connections = {}
        }
    end
    
    -- Connect chambers
    for i = 1, num_chambers do
        -- Main path
        if i < num_chambers then
            table.insert(dungeon.chambers[i].connections, i + 1)
            table.insert(dungeon.chambers[i + 1].connections, i)
        end
        
        -- Random branches
        if math.random(1, 100) <= 30 and i < num_chambers - 1 then
            local target = math.min(num_chambers, i + math.random(2, 4))
            if target ~= i and not GameLogic.has_connection(dungeon, i, target) then
                table.insert(dungeon.chambers[i].connections, target)
                table.insert(dungeon.chambers[target].connections, i)
            end
        end
    end
    
    return dungeon
end

-- Check if connection exists
function GameLogic.has_connection(dungeon, chamber_id, target_id)
    local chamber = dungeon.chambers[chamber_id]
    for _, conn in ipairs(chamber.connections) do
        if conn == target_id then
            return true
        end
    end
    return false
end

-- Create enemy
function GameLogic.create_enemy(dungeon_position, EncounterData, EnemyStats)
    if not EncounterData or not EncounterData.hostile_encounters then
        return {
            name = "Goblin",
            hp = 10,
            max_hp = 10,
            ac = 12,
            attack = 3,
            damage = "1d6+1",
            xp = 50
        }
    end
    
    local dungeon_level = math.min(10, math.floor(dungeon_position / 2) + 1)
    
    -- Filter enemies by level
    local valid_enemies = {}
    for _, encounter in ipairs(EncounterData.hostile_encounters) do
        if encounter.min_dungeon_level and encounter.min_dungeon_level <= dungeon_level then
            table.insert(valid_enemies, encounter)
        end
    end
    
    if #valid_enemies == 0 then
        valid_enemies = EncounterData.hostile_encounters
    end
    
    local encounter = valid_enemies[math.random(#valid_enemies)]
    
    if not EnemyStats or not EnemyStats[encounter.type] then
        return {
            name = encounter.name,
            hp = 10,
            max_hp = 10,
            ac = 12,
            attack = 3,
            damage = "1d6",
            xp = 50
        }
    end
    
    local stats = EnemyStats[encounter.type]
    
    return {
        name = encounter.name,
        type = encounter.type,
        hp = stats.hp + (dungeon_level * 2),
        max_hp = stats.hp + (dungeon_level * 2),
        ac = stats.ac,
        attack = stats.attack,
        damage = stats.damage,
        xp = stats.xp
    }
end

-- Generate loot
function GameLogic.generate_loot(chamber_type, enemy_defeated, LootData)
    if not LootData then
        return {
            gold = math.random(10, 50),
            items = {}
        }
    end
    
    local quality = "common"
    local chamber_quality_map = LootData.chamber_loot_quality
    
    if chamber_quality_map and chamber_quality_map[chamber_type] then
        local qualities = chamber_quality_map[chamber_type]
        quality = qualities[math.random(#qualities)]
    elseif chamber_type == 2 then
        quality = "uncommon"
    elseif chamber_type == 7 then
        quality = "uncommon"
    end
    
    -- Upgrade quality if enemy defeated
    if enemy_defeated then
        if quality == "poor" then quality = "common"
        elseif quality == "common" then quality = "uncommon" end
    end
    
    local loot = {gold = 0, items = {}}
    
    if LootData.treasure_tables and LootData.treasure_tables[quality] then
        local table_data = LootData.treasure_tables[quality]
        if table_data.gold then
            loot.gold = math.random(table_data.gold.min, table_data.gold.max)
        end
        
        if table_data.items then
            local item_count = quality == "common" and 1 or (quality == "uncommon" and 2 or 1)
            for i = 1, math.min(item_count, #table_data.items) do
                local item = table_data.items[math.random(#table_data.items)]
                table.insert(loot.items, item)
            end
        end
    else
        loot.gold = math.random(10, 50)
    end
    
    return loot
end

-- Search chamber
function GameLogic.search_chamber(chamber, player)
    if chamber.searched then
        return "already_searched", nil
    end
    
    chamber.searched = true
    chamber.search_results = {}
    
    local search_chances = {
        [1] = 20, [2] = 80, [3] = 30, [4] = 40, [5] = 60,
        [6] = 50, [7] = 70, [8] = 70, [9] = 60, [10] = 90
    }
    
    local chance = search_chances[chamber.type] or 30
    
    if math.random(1, 100) <= chance then
        local finds = {
            "Hidden gold stash",
            "Health Potion",
            "Ancient scroll",
            "Secret passage clue",
            "Mysterious key",
            "Rare gem",
            "Old map fragment",
            "Magic ring"
        }
        
        local find = finds[math.random(#finds)]
        table.insert(chamber.search_results, find)
        
        -- Give reward
        if find == "Hidden gold stash" then
            local gold = math.random(20, 100)
            player.gold = player.gold + gold
            return "found", {type = "gold", amount = gold, name = find}
        elseif find == "Health Potion" then
            player.potions = player.potions + 1
            return "found", {type = "potion", name = find}
        else
            table.insert(player.items, find)
            return "found", {type = "item", name = find}
        end
    else
        table.insert(chamber.search_results, "Nothing of value")
        return "nothing", nil
    end
end

-- Rest
function GameLogic.rest(player, TUIConfig)
    local heal_formula = TUIConfig and TUIConfig.healing and TUIConfig.healing.rest or "1d6+2"
    local heal = GameLogic.roll(heal_formula)
    player.hp = math.min(player.max_hp, player.hp + heal)
    
    local encounter_chance = TUIConfig and TUIConfig.rest_encounter_chance or 30
    local has_encounter = math.random(1, 100) <= encounter_chance
    
    return heal, has_encounter
end

-- Use potion
function GameLogic.use_potion(player, TUIConfig)
    if player.potions <= 0 then
        return 0, false
    end
    
    local heal_formula = TUIConfig and TUIConfig.healing and TUIConfig.healing.potion or "2d4+2"
    local heal = GameLogic.roll(heal_formula)
    player.hp = math.min(player.max_hp, player.hp + heal)
    player.potions = player.potions - 1
    
    return heal, true
end

-- Combat: Player attack
function GameLogic.player_attack(player, enemy)
    local attack_roll = math.random(1, 20) + player.attack_bonus
    
    if attack_roll >= enemy.ac then
        local damage = GameLogic.roll(player.damage)
        enemy.hp = enemy.hp - damage
        return true, damage, enemy.hp <= 0
    else
        return false, 0, false
    end
end

-- Combat: Enemy attack
function GameLogic.enemy_attack(enemy, player)
    local attack_bonus = enemy.attack or enemy.attack_bonus or 3
    local attack_roll = math.random(1, 20) + attack_bonus
    
    if attack_roll >= player.ac then
        local damage = GameLogic.roll(enemy.damage or "1d6")
        player.hp = player.hp - damage
        return true, damage, player.hp <= 0
    else
        return false, 0, false
    end
end

-- Cast spell
function GameLogic.cast_spell(spell_id, player, enemy, SpellData)
    if not SpellData or not SpellData[spell_id] then
        return false, "unknown_spell"
    end
    
    local spell = SpellData[spell_id]
    
    if not player.mana or player.mana < spell.mana_cost then
        return false, "no_mana"
    end
    
    player.mana = player.mana - spell.mana_cost
    
    if spell.damage then
        local damage = GameLogic.roll(spell.damage)
        enemy.hp = enemy.hp - damage
        return true, "damage", damage, enemy.hp <= 0
    elseif spell.name == "Heal" then
        local heal = GameLogic.roll(spell.healing or "2d4+2")
        player.hp = math.min(player.max_hp, player.hp + heal)
        return true, "heal", heal, false
    elseif spell.ac_bonus then
        player.ac = player.ac + spell.ac_bonus
        return true, "buff", spell.ac_bonus, false
    end
    
    return false, "unknown_effect"
end

return GameLogic
