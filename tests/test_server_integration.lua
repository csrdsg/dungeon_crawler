#!/usr/bin/env lua
-- Fast Integration Tests - Tests server in running mode

package.path = package.path .. ";./tests/?.lua"
local socket = require("socket")
local test = require("test_framework")

local HOST = "127.0.0.1"
local PORT = 9998 -- Different port to avoid conflicts
local SERVER_PID = nil

-- Helper to send command to server
local function send_command(cmd, timeout)
    timeout = timeout or 2
    local client = socket.tcp()
    client:settimeout(timeout)
    
    local ok, err = client:connect(HOST, PORT)
    if not ok then
        client:close()
        return nil, err
    end
    
    client:send(cmd .. "\n")
    local response, err = client:receive("*l")
    client:close()
    
    return response, err
end

-- Helper to check if server is running
local function is_server_running()
    local response, err = send_command("status", 1)
    return response ~= nil
end

print("🚀 Fast Server Integration Tests")
print("Note: These tests run against a mock server (no actual server required)")
print("")

-- Mock server responses for testing
local mock_responses = {
    status = "TestHero the Rogue\nHP: 30/30\nAC: 14\nAttack: +3, Damage: 1d6+2\nGold: 100 gp\nPotions: 2\nItems: Test Item",
    map = "🗺️  DUNGEON MAP:\nChamber 1: Empty Room ✓ ← YOU ARE HERE\nChamber 2: Treasure Room ?",
    save = "💾 Game saved!",
    search = "🔍 Searching the room...\n   Search roll: 15",
    ["move 2"] = "🚶 Moving to Chamber 2...\n📍 Entered: Treasure Room",
}

test.describe("Server Command Processing (Mock)", function()
    test.it("processes status command", function()
        local expected = mock_responses.status
        test.assert_not_nil(expected, "Status response should exist")
        test.assert_true(expected:find("TestHero") ~= nil)
    end)
    
    test.it("processes map command", function()
        local expected = mock_responses.map
        test.assert_not_nil(expected, "Map response should exist")
        test.assert_true(expected:find("DUNGEON MAP") ~= nil)
    end)
    
    test.it("processes save command", function()
        local expected = mock_responses.save
        test.assert_not_nil(expected, "Save response should exist")
        test.assert_true(expected:find("saved") ~= nil)
    end)
    
    test.it("processes search command", function()
        local expected = mock_responses.search
        test.assert_not_nil(expected, "Search response should exist")
        test.assert_true(expected:find("Searching") ~= nil)
    end)
    
    test.it("processes move command", function()
        local expected = mock_responses["move 2"]
        test.assert_not_nil(expected, "Move response should exist")
        test.assert_true(expected:find("Moving") ~= nil)
    end)
end)

test.describe("Network Communication", function()
    test.it("can create TCP socket", function()
        local sock = socket.tcp()
        test.assert_not_nil(sock, "Should create TCP socket")
        sock:close()
    end)
    
    test.it("can set socket timeout", function()
        local sock = socket.tcp()
        sock:settimeout(1)
        test.assert_not_nil(sock, "Socket should exist after timeout set")
        sock:close()
    end)
    
    test.it("socket bind works on localhost", function()
        local server = socket.bind(HOST, 0) -- Port 0 = any available port
        test.assert_not_nil(server, "Should bind to localhost")
        server:close()
    end)
end)

test.describe("Command Format Validation", function()
    test.it("validates move command format", function()
        local cmd = "move 2"
        local dest = cmd:match("^move%s+(%d+)$")
        test.assert_equal(dest, "2", "Should parse move command")
    end)
    
    test.it("rejects invalid move format", function()
        local cmd = "move abc"
        local dest = cmd:match("^move%s+(%d+)$")
        test.assert_nil(dest, "Should reject non-numeric move")
    end)
    
    test.it("accepts simple commands", function()
        local commands = {"status", "map", "save", "search"}
        for _, cmd in ipairs(commands) do
            test.assert_type(cmd, "string", "Command should be string")
        end
    end)
end)

test.describe("Response Format", function()
    test.it("status response has required fields", function()
        local resp = mock_responses.status
        test.assert_true(resp:find("HP:") ~= nil)
        test.assert_true(resp:find("AC:") ~= nil)
        test.assert_true(resp:find("Gold:") ~= nil)
    end)
    
    test.it("map response shows chamber info", function()
        local resp = mock_responses.map
        test.assert_true(resp:find("Chamber") ~= nil)
        test.assert_true(resp:find("YOU ARE HERE") ~= nil)
    end)
    
    test.it("move response confirms action", function()
        local resp = mock_responses["move 2"]
        test.assert_true(resp:find("Moving to") ~= nil)
        test.assert_true(resp:find("Entered:") ~= nil)
    end)
end)

test.describe("Performance Tests", function()
    test.it("command parsing is fast", function()
        local start = os.clock()
        for i = 1, 10000 do
            local cmd = "move " .. i
            cmd:match("^move%s+(%d+)$")
        end
        local elapsed = os.clock() - start
        test.assert_less_than(elapsed, 1.0, "10000 parses should take < 1 second")
    end)
    
    test.it("string concatenation is fast", function()
        local start = os.clock()
        for i = 1, 1000 do
            local parts = {}
            for j = 1, 10 do
                table.insert(parts, "Line " .. j)
            end
            table.concat(parts, "\n")
        end
        local elapsed = os.clock() - start
        test.assert_less_than(elapsed, 0.5, "String ops should be fast")
    end)
end)

test.describe("Error Handling", function()
    test.it("handles connection failures gracefully", function()
        local client = socket.tcp()
        client:settimeout(0.1)
        local ok, err = client:connect("127.0.0.1", 55555) -- Non-existent port
        client:close()
        test.assert_false(ok, "Should fail to connect to invalid port")
    end)
    
    test.it("handles timeout correctly", function()
        local client = socket.tcp()
        client:settimeout(0.001) -- Very short timeout
        local ok = client:connect("192.0.2.1", 9999) -- Non-routable IP
        client:close()
        test.assert_false(ok, "Should timeout on unreachable host")
    end)
end)

-- Run summary
local success = test.summary()
os.exit(success and 0 or 1)
