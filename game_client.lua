#!/usr/bin/env lua
-- Game Client - Enhanced with persistent connection support

local socket = require("socket")

local HOST = "127.0.0.1"
local PORT = 9999
local INTERACTIVE_MODE = false
local SESSION_ID = nil

-- Parse command line arguments
local args = {...}
local command_parts = {}

for i, arg in ipairs(args) do
    if arg == "-i" or arg == "--interactive" then
        INTERACTIVE_MODE = true
    else
        table.insert(command_parts, arg)
    end
end

local command = table.concat(command_parts, " ")

-- Connect to server
local function connect()
    local client = socket.tcp()
    client:settimeout(10)
    
    local success, err = client:connect(HOST, PORT)
    if not success then
        print("❌ Could not connect to game server!")
        print("💡 Start the server with: lua game_server.lua")
        print("Error: " .. tostring(err))
        return nil
    end
    
    -- Receive welcome message with session ID
    local welcome, err = client:receive()
    if welcome and welcome:match("^WELCOME:") then
        SESSION_ID = welcome:match("^WELCOME:(.+)$")
        print(string.format("✅ Connected! Session: %s", SESSION_ID))
    end
    
    return client
end

-- Send command and get response
local function send_command(client, cmd)
    if not client then return nil, "Not connected" end
    
    local success, err = client:send(cmd .. "\n")
    if not success then
        return nil, "Send failed: " .. tostring(err)
    end
    
    -- Read all lines until empty line or timeout
    local lines = {}
    client:settimeout(0.5)
    while true do
        local line, err = client:receive()
        if not line then
            break
        end
        table.insert(lines, line)
    end
    
    if #lines == 0 then
        return nil, "No response received"
    end
    
    return table.concat(lines, "\n")
end

-- Interactive mode
local function interactive_mode()
    local client = connect()
    if not client then
        os.exit(1)
    end
    
    print("\n🎮 Interactive mode - type 'quit' to exit")
    print("📝 Commands: status, map, search, move <n>, save, help\n")
    
    client:settimeout(0.1) -- Make non-blocking for interactive use
    
    while true do
        io.write("> ")
        io.flush()
        local input = io.read()
        
        if not input or input == "quit" or input == "exit" then
            print("👋 Goodbye!")
            break
        end
        
        if input == "help" then
            print([[
Commands:
  status       - Show character stats
  map          - Show dungeon map
  search       - Search current room
  move <n>     - Move to chamber <n>
  save         - Save game
  ping         - Test connection
  quit         - Exit interactive mode
]])
        elseif input ~= "" then
            -- Send command
            client:settimeout(5) -- Blocking for command
            local response, err = send_command(client, input)
            client:settimeout(0.1) -- Back to non-blocking
            
            if response then
                print(response)
            else
                print("❌ Error: " .. tostring(err))
                print("🔄 Attempting to reconnect...")
                client:close()
                client = connect()
                if not client then
                    print("❌ Reconnection failed!")
                    break
                end
            end
        end
        
        print() -- Blank line for readability
    end
    
    client:close()
end

-- Single command mode
local function single_command_mode(cmd)
    if cmd == "" then
        print("Usage: lua game_client.lua <command>")
        print("       lua game_client.lua -i  (interactive mode)")
        print("\nExamples:")
        print("  lua game_client.lua search")
        print("  lua game_client.lua move 4")
        print("  lua game_client.lua status")
        print("  lua game_client.lua map")
        print("  lua game_client.lua -i")
        os.exit(1)
    end
    
    local client = connect()
    if not client then
        os.exit(1)
    end
    
    local response, err = send_command(client, cmd)
    if response then
        print(response)
    else
        print("❌ Error: " .. tostring(err))
        os.exit(1)
    end
    
    client:close()
end

-- Main
if INTERACTIVE_MODE then
    interactive_mode()
else
    single_command_mode(command)
end
