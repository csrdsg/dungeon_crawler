# 🤖 Ollama Usage Guide

You have **Ollama** installed with the **llama3.2:3b** model. Here's how to use it for various tasks beyond the dungeon crawler game.

## 🚀 Quick Start

### 1. Interactive Chat Mode
```bash
ollama run llama3.2:3b
```
Then just type your questions and press Enter. Type `/bye` to exit.

### 2. One-Off Commands
```bash
ollama run llama3.2:3b "Your question here"
```

---

## 💡 Common Use Cases

### Code Assistance
```bash
# Explain code
ollama run llama3.2:3b "Explain this Python: [x**2 for x in range(10)]"

# Generate code
ollama run llama3.2:3b "Write a Bash script to backup a directory"

# Debug help
ollama run llama3.2:3b "Why does this give IndexError: list[10]"

# Code review
ollama run llama3.2:3b "Review this code for bugs: $(cat myfile.py)"
```

### Writing & Editing
```bash
# Summarize
ollama run llama3.2:3b "Summarize: $(cat long_document.txt)"

# Translate
ollama run llama3.2:3b "Translate to French: Hello, how are you?"

# Improve writing
ollama run llama3.2:3b "Make this more professional: yo whats up"

# Generate content
ollama run llama3.2:3b "Write a README for a REST API project"
```

### Learning & Research
```bash
# Explanations
ollama run llama3.2:3b "Explain REST APIs like I'm 5"

# Comparisons
ollama run llama3.2:3b "Compare TCP vs UDP protocols"

# Step-by-step guides
ollama run llama3.2:3b "How do I set up SSH keys?"
```

### Data Processing
```bash
# Parse/extract
ollama run llama3.2:3b "Extract email addresses from: $(cat contacts.txt)"

# Transform
ollama run llama3.2:3b "Convert this CSV to JSON format: name,age\nJohn,30"

# Analyze
ollama run llama3.2:3b "What patterns do you see in: $(cat logfile.log | tail -n 20)"
```

---

## 🔧 Using the HTTP API

Ollama runs a local server at `http://localhost:11434`. You can use it with any programming language.

### cURL Examples

**Simple generation:**
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Why is the sky blue?",
  "stream": false
}' | python3 -c "import sys, json; print(json.load(sys.stdin)['response'])"
```

**Chat with context:**
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2:3b",
  "messages": [
    {"role": "system", "content": "You are a helpful coding assistant"},
    {"role": "user", "content": "How do I read a file in Python?"}
  ],
  "stream": false
}' | python3 -c "import sys, json; print(json.load(sys.stdin)['message']['content'])"
```

**Streaming responses:**
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Write a story about a robot",
  "stream": true
}'
```

### Python Script

Create a simple wrapper:

```python
#!/usr/bin/env python3
import requests
import json

def ask(prompt, system_prompt=None):
    if system_prompt:
        # Chat mode with system message
        response = requests.post('http://localhost:11434/api/chat', json={
            'model': 'llama3.2:3b',
            'messages': [
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': prompt}
            ],
            'stream': False
        })
        return response.json()['message']['content']
    else:
        # Simple generation
        response = requests.post('http://localhost:11434/api/generate', json={
            'model': 'llama3.2:3b',
            'prompt': prompt,
            'stream': False
        })
        return response.json()['response']

# Usage
print(ask("What is 25 * 34?"))
print(ask("Review this code for bugs", system_prompt="You are a senior code reviewer"))
```

### Lua (for game integration)

See `src/ai_storyteller.lua` for a complete example, or use this minimal version:

```lua
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

function ask_ollama(prompt)
    local request_body = json.encode({
        model = "llama3.2:3b",
        prompt = prompt,
        stream = false
    })
    
    local response_body = {}
    local res, code = http.request{
        url = "http://localhost:11434/api/generate",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#request_body)
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    }
    
    if code == 200 then
        local response = json.decode(table.concat(response_body))
        return response.response
    end
    return nil
end

print(ask_ollama("Generate a random monster name"))
```

---

## 📚 Available Models

You currently have: **llama3.2:3b** (3 billion parameters)

### Download more models:
```bash
# Larger, more capable (needs more RAM/time)
ollama pull llama3.2       # 8B parameters
ollama pull llama3.2:70b   # 70B parameters (needs ~40GB RAM!)

# Specialized models
ollama pull codellama       # Better for code
ollama pull mistral         # Fast and efficient
ollama pull phi3            # Small and fast (3.8B)

# List all available models
ollama list

# Remove a model
ollama rm modelname
```

---

## ⚙️ Advanced Options

### Temperature (creativity vs consistency)
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Write a creative story",
  "options": {
    "temperature": 0.9
  },
  "stream": false
}'
```

- **0.0-0.3**: Deterministic, factual (good for code, facts)
- **0.5-0.7**: Balanced (default)
- **0.8-1.0**: Creative, varied (good for stories, ideas)

### Token Limits
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Explain machine learning",
  "options": {
    "num_predict": 100
  },
  "stream": false
}'
```

### Context Window
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Continue this story...",
  "options": {
    "num_ctx": 4096
  },
  "stream": false
}'
```

---

## 🛠️ Shell Integration

### Add to your `.bashrc` or `.zshrc`:

```bash
# Quick AI assistant
ai() {
    ollama run llama3.2:3b "$*"
}

# Explain shell commands
explain() {
    ollama run llama3.2:3b "Explain this shell command: $*"
}

# Git commit message generator
gitai() {
    local diff=$(git diff --staged)
    ollama run llama3.2:3b "Write a concise git commit message for: $diff"
}
```

Usage:
```bash
ai "what is docker?"
explain "grep -r 'pattern' ."
gitai
```

---

## 🔍 Prompt Engineering Tips

### Be Specific
❌ "Write code"  
✅ "Write a Python function that takes a list and returns unique elements"

### Provide Context
❌ "Fix this bug"  
✅ "Fix this Python IndexError in a function that processes user data: [code]"

### Use System Prompts (via API)
```json
{
  "role": "system",
  "content": "You are an expert in Lua programming. Be concise and provide code examples."
}
```

### Format Constraints
"Explain in 3 bullet points"  
"Answer in one sentence"  
"Respond as JSON"  
"Write exactly 100 words"

---

## 📊 Performance & Resources

**llama3.2:3b stats:**
- Size: ~2GB
- RAM usage: ~4-6GB
- Speed: ~30-40 tokens/second (M-series Mac)
- Context: 128K tokens

**Tips for better performance:**
- Keep the model loaded (faster subsequent requests)
- Use streaming for long responses
- Cache common prompts
- Consider smaller models (phi3) for speed
- Use larger models (llama3.2) for quality

---

## 🎮 Integration Examples

### Automated Git Workflow
```bash
#!/bin/bash
# git-smart-commit.sh

git add -A
diff=$(git diff --staged)
msg=$(ollama run llama3.2:3b "Write a concise git commit message: $diff" | head -1)
git commit -m "$msg"
```

### Code Documentation Generator
```bash
#!/bin/bash
# document.sh <file>

code=$(cat "$1")
ollama run llama3.2:3b "Generate JSDoc comments for: $code"
```

### Interactive Tutor
```bash
#!/bin/bash
# tutor.sh <topic>

echo "AI Tutor: $1"
echo "Ask questions (type 'quit' to exit):"
while true; do
    read -p "> " question
    [[ "$question" == "quit" ]] && break
    ollama run llama3.2:3b "Explain about $1: $question"
done
```

---

## 🆘 Troubleshooting

**Ollama not responding?**
```bash
brew services restart ollama
```

**Check if running:**
```bash
curl http://localhost:11434
# Should return: "Ollama is running"
```

**Model not found:**
```bash
ollama list  # See available models
ollama pull llama3.2:3b  # Download again
```

**Slow responses:**
- Close other memory-intensive apps
- Use smaller model (phi3)
- Reduce context window
- Lower temperature

---

## 📖 Resources

- **Ollama Docs**: https://ollama.com/docs
- **Model Library**: https://ollama.com/library
- **API Reference**: https://github.com/ollama/ollama/blob/main/docs/api.md
- **Your game integration**: `src/ai_storyteller.lua`

---

## 🚀 Next Steps

1. Try the interactive chat: `ollama run llama3.2:3b`
2. Create shell aliases for common tasks
3. Build your own AI-powered tools
4. Explore other models for specialized tasks
5. Share your AI-enhanced dungeon crawler game!

**The model is yours to use however you want - it runs 100% locally and is completely free!**
