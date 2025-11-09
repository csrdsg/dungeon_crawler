-- Dialogue Content - Conversation options for NPCs and scenarios
-- This file contains the actual dialogue trees and conversation data

local DialogueContent = {}

-- =============================================================================
-- MERCHANT DIALOGUES
-- =============================================================================

DialogueContent.merchant_greeting = {
    speaker = "Merchant",
    text = "Greetings, traveler! Looking to buy or sell?",
    options = {
        {
            text = "Show me your wares",
            result = {
                response = "Of course! Take a look at what I have in stock."
            },
            next = {
                speaker = "Merchant",
                text = "I have potions, weapons, and rare artifacts.",
                options = {
                    {
                        text = "I'll take a healing potion (50 gold)",
                        condition = { min_gold = 50 },
                        result = {
                            response = "Excellent choice! This will heal your wounds in battle.",
                            gold_change = -50,
                            add_item = { id = "healing_potion", name = "Healing Potion", type = "consumable", heal = 50 }
                        }
                    },
                    {
                        text = "I'll take a healing potion (50 gold)",
                        condition = { min_gold = 0 },  -- Show if not enough gold
                        hint = "Not enough gold",
                        result = {
                            response = "Come back when you have enough gold, friend."
                        }
                    },
                    {
                        text = "Never mind",
                        result = {
                            response = "Come back anytime!"
                        }
                    }
                }
            }
        },
        {
            text = "Tell me about this place",
            result = {
                response = "This dungeon has claimed many adventurers. Be careful, and may fortune favor you."
            }
        },
        {
            text = "Goodbye",
            result = {
                response = "Safe travels, adventurer!"
            }
        }
    }
}

-- =============================================================================
-- QUEST GIVER DIALOGUES
-- =============================================================================

DialogueContent.quest_giver_initial = {
    speaker = "Village Elder",
    text = "Ah, a brave soul! We desperately need your help.",
    options = {
        {
            text = "What's wrong?",
            condition = { not_flag = "heard_elder_problem" },
            result = {
                response = "Goblins have been raiding our village. Their leader holds a sacred artifact we need to recover.",
                set_flag = "heard_elder_problem"
            },
            next = {
                speaker = "Village Elder",
                text = "Will you help us retrieve the Sacred Amulet from the goblin king?",
                options = {
                    {
                        text = "I'll do it",
                        result = {
                            response = "Bless you, hero! The goblins' lair is deep in the eastern caves. Be careful!",
                            start_quest = "retrieve_amulet"
                        }
                    },
                    {
                        text = "What's in it for me?",
                        result = {
                            response = "We can offer 500 gold and my family's enchanted sword."
                        },
                        next = {
                            speaker = "Village Elder",
                            text = "Will you help us?",
                            options = {
                                {
                                    text = "Alright, I'll help",
                                    result = {
                                        response = "Thank you! The village won't forget this.",
                                        start_quest = "retrieve_amulet"
                                    }
                                },
                                {
                                    text = "Not interested",
                                    result = {
                                        response = "I understand... perhaps another time."
                                    }
                                }
                            }
                        }
                    },
                    {
                        text = "Not right now",
                        result = {
                            response = "I understand. Come speak to me when you're ready."
                        }
                    }
                }
            }
        },
        {
            text = "I've completed your quest",
            condition = { 
                quest_active = "retrieve_amulet",
                has_item = "sacred_amulet"
            },
            result = {
                response = "You've done it! You've saved our village! Here is your reward.",
                complete_quest = "retrieve_amulet",
                remove_item = "sacred_amulet",
                gold_change = 500,
                add_item = { id = "elders_blade", name = "Elder's Blade", type = "weapon", damage = 15 },
                reputation_change = { village = 50 }
            }
        },
        {
            text = "Goodbye",
            result = {
                response = "May the gods watch over you."
            }
        }
    }
}

-- =============================================================================
-- MYSTERIOUS STRANGER DIALOGUES
-- =============================================================================

DialogueContent.mysterious_stranger = {
    speaker = "Hooded Figure",
    text = "Psst... you look like someone who appreciates valuable information.",
    options = {
        {
            text = "What kind of information?",
            result = {
                response = "For a price, I can reveal the location of a hidden treasure room in this very dungeon."
            },
            next = {
                speaker = "Hooded Figure",
                text = "Only 100 gold for this exclusive knowledge.",
                options = {
                    {
                        text = "Here's the gold",
                        condition = { min_gold = 100 },
                        result = {
                            response = "Smart choice. Head north from the next fork, then take the third left. Look for a crack in the eastern wall.",
                            gold_change = -100,
                            set_flag = "knows_secret_room"
                        }
                    },
                    {
                        text = "I don't trust you",
                        result = {
                            response = "Your loss, friend. The treasure will be there if you change your mind."
                        }
                    },
                    {
                        text = "Not interested",
                        result = {
                            response = "Suit yourself."
                        }
                    }
                }
            }
        },
        {
            text = "[Intimidate] Tell me for free",
            condition = { min_charisma = 15 },
            hint = "Charisma check",
            result = {
                response = "Alright, alright! No need for threats... The secret room is north from the next fork, third left, crack in the eastern wall.",
                set_flag = "knows_secret_room",
                set_flag = "intimidated_stranger"
            }
        },
        {
            text = "Leave me alone",
            result = {
                response = "*The figure melts back into the shadows*"
            }
        }
    }
}

-- =============================================================================
-- PRISONER DIALOGUES
-- =============================================================================

DialogueContent.imprisoned_knight = {
    speaker = "Imprisoned Knight",
    text = "Please... you must help me! I've been trapped here for days!",
    options = {
        {
            text = "How did you get here?",
            result = {
                response = "I was captured by bandits while escorting a merchant caravan. They took everything, even my sword!"
            },
            next = {
                speaker = "Imprisoned Knight",
                text = "If you free me, I'll join you in your quest. I can fight!",
                options = {
                    {
                        text = "I'll get you out of there",
                        condition = { has_item = "iron_key" },
                        result = {
                            response = "Thank you! I owe you my life. Let me fight by your side!",
                            remove_item = "iron_key",
                            set_flag = "knight_companion",
                            reputation_change = { knights_order = 25 }
                        }
                    },
                    {
                        text = "I don't have a key",
                        result = {
                            response = "The bandits must have it. Please, find it and come back!"
                        }
                    },
                    {
                        text = "You're on your own",
                        result = {
                            response = "How could you leave me here to die?!",
                            reputation_change = { knights_order = -10 }
                        }
                    }
                }
            }
        },
        {
            text = "Too bad for you",
            result = {
                response = "*The knight's face falls with despair*",
                reputation_change = { knights_order = -15 }
            }
        }
    }
}

-- =============================================================================
-- DUNGEON BOSS DIALOGUES
-- =============================================================================

DialogueContent.goblin_king = {
    speaker = "Goblin King",
    text = "You dare enter my throne room, human? You'll make a fine trophy!",
    options = {
        {
            text = "Give me the Sacred Amulet!",
            condition = { quest_active = "retrieve_amulet" },
            result = {
                response = "HAH! Come and take it from my cold, dead hands!"
            }
        },
        {
            text = "[Intelligence] The dragon wants his gold back",
            condition = { min_intelligence = 18 },
            hint = "Intelligence check",
            result = {
                response = "D-dragon?! I... I don't want any trouble! Take what you want and go!",
                set_flag = "goblin_king_scared",
                add_item = { id = "sacred_amulet", name = "Sacred Amulet", type = "quest_item" },
                gold_change = 200
            }
        },
        {
            text = "I challenge you to single combat!",
            result = {
                response = "You have courage, I'll give you that. GUARDS! Leave us! This one is mine!",
                set_flag = "honorable_duel"
            }
        },
        {
            text = "Actually, I'll just leave",
            result = {
                response = "Run, coward! Don't come back!"
            }
        }
    }
}

-- =============================================================================
-- TAVERN DIALOGUES
-- =============================================================================

DialogueContent.bartender = {
    speaker = "Bartender",
    text = "What'll it be, stranger?",
    options = {
        {
            text = "Give me your strongest ale (10 gold)",
            condition = { min_gold = 10 },
            result = {
                response = "One Dragon's Breath coming right up! *slides mug across the bar*",
                gold_change = -10,
                set_flag = "had_ale"
            }
        },
        {
            text = "Any rumors worth hearing?",
            result = {
                response = "Well, I heard the old mine to the north is haunted. Strange lights, ghostly sounds... but also treasure, they say."
            }
        },
        {
            text = "I'm looking for work",
            result = {
                response = "Talk to the bounty board by the door. Always someone needing help around here."
            }
        },
        {
            text = "Nothing, thanks",
            result = {
                response = "Alright, but you're welcome to stay and rest."
            }
        }
    }
}

-- =============================================================================
-- HELPER FUNCTION: Get dialogue by ID
-- =============================================================================

function DialogueContent.get(dialogue_id)
    return DialogueContent[dialogue_id]
end

-- List of all available dialogues
DialogueContent.all_dialogues = {
    "merchant_greeting",
    "quest_giver_initial",
    "mysterious_stranger",
    "imprisoned_knight",
    "goblin_king",
    "bartender"
}

return DialogueContent
