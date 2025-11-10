-- TUI Renderer
-- Handles all terminal rendering, UI components, and screen drawing

local Renderer = {}

-- Load screen size module for responsive features
local ScreenSize = require("src.tui_screen_size")

-- Current screen info (cached)
Renderer.screen_info = nil

-- ANSI escape codes
local function esc(code) return "\27[" .. code .. "m" end

-- Screen control
function Renderer.clear_screen() io.write("\27[2J\27[H") end
function Renderer.move_cursor(row, col) io.write(string.format("\27[%d;%dH", row, col)) end
function Renderer.hide_cursor() io.write("\27[?25l") end
function Renderer.show_cursor() io.write("\27[?25h") end
function Renderer.clear_line() io.write("\27[2K") end

-- Colors
Renderer.colors = {
    reset = esc("0"),
    bold = esc("1"),
    dim = esc("2"),
    
    black = esc("30"),
    red = esc("31"),
    green = esc("32"),
    yellow = esc("33"),
    blue = esc("34"),
    magenta = esc("35"),
    cyan = esc("36"),
    white = esc("37"),
    
    bg_black = esc("40"),
    bg_red = esc("41"),
    bg_green = esc("42"),
    bg_yellow = esc("43"),
    bg_blue = esc("44"),
    bg_magenta = esc("45"),
    bg_cyan = esc("46"),
    bg_white = esc("47"),
}

-- UI Components
function Renderer.box(x, y, width, height, title)
    local top = "┌" .. string.rep("─", width - 2) .. "┐"
    local middle = "│" .. string.rep(" ", width - 2) .. "│"
    local bottom = "└" .. string.rep("─", width - 2) .. "┘"
    
    -- Top border with title
    Renderer.move_cursor(y, x)
    if title then
        local title_text = " " .. title .. " "
        local padding = math.floor((width - #title_text) / 2)
        io.write("┌" .. string.rep("─", padding - 1) .. Renderer.colors.bold .. title_text .. 
                 Renderer.colors.reset .. string.rep("─", width - padding - #title_text - 1) .. "┐")
    else
        io.write(top)
    end
    
    -- Middle rows
    for i = 1, height - 2 do
        Renderer.move_cursor(y + i, x)
        io.write(middle)
    end
    
    -- Bottom border
    Renderer.move_cursor(y + height - 1, x)
    io.write(bottom)
end

function Renderer.text(x, y, text, color)
    Renderer.move_cursor(y, x)
    io.write((color or "") .. text .. Renderer.colors.reset)
end

function Renderer.center_text(y, text, width, color)
    local x = math.floor((width - #text) / 2)
    Renderer.text(x, y, text, color)
end

function Renderer.progress_bar(x, y, current, max, width, label)
    local percentage = math.floor((current / max) * 100)
    local filled = math.floor((current / max) * width)
    local empty = width - filled
    
    local bar_color = Renderer.colors.green
    if percentage < 30 then
        bar_color = Renderer.colors.red
    elseif percentage < 60 then
        bar_color = Renderer.colors.yellow
    end
    
    Renderer.move_cursor(y, x)
    io.write(label or "")
    io.write(bar_color .. "[" .. string.rep("█", filled) .. Renderer.colors.dim .. 
             string.rep("░", empty) .. Renderer.colors.reset .. bar_color .. "]" .. Renderer.colors.reset)
    io.write(string.format(" %d/%d", current, max))
end

function Renderer.menu(x, y, options, selected)
    for i, option in ipairs(options) do
        Renderer.move_cursor(y + i - 1, x)
        if i == selected then
            io.write(Renderer.colors.bg_cyan .. Renderer.colors.black .. " ▶ " .. option .. 
                    string.rep(" ", 40 - #option) .. Renderer.colors.reset)
        else
            io.write("   " .. option)
        end
    end
end

-- Header
function Renderer.draw_header()
    Renderer.move_cursor(1, 1)
    io.write(Renderer.colors.bold .. Renderer.colors.cyan)
    io.write("╔═══════════════════════════════════════════════════════════════════════════════╗")
    Renderer.move_cursor(2, 1)
    io.write("║" .. string.rep(" ", 79) .. "║")
    Renderer.move_cursor(2, 30)
    io.write("🏰 DUNGEON CRAWLER 🏰")
    Renderer.move_cursor(3, 1)
    io.write("╚═══════════════════════════════════════════════════════════════════════════════╝")
    io.write(Renderer.colors.reset)
end

-- Footer with optional context name
function Renderer.draw_footer(text, context_name)
    Renderer.move_cursor(24, 1)
    io.write(Renderer.colors.dim)
    io.write("─" .. string.rep("─", 79))
    Renderer.move_cursor(25, 1)

    -- If context name provided, show it on the left
    if context_name then
        io.write(Renderer.colors.cyan .. Renderer.colors.bold .. "[" .. context_name .. "]" ..
                Renderer.colors.reset .. Renderer.colors.dim .. "  " .. (text or ""))
    else
        io.write(text or "↑↓: Navigate | Enter: Select | Q: Quit")
    end

    io.write(Renderer.colors.reset)
end

-- Floating pane with optional status line (overlay on top of other content)
-- status_text: optional status line text to display at bottom of pane
function Renderer.floating_pane(x, y, width, height, title, content, style, status_text)
    style = style or "normal"

    -- Draw shadow effect
    for i = 1, height do
        Renderer.move_cursor(y + i, x + 2)
        io.write(Renderer.colors.dim .. string.rep("░", width) .. Renderer.colors.reset)
    end

    -- Border style based on type
    local border_color = Renderer.colors.cyan
    if style == "ai" then
        border_color = Renderer.colors.magenta
    elseif style == "warning" then
        border_color = Renderer.colors.yellow
    elseif style == "error" then
        border_color = Renderer.colors.red
    end

    -- Draw the pane
    local top = "╔" .. string.rep("═", width - 2) .. "╗"
    local middle = "║" .. string.rep(" ", width - 2) .. "║"
    local bottom = "╚" .. string.rep("═", width - 2) .. "╝"

    -- Top border with title
    Renderer.move_cursor(y, x)
    io.write(border_color)
    if title then
        local title_text = " " .. title .. " "
        local padding = math.floor((width - #title_text) / 2)
        io.write("╔" .. string.rep("═", padding - 1) .. Renderer.colors.bold .. title_text ..
                 Renderer.colors.reset .. border_color .. string.rep("═", width - padding - #title_text - 1) .. "╗")
    else
        io.write(top)
    end
    io.write(Renderer.colors.reset)

    -- Calculate content height (reserve space for status line if present)
    local content_height = height - 2
    if status_text then
        content_height = content_height - 1  -- Reserve bottom line for status
    end

    -- Middle rows with content
    for i = 1, content_height do
        Renderer.move_cursor(y + i, x)
        io.write(border_color .. "║" .. Renderer.colors.reset)

        -- Draw content if provided
        if content and content[i] then
            local line = content[i]
            -- Get actual text length (without color codes)
            local text_only = line:gsub("\27%[[%d;]*m", "")

            -- Truncate if too long
            if #text_only > width - 4 then
                -- Try to preserve color codes while truncating
                local truncated = line:sub(1, width - 7) .. "..."
                io.write(" " .. truncated)
                -- Calculate remaining space
                local remaining = width - #text_only - 3
                if remaining > 0 then
                    io.write(string.rep(" ", remaining))
                end
            else
                io.write(" " .. line)
                local padding = width - #text_only - 3
                if padding > 0 then
                    io.write(string.rep(" ", padding))
                end
            end
        else
            io.write(string.rep(" ", width - 2))
        end

        io.write(border_color .. "║" .. Renderer.colors.reset)
    end

    -- Status line (if provided)
    if status_text then
        Renderer.move_cursor(y + content_height + 1, x)
        io.write(border_color .. "║" .. Renderer.colors.reset)

        -- Truncate status text if too long
        local status_display = status_text
        local status_plain = status_text:gsub("\27%[[%d;]*m", "")
        if #status_plain > width - 4 then
            status_display = status_text:sub(1, width - 7) .. "..."
        end

        -- Center or left-align status text
        io.write(" " .. Renderer.colors.dim .. status_display .. Renderer.colors.reset)
        local padding = width - #status_plain - 3
        if padding > 0 then
            io.write(string.rep(" ", padding))
        end
        io.write(border_color .. "║" .. Renderer.colors.reset)
    end

    -- Bottom border
    Renderer.move_cursor(y + height - 1, x)
    io.write(border_color .. bottom .. Renderer.colors.reset)
end

-- Draw a status line (for use within boxes/panes)
-- x, y: position
-- width: width of the status line
-- context_name: name of current context (e.g., "Inventory", "Combat")
-- keybindings: table of {key, desc} pairs or formatted string
function Renderer.status_line(x, y, width, context_name, keybindings)
    Renderer.move_cursor(y, x)

    -- Format: [Context Name] | Key1:Action1 | Key2:Action2
    local parts = {}

    -- Add context name
    if context_name then
        table.insert(parts, Renderer.colors.cyan .. Renderer.colors.bold .. context_name .. Renderer.colors.reset)
    end

    -- Add keybindings
    if type(keybindings) == "string" then
        table.insert(parts, Renderer.colors.dim .. keybindings .. Renderer.colors.reset)
    elseif type(keybindings) == "table" then
        local binding_parts = {}
        for _, binding in ipairs(keybindings) do
            table.insert(binding_parts, string.format("%s:%s", binding.key, binding.desc))
        end
        table.insert(parts, Renderer.colors.dim .. table.concat(binding_parts, " | ") .. Renderer.colors.reset)
    end

    local status_text = table.concat(parts, " " .. Renderer.colors.dim .. "│" .. Renderer.colors.reset .. " ")

    -- Strip color codes for length calculation
    local plain_text = status_text:gsub("\27%[[%d;]*m", "")

    -- Truncate if too long
    if #plain_text > width then
        status_text = status_text:sub(1, width - 3) .. "..."
    end

    io.write(status_text)
    io.write(Renderer.colors.reset)
end

-- Word wrap text to fit in a width
function Renderer.word_wrap(text, width)
    local lines = {}
    local current_line = ""

    for word in text:gmatch("%S+") do
        if #current_line + #word + 1 <= width then
            if #current_line > 0 then
                current_line = current_line .. " " .. word
            else
                current_line = word
            end
        else
            if #current_line > 0 then
                table.insert(lines, current_line)
            end
            current_line = word
        end
    end

    if #current_line > 0 then
        table.insert(lines, current_line)
    end

    return lines
end

-- ============================================================================
-- RESPONSIVE LAYOUT FUNCTIONS
-- ============================================================================

-- Initialize or refresh screen info
function Renderer.init_screen(force_refresh)
    Renderer.screen_info = ScreenSize.get_info(force_refresh)
    return Renderer.screen_info
end

-- Get current screen info (auto-initialize if needed)
function Renderer.get_screen_info()
    if not Renderer.screen_info then
        Renderer.init_screen()
    end
    return Renderer.screen_info
end

-- Get layout configuration for current screen size
function Renderer.get_layout()
    local screen_info = Renderer.get_screen_info()
    return ScreenSize.get_layout_config(screen_info.size_class)
end

-- Responsive box that adjusts to screen size
-- If width/height are percentages (0-1), calculate from screen size
-- If absolute values, ensure they fit on screen
function Renderer.responsive_box(x, y, width, height, title)
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    -- Convert percentage to absolute if needed
    if width and width <= 1 then
        width = math.floor(screen_info.cols * width)
    end
    if height and height <= 1 then
        height = math.floor(screen_info.rows * height)
    end

    -- Auto-center if x, y are nil or "center"
    if not x or x == "center" then
        x = math.floor((screen_info.cols - width) / 2)
    end
    if not y or y == "center" then
        y = math.floor((screen_info.rows - height) / 2)
    end

    -- Ensure box fits on screen
    width = math.min(width, screen_info.cols - 2)
    height = math.min(height, screen_info.rows - 4)

    -- Ensure minimum position
    x = math.max(1, x)
    y = math.max(4, y)

    -- Draw box with or without borders based on screen size
    if layout.show_borders then
        Renderer.box(x, y, width, height, title)
    else
        -- Minimal box (no borders on tiny screens)
        Renderer.box_minimal(x, y, width, height, title)
    end

    return x, y, width, height
end

-- Minimal box without borders (for very small screens)
function Renderer.box_minimal(x, y, width, height, title)
    -- Just draw title and content area
    if title then
        Renderer.move_cursor(y, x)
        io.write(Renderer.colors.bold .. title .. Renderer.colors.reset)
    end

    -- Draw underline for title
    if title then
        Renderer.move_cursor(y + 1, x)
        io.write(Renderer.colors.dim .. string.rep("─", width) .. Renderer.colors.reset)
    end
end

-- Responsive floating pane that adjusts size and position
function Renderer.responsive_floating_pane(title, content, style, status_text)
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    -- Calculate responsive dimensions
    local width = math.min(layout.floating_pane_max_width, screen_info.cols - 10)
    local height = math.min(layout.floating_pane_max_height, screen_info.rows - 10)

    -- Center the pane
    local x = math.floor((screen_info.cols - width) / 2)
    local y = math.floor((screen_info.rows - height) / 2)

    -- Ensure minimum position
    x = math.max(1, x)
    y = math.max(4, y)

    -- Draw the pane
    Renderer.floating_pane(x, y, width, height, title, content, style, status_text)

    return x, y, width, height
end

-- Responsive header that adjusts to screen width
function Renderer.responsive_header()
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    Renderer.move_cursor(1, 1)
    io.write(Renderer.colors.bold .. Renderer.colors.cyan)

    -- Calculate border width
    local border_width = screen_info.cols - 2

    -- Top border
    io.write("╔" .. string.rep("═", border_width) .. "╗")
    Renderer.move_cursor(2, 1)
    io.write("║" .. string.rep(" ", border_width) .. "║")

    -- Title (centered)
    local title = "🏰 DUNGEON CRAWLER 🏰"
    local title_x = math.floor((screen_info.cols - #title) / 2)
    Renderer.move_cursor(2, title_x)
    io.write(title)

    -- Bottom border
    Renderer.move_cursor(3, 1)
    io.write("╚" .. string.rep("═", border_width) .. "╝")
    io.write(Renderer.colors.reset)
end

-- Responsive footer that adjusts to screen width
function Renderer.responsive_footer(text, context_name)
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    local footer_row = screen_info.rows - 1
    local separator_row = screen_info.rows - 2

    -- Draw separator line
    Renderer.move_cursor(separator_row, 1)
    io.write(Renderer.colors.dim)
    io.write(string.rep("─", screen_info.cols))

    -- Draw footer text
    Renderer.move_cursor(footer_row, 1)

    -- Truncate text if too long
    local max_width = screen_info.cols - 2
    local footer_text = text or "↑↓: Navigate | Enter: Select | Q: Quit"

    if context_name then
        local prefix = Renderer.colors.cyan .. Renderer.colors.bold .. "[" .. context_name .. "]" ..
                       Renderer.colors.reset .. Renderer.colors.dim .. "  "
        footer_text = prefix .. footer_text
    end

    -- Strip color codes for length check
    local plain_text = footer_text:gsub("\27%[[%d;]*m", "")
    if #plain_text > max_width then
        footer_text = footer_text:sub(1, max_width - 3) .. "..."
    end

    io.write(footer_text)
    io.write(Renderer.colors.reset)
end

-- Get responsive column layout
function Renderer.get_columns(num_columns)
    local screen_info = Renderer.get_screen_info()
    return ScreenSize.get_column_layout(num_columns, screen_info)
end

-- Responsive menu that adjusts option padding
function Renderer.responsive_menu(x, y, options, selected)
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    local padding = layout.menu_option_padding

    for i, option in ipairs(options) do
        Renderer.move_cursor(y + i - 1, x)
        if i == selected then
            -- Calculate highlight width (ensure it fits)
            local highlight_width = math.min(padding, screen_info.cols - x - 4)
            io.write(Renderer.colors.bg_cyan .. Renderer.colors.black .. " ▶ " .. option ..
                    string.rep(" ", math.max(0, highlight_width - #option)) .. Renderer.colors.reset)
        else
            io.write("   " .. option)
        end
    end
end

-- Responsive progress bar that adjusts width
function Renderer.responsive_progress_bar(x, y, current, max, label)
    local screen_info = Renderer.get_screen_info()
    local layout = Renderer.get_layout()

    -- Calculate available width for progress bar
    local label_len = label and #label or 0
    local info_len = #string.format(" %d/%d", current, max)
    local available_width = screen_info.cols - x - label_len - info_len - 4

    -- Clamp width to reasonable range
    local bar_width = math.max(10, math.min(50, available_width))

    Renderer.progress_bar(x, y, current, max, bar_width, label)
end

-- Truncate text with ellipsis to fit width
function Renderer.truncate_text(text, max_width)
    -- Strip color codes for length calculation
    local plain_text = text:gsub("\27%[[%d;]*m", "")

    if #plain_text <= max_width then
        return text
    end

    -- Find position to truncate (accounting for color codes)
    local truncated = text:sub(1, max_width - 3) .. "..."
    return truncated
end

-- Check if screen is too small and show warning
function Renderer.check_screen_size()
    if ScreenSize.is_below_minimum() then
        return ScreenSize.show_size_warning()
    end
    return false
end

-- Display screen size info (for debugging)
function Renderer.show_screen_debug()
    local screen_info = Renderer.get_screen_info()
    local debug_info = ScreenSize.format_debug_info(screen_info)

    Renderer.move_cursor(1, 1)
    io.write(Renderer.colors.yellow .. debug_info .. Renderer.colors.reset)
end

-- Get responsive dimensions for specific UI elements
function Renderer.get_character_panel_size()
    local layout = Renderer.get_layout()
    return layout.character_panel_width, 18
end

function Renderer.get_dungeon_panel_size()
    local layout = Renderer.get_layout()
    return layout.dungeon_panel_width, 18
end

function Renderer.get_combat_log_lines()
    local layout = Renderer.get_layout()
    return layout.combat_log_lines
end

function Renderer.should_show_ascii_art()
    local layout = Renderer.get_layout()
    return layout.show_ascii_art
end

function Renderer.should_show_shadows()
    local layout = Renderer.get_layout()
    return layout.show_shadows
end

function Renderer.get_max_log_lines()
    local layout = Renderer.get_layout()
    return layout.max_log_lines
end

function Renderer.get_text_wrap_width()
    local layout = Renderer.get_layout()
    return layout.text_wrap_width
end

return Renderer
