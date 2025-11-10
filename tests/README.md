# Dungeon Crawler Test Suite

Comprehensive unit and integration tests for the TUI game systems.

## Quick Start

Run all tests:
```bash
cd tests
./run_tests.sh
```

Run individual test suites:
```bash
cd tests
lua test_progression.lua  # Progression system tests
lua test_effects.lua       # Effects system tests
lua test_quest_ui.lua      # Quest UI tests
lua test_integration.lua   # Integration tests
```

## Test Organization

### Unit Tests

**test_progression.lua** (12 tests)
- XP tracking and calculation
- Level up mechanics
- Stat progression
- Milestone bonuses
- Mana increases
- HP restoration

**test_effects.lua** (18 tests)
- Effect application
- Effect processing
- Duration management
- Stun mechanics
- Attack modifiers
- Damage/healing over time
- Effect stacking
- Display formatting

**test_quest_ui.lua** (17 tests)
- Quest formatting
- Count tracking
- Objective management
- Reward awarding
- Quest completion
- Display icons
- Summary generation

### Integration Tests

**test_integration.lua** (12 tests)
- System interactions
- Progression + Effects
- Effects + Combat
- Quests + Rewards
- Level ups with effects
- Save/load compatibility
- Multi-system workflows

## Test Results

Current Status: **✅ ALL TESTS PASSING**

```
Test Suites:
  Total:  4
  Passed: 4 ✅
  Failed: 0 ❌

Individual Tests:
  Progression: 12/12 ✅
  Effects:     18/18 ✅
  Quest UI:    17/17 ✅
  Integration: 12/12 ✅
  
Total: 59/59 tests passing ✅
```

## Coverage

### What's Tested

✅ **Progression System**
- XP calculation formulas
- Level up triggers
- Stat increases
- Milestone bonuses
- Mana progression
- HP restoration

✅ **Effects System**
- All 6 effect types (poison, bleeding, stun, strength, regen, curse)
- Effect application and removal
- Duration tracking
- Damage/healing processing
- Attack modifiers
- Stun prevention

✅ **Quest UI**
- Quest display formatting
- Objective tracking
- Reward distribution
- Completion detection
- Count summaries

✅ **Integration**
- Cross-system interactions
- Player creation workflows
- Combat integration
- Save/load preservation
- Multi-feature scenarios

### What's NOT Tested

❌ **TUI Rendering**
- Screen drawing functions
- Input handling
- Terminal control

❌ **AI Storyteller**
- Ollama integration
- Description generation

❌ **Game Logic (Existing)**
- Combat calculations
- Dungeon generation
- Loot tables

(These have their own test files in the main tests directory)

## Writing New Tests

### Test Structure

```lua
#!/usr/bin/env lua
package.path = package.path .. ";../?.lua"

local MyModule = require("src.my_module")

local tests_passed = 0
local tests_failed = 0

local function test(name, fn)
    io.write(string.format("%-50s", name .. "..."))
    local ok, err = pcall(fn)
    if ok then
        print(" ✅ PASS")
        tests_passed = tests_passed + 1
    else
        print(" ❌ FAIL")
        print("  Error: " .. tostring(err))
        tests_failed = tests_failed + 1
    end
end

local function assert_equals(actual, expected, msg)
    if actual ~= expected then
        error(string.format("%s: expected %s but got %s", 
            msg or "Assertion failed", 
            tostring(expected), 
            tostring(actual)))
    end
end

-- Write tests
test("My test description", function()
    local result = MyModule.some_function()
    assert_equals(result, expected_value, "Result value")
end)

-- Summary
print("\n" .. string.rep("=", 60))
print("MY MODULE TESTS SUMMARY")
print(string.rep("=", 60))
print(string.format("Passed: %d", tests_passed))
print(string.format("Failed: %d", tests_failed))
print(string.rep("=", 60))

if tests_failed > 0 then
    os.exit(1)
else
    print("✅ All tests passed!")
    os.exit(0)
end
```

### Helper Functions

Available assertion helpers:
```lua
assert_equals(actual, expected, msg)  -- Equality check
assert_true(value, msg)                -- Boolean true
assert_false(value, msg)               -- Boolean false
```

### Mock Functions

For testing with random elements:
```lua
local function mock_roll(dice)
    return 3  -- Predictable result
end

Effects.process_turn(entity, mock_roll)
```

## Continuous Integration

Add to CI/CD:
```yaml
test:
  script:
    - cd tests
    - ./run_tests.sh
```

## Debugging Failed Tests

When a test fails:

1. **Read the error message**
   ```
   ❌ FAIL
   Error: test_file.lua:26: Expected 5 but got 6
   ```

2. **Run the specific test file**
   ```bash
   lua test_progression.lua
   ```

3. **Add debug output**
   ```lua
   print("Debug: player.level = " .. player.level)
   ```

4. **Check assumptions**
   - Are formulas correct?
   - Are test expectations accurate?
   - Did the implementation change?

## Best Practices

### DO:
✅ Write tests for new features
✅ Keep tests simple and focused
✅ Use descriptive test names
✅ Test edge cases
✅ Test error conditions
✅ Run tests before committing

### DON'T:
❌ Test implementation details
❌ Write dependent tests
❌ Use random data without seeds
❌ Ignore failing tests
❌ Write tests that depend on timing

## Performance

Test execution time:
- Progression: ~0.5s
- Effects: ~0.7s
- Quest UI: ~0.4s
- Integration: ~0.6s

**Total: ~2.2 seconds**

Fast enough for frequent execution during development.

## Maintenance

Update tests when:
- Adding new features
- Changing existing behavior
- Fixing bugs
- Refactoring code

Keep tests in sync with code!

## Support

If tests fail unexpectedly:
1. Check if code changed
2. Verify test assumptions
3. Look for environment issues
4. Review recent commits

## Future Enhancements

Potential additions:
- [ ] Performance benchmarks
- [ ] Test coverage metrics
- [ ] Automated test generation
- [ ] Visual test reports
- [ ] Regression test suite
- [ ] Property-based testing
- [ ] Mocking framework

---

**Status:** ✅ 59/59 tests passing
**Last Updated:** 2024-11-10
**Maintained by:** Development Team
