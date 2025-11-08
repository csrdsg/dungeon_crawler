# Dungeon Chamber Types

## Overview
Dungeons consist of various chamber types, each with unique characteristics and challenges. Chambers are numbered 1-10 and randomly assigned during dungeon generation.

---

## Chamber Type Reference

### Type 1: Empty Room
**Description:** A barren chamber with nothing of interest.
**Varieties:**
- Dusty abandoned hall
- Collapsed storage room
- Former guard post
- Crumbling chamber

### Type 2: Treasure Room
**Description:** Chambers containing valuable loot and riches.
**Varieties:**
- Ancient vault
- Hidden cache
- Dragon's hoard
- Merchant's stash

### Type 3: Monster Lair
**Description:** Home to dangerous creatures and beasts.
**Varieties:**
- Goblin nest
- Spider den
- Undead crypt
- Beast warren

### Type 4: Trap Room
**Description:** Chambers filled with deadly traps and mechanisms.
**Varieties:**
- Spike pit chamber
- Arrow trap corridor
- Poison gas room
- Crushing ceiling trap

### Type 5: Puzzle Room
**Description:** Requires solving riddles or puzzles to proceed.
**Varieties:**
- Ancient mechanism
- Symbol puzzle
- Magical lock
- Riddle chamber

### Type 6: Prison Cells
**Description:** Former or current holding cells for prisoners.
**Varieties:**
- Iron cage prison
- Torture chamber
- Dungeon cells
- Slave pens

### Type 7: Armory
**Description:** Storage for weapons, armor, and military equipment.
**Varieties:**
- Weapons cache
- Guard armory
- Ancient arsenal
- Forgotten stockpile

### Type 8: Library
**Description:** Repositories of knowledge, books, and scrolls.
**Varieties:**
- Ancient archive
- Wizard's study
- Scroll repository
- Forbidden library

### Type 9: Throne Room
**Description:** Grand chambers of power and authority.
**Varieties:**
- Royal hall
- Dark lord's court
- Ceremonial chamber
- War council room

### Type 10: Boss Chamber
**Description:** Large chamber housing the dungeon's most powerful enemy.
**Varieties:**
- Dragon's throne room
- Lich's sanctum
- Demon pit
- Ancient guardian chamber

---

## Generation Notes
- Chambers are connected in a forest structure (some isolated, some connected)
- Each chamber can connect to 0-3 other chambers
- Type is randomly assigned from 1-10
- Use `lua dungeon_generator.lua <number>` to generate dungeons
