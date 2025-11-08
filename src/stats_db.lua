-- stats_db.lua - SQLite stat tracking for balance testing
local M = {}

local DB_FILE = "dungeon_stats.db"

-- Execute SQL command
local function exec_sql(sql, params)
    local cmd = string.format('sqlite3 %s "%s"', DB_FILE, sql:gsub('"', '\\"'))
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result
end

-- Initialize database schema
function M.init_db()
    local schema = [[
CREATE TABLE IF NOT EXISTS playthroughs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_name TEXT,
    character_class TEXT,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    result TEXT,
    final_level INTEGER,
    final_hp INTEGER,
    max_hp INTEGER,
    chambers_explored INTEGER,
    chambers_total INTEGER,
    enemies_defeated INTEGER,
    gold_collected INTEGER,
    xp_gained INTEGER,
    potions_used INTEGER,
    traps_triggered INTEGER,
    deaths INTEGER,
    score INTEGER,
    difficulty TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS combat_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    playthrough_id INTEGER,
    chamber_number INTEGER,
    enemy_type TEXT,
    enemy_hp INTEGER,
    rounds INTEGER,
    damage_dealt INTEGER,
    damage_taken INTEGER,
    result TEXT,
    critical_hits INTEGER,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(playthrough_id) REFERENCES playthroughs(id)
);

CREATE TABLE IF NOT EXISTS chamber_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    playthrough_id INTEGER,
    chamber_number INTEGER,
    chamber_type TEXT,
    event_type TEXT,
    success INTEGER,
    hp_before INTEGER,
    hp_after INTEGER,
    loot_found TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(playthrough_id) REFERENCES playthroughs(id)
);

CREATE TABLE IF NOT EXISTS character_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    playthrough_id INTEGER,
    level INTEGER,
    hp INTEGER,
    max_hp INTEGER,
    ac INTEGER,
    attack_bonus INTEGER,
    damage_bonus INTEGER,
    str INTEGER,
    dex INTEGER,
    con INTEGER,
    int INTEGER,
    wis INTEGER,
    cha INTEGER,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(playthrough_id) REFERENCES playthroughs(id)
);

CREATE TABLE IF NOT EXISTS balance_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    metric_name TEXT,
    metric_value REAL,
    category TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
]]
    
    exec_sql(schema)
    print("✅ Database initialized: " .. DB_FILE)
end

-- Start new playthrough
function M.start_playthrough(char_name, char_class, difficulty)
    difficulty = difficulty or "normal"
    local sql = string.format([[
INSERT INTO playthroughs (character_name, character_class, difficulty, chambers_total)
VALUES ('%s', '%s', '%s', 10);
SELECT last_insert_rowid();
]], char_name, char_class, difficulty)
    
    local result = exec_sql(sql)
    local id = tonumber(result:match("%d+"))
    return id
end

-- Record character stats snapshot
function M.record_stats(playthrough_id, character)
    local sql = string.format([[
INSERT INTO character_stats (playthrough_id, level, hp, max_hp, ac, attack_bonus, damage_bonus, str, dex, con, int, wis, cha)
VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d);
]], playthrough_id, character.level or 1, character.hp, character.max_hp, character.ac,
   character.atk, character.dmg, character.str or 10, character.dex or 10, 
   character.con or 10, character.int or 10, character.wis or 10, character.cha or 10)
   
    exec_sql(sql)
end

-- Record combat event
function M.record_combat(playthrough_id, chamber, enemy_type, enemy_hp, rounds, dmg_dealt, dmg_taken, result, crits)
    crits = crits or 0
    local sql = string.format([[
INSERT INTO combat_events (playthrough_id, chamber_number, enemy_type, enemy_hp, rounds, damage_dealt, damage_taken, result, critical_hits)
VALUES (%d, %d, '%s', %d, %d, %d, %d, '%s', %d);
]], playthrough_id, chamber, enemy_type, enemy_hp, rounds, dmg_dealt, dmg_taken, result, crits)
    
    exec_sql(sql)
end

-- Record chamber event
function M.record_chamber(playthrough_id, chamber, chamber_type, event_type, success, hp_before, hp_after, loot)
    success = success and 1 or 0
    loot = loot or ""
    local sql = string.format([[
INSERT INTO chamber_events (playthrough_id, chamber_number, chamber_type, event_type, success, hp_before, hp_after, loot_found)
VALUES (%d, %d, '%s', '%s', %d, %d, %d, '%s');
]], playthrough_id, chamber, chamber_type, event_type, success, hp_before, hp_after, loot)
    
    exec_sql(sql)
end

-- End playthrough
function M.end_playthrough(playthrough_id, result, character, stats)
    stats = stats or {}
    local sql = string.format([[
UPDATE playthroughs SET
    end_time = CURRENT_TIMESTAMP,
    result = '%s',
    final_level = %d,
    final_hp = %d,
    max_hp = %d,
    chambers_explored = %d,
    enemies_defeated = %d,
    gold_collected = %d,
    xp_gained = %d,
    potions_used = %d,
    traps_triggered = %d,
    deaths = %d,
    score = %d
WHERE id = %d;
]], result, character.level or 1, character.hp, character.max_hp,
   stats.chambers or 0, stats.enemies or 0, stats.gold or 0,
   stats.xp or 0, stats.potions_used or 0, stats.traps or 0,
   stats.deaths or 0, stats.score or 0, playthrough_id)
   
    exec_sql(sql)
end

-- Record balance metric
function M.record_metric(name, value, category)
    category = category or "general"
    local sql = string.format([[
INSERT INTO balance_metrics (metric_name, metric_value, category)
VALUES ('%s', %f, '%s');
]], name, value, category)
    
    exec_sql(sql)
end

-- Get win rate
function M.get_win_rate(char_class, difficulty)
    local where = ""
    if char_class then
        where = string.format(" WHERE character_class = '%s'", char_class)
        if difficulty then
            where = where .. string.format(" AND difficulty = '%s'", difficulty)
        end
    elseif difficulty then
        where = string.format(" WHERE difficulty = '%s'", difficulty)
    end
    
    local sql = string.format([[
SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) as wins
FROM playthroughs%s;
]], where)
    
    local result = exec_sql(sql)
    local total, wins = result:match("(%d+)|(%d+)")
    if total and wins then
        total, wins = tonumber(total), tonumber(wins)
        if total > 0 then
            return wins / total * 100, wins, total
        end
    end
    return 0, 0, 0
end

-- Get combat statistics
function M.get_combat_stats(enemy_type)
    local where = enemy_type and string.format(" WHERE enemy_type = '%s'", enemy_type) or ""
    local sql = string.format([[
SELECT 
    COUNT(*) as total_fights,
    AVG(rounds) as avg_rounds,
    AVG(damage_dealt) as avg_dmg_dealt,
    AVG(damage_taken) as avg_dmg_taken,
    SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as win_rate
FROM combat_events%s;
]], where)
    
    local result = exec_sql(sql)
    return result
end

-- Generate balance report
function M.generate_report()
    print("\n" .. string.rep("=", 70))
    print("📊 BALANCE & PLAYTEST REPORT")
    print(string.rep("=", 70))
    
    -- Overall stats
    local overall = exec_sql([[
SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) as wins,
    AVG(chambers_explored) as avg_chambers,
    AVG(enemies_defeated) as avg_enemies,
    AVG(score) as avg_score
FROM playthroughs;
]])
    
    print("\n📈 OVERALL STATISTICS:")
    print(overall:gsub("|", " | "))
    
    -- Win rate by class
    print("\n🎭 WIN RATE BY CLASS:")
    local by_class = exec_sql([[
SELECT 
    character_class,
    COUNT(*) as runs,
    SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as win_rate
FROM playthroughs
GROUP BY character_class
ORDER BY win_rate DESC;
]])
    print(by_class:gsub("|", " | "))
    
    -- Combat stats by enemy
    print("\n⚔️  COMBAT STATS BY ENEMY:")
    local by_enemy = exec_sql([[
SELECT 
    enemy_type,
    COUNT(*) as encounters,
    AVG(rounds) as avg_rounds,
    SUM(CASE WHEN result = 'victory' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as win_rate
FROM combat_events
GROUP BY enemy_type
ORDER BY encounters DESC
LIMIT 10;
]])
    print(by_enemy:gsub("|", " | "))
    
    -- Deadly chambers
    print("\n💀 MOST DANGEROUS CHAMBER TYPES:")
    local deadly = exec_sql([[
SELECT 
    ce.chamber_type,
    COUNT(*) as visits,
    SUM(ce.hp_before - ce.hp_after) as total_hp_lost,
    AVG(ce.hp_before - ce.hp_after) as avg_hp_lost
FROM chamber_events ce
GROUP BY ce.chamber_type
ORDER BY avg_hp_lost DESC
LIMIT 5;
]])
    print(deadly:gsub("|", " | "))
    
    print("\n" .. string.rep("=", 70))
end

-- Export data to CSV
function M.export_csv(filename)
    filename = filename or "playthrough_data.csv"
    os.execute(string.format('sqlite3 -header -csv %s "SELECT * FROM playthroughs;" > %s', DB_FILE, filename))
    print("✅ Data exported to: " .. filename)
end

-- Clear all data (for testing)
function M.clear_all()
    exec_sql("DELETE FROM combat_events;")
    exec_sql("DELETE FROM chamber_events;")
    exec_sql("DELETE FROM character_stats;")
    exec_sql("DELETE FROM playthroughs;")
    exec_sql("DELETE FROM balance_metrics;")
    print("✅ All data cleared")
end

-- CLI interface
if arg and arg[1] then
    local cmd = arg[1]
    
    if cmd == "init" then
        M.init_db()
    elseif cmd == "report" then
        M.generate_report()
    elseif cmd == "winrate" then
        local class = arg[2]
        local diff = arg[3]
        local rate, wins, total = M.get_win_rate(class, diff)
        print(string.format("Win Rate: %.1f%% (%d/%d)", rate, wins, total))
    elseif cmd == "export" then
        M.export_csv(arg[2])
    elseif cmd == "clear" then
        print("⚠️  This will delete ALL tracking data. Continue? (yes/no)")
        local confirm = io.read()
        if confirm == "yes" then
            M.clear_all()
        else
            print("Cancelled")
        end
    else
        print([[
Stats Database - Usage:

  lua stats_db.lua init              - Initialize database
  lua stats_db.lua report             - Generate balance report
  lua stats_db.lua winrate [class] [difficulty] - Show win rate
  lua stats_db.lua export [file.csv] - Export data to CSV
  lua stats_db.lua clear              - Clear all data (with confirmation)

Integration (in your Lua code):
  local stats = require('stats_db')
  stats.init_db()
  
  -- Start playthrough
  local id = stats.start_playthrough("Bimbo", "Rogue", "hard")
  
  -- Record events
  stats.record_combat(id, chamber, "goblin", 10, 3, 15, 5, "victory", 1)
  stats.record_chamber(id, chamber, "trap_room", "trap", true, 30, 25, "20gp")
  
  -- End playthrough
  stats.end_playthrough(id, "victory", character, stats_table)
  
  -- Generate report
  stats.generate_report()
]])
    end
end

return M
