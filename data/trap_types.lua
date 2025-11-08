-- Trap types data
-- Separated from game logic for easy modding and balance changes

return {
    {name = "Poison Dart Trap", damage = "2d6", dc = 12, type = "dex"},
    {name = "Pit Trap", damage = "3d6", dc = 13, type = "dex"},
    {name = "Arrow Trap", damage = "1d8+2", dc = 11, type = "dex"},
    {name = "Flame Jet", damage = "2d8", dc = 14, type = "dex"},
    {name = "Crushing Wall", damage = "4d6", dc = 15, type = "str"},
    {name = "Magic Rune", damage = "3d8", dc = 16, type = "int"},
    {name = "Spike Trap", damage = "2d10", dc = 13, type = "dex"},
    {name = "Gas Trap", damage = "3d6", dc = 12, type = "con"},
    {name = "Electric Floor", damage = "4d4", dc = 14, type = "dex"},
    {name = "Falling Rocks", damage = "5d6", dc = 15, type = "dex"}
}
