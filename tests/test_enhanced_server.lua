#!/usr/bin/env lua
-- Tests for Enhanced Server Core

package.path = package.path .. ";./src/?.lua;./tests/?.lua"
local test = require("test_framework")
local ServerCore = require("server_core")

test.describe("ServerCore Initialization", function()
    test.it("creates server instance", function()
        local server = ServerCore.new("127.0.0.1", 9998)
        test.assert_not_nil(server)
        test.assert_equal(server.host, "127.0.0.1")
        test.assert_equal(server.port, 9998)
        test.assert_false(server.running)
    end)
    
    test.it("sets default configuration", function()
        local server = ServerCore.new()
        test.assert_equal(server.host, "127.0.0.1")
        test.assert_equal(server.port, 9999)
        test.assert_equal(server.max_clients, 10)
        test.assert_equal(server.client_timeout, 300)
    end)
end)

test.describe("Session Management", function()
    test.it("generates unique session IDs", function()
        local server = ServerCore.new()
        local id1 = server:generate_session_id()
        local id2 = server:generate_session_id()
        test.assert_not_nil(id1)
        test.assert_not_nil(id2)
        test.assert_type(id1, "string")
        test.assert_true(id1 ~= id2)
    end)
    
    test.it("stores and retrieves session data", function()
        local server = ServerCore.new()
        local session_id = "test-session-123"
        server.sessions[session_id] = {data = {}}
        
        server:set_session_data(session_id, "player_hp", 100)
        local hp = server:get_session_data(session_id).player_hp
        test.assert_equal(hp, 100)
    end)
    
    test.it("counts clients correctly", function()
        local server = ServerCore.new()
        test.assert_equal(server:count_clients(), 0)
        
        server.clients["client1"] = {session_id = "s1"}
        server.clients["client2"] = {session_id = "s2"}
        test.assert_equal(server:count_clients(), 2)
    end)
end)

test.describe("Event Handlers", function()
    test.it("registers event handlers", function()
        local server = ServerCore.new()
        local called = false
        
        server:on("on_connect", function(session_id)
            called = true
        end)
        
        test.assert_not_nil(server.handlers.on_connect)
    end)
    
    test.it("registers error handlers", function()
        local server = ServerCore.new()
        local error_caught = false
        
        server:on_error(function(session_id, err)
            error_caught = true
        end)
        
        test.assert_not_nil(server.error_handler)
    end)
end)

test.describe("Message Handling", function()
    test.it("handles PING heartbeat", function()
        local server = ServerCore.new()
        local response_sent = false
        
        server.clients["test"] = {
            session_id = "s1",
            socket = {
                send = function(self, msg)
                    if msg == "PONG\n" then
                        response_sent = true
                    end
                    return true
                end
            }
        }
        
        server:handle_message("test", "PING")
        test.assert_true(response_sent)
    end)
    
    test.it("processes custom messages", function()
        local server = ServerCore.new()
        local message_received = nil
        
        server.clients["test"] = {
            session_id = "s1",
            socket = {send = function(self, msg) return true end}
        }
        server.sessions["s1"] = {client_id = "test", data = {}}
        
        server:on("on_message", function(session_id, msg)
            message_received = msg
            return "OK"
        end)
        
        server:handle_message("test", "status")
        test.assert_equal(message_received, "status")
    end)
end)

test.describe("Broadcasting", function()
    test.it("sends message to all sessions", function()
        local server = ServerCore.new()
        local received = {}
        
        local function mock_send(msg)
            table.insert(received, msg)
            return true
        end
        
        server.clients["c1"] = {
            session_id = "s1",
            socket = {send = function(self, msg) return mock_send(msg) end}
        }
        server.clients["c2"] = {
            session_id = "s2",
            socket = {send = function(self, msg) return mock_send(msg) end}
        }
        server.sessions["s1"] = {client_id = "c1"}
        server.sessions["s2"] = {client_id = "c2"}
        
        server:broadcast("Hello all!")
        test.assert_equal(#received, 2)
    end)
    
    test.it("excludes specific session from broadcast", function()
        local server = ServerCore.new()
        local received = {}
        
        server.clients["c1"] = {
            session_id = "s1",
            socket = {send = function(self, msg) table.insert(received, "s1") return true end}
        }
        server.clients["c2"] = {
            session_id = "s2",
            socket = {send = function(self, msg) table.insert(received, "s2") return true end}
        }
        server.sessions["s1"] = {client_id = "c1"}
        server.sessions["s2"] = {client_id = "c2"}
        
        server:broadcast("Test", "s1")
        test.assert_equal(#received, 1)
        test.assert_equal(received[1], "s2")
    end)
end)

test.describe("Error Handling", function()
    test.it("catches errors in message handlers", function()
        local server = ServerCore.new()
        local error_caught = false
        
        server.clients["test"] = {
            session_id = "s1",
            socket = {send = function(self, msg) return true end}
        }
        server.sessions["s1"] = {client_id = "test"}
        
        server:on("on_message", function(session_id, msg)
            error("Test error")
        end)
        
        server:on_error(function(session_id, err)
            error_caught = true
        end)
        
        server:handle_message("test", "test")
        test.assert_true(error_caught)
    end)
    
    test.it("sends error response to client", function()
        local server = ServerCore.new()
        local error_msg = nil
        
        server.clients["test"] = {
            session_id = "s1",
            socket = {
                send = function(self, msg)
                    if msg:match("^ERROR:") then
                        error_msg = msg
                    end
                    return true
                end
            }
        }
        server.sessions["s1"] = {client_id = "test"}
        
        server:on("on_message", function(session_id, msg)
            error("Something went wrong")
        end)
        
        server:handle_message("test", "test")
        test.assert_not_nil(error_msg)
        test.assert_true(error_msg:match("ERROR:") ~= nil)
    end)
end)

test.describe("Connection Limits", function()
    test.it("enforces max client limit", function()
        local server = ServerCore.new()
        server.max_clients = 2
        
        test.assert_equal(server.max_clients, 2)
        
        -- Simulate clients
        server.clients["c1"] = {session_id = "s1"}
        server.clients["c2"] = {session_id = "s2"}
        
        test.assert_equal(server:count_clients(), 2)
        test.assert_true(server:count_clients() >= server.max_clients)
    end)
end)

-- Run summary
local success = test.summary()
os.exit(success and 0 or 1)
