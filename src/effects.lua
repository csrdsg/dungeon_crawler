#!/usr/bin/env lua
-- Status Effects System

local effects = {
    poison = {name = "Poisoned", damage = "1d4", duration = 3, desc = "Taking poison damage each turn"},
    bleeding = {name = "Bleeding", damage = "1d6", duration = 2, desc = "Losing blood"},
    stunned = {name = "Stunned", damage = "0", duration = 1, desc = "Cannot act next turn"},
    strength = {name = "Strength Boost", damage = "0", duration = 3, desc = "+2 to attack rolls"}
}

local function apply_effect(effect_name, target)
    local effect = effects[effect_name]
    if not effect then
        print("Unknown effect: " .. effect_name)
        return
    end
    
    print(string.format("💫 %s applied to %s!", effect.name, target))
    print(string.format("   %s (Duration: %d turns)", effect.desc, effect.duration))
end

if arg[1] then
    apply_effect(arg[1], arg[2] or "target")
else
    print("Status Effects System")
    print("\nAvailable effects:")
    for name, effect in pairs(effects) do
        print(string.format("  %s - %s", name, effect.desc))
    end
end
