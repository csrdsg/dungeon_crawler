-- State Manager Module
-- Fast, efficient character and mission state tracking system
-- Supports JSON-like serialization for easy load/unload

local StateManager = {}

-- Version for save format
StateManager.VERSION = "STATE_V2"

-- State directories
StateManager.DIRS = {
    characters = "data/characters/",
    missions = "data/missions/",
    sessions = "data/sessions/"
}

-- Ensure directories exist (pure Lua)
local function mkdir_p(path)
    local parts = {}
    for part in path:gmatch("[^/]+") do
        table.insert(parts, part)
    end
    
    local current = ""
    for _, part in ipairs(parts) do
        current = current .. part .. "/"
        local f = io.open(current .. ".test", "w")
        if f then
            f:close()
            os.remove(current .. ".test")
        else
            -- Try to create directory using Lua's os.execute as fallback
            -- This is the minimal shell usage we need for directory creation
            os.execute("mkdir -p " .. current)
        end
    end
end

function StateManager.init()
    for _, dir in pairs(StateManager.DIRS) do
        mkdir_p(dir)
    end
end

-- Serialize a Lua table to a compact string format
local function serialize(t, indent)
    indent = indent or 0
    local result = {}
    local spacing = string.rep("  ", indent)
    
    if type(t) ~= "table" then
        if type(t) == "string" then
            return string.format("%q", t)
        elseif type(t) == "boolean" then
            return tostring(t)
        else
            return tostring(t)
        end
    end
    
    table.insert(result, "{\n")
    for k, v in pairs(t) do
        local key
        if type(k) == "string" then
            key = k
        else
            key = "[" .. tostring(k) .. "]"
        end
        
        if type(v) == "table" then
            table.insert(result, spacing .. "  " .. key .. " = " .. serialize(v, indent + 1) .. ",\n")
        elseif type(v) == "string" then
            table.insert(result, spacing .. "  " .. key .. " = " .. string.format("%q", v) .. ",\n")
        elseif type(v) == "boolean" then
            table.insert(result, spacing .. "  " .. key .. " = " .. tostring(v) .. ",\n")
        else
            table.insert(result, spacing .. "  " .. key .. " = " .. tostring(v) .. ",\n")
        end
    end
    table.insert(result, spacing .. "}")
    
    return table.concat(result)
end

-- Deserialize a Lua table from string
local function deserialize(str)
    local func, err = load("return " .. str)
    if not func then
        return nil, err
    end
    local ok, result = pcall(func)
    if not ok then
        return nil, result
    end
    return result
end

-- Character State Management
function StateManager.save_character(char_id, character_data)
    local filename = StateManager.DIRS.characters .. char_id .. ".lua"
    local file = io.open(filename, "w")
    if not file then
        return false, "Could not create file: " .. filename
    end
    
    local state = {
        version = StateManager.VERSION,
        char_id = char_id,
        saved_at = os.time(),
        data = character_data
    }
    
    file:write("-- Character: " .. char_id .. "\n")
    file:write("-- Saved: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("return " .. serialize(state) .. "\n")
    file:close()
    
    return true
end

function StateManager.load_character(char_id)
    local filename = StateManager.DIRS.characters .. char_id .. ".lua"
    local file = io.open(filename, "r")
    if not file then
        return nil, "Character not found: " .. char_id
    end
    
    local content = file:read("*a")
    file:close()
    
    local state = deserialize(content:match("return (.+)"))
    if not state or state.version ~= StateManager.VERSION then
        return nil, "Invalid or incompatible character file"
    end
    
    return state.data
end

-- List files in directory (pure Lua alternative)
local function list_files(directory, pattern)
    local files = {}
    local lfs_ok, lfs = pcall(require, "lfs")
    
    if lfs_ok then
        -- Use LuaFileSystem if available
        for file in lfs.dir(directory) do
            if file ~= "." and file ~= ".." and file:match(pattern) then
                table.insert(files, file)
            end
        end
    else
        -- Fallback to shell command
        local handle = io.popen("ls " .. directory .. pattern .. " 2>/dev/null")
        if handle then
            for filename in handle:lines() do
                local file = filename:match("([^/]+)$")
                if file then
                    table.insert(files, file)
                end
            end
            handle:close()
        end
    end
    
    return files
end

function StateManager.list_characters()
    local chars = {}
    local files = list_files(StateManager.DIRS.characters, "*.lua")
    
    for _, filename in ipairs(files) do
        local char_id = filename:match("^(.+)%.lua$")
        if char_id and char_id ~= ".gitkeep" then
            table.insert(chars, char_id)
        end
    end
    
    return chars
end

function StateManager.delete_character(char_id)
    local filename = StateManager.DIRS.characters .. char_id .. ".lua"
    return os.remove(filename)
end

-- Mission/Quest State Management
function StateManager.save_mission(mission_id, mission_data)
    local filename = StateManager.DIRS.missions .. mission_id .. ".lua"
    local file = io.open(filename, "w")
    if not file then
        return false, "Could not create file: " .. filename
    end
    
    local state = {
        version = StateManager.VERSION,
        mission_id = mission_id,
        saved_at = os.time(),
        data = mission_data
    }
    
    file:write("-- Mission: " .. mission_id .. "\n")
    file:write("-- Saved: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("return " .. serialize(state) .. "\n")
    file:close()
    
    return true
end

function StateManager.load_mission(mission_id)
    local filename = StateManager.DIRS.missions .. mission_id .. ".lua"
    local file = io.open(filename, "r")
    if not file then
        return nil, "Mission not found: " .. mission_id
    end
    
    local content = file:read("*a")
    file:close()
    
    local state = deserialize(content:match("return (.+)"))
    if not state or state.version ~= StateManager.VERSION then
        return nil, "Invalid or incompatible mission file"
    end
    
    return state.data
end

function StateManager.list_missions()
    local missions = {}
    local files = list_files(StateManager.DIRS.missions, "*.lua")
    
    for _, filename in ipairs(files) do
        local mission_id = filename:match("^(.+)%.lua$")
        if mission_id and mission_id ~= ".gitkeep" then
            table.insert(missions, mission_id)
        end
    end
    
    return missions
end

-- Game Session Management (combines character + dungeon + quests)
function StateManager.save_session(session_id, session_data)
    local filename = StateManager.DIRS.sessions .. session_id .. ".lua"
    local file = io.open(filename, "w")
    if not file then
        return false, "Could not create file: " .. filename
    end
    
    local state = {
        version = StateManager.VERSION,
        session_id = session_id,
        saved_at = os.time(),
        data = {
            player = session_data.player,
            dungeon = session_data.dungeon,
            quest_log = session_data.quest_log,
            metadata = session_data.metadata or {}
        }
    }
    
    file:write("-- Session: " .. session_id .. "\n")
    file:write("-- Saved: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("return " .. serialize(state) .. "\n")
    file:close()
    
    return true
end

function StateManager.load_session(session_id)
    local filename = StateManager.DIRS.sessions .. session_id .. ".lua"
    local file = io.open(filename, "r")
    if not file then
        return nil, "Session not found: " .. session_id
    end
    
    local content = file:read("*a")
    file:close()
    
    local state = deserialize(content:match("return (.+)"))
    if not state or state.version ~= StateManager.VERSION then
        return nil, "Invalid or incompatible session file"
    end
    
    return state.data
end

function StateManager.list_sessions()
    local sessions = {}
    local files = list_files(StateManager.DIRS.sessions, "*.lua")
    
    for _, filename in ipairs(files) do
        local session_id = filename:match("^(.+)%.lua$")
        if session_id and session_id ~= ".gitkeep" then
            -- Load session metadata
            local file = io.open(StateManager.DIRS.sessions .. filename, "r")
            if file then
                local content = file:read("*a")
                file:close()
                local state = deserialize(content:match("return (.+)"))
                if state then
                    table.insert(sessions, {
                        id = session_id,
                        saved_at = state.saved_at,
                        saved_date = os.date("%Y-%m-%d %H:%M:%S", state.saved_at),
                        player_name = state.data.player and state.data.player.name or "Unknown"
                    })
                end
            end
        end
    end
    
    return sessions
end

-- Quick save/load for legacy compatibility
function StateManager.quick_save(player, dungeon, quest_log, name)
    name = name or player.name or "default"
    local session_id = name:lower():gsub("%s+", "_")
    
    return StateManager.save_session(session_id, {
        player = player,
        dungeon = dungeon,
        quest_log = quest_log,
        metadata = {
            quick_save = true,
            character_name = player.name
        }
    })
end

function StateManager.quick_load(name)
    local session_id = name:lower():gsub("%s+", "_")
    return StateManager.load_session(session_id)
end

-- Export character template (for reuse across sessions)
function StateManager.export_character_template(player, template_name)
    local char_data = {
        name = player.name,
        max_hp = player.max_hp,
        ac = player.ac,
        attack_bonus = player.attack_bonus,
        damage = player.damage,
        class = player.class,
        level = player.level or 1,
        template = true
    }
    
    return StateManager.save_character(template_name, char_data)
end

-- Import character from template
function StateManager.import_character_template(template_name)
    local template = StateManager.load_character(template_name)
    if not template then
        return nil
    end
    
    -- Create fresh character from template
    return {
        name = template.name,
        hp = template.max_hp,
        max_hp = template.max_hp,
        ac = template.ac,
        attack_bonus = template.attack_bonus,
        damage = template.damage,
        class = template.class,
        level = template.level or 1,
        gold = 0,
        potions = 3,
        items = {}
    }
end

return StateManager
