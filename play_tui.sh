#!/usr/bin/env zsh
# Dungeon Crawler TUI - Quick Start

echo "🏰 Dungeon Crawler TUI"
echo "====================="
echo ""
echo "✨ Features:"
echo "  • Beautiful terminal interface"
echo "  • Turn-based combat"
echo "  • Dungeon exploration"
echo "  • Save/Load system"
echo "  • 100% data-driven"
echo ""
echo "📊 Data files loaded:"
ls -1 data/*.lua | wc -l | xargs echo "  •" "files ready"
echo ""
echo "🎮 Starting game..."
echo ""

# Launch the TUI
lua game_tui.lua
