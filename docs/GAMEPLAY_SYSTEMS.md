# Complete Gameplay Systems Reference
**Version:** 3.0  
**Status:** Fully Playable ✅  
**Balance:** 100% survival rate in testing

---

## 🎮 QUICK COMMAND REFERENCE

### Exploration
```bash
# Generate new 10-chamber dungeon
lua dungeon_generator.lua 10 my_quest.txt

# View ASCII map
lua dungeon_generator.lua map my_quest.txt

# Load dungeon
lua dungeon_generator.lua load my_quest.txt

# Move to chamber
lua dungeon_generator.lua move my_quest.txt 5
```

### Combat
```bash
# Fight enemy
lua combat.lua fight character_bimbo.md goblin 1

# After victory, gain XP
lua progression.lua add character_bimbo.md 75
```

### Character Management
```bash
# View inventory
lua inventory.lua show character_bimbo.md

# Use healing potion
lua inventory.lua use character_bimbo.md "healing potion"

# Check XP/level
lua progression.lua show character_bimbo.md
```

### Recovery
```bash
# Short rest (2d6 HP, 30% encounter risk)
lua rest.lua short

# Long rest (full HP, 60% encounter risk)
lua rest.lua long
```

### Encounters & Loot
```bash
# Generate encounter
lua encounter_gen.lua generate 3 1

# Generate loot
lua loot.lua generate 3 true

# Trigger trap
lua traps.lua trigger 1 3 2
```

### Testing
```bash
# Auto-play full dungeon
lua autoplay.lua

# Integrated playthrough test
lua test_integrated_playthrough.lua
```

---

## ⚔️ COMBAT BALANCE (REBALANCED)

### Player Stats (Level 1)
- **HP:** 30 (20 + CON×2)
- **AC:** 14 (10 + DEX + armor+4)
- **Attack:** +3 (proficiency)
- **Damage:** 1d6+2 (weapon + bonus)
- **Potions:** 3 × Healing (2d4+2 HP each)

### Enemy Stats (Level 1)

| Enemy | HP | AC | ATK | DMG | XP |
|-------|----|----|-----|-----|-----|
| Goblin | 7 | 11 | +2 | 1d6 | 75 |
| Cultist | 9 | 11 | +2 | 1d4 | 75 |
| Bandit | 11 | 11 | +2 | 1d6 | 100 |
| Skeleton | 13 | 11 | +2 | 1d6+1 | 75 |

**Win Rate:** ~100% (tested)

### Higher Level Enemies

| Enemy | HP | AC | ATK | DMG | XP |
|-------|----|----|-----|-----|-----|
| Orc | 15 | 12 | +3 | 1d8 | 125 |
| Zombie | 18 | 8 | +2 | 1d6 | 75 |
| Spider | 20 | 13 | +3 | 1d6+1 | 125 |
| Gargoyle | 45 | 14 | +4 | 1d8+2 | 200 |
| Ogre | 50 | 12 | +5 | 2d8+3 | 450 |
| Vampire | 70 | 15 | +7 | 1d8+3 | 2300 |
| Dragon | 120 | 17 | +8 | 2d10+5 | 5000 |

---

## 📊 CHAMBER TYPES & ENCOUNTERS

### Type Distribution (Weighted)
1. **Empty Room (12%)** - 30% encounter
2. **Treasure Room (10%)** - 60% encounter + loot
3. **Monster Lair (10%)** - 90% encounter
4. **Trap Room (8%)** - 20% encounter + traps
5. **Puzzle Room (10%)** - 40% encounter
6. **Prison Cells (8%)** - 50% encounter
7. **Armory (10%)** - 50% encounter
8. **Library (8%)** - 40% encounter
9. **Throne Room (12%)** - 70% encounter
10. **Boss Chamber (12%)** - 100% encounter

### Encounter Disposition
- **Hostile (40%):** Attack on sight
- **Neutral (40%):** Can negotiate/avoid
- **Friendly (20%):** Helpful, trading

---

## 🎲 PROGRESSION SYSTEM

### XP Requirements
- **Level 1→2:** 1000 XP (~13 goblins)
- **Level 2→3:** 2000 XP (~16 bandits)
- **Level N→N+1:** N × 1000 XP

### Level-Up Benefits
- +2 Skill Points
- +1d8+4 HP (avg +8 HP)
- Unlock abilities at milestones

### Milestones
- **Level 5:** Skill Specializations
- **Level 10:** Master Tier
- **Level 15:** Epic Abilities
- **Level 20:** Legendary Status

---

## 🔧 GAME MECHANICS

### Dice Rolls
- **Attack Roll:** d20 + attack_bonus vs AC
  - Natural 20 = Critical Hit (2× damage)
  - Natural 1 = Critical Miss (auto-fail)
- **Damage Roll:** Weapon dice + damage bonus
- **Saving Throws:** d20 + modifier vs DC

### Rest System
| Type | Time | Healing | Encounter Risk | Cost |
|------|------|---------|----------------|------|
| Short | 15min | 2d6 HP | 30% | None |
| Long | 8hrs | Full HP/MP | 60% | 1 ration |

### Trap Mechanics
1. **Detection:** d20 + WIS + Trap Detection vs DC
2. **Disarm:** d20 + DEX + Lockpicking vs DC+2
3. **Damage:** Varies by trap type (1d8 to 4d6)

---

## 📈 BALANCE TESTING RESULTS

### 50-Run Automated Test
```
Survival Rate: 100% (50/50 runs)
Avg Chambers: 10/10 (100%)
Avg Enemies: 5 defeated
Avg Gold: 129 gp
Avg HP Left: 27/30 (90%)
Potions Used: 0.04 per run
```

### Before vs After Rebalance
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Survival | 0% | 100% | +100% ✅ |
| Completion | 10-70% | 100% | +30-90% ✅ |
| Player Hit% | 31% | ~55% | +24% ✅ |
| Enemy Hit% | 75% | ~45% | -30% ✅ |

---

## 🎯 DIFFICULTY RATINGS

### Current Balance: **NORMAL**
- Fair for Level 1 characters
- 100% completion possible
- Tactical play rewarded
- Mistakes survivable

### Suggested Difficulty Variants

**EASY MODE:**
- Player AC +2 (16 total)
- Enemy damage -2
- Double potion drops
- **Expected survival:** 100%

**HARD MODE:**
- Enemy HP +50%
- Enemy ATK +1
- Fewer healing items
- **Expected survival:** 60-70%

**IRONMAN MODE:**
- Permadeath (no saves)
- Enemies +25% stronger
- 1 potion only
- **Expected survival:** 30-40%

---

## 🗺️ TYPICAL PLAYTHROUGH

### Chamber 1-3 (Early Game)
- Easy enemies (goblins, cultists)
- Learn mechanics
- Gather starting loot
- Usually no HP loss if careful

### Chamber 4-6 (Mid Game)
- Tougher enemies (bandits, skeletons)
- Start using potions
- First rest might be needed
- Traps appear

### Chamber 7-9 (Late Game)
- Multiple encounters possible
- Resource management critical
- Short rests between fights
- Treasure rooms valuable

### Chamber 10 (Boss Fight)
- Boss chamber encounter
- Use long rest before
- Save scrolls/potions
- Final reward

---

## 💡 PRO TIPS

### Combat
- Save healing potions for emergencies
- Use short rests when HP < 50%
- Long rest before boss chambers
- Attack bonuses matter more than damage

### Exploration
- Check ASCII map frequently
- Mark visited chambers mentally
- Treasure rooms worth the risk
- Dead ends might have loot

### Resource Management
- 3 potions usually enough for full dungeon
- Short rest > potion when safe
- Long rest only when critically low
- Save scrolls for tough fights

### Trap Rooms
- Always worth checking for traps
- Failed disarm < taking full damage
- WIS characters better at detection
- DEX characters better at disarming

---

## 📚 DOCUMENTATION FILES

- `INIT.md` - Quick start guide
- `NEW_FEATURES.md` - All 6 new systems explained
- `CHAMBERS.md` - Chamber type descriptions
- `ENCOUNTERS.md` - All enemy stats
- `ITEMS.md` - Equipment and loot tables
- `CHARACTER_SHEET.md` - Character creation rules
- `playtest_report.txt` - Detailed balance analysis
- `dungeon_gen_analysis.txt` - Generator improvements

---

**Game is now fully balanced, feature-complete, and thoroughly tested!** 🎉

Enjoy exploring the dungeons! 🗝️✨
