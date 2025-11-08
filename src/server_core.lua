-- Server Core - Enhanced async server with session management
local socket = require("socket")

local ServerCore = {}
ServerCore.__index = ServerCore

function ServerCore.new(host, port)
    local self = setmetatable({}, ServerCore)
    
    self.host = host or "127.0.0.1"
    self.port = port or 9999
    self.server = nil
    self.clients = {}
    self.sessions = {}
    self.running = false
    self.handlers = {}
    self.error_handler = nil
    self.heartbeat_interval = 30
    self.client_timeout = 300
    self.max_clients = 10
    
    return self
end

function ServerCore:start()
    local server, err = socket.bind(self.host, self.port)
    if not server then
        return false, "Failed to bind: " .. tostring(err)
    end
    
    server:settimeout(0) -- Non-blocking
    self.server = server
    self.running = true
    
    print(string.format("🚀 Server started on %s:%d", self.host, self.port))
    return true
end

function ServerCore:stop()
    self.running = false
    
    -- Close all client connections
    for client_id, client_data in pairs(self.clients) do
        self:disconnect_client(client_id, "Server shutdown")
    end
    
    if self.server then
        self.server:close()
        self.server = nil
    end
    
    print("🛑 Server stopped")
end

function ServerCore:accept_clients()
    if not self.server then return end
    
    -- Accept new connections
    while true do
        local client = self.server:accept()
        if not client then break end
        
        if self:count_clients() >= self.max_clients then
            client:send("ERROR: Server full\n")
            client:close()
        else
            self:add_client(client)
        end
    end
end

function ServerCore:add_client(client)
    client:settimeout(0) -- Non-blocking
    
    local client_id = tostring(client):match("0x%x+") or tostring(os.time())
    local session_id = self:generate_session_id()
    
    self.clients[client_id] = {
        socket = client,
        session_id = session_id,
        connected_at = os.time(),
        last_activity = os.time(),
        buffer = ""
    }
    
    self.sessions[session_id] = {
        client_id = client_id,
        created_at = os.time(),
        data = {}
    }
    
    print(string.format("✅ Client connected: %s (session: %s)", client_id, session_id))
    
    -- Send welcome message
    client:send(string.format("WELCOME:%s\n", session_id))
    
    if self.handlers.on_connect then
        self.handlers.on_connect(session_id)
    end
end

function ServerCore:disconnect_client(client_id, reason)
    local client_data = self.clients[client_id]
    if not client_data then return end
    
    local session_id = client_data.session_id
    
    if self.handlers.on_disconnect then
        self.handlers.on_disconnect(session_id, reason or "Client disconnected")
    end
    
    client_data.socket:close()
    self.clients[client_id] = nil
    self.sessions[session_id] = nil
    
    print(string.format("❌ Client disconnected: %s (reason: %s)", client_id, reason or "unknown"))
end

function ServerCore:process_clients()
    local to_remove = {}
    
    for client_id, client_data in pairs(self.clients) do
        local socket = client_data.socket
        
        -- Check for timeout
        if os.time() - client_data.last_activity > self.client_timeout then
            table.insert(to_remove, {client_id, "Timeout"})
        else
            -- Try to read data
            local data, err, partial = socket:receive("*l")
            
            if data then
                client_data.last_activity = os.time()
                self:handle_message(client_id, data)
            elseif partial and partial ~= "" then
                -- Partial data received, buffer it
                client_data.buffer = client_data.buffer .. partial
            elseif err == "closed" then
                table.insert(to_remove, {client_id, "Connection closed"})
            end
        end
    end
    
    -- Remove disconnected clients
    for _, item in ipairs(to_remove) do
        self:disconnect_client(item[1], item[2])
    end
end

function ServerCore:handle_message(client_id, message)
    local client_data = self.clients[client_id]
    if not client_data then return end
    
    local session_id = client_data.session_id
    
    -- Handle heartbeat
    if message == "PING" then
        self:send_to_client(client_id, "PONG")
        return
    end
    
    -- Call message handler
    if self.handlers.on_message then
        local success, response = pcall(self.handlers.on_message, session_id, message)
        
        if success then
            if response then
                self:send_to_client(client_id, response)
            end
        else
            local err_msg = "ERROR: " .. tostring(response)
            self:send_to_client(client_id, err_msg)
            
            if self.error_handler then
                self.error_handler(session_id, response)
            end
        end
    end
end

function ServerCore:send_to_client(client_id, message)
    local client_data = self.clients[client_id]
    if not client_data then return false end
    
    local success, err = client_data.socket:send(message .. "\n")
    return success ~= nil
end

function ServerCore:send_to_session(session_id, message)
    local session = self.sessions[session_id]
    if not session then return false end
    
    return self:send_to_client(session.client_id, message)
end

function ServerCore:broadcast(message, exclude_session)
    for session_id, _ in pairs(self.sessions) do
        if session_id ~= exclude_session then
            self:send_to_session(session_id, message)
        end
    end
end

function ServerCore:run_loop()
    while self.running do
        self:accept_clients()
        self:process_clients()
        socket.sleep(0.01)
    end
end

function ServerCore:get_session_data(session_id)
    local session = self.sessions[session_id]
    return session and session.data
end

function ServerCore:set_session_data(session_id, key, value)
    local session = self.sessions[session_id]
    if session then
        session.data[key] = value
    end
end

function ServerCore:count_clients()
    local count = 0
    for _ in pairs(self.clients) do
        count = count + 1
    end
    return count
end

function ServerCore:generate_session_id()
    return string.format("%s-%d", os.date("%Y%m%d%H%M%S"), math.random(1000, 9999))
end

function ServerCore:on(event, handler)
    self.handlers[event] = handler
end

function ServerCore:on_error(handler)
    self.error_handler = handler
end

return ServerCore
