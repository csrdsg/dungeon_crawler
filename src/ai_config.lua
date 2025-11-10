-- AI Configuration
-- Settings for AI Storyteller module

return {
    -- AI Mode
    enabled = false,  -- Toggle AI on/off (set via command line)
    
    -- Provider Settings
    provider = "ollama",  -- "ollama" or "openai"
    
    -- Ollama Config (Local LLM)
    ollama = {
        endpoint = "http://localhost:11434/api/generate",
        model = nil,  -- Auto-detect fastest available model
        timeout = 3
    },
    
    -- OpenAI Config (Cloud API)
    openai = {
        endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-3.5-turbo",  -- Options: gpt-3.5-turbo, gpt-4, gpt-4-turbo
        api_key = os.getenv("OPENAI_API_KEY"),
        timeout = 5
    },
    
    -- Generation Settings
    max_tokens = 150,  -- Shorter, faster descriptions
    temperature = 0.7,  -- 0.0 = deterministic, 1.0 = creative
    
    -- Features (Phase 1)
    narrate_chambers = true,
    narrate_combat = true,
    narrate_items = false,  -- Phase 2
    narrate_dialogue = false,  -- Phase 2
    
    -- Performance
    cache_enabled = true,
    cache_size = 100,
    async_mode = false,  -- Future: async generation
    
    -- Fallbacks
    use_static_on_error = true,
    max_retries = 1,  -- Fewer retries for speed
    
    -- Debug
    verbose = false,
    log_prompts = false,
    log_responses = false
}
