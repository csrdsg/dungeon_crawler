# New Game Features - Complete Guide
**Date:** 2025-11-08
**Version:** 3.0

---

## 🎒 INVENTORY SYSTEM (inventory.lua)

### Commands
```bash
# View inventory
lua inventory.lua show character_bimbo.md

# Use consumable item
lua inventory.lua use character_bimbo.md "healing potion"

# Add item to inventory
lua inventory.lua add character_bimbo.md "Magic Sword +1" 3.0

# Drop item
lua inventory.lua drop character_bimbo.md rope
```

### Features
- ✓ Display all weapons, armor, and items
- ✓ Shows gold and weight capacity
- ✓ Use potions to heal (2d4+2 HP)
- ✓ Use scrolls for combat effects
- ✓ Eat rations
- ✓ Auto-decrements item counts
- ✓ Weight management (prevents over-encumbrance)

### Supported Items
- **Healing Potions:** Restore 2d4+2 HP, consumed on use
- **Scrolls:** One-time magical effects
- **Rations:** Food for resting
- **Equipment:** Quest items, cannot be used

---

## ⭐ XP/LEVELING SYSTEM (progression.lua)

### Commands
```bash
# Show character progression
lua progression.lua show character_bimbo.md

# Add XP (e.g., after defeating enemy)
lua progression.lua add character_bimbo.md 150

# Force level up to next level
lua progression.lua levelup character_bimbo.md
```

### Features
- ✓ Track XP with visual progress bar
- ✓ Automatic level-up when threshold reached
- ✓ Gain 2 skill points per level
- ✓ Max HP increases by 1d8+4 per level
- ✓ Milestone rewards at levels 5, 10, 15, 20
- ✓ Level scaling: Level N requires N × 1000 XP

### XP Values (from combat.lua)
- Goblin: 75 XP
- Bandit: 100 XP
- Orc: 125 XP
- Spider: 125 XP
- Gargoyle: 200 XP
- Ogre: 450 XP
- Vampire: 2300 XP
- Dragon: 5000 XP

### Milestones
- **Level 5:** Skill Specializations unlocked
- **Level 10:** Master Tier Skills
- **Level 15:** Epic Abilities
- **Level 20:** Legendary Status

---

## 🏕️ REST SYSTEM (rest.lua)

### Commands
```bash
# Short rest (15 minutes)
lua rest.lua short

# Long rest (8 hours)
lua rest.lua long
```

### Features
- **Short Rest:**
  - Heals 2d6 HP
  - Takes 15 minutes
  - 30% chance of encounter interruption
  - Good for quick healing between fights

- **Long Rest:**
  - Fully restores HP and MP
  - Takes 8 hours
  - 60% chance of night encounter
  - Consumes 1 day of rations
  - Best for full recovery

### Usage Tips
- Use short rests between chambers
- Save long rests for when critically injured
- Have rations before long rest
- Be prepared for encounters during rest

---

## 🪤 TRAP SYSTEM (traps.lua)

### Commands
```bash
# Trigger random trap
lua traps.lua trigger

# Trigger specific trap with bonuses
lua traps.lua trigger 1 3 2
# Args: trap_id detect_bonus disarm_bonus
```

### Trap Types
1. **Poison Dart Trap** - 2d6 dmg, DC 12 (DEX)
2. **Pit Trap** - 3d6 dmg, DC 13 (DEX)
3. **Arrow Trap** - 1d8+2 dmg, DC 11 (DEX)
4. **Flame Jet** - 2d8 dmg, DC 14 (DEX)
5. **Crushing Wall** - 4d6 dmg, DC 15 (STR)
6. **Magic Rune** - 3d8 dmg, DC 16 (INT)

### Mechanics
1. **Detection Phase:**
   - Roll: 1d20 + detect_bonus vs DC
   - Success = trap spotted, can attempt disarm
   - Failure = trap triggers automatically

2. **Disarm Phase:**
   - Only if detected
   - Roll: 1d20 + disarm_bonus vs (DC + 2)
   - Success = trap disabled, no damage
   - Failure = trap triggers

3. **Trigger:**
   - Takes damage based on trap type
   - Can be lethal at low levels

### Bonuses
- **Detection:** WIS modifier + Trap Detection rank
- **Disarm:** DEX modifier + Lockpicking rank

---

## 💫 STATUS EFFECTS (effects.lua)

### Commands
```bash
# Apply status effect
lua effects.lua poison player
lua effects.lua strength goblin
```

### Available Effects
- **poison** - 1d4 damage/turn for 3 turns
- **bleeding** - 1d6 damage/turn for 2 turns
- **stunned** - Cannot act next turn
- **strength** - +2 to attack rolls for 3 turns

### Usage
- Effects are applied during combat
- Track duration (decrements each turn)
- Some effects stackable, some replace
- Cleansed by certain items/spells

---

## 🎯 AUTO-PLAY MODE (autoplay.lua)

### Command
```bash
lua autoplay.lua
```

### Features
- Simulates full 10-chamber dungeon run
- Automated combat decisions
- Random encounters and loot
- Auto-resting when low HP
- Final statistics report

### Output
- Chambers explored
- Enemies defeated
- Treasure found
- Damage taken
- Final HP and survival status

### Use Cases
- Test game balance
- Simulate outcomes
- Benchmark character builds
- Fun to watch!

---

## 🎮 INTEGRATED GAMEPLAY EXAMPLE

### Complete Chamber Exploration
```bash
# 1. Move to new chamber
lua dungeon_generator.lua move bimbo_quest.txt 7

# 2. Generate encounter
lua encounter_gen.lua generate 7 2

# 3. Check for traps (Armory = trap room)
lua traps.lua trigger 2 3 2

# 4. If hostile encounter, fight
lua combat.lua fight character_bimbo.md orc 2

# 5. Gain XP from victory
lua progression.lua add character_bimbo.md 125

# 6. Generate loot
lua loot.lua generate 7 true

# 7. If injured, use potion
lua inventory.lua use character_bimbo.md "healing potion"

# 8. Check progression
lua progression.lua show character_bimbo.md

# 9. Rest if needed
lua rest.lua short

# 10. View dungeon map
lua dungeon_generator.lua map bimbo_quest.txt
```

### Quick Combat Loop
```bash
# Fight, gain XP, loot, heal
lua combat.lua fight character_bimbo.md goblin 1
lua progression.lua add character_bimbo.md 75
lua loot.lua generate 3 true
lua inventory.lua use character_bimbo.md "healing potion"
```

---

## 📊 SYSTEM COMPATIBILITY MATRIX

| Feature | Works With | Notes |
|---------|-----------|-------|
| Inventory | Character files | Reads .md format |
| XP/Leveling | Character files | Tracks level/XP |
| Rest | Standalone | Can integrate with character HP |
| Traps | Standalone | Use bonuses from character |
| Effects | Combat system | Applied during fights |
| Auto-Play | All systems | Simulates full run |

---

## 🔧 INTEGRATION TIPS

### Character File Updates
Most systems READ from character files but don't WRITE back. You'll need to manually update:
- HP after combat/rest
- XP after fights
- Items after inventory changes
- Level after level-ups

### Recommended Workflow
1. Use systems to calculate results
2. Note changes (XP gained, HP lost, items used)
3. Manually update character .md file
4. Save game state

### Future Enhancement
Consider creating a master `game_manager.lua` that:
- Coordinates all systems
- Auto-updates character file
- Manages game state
- Provides unified CLI

---

## 📈 BALANCE NOTES

### XP Progression
- Level 1→2: ~7-13 goblin fights
- Level 2→3: ~8-15 bandit fights
- Level 5: ~20-30 total fights
- Level 10: ~50-80 total fights

### Rest vs Potions
- **Potion:** Instant, reliable, limited supply
- **Short Rest:** Quick, moderate heal, encounter risk
- **Long Rest:** Full heal, long time, higher encounter risk

### Trap Difficulty
- Early game (DC 11-13): 60-70% success with +3 bonus
- Mid game (DC 14-15): 50-60% success
- Late game (DC 16+): 40-50% success, need +5 bonus

---

## 🎯 QUICK REFERENCE

```bash
# Character Management
lua inventory.lua show character_bimbo.md
lua progression.lua show character_bimbo.md

# Combat Flow
lua combat.lua fight character_bimbo.md <enemy> <level>
lua progression.lua add character_bimbo.md <xp>
lua loot.lua generate <chamber_type> true

# Recovery
lua inventory.lua use character_bimbo.md "healing potion"
lua rest.lua short
lua rest.lua long

# Exploration
lua dungeon_generator.lua map bimbo_quest.txt
lua encounter_gen.lua generate <chamber_type> <level>
lua traps.lua trigger [trap_id] [detect] [disarm]

# Simulation
lua autoplay.lua
```

---

**All systems fully functional and tested!**
**Compatible with existing dungeon crawler infrastructure.**
**No external dependencies - pure Lua 5.x**

