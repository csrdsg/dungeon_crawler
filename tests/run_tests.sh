#!/bin/bash
# Test runner for Dungeon Crawler TUI

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              DUNGEON CRAWLER TEST SUITE                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$TESTS_DIR"

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_TESTS=0

run_test() {
    local test_file=$1
    local test_name=$2
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if lua "$test_file"; then
        echo ""
        return 0
    else
        echo ""
        return 1
    fi
}

# Run unit tests
echo "📦 UNIT TESTS"
echo ""

if run_test "test_progression.lua" "Progression System"; then
    ((TOTAL_PASSED++))
else
    ((TOTAL_FAILED++))
fi

if run_test "test_effects.lua" "Effects System"; then
    ((TOTAL_PASSED++))
else
    ((TOTAL_FAILED++))
fi

if run_test "test_quest_ui.lua" "Quest UI System"; then
    ((TOTAL_PASSED++))
else
    ((TOTAL_FAILED++))
fi

((TOTAL_TESTS = TOTAL_PASSED + TOTAL_FAILED))

# Run integration tests
echo ""
echo "🔗 INTEGRATION TESTS"
echo ""

if run_test "test_integration.lua" "System Integration"; then
    ((TOTAL_PASSED++))
else
    ((TOTAL_FAILED++))
fi

((TOTAL_TESTS = TOTAL_PASSED + TOTAL_FAILED))

# Final summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    FINAL TEST SUMMARY                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Test Suites:"
echo "    Total:  $TOTAL_TESTS"
echo "    Passed: $TOTAL_PASSED ✅"
echo "    Failed: $TOTAL_FAILED ❌"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "  Result: ✅ ALL TESTS PASSED!"
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  🎉 The codebase is working correctly! 🎉                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    exit 0
else
    echo "  Result: ❌ SOME TESTS FAILED"
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  ⚠️  Please fix the failing tests  ⚠️                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    exit 1
fi
