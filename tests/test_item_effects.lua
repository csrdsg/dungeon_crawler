#!/usr/bin/env lua
-- test_item_effects.lua - Unit tests for item effects system
package.path = package.path .. ";../src/?.lua"

local test = require('test_framework')
local item_effects = require('item_effects')

test.describe("Item Effects - Active Effects", function()
    
    test.it("should use flaming sword effect", function()
        local result = item_effects.use_item_effect("flaming_sword", {name = "Hero"}, {name = "Enemy"})
        
        test.assert_true(result.success)
        test.assert_not_nil(result.damage_bonus)
        test.assert_greater_than(result.damage_bonus, 0)
        test.assert_equal(#result.effects, 1)
    end)
    
    test.it("should use healing amulet", function()
        local result = item_effects.use_item_effect("amulet_of_healing", {name = "Hero"})
        
        test.assert_true(result.success)
        test.assert_not_nil(result.healing)
        test.assert_greater_than(result.healing, 0)
    end)
    
    test.it("should apply defense buff", function()
        local result = item_effects.use_item_effect("shield_of_valor", {name = "Hero"})
        
        test.assert_true(result.success)
        test.assert_equal(result.ac_bonus, 2)
        test.assert_equal(result.duration, 3)
    end)
    
    test.it("should fail on unknown effect", function()
        local result = item_effects.use_item_effect("nonexistent", {name = "Hero"})
        
        test.assert_false(result.success)
    end)
    
    test.it("should fail on passive effect as active", function()
        local result = item_effects.use_item_effect("vampire_blade", {name = "Hero"})
        
        test.assert_false(result.success)
    end)
    
end)

test.describe("Item Effects - Passive Effects", function()
    
    test.it("should apply vampire blade lifesteal", function()
        local result = item_effects.apply_passive_effect("vampire_blade")
        
        test.assert_not_nil(result)
        test.assert_equal(result.lifesteal_percent, 20)
    end)
    
    test.it("should apply damage reduction", function()
        local result = item_effects.apply_passive_effect("plate_of_invulnerability")
        
        test.assert_not_nil(result)
        test.assert_equal(result.damage_reduction, 2)
    end)
    
    test.it("should apply AC bonus", function()
        local result = item_effects.apply_passive_effect("ring_of_protection")
        
        test.assert_not_nil(result)
        test.assert_equal(result.ac_bonus, 2)
    end)
    
    test.it("should apply HP bonus", function()
        local result = item_effects.apply_passive_effect("amulet_of_health")
        
        test.assert_not_nil(result)
        test.assert_equal(result.hp_bonus, 8)
    end)
    
    test.it("should apply regeneration", function()
        local result = item_effects.apply_passive_effect("armor_of_regeneration")
        
        test.assert_not_nil(result)
        test.assert_not_nil(result.regen)
        test.assert_greater_than(result.regen, 0)
    end)
    
    test.it("should apply bonus vs specific type", function()
        local context = {target_type = "undead"}
        local result = item_effects.apply_passive_effect("holy_mace", context)
        
        test.assert_not_nil(result)
        test.assert_not_nil(result.bonus_damage)
        test.assert_greater_than(result.bonus_damage, 0)
    end)
    
    test.it("should not apply bonus vs wrong type", function()
        local context = {target_type = "human"}
        local result = item_effects.apply_passive_effect("holy_mace", context)
        
        test.assert_not_nil(result)
        test.assert_nil(result.bonus_damage)
    end)
    
end)

test.describe("Item Effects - Cursed Effects", function()
    
    test.it("should apply cursed sword", function()
        local result = item_effects.apply_cursed_effect("cursed_sword_of_greed")
        
        test.assert_not_nil(result)
        test.assert_not_nil(result.damage_bonus)
        test.assert_equal(result.hp_drain_per_hit, 1)
        test.assert_true(result.cannot_remove)
    end)
    
    test.it("should apply helm of madness", function()
        local result = item_effects.apply_cursed_effect("helm_of_madness")
        
        test.assert_not_nil(result)
        test.assert_equal(result.attack_bonus, 2)
        test.assert_equal(result.ac_penalty, 1)
        test.assert_true(result.cannot_remove)
    end)
    
    test.it("should apply stat drain curse", function()
        local result = item_effects.apply_cursed_effect("ring_of_weakness")
        
        test.assert_not_nil(result)
        test.assert_equal(result.damage_penalty, 1)
        test.assert_true(result.cannot_remove)
    end)
    
end)

test.describe("Item Effects - Utility Functions", function()
    
    test.it("should get effect info", function()
        local info = item_effects.get_effect_info("flaming_sword")
        
        test.assert_not_nil(info)
        test.assert_equal(info.name, "Flaming Blade")
        test.assert_equal(info.type, "active")
    end)
    
    test.it("should list effects by type", function()
        local actives = item_effects.list_effects_by_type("active")
        local passives = item_effects.list_effects_by_type("passive")
        local cursed = item_effects.list_effects_by_type("cursed")
        
        test.assert_greater_than(#actives, 0)
        test.assert_greater_than(#passives, 0)
        test.assert_greater_than(#cursed, 0)
    end)
    
    test.it("should have correct effect counts", function()
        local actives = item_effects.list_effects_by_type("active")
        local passives = item_effects.list_effects_by_type("passive")
        local cursed = item_effects.list_effects_by_type("cursed")
        
        -- We created 7 active, 10 passive, 5 cursed
        test.assert_equal(#actives, 7, "Should have 7 active effects")
        test.assert_equal(#passives, 10, "Should have 10 passive effects")
        test.assert_equal(#cursed, 5, "Should have 5 cursed effects")
    end)
    
end)

test.describe("Item Effects - Edge Cases", function()
    
    test.it("should handle nil user gracefully", function()
        local result = item_effects.use_item_effect("flaming_sword", nil, {name = "Enemy"})
        
        test.assert_true(result.success)  -- Should still work
    end)
    
    test.it("should handle nil target gracefully", function()
        local result = item_effects.use_item_effect("amulet_of_healing", {name = "Hero"}, nil)
        
        test.assert_true(result.success)  -- Healing doesn't need target
    end)
    
    test.it("should return nil for passive on wrong type", function()
        local result = item_effects.apply_passive_effect("flaming_sword")
        
        test.assert_nil(result)  -- Flaming sword is active, not passive
    end)
    
    test.it("should return nil for cursed on wrong type", function()
        local result = item_effects.apply_cursed_effect("vampire_blade")
        
        test.assert_nil(result)  -- Vampire blade is passive, not cursed
    end)
    
end)

local success = test.summary()
os.exit(success and 0 or 1)
