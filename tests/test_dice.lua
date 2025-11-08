#!/usr/bin/env lua
-- test_dice.lua - Unit tests for dice module
package.path = package.path .. ";../src/?.lua"
local test = require('test_framework')
local dice = require('dice')

math.randomseed(12345) -- Fixed seed for reproducibility

test.describe("Dice Module", function()
    
    test.it("should roll d20", function()
        local result = dice.roll("d20")
        test.assert_not_nil(result)
        test.assert_true(result >= 1)
        test.assert_true(result <= 20)
    end)
    
    test.it("should roll multiple d6", function()
        local result = dice.roll("3d6")
        test.assert_not_nil(result)
        test.assert_true(result >= 3)
        test.assert_true(result <= 18)
    end)
    
    test.it("should handle modifiers", function()
        local result = dice.roll("1d20+5")
        test.assert_true(result >= 6) -- min 1+5
        test.assert_true(result <= 25) -- max 20+5
    end)
    
    test.it("should handle subtraction", function()
        local result = dice.roll("1d20-3")
        test.assert_true(result >= -2) -- min 1-3
        test.assert_true(result <= 17) -- max 20-3
    end)
    
end)

local success = test.summary()
os.exit(success and 0 or 1)
