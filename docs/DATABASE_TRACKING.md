# Database Stat Tracking System

## Overview
SQLite-based stat tracking for balance testing and playtesting analysis. Tracks playthroughs, combat events, chamber exploration, and character progression.

## Quick Start

### 1. Initialize Database
```bash
lua stats_db.lua init
```

### 2. Run Tracked Balance Tests
```bash
lua balance_test_tracked.lua
```

### 3. View Analysis
```bash
lua quick_analysis.lua
lua stats_db.lua report
```

## Database Schema

### Tables

#### `playthroughs`
Main playthrough tracking
- Character info (name, class, level)
- Final stats (HP, gold, XP, score)
- Outcome (victory/defeat)
- Performance metrics

#### `combat_events`
Individual combat encounters
- Enemy type, HP, AC
- Combat duration (rounds)
- Damage dealt/taken
- Critical hits
- Victory/defeat

#### `chamber_events`
Chamber exploration
- Chamber type (trap, treasure, etc.)
- Event type (exploration, trap, puzzle)
- HP changes
- Loot found

#### `character_stats`
Character progression snapshots
- Attributes (STR, DEX, CON, etc.)
- Combat stats (HP, AC, ATK, DMG)
- Level progression

#### `balance_metrics`
Custom balance metrics
- Win rates
- Performance indicators
- Test results

## Usage in Code

### Basic Integration
```lua
local stats = require('stats_db')
stats.init_db()

-- Start tracking
local id = stats.start_playthrough("Bimbo", "Rogue", "hard")

-- Record events
stats.record_combat(id, chamber_num, "goblin", 10, 3, 15, 5, "victory", 1)
stats.record_chamber(id, chamber_num, "trap_room", "trap", true, 30, 25, "20gp")

-- End tracking
stats.end_playthrough(id, "victory", character, stats_table)
```

### Advanced Queries
```lua
-- Get win rate
local rate, wins, total = stats.get_win_rate("Rogue", "hard")

-- Get combat statistics
local combat_stats = stats.get_combat_stats("Orc")

-- Generate report
stats.generate_report()
```

## CLI Commands

```bash
# Generate comprehensive report
lua stats_db.lua report

# Check win rate
lua stats_db.lua winrate Rogue hard

# Export to CSV
lua stats_db.lua export playthrough_data.csv

# Clear all data (with confirmation)
lua stats_db.lua clear
```

## Analysis Tools

### Quick Analysis
```bash
lua quick_analysis.lua
```
Shows:
- Win rate by character build
- Enemy difficulty ranking
- HP loss by chamber type
- Stat correlation with success
- Critical hit impact
- Recent performance trends

### Balance Test
```bash
lua balance_test_tracked.lua
```
Runs 100 playthroughs across 4 builds and tracks everything.

## Key Insights from Testing

### Character Build Performance
- **Tank (50HP/18AC)**: 64% win rate - Most reliable
- **Glass Cannon (25HP/12AC)**: 52% win rate - High variance
- **Warrior (40HP/16AC)**: 48% win rate - Balanced
- **Rogue (30HP/14AC)**: 8% win rate - Needs buffing

### Enemy Difficulty
1. **Orc**: Hardest (73% win rate)
2. **Bandit**: Medium (84% win rate)
3. **Skeleton**: Easy (96% win rate)
4. **Goblin**: Easiest (97% win rate)

### Critical Insights
- **Critical Hits**: 97% win rate vs 85% without
- **High HP (40+)**: 56% win rate
- **High AC (16+)**: 56% win rate
- Puzzle chambers cause most HP loss (avg 3.1)

## Data Export

Export to CSV for Excel/Google Sheets analysis:
```bash
lua stats_db.lua export my_data.csv
```

## Database Location
- **File**: `dungeon_stats.db`
- **Format**: SQLite 3
- **Size**: ~50KB per 100 playthroughs

## Tips

1. **Run regular tests**: Track balance changes over time
2. **Compare builds**: Test new character builds against baseline
3. **Enemy tuning**: Identify overtuned/undertuned enemies
4. **Chamber balance**: Ensure all chamber types are fair
5. **Export periodically**: Keep historical data in CSV

## Advanced SQL Queries

Direct database queries:
```bash
# Win rate by hour of day
sqlite3 dungeon_stats.db "SELECT strftime('%H', start_time) as hour, 
  COUNT(*) as runs, 
  AVG(CASE WHEN result='victory' THEN 100.0 ELSE 0.0 END) as win_rate 
FROM playthroughs 
GROUP BY hour;"

# Average combat length by enemy
sqlite3 dungeon_stats.db "SELECT enemy_type, AVG(rounds) as avg_rounds 
FROM combat_events 
GROUP BY enemy_type 
ORDER BY avg_rounds DESC;"

# Most deadly chamber combinations
sqlite3 dungeon_stats.db "SELECT chamber_type, 
  SUM(hp_before - hp_after) as total_damage 
FROM chamber_events 
GROUP BY chamber_type 
ORDER BY total_damage DESC;"
```

## Files
- `stats_db.lua` - Core database module
- `balance_test_tracked.lua` - Automated balance testing
- `quick_analysis.lua` - Quick insight viewer
- `dungeon_stats.db` - SQLite database (generated)
- `DATABASE_TRACKING.md` - This file
