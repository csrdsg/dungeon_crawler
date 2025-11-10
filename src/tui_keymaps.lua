-- TUI Keymaps Configuration
-- Centralized keymap configuration for easy customization with context-aware local keymaps

local Keymaps = {}

-- Main Menu Keys
Keymaps.main_menu = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    quit = "q"
}

-- Game Screen Keys
Keymaps.game = {
    move = "m",
    inventory = "i",
    search = "s",
    rest = "r",
    save = "w",
    quit = "q",
    use_potion = "p",
    dismiss_ai = "d",
    quest_log = "l"
}

-- Combat Keys
Keymaps.combat = {
    attack = "a",
    cast_spell = "c",
    use_potion = "p",
    run = "r"
}

-- Navigation Keys (universal)
Keymaps.navigation = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    cancel = "\27",
    back = "\27"
}

-- Inventory Keys
Keymaps.inventory = {
    close = "i",
    use_potion = "p",
    cancel = "\27"
}

-- Move Screen Keys
Keymaps.move = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    cancel = "\27"
}

-- Search Screen Keys
Keymaps.search = {
    search = "\n",
    cancel = "\27",
    close = "s"
}

-- Spell Select Keys
Keymaps.spell_select = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    cancel = "\27"
}

-- Quest Log Keys
Keymaps.quest_log = {
    close = "l",
    cancel = "\27"
}

-- Character Creation Keys
Keymaps.character_creation = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    cancel = "\27"
}

-- Dungeon Size Keys
Keymaps.dungeon_size = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    cancel = "\27"
}

-- Load Menu Keys
Keymaps.load_menu = {
    up = "\27[A",
    down = "\27[B",
    select = "\n",
    cancel = "\27"
}

-- Game Over Keys
Keymaps.game_over = {
    new_game = "n",
    main_menu = "m",
    quit = "q"
}

-- Victory Keys
Keymaps.victory = {
    new_game = "n",
    main_menu = "m",
    quit = "q"
}

-- Context-aware keymap descriptions
-- Maps game states to human-readable keybinding descriptions
Keymaps.descriptions = {
    main_menu = {
        {key = "↑↓", desc = "Navigate"},
        {key = "Enter", desc = "Select"},
        {key = "Q", desc = "Quit"}
    },

    character_creation = {
        {key = "↑↓", desc = "Browse Classes"},
        {key = "Enter", desc = "Select Class"},
        {key = "Esc", desc = "Back"}
    },

    dungeon_size = {
        {key = "↑↓", desc = "Choose Size"},
        {key = "Enter", desc = "Start Game"},
        {key = "Esc", desc = "Back"}
    },

    load_menu = {
        {key = "↑↓", desc = "Browse Saves"},
        {key = "Enter", desc = "Load Game"},
        {key = "Esc", desc = "Back"}
    },

    game = {
        {key = "M", desc = "Move"},
        {key = "I", desc = "Inventory"},
        {key = "S", desc = "Search"},
        {key = "R", desc = "Rest"},
        {key = "P", desc = "Use Potion"},
        {key = "L", desc = "Quest Log"},
        {key = "W", desc = "Save Game"},
        {key = "Q", desc = "Main Menu"}
    },

    combat = {
        {key = "A", desc = "Attack"},
        {key = "C", desc = "Cast Spell"},
        {key = "P", desc = "Use Potion"},
        {key = "R", desc = "Run Away"}
    },

    spell_select = {
        {key = "↑↓", desc = "Select Spell"},
        {key = "Enter", desc = "Cast"},
        {key = "Esc", desc = "Cancel"}
    },

    move = {
        {key = "↑↓", desc = "Select Chamber"},
        {key = "Enter", desc = "Move"},
        {key = "Esc", desc = "Cancel"}
    },

    inventory = {
        {key = "P", desc = "Use Potion"},
        {key = "I/Esc", desc = "Close"}
    },

    search = {
        {key = "Enter", desc = "Search"},
        {key = "S/Esc", desc = "Close"}
    },

    quest_log = {
        {key = "L/Esc", desc = "Close"}
    },

    game_over = {
        {key = "N", desc = "New Game"},
        {key = "M", desc = "Main Menu"},
        {key = "Q", desc = "Quit"}
    },

    victory = {
        {key = "N", desc = "New Game"},
        {key = "M", desc = "Main Menu"},
        {key = "Q", desc = "Quit"}
    }
}

-- Helper function to check if a key matches a keymap action
function Keymaps.matches(key, action_table, action_name)
    local mapping = action_table[action_name]
    if not mapping then return false end

    if type(mapping) == "string" then
        return key == mapping or key:lower() == mapping:lower()
    elseif type(mapping) == "table" then
        for _, k in ipairs(mapping) do
            if key == k or key:lower() == k:lower() then
                return true
            end
        end
    end

    return false
end

-- Check if key is arrow up
function Keymaps.is_up(key, next1, next2)
    return key == "\27" and next1 == "[" and next2 == "A"
end

-- Check if key is arrow down
function Keymaps.is_down(key, next1, next2)
    return key == "\27" and next1 == "[" and next2 == "B"
end

-- Check if key is ESC (escape only, not arrow)
function Keymaps.is_escape_only(key, next1)
    return key == "\27" and (next1 ~= "[" or next1 == nil)
end

-- Get formatted keybindings for a context
-- Returns a string suitable for display in status line or footer
function Keymaps.get_context_help(context, compact)
    local descriptions = Keymaps.descriptions[context]
    if not descriptions then return "" end

    if compact then
        -- Compact format: "Key:Action | Key:Action"
        local parts = {}
        for _, binding in ipairs(descriptions) do
            table.insert(parts, string.format("%s:%s", binding.key, binding.desc))
        end
        return table.concat(parts, " | ")
    else
        -- Full format with more spacing
        local parts = {}
        for _, binding in ipairs(descriptions) do
            table.insert(parts, string.format("[%s] %s", binding.key, binding.desc))
        end
        return table.concat(parts, "  ")
    end
end

-- Get active context name (for status line display)
function Keymaps.get_context_name(state)
    local context_names = {
        main_menu = "Main Menu",
        character_creation = "Character Creation",
        dungeon_size = "Dungeon Setup",
        load_menu = "Load Game",
        game = "Exploring",
        combat = "Combat",
        spell_select = "Spell Selection",
        move = "Movement",
        inventory = "Inventory",
        search = "Search Chamber",
        quest_log = "Quest Log",
        game_over = "Game Over",
        victory = "Victory"
    }

    return context_names[state] or state
end

return Keymaps
