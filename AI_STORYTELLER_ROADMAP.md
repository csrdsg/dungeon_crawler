# 🤖 AI Storyteller Roadmap

**Status:** Planning Phase  
**Created:** 2025-11-08  
**Goal:** Transform dungeon crawler into dynamic narrative experience with AI-driven storytelling

---

## 🎯 Vision

Replace static descriptions and canned responses with an AI agent that serves as a dynamic storyteller, creating personalized narrative experiences while maintaining reliable game mechanics.

## ✅ Current Architecture Advantages

- ✅ Event-driven server architecture (perfect for AI callbacks)
- ✅ Session management (track narrative context per player)
- ✅ Modular design (easy AI integration points)
- ✅ 10 distinct chamber types (ready for dynamic descriptions)
- ✅ Comprehensive test suite (ensure AI doesn't break mechanics)

## 🎮 Integration Strategy: Hybrid Mode

**Core Principle:** Deterministic mechanics + AI narrative layer

- **Game Engine:** Handles dice, combat, stats, inventory (unchanged)
- **AI Layer:** Provides descriptions, dialogue, quests, flavor text
- **Benefit:** Reliable gameplay with rich, dynamic storytelling

---

## 📋 TODO: Phase 1 - AI Narration Layer (2-3 days)

### TODO 1.1: Create AI Storyteller Module
- [ ] Create `src/ai_storyteller.lua`
- [ ] Implement LLM client (Ollama or OpenAI API)
- [ ] Add configuration for API endpoint/model selection
- [ ] Implement basic prompt templates
- [ ] Add error handling and fallbacks

### TODO 1.2: Dynamic Chamber Descriptions
- [ ] Replace static `chamber_art.lua` with AI-generated descriptions
- [ ] Create chamber context builder (type, exits, items, enemies)
- [ ] Implement description caching (avoid regenerating)
- [ ] Add player history to context (previous chambers visited)
- [ ] Fallback to static descriptions on API failure

### TODO 1.3: Combat Narration
- [ ] Create combat event hooks in `src/combat.lua`
- [ ] Generate dramatic attack descriptions
- [ ] Narrate hits, misses, critical hits, defeats
- [ ] Maintain combat pacing (concise vs verbose modes)
- [ ] Track combat history for coherent narrative

### TODO 1.4: Testing & Integration
- [ ] Create `tests/test_ai_storyteller.lua`
- [ ] Test API connectivity and error handling
- [ ] Mock LLM responses for automated testing
- [ ] Performance testing (latency targets: <500ms local, <200ms API)
- [ ] Integration with existing game server

### TODO 1.5: Configuration & Setup
- [ ] Add AI config to server startup
- [ ] Document API key setup (OpenAI) or Ollama installation
- [ ] Create toggle for AI mode vs classic mode
- [ ] Add verbose/concise narrative settings
- [ ] Update README with AI setup instructions

---

## 📋 TODO: Phase 2 - Dynamic NPCs (3-5 days)

### TODO 2.1: NPC Memory System
- [ ] Create `src/npc_memory.lua`
- [ ] Track conversations per session
- [ ] Store NPC personality profiles
- [ ] Remember player interactions and choices
- [ ] Implement context windowing (last N interactions)

### TODO 2.2: Conversational NPCs
- [ ] Replace canned NPC responses with AI dialogue
- [ ] Create NPC personality templates (merchant, guard, prisoner, etc.)
- [ ] Implement free-form player queries
- [ ] Add dialogue state machine (greeting, trading, quest, farewell)
- [ ] Maintain character consistency across conversations

### TODO 2.3: Dynamic Quest Generation
- [ ] Create quest context builder (player level, location, history)
- [ ] Generate quests based on chamber context
- [ ] Track quest progress and state
- [ ] Implement quest rewards (XP, items, story progression)
- [ ] Multiple quest types (fetch, kill, explore, solve)

### TODO 2.4: NPC Actions & Reactions
- [ ] NPCs react to player reputation/choices
- [ ] Shopkeeper pricing based on relationship
- [ ] Guards react to player behavior
- [ ] Prisoners share secrets if helped
- [ ] Dynamic faction system

### TODO 2.5: Testing
- [ ] Create `tests/test_npc_ai.lua`
- [ ] Test conversation coherence
- [ ] Test memory persistence across sessions
- [ ] Test quest generation variety
- [ ] Performance testing for dialogue generation

---

## 📋 TODO: Phase 3 - Adaptive Storytelling (1-2 weeks)

### TODO 3.1: Player Choice Tracking
- [ ] Create `src/narrative_engine.lua`
- [ ] Track all player decisions and actions
- [ ] Build player reputation system
- [ ] Record key story moments
- [ ] Implement consequence tracking

### TODO 3.2: Branching Narratives
- [ ] Create story arc templates
- [ ] Implement narrative branches based on choices
- [ ] Generate dungeon themes (haunted, ancient, corrupted, etc.)
- [ ] Persistent world changes from player actions
- [ ] Multiple endings based on playthrough

### TODO 3.3: Personalized Campaigns
- [ ] Analyze player style (combat, stealth, diplomacy)
- [ ] Adapt dungeon generation to preferences
- [ ] Custom loot based on play style
- [ ] Personalized challenges and encounters
- [ ] Remember player achievements across sessions

### TODO 3.4: Dynamic World Events
- [ ] Random events with narrative impact
- [ ] Time-based story progression
- [ ] Recurring NPCs and storylines
- [ ] Dungeon "living world" simulation
- [ ] Player actions affect future encounters

### TODO 3.5: Meta-Narrative Features
- [ ] Campaign mode (multi-session storylines)
- [ ] Character relationships and growth
- [ ] Unlockable lore and backstory
- [ ] Player legacy system (actions affect other players)
- [ ] Story summaries and highlights

### TODO 3.6: Testing & Polish
- [ ] Create `tests/test_narrative_engine.lua`
- [ ] Playtest full campaigns
- [ ] Balance narrative pacing
- [ ] Optimize context management (avoid token bloat)
- [ ] Performance optimization for long sessions

---

## 🔧 Technical Implementation Details

### AI Integration Points

```lua
-- src/ai_storyteller.lua (to be created)
local ai_storyteller = {
    -- Configuration
    provider = "ollama",  -- or "openai"
    model = "llama3.2",
    endpoint = "http://localhost:11434/api/generate",
    api_key = nil,  -- for OpenAI
    
    -- Core Functions
    narrate_chamber = function(chamber_type, player_history)
        -- Generate vivid room descriptions
    end,
    
    narrate_combat = function(action, attacker, defender, result)
        -- Dynamic combat narration
    end,
    
    generate_dialogue = function(npc_type, player_query, conversation_history)
        -- NPC conversations
    end,
    
    generate_quest = function(context)
        -- Context-aware quest generation
    end,
    
    -- Utility
    get_completion = function(prompt, max_tokens)
        -- LLM API wrapper
    end,
    
    build_context = function(session_data)
        -- Build context from session state
    end
}
```

### LLM Provider Options

**Option 1: Ollama (Local)**
- ✅ Free, private, no rate limits
- ✅ Models: llama3.2, mistral, phi
- ⚠️ ~500ms latency
- ⚠️ Requires local installation
- 💰 Cost: $0

**Option 2: OpenAI API**
- ✅ Fast (<100ms)
- ✅ High quality (GPT-4, GPT-3.5)
- ⚠️ Requires API key
- ⚠️ Rate limits
- 💰 Cost: ~$0.01-0.05 per game session

**Option 3: Anthropic Claude**
- ✅ Excellent at roleplay/narrative
- ✅ Large context window (200K tokens)
- ⚠️ Requires API key
- 💰 Cost: ~$0.02-0.08 per session

**Recommendation:** Start with Ollama for development, add OpenAI as optional premium feature

### Performance Targets

| Operation | Target Latency | Acceptable Max |
|-----------|---------------|----------------|
| Chamber description | <500ms | 1000ms |
| Combat narration | <300ms | 500ms |
| NPC dialogue | <800ms | 1500ms |
| Quest generation | <2000ms | 5000ms |

### Context Management

```lua
-- Keep context under control
context = {
    player_stats = {...},           -- 100 tokens
    current_chamber = {...},        -- 150 tokens
    recent_history = [...],         -- 300 tokens (last 5 actions)
    active_quests = [...],          -- 200 tokens
    npc_memory = {...},            -- 250 tokens (relevant NPCs)
    -- Total: ~1000 tokens input
    -- Output: ~200-500 tokens
    -- Total per request: ~1500 tokens
}
```

---

## 🚀 Quick Start (Once Implemented)

### With Ollama (Local, Free)
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Download model
ollama pull llama3.2

# Start server with AI
lua game_server.lua --ai-mode ollama

# Connect client
lua game_client.lua -i
```

### With OpenAI API
```bash
# Set API key
export OPENAI_API_KEY="sk-..."

# Start server with AI
lua game_server.lua --ai-mode openai --ai-model gpt-4

# Connect client
lua game_client.lua -i
```

---

## 📊 Integration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Game Client                             │
│                  (Interactive REPL)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ Commands (move, search, talk)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Game Server (game_server.lua)              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Session Manager (server_core.lua)             │ │
│  └────────────────────────────────────────────────────────┘ │
│              │                              │                │
│              ▼                              ▼                │
│  ┌─────────────────────┐      ┌──────────────────────────┐ │
│  │   Game Engine       │      │   AI Storyteller         │ │
│  │   (deterministic)   │◄────►│   (narrative layer)      │ │
│  │                     │      │                          │ │
│  │ • Dice rolls        │      │ • Chamber descriptions   │ │
│  │ • Combat math       │      │ • Combat narration       │ │
│  │ • Inventory         │      │ • NPC dialogue           │ │
│  │ • Stats tracking    │      │ • Quest generation       │ │
│  └─────────────────────┘      └──────────────┬───────────┘ │
│                                               │              │
└───────────────────────────────────────────────┼─────────────┘
                                                │
                                                ▼
                                   ┌────────────────────────┐
                                   │   LLM Provider         │
                                   │   (Ollama/OpenAI)      │
                                   └────────────────────────┘
```

---

## 🎨 Example: Before vs After

### Before (Static)
```
You enter the chamber.

  ╔════════════════════╗
  ║    THRONE ROOM     ║
  ║                    ║
  ║        👑         ║
  ║      ▓▓▓▓▓        ║
  ║                    ║
  ╚════════════════════╝

Exits: North, East
```

### After (AI-Enhanced)
```
You push open the massive oak doors and step into a magnificent throne room.
Tattered banners hang from the vaulted ceiling, their once-proud heraldry
faded to ghostly shadows. At the far end, a throne of black iron sits upon
a dais, its surface etched with runes that pulse with a faint crimson light.

The air is thick with the scent of ancient power and decay. Dust motes dance
in shafts of light from arrow-slit windows high above. Something glints
beneath the throne...

Exits lead north through a collapsed archway, and east into darkness.
```

---

## ⚠️ Risks & Mitigation

### Risk 1: AI Unpredictability
- **Mitigation:** Validate AI output, fallback to static content
- **Mitigation:** Use structured prompts with strict formats
- **Mitigation:** Implement content filters

### Risk 2: Latency
- **Mitigation:** Cache common descriptions
- **Mitigation:** Async generation (show "thinking..." indicator)
- **Mitigation:** Hybrid mode (AI for important moments only)

### Risk 3: Cost (if using API)
- **Mitigation:** Offer free Ollama mode
- **Mitigation:** Implement token budgets per session
- **Mitigation:** Cache and reuse appropriate content

### Risk 4: Context Drift
- **Mitigation:** Strict context windowing
- **Mitigation:** Periodic "memory compression" summaries
- **Mitigation:** Track essential facts separately

### Risk 5: Breaking Game Balance
- **Mitigation:** AI narrates, engine decides (dice, combat, loot)
- **Mitigation:** Comprehensive testing
- **Mitigation:** AI mode toggle for classic experience

---

## 📈 Success Metrics

### Phase 1
- [ ] 100% chamber descriptions generated successfully
- [ ] <500ms average latency for narration
- [ ] 0 game-breaking AI responses
- [ ] All existing tests still pass

### Phase 2
- [ ] NPCs respond coherently 95%+ of the time
- [ ] Quest completion rate >80%
- [ ] Player satisfaction with dialogue (survey)
- [ ] <1000ms average dialogue generation

### Phase 3
- [ ] Player choice tracking 100% accurate
- [ ] Narrative branching functions correctly
- [ ] Session memory persists across reconnects
- [ ] Campaign completion rate >60%

---

## 🔄 Maintenance Plan

### Weekly
- [ ] Monitor API costs (if using paid LLM)
- [ ] Review AI output quality
- [ ] Check error logs for AI failures
- [ ] Update prompt templates based on feedback

### Monthly
- [ ] Retrain/fine-tune prompts
- [ ] Update NPC personalities
- [ ] Add new quest templates
- [ ] Performance optimization

### Quarterly
- [ ] Evaluate new LLM models
- [ ] User feedback survey
- [ ] Content expansion (new NPCs, locations)
- [ ] Major feature additions

---

## 📚 Resources & References

### Documentation to Create
- [ ] `docs/AI_INTEGRATION.md` - Technical integration guide
- [ ] `docs/PROMPT_ENGINEERING.md` - Prompt templates and best practices
- [ ] `docs/AI_TROUBLESHOOTING.md` - Common issues and solutions

### External Resources
- Ollama: https://ollama.com
- OpenAI API: https://platform.openai.com/docs
- Anthropic Claude: https://www.anthropic.com/claude
- LangChain (optional framework): https://www.langchain.com

---

## 🎯 Next Steps

1. **Immediate:** Review and approve roadmap
2. **Week 1:** Implement Phase 1 (AI Narration Layer)
3. **Week 2:** Test and iterate on descriptions
4. **Week 3-4:** Phase 2 (Dynamic NPCs)
5. **Month 2:** Phase 3 (Adaptive Storytelling)

---

## 💬 Notes

- Keep game mechanics deterministic (dice, combat, loot)
- AI enhances narrative, doesn't replace core gameplay
- Always provide classic mode fallback
- Focus on player experience over technical complexity
- Iterate based on playtesting feedback

---

**Status:** Ready for Phase 1 implementation  
**Owner:** To be assigned  
**Priority:** High (transforms core gameplay experience)
