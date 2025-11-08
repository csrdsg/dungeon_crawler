# 🎲 Dungeon Crawler v0.1.0-alpha

**First Alpha Release** - 2025-11-08

A Lua-based tabletop RPG system with procedural dungeon generation, turn-based combat, magic, and persistent character progression.

---

## ⚠️ Alpha Status

This is an **alpha release**. The game is feature-complete and playable, but:
- Balance is still being tested
- Some edge cases may not be handled
- Documentation is comprehensive but may have gaps
- API may change in future releases

We welcome feedback, bug reports, and suggestions!

---

## 🎮 What's Included

### Core Features
✅ **Procedural Dungeon Generation** - Forest-graph structure, 10 chamber types  
✅ **Turn-Based Combat** - d20 attack rolls, damage calculation, critical hits  
✅ **Magic System** - 12 spells with MP management  
✅ **Item Effects** - 22 balanced effects (active, passive, cursed)  
✅ **Character Progression** - XP, leveling, skill trees  
✅ **Inventory Management** - Weight, encumbrance, item usage  
✅ **Rest System** - Short/long rests, resource recovery  
✅ **Save/Load** - Persistent dungeons and characters  

### Game Balance
- **64% Survival Rate** (tested with 100 automated playthroughs)
- **80% Average Progress** (8/10 chambers completed)
- All character builds viable
- Item effects balanced for fair gameplay

### Testing
- **100% Item Effects Tests** (22/22 passing)
- **91% Integration Tests** (10/11 passing)
- Automated balance testing included
- 200+ playthroughs simulated

---

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dungeon_crawler.git
cd dungeon_crawler

# Requires Lua 5.x (no external dependencies)
lua -v
```

### Play the Game
```bash
# Start new adventure
lua play.lua

# Continue saved game
lua continue_game.lua
```

### Run Tests
```bash
cd tests
./run_tests.sh
```

---

## 📖 Documentation

All documentation is in the `docs/` folder:

- **[README.md](README.md)** - Complete project overview
- **[docs/INIT.md](docs/INIT.md)** - Quick reference guide
- **[docs/GAMEPLAY_SYSTEMS.md](docs/GAMEPLAY_SYSTEMS.md)** - Combat, loot, encounters
- **[docs/ITEMS.md](docs/ITEMS.md)** - Item effects system
- **[docs/MAGIC_ABILITIES.md](docs/MAGIC_ABILITIES.md)** - All spells
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 🎯 Alpha Release Highlights

### Balance v2.0
All 22 item effects have been carefully balanced:

**Active Effects:**
- Normalized to 4.5-9 damage/healing per use
- Multiple uses per rest for tactical decisions
- Examples: Flaming Blade (+1d8 fire × 3), Emergency Heal (2d8+2 × 2)

**Passive Effects:**
- Moderate bonuses (+2 AC, +8 HP/MP)
- No overpowered "must-have" items
- Examples: Life Drain (20% lifesteal), Vorpal Edge (crit 19-20, 3× damage)

**Cursed Items:**
- Penalties reduced 50% from initial values
- Now viable risk/reward choices
- Examples: Greed's Curse (+2d6 damage, -1 HP/hit)

### Code Organization
- Clean folder structure (src/, tests/, docs/, analysis/, reports/)
- Comprehensive test suite
- Example character and dungeon included
- Database tracking for balance analysis

---

## 🐛 Known Issues

1. **Integration Test:** One integration test fails intermittently (10/11 passing)
2. **Stats Database:** May grow large after many automated tests
3. **Character Files:** Manual editing required for some actions
4. **Balance:** Still gathering player feedback for fine-tuning

---

## 🤝 Contributing

This is an alpha release. We welcome:
- 🐛 Bug reports
- 💡 Feature suggestions
- 📝 Documentation improvements
- 🎮 Balance feedback from actual play

**How to Contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📊 Game Statistics

### Combat Balance (v2.0)
```
Player Stats:
- AC: 14 (leather armor)
- Attack: +3 (proficiency)
- Damage: 1d6+2
- HP: 30-55 (class dependent)

Enemy Stats (Level 1):
- AC: 12
- Attack: +3
- HP: 8-14
- Damage: 1d4+2 to 1d6+2
```

### Survival Rates (100 test runs)
```
Overall:        64%
With Magic:     82%
Pure Fighter:   90%
Rogue:          46%
```

### Item Balance
```
Active:    7 effects (4.5-9 value/use)
Passive:   10 effects (moderate bonuses)
Cursed:    5 effects (3/5 viable)
```

---

## 🛠️ Technical Details

**Requirements:**
- Lua 5.x
- No external dependencies
- ~1 MB disk space

**Project Structure:**
```
dungeon_crawler/
├── src/          # Core game engine (14 files)
├── tests/        # Test suite (12 files)
├── docs/         # Documentation (14 files)
├── analysis/     # Balance tools (3 files)
├── reports/      # Generated reports (5 files)
├── play.lua      # Main game launcher
└── README.md     # Project guide
```

**Performance:**
- 28 million dice rolls/second
- Instant dungeon generation (< 0.1s for 20 chambers)
- Minimal memory footprint

---

## 📜 License

Free to use, modify, and distribute for personal and educational purposes.

See repository for full license details.

---

## 🎲 What's Next?

### Planned for Beta (v0.2.0)
- [ ] Full GUI/TUI interface
- [ ] More character classes
- [ ] Additional magic schools
- [ ] Monster AI improvements
- [ ] Quest system
- [ ] Multiplayer support

### Planned for v1.0
- [ ] Complete campaign mode
- [ ] Achievement system
- [ ] Difficulty levels
- [ ] Random event system
- [ ] Full audio support
- [ ] Mobile compatibility

---

## 🙏 Credits

Created with ❤️ using pure Lua

Special thanks to:
- The Lua community
- Tabletop RPG enthusiasts
- Early alpha testers

---

## 📞 Contact & Support

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions
- **Email:** [Your Email]

---

**Download and start your adventure today!**

May your dice rolls be high and your HP stay above zero! ⚔️🛡️✨

---

*Dungeon Crawler v0.1.0-alpha - Released 2025-11-08*
