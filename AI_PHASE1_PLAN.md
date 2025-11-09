# AI Storyteller - Phase 1 Implementation Plan

**Branch:** `feature/ai-storyteller`  
**Start Date:** 2025-11-09  
**Target:** 2-3 days  
**Status:** Planning

---

## 🎯 Phase 1 Goals

1. Create AI storyteller module with LLM integration
2. Replace static chamber descriptions with dynamic AI narration
3. Add combat narration hooks
4. Implement caching and fallback mechanisms
5. Add configuration for Ollama/OpenAI

---

## 📋 Task Breakdown

### Task 1.1: AI Storyteller Core Module (4-6 hours)

**File:** `src/ai_storyteller.lua`

**Components:**
- [ ] LLM client wrapper (HTTP requests)
- [ ] Ollama integration (local, default)
- [ ] OpenAI integration (optional, premium)
- [ ] Error handling and retry logic
- [ ] Response validation and sanitization
- [ ] Fallback to static content

**API Structure:**
```lua
local ai_storyteller = {
    -- Config
    config = {
        provider = "ollama",  -- or "openai"
        model = "llama3.2",
        endpoint = "http://localhost:11434/api/generate",
        api_key = nil,
        timeout = 10,
        max_tokens = 500,
        temperature = 0.7
    },
    
    -- Core methods
    init = function(config) end,
    get_completion = function(prompt, options) end,
    narrate_chamber = function(chamber_data, player_context) end,
    narrate_combat = function(combat_event) end,
    generate_dialogue = function(npc_type, query, history) end,
    
    -- Utilities
    build_prompt = function(template, context) end,
    validate_response = function(text) end,
    cache_response = function(key, response) end,
    get_cached = function(key) end
}
```

**Dependencies:**
- `socket.http` for HTTP requests (already in LuaSocket)
- `dkjson` for JSON parsing (already used)
- `lfs` for cache file operations (if needed)

---

### Task 1.2: Chamber Description AI (3-4 hours)

**Files to modify:**
- `src/chamber_art.lua` (add AI integration points)
- `src/chamber_gen.lua` (pass context to AI)

**Implementation:**
```lua
-- In chamber_art.lua
function get_chamber_description(chamber_type, exits, items, enemies, player_history)
    -- Try AI first
    if AI_ENABLED then
        local context = {
            type = chamber_type,
            exits = exits,
            items = items,
            enemies = enemies,
            history = player_history
        }
        
        local ai_desc = ai_storyteller.narrate_chamber(context)
        if ai_desc then
            return ai_desc .. "\n\n" .. get_ascii_art(chamber_type)
        end
    end
    
    -- Fallback to static
    return get_static_description(chamber_type) .. "\n\n" .. get_ascii_art(chamber_type)
end
```

**Prompt Template:**
```
You are a dungeon master narrating a dark fantasy adventure. 
Describe the following chamber in 2-3 vivid sentences:

Chamber Type: {type}
Exits: {exits}
Items Present: {items}
Enemies: {enemies}
Player's Recent Journey: {history}

Keep it atmospheric, immersive, and concise. Do not repeat information.
```

**Caching Strategy:**
- Cache by chamber signature: `{type}_{items}_{enemies}`
- Max cache size: 100 entries
- TTL: Session-based (clear on disconnect)

---

### Task 1.3: Combat Narration Hooks (2-3 hours)

**Files to modify:**
- `src/combat.lua` (add narration hooks)

**Events to narrate:**
- Attack hit
- Attack miss
- Critical hit
- Enemy defeat
- Player victory
- Player defeat

**Example Hook:**
```lua
-- In combat.lua
function execute_attack(attacker, defender, weapon)
    local roll = math.random(1, 20)
    local hit = (roll + attacker.attack_bonus >= defender.armor_class)
    
    local damage = 0
    if hit then
        damage = calculate_damage(weapon)
        defender.hp = defender.hp - damage
    end
    
    -- AI Narration
    if AI_ENABLED then
        local narration = ai_storyteller.narrate_combat({
            event = hit and "hit" or "miss",
            attacker = attacker.name,
            defender = defender.name,
            weapon = weapon.name,
            damage = damage,
            critical = (roll == 20)
        })
        print(narration)
    else
        print(get_static_combat_text(hit, attacker.name, defender.name, damage))
    end
    
    return {hit = hit, damage = damage, defender_alive = (defender.hp > 0)}
end
```

**Combat Prompt Template:**
```
Narrate this combat action in one dramatic sentence:

{attacker} attacks {defender} with {weapon}
Result: {hit/miss/critical}
Damage: {damage}

Be vivid but concise. Match dark fantasy tone.
```

---

### Task 1.4: Configuration System (1-2 hours)

**File:** `src/ai_config.lua`

**Config Options:**
```lua
return {
    -- AI Mode
    enabled = false,  -- Toggle AI on/off
    
    -- Provider Settings
    provider = "ollama",  -- "ollama" or "openai"
    
    -- Ollama Config
    ollama = {
        endpoint = "http://localhost:11434/api/generate",
        model = "llama3.2",
        timeout = 10
    },
    
    -- OpenAI Config
    openai = {
        endpoint = "https://api.openai.com/v1/chat/completions",
        model = "gpt-3.5-turbo",
        api_key = os.getenv("OPENAI_API_KEY"),
        timeout = 5
    },
    
    -- Generation Settings
    max_tokens = 500,
    temperature = 0.7,
    
    -- Features
    narrate_chambers = true,
    narrate_combat = true,
    narrate_items = false,  -- Phase 2
    
    -- Performance
    cache_enabled = true,
    cache_size = 100,
    async_mode = false,  -- Future: async generation
    
    -- Fallbacks
    use_static_on_error = true,
    max_retries = 2
}
```

**Command Line Args:**
```bash
lua game_server.lua --ai-mode ollama
lua game_server.lua --ai-mode openai --ai-model gpt-4
lua game_server.lua --no-ai  # Classic mode
```

---

### Task 1.5: Testing (3-4 hours)

**File:** `tests/test_ai_storyteller.lua`

**Test Cases:**
```lua
-- Unit Tests
test_ollama_connection()
test_openai_connection()
test_prompt_building()
test_response_validation()
test_caching()
test_fallback_on_error()

-- Integration Tests
test_chamber_description_generation()
test_combat_narration()
test_context_building()
test_latency_requirements()

-- Mock Tests (no actual LLM calls)
test_with_mocked_responses()
test_error_handling()
```

**Performance Benchmarks:**
- Chamber description: <500ms (target), <1000ms (max)
- Combat narration: <300ms (target), <500ms (max)
- Cache hit rate: >50%

---

## 🛠️ Implementation Order

### Day 1: Foundation
1. ✅ Create feature branch
2. ✅ Create planning doc
3. ⏳ Implement `src/ai_storyteller.lua` core
4. ⏳ Add Ollama integration
5. ⏳ Test basic LLM connectivity

### Day 2: Integration
6. ⏳ Implement chamber description AI
7. ⏳ Add combat narration hooks
8. ⏳ Create configuration system
9. ⏳ Add caching layer

### Day 3: Testing & Polish
10. ⏳ Write comprehensive tests
11. ⏳ Performance optimization
12. ⏳ Add OpenAI support (optional)
13. ⏳ Documentation
14. ⏳ Merge to main

---

## 📦 Dependencies

### Required
- [x] LuaSocket (HTTP client) - already installed
- [x] dkjson (JSON parser) - already used
- [ ] Ollama installed locally (user setup)

### Optional
- [ ] OpenAI API key (for premium mode)

---

## 🧪 Testing Strategy

### Manual Testing
```bash
# 1. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2

# 2. Start server with AI
lua game_server.lua --ai-mode ollama

# 3. Play and verify
lua game_client.lua -i
> move north
# Should see AI-generated description

# 4. Test combat
> search
# If enemy found, should see AI combat narration
```

### Automated Testing
```bash
# Run all tests
lua tests/test_ai_storyteller.lua

# Run with mocked LLM (no network)
lua tests/test_ai_storyteller.lua --mock

# Performance benchmarks
lua tests/test_ai_storyteller.lua --benchmark
```

---

## 🎨 Example Outputs

### Chamber Description (Static vs AI)

**Static (current):**
```
You enter a throne room.
Exits: North, East
```

**AI-Enhanced:**
```
The throne room's grandeur has long since faded. Tattered banners bearing 
forgotten sigils hang from the vaulted ceiling, swaying in an unfelt breeze. 
The obsidian throne dominates the chamber, its surface carved with runes that 
pulse with a dull crimson light. Something glints in the shadows beneath it.

Exits: North through a collapsed archway, East into darkness
```

### Combat Narration (Static vs AI)

**Static:**
```
You attack the goblin with your sword. Hit! 7 damage.
```

**AI-Enhanced:**
```
Your blade carves through the air in a deadly arc, catching the goblin across 
its chest. It shrieks and staggers backward, dark blood spattering the stone floor.
[7 damage dealt]
```

---

## ⚠️ Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Ollama not installed | High | Clear error message, fallback to static |
| API latency too high | Medium | Caching, async mode (future), timeout limits |
| AI generates bad content | Medium | Response validation, profanity filter |
| Token costs (OpenAI) | Low | Default to Ollama, warn users about costs |
| Context too large | Low | Strict token budgets, context windowing |

---

## 📝 Documentation TODO

- [ ] Update `README.md` with AI setup instructions
- [ ] Create `docs/AI_SETUP.md` for detailed configuration
- [ ] Update `MOD_GUIDE.md` with AI customization options
- [ ] Add AI section to `CHANGELOG.md`

---

## ✅ Definition of Done

Phase 1 is complete when:
- [ ] AI storyteller module working with Ollama
- [ ] Chamber descriptions dynamically generated
- [ ] Combat narration functional
- [ ] All tests passing
- [ ] Performance targets met (<500ms chambers, <300ms combat)
- [ ] Fallback to static content working
- [ ] Configuration system implemented
- [ ] Documentation updated
- [ ] No regressions in existing tests
- [ ] Branch merged to main

---

## 🚀 Next Phase Preview

**Phase 2:** Dynamic NPCs
- NPC memory system
- Conversational AI dialogue
- Quest generation
- Personality profiles

---

**Ready to start Task 1.1!** 🎮
