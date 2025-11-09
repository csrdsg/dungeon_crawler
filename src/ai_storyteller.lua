-- AI Storyteller Module
-- Provides dynamic narrative generation using local LLMs (Ollama) or cloud APIs (OpenAI)

local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

local ai_storyteller = {
    config = {
        enabled = false,
        provider = "ollama",
        model = "llama3.2:3b",
        endpoint = "http://localhost:11434/api/generate",
        api_key = nil,
        timeout = 10,
        max_tokens = 500,
        temperature = 0.7,
        use_static_on_error = true,
        max_retries = 2,
        cache_enabled = true,
        cache_size = 100
    },
    
    -- Response cache
    cache = {},
    cache_order = {},
    
    -- Stats
    stats = {
        requests = 0,
        successes = 0,
        failures = 0,
        cache_hits = 0,
        total_latency = 0
    }
}

-- Initialize AI storyteller with config
function ai_storyteller.init(config)
    if config then
        for k, v in pairs(config) do
            ai_storyteller.config[k] = v
        end
    end
    
    -- Test connection on init
    if ai_storyteller.config.enabled then
        local success = ai_storyteller.test_connection()
        if not success then
            print("⚠️  AI Storyteller: Could not connect to " .. ai_storyteller.config.provider)
            print("    Falling back to static content")
            ai_storyteller.config.enabled = false
        else
            print("✅ AI Storyteller: Connected to " .. ai_storyteller.config.provider)
            print("   Model: " .. ai_storyteller.config.model)
        end
    end
    
    return ai_storyteller.config.enabled
end

-- Test connection to LLM provider
function ai_storyteller.test_connection()
    if ai_storyteller.config.provider == "ollama" then
        -- Test Ollama connection
        local response = {}
        local body, code = http.request{
            url = ai_storyteller.config.endpoint:gsub("/api/generate", "/api/tags"),
            sink = ltn12.sink.table(response)
        }
        return code == 200
    elseif ai_storyteller.config.provider == "openai" then
        -- Test OpenAI connection with models endpoint
        if not ai_storyteller.config.api_key then
            return false
        end
        local response = {}
        local body, code = http.request{
            url = "https://api.openai.com/v1/models",
            headers = {
                ["Authorization"] = "Bearer " .. ai_storyteller.config.api_key
            },
            sink = ltn12.sink.table(response)
        }
        return code == 200
    end
    
    return false
end

-- Get completion from LLM
function ai_storyteller.get_completion(prompt, options)
    options = options or {}
    
    ai_storyteller.stats.requests = ai_storyteller.stats.requests + 1
    local start_time = os.clock()
    
    -- Use custom cache key if provided, otherwise use prompt prefix
    local cache_key = options.cache_key or prompt:sub(1, 100)
    
    -- Try to get from cache first (only if no custom key was provided via options)
    if not options.cache_key and ai_storyteller.config.cache_enabled and ai_storyteller.cache[cache_key] then
        ai_storyteller.stats.cache_hits = ai_storyteller.stats.cache_hits + 1
        return ai_storyteller.cache[cache_key], 0
    end
    
    local response_text = nil
    local attempts = 0
    
    while attempts < ai_storyteller.config.max_retries and not response_text do
        attempts = attempts + 1
        
        if ai_storyteller.config.provider == "ollama" then
            response_text = ai_storyteller._get_ollama_completion(prompt, options)
        elseif ai_storyteller.config.provider == "openai" then
            response_text = ai_storyteller._get_openai_completion(prompt, options)
        end
        
        if not response_text and attempts < ai_storyteller.config.max_retries then
            -- Brief pause before retry
            os.execute("sleep 0.5")
        end
    end
    
    local latency = os.clock() - start_time
    ai_storyteller.stats.total_latency = ai_storyteller.stats.total_latency + latency
    
    if response_text then
        ai_storyteller.stats.successes = ai_storyteller.stats.successes + 1
        
        -- Cache the response
        if ai_storyteller.config.cache_enabled then
            ai_storyteller._cache_response(cache_key, response_text)
        end
        
        return response_text, latency
    else
        ai_storyteller.stats.failures = ai_storyteller.stats.failures + 1
        return nil, latency
    end
end

-- Get completion from Ollama
function ai_storyteller._get_ollama_completion(prompt, options)
    local request_body = {
        model = options.model or ai_storyteller.config.model,
        prompt = prompt,
        stream = false,
        options = {
            temperature = options.temperature or ai_storyteller.config.temperature,
            num_predict = options.max_tokens or ai_storyteller.config.max_tokens
        }
    }
    
    local request_json = json.encode(request_body)
    local response_body = {}
    
    local body, code, headers = http.request{
        url = ai_storyteller.config.endpoint,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#request_json)
        },
        source = ltn12.source.string(request_json),
        sink = ltn12.sink.table(response_body)
    }
    
    if code == 200 then
        local response_str = table.concat(response_body)
        local response_data = json.decode(response_str)
        
        if response_data and response_data.response then
            return response_data.response:match("^%s*(.-)%s*$")  -- Trim whitespace
        end
    end
    
    return nil
end

-- Get completion from OpenAI
function ai_storyteller._get_openai_completion(prompt, options)
    if not ai_storyteller.config.api_key then
        return nil
    end
    
    local request_body = {
        model = options.model or ai_storyteller.config.model,
        messages = {
            {role = "system", content = "You are a creative dungeon master narrating a dark fantasy adventure. Be vivid, atmospheric, and concise."},
            {role = "user", content = prompt}
        },
        temperature = options.temperature or ai_storyteller.config.temperature,
        max_tokens = options.max_tokens or ai_storyteller.config.max_tokens
    }
    
    local request_json = json.encode(request_body)
    local response_body = {}
    
    local body, code = http.request{
        url = "https://api.openai.com/v1/chat/completions",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. ai_storyteller.config.api_key,
            ["Content-Length"] = tostring(#request_json)
        },
        source = ltn12.source.string(request_json),
        sink = ltn12.sink.table(response_body)
    }
    
    if code == 200 then
        local response_str = table.concat(response_body)
        local response_data = json.decode(response_str)
        
        if response_data and response_data.choices and response_data.choices[1] then
            return response_data.choices[1].message.content:match("^%s*(.-)%s*$")
        end
    end
    
    return nil
end

-- Cache response
function ai_storyteller._cache_response(key, response)
    -- Add to cache
    ai_storyteller.cache[key] = response
    table.insert(ai_storyteller.cache_order, key)
    
    -- Evict oldest if cache is full
    if #ai_storyteller.cache_order > ai_storyteller.config.cache_size then
        local oldest_key = table.remove(ai_storyteller.cache_order, 1)
        ai_storyteller.cache[oldest_key] = nil
    end
end

-- Build prompt from template
function ai_storyteller.build_prompt(template, context)
    local prompt = template
    
    for key, value in pairs(context) do
        local placeholder = "{" .. key .. "}"
        local replacement = value
        
        if type(value) == "table" then
            replacement = table.concat(value, ", ")
        elseif type(value) == "boolean" then
            replacement = value and "yes" or "no"
        else
            replacement = tostring(value)
        end
        
        prompt = prompt:gsub(placeholder, replacement)
    end
    
    return prompt
end

-- Validate and sanitize response
function ai_storyteller.validate_response(text)
    if not text or text == "" then
        return nil
    end
    
    -- Basic sanitization
    text = text:match("^%s*(.-)%s*$")  -- Trim whitespace
    
    -- Check for minimum length
    if #text < 20 then
        return nil
    end
    
    -- Check for maximum length (prevent runaway generation)
    if #text > 2000 then
        text = text:sub(1, 2000)
    end
    
    return text
end

-- Narrate chamber entry
function ai_storyteller.narrate_chamber(chamber_data, player_context)
    if not ai_storyteller.config.enabled then
        return nil
    end
    
    -- Create unique cache key based on chamber properties
    local cache_key = "chamber:" .. (chamber_data.type or "unknown") .. ":" .. (chamber_data.exits or "none")
    
    -- Check cache first
    if ai_storyteller.config.cache_enabled and ai_storyteller.cache[cache_key] then
        ai_storyteller.stats.cache_hits = ai_storyteller.stats.cache_hits + 1
        ai_storyteller.stats.requests = ai_storyteller.stats.requests + 1
        return ai_storyteller.cache[cache_key]
    end
    
    local prompt_template = [[You are a dungeon master narrating a dark fantasy adventure. 
Describe the following chamber in 2-3 vivid, atmospheric sentences. Be immersive and concise.

Chamber Type: {chamber_type}
Exits: {exits}
Items: {items}
Enemies: {enemies}

Do not repeat information. Focus on atmosphere and sensory details.]]
    
    local context = {
        chamber_type = chamber_data.type or "chamber",
        exits = chamber_data.exits or "none",
        items = chamber_data.items or "none",
        enemies = chamber_data.enemies or "none"
    }
    
    local prompt = ai_storyteller.build_prompt(prompt_template, context)
    local response, latency = ai_storyteller.get_completion(prompt, {cache_key = cache_key})
    
    if response then
        response = ai_storyteller.validate_response(response)
        -- Cache the validated response
        if response and ai_storyteller.config.cache_enabled then
            ai_storyteller._cache_response(cache_key, response)
        end
    end
    
    return response
end

-- Narrate combat action
function ai_storyteller.narrate_combat(combat_event)
    if not ai_storyteller.config.enabled then
        return nil
    end
    
    local event_type = combat_event.event or "hit"
    local prompt_template
    
    if event_type == "hit" then
        prompt_template = [[Narrate this combat action in ONE dramatic sentence:

{attacker} attacks {defender} with {weapon} and hits for {damage} damage.

Be vivid but concise. Match dark fantasy tone.]]
    elseif event_type == "miss" then
        prompt_template = [[Narrate this combat action in ONE dramatic sentence:

{attacker} attacks {defender} with {weapon} but misses.

Be vivid but concise. Match dark fantasy tone.]]
    elseif event_type == "critical" then
        prompt_template = [[Narrate this CRITICAL HIT in ONE dramatic sentence:

{attacker} lands a devastating blow on {defender} with {weapon} for {damage} damage!

Be epic and vivid. Match dark fantasy tone.]]
    elseif event_type == "defeat" then
        prompt_template = [[Narrate this enemy defeat in ONE dramatic sentence:

{defender} has been slain by {attacker}.

Be vivid but concise. Match dark fantasy tone.]]
    else
        return nil
    end
    
    local context = {
        attacker = combat_event.attacker or "The warrior",
        defender = combat_event.defender or "the enemy",
        weapon = combat_event.weapon or "their weapon",
        damage = combat_event.damage or 0
    }
    
    local prompt = ai_storyteller.build_prompt(prompt_template, context)
    local response, latency = ai_storyteller.get_completion(prompt, {max_tokens = 100})
    
    if response then
        response = ai_storyteller.validate_response(response)
    end
    
    return response
end

-- Get stats
function ai_storyteller.get_stats()
    local avg_latency = 0
    if ai_storyteller.stats.requests > 0 then
        avg_latency = ai_storyteller.stats.total_latency / ai_storyteller.stats.requests
    end
    
    local success_rate = 0
    if ai_storyteller.stats.requests > 0 then
        success_rate = (ai_storyteller.stats.successes / ai_storyteller.stats.requests) * 100
    end
    
    return {
        enabled = ai_storyteller.config.enabled,
        provider = ai_storyteller.config.provider,
        model = ai_storyteller.config.model,
        requests = ai_storyteller.stats.requests,
        successes = ai_storyteller.stats.successes,
        failures = ai_storyteller.stats.failures,
        cache_hits = ai_storyteller.stats.cache_hits,
        avg_latency_ms = math.floor(avg_latency * 1000),
        success_rate = string.format("%.1f%%", success_rate)
    }
end

-- Clear cache
function ai_storyteller.clear_cache()
    ai_storyteller.cache = {}
    ai_storyteller.cache_order = {}
end

return ai_storyteller
