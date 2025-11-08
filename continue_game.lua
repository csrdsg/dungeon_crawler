#!/usr/bin/env lua

-- Load all game modules
dofile("dice.lua")
dofile("dungeon_generator.lua")
dofile("encounter_gen.lua")
dofile("combat.lua")
dofile("inventory.lua")
dofile("rest.lua")
dofile("traps.lua")
dofile("effects.lua")
dofile("progression.lua")

-- Load Bimbo's character
local player = {
    name = "Bimbo",
    class = "Rogue",
    level = 1,
    hp = 30,
    max_hp = 30,
    mp = 25,
    max_mp = 25,
    ac = 14,
    str = 10,
    dex = 12,
    con = 5,
    int = 10,
    wis = 11,
    cha = 14,
    attack_bonus = 3,
    damage_dice = "1d6+2",
    gold = 142,
    inventory = {
        weapons = {"Shortsword", "Dagger", "Throwing Knives x4"},
        armor = {"Leather Armor", "Hooded Cloak"},
        items = {
            "Thieves' Tools",
            "Lockpicks",
            "Rope (50 ft)",
            "Torch x5",
            "Rations x5",
            "Waterskin",
            "Healing Potion x3",
            "Small Steel Mirror",
            "Chalk x10",
            "Backpack",
            "Crowbar",
            "Silver Key",
            "Scroll of Light",
            "Scroll of Protection from Constructs"
        }
    },
    skills = {
        stealth = 1,
        lockpicking = 1,
        trap_detection = 1
    },
    position = 6
}

-- Load dungeon
print("🗺️  LOADING SAVED GAME: BIMBO'S QUEST")
print(string.rep("═", 70))

local dungeon = load_dungeon("bimbo_quest.txt")
if not dungeon then
    print("❌ ERROR: Could not load save file!")
    return
end

print("\n✅ SAVE LOADED!")
print(string.rep("-", 70))
print(string.format("Character: %s the %s (Level %d)", player.name, player.class, player.level))
print(string.format("HP: %d/%d | AC: %d | Gold: %d gp", player.hp, player.max_hp, player.ac, player.gold))
print(string.format("Location: Chamber %d (%s)", player.position, get_chamber_type_name(dungeon.chambers[player.position].type)))
print(string.rep("-", 70))

-- Show quest status
print("\n🎯 ACTIVE QUESTS:")
print("  • Free Captain Theron's Spirit (Defeat Iron Sentinel in Chamber 7)")
print("  • Unlock the vault in Chamber 8 (Silver Key acquired!)")
print("  • Explore remaining chambers (7/10 explored)")

-- Show known intel
print("\n📜 KNOWN INTELLIGENCE:")
print("  ⚠️  Chamber 4: 'Dark things dwell there' (warning from spirit)")
print("  ⚔️  Chamber 7 (Armory): Iron Sentinel patrols - DANGEROUS")
print("  🔑 Chamber 8 (Library): Treasure vault - Silver Key needed")

-- Print map
print("\n🗺️  DUNGEON MAP:")
print(string.rep("═", 70))
print_dungeon_map(dungeon, player.position)

-- Show available actions
print("\n⚡ WHAT WOULD YOU LIKE TO DO?")
print(string.rep("-", 70))

-- Get connections from current chamber
local current = dungeon.chambers[player.position]
print("\n📍 Current Location: Chamber " .. player.position)
print("Available exits:")
if current.connections and #current.connections > 0 then
    for _, conn in ipairs(current.connections) do
        local dest = dungeon.chambers[conn]
        local visited = dest.visited and "✓" or "?"
        local type_name = get_chamber_type_name(dest.type)
        print(string.format("  → Chamber %d (%s) %s", conn, type_name, visited))
    end
else
    print("  ⚠️  No exits! Dead end.")
end

print("\nActions:")
print("  [1-10] - Move to connected chamber")
print("  [inv]  - View inventory")
print("  [rest] - Short rest (1d6+1 HP, 50% encounter chance)")
print("  [search] - Search current room")
print("  [status] - View character status")
print("  [map] - View full dungeon map")
print("  [save] - Save game")
print("  [quit] - Exit game")
print(string.rep("═", 70))
print("\n💡 Ready for your command!")
