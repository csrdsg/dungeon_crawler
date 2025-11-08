#!/bin/bash
# Fast test runner for server tests

echo "🚀 Running Fast Server Tests"
echo "=============================="
echo ""

# Run unit tests
echo "📦 Running Server Unit Tests..."
lua tests/test_server.lua
UNIT_RESULT=$?

echo ""
echo "=============================="
echo ""

# Run integration tests
echo "📦 Running Server Integration Tests..."
lua tests/test_server_integration.lua
INTEGRATION_RESULT=$?

echo ""
echo "=============================="
echo "📊 Final Results"
echo "=============================="

if [ $UNIT_RESULT -eq 0 ] && [ $INTEGRATION_RESULT -eq 0 ]; then
    echo "✅ ALL SERVER TESTS PASSED!"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    [ $UNIT_RESULT -ne 0 ] && echo "  - Unit tests failed"
    [ $INTEGRATION_RESULT -ne 0 ] && echo "  - Integration tests failed"
    exit 1
fi
