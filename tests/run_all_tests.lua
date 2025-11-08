#!/usr/bin/env lua
-- run_all_tests.lua - Run all unit tests
package.path = package.path .. ";../src/?.lua"

print("╔══════════════════════════════════════════════════════════════════════╗")
print("║                     DUNGEON CRAWLER - UNIT TESTS                     ║")
print("╚══════════════════════════════════════════════════════════════════════╝")
print()

local test_files = {
    "test_dice.lua",
    "test_combat.lua",
    "test_inventory.lua",
    "test_stats_db.lua"
}

local total_passed = 0
local total_failed = 0
local failed_suites = {}

for i, test_file in ipairs(test_files) do
    print(string.format("\n[%d/%d] Running %s...", i, #test_files, test_file))
    print(string.rep("═", 70))
    
    -- Run test and capture exit code
    local exit_code = os.execute("lua " .. test_file .. " >/dev/null 2>&1; echo $?")
    local exit_status = os.execute("lua " .. test_file)
    
    -- On macOS/BSD, os.execute returns exit code * 256
    local actual_exit = type(exit_status) == "number" and (exit_status / 256) or exit_status
    
    -- Also just run it normally to see output
    os.execute("lua " .. test_file)
    
    -- Check if test passed (exit code 0)
    if actual_exit == 0 or actual_exit == true then
        total_passed = total_passed + 1
    else
        table.insert(failed_suites, test_file)
        total_failed = total_failed + 1
    end
end

print("\n" .. string.rep("═", 70))
print("🎯 OVERALL TEST RESULTS")
print(string.rep("═", 70))
print(string.format("Test Suites Run:    %d", #test_files))
print(string.format("Test Suites Passed: %d", total_passed))
print(string.format("Test Suites Failed: %d", total_failed))
print(string.rep("═", 70))

if total_failed == 0 then
    print("🎉 ALL TEST SUITES PASSED!")
    print(string.rep("═", 70))
    os.exit(0)
else
    print("❌ FAILED TEST SUITES:")
    for _, suite in ipairs(failed_suites) do
        print("   - " .. suite)
    end
    print(string.rep("═", 70))
    os.exit(1)
end
