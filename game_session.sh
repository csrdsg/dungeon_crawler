#!/bin/bash
# Game session manager - keeps track of active session

SESSION_FILE=".game_session_pid"
SESSION_ID="dungeon_game"

case "$1" in
    start)
        # Kill any existing session first
        if [ -f "$SESSION_FILE" ]; then
            OLD_PID=$(cat "$SESSION_FILE")
            kill $OLD_PID 2>/dev/null
            rm -f "$SESSION_FILE"
        fi
        
        # Start new game session in background
        lua play.lua &
        GAME_PID=$!
        echo $GAME_PID > "$SESSION_FILE"
        echo "Game session started with PID $GAME_PID"
        ;;
        
    status)
        if [ -f "$SESSION_FILE" ]; then
            PID=$(cat "$SESSION_FILE")
            if ps -p $PID > /dev/null 2>&1; then
                echo "Session $SESSION_ID is RUNNING (PID: $PID)"
                exit 0
            else
                echo "Session $SESSION_ID is NOT running (stale PID file)"
                rm -f "$SESSION_FILE"
                exit 1
            fi
        else
            echo "No active session"
            exit 1
        fi
        ;;
        
    send)
        if [ -f "$SESSION_FILE" ]; then
            PID=$(cat "$SESSION_FILE")
            if ps -p $PID > /dev/null 2>&1; then
                echo "Session is running, ready to receive input"
                exit 0
            else
                echo "Session not running, need to restart"
                rm -f "$SESSION_FILE"
                exit 1
            fi
        else
            echo "No session file found"
            exit 1
        fi
        ;;
        
    stop)
        if [ -f "$SESSION_FILE" ]; then
            PID=$(cat "$SESSION_FILE")
            kill $PID 2>/dev/null
            rm -f "$SESSION_FILE"
            echo "Session stopped"
        else
            echo "No active session to stop"
        fi
        ;;
        
    *)
        echo "Usage: $0 {start|status|send|stop}"
        exit 1
        ;;
esac
