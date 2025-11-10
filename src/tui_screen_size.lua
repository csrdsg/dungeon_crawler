-- TUI Screen Size Detection and Management
-- Handles terminal size detection, breakpoint management, and responsive layout configuration

local ScreenSize = {}

-- Cache for screen size to avoid repeated shell calls
ScreenSize.cache = {
    cols = nil,
    rows = nil,
    size_class = nil,
    timestamp = 0
}

-- Cache timeout in seconds (refresh if older than this)
ScreenSize.cache_timeout = 5

-- Breakpoint definitions
ScreenSize.breakpoints = {
    tiny = {min_cols = 0, max_cols = 79, min_rows = 0, max_rows = 23},
    small = {min_cols = 80, max_cols = 99, min_rows = 24, max_rows = 29},
    medium = {min_cols = 100, max_cols = 139, min_rows = 30, max_rows = 44},
    large = {min_cols = 140, max_cols = 179, min_rows = 45, max_rows = 59},
    xlarge = {min_cols = 180, max_cols = 999, min_rows = 60, max_rows = 999}
}

-- Detect terminal size using tput (most reliable method)
function ScreenSize.detect_with_tput()
    local success, cols_handle = pcall(io.popen, "tput cols 2>/dev/null")
    if not success or not cols_handle then
        return nil, nil
    end

    local cols_str = cols_handle:read("*a")
    cols_handle:close()

    local success2, rows_handle = pcall(io.popen, "tput lines 2>/dev/null")
    if not success2 or not rows_handle then
        return nil, nil
    end

    local rows_str = rows_handle:read("*a")
    rows_handle:close()

    local cols = tonumber(cols_str)
    local rows = tonumber(rows_str)

    return cols, rows
end

-- Detect terminal size using stty (alternative method)
function ScreenSize.detect_with_stty()
    local success, handle = pcall(io.popen, "stty size 2>/dev/null")
    if not success or not handle then
        return nil, nil
    end

    local output = handle:read("*a")
    handle:close()

    local rows_str, cols_str = output:match("(%d+)%s+(%d+)")
    local rows = tonumber(rows_str)
    local cols = tonumber(cols_str)

    return cols, rows
end

-- Main detection function with fallback
-- Returns: cols, rows, or defaults (80, 24) if detection fails
function ScreenSize.detect(force_refresh)
    -- Check cache first (unless force refresh)
    if not force_refresh and ScreenSize.cache.cols then
        local current_time = os.time()
        if current_time - ScreenSize.cache.timestamp < ScreenSize.cache_timeout then
            return ScreenSize.cache.cols, ScreenSize.cache.rows
        end
    end

    -- Try tput first (most reliable)
    local cols, rows = ScreenSize.detect_with_tput()

    -- Fallback to stty if tput fails
    if not cols or not rows then
        cols, rows = ScreenSize.detect_with_stty()
    end

    -- Ultimate fallback to standard 80x24
    if not cols or not rows or cols < 20 or rows < 10 then
        cols = 80
        rows = 24
    end

    -- Update cache
    ScreenSize.cache.cols = cols
    ScreenSize.cache.rows = rows
    ScreenSize.cache.timestamp = os.time()
    ScreenSize.cache.size_class = ScreenSize.classify(cols, rows)

    return cols, rows
end

-- Classify screen size into breakpoint category
function ScreenSize.classify(cols, rows)
    if cols < 80 or rows < 24 then
        return "tiny"
    elseif cols < 100 or rows < 30 then
        return "small"
    elseif cols < 140 or rows < 45 then
        return "medium"
    elseif cols < 180 or rows < 60 then
        return "large"
    else
        return "xlarge"
    end
end

-- Get current screen info with classification
function ScreenSize.get_info(force_refresh)
    local cols, rows = ScreenSize.detect(force_refresh)
    local size_class = ScreenSize.classify(cols, rows)

    return {
        cols = cols,
        rows = rows,
        size_class = size_class,
        is_tiny = size_class == "tiny",
        is_small = size_class == "small",
        is_medium = size_class == "medium",
        is_large = size_class == "large",
        is_xlarge = size_class == "xlarge"
    }
end

-- Get layout configuration based on size class
-- Returns responsive layout parameters for UI components
function ScreenSize.get_layout_config(size_class)
    local configs = {
        tiny = {
            -- Minimum support - very compact
            header_height = 2,
            footer_height = 1,
            content_area_height = 21,
            show_borders = false,
            show_ascii_art = false,
            show_shadows = false,

            -- Box sizing
            box_padding = 1,
            box_min_width = 30,

            -- Panel layouts
            character_panel_width = 30,
            dungeon_panel_width = 40,

            -- Text
            text_wrap_width = 70,
            max_log_lines = 3,
            max_effect_lines = 1,

            -- Menu
            menu_option_padding = 20,

            -- Combat
            combat_log_lines = 2,
            show_enemy_art = false,

            -- Floating pane
            floating_pane_max_width = 60,
            floating_pane_max_height = 8
        },

        small = {
            -- Compact mode for 80x24 standard terminals
            header_height = 3,
            footer_height = 2,
            content_area_height = 19,
            show_borders = true,
            show_ascii_art = false,  -- Skip ASCII art on small screens
            show_shadows = false,

            box_padding = 1,
            box_min_width = 30,

            character_panel_width = 35,
            dungeon_panel_width = 42,

            text_wrap_width = 75,
            max_log_lines = 5,
            max_effect_lines = 2,

            menu_option_padding = 30,

            combat_log_lines = 3,
            show_enemy_art = false,

            floating_pane_max_width = 70,
            floating_pane_max_height = 10
        },

        medium = {
            -- Standard mode for typical terminal sizes (100x30+)
            header_height = 3,
            footer_height = 2,
            content_area_height = 25,
            show_borders = true,
            show_ascii_art = true,
            show_shadows = true,

            box_padding = 2,
            box_min_width = 40,

            character_panel_width = 40,
            dungeon_panel_width = 50,

            text_wrap_width = 90,
            max_log_lines = 8,
            max_effect_lines = 3,

            menu_option_padding = 40,

            combat_log_lines = 4,
            show_enemy_art = true,

            floating_pane_max_width = 80,
            floating_pane_max_height = 15
        },

        large = {
            -- Expanded mode for large terminals (140x45+)
            header_height = 4,
            footer_height = 2,
            content_area_height = 39,
            show_borders = true,
            show_ascii_art = true,
            show_shadows = true,

            box_padding = 3,
            box_min_width = 50,

            character_panel_width = 50,
            dungeon_panel_width = 70,

            text_wrap_width = 120,
            max_log_lines = 12,
            max_effect_lines = 5,

            menu_option_padding = 50,

            combat_log_lines = 6,
            show_enemy_art = true,

            floating_pane_max_width = 100,
            floating_pane_max_height = 20
        },

        xlarge = {
            -- Ultra-wide mode (180+ cols)
            header_height = 4,
            footer_height = 2,
            content_area_height = 54,
            show_borders = true,
            show_ascii_art = true,
            show_shadows = true,

            box_padding = 4,
            box_min_width = 60,

            character_panel_width = 60,
            dungeon_panel_width = 80,

            text_wrap_width = 150,
            max_log_lines = 15,
            max_effect_lines = 7,

            menu_option_padding = 60,

            combat_log_lines = 8,
            show_enemy_art = true,

            floating_pane_max_width = 120,
            floating_pane_max_height = 25
        }
    }

    return configs[size_class] or configs.medium
end

-- Get responsive dimensions for a centered box
-- Returns x, y, width, height adjusted for screen size
function ScreenSize.get_centered_box(desired_width, desired_height, screen_info)
    local cols = screen_info.cols
    local rows = screen_info.rows

    -- Ensure box fits on screen with padding
    local max_width = cols - 4
    local max_height = rows - 6  -- Leave room for header/footer

    local width = math.min(desired_width, max_width)
    local height = math.min(desired_height, max_height)

    -- Center the box
    local x = math.floor((cols - width) / 2)
    local y = math.floor((rows - height) / 2)

    -- Ensure minimum position
    x = math.max(1, x)
    y = math.max(4, y)  -- Below header

    return x, y, width, height
end

-- Calculate responsive column positions for multi-column layouts
function ScreenSize.get_column_layout(num_columns, screen_info)
    local cols = screen_info.cols
    local layout = ScreenSize.get_layout_config(screen_info.size_class)

    if num_columns == 1 then
        return {{x = 2, width = cols - 4}}
    elseif num_columns == 2 then
        -- Two column layout
        local gutter = layout.box_padding * 2
        local total_width = cols - 4 - gutter
        local col_width = math.floor(total_width / 2)

        return {
            {x = 2, width = col_width},
            {x = 2 + col_width + gutter, width = col_width}
        }
    elseif num_columns == 3 then
        -- Three column layout (only on large+ screens)
        if screen_info.size_class == "tiny" or screen_info.size_class == "small" then
            -- Fall back to 2 columns
            return ScreenSize.get_column_layout(2, screen_info)
        end

        local gutter = layout.box_padding * 2
        local total_width = cols - 4 - (gutter * 2)
        local col_width = math.floor(total_width / 3)

        return {
            {x = 2, width = col_width},
            {x = 2 + col_width + gutter, width = col_width},
            {x = 2 + (col_width * 2) + (gutter * 2), width = col_width}
        }
    end

    return {{x = 2, width = cols - 4}}
end

-- Calculate percentage-based width
function ScreenSize.percent_width(percent, screen_info)
    return math.floor(screen_info.cols * (percent / 100))
end

-- Calculate percentage-based height
function ScreenSize.percent_height(percent, screen_info)
    return math.floor(screen_info.rows * (percent / 100))
end

-- Check if current screen size is below minimum recommended
function ScreenSize.is_below_minimum()
    local cols, rows = ScreenSize.detect()
    return cols < 80 or rows < 24
end

-- Get a warning message for undersized terminals
function ScreenSize.get_size_warning()
    local cols, rows = ScreenSize.detect()

    if cols < 80 or rows < 24 then
        return string.format(
            "Terminal size (%dx%d) is below recommended minimum (80x24). " ..
            "Some UI elements may not display correctly. " ..
            "Please resize your terminal for the best experience.",
            cols, rows
        )
    end

    return nil
end

-- Display a warning screen for undersized terminals
function ScreenSize.show_size_warning()
    local warning = ScreenSize.get_size_warning()
    if not warning then
        return false
    end

    -- Clear screen and show warning
    io.write("\27[2J\27[H")  -- Clear screen
    io.write("\27[33m")  -- Yellow color
    io.write("\n")
    io.write("  ⚠ WARNING: Terminal Too Small ⚠\n")
    io.write("\27[0m")  -- Reset color
    io.write("\n")

    -- Word wrap the warning
    local max_width = 70
    local words = {}
    for word in warning:gmatch("%S+") do
        table.insert(words, word)
    end

    local line = "  "
    for _, word in ipairs(words) do
        if #line + #word + 1 <= max_width then
            line = line .. word .. " "
        else
            io.write(line .. "\n")
            line = "  " .. word .. " "
        end
    end
    if #line > 2 then
        io.write(line .. "\n")
    end

    io.write("\n")
    io.write("  Press any key to continue anyway, or resize and restart...\n")
    io.write("\n")

    return true
end

-- Format screen info for debugging
function ScreenSize.format_debug_info(screen_info)
    return string.format(
        "Screen: %dx%d | Class: %s | Layout: %s",
        screen_info.cols,
        screen_info.rows,
        screen_info.size_class,
        screen_info.is_tiny and "Minimal" or
        screen_info.is_small and "Compact" or
        screen_info.is_medium and "Standard" or
        screen_info.is_large and "Expanded" or
        "Ultra-Wide"
    )
end

return ScreenSize
