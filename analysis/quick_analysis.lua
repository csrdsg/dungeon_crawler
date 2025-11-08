-- quick_analysis.lua - Quick database queries for balance insights
local stats = require('stats_db')

print("\n🔍 QUICK BALANCE ANALYSIS")
print(string.rep("=", 70))

-- Win rates by class
print("\n📊 WIN RATE BY CHARACTER BUILD:")
print(string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    character_name || ' (' || character_class || ')' as build,
    printf('Runs: %3d', COUNT(*)) as runs,
    printf('Wins: %2d', SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END)) as wins,
    printf('Rate: %5.1f%%', SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as win_rate,
    printf('Avg Score: %4.0f', AVG(score)) as avg_score
FROM playthroughs
GROUP BY character_name
ORDER BY win_rate DESC;
]] .. '"')

-- Enemy difficulty ranking
print("\n⚔️  ENEMY DIFFICULTY RANKING (by win rate):")
print(string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    enemy_type,
    printf('%3d', COUNT(*)) as encounters,
    printf('%4.1f', AVG(rounds)) as avg_rounds,
    printf('%4.1f%%', SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as win_rate,
    printf('%4.1f', AVG(damage_taken)) as avg_dmg_taken
FROM combat_events
GROUP BY enemy_type
ORDER BY win_rate ASC;
]] .. '"')

-- HP loss by chamber type
print("\n💔 AVERAGE HP LOSS BY CHAMBER TYPE:")
print(string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    chamber_type,
    printf('%3d', COUNT(*)) as visits,
    printf('%4.1f', AVG(hp_before - hp_after)) as avg_hp_lost,
    printf('%4.1f', MAX(hp_before - hp_after)) as max_hp_lost
FROM chamber_events
GROUP BY chamber_type
ORDER BY avg_hp_lost DESC;
]] .. '"')

-- Performance by starting stats
print("\n💪 STAT CORRELATION WITH SUCCESS:")
print(string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    CASE 
        WHEN cs.hp >= 40 THEN 'High HP (40+)'
        WHEN cs.hp >= 30 THEN 'Medium HP (30-39)'
        ELSE 'Low HP (<30)'
    END as hp_category,
    printf('%3d', COUNT(*)) as runs,
    printf('%5.1f%%', AVG(CASE WHEN p.result = 'victory' THEN 100.0 ELSE 0.0 END)) as win_rate
FROM character_stats cs
JOIN playthroughs p ON cs.playthrough_id = p.id
WHERE cs.id IN (
    SELECT MIN(id) FROM character_stats GROUP BY playthrough_id
)
GROUP BY hp_category
ORDER BY win_rate DESC;
]] .. '"')

print("\n" .. string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    CASE 
        WHEN cs.ac >= 16 THEN 'High AC (16+)'
        WHEN cs.ac >= 14 THEN 'Medium AC (14-15)'
        ELSE 'Low AC (<14)'
    END as ac_category,
    printf('%3d', COUNT(*)) as runs,
    printf('%5.1f%%', AVG(CASE WHEN p.result = 'victory' THEN 100.0 ELSE 0.0 END)) as win_rate
FROM character_stats cs
JOIN playthroughs p ON cs.playthrough_id = p.id
WHERE cs.id IN (
    SELECT MIN(id) FROM character_stats GROUP BY playthrough_id
)
GROUP BY ac_category
ORDER BY win_rate DESC;
]] .. '"')

-- Critical hits impact
print("\n💥 CRITICAL HIT ANALYSIS:")
print(string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    printf('Combats with crits: %3d', SUM(CASE WHEN critical_hits > 0 THEN 1 ELSE 0 END)) as with_crits,
    printf('Combats without: %3d', SUM(CASE WHEN critical_hits = 0 THEN 1 ELSE 0 END)) as without_crits,
    printf('Win rate (with crits): %5.1f%%', 
        SUM(CASE WHEN critical_hits > 0 AND result = 'victory' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN critical_hits > 0 THEN 1 ELSE 0 END), 0)) as wr_with,
    printf('Win rate (no crits): %5.1f%%',
        SUM(CASE WHEN critical_hits = 0 AND result = 'victory' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN critical_hits = 0 THEN 1 ELSE 0 END), 0)) as wr_without
FROM combat_events;
]] .. '"')

-- Recent trends (last 20 runs)
print("\n📈 RECENT PERFORMANCE TREND (Last 20 runs):")
print(string.rep("-", 70))
os.execute('sqlite3 dungeon_stats.db "' ..
[[SELECT 
    id,
    character_name,
    result,
    chambers_explored || '/10' as progress,
    enemies_defeated as enemies,
    score
FROM playthroughs
ORDER BY id DESC
LIMIT 20;
]] .. '"')

print("\n" .. string.rep("=", 70))
print("💡 Use 'lua stats_db.lua export data.csv' for detailed Excel analysis")
print("💡 Database: dungeon_stats.db (SQLite format)")
print(string.rep("=", 70))
