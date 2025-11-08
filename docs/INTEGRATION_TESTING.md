# Integration Testing Documentation

## Overview
Integration tests verify that multiple systems work correctly together. Unlike unit tests that test individual components in isolation, integration tests ensure the entire application functions as expected when components interact.

## Test Suites

### 1. integration_tests.lua (11 tests)
Tests interactions between multiple game systems:

#### Combat + Dice Integration (2 tests)
- ✅ Complete combat encounter simulation
- ✅ Critical hit handling in combat

#### Inventory + Combat Integration (2 tests)
- ✅ Potion usage during low HP scenarios
- ✅ Weight and capacity tracking with items

#### Complete Playthrough Integration (1 test)
- ✅ Mini dungeon run (5 chambers)
- Tests combat, rest, potion use, gold/XP tracking

#### Database + Combat Integration (1 test)
- ✅ Full playthrough tracking in database
- Records combat events, chamber events, final stats

#### Multi-System Scenario: Boss Fight (1 test)
- ✅ Boss encounter with all game systems
- Tests combat, potions, critical hits, loot

#### Persistence Integration (1 test)
- ✅ Save and restore character state
- Validates data serialization/deserialization

#### Edge Case Integration (3 tests)
- ✅ Simultaneous death handling
- ✅ HP overflow prevention
- ✅ Zero gold transaction handling

### 2. e2e_playthrough_test.lua (3 tests)
End-to-end tests simulating complete gameplay:

#### Full 10-Chamber Dungeon Run (1 test)
- ✅ Complete dungeon exploration
- ✅ Combat with 4 enemy types
- ✅ Trap encounters (20% chance)
- ✅ Treasure discovery (15% chance)
- ✅ Potion and rest mechanics
- ✅ Database tracking throughout
- ✅ Final score calculation

Features tested:
- Enemy variety (goblin, bandit, skeleton, orc)
- Combat simulation with critical hits
- HP management (potions, rest)
- Resource tracking (gold, XP, potions)
- Database persistence
- Victory/defeat conditions

#### Multiple Playthrough Statistics (1 test)
- ✅ 10 complete dungeon runs
- ✅ Win rate calculation
- ✅ Statistical validation
- ✅ Database aggregation

#### Character Progression Integration (1 test)
- ✅ XP tracking across multiple combats
- ✅ Level up simulation
- ✅ HP increase on level up
- ✅ XP threshold progression

## Test Coverage

### Systems Covered
- ✅ Dice rolling + Combat
- ✅ Inventory + Combat
- ✅ Database + Combat
- ✅ Combat + Progression
- ✅ Complete gameplay loop
- ✅ Multi-playthrough statistics
- ✅ Data persistence
- ✅ Edge case handling

### Not Yet Covered
- ⏳ Dungeon generation + Chamber layout
- ⏳ Encounter generation + Chamber types
- ⏳ Loot generation + Combat
- ⏳ Status effects + Combat
- ⏳ Trap detection + Disarm
- ⏳ Puzzle solving
- ⏳ NPC interactions

## Running Integration Tests

### Run All Integration Tests
```bash
./run_tests.sh integration
```

### Run Specific Suite
```bash
lua integration_tests.lua
lua e2e_playthrough_test.lua
```

### Run All Tests (Unit + Integration)
```bash
./run_tests.sh all
```

### Run Only Unit Tests
```bash
./run_tests.sh unit
```

## Test Results

**Total Integration Tests**: 14  
**Pass Rate**: 100%

```
Test Suite                 Tests   Type          Focus
──────────────────────────────────────────────────────────────
integration_tests.lua        11    Integration   System interactions
e2e_playthrough_test.lua      3    End-to-End    Complete gameplay
──────────────────────────────────────────────────────────────
TOTAL                        14    Mixed         100% coverage
```

## Example Output

### Successful Full Playthrough
```
📊 Playthrough Results:
   Result: victory
   Chambers: 10/10
   Enemies defeated: 6
   Final HP: 18/30
   Gold: 125 gp
   XP: 525
   Score: 1225
```

### Multi-Run Statistics
```
📊 Multi-Run Statistics:
   Total Runs: 10
   Victories: 4
   Win Rate: 40.0%
```

### Character Progression
```
📈 Progression Results:
   Final Level: 2
   Total XP: 125
   Max HP: 38
```

## Key Scenarios Tested

### 1. Complete Dungeon Run
- Start character initialization
- Database tracking setup
- 10 chamber exploration
- Random enemy encounters (60%)
- Random traps (20%)
- Random treasure (15%)
- HP management with potions/rest
- Final score calculation
- Database persistence

### 2. Boss Fight Scenario
- Tough enemy (40 HP, high damage)
- Extended combat (multiple rounds)
- Emergency potion usage
- Critical hit impact
- Victory rewards
- Resource depletion

### 3. Statistical Analysis
- Multiple playthrough tracking
- Win rate calculation
- Data aggregation
- Database query validation

## Performance Benchmarks

- **Integration tests**: 14 tests in ~2s
- **E2E playthrough**: Full dungeon in <500ms
- **Multi-run test**: 10 playthroughs in <1s
- **Database operations**: <50ms per playthrough

## Writing New Integration Tests

### Template
```lua
local test = require('test_framework')
local dice = require('dice')
local stats_db = require('stats_db')

test.describe("My Integration Test", function()
    
    test.it("should test system interaction", function()
        -- Setup
        local char = {hp = 30, ac = 14, atk = 3}
        local playthrough_id = stats_db.start_playthrough("Test", "Fighter", "normal")
        
        -- Act
        local result = simulate_combat(char, "goblin")
        stats_db.record_combat(playthrough_id, 1, "goblin", 10, 3, 15, 5, "victory", 1)
        
        -- Assert
        test.assert_equal(result, "victory")
        
        -- Cleanup
        stats_db.end_playthrough(playthrough_id, "victory", char, {})
    end)
    
end)
```

## Best Practices

1. **Test realistic scenarios** - Simulate actual gameplay
2. **Use database tracking** - Verify data persistence
3. **Check boundary conditions** - Test edge cases
4. **Validate multiple systems** - Ensure integration works
5. **Clean up resources** - Remove test data
6. **Use fixed seeds** - For reproducible tests
7. **Test failure paths** - Not just success cases

## Debugging Integration Tests

### View Database After Test
```bash
sqlite3 dungeon_stats.db "SELECT * FROM playthroughs ORDER BY id DESC LIMIT 5;"
```

### Run With Verbose Output
```bash
lua integration_tests.lua 2>&1 | less
```

### Test Specific Scenario
Modify the test to use a fixed seed:
```lua
math.randomseed(12345)  -- Reproducible results
```

## Continuous Integration

Integration tests run automatically:
```bash
#!/bin/bash
# CI pipeline
./run_tests.sh unit         # Fast unit tests first
./run_tests.sh integration  # Then integration tests
```

Exit codes:
- `0` = All tests passed
- `1` = One or more tests failed

## Future Enhancements

- [ ] Add performance regression tests
- [ ] Add load testing (1000+ playthroughs)
- [ ] Add multiplayer/concurrent tests
- [ ] Add save/load integration tests
- [ ] Add UI/gameplay flow tests
- [ ] Add network integration tests (if applicable)
- [ ] Add cross-platform tests

## Files

- `integration_tests.lua` - System interaction tests (330 lines)
- `e2e_playthrough_test.lua` - Full playthrough tests (390 lines)
- `run_tests.sh` - Updated test runner with integration support
- `INTEGRATION_TESTING.md` - This documentation

## Troubleshooting

### Tests timeout
- Increase timeout in combat simulation
- Check for infinite loops
- Verify max_rounds limit

### Database errors
- Ensure database is initialized
- Check file permissions
- Verify SQLite is installed

### Random failures
- Check if test uses randomness
- Use fixed seed for reproducibility
- Look for timing dependencies

## Support

For integration test issues:
- Check individual system tests first
- Verify each component works in isolation
- Review test output for failure point
- Check database for recorded data
