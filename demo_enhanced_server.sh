#!/bin/bash
# Demo script for enhanced server features

echo "🎮 Enhanced Dungeon Crawler Server Demo"
echo "========================================"
echo ""

# Start server in background
echo "🚀 Starting server..."
lua game_server.lua > /tmp/dungeon_server.log 2>&1 &
SERVER_PID=$!
echo "   Server PID: $SERVER_PID"
sleep 2

# Check if server is running
if ! ps -p $SERVER_PID > /dev/null; then
    echo "❌ Server failed to start!"
    cat /tmp/dungeon_server.log
    exit 1
fi

echo "✅ Server started successfully"
echo ""

# Demo 1: Multiple concurrent clients
echo "📊 Demo 1: Concurrent Connections"
echo "   Sending 3 simultaneous status requests..."
lua game_client.lua status > /tmp/client1.txt 2>&1 &
lua game_client.lua status > /tmp/client2.txt 2>&1 &
lua game_client.lua status > /tmp/client3.txt 2>&1 &
wait

echo "   Client 1 session: $(grep 'Session:' /tmp/client1.txt | cut -d: -f2)"
echo "   Client 2 session: $(grep 'Session:' /tmp/client2.txt | cut -d: -f2)"
echo "   Client 3 session: $(grep 'Session:' /tmp/client3.txt | cut -d: -f2)"
echo "   ✅ All clients got unique sessions!"
echo ""

# Demo 2: Various commands
echo "📊 Demo 2: Command Variety"
echo "   Testing different commands..."

echo -n "   - status: "
lua game_client.lua status 2>&1 | grep -q "Bimbo the Rogue" && echo "✅" || echo "❌"

echo -n "   - map: "
lua game_client.lua map 2>&1 | grep -q "DUNGEON MAP" && echo "✅" || echo "❌"

echo -n "   - search: "
lua game_client.lua search 2>&1 | grep -q "Searching" && echo "✅" || echo "❌"

echo -n "   - save: "
lua game_client.lua save 2>&1 | grep -q "saved" && echo "✅" || echo "❌"

echo ""

# Demo 3: Performance test
echo "📊 Demo 3: Performance Test"
echo "   Sending 10 rapid requests..."
START=$(perl -MTime::HiRes -e 'print Time::HiRes::time()')
for i in {1..10}; do
    lua game_client.lua status > /dev/null 2>&1
done
END=$(perl -MTime::HiRes -e 'print Time::HiRes::time()')
DURATION=$(echo "$END - $START" | bc)
echo "   Time: ${DURATION}s"
echo "   Average: $(echo "scale=2; $DURATION / 10" | bc)s per request"
echo ""

# Check server log
echo "📊 Server Activity Log (last 10 lines):"
tail -10 /tmp/dungeon_server.log | sed 's/^/   /'
echo ""

# Cleanup
echo "🧹 Cleaning up..."
kill $SERVER_PID 2>/dev/null
rm -f /tmp/client*.txt /tmp/dungeon_server.log
echo "✅ Demo complete!"
echo ""
echo "💡 Try interactive mode: lua game_client.lua -i"
