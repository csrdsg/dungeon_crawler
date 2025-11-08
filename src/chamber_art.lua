#!/usr/bin/env lua

-- ASCII Art for different chamber types

-- Load chamber art from external file
local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("(.*/)")
local data_dir = script_dir and script_dir:gsub("src/$", "data/") or "../data/"
local chamber_art = dofile(data_dir .. "chamber_art.lua")

function get_chamber_art(chamber_type)
    return chamber_art[chamber_type] or chamber_art[1]
end

return {
    get_chamber_art = get_chamber_art
}
