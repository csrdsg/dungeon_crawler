#!/bin/bash

echo "================================================"
echo "TESTING ALL REFACTORED SYSTEMS"
echo "================================================"

echo ""
echo "1. Testing Loot System..."
lua src/loot.lua generate 5 > /dev/null 2>&1 && echo "   ✅ Loot system works" || echo "   ❌ Loot system failed"

echo ""
echo "2. Testing Trap System..."
lua src/traps.lua trigger 3 5 3 > /dev/null 2>&1 && echo "   ✅ Trap system works" || echo "   ❌ Trap system failed"

echo ""
echo "3. Testing Encounter System..."
lua src/encounter_gen.lua generate 8 3 > /dev/null 2>&1 && echo "   ✅ Encounter system works" || echo "   ❌ Encounter system failed"

echo ""
echo "4. Testing Rest System..."
lua src/rest.lua short > /dev/null 2>&1 && echo "   ✅ Rest system works" || echo "   ❌ Rest system failed"

echo ""
echo "5. Testing Magic System..."
cd src && lua magic.lua list > /dev/null 2>&1 && echo "   ✅ Magic system works" || echo "   ❌ Magic system failed"
cd ..

echo ""
echo "6. Testing Quest System..."
lua -e "package.path = package.path .. ';./src/?.lua'; local q = require('src.initial_quests'); local quests = q.get_default_quests(); print('Quests loaded: ' .. (function() local c=0; for _ in pairs(quests) do c=c+1 end return c end)())" > /dev/null 2>&1 && echo "   ✅ Quest system works" || echo "   ❌ Quest system failed"

echo ""
echo "================================================"
echo "ALL TESTS COMPLETE"
echo "================================================"
