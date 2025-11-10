#!/usr/bin/env lua
-- Dungeon Crawler TUI (Text User Interface)
-- Refactored: UI and game logic separated

-- Force unbuffered output
io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

-- Load modules
local StateManager = require("src.state_manager")
local Renderer = require("src.tui_renderer")
local GameLogic = require("src.game_logic")
local Keymaps = require("src.tui_keymaps")
local Progression = require("src.tui_progression")
local Effects = require("src.tui_effects")
local QuestUI = require("src.tui_quest_ui")

-- Load game data files
local function load_data_safe(path)
    local ok, data = pcall(dofile, path)
    if ok then return data end
    return nil
end

local function load_module_safe(name)
    local ok, module = pcall(require, name)
    if ok then return module end
    return nil
end

-- Data files
local EncounterData = load_data_safe("data/encounters.lua")
local LootData = load_data_safe("data/loot_tables.lua")
local ChamberArt = load_data_safe("data/chamber_art.lua")
local TUIConfig = load_data_safe("data/tui_config.lua")
local EnemyStats = load_data_safe("data/enemy_stats.lua")
local SpellData = load_data_safe("data/spells.lua")
local CharacterClasses = load_data_safe("data/character_classes.lua")
local EnemyArt = load_data_safe("data/enemy_art.lua")

-- Load AI Storyteller (optional)
local AIStoryteller = load_module_safe("src.ai_storyteller")
if AIStoryteller then
    local ai_enabled = AIStoryteller.init({
        enabled = true,
        provider = "ollama",
        model = nil,  -- Auto-detect
        use_static_on_error = true,
        timeout = 3
    })
    if ai_enabled then
        print("🤖 AI Storyteller ready!")
    end
end

-- Initialize
StateManager.init()

-- Initialize responsive screen (detect terminal size)
Renderer.init_screen()

-- Game State
local game = {
    state = "main_menu",
    selected_menu = 1,
    selected_class = 1,
    dungeon_size = 20,
    player = nil,
    dungeon = nil,
    quest_log = nil,
    message = "",
    session_list = {},
    combat_state = nil,
    move_selection = 1,
    inventory_selection = 1,
    selected_spell = 1,
    log = {},
    ai_description = nil,
    show_ai_pane = false,
    game_over_reason = nil,
    game_over_stats = nil,
    victory_stats = nil,
    show_screen_warning = false
}

-- Helper: Add to message log
function game:add_log(message)
    table.insert(self.log, 1, message)
    if #self.log > 10 then
        table.remove(self.log)
    end
    self.message = message
end

-- Load available sessions
function game:load_sessions()
    self.session_list = StateManager.list_sessions()
    table.sort(self.session_list, function(a, b) return a.saved_at > b.saved_at end)
end

-- SCREEN DRAWING FUNCTIONS

function game:draw_main_menu()
    Renderer.clear_screen()
    Renderer.responsive_header()

    -- Responsive box positioning
    local screen_info = Renderer.get_screen_info()
    local box_width = math.min(50, screen_info.cols - 20)
    local box_height = 12
    local box_x = math.floor((screen_info.cols - box_width) / 2)
    local box_y = math.floor((screen_info.rows - box_height) / 2) - 2

    Renderer.responsive_box(box_x, box_y, box_width, box_height, "MAIN MENU")

    local options = {
        "New Game",
        "Load Game",
        "Character Templates",
        "Statistics",
        "Quit"
    }

    Renderer.responsive_menu(box_x + 3, box_y + 2, options, self.selected_menu)

    if self.message ~= "" then
        local msg_y = math.min(screen_info.rows - 5, box_y + box_height + 2)
        Renderer.text(4, msg_y, Renderer.colors.yellow .. "  " .. self.message .. Renderer.colors.reset)
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("main_menu")
    local help_text = Keymaps.get_context_help("main_menu")
    Renderer.responsive_footer(help_text, context_name)
end

function game:draw_load_menu()
    Renderer.clear_screen()
    Renderer.draw_header()

    Renderer.box(20, 6, 60, 15, "LOAD GAME")

    if #self.session_list == 0 then
        Renderer.text(35, 12, "No saved games found", Renderer.colors.yellow)
        Renderer.text(30, 14, "Press any key to return...", Renderer.colors.dim)
    else
        local options = {}
        for i, session in ipairs(self.session_list) do
            table.insert(options, string.format("%-15s | %s", session.player_name, session.saved_date))
        end
        table.insert(options, "< Back >")

        Renderer.menu(23, 8, options, self.selected_menu)
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("load_menu")
    local help_text = Keymaps.get_context_help("load_menu")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_character_panel()
    if not self.player then return end
    
    Renderer.box(2, 5, 35, 18, "CHARACTER")
    
    -- Name and Level
    local level_text = self.player.level and string.format(" (Lvl %d)", self.player.level) or ""
    Renderer.text(4, 7, Renderer.colors.bold .. self.player.name .. level_text .. Renderer.colors.reset)
    
    -- HP Bar
    Renderer.progress_bar(4, 9, self.player.hp, self.player.max_hp, 25, "HP: ")
    
    -- XP Bar (if progression is active)
    if self.player.xp and self.player.level then
        local xp_current = Progression.get_current_level_xp(self.player)
        local xp_needed = Progression.get_xp_needed(self.player)
        Renderer.progress_bar(4, 10, xp_current, xp_needed, 25, "XP: ")
    end
    
    -- Stats
    Renderer.text(4, 12, "AC:     " .. Renderer.colors.cyan .. self.player.ac .. Renderer.colors.reset)
    Renderer.text(4, 13, "Attack: " .. Renderer.colors.yellow .. "+" .. self.player.attack_bonus .. Renderer.colors.reset)
    Renderer.text(4, 14, "Damage: " .. Renderer.colors.red .. self.player.damage .. Renderer.colors.reset)
    
    -- Resources
    Renderer.text(4, 16, "Gold:    " .. Renderer.colors.yellow .. "💰 " .. self.player.gold .. Renderer.colors.reset)
    Renderer.text(4, 17, "Potions: " .. Renderer.colors.green .. "🧪 " .. self.player.potions .. Renderer.colors.reset)
    
    -- Active Effects
    if self.player.effects and #self.player.effects > 0 then
        Renderer.text(4, 19, Renderer.colors.bold .. "Effects:" .. Renderer.colors.reset)
        local effect_list = Effects.get_display_list(self.player)
        for i = 1, math.min(2, #effect_list) do
            Renderer.text(4, 19 + i, "  " .. effect_list[i])
        end
    end
end

function game:draw_dungeon_panel()
    if not self.dungeon then return end
    
    Renderer.box(39, 5, 42, 18, "DUNGEON MAP")
    
    local current_chamber = self.dungeon.chambers[self.dungeon.player_position]
    
    Renderer.text(41, 7, "Current Location: " .. Renderer.colors.yellow .. "Chamber " .. self.dungeon.player_position .. Renderer.colors.reset)
    Renderer.text(41, 8, "Type: " .. Renderer.colors.cyan .. GameLogic.get_chamber_type_name(current_chamber.type) .. Renderer.colors.reset)
    
    Renderer.text(41, 10, Renderer.colors.bold .. "Available Exits:" .. Renderer.colors.reset)
    if #current_chamber.connections > 0 then
        for i, conn_id in ipairs(current_chamber.connections) do
            local conn = self.dungeon.chambers[conn_id]
            local status = conn.visited and Renderer.colors.dim .. "(visited)" .. Renderer.colors.reset or Renderer.colors.green .. "(new)" .. Renderer.colors.reset
            Renderer.text(41, 10 + i, string.format("  → Chamber %d %s", conn_id, status))
        end
    else
        Renderer.text(41, 11, Renderer.colors.red .. "  Dead end!" .. Renderer.colors.reset)
    end
    
    local visited = 0
    for _, chamber in pairs(self.dungeon.chambers) do
        if chamber.visited then visited = visited + 1 end
    end
    
    Renderer.text(41, 17, "Progress:")
    Renderer.progress_bar(41, 18, visited, self.dungeon.num_chambers, 30, "")
end

function game:draw_game_screen()
    Renderer.clear_screen()
    Renderer.responsive_header()

    self:draw_character_panel()
    self:draw_dungeon_panel()

    -- Draw AI description floating pane if available (responsive)
    if self.ai_description and self.show_ai_pane then
        local layout = Renderer.get_layout()
        local text_width = Renderer.get_text_wrap_width()

        -- Word wrap the description
        local wrapped = Renderer.word_wrap(self.ai_description, text_width - 4)

        -- Prepare content lines
        local content_lines = {}
        table.insert(content_lines, "") -- Empty line for padding

        local max_lines = layout.floating_pane_max_height - 4
        for i = 1, math.min(#wrapped, max_lines) do
            table.insert(content_lines, Renderer.colors.cyan .. wrapped[i] .. Renderer.colors.reset)
        end

        -- Add hint at bottom
        if #wrapped > max_lines then
            table.insert(content_lines, Renderer.colors.dim .. "(Text truncated...)" .. Renderer.colors.reset)
        end

        -- Status line for AI pane
        local ai_status = "Press D to dismiss"
        Renderer.responsive_floating_pane("🤖 AI Storyteller", content_lines, "ai", ai_status)
    end

    local screen_info = Renderer.get_screen_info()
    if self.message ~= "" then
        local msg_y = screen_info.rows - 4
        Renderer.text(5, msg_y, Renderer.colors.yellow .. self.message .. Renderer.colors.reset)
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("game")
    local help_text = Keymaps.get_context_help("game", true)  -- Compact format
    Renderer.responsive_footer(help_text, context_name)
end

function game:draw_combat_screen()
    Renderer.clear_screen()
    Renderer.responsive_header()

    local combat = self.combat_state
    local enemy = combat.enemy
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    -- Responsive enemy box
    local enemy_box_width = math.min(50, math.floor(screen_info.cols * 0.6))
    local enemy_box_height = 18
    Renderer.responsive_box(2, 5, enemy_box_width, enemy_box_height, "ENEMY")

    -- Show enemy ASCII art only if screen size allows
    if layout.show_enemy_art and combat.enemy_type and EnemyArt and EnemyArt[combat.enemy_type] then
        local art_data = EnemyArt[combat.enemy_type]
        local art = art_data[1] or ""
        local lines = {}
        for line in art:gmatch("[^\n]+") do
            table.insert(lines, line)
        end

        local max_art_lines = math.min(12, enemy_box_height - 6)
        for i, line in ipairs(lines) do
            if i <= max_art_lines then
                Renderer.text(6, 6 + i, Renderer.colors.red .. line .. Renderer.colors.reset)
            end
        end
    end
    
    Renderer.text(4, 20, Renderer.colors.red .. Renderer.colors.bold .. enemy.name .. Renderer.colors.reset)
    Renderer.progress_bar(4, 21, enemy.hp, enemy.max_hp, 42, "HP: ")
    Renderer.text(4, 22, "AC: " .. Renderer.colors.cyan .. enemy.ac .. Renderer.colors.reset .. 
                   "  ATK: " .. Renderer.colors.yellow .. "+" .. enemy.attack .. Renderer.colors.reset ..
                   "  DMG: " .. Renderer.colors.red .. enemy.damage .. Renderer.colors.reset)
    
    -- Show enemy effects
    if enemy.effects and #enemy.effects > 0 then
        local effect_list = Effects.get_display_list(enemy)
        local effects_text = table.concat(effect_list, " ")
        if #effects_text > 45 then
            effects_text = effects_text:sub(1, 42) .. "..."
        end
        Renderer.text(4, 23, effects_text)
    end
    
    Renderer.box(54, 5, 26, 14, "YOU")
    Renderer.text(56, 7, Renderer.colors.green .. Renderer.colors.bold .. self.player.name .. Renderer.colors.reset)
    Renderer.progress_bar(56, 9, self.player.hp, self.player.max_hp, 20, "HP: ")
    if self.player.mana then
        Renderer.progress_bar(56, 10, self.player.mana, self.player.max_mana, 20, "MP: ")
    end
    Renderer.text(56, 12, "Potions: " .. Renderer.colors.green .. self.player.potions .. Renderer.colors.reset)
    
    -- Show player effects
    if self.player.effects and #self.player.effects > 0 then
        local effect_list = Effects.get_display_list(self.player)
        for i = 1, math.min(2, #effect_list) do
            Renderer.text(56, 13 + i, effect_list[i])
        end
    end
    
    Renderer.box(2, 24, 78, 5, "COMBAT LOG")
    if combat.log then
        for i = 1, math.min(3, #combat.log) do
            Renderer.text(4, 24 + i, combat.log[i])
        end
    end
    
    -- Context-aware footer for combat
    local context_name = Keymaps.get_context_name("combat")
    local help_text = Keymaps.get_context_help("combat")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_move_screen()
    Renderer.clear_screen()
    Renderer.draw_header()

    local current = self.dungeon.chambers[self.dungeon.player_position]

    Renderer.box(20, 6, 60, 16, "CHOOSE DESTINATION")

    Renderer.text(22, 8, "Current: " .. Renderer.colors.yellow .. "Chamber " .. self.dungeon.player_position .. Renderer.colors.reset)
    Renderer.text(22, 9, "Type: " .. Renderer.colors.cyan .. GameLogic.get_chamber_type_name(current.type) .. Renderer.colors.reset)

    Renderer.text(22, 11, Renderer.colors.bold .. "Available Exits:" .. Renderer.colors.reset)

    local options = {}
    for i, conn_id in ipairs(current.connections) do
        local conn = self.dungeon.chambers[conn_id]
        local status = conn.visited and "(visited)" or "(new)"
        local type_name = GameLogic.get_chamber_type_name(conn.type)
        table.insert(options, string.format("Chamber %d - %s %s", conn_id, type_name, status))
    end

    if #options > 0 then
        Renderer.menu(25, 13, options, self.move_selection)
    else
        Renderer.text(25, 13, Renderer.colors.red .. "No exits available!" .. Renderer.colors.reset)
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("move")
    local help_text = Keymaps.get_context_help("move")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_inventory_screen()
    Renderer.clear_screen()
    Renderer.draw_header()

    Renderer.box(15, 5, 70, 20, "INVENTORY")

    Renderer.text(17, 7, Renderer.colors.bold .. "Resources:" .. Renderer.colors.reset)
    Renderer.text(17, 8, "  Gold: " .. Renderer.colors.yellow .. self.player.gold .. Renderer.colors.reset)
    Renderer.text(17, 9, "  Potions: " .. Renderer.colors.green .. self.player.potions .. Renderer.colors.reset .. " [Press P to use]")

    Renderer.text(17, 11, Renderer.colors.bold .. "Items:" .. Renderer.colors.reset)
    if self.player.items and #self.player.items > 0 then
        for i, item in ipairs(self.player.items) do
            Renderer.text(17, 11 + i, "  • " .. item)
        end
    else
        Renderer.text(17, 12, Renderer.colors.dim .. "  No items" .. Renderer.colors.reset)
    end

    Renderer.text(17, 18, Renderer.colors.bold .. "Statistics:" .. Renderer.colors.reset)
    Renderer.text(17, 19, string.format("  HP: %d/%d", self.player.hp, self.player.max_hp))
    Renderer.text(17, 20, "  AC: " .. self.player.ac)
    Renderer.text(17, 21, "  Attack: +" .. self.player.attack_bonus)
    Renderer.text(17, 22, "  Damage: " .. self.player.damage)

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("inventory")
    local help_text = Keymaps.get_context_help("inventory")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_character_creation()
    Renderer.clear_screen()
    Renderer.responsive_header()

    local screen_info = Renderer.get_screen_info()
    local box_width = math.min(80, screen_info.cols - 10)
    local box_height = math.min(24, screen_info.rows - 8)
    local box_x = math.floor((screen_info.cols - box_width) / 2)
    local box_y = 5

    Renderer.responsive_box(box_x, box_y, box_width, box_height, "CREATE CHARACTER")

    Renderer.text(box_x + 2, box_y + 2, Renderer.colors.bold .. "Choose Your Class:" .. Renderer.colors.reset)
    
    if not CharacterClasses then
        Renderer.text(30, 12, Renderer.colors.red .. "Character data not loaded!" .. Renderer.colors.reset)
        return
    end
    
    local classes = {"warrior", "mage", "rogue", "cleric", "ranger", "paladin"}
    local class_names = {}
    for i, class_id in ipairs(classes) do
        local class_data = CharacterClasses[class_id]
        if class_data then
            table.insert(class_names, class_data.icon .. " " .. class_data.name)
        end
    end
    
    Renderer.menu(15, 9, class_names, self.selected_class)
    
    local selected_class_id = classes[self.selected_class]
    local class_data = CharacterClasses[selected_class_id]
    
    if class_data then
        Renderer.box(45, 7, 32, 18, "CLASS INFO")
        
        Renderer.text(47, 9, Renderer.colors.bold .. class_data.icon .. " " .. class_data.name .. Renderer.colors.reset)
        Renderer.text(47, 10, Renderer.colors.dim .. class_data.description .. Renderer.colors.reset)
        
        Renderer.text(47, 12, "Stats:")
        Renderer.text(47, 13, "  HP: " .. Renderer.colors.green .. class_data.hp .. Renderer.colors.reset)
        Renderer.text(47, 14, "  MP: " .. Renderer.colors.cyan .. class_data.mana .. Renderer.colors.reset)
        Renderer.text(47, 15, "  AC: " .. Renderer.colors.yellow .. class_data.ac .. Renderer.colors.reset)
        Renderer.text(47, 16, "  ATK: +" .. class_data.attack_bonus)
        Renderer.text(47, 17, "  DMG: " .. class_data.damage)
        
        Renderer.text(47, 19, "Starting Gold: " .. Renderer.colors.yellow .. class_data.gold .. Renderer.colors.reset)
        Renderer.text(47, 20, "Potions: " .. Renderer.colors.green .. class_data.potions .. Renderer.colors.reset)
        
        if #class_data.spells > 0 then
            Renderer.text(47, 21, "Spells: " .. Renderer.colors.magenta .. #class_data.spells .. Renderer.colors.reset)
        end
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("character_creation")
    local help_text = Keymaps.get_context_help("character_creation")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_dungeon_size()
    Renderer.clear_screen()
    Renderer.draw_header()
    
    Renderer.box(20, 8, 60, 14, "DUNGEON SIZE")
    
    local sizes = {
        {name = "Small (10 chambers)", size = 10},
        {name = "Medium (20 chambers)", size = 20},
        {name = "Large (30 chambers)", size = 30},
        {name = "Huge (50 chambers)", size = 50},
        {name = "Epic (100 chambers)", size = 100}
    }
    
    local size_names = {}
    for _, s in ipairs(sizes) do
        table.insert(size_names, s.name)
    end
    
    Renderer.menu(25, 10, size_names, self.selected_menu)
    
    local selected = sizes[self.selected_menu]
    Renderer.text(25, 16, Renderer.colors.dim .. "Estimated play time:")
    if selected.size <= 10 then
        Renderer.text(25, 17, Renderer.colors.green .. "~10-15 minutes" .. Renderer.colors.reset)
    elseif selected.size <= 30 then
        Renderer.text(25, 17, Renderer.colors.yellow .. "~20-30 minutes" .. Renderer.colors.reset)
    else
        Renderer.text(25, 17, Renderer.colors.red .. "~1+ hour" .. Renderer.colors.reset)
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("dungeon_size")
    local help_text = Keymaps.get_context_help("dungeon_size")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_search_screen()
    Renderer.clear_screen()
    Renderer.draw_header()
    
    if not self.dungeon or not self.dungeon.chambers then
        Renderer.text(30, 12, Renderer.colors.red .. "No dungeon loaded!" .. Renderer.colors.reset)
        local context_name = Keymaps.get_context_name("search")
        Renderer.draw_footer("Press any key to return", context_name)
        return
    end

    local current = self.dungeon.chambers[self.dungeon.player_position]
    if not current then
        Renderer.text(30, 12, Renderer.colors.red .. "Invalid chamber!" .. Renderer.colors.reset)
        local context_name = Keymaps.get_context_name("search")
        Renderer.draw_footer("Press any key to return", context_name)
        return
    end

    Renderer.box(5, 5, 72, 20, "SEARCH CHAMBER " .. current.id)

    if ChamberArt and ChamberArt[current.type] then
        local art_data = ChamberArt[current.type]
        local art = art_data[1] or art_data
        if type(art) == "string" then
            local lines = {}
            for line in art:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            for i, line in ipairs(lines) do
                if i >= 2 and i <= 7 then
                    Renderer.text(15, 5 + i, line)
                end
            end
        end
    end

    Renderer.text(7, 14, Renderer.colors.bold .. "Type: " .. Renderer.colors.reset .. Renderer.colors.cyan .. GameLogic.get_chamber_type_name(current.type) .. Renderer.colors.reset)
    Renderer.text(7, 15, Renderer.colors.bold .. "Status: " .. Renderer.colors.reset .. (current.visited and Renderer.colors.dim .. "Previously explored" or Renderer.colors.green .. "First time here") .. Renderer.colors.reset)

    Renderer.text(7, 17, Renderer.colors.bold .. "Search Results:" .. Renderer.colors.reset)

    if not current.searched then
        Renderer.text(7, 18, Renderer.colors.yellow .. "▶ Press [ENTER] to search this chamber" .. Renderer.colors.reset)
        Renderer.text(7, 19, Renderer.colors.dim .. "  (Each chamber can only be searched once)" .. Renderer.colors.reset)
    else
        Renderer.text(7, 18, Renderer.colors.green .. "✓ Chamber already searched" .. Renderer.colors.reset)
        if current.search_results and #current.search_results > 0 then
            for i, result in ipairs(current.search_results) do
                if result == "Nothing of value" then
                    Renderer.text(7, 19 + i, Renderer.colors.dim .. "  • " .. result .. Renderer.colors.reset)
                else
                    Renderer.text(7, 19 + i, Renderer.colors.yellow .. "  • " .. result .. Renderer.colors.reset)
                end
            end
        else
            Renderer.text(7, 19, Renderer.colors.dim .. "  • Nothing found" .. Renderer.colors.reset)
        end
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("search")
    local help_text = Keymaps.get_context_help("search")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_spell_select()
    Renderer.clear_screen()
    Renderer.draw_header()
    
    Renderer.box(20, 6, 60, 16, "SELECT SPELL")
    
    Renderer.text(22, 8, "Mana: " .. Renderer.colors.cyan .. self.player.mana .. "/" .. self.player.max_mana .. Renderer.colors.reset)
    
    if not self.player.spells or #self.player.spells == 0 then
        Renderer.text(30, 12, Renderer.colors.yellow .. "No spells known!" .. Renderer.colors.reset)
    else
        local spell_options = {}
        for _, spell_id in ipairs(self.player.spells) do
            local spell = SpellData[spell_id]
            if spell then
                local cost_color = self.player.mana >= spell.mana_cost and Renderer.colors.green or Renderer.colors.red
                table.insert(spell_options, string.format("%s %s(Cost: %d MP)%s", 
                    spell.name, cost_color, spell.mana_cost, Renderer.colors.reset))
            end
        end
        table.insert(spell_options, "< Cancel >")
        
        Renderer.menu(25, 10, spell_options, self.selected_spell or 1)
        
        if self.selected_spell and self.selected_spell <= #self.player.spells then
            local spell_id = self.player.spells[self.selected_spell]
            local spell = SpellData[spell_id]
            if spell then
                Renderer.text(22, 18, Renderer.colors.dim .. spell.description .. Renderer.colors.reset)
                if spell.damage then
                    Renderer.text(22, 19, Renderer.colors.dim .. "Damage: " .. spell.damage .. Renderer.colors.reset)
                end
            end
        end
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("spell_select")
    local help_text = Keymaps.get_context_help("spell_select")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_quest_log()
    Renderer.clear_screen()
    Renderer.draw_header()
    
    Renderer.box(5, 5, 70, 22, "QUEST LOG")
    
    if not self.quest_log then
        Renderer.text(20, 12, Renderer.colors.yellow .. "No quest log available" .. Renderer.colors.reset)
        local context_name = Keymaps.get_context_name("quest_log")
        Renderer.draw_footer("Press any key to return", context_name)
        return
    end

    local counts = QuestUI.get_counts(self.quest_log)

    if counts.total == 0 then
        Renderer.text(20, 12, Renderer.colors.dim .. "No quests yet" .. Renderer.colors.reset)
        Renderer.text(20, 13, "Quests will appear as you explore the dungeon")
        local context_name = Keymaps.get_context_name("quest_log")
        local help_text = Keymaps.get_context_help("quest_log")
        Renderer.draw_footer(help_text, context_name)
        return
    end
    
    -- Header with counts
    Renderer.text(7, 7, string.format("Active: %s%d%s | Completed: %s%d%s | Failed: %s%d%s",
        Renderer.colors.green, counts.active, Renderer.colors.reset,
        Renderer.colors.cyan, counts.completed, Renderer.colors.reset,
        Renderer.colors.red, counts.failed, Renderer.colors.reset))
    
    -- Show active quests
    local y = 9
    if counts.active > 0 then
        Renderer.text(7, y, Renderer.colors.bold .. "📜 Active Quests:" .. Renderer.colors.reset)
        y = y + 1
        
        for _, quest in ipairs(self.quest_log.active or {}) do
            local quest_lines = QuestUI.format_quest(quest)
            for _, line in ipairs(quest_lines) do
                if y <= 24 then
                    Renderer.text(7, y, line)
                    y = y + 1
                end
            end
            y = y + 1 -- Spacing
        end
    end
    
    -- Show completed quests (limited)
    if counts.completed > 0 and y <= 20 then
        Renderer.text(7, y, Renderer.colors.bold .. Renderer.colors.dim .. "✅ Completed:" .. Renderer.colors.reset)
        y = y + 1
        
        for i, quest in ipairs(self.quest_log.completed or {}) do
            if i <= 2 and y <= 24 then
                Renderer.text(7, y, string.format("  %s", quest.title or "Unknown"))
                y = y + 1
            end
        end
    end

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("quest_log")
    local help_text = Keymaps.get_context_help("quest_log")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_game_over()
    Renderer.clear_screen()
    Renderer.draw_header()
    
    -- Main game over box
    Renderer.box(15, 6, 50, 16, "")
    
    -- Skull art
    local skull = {
        "    ___________    ",
        "   /           \\   ",
        "  |  X     X   |  ",
        "  |     ^      |  ",
        "  |   \\___/    |  ",
        "   \\_________/    "
    }
    
    for i, line in ipairs(skull) do
        Renderer.text(28, 8 + i, Renderer.colors.red .. line .. Renderer.colors.reset)
    end
    
    -- Game Over text
    Renderer.text(27, 15, Renderer.colors.red .. Renderer.colors.bold .. "GAME OVER" .. Renderer.colors.reset)
    
    -- Reason
    if self.game_over_reason then
        Renderer.text(20, 17, Renderer.colors.yellow .. self.game_over_reason .. Renderer.colors.reset)
    end
    
    -- Stats summary
    if self.game_over_stats then
        local stats = self.game_over_stats
        local y = 19
        
        Renderer.text(20, y, Renderer.colors.dim .. "Final Statistics:" .. Renderer.colors.reset)
        y = y + 1
        
        if stats.level then
            Renderer.text(22, y, string.format("Level Reached: %s%d%s", 
                Renderer.colors.cyan, stats.level, Renderer.colors.reset))
            y = y + 1
        end
        
        if stats.chambers_explored then
            Renderer.text(22, y, string.format("Chambers Explored: %s%d%s", 
                Renderer.colors.green, stats.chambers_explored, Renderer.colors.reset))
            y = y + 1
        end
        
        if stats.enemies_defeated then
            Renderer.text(22, y, string.format("Enemies Defeated: %s%d%s", 
                Renderer.colors.yellow, stats.enemies_defeated, Renderer.colors.reset))
            y = y + 1
        end
        
        if stats.gold_collected then
            Renderer.text(22, y, string.format("Gold Collected: %s%d%s", 
                Renderer.colors.yellow, stats.gold_collected, Renderer.colors.reset))
            y = y + 1
        end
    end
    
    -- Options
    Renderer.box(15, 24, 50, 3, "")
    Renderer.text(20, 25, "[N]ew Game    [M]ain Menu    [Q]uit to Desktop")

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("game_over")
    local help_text = Keymaps.get_context_help("game_over")
    Renderer.draw_footer(help_text, context_name)
end

function game:draw_victory()
    Renderer.clear_screen()
    Renderer.draw_header()

    -- Main victory box
    Renderer.box(15, 6, 50, 16, "")

    -- Trophy/celebration art
    local trophy = {
        "       ___________       ",
        "      '._==_==_=_.'      ",
        "      .-\\:      /-.     ",
        "     | (|:.     |) |     ",
        "      '-|:.     |-'      ",
        "        \\::.    /        ",
        "         '::. .'         ",
        "           ) (           ",
        "         _.' '._         ",
        "        '-------'        "
    }

    for i, line in ipairs(trophy) do
        Renderer.text(23, 7 + i, Renderer.colors.yellow .. line .. Renderer.colors.reset)
    end

    -- Victory text
    Renderer.text(25, 18, Renderer.colors.yellow .. Renderer.colors.bold .. "VICTORY!" .. Renderer.colors.reset)
    Renderer.text(20, 19, Renderer.colors.green .. "You conquered the dungeon!" .. Renderer.colors.reset)

    -- Stats summary
    if self.victory_stats then
        local stats = self.victory_stats
        local y = 24

        Renderer.box(10, 23, 60, 11, "")

        Renderer.text(12, y + 1, Renderer.colors.bold .. "Final Statistics:" .. Renderer.colors.reset)
        y = y + 2

        if stats.level then
            Renderer.text(14, y, string.format("Final Level: %s%d%s",
                Renderer.colors.cyan, stats.level, Renderer.colors.reset))
            y = y + 1
        end

        if stats.chambers_explored then
            Renderer.text(14, y, string.format("Chambers Cleared: %s%d/%d (100%%!)%s",
                Renderer.colors.green, stats.chambers_explored, stats.total_chambers, Renderer.colors.reset))
            y = y + 1
        end

        if stats.enemies_defeated then
            Renderer.text(14, y, string.format("Enemies Defeated: %s%d%s",
                Renderer.colors.yellow, stats.enemies_defeated, Renderer.colors.reset))
            y = y + 1
        end

        if stats.gold_collected then
            Renderer.text(14, y, string.format("Gold Collected: %s%d%s",
                Renderer.colors.yellow, stats.gold_collected, Renderer.colors.reset))
            y = y + 1
        end

        if stats.final_hp then
            Renderer.text(14, y, string.format("Remaining HP: %s%d/%d%s",
                Renderer.colors.green, stats.final_hp, stats.max_hp, Renderer.colors.reset))
            y = y + 1
        end

        if stats.potions_remaining then
            Renderer.text(14, y, string.format("Potions Left: %s%d%s",
                Renderer.colors.green, stats.potions_remaining, Renderer.colors.reset))
        end
    end

    -- Options
    Renderer.box(15, 35, 50, 3, "")
    Renderer.text(20, 36, "[N]ew Game    [M]ain Menu    [Q]uit to Desktop")

    -- Context-aware footer
    local context_name = Keymaps.get_context_name("victory")
    local help_text = Keymaps.get_context_help("victory")
    Renderer.draw_footer(help_text, context_name)
end

-- GAME LOGIC FUNCTIONS

function game:new_game()
    local classes = {"warrior", "mage", "rogue", "cleric", "ranger", "paladin"}
    local class_id = classes[self.selected_class] or "warrior"
    
    self.player = GameLogic.create_player(class_id, CharacterClasses)
    if not self.player then
        self:add_log("Character data not loaded!")
        return
    end
    
    -- Initialize progression system
    Progression.init_player(self.player)
    
    -- Initialize effects system
    Effects.init_entity(self.player)
    
    self.dungeon = GameLogic.generate_dungeon(self.dungeon_size)
    self.quest_log = {active = {}, completed = {}, failed = {}}
    self.state = "game"
    self:add_log("Welcome, " .. self.player.name .. "! Your adventure begins...")
    
    -- Try to get AI description for starting chamber
    local start_chamber = self.dungeon.chambers[1]
    if start_chamber then
        local description = self:get_chamber_description(start_chamber)
        if description then
            self.ai_description = description
            self.show_ai_pane = true
        end
    end
end

function game:load_game(session_id)
    local session = StateManager.load_session(session_id)
    if session then
        self.player = session.player
        self.dungeon = session.dungeon
        self.quest_log = session.quest_log or {active = {}, completed = {}, failed = {}}
        
        -- Ensure progression/effects are initialized
        Progression.init_player(self.player)
        Effects.init_entity(self.player)
        
        self.state = "game"
        self.message = "Game loaded successfully!"
    else
        self.message = "Failed to load game!"
    end
end

function game:save_game()
    if self.player and self.dungeon then
        local success = StateManager.quick_save(self.player, self.dungeon, self.quest_log)
        if success then
            self.message = "Game saved!"
        else
            self.message = "Save failed!"
        end
    end
end

function game:rest()
    local heal, has_encounter = GameLogic.rest(self.player, TUIConfig)
    self:add_log(string.format("Rested and healed %d HP!", heal))
    
    if has_encounter then
        self:add_log("A creature disturbs your rest!")
        self:start_combat()
    end
end

function game:use_potion()
    local heal, success = GameLogic.use_potion(self.player, TUIConfig)
    if success then
        self:add_log(string.format("Used potion! Healed %d HP", heal))
    else
        self:add_log("No potions remaining!")
    end
end

function game:trigger_game_over(reason)
    -- Calculate stats
    local chambers_explored = 0
    if self.dungeon and self.dungeon.chambers then
        for _, chamber in pairs(self.dungeon.chambers) do
            if chamber.visited then
                chambers_explored = chambers_explored + 1
            end
        end
    end

    self.game_over_reason = reason
    self.game_over_stats = {
        level = self.player and self.player.level or 1,
        chambers_explored = chambers_explored,
        enemies_defeated = self.player and self.player.kills or 0,
        gold_collected = self.player and self.player.gold or 0
    }

    self.state = "game_over"
end

function game:trigger_victory()
    -- Calculate final stats
    local chambers_explored = 0
    if self.dungeon and self.dungeon.chambers then
        for _, chamber in pairs(self.dungeon.chambers) do
            if chamber.visited then
                chambers_explored = chambers_explored + 1
            end
        end
    end

    self.victory_stats = {
        level = self.player and self.player.level or 1,
        chambers_explored = chambers_explored,
        total_chambers = self.dungeon and self.dungeon.num_chambers or 0,
        enemies_defeated = self.player and self.player.kills or 0,
        gold_collected = self.player and self.player.gold or 0,
        final_hp = self.player and self.player.hp or 0,
        max_hp = self.player and self.player.max_hp or 0,
        potions_remaining = self.player and self.player.potions or 0
    }

    self.state = "victory"
    self:add_log("VICTORY! You have conquered the entire dungeon!")
end

function game:check_victory()
    if not self.dungeon or not self.dungeon.chambers then
        return false
    end

    -- Count visited chambers
    local chambers_visited = 0
    for _, chamber in pairs(self.dungeon.chambers) do
        if chamber.visited then
            chambers_visited = chambers_visited + 1
        end
    end

    -- Victory condition: all chambers visited
    if chambers_visited >= self.dungeon.num_chambers then
        self:trigger_victory()
        return true
    end

    return false
end

function game:check_player_death()
    if self.player and self.player.hp <= 0 then
        -- Determine death reason
        local reason = "Succumbed to wounds"
        
        if Effects.has_effect(self.player, "poison") then
            reason = "Died from poison"
        elseif Effects.has_effect(self.player, "bleeding") then
            reason = "Bled to death"
        end
        
        self:trigger_game_over(reason)
        return true
    end
    return false
end

function game:start_combat()
    local enemy = GameLogic.create_enemy(self.dungeon.player_position, EncounterData, EnemyStats)
    
    -- Initialize effects on enemy
    Effects.init_entity(enemy)
    
    self.combat_state = {
        enemy = enemy,
        enemy_type = enemy.type,
        turn = "player",
        log = {}
    }
    self.state = "combat"
    self:add_log("Combat started with " .. enemy.name .. "!")
end

function game:player_attack()
    local combat = self.combat_state
    
    -- Check if player is stunned
    if Effects.is_stunned(self.player) then
        table.insert(combat.log, 1, "You are stunned and cannot act!")
        -- Process effects at end of turn
        local effect_msgs = Effects.process_turn(self.player, GameLogic.roll)
        for _, msg in ipairs(effect_msgs) do
            table.insert(combat.log, 1, msg)
        end
        return
    end
    
    -- Apply effect bonuses to attack
    local attack_modifier = Effects.get_attack_modifier(self.player)
    
    local hit, damage, enemy_dead = GameLogic.player_attack(self.player, combat.enemy)
    damage = damage + (attack_modifier > 0 and math.abs(attack_modifier) or 0)
    
    if hit then
        combat.enemy.hp = combat.enemy.hp - damage
        enemy_dead = combat.enemy.hp <= 0
        table.insert(combat.log, 1, string.format("You hit for %d damage!", damage))
        if enemy_dead then
            self:end_combat(true)
            return
        end
    else
        table.insert(combat.log, 1, "You missed!")
    end
    
    -- Process player effects
    local player_effect_msgs = Effects.process_turn(self.player, GameLogic.roll)
    for _, msg in ipairs(player_effect_msgs) do
        table.insert(combat.log, 1, msg)
    end
    
    -- Check if player died from effects
    if self:check_player_death() then
        return
    end
    
    -- Process enemy effects
    local enemy_effect_msgs = Effects.process_turn(combat.enemy, GameLogic.roll)
    for _, msg in ipairs(enemy_effect_msgs) do
        table.insert(combat.log, 1, msg)
    end
    
    -- Check if enemy died from effects
    if combat.enemy.hp <= 0 then
        self:end_combat(true)
        return
    end
    
    -- Enemy attack (if not stunned)
    if not Effects.is_stunned(combat.enemy) then
        local enemy_hit, enemy_damage, player_dead = GameLogic.enemy_attack(combat.enemy, self.player)
        
        if enemy_hit then
            table.insert(combat.log, 1, string.format("%s hits you for %d damage!", combat.enemy.name, enemy_damage))
            if player_dead or self:check_player_death() then
                self:end_combat(false)
                return
            end
        else
            table.insert(combat.log, 1, combat.enemy.name .. " missed!")
        end
    else
        table.insert(combat.log, 1, combat.enemy.name .. " is stunned!")
    end
    
    if #combat.log > 5 then
        table.remove(combat.log)
    end
end

function game:cast_spell(spell_id)
    local success, result, value, enemy_dead = GameLogic.cast_spell(spell_id, self.player, self.combat_state.enemy, SpellData)
    
    if not success then
        if result == "no_mana" then
            table.insert(self.combat_state.log, 1, "Not enough mana!")
        else
            table.insert(self.combat_state.log, 1, "Unknown spell!")
        end
        return
    end
    
    local spell = SpellData[spell_id]
    
    if result == "damage" then
        table.insert(self.combat_state.log, 1, string.format("Cast %s for %d damage!", spell.name, value))
        if enemy_dead then
            self:end_combat(true)
            return
        end
    elseif result == "heal" then
        table.insert(self.combat_state.log, 1, string.format("Healed %d HP!", value))
    elseif result == "buff" then
        table.insert(self.combat_state.log, 1, string.format("Cast %s! AC +%d", spell.name, value))
    end
    
    local enemy_hit, enemy_damage, player_dead = GameLogic.enemy_attack(self.combat_state.enemy, self.player)
    
    if enemy_hit then
        table.insert(self.combat_state.log, 1, string.format("%s hits for %d damage!", self.combat_state.enemy.name, enemy_damage))
        if player_dead then
            self:end_combat(false)
            return
        end
    else
        table.insert(self.combat_state.log, 1, self.combat_state.enemy.name .. " missed!")
    end
    
    if #self.combat_state.log > 5 then
        table.remove(self.combat_state.log)
    end
end

function game:end_combat(victory)
    if victory then
        local xp = self.combat_state.enemy.xp or 50
        
        -- Award XP and check for level up
        local leveled_up, messages = Progression.add_xp(self.player, xp)
        
        -- Show all progression messages
        for _, msg in ipairs(messages) do
            self:add_log(msg)
        end
        
        -- Show level up in floating pane if leveled up
        if leveled_up then
            local level_msg = string.format("⭐ LEVEL UP! You are now level %d! ⭐", self.player.level)
            self.ai_description = level_msg .. "\n\nYour power grows! HP and stats have increased. You feel ready to face greater challenges."
            self.show_ai_pane = true
        end
        
        if self.player.mana then
            local mana_restore = math.floor(self.player.max_mana * 0.3)
            self.player.mana = math.min(self.player.max_mana, self.player.mana + mana_restore)
        end
        
        local current = self.dungeon.chambers[self.dungeon.player_position]
        local loot = GameLogic.generate_loot(current.type, true, LootData)
        self.player.gold = self.player.gold + loot.gold
        
        if loot.gold > 0 then
            self:add_log(string.format("Found %d gold!", loot.gold))
        end
        
        for _, item in ipairs(loot.items) do
            if item == "Health Potion" then
                self.player.potions = self.player.potions + 1
                self:add_log("Found a Health Potion!")
            else
                table.insert(self.player.items, item)
                self:add_log("Found: " .. item)
            end
        end
        
        -- Chance to apply poison/bleeding effect on certain enemies
        if math.random(1, 100) <= 20 then
            Effects.apply(self.player, "poison", 2)
            self:add_log("☠️ You were poisoned in the fight!")
        end

        -- Track kill count
        self.player.kills = (self.player.kills or 0) + 1
    else
        -- Player defeated - trigger game over
        local enemy_name = self.combat_state.enemy.name
        self:trigger_game_over("Slain by " .. enemy_name)
        return
    end

    self.combat_state = nil
    self.state = "game"

    -- Check for victory after combat ends
    self:check_victory()
end

function game:search_chamber()
    local current = self.dungeon.chambers[self.dungeon.player_position]
    local result, reward = GameLogic.search_chamber(current, self.player)
    
    if result == "already_searched" then
        self:add_log("You already searched this chamber thoroughly")
    elseif result == "found" then
        if reward.type == "gold" then
            self:add_log(string.format("Found %d gold hidden in the shadows!", reward.amount))
        elseif reward.type == "potion" then
            self:add_log("Found a health potion tucked away!")
        else
            self:add_log("Found: " .. reward.name .. "!")
        end
    else
        self:add_log("You searched carefully but found nothing")
    end
end

function game:move_to_chamber(chamber_id)
    if not self.dungeon.chambers[chamber_id] then
        self:add_log("Invalid chamber!")
        return
    end

    self.dungeon.player_position = chamber_id
    local chamber = self.dungeon.chambers[chamber_id]
    chamber.visited = true

    -- Check for victory after marking chamber as visited
    if self:check_victory() then
        return  -- Victory triggered, stop processing
    end

    local description = self:get_chamber_description(chamber)
    if description then
        -- Store AI description for floating pane
        self.ai_description = description
        self.show_ai_pane = true
        self:add_log("📜 AI description available - new chamber entered")
    else
        self.ai_description = nil
        self.show_ai_pane = false
        self:add_log("Moved to Chamber " .. chamber_id .. " - " .. GameLogic.get_chamber_type_name(chamber.type))
    end

    if not TUIConfig or not TUIConfig.encounter_chance then
        return
    end

    local chance = TUIConfig.encounter_chance[chamber.type]
    if not chance then
        return
    end

    if math.random(1, 100) <= chance then
        local encounter_type_roll = math.random(1, 100)

        if encounter_type_roll <= 60 then
            self:start_combat()
        elseif encounter_type_roll <= 85 then
            self:neutral_encounter()
        else
            self:friendly_encounter()
        end
    else
        if chamber.type == 2 then
            local loot = GameLogic.generate_loot(chamber.type, false, LootData)
            self.player.gold = self.player.gold + loot.gold
            if loot.gold > 0 then
                self:add_log(string.format("Found %d gold!", loot.gold))
            end
        elseif chamber.type == 4 then
            if TUIConfig.trap and math.random(1, 100) <= TUIConfig.trap.chance then
                local damage = GameLogic.roll(TUIConfig.trap.damage)
                self.player.hp = self.player.hp - damage
                self:add_log(string.format("Trap! Took %d damage!", damage))
            end
        end
    end
end

function game:get_chamber_description(chamber)
    if not AIStoryteller or not AIStoryteller.config.enabled then
        return nil
    end
    
    if chamber.ai_description then
        return chamber.ai_description
    end
    
    local chamber_type = GameLogic.get_chamber_type_name(chamber.type)
    local exits = #chamber.connections .. " exits"
    
    local chamber_data = {
        type = chamber_type,
        exits = exits,
        items = chamber.searched and "searched" or "unsearched",
        enemies = chamber.has_enemies and "present" or "none"
    }
    
    local player_context = {
        class = self.player.class or "adventurer",
        name = self.player.name,
        hp = self.player.hp,
        depth = chamber.id
    }
    
    local description = AIStoryteller.narrate_chamber(chamber_data, player_context)
    
    if description then
        chamber.ai_description = description
        return description
    end
    
    return nil
end

function game:neutral_encounter()
    if not EncounterData or not EncounterData.neutral_encounters then
        self:add_log("You encounter something...")
        return
    end
    
    local encounter = EncounterData.neutral_encounters[math.random(#EncounterData.neutral_encounters)]
    self:add_log(Renderer.colors.cyan .. encounter.name .. ": " .. Renderer.colors.reset .. encounter.desc)
end

function game:friendly_encounter()
    if not EncounterData or not EncounterData.friendly_encounters then
        self:add_log("You encounter someone friendly...")
        return
    end
    
    local encounter = EncounterData.friendly_encounters[math.random(#EncounterData.friendly_encounters)]
    self:add_log(Renderer.colors.green .. encounter.name .. ": " .. Renderer.colors.reset .. encounter.desc)
    
    local bonus_roll = math.random(1, 100)
    if bonus_roll <= 30 then
        local heal = math.random(5, 10)
        self.player.hp = math.min(self.player.max_hp, self.player.hp + heal)
        self:add_log("They help you! Healed " .. heal .. " HP")
    elseif bonus_roll <= 60 then
        local gold = math.random(10, 30)
        self.player.gold = self.player.gold + gold
        self:add_log("They give you " .. gold .. " gold!")
    elseif bonus_roll <= 80 then
        self.player.potions = self.player.potions + 1
        self:add_log("They give you a health potion!")
    end
end

-- INPUT HANDLING

function game:get_key()
    os.execute("stty -icanon -echo")
    local key = io.read(1)
    os.execute("stty icanon echo")
    return key
end

function game:handle_main_menu_input(key)
    if key == "\27" then
        local next1 = io.read(1)
        local next2 = io.read(1)
        if Keymaps.is_up(key, next1, next2) then
            self.selected_menu = math.max(1, self.selected_menu - 1)
        elseif Keymaps.is_down(key, next1, next2) then
            self.selected_menu = math.min(5, self.selected_menu + 1)
        end
    elseif key == "\n" or key == "\r" then
        if self.selected_menu == 1 then
            self.state = "character_creation"
            self.selected_class = 1
        elseif self.selected_menu == 2 then
            self:load_sessions()
            self.state = "load_menu"
            self.selected_menu = 1
        elseif self.selected_menu == 5 then
            return true
        end
    elseif Keymaps.matches(key, Keymaps.main_menu, "quit") then
        return true
    end
    return false
end

function game:handle_character_creation_input(key)
    if key == "\27" then
        local next1 = io.read(1)
        if next1 == "[" then
            local next2 = io.read(1)
            if Keymaps.is_up("\27", "[", next2) then
                self.selected_class = math.max(1, self.selected_class - 1)
            elseif Keymaps.is_down("\27", "[", next2) then
                self.selected_class = math.min(6, self.selected_class + 1)
            end
        else
            self.state = "main_menu"
            self.selected_menu = 1
        end
    elseif key == "\n" or key == "\r" then
        self.state = "dungeon_size"
        self.selected_menu = 2
    end
    return false
end

function game:handle_dungeon_size_input(key)
    if key == "\27" then
        local next1 = io.read(1)
        if next1 == "[" then
            local next2 = io.read(1)
            if Keymaps.is_up("\27", "[", next2) then
                self.selected_menu = math.max(1, self.selected_menu - 1)
            elseif Keymaps.is_down("\27", "[", next2) then
                self.selected_menu = math.min(5, self.selected_menu + 1)
            end
        else
            self.state = "character_creation"
        end
    elseif key == "\n" or key == "\r" then
        local sizes = {10, 20, 30, 50, 100}
        self.dungeon_size = sizes[self.selected_menu]
        self:new_game()
    end
    return false
end

function game:handle_load_menu_input(key)
    if key == "\27" then
        local next1 = io.read(1)
        if next1 == "[" then
            local next2 = io.read(1)
            if Keymaps.is_up("\27", "[", next2) then
                self.selected_menu = math.max(1, self.selected_menu - 1)
            elseif Keymaps.is_down("\27", "[", next2) then
                self.selected_menu = math.min(#self.session_list + 1, self.selected_menu + 1)
            end
        else
            self.state = "main_menu"
            self.selected_menu = 1
        end
    elseif key == "\n" or key == "\r" then
        if self.selected_menu <= #self.session_list then
            self:load_game(self.session_list[self.selected_menu].id)
        else
            self.state = "main_menu"
            self.selected_menu = 1
        end
    end
    return false
end

function game:handle_game_input(key)
    if Keymaps.matches(key, Keymaps.game, "quit") then
        self.state = "main_menu"
        self.selected_menu = 1
    elseif Keymaps.matches(key, Keymaps.game, "save") then
        self:save_game()
    elseif Keymaps.matches(key, Keymaps.game, "search") then
        if self.dungeon and self.dungeon.chambers then
            self.state = "search"
        else
            self:add_log("No dungeon to search!")
        end
    elseif Keymaps.matches(key, Keymaps.game, "move") then
        local current = self.dungeon.chambers[self.dungeon.player_position]
        if #current.connections > 0 then
            self.state = "move"
            self.move_selection = 1
        else
            self:add_log("No exits available!")
        end
    elseif Keymaps.matches(key, Keymaps.game, "inventory") then
        self.state = "inventory"
    elseif Keymaps.matches(key, Keymaps.game, "quest_log") then
        self.state = "quest_log"
    elseif Keymaps.matches(key, Keymaps.game, "rest") then
        self:rest()
    elseif Keymaps.matches(key, Keymaps.game, "use_potion") then
        self:use_potion()
    elseif key:lower() == "d" then
        -- Dismiss AI description pane
        if self.show_ai_pane then
            self.show_ai_pane = false
            self:add_log("AI description dismissed")
        end
    end
    return false
end

function game:handle_move_input(key)
    local current = self.dungeon.chambers[self.dungeon.player_position]
    
    if key == "\27" then
        local next1 = io.read(1)
        if next1 == "[" then
            local next2 = io.read(1)
            if Keymaps.is_up("\27", "[", next2) then
                self.move_selection = math.max(1, self.move_selection - 1)
            elseif Keymaps.is_down("\27", "[", next2) then
                self.move_selection = math.min(#current.connections, self.move_selection + 1)
            end
        else
            self.state = "game"
        end
    elseif key == "\n" or key == "\r" then
        local target = current.connections[self.move_selection]
        self:move_to_chamber(target)
        if self.state ~= "combat" then
            self.state = "game"
        end
    end
    return false
end

function game:handle_inventory_input(key)
    if key == "\27" or Keymaps.matches(key, Keymaps.inventory, "close") then
        self.state = "game"
    elseif Keymaps.matches(key, Keymaps.inventory, "use_potion") then
        self:use_potion()
    end
    return false
end

function game:handle_combat_input(key)
    if Keymaps.matches(key, Keymaps.combat, "attack") then
        self:player_attack()
    elseif Keymaps.matches(key, Keymaps.combat, "cast_spell") then
        self.state = "spell_select"
        self.selected_spell = 1
    elseif Keymaps.matches(key, Keymaps.combat, "use_potion") and self.player.potions > 0 then
        self:use_potion()
    elseif Keymaps.matches(key, Keymaps.combat, "run") then
        local escape_chance = TUIConfig and TUIConfig.escape_chance or 50
        if math.random(1, 100) <= escape_chance then
            self:add_log("Escaped successfully!")
            self.combat_state = nil
            self.state = "game"
        else
            self:add_log("Failed to escape!")
            local damage = GameLogic.roll(self.combat_state.enemy.damage)
            self.player.hp = self.player.hp - damage
            table.insert(self.combat_state.log, 1, string.format("Enemy hits for %d!", damage))
            
            if self.player.hp <= 0 then
                self:end_combat(false)
            end
        end
    end
    return false
end

function game:handle_search_input(key)
    if key == "\27" or Keymaps.matches(key, Keymaps.game, "search") then
        self.state = "game"
    elseif key == "\n" or key == "\r" then
        self:search_chamber()
    end
    return false
end

function game:handle_quest_log_input(key)
    if key == "\27" or Keymaps.matches(key, Keymaps.game, "quest_log") then
        self.state = "game"
    end
    return false
end

function game:handle_game_over_input(key)
    if key:lower() == "n" then
        -- New game - go to character creation
        self.state = "character_creation"
        self.selected_class = 1
        self.game_over_reason = nil
        self.game_over_stats = nil
        return false
    elseif key:lower() == "m" then
        -- Main menu
        self.state = "main_menu"
        self.selected_menu = 1
        self.game_over_reason = nil
        self.game_over_stats = nil
        return false
    elseif key:lower() == "q" then
        -- Quit to desktop
        return true
    end
    return false
end

function game:handle_victory_input(key)
    if key:lower() == "n" then
        -- New game - go to character creation
        self.state = "character_creation"
        self.selected_class = 1
        self.victory_stats = nil
        return false
    elseif key:lower() == "m" then
        -- Main menu
        self.state = "main_menu"
        self.selected_menu = 1
        self.victory_stats = nil
        return false
    elseif key:lower() == "q" then
        -- Quit to desktop
        return true
    end
    return false
end

function game:handle_spell_select_input(key)
    if key == "\27" then
        local next1 = io.read(1)
        if next1 == "[" then
            local next2 = io.read(1)
            if Keymaps.is_up("\27", "[", next2) then
                self.selected_spell = math.max(1, (self.selected_spell or 1) - 1)
            elseif Keymaps.is_down("\27", "[", next2) then
                local max_option = #self.player.spells + 1
                self.selected_spell = math.min(max_option, (self.selected_spell or 1) + 1)
            end
        else
            self.state = "combat"
        end
    elseif key == "\n" or key == "\r" then
        if self.selected_spell <= #self.player.spells then
            local spell_id = self.player.spells[self.selected_spell]
            self:cast_spell(spell_id)
            self.state = "combat"
        else
            self.state = "combat"
        end
    end
    return false
end

-- MAIN LOOP

function game:run()
    Renderer.hide_cursor()
    
    while true do
        if self.state == "main_menu" then
            self:draw_main_menu()
        elseif self.state == "character_creation" then
            self:draw_character_creation()
        elseif self.state == "dungeon_size" then
            self:draw_dungeon_size()
        elseif self.state == "load_menu" then
            self:draw_load_menu()
        elseif self.state == "game" then
            self:draw_game_screen()
        elseif self.state == "combat" then
            self:draw_combat_screen()
        elseif self.state == "spell_select" then
            self:draw_spell_select()
        elseif self.state == "move" then
            self:draw_move_screen()
        elseif self.state == "inventory" then
            self:draw_inventory_screen()
        elseif self.state == "search" then
            self:draw_search_screen()
        elseif self.state == "quest_log" then
            self:draw_quest_log()
        elseif self.state == "game_over" then
            self:draw_game_over()
        elseif self.state == "victory" then
            self:draw_victory()
        end

        local key = self:get_key()
        local quit = false
        
        if self.state == "main_menu" then
            quit = self:handle_main_menu_input(key)
        elseif self.state == "character_creation" then
            quit = self:handle_character_creation_input(key)
        elseif self.state == "dungeon_size" then
            quit = self:handle_dungeon_size_input(key)
        elseif self.state == "load_menu" then
            quit = self:handle_load_menu_input(key)
        elseif self.state == "game" then
            quit = self:handle_game_input(key)
        elseif self.state == "combat" then
            quit = self:handle_combat_input(key)
        elseif self.state == "spell_select" then
            quit = self:handle_spell_select_input(key)
        elseif self.state == "move" then
            quit = self:handle_move_input(key)
        elseif self.state == "inventory" then
            quit = self:handle_inventory_input(key)
        elseif self.state == "search" then
            quit = self:handle_search_input(key)
        elseif self.state == "quest_log" then
            quit = self:handle_quest_log_input(key)
        elseif self.state == "game_over" then
            quit = self:handle_game_over_input(key)
        elseif self.state == "victory" then
            quit = self:handle_victory_input(key)
        end

        if quit then break end
    end
    
    Renderer.show_cursor()
    Renderer.clear_screen()
    Renderer.move_cursor(1, 1)
    print("Thanks for playing!")
end

-- Start the game
game:run()
