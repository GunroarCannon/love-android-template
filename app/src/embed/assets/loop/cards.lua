local cards = {}
local c = cards

c.death = {
    isWeird = true,
    properties = {
        topic = true,
    },
    source = "death.png",
}

c.life = {
    isWeird = true,
    properties = {
        topic = true,
    },
    source = "apple.png",
}

c.bury = {
    properties = {
        sketchy = true,
    },
    source = "bury.png",
    specialName = "bury something",
}

c.kill = {
    properties = {
        weird = true,
    },
    source = "kill.png",
    specialName = "kill someone"
}

c.plead = {
    properties = {
        prayer = true,
    },
    source = "plead.png",
    specialName = "plead for help"
}

c.pray = {
    properties = {
        prayer = true,
    },
    source = "pray.png",
    specialName = "pray",
}

c.clean = {
    properties = {
        change = true,
    },
    source = "clean.png",
    specialName = "clean up"
}

c.laugh = {
    properties = {
        weird = true,
        sketchy = true
    },
    source = "laugh.png",
    specialName = "laugh"
}

c.stroll = {
    properties = {
        action = true
    },
    source = "stroll.png",
    specialName = "take a stroll",
}

c.rest = {
    properties = {
        action = true,
    },
    source = "rest.png",
    specialName = "Rest",
}

c.cry = {
    properties = {
        weird = true,
        suffer = true,
        prayer = true,
        change = true,
        sketchy = true,
    },
    source = "cry.png",
    specialName = "cry",
}

c.weep = {
    properties = {
        weird = true,
        suffer = true,
        prayer = true
    },
    source = "weep.png",
    specialName = "cry",
}

c.lament = {
    properties = {
        -- weird = true,
        suffer = true,
        prayer = true
    },
    source = "lament.png",
    specialName = "cry"
}

c.read = {
    properties = {
        action = true,
    },
    source = "read.png",
    specialName = "read",
}

c.anime = {
    properties = {
        topic = true,
    },
    source = "anime.png",
    name = "anime"
}

c.experiment = {
    isWeird = true,
    properties = {
        action = true,
    },
    source = "experiment.png",
    specialName = "perform experiments"
}

c.exercise = {
    properties = {
        action = true,
    },
    source = "exercise.png",
    specialName = "exercise"
}

c.boot = {
    properties = {
        boot = true,
        shoe = true,
        leather = true
    },
    source = "boot.png",
    name = "boots",
    

}

c.flipflops = {
    properties = {
        slipper = true,
        shoe = true
    },
    source = "flipflops.png",
    
}


c.sneakers = {
    properties = {
        shoe = true,
        fabric = true,
        topic = true
    },
    source = "sneakers.png"
}


c.sandals = {
    properties = {
        shoe = true,
    },
    source = "sandals.png"
}

c.shirt = {
    properties = {
        clothing = true,
        fabric = true
    },
    source = "tshirt.png",
    name = "a shirt",
}


c.hoodie = {
    properties = {
        clothing = true,
        fabric = true
    },
    source = "hoodie.png",
    name = "a hoodie",
}


c.sweater = {
    properties = {
        clothing = true,
        fabric = true
    },
    source = "sweater.png",
    name = "a sweater",
}

 
c.vest = {
    properties = {
        clothing = true,
        fabric = true
    },
    source = "vest.png",
    name = "a vest"
}

c.pie = {
    properties = {
        food = true,
        topic = true
    },
    source = "pie.png"
}

c.sandwich = {
    properties = {
        food = true,
         
    },
    source = "sandwich.png",
    name = "a sandwich",
}

c.apple = {
    properties = {
        food = true, 
    },
    source = "apple.png",
    name = "an apple"
}

c.pancakes = {
    properties = {
        food = true,
        topic = true
    },
    source = "pancakes.png"
}

c.banana = {
    properties = {
        food = true, 
    },
    source = "banana.png",
    name = "a banana",
}

c.soda = {
    properties = {
        beverage = true, 
    },
    source = "soda.png"
}

c.milkshake = {
    properties = {
        beverage = true, 
    },
    source = "milkshake.png",
    name = "a milkshake"
}

c.tea = {
    properties = {
        beverage = true, 
    },
    source = "tea.png",
    name = "some tea"
}

c.water = {
    properties = {
        beverage = true, 
    },
    source = "water.png",
}

c.coffee = {
    properties = {
        beverage = true, 
    },
    source = "coffee.png"
}

c.pear = {
    properties = {
        food = true, 
    },
    source = "pear.png",
    name = "a pear"
}

c.scorn = {
    properties = {
        interact = true,
        rude = true,
        interact_dog = true,
        help = true, 
    },
    source = "scorn.png",
    specialName = "scorn someone",
}

c.kick_dog = {
    properties = { 
       -- rude = true,
        interact_dog = true, 
    },
    source = "kick.png",
    specialName = "kick a dog"
}

c.pet_dog = {
    properties = { 
        interact_dog = true, 
    },
    source = "pet.png",
    specialName = "pet a dog",
}

c.greet = {
    properties = {
        interact = true,
        interact_dog = true,
        kind = true
    },
    source = "greet.png",
    specialName = "greet someone"
}

c.mock = {
    properties = {
        interact = true,
        rude = true,
        give = true,
        help = true,
    },
    source = "mock.png",
    specialName = "mock someone",
}

c.ignore = {
    properties = {
        interact = true,
        interact_dog = true ,
        help = true,
        give = true,
        rude = true,
        defense = true
    },
    source = "ignore.png",
    specialName = "ignore someone"
}

c.help = {
    properties = {
        help = true,
        kind = true,
        give = true
    },
    source = "help.png",
    specialName = "help"
}

c.fight = {
    properties = {
        rude = true,
        violent = true,
        defense = true
    },
    source = "fight.png",
    specialName = "fight someone"
}

c.run = {
    properties = {
        defense = true,
        rude = true,
        sketchy = true,
        change = true
    },
    source = "run.png",
    specialName = "run away"
}

c.talk = {
    properties = {
        interact = true,
        kind = true,
        defense = true
    },
    source = "talk.png",
    specialName = "talk",
}

c.food = {
    properties = {
        give = true,
        topic = true
    },
    source = "food.png"
}

c.violence = {
    properties = {
        topic = true, 
    },
    source = "violence.png"
}

c.videogame = {
    properties = {
        topic = true,
        videogame = true,
        give = true
    },
    source = "videogames.png",
    name = "video games"
}

c.vidyagaem = {
    properties = {
        videogame = true, 
        vidyagaem = true,
       -- give = true
        
    },
    source = "vidyagaems.png",
    name = "video games"
}

c.eldritch = {
    properties = {
        eldritch = true
    },
    source = function()
        if game.room.env.vidyagaem then
           -- return "monsterv.png"
        end
        
        local list = {1,2,3,4,5,6,7,8,9}
        return string .format("monster%s.png",lume.randomchoice(list))
    end,
    specialName = "come across a stange being"
}


-- copied so there can be atleast 3 cards of that type...

c.ee=lume.copy(c.eldritch)
c.eeg=lume.copy(c .eldritch)



c.strange = {
    properties = {
        strange = true,
        glitch = true
    },
    source = function()
        if game.room.env.vidyagaem then
           -- return "monsterv.png"
        end
        
        local list = {1,2,3,4,5,6,7,8,9}
        return string.format("monster%s.png",lume.randomchoice(list))
    end,
    specialName = "come across a strange being"
}
c.strange2 = lume.copy(c.strange)
c.strange3 = lume.copy(c.strange)

c.loop = {
    properties = {
        loop = true
    },
    source = "loop.png"
}
c.ll = lume.copy(c.loop)
c.llg = lume.copy(c.loop)
return cards