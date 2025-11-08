#!/bin/bash
# run_tests.sh - Run all tests with proper exit code handling

TEST_TYPE="${1:-all}"

case "$TEST_TYPE" in
    unit)
        echo "╔══════════════════════════════════════════════════════════════════════╗"
        echo "║                     DUNGEON CRAWLER - UNIT TESTS                     ║"
        echo "╚══════════════════════════════════════════════════════════════════════╝"
        TESTS=("test_dice.lua" "test_combat.lua" "test_inventory.lua" "test_stats_db.lua" "test_magic.lua" "test_item_effects.lua")
        ;;
    integration)
        echo "╔══════════════════════════════════════════════════════════════════════╗"
        echo "║                  DUNGEON CRAWLER - INTEGRATION TESTS                 ║"
        echo "╚══════════════════════════════════════════════════════════════════════╝"
        TESTS=("integration_tests.lua" "test_integrated_playthrough.lua")
        ;;
    all)
        echo "╔══════════════════════════════════════════════════════════════════════╗"
        echo "║                   DUNGEON CRAWLER - ALL TESTS                        ║"
        echo "╚══════════════════════════════════════════════════════════════════════╝"
        TESTS=("test_dice.lua" "test_combat.lua" "test_inventory.lua" "test_stats_db.lua" "test_magic.lua" "test_item_effects.lua" "integration_tests.lua" "test_integrated_playthrough.lua")
        ;;
    *)
        echo "Usage: $0 [unit|integration|all]"
        echo "  unit        - Run only unit tests"
        echo "  integration - Run only integration tests"
        echo "  all         - Run all tests (default)"
        exit 1
        ;;
esac
PASSED=0
FAILED=0
FAILED_TESTS=()

for i in "${!TESTS[@]}"; do
    TEST="${TESTS[$i]}"
    echo ""
    echo "[$(($i+1))/${#TESTS[@]}] Running $TEST..."
    echo "══════════════════════════════════════════════════════════════════════"
    
    if lua "$TEST"; then
        ((PASSED++))
    else
        ((FAILED++))
        FAILED_TESTS+=("$TEST")
    fi
done

echo ""
echo "══════════════════════════════════════════════════════════════════════"
echo "🎯 OVERALL TEST RESULTS"
echo "══════════════════════════════════════════════════════════════════════"
echo "Test Suites Run:    ${#TESTS[@]}"
echo "Test Suites Passed: $PASSED"
echo "Test Suites Failed: $FAILED"
echo "══════════════════════════════════════════════════════════════════════"

if [ $FAILED -eq 0 ]; then
    echo "🎉 ALL TEST SUITES PASSED!"
    echo "══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo "❌ FAILED TEST SUITES:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "   - $test"
    done
    echo "══════════════════════════════════════════════════════════════════════"
    exit 1
fi
