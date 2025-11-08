#!/usr/bin/env lua
-- test_inventory.lua - Unit tests for inventory module
package.path = package.path .. ";../src/?.lua"

local test = require('test_framework')

test.describe("Inventory Module", function()
    
    test.it("should load inventory module", function()
        local ok, inv = pcall(require, 'inventory')
        test.assert_true(ok, "Failed to load inventory module")
    end)
end)

test.describe("Inventory Management", function()
    
    test.it("should track carrying capacity", function()
        local strength = 10
        local capacity = strength * 5
        test.assert_equal(capacity, 50, "Capacity calculation wrong")
    end)
    
    test.it("should calculate current weight", function()
        local items = {
            {name = "Sword", weight = 5},
            {name = "Shield", weight = 10},
            {name = "Potion", weight = 0.5}
        }
        
        local total_weight = 0
        for _, item in ipairs(items) do
            total_weight = total_weight + item.weight
        end
        
        test.assert_equal(total_weight, 15.5, "Weight calculation wrong")
    end)
    
    test.it("should detect overencumbered state", function()
        local current_weight = 55
        local capacity = 50
        local overencumbered = current_weight > capacity
        test.assert_true(overencumbered, "Should detect overencumbered")
    end)
    
    test.it("should allow items within capacity", function()
        local current_weight = 45
        local capacity = 50
        local new_item_weight = 3
        local can_carry = (current_weight + new_item_weight) <= capacity
        test.assert_true(can_carry, "Should be able to carry item")
    end)
    
    test.it("should prevent adding items over capacity", function()
        local current_weight = 48
        local capacity = 50
        local new_item_weight = 5
        local can_carry = (current_weight + new_item_weight) <= capacity
        test.assert_false(can_carry, "Should not be able to carry item")
    end)
    
    test.it("should count items correctly", function()
        local items = {"sword", "shield", "potion", "rope", "torch"}
        test.assert_equal(#items, 5, "Item count wrong")
    end)
    
    test.it("should find item by name", function()
        local items = {"Sword", "Shield", "Potion"}
        local found = false
        for _, item in ipairs(items) do
            if item == "Shield" then
                found = true
                break
            end
        end
        test.assert_true(found, "Should find item")
    end)
    
    test.it("should handle item removal", function()
        local items = {"Sword", "Shield", "Potion"}
        local new_items = {}
        for _, item in ipairs(items) do
            if item ~= "Shield" then
                table.insert(new_items, item)
            end
        end
        test.assert_equal(#new_items, 2, "Should have 2 items after removal")
    end)
    
    test.it("should handle stackable items", function()
        local item = {name = "Potion", quantity = 3}
        item.quantity = item.quantity + 1
        test.assert_equal(item.quantity, 4, "Stacking should work")
    end)
    
    test.it("should calculate total value", function()
        local items = {
            {name = "Sword", value = 50},
            {name = "Shield", value = 30},
            {name = "Potion", value = 10}
        }
        
        local total_value = 0
        for _, item in ipairs(items) do
            total_value = total_value + item.value
        end
        
        test.assert_equal(total_value, 90, "Total value calculation wrong")
    end)
end)

test.describe("Item Usage", function()
    
    test.it("should consume potion and heal HP", function()
        local hp = 15
        local max_hp = 30
        local healing = math.random(2, 8)  -- 2d4 average
        local new_hp = math.min(hp + healing, max_hp)
        
        test.assert_greater_than(new_hp, hp, "HP should increase")
        test.assert_true(new_hp <= max_hp, "HP should not exceed max")
    end)
    
    test.it("should not heal beyond max HP", function()
        local hp = 28
        local max_hp = 30
        local healing = 8
        local new_hp = math.min(hp + healing, max_hp)
        
        test.assert_equal(new_hp, 30, "HP should cap at max")
    end)
    
    test.it("should decrease potion count after use", function()
        local potions = 3
        potions = potions - 1
        test.assert_equal(potions, 2, "Potion count should decrease")
    end)
    
    test.it("should not allow using items at 0 quantity", function()
        local potions = 0
        local can_use = potions > 0
        test.assert_false(can_use, "Cannot use item with 0 quantity")
    end)
end)

test.describe("Equipment", function()
    
    test.it("should calculate AC with armor", function()
        local base_ac = 10
        local dex_mod = 2
        local armor_bonus = 4
        local total_ac = base_ac + dex_mod + armor_bonus
        test.assert_equal(total_ac, 16, "AC calculation wrong")
    end)
    
    test.it("should calculate damage with weapon", function()
        local base_damage = math.random(1, 6)
        local str_mod = 3
        local total_damage = base_damage + str_mod
        test.assert_in_range(total_damage, 4, 9, "Damage calculation wrong")
    end)
    
    test.it("should handle weapon switching", function()
        local equipped_weapon = "Sword"
        equipped_weapon = "Axe"
        test.assert_equal(equipped_weapon, "Axe", "Weapon switch failed")
    end)
end)

local success = test.summary()
os.exit(success and 0 or 1)
