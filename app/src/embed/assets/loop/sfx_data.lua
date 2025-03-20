local SFX_data = {}

local sfx = {}


sfx.other = {
    scream1 = "scream1.wav",
    scream2 = "scream2.wav",
    scream3 = "scream3.mp3",
    
    deep_growl = "deep_growl.mp3",
    laughter = "laughter-2.mp3",
    
    mon1 = "mon1.mp3",
    mon2 = "mon2.mp3",
    mon3 = "mon3.mp3",
    mon4 = "mon4.wav",
    mon5 = "mon5.mp3",
    mon6 = "mon6.mp3",
    mon7 = "mon7.mp3",
    mon8 = "mon8.mp3",
    
    byeback = "byeback.mp3",
    eat = "eat.mp3",
    eat2 = "eat2.mp3",
    
    drink = "drink.mp3",
    
    dog1 = "dog1.mp3",
    dog2 = "dog2.mp3",
    whine = "whine.mp3",
    
    rude = "rude.mp3",
    hey = "hey.mp3",
    ugh = "ugh.mp3",
    ah  = "ah.mp3",
    hey2 = "hey2.mp3",
    help = "help.mp3",
    
    fearful = "fearful.mp3",
    
    thief = "thief.mp3",
    
    you = "you.mp3",
    zip = "zip.mp3",
    
    swift = "swift.mp3",
    beg = "beg.mp3",
    beg2 = "beg2.mp3",
    
    warhorn = "warhorn.ogg",
    
    cheering = "cheering.mp3",
    levelup_achievement = "levelup_achievement.mp3",
    levelup = "levelup.mp3",
    buzz = "buzz.mp3",
    ding = "ding.ogg"
}


sfx['smc-wwviRetroActionSounds'] = {
    portal1 = "jetwash.ogg",
    portal2 = "gravity_bomb.ogg"
}

sfx.battle_sound_effects = {
    wood = "Bow.wav"
}



local sounds = {}

for dir, data in pairs(sfx) do
    for name, filename in pairs(data) do
        sounds[name] = string.format("%s/%s",dir,filename)
    end
end

SFX_data = {
	sfx = sounds,
	data = sfx
}

return SFX_data
	
	