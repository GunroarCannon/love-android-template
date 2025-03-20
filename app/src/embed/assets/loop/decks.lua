local decks = {}
local d = decks

gameoverDeck = {
    eldritch = true,
    cards = {"eldritch"},
    text = {
        "You got caught by a monster!!",
        "An abomination caught you!",
        "You messed up the time loop!",
        "The timeloop was broken by you...",
        "You chose incorrectly...",
        "You are hunted by spacetime"
    } or {
        "It's some kind of  monster",
        "An abomination of spacetime",
        "A horror of spacetime approaches you",
        "Dread washes over you",
        " It's broken",
        " Ch$$%s %nePAIR end do &&5",
        ":Last cha%%nce~~===%&&&$ No chance",
        " Dead.",
        ":::When I sin__ g George watch me.",
        "The eraser of you...",
        "&&&&&&&&%%%%%%*------444",
        "Only I c!an he)p you" ,
        "DON'T LOOP!!" ,
        "...DEID UOY",
        "Just leave us...",
        "Lorem ipsum docet",
        "Just what is th?jj@@88t...",
        "It was a tale of time. Long ago we were all normal like you but then the loop had us. We were tortured until our very souls left us empty and longing for destroyers of time.",
        "Unfortunately I couldn't run anymore. 5 of us were there. I had to outrun my best friends if i was to live. I reached the end of the field only to realize that we had been brought to the beginning. We had looped. And the abomination was upon us.",        
    },
    presound = {"mon1","mon2","mon3","mon4","mon5","mon6","mon7","mon8","deep_growl"},
    sound = {"scream1","scream2","scream3"}
}

loopDeck = {
    loop = true,
    eldritch = true,
    cards = {"loop"},
    text = "A time vortex",
    sound = {"portal1","portal2"},
    action = "loop",
}

d.shoe = {
    text = "You wear a shoe",
    max = 3,
    action = "wear",
    
    cards = {"shoe"},
    
    choices = {
        any = {
            loops = {1,3},
            spawn = {"mud","compliment"},
            after = {1,5}
        }
    },
    
    sound = "zip"
}

d.clothe = {
    text = "You put on some clothes",
    max = 2,
    action = "put on",
    
    cards = {"clothing"},
    choices = {
        any = {
            loops = {1,3},
            spawn = {"mud","compliment"},
            after = {1,3},
            afterTimes = {mud=-1},
            after2 = -1
        }
    },
    
    sound = "zip"
}

d.dog = {
    text = "You come across a dog",
    action = "treat a dog",
    cards = {"interact_dog"},
    presound = {"dog1","dog2"},
    sounds = {kick_dog="whine"}
}

d.drink = {
    text = "You drink something",
    action = "drink",
    cards = {"beverage"},
    --sound = "drink"
}

d.eat = {
    text = "You eat something",
    action = "eat",
    cards = {"food"},
    sound = {"eat","eat","eat2"},
    presound="eat2"
}

d.stranger = {
    text = "You meet a stranger",
    action = "meet",
    cards = {"interact"},

    choices = {
        talk = {
            loops = {1,3},
            spawn = "talkabout",
            after = 1,
        }
    },
    
    presound = "hey2",
    sounds = {
        fight = "rude"
    }
}

d.friend = {
    text = "You meet an acquaintance",
    cards = {"interact"},
    action = "meet",
    choices = {
        talk = {
            loops = {1,3},
            spawn = "talkabout",
            after = 1,
        }
    },
    presound = "hey"
}

d.talkabout = {
    text = "You talk about a topic",
    action = "talk about",
    cards = {"topic"},
    mustDerive = true,
    sound = "ah"
}

d.compliment = {
    mustDerive = true,
    text = "Someone compliments what you wear",
    action = "meet",
    cards = {"interact"},

    choices = {
        talk = {
            loops = {1,3},
            spawn = "talkabout",
            after = 1,
        }
    },
    presound = "ah",
    sounds = {
        fight = "rude",
        mock = "rude",
        ignore = "rude",
    }
}
    

d.mud = {
    -- mustDerive = true,
    text = "You got mud on yourself",
    action = "change to",
    cards = {"change"},
    choices = {
        any = {
            loops = {1,3},
            spawn = {"clothe","shoe"},
            after = {1,5}
        }
    },
    sound = "ugh"
}

d.bored = {
    text = "You got bored",
    action = "do",
    cards = {"action"},
}

d.strangeIntro = {
    isStrangeIntro = true,
    text = {'"I will show you my F??ther"', '"Come, l71t us sing +nd play:;?"','"Fa44333333 ##er, come and see"'},
    action = "strange",
    choices = {
        any = {
            amount = 3,
            loops = {1,2},
            spawn = {"strange"},
            after = {1,3}
        }
    },
    sound = "warhorn",
    cards = {"strange"}
}
    

d.corpse = {
    isWeird = true,
    text = "You find a corpse",
    action = "sketchy",
    cards = {"sketchy"},
}

d.strange = {
    mustDerive = true,
    isWeird = true,
    action = "pray",
    text = "You see ... a god?",
    cards = {"prayer"}
}

d.suffer = {
    isWeird = true,
    action = "pray",
    text = "It's ... so painful.",
    cards = {"prayer"}
}

d.introduced = {
    needs = {"complimented"},
    text  = "A friend introduced you to someone",
    cards = {"interact"},
    action = "meet",
    presound = {"laughter","hey2"},
    sounds = {
        fight = "rude",
        mock = "rude",
        ignore = "rude"
    }
}

d.stranger_help = {
    text = "A stranger asks for help",
    action = "treat",
    cards = {"help"},
    presound = "help"
}

d.thief = {
    text = "You come across a thief",
    action = "defend",
    cards = {"defense"},
    presound = "thief",
    sounds = {
        fight = "rude",
        mock = "rude"
    }
}

d.beggar = {
    text = "A beggar asks for something. Anything",
    action = "give away",
    cards = {"give"},
    presound = {"beg2","beg"}
}

d.running = {
    text = "A fearful stranger bumps into you",
    action = "defend",
    cards = {"rude"},
    needs = {"violent"},
    presound = "fearful"
}

d.policeman = {
    mustDerive = true,
    text = "A policeman confronts you",
    action = "defend",
    cards = {"defense"},
    needs = {{"fight",3}},

    choices = {
        talk = {
            loops = {1,3},
            spawn = "talkabout",
            after = 1,
        }
    }
}
    

return decks