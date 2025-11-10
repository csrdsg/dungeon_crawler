-- Character Class Templates
-- Different starting characters with unique stats and abilities

return {
    warrior = {
        name = "Warrior",
        description = "Strong fighter with high HP and melee prowess",
        hp = 40,
        max_hp = 40,
        mana = 10,
        max_mana = 10,
        ac = 16,  -- Heavy armor
        attack_bonus = 5,
        damage = "1d8+3",
        gold = 50,
        potions = 2,
        spells = {},  -- No magic
        items = {"Iron Sword", "Steel Shield"},
        icon = "⚔️"
    },
    
    mage = {
        name = "Mage",
        description = "Powerful spellcaster with high mana",
        hp = 25,
        max_hp = 25,
        mana = 40,
        max_mana = 40,
        ac = 12,  -- Robes only
        attack_bonus = 2,
        damage = "1d4+1",
        gold = 75,
        potions = 3,
        spells = {"magic_missile", "fireball", "heal", "shield"},
        items = {"Wooden Staff", "Spellbook"},
        icon = "🔮"
    },
    
    rogue = {
        name = "Rogue",
        description = "Agile thief with high gold and critical strikes",
        hp = 30,
        max_hp = 30,
        mana = 15,
        max_mana = 15,
        ac = 14,  -- Light armor
        attack_bonus = 4,
        damage = "1d6+2",
        gold = 150,  -- Starts rich!
        potions = 4,
        spells = {},  -- No magic
        items = {"Dagger", "Lockpicks", "Thieves' Tools"},
        icon = "🗡️"
    },
    
    cleric = {
        name = "Cleric",
        description = "Holy warrior with healing magic and decent armor",
        hp = 35,
        max_hp = 35,
        mana = 25,
        max_mana = 25,
        ac = 15,  -- Medium armor
        attack_bonus = 3,
        damage = "1d6+2",
        gold = 60,
        potions = 5,
        spells = {"heal", "cure_wounds", "bless"},
        items = {"Mace", "Holy Symbol", "Prayer Book"},
        icon = "✨"
    },
    
    ranger = {
        name = "Ranger",
        description = "Wilderness expert with balanced combat and survival",
        hp = 32,
        max_hp = 32,
        mana = 18,
        max_mana = 18,
        ac = 14,  -- Leather armor
        attack_bonus = 4,
        damage = "1d8+2",
        gold = 70,
        potions = 3,
        spells = {"detect_magic", "cure_wounds"},
        items = {"Longbow", "Arrows (20)", "Survival Kit"},
        icon = "🏹"
    },
    
    paladin = {
        name = "Paladin",
        description = "Holy knight with strong defense and divine magic",
        hp = 38,
        max_hp = 38,
        mana = 20,
        max_mana = 20,
        ac = 17,  -- Plate armor
        attack_bonus = 4,
        damage = "1d8+3",
        gold = 50,
        potions = 3,
        spells = {"heal", "bless", "smite"},
        items = {"Longsword", "Shield", "Holy Symbol"},
        icon = "🛡️"
    }
}
