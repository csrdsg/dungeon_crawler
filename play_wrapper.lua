#!/usr/bin/env lua
-- Pure Lua game wrapper with integrated server management

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

local socket = require("socket")

local HOST = "127.0.0.1"
local PORT = 9999
local server_process = nil

-- Start server in background
local function start_server()
    print("🎮 Starting game server...")
    
    -- Fork server process
    local pid = io.popen("lua game_server.lua > /tmp/game_server.log 2>&1 & echo $!")
    local server_pid = pid:read("*l")
    pid:close()
    
    if server_pid then
        server_process = tonumber(server_pid)
        print("✅ Server started (PID: " .. server_pid .. ")")
    end
    
    -- Wait for server to be ready
    socket.sleep(2)
    
    -- Verify server is running
    local test = socket.tcp()
    test:settimeout(1)
    local ok = test:connect(HOST, PORT)
    test:close()
    
    if not ok then
        print("❌ Server failed to start")
        return false
    end
    
    return true
end

-- Stop server
local function stop_server()
    if server_process then
        print("\n🛑 Stopping server...")
        os.execute("kill " .. server_process .. " 2>/dev/null")
    end
end

-- Connect to server
local function connect()
    local client = socket.tcp()
    client:settimeout(5)
    
    local success, err = client:connect(HOST, PORT)
    if not success then
        return nil, err
    end
    
    -- Receive welcome message
    local welcome = client:receive()
    if welcome and welcome:match("^WELCOME:") then
        local session_id = welcome:match("^WELCOME:(.+)$")
        print(string.format("✅ Connected! Session: %s\n", session_id))
    end
    
    return client
end

-- Send command
local function send_command(client, cmd)
    if not client then return nil, "Not connected" end
    
    local success, err = client:send(cmd .. "\n")
    if not success then
        return nil, "Send failed: " .. tostring(err)
    end
    
    client:settimeout(10)
    local response, err = client:receive()
    if not response then
        return nil, "Receive failed: " .. tostring(err)
    end
    
    return response
end

-- Main game loop
local function main()
    -- Start server
    if not start_server() then
        print("❌ Failed to start server. Check /tmp/game_server.log")
        os.exit(1)
    end
    
    -- Connect client
    local client = connect()
    if not client then
        print("❌ Could not connect to server!")
        stop_server()
        os.exit(1)
    end
    
    print("🎮 Game ready! Type 'help' for commands, 'quit' to exit\n")
    
    -- Keep stdin/stdout active
    io.stdout:setvbuf("no")
    io.stdin:setvbuf("no")
    
    -- Game loop
    while true do
        io.write("> ")
        io.flush()
        local input = io.read("*l")
        
        if not input or input == "quit" or input == "exit" then
            print("👋 Goodbye!")
            break
        end
        
        if input == "" then
            -- Skip empty input
        elseif input == "help" then
            print([[
📖 COMMANDS:
  status       - Show character stats
  quests       - View quest log (active/completed)
  map          - Show dungeon map
  search       - Search current room
  move <n>     - Move to chamber <n>
  rest         - Take a short rest
  potion       - Use healing potion
  save         - Save game
  quit         - Exit game
]])
        else
            -- Send command to server
            local response, err = send_command(client, input)
            
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
        
        print() -- Blank line
    end
    
    -- Cleanup
    if client then
        client:close()
    end
    stop_server()
end

-- Run with cleanup
local ok, err = pcall(main)
if not ok then
    print("❌ Error: " .. tostring(err))
    stop_server()
    os.exit(1)
end
