-- test_framework.lua - Simple unit testing framework
local M = {}
package.path = package.path .. ";../src/?.lua"

M.total_tests = 0
M.passed_tests = 0
M.failed_tests = 0
M.current_suite = ""

function M.describe(suite_name, test_fn)
    M.current_suite = suite_name
    print(string.format("\n📦 %s", suite_name))
    print(string.rep("─", 70))
    test_fn()
end

function M.it(description, test_fn)
    M.total_tests = M.total_tests + 1
    local status, err = pcall(test_fn)
    
    if status then
        M.passed_tests = M.passed_tests + 1
        print(string.format("  ✅ %s", description))
    else
        M.failed_tests = M.failed_tests + 1
        print(string.format("  ❌ %s", description))
        print(string.format("     Error: %s", tostring(err)))
    end
end

function M.assert_equal(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s\n     Expected: %s\n     Got: %s", 
              message or "Values not equal", tostring(expected), tostring(actual)))
    end
end

function M.assert_true(value, message)
    if not value then
        error(message or "Expected true, got false")
    end
end

function M.assert_false(value, message)
    if value then
        error(message or "Expected false, got true")
    end
end

function M.assert_not_nil(value, message)
    if value == nil then
        error(message or "Expected non-nil value")
    end
end

function M.assert_nil(value, message)
    if value ~= nil then
        error(string.format("%s (got: %s)", message or "Expected nil", tostring(value)))
    end
end

function M.assert_type(value, expected_type, message)
    local actual_type = type(value)
    if actual_type ~= expected_type then
        error(string.format("%s\n     Expected type: %s\n     Got type: %s", 
              message or "Type mismatch", expected_type, actual_type))
    end
end

function M.assert_greater_than(actual, threshold, message)
    if not (actual > threshold) then
        error(string.format("%s\n     Expected > %s\n     Got: %s", 
              message or "Value not greater than threshold", tostring(threshold), tostring(actual)))
    end
end

function M.assert_less_than(actual, threshold, message)
    if not (actual < threshold) then
        error(string.format("%s\n     Expected < %s\n     Got: %s", 
              message or "Value not less than threshold", tostring(threshold), tostring(actual)))
    end
end

function M.assert_in_range(actual, min_val, max_val, message)
    if not (actual >= min_val and actual <= max_val) then
        error(string.format("%s\n     Expected: %s-%s\n     Got: %s", 
              message or "Value out of range", tostring(min_val), tostring(max_val), tostring(actual)))
    end
end

function M.assert_contains(table_val, value, message)
    for _, v in pairs(table_val) do
        if v == value then return end
    end
    error(string.format("%s\n     Value '%s' not found in table", 
          message or "Table does not contain value", tostring(value)))
end

function M.summary()
    print("\n" .. string.rep("═", 70))
    print("📊 TEST SUMMARY")
    print(string.rep("═", 70))
    print(string.format("Total Tests:  %d", M.total_tests))
    print(string.format("Passed:       %d (%.1f%%)", M.passed_tests, 
          M.total_tests > 0 and (M.passed_tests / M.total_tests * 100) or 0))
    print(string.format("Failed:       %d (%.1f%%)", M.failed_tests, 
          M.total_tests > 0 and (M.failed_tests / M.total_tests * 100) or 0))
    print(string.rep("═", 70))
    
    if M.failed_tests == 0 then
        print("🎉 ALL TESTS PASSED!")
        return true
    else
        print("❌ SOME TESTS FAILED")
        return false
    end
end

return M
