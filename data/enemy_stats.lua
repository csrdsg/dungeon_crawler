-- Enemy Stats Data
-- Base stats for different enemy types

return {
    goblin = {
        hp = 8,
        ac = 12,
        attack = 3,
        damage = "1d6+1",
        xp = 75
    },
    orc = {
        hp = 18,
        ac = 13,
        attack = 4,
        damage = "1d8+1",
        xp = 125
    },
    skeleton = {
        hp = 14,
        ac = 12,
        attack = 3,
        damage = "1d6+2",
        xp = 75
    },
    zombie = {
        hp = 20,
        ac = 9,
        attack = 3,
        damage = "1d6+1",
        xp = 75
    },
    spider = {
        hp = 22,
        ac = 14,
        attack = 4,
        damage = "1d8+1",
        xp = 125
    },
    bandit = {
        hp = 13,
        ac = 12,
        attack = 3,
        damage = "1d6+1",
        xp = 100
    },
    cultist = {
        hp = 11,
        ac = 12,
        attack = 3,
        damage = "1d4+2",
        xp = 75
    },
    gargoyle = {
        hp = 55,
        ac = 15,
        attack = 5,
        damage = "1d10+2",
        xp = 200
    },
    ogre = {
        hp = 65,
        ac = 13,
        attack = 6,
        damage = "2d8+3",
        xp = 450
    },
    vampire = {
        hp = 85,
        ac = 16,
        attack = 8,
        damage = "1d10+3",
        xp = 2300
    },
    dragon = {
        hp = 140,
        ac = 18,
        attack = 10,
        damage = "2d10+5",
        xp = 5000
    }
}
