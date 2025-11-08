#!/bin/bash
# Wrapper to send commands to the game with session checking

# Check if session is running
if ! bash game_session.sh status > /dev/null 2>&1; then
    echo "Starting new game session..."
    bash game_session.sh start
    sleep 2
fi

# Start game in async mode if not already running
SESSION_ID="game_persist"

# Function to check and restart if needed
ensure_session() {
    # This will be called before each command
    ps aux | grep -v grep | grep "lua play.lua" > /dev/null 2>&1
    return $?
}

# Always use the same session ID
echo "Session ID: $SESSION_ID"
