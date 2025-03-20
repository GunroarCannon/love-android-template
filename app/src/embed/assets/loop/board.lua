local Board = toybox.Room("Board")

reverseShader = love.graphics.newShader([[/*
    Edge shader
    Author: Themaister
    License: Public domain.
    
    modified by slime73 for use with love2d and mari0
*/

vec3 grayscale(vec3 color)
{
	return vec3(dot(color, vec3(0.3, 0.59, 0.11)));
}
 
vec4 effect(vec4 vcolor, Image texture, vec2 tex, vec2 pixel_coords)
{
	vec4 texcolor = Texel(texture, tex);
	
	float x = 0.5 / love_ScreenSize.x;
	float y = 0.5 / love_ScreenSize.y;
	vec2 dg1 = vec2( x, y);
	vec2 dg2 = vec2(-x, y);
	
	vec3 c00 = Texel(texture, tex - dg1).xyz;
	vec3 c02 = Texel(texture, tex + dg2).xyz;
	vec3 c11 = texcolor.xyz;
	vec3 c20 = Texel(texture, tex - dg2).xyz;
	vec3 c22 = Texel(texture, tex + dg1).xyz;
	
	vec2 texsize = love_ScreenSize.xy;
	
	vec3 first = mix(c00, c20, fract(tex.x * texsize.x + 0.5));
	vec3 second = mix(c02, c22, fract(tex.x * texsize.x + 0.5));
	
	vec3 res = mix(first, second, fract(tex.y * texsize.y + 0.5));
	vec4 final = vec4(5.0 * grayscale(abs(res - c11)), vcolor.a*Texel(texture, tex).a);
	return clamp(final, 0.0, 1.0);
}]])

--flashc
redShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc) {
        return vec4(1,0,0,color.a * Texel(img, tc).a);
    }]])
    
    
reverseShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc) {
        return vec4(1,0.843,0,color.a * Texel(img, tc).a);
    }]])

reverseShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total > 2.0) {
    float diff = 0.0;
	vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
	return vec4(gc, (color.a*Texel(img, tc).a));
	} else
	return vec4(vec3(1.0,1.0,1.0),(color.a*Texel(img, tc).a));
}
]])

math.randomseed(love.timer.getTime())
local Card = toybox.Object("Card")

Card.__bdraw = Card.__draw

function Card:create(p)
    self.solid = false
    self.angle = p.angle or 0
end

function Card:setData(card)
    local s = card.source
    card.object = self
    
    for check = 1,2 do
        if type(s) == "table" then
            s = getValue(s)
        end
        if type(s) == "function" then
            s = s(self, card )
        end
    end
    
    self.source = string.format("cards/%s", s)
    self.data = card
end

function Card.__draw(self)
    if gooi.showingDialog then return end
    if self.room.over then return end
    
    self.__bdraw(self)
end

function Board:setup()
    gooi.components = {}
    gooi.closeDialog()
    
    self:activate_gooi()
    self.cover_alpha = 1
    self:tweenCoverAlpha(1, 0)
    
    
    local nn = 1.2
    local ww = W()*.5*nn
    local hh = H()*.6*nn
    
    self.cards_3 = gooi.newPanel({
        x = W()/2-ww/2,
        y = H()/2-hh/2,
        w = ww,
        h = hh,
        group = "cards",
        layout = "grid 7x3",
        padding = 7
    }):
    setColspan(1,1,3):
    setColspan(7,1,3):
    setRowspan(2,1,5):
    setRowspan(2,2,5):
    setRowspan(2,3,5)
    
    --self.cards_3.layout:init(self.cards_3)
    ttx=0
    gooi.newb = gooi.newb or gooi.newLabel
    gooi.newLabel = function(...)
        
        local g = gooi.newButton(...)
        g.opaque = false --g.ttx = ttx+1 ttx=ttx+1 if ttx==3 then error(g.ttx) end g.hh=1
        return g
        
    end
    
    self.description = gooi.newButton({group="cards"}):setText(""):center()
    self.description.angle = 0
    self.cards_3:add(self.description)
    self.cards_3.cards = {}
    
    self.description.fgColor = {1,1,1}
    self.description.opaque = true
    self.cardsUI = {}
    
    self.score = 0
    self.cards = {}
    self.env = {}
    
    for x = 1, 3 do
        local card = gooi.newButton({group="cards",text=""}):onRelease(self.selectCard)
        card._id = x
        card.card = true
        self.cards_3.cards[x] = card
        self.cards_3:add(card)
        
        card.bgColor = {0,0,0,0}
        card.borderColor = {0,0,0,0}
        card.draw = null
        card.drawSpecifics = null
        
        self.cardsUI[x] = card
    end
    
    self.extra = gooi.newLabel({group="cards"}):setText(""):center()
    self.cards_3:add(self.extra)
    
    self.num = 3
    self.toAdd = {}
    
    -- amount of times a deck has looped
    self.deckTimes = {}
    
    -- amounts of times a deck is present in one loop
    self.deckAmount = {}
    
    -- decks in a loop
    self.loops = {}
    self.choices = {}
    
    -- mad cards per loop
    self.maxCards = 3
    

    self.lloops = 0
    
    self:loadCards()
    self.currentL = 1
    self:getDeck(self.currentL)
    
    gooi.currentGroup = "cards"
    gooi.removeComponent(self.cards_3)
    gooi.addComponent(self.cards_3)
    
    
    self.startTime = 4
    self.time = self.startTime
    self.doTime = 1
    if not toybox.getData('loop').intro then
        gooi.closeDialog()
        toybox.getData("loop").intro = true
        toybox.saveData("loop")
        gooi.alert({
            text = intro,
            big = true
        })
    else
        claimPop()
    end
end

function Board:loadCards()
    for x = 1, self.num do
        local card = Card:new({room=self})
        self:place_instance(card,0,0)
        card.num = x
        self.cards[x] = card
    end
end

function Board:keypressed(key)
    if key == "f1" or key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    if key == "escape" then
        game:set_room(Home)
    end
    
    local n = tonumber(key)
    if n and self.cardsUI[n] then
        self.selectCard(self.cardsUI[n])
    end
end
 
function Board.selectCard(card)
    local t = 1
    
    if math.abs(game.room.cards[card._id].angle)>10 or game.room.noTouch then--card.block then
        return
    end
    
    game.room.drawTime = nil
    
    local data = game.room.cards[card._id].data
    local cc = game.room.cards[card._id]
    local self = game.room
    local n = self.current
    local deck = self.loops[n][1]
    assert(deck)
    
    media.sfx.swift:play()
    if deck.sound then
        media.sfx[getValue(deck.sound)]:play()
    end
    
    cc.color = getColor("green")
    
    self:after(.1, function()
    
    local s = deck.sounds and deck.sounds[data._name]
    
    if s then
        media.sfx[s]:play()
    end
    self.time = self.startTime
    
    checkDailyChallenge(deck, data)
    
    log("!!"..inspect(data,1)..inspect(self. loops[n]))
    if  data.properties.loop and deck.loop then

        self:addScore(10,cc)
        self:repeatt()
    
    elseif data.properties.glitch and not self.weird then
        self.weird = true
        self:placeDeck(decks.strangeIntro, #self.loops)--loops)
        --self.nextDeck = decks.strangeIntro
        -- so that it will loop --after nextDeck
        --self.currentL = self.currentL-1--self.maxCards-1
        -- self.maxCards = self.maxCards+2
        t = t*3
        self:reverseBlip(.4)
        media.music:setPitch(.6)
        
    elseif data.properties.eldritch and not data.properties.glitch then
        self:gamegameover()
    elseif self.choices[tostring(self.loops[n])] and self.choices[tostring(self.loops[n])] ~= data and not data.properties.glitch then
        log(inspect(self.choices[tostring(self.loops[n])],1)..", failed "..inspect(data,1))
        local obj = self.choices[tostring(self.loops[n])].object
        -- obj.color = getColor("red") warn()
        obj.correct = true
        self.gameDone = true
        -- self:gameover()
    elseif not self.choices[tostring(self.loops[n])] then
        self.choices[tostring(self.loops[n])] = data
        self.time = 1
        --local deck = decks.clothe
        local nn = deck.choices and (deck.choices[data._name] or deck.choices.any)
        if nn then
          for x = 1, nn.amount or 1 do
            local after = getValue(nn.loops or {1,2})
            local deck = getValue(nn.spawn or nn.decks)
            
            if nn.afterTime then
                after = getValue(nn.afterTime[deck] or after)
            end
            
            local pos = getValue(nn.after or 1)+n
            
            self:addDeck(decks[deck],after,pos)
          end
        end

        self:addScore(5,cc)
        
    else

        self:addScore(5,cc)
    end
    
    if data.isWeird then
        t = t*2
    end
    
    if self.gameDone then
        t = t*1.5
    end
    
    for x, i in ipairs(data.properties) do
        self.env[i] = (self.env[i] or 0)+1
    end
    
    --media.sfx.eat:play()
    
    local gameDone
    
    local function done()
    
    if self.gameDone then
        self:gameover(t*2)
        self.gameover = null
    end
    
    local function next()
    for x = 1, game.room.num do
        local cc = game.room.cards[x]
        local c = toybox.NewBaseObject({room=game.room})
        c.source = cc.source
        c.solid = false
        c.x, c.y = cc.x, cc.y
        c.w, c.h = cc.w, cc.h
        
        cc:move_to(-1000,-1000)
        if game.room.cardsUI[x] == card then
            game.room:tween(t+.05, c, {x=W()+c.w, y=0, angle = 700}, "out-quad", function()
                c:destroy()
                --game.room:getDeck(1)
            end)
            game.room.timer:after(t*.7, function()
            self.currentL = self.currentL+1
            if self.currentL>self.maxCards then
                 
                self:repeatLoop()
            end 
                game.room:getDeck(self.currentL)
                 
            end)
        else
            if cc.correct then c.color = "red" end
            game.room:tween(t*1.5, c, {x=self.gameDone and c.x or -c.w, y=cc.correct and -cc.h or H()+c.h, angle= cc.correct and 0 or -700}, self.gameDone and "out-quad" or "out-circ",function()
                c:destroy()
            end)
            cc.correct = false
        end
    end
    
    local desc = self.description
    local dx, dy = desc.x, desc.y
    local function refix()
        desc.x, desc.y = dx, dy
        -- desc:setText("")
        desc.angle = 0
    end
    
    self:tween(t, desc, {angle = getValue(200,400), x = math.random()>.5 and W() or -desc.w, y = -desc.h}, "out-circ", refix)
    
    game.room.timer:after(t,function()
        self.noTouch = nil
    end)
    end
    game.timer:after(gameDone and .5 or 0, next)
    end
    
    
    self.noTouch = 1
    game.timer:after(gameDone and .15 or 0, done)
    
    game.room.camera:shake(self.gameDone and 50 or 25,self.gameDone and .5 or .2,40)
    end)
    
    self.noTouch = 1
end

local texts = {
    lost = {
[[You have been hunted 
by a creature of space and
time]],
[[You messed up the time loop]],
[[The divine entities are angry]],
[[You seize to exist]]
},
    again = {
    "again","more...","loop","another"
     },
     cancel = {"no more",'stop...'," NO!","no more"}
}

function Board:gamegameover()
    self.over = true
    gooi.removeComponent(self.cards_3)
    media.sfx["scream"..math.random(1,3)]:play()
    if self.score > toybox.getData('loop').highest then
        toybox.getData('loop').highest = self.score
        toybox.saveData('loop')
    end
    
    rewardPoints(self.score)
    
    gooi.currentGroup = "over"
    gooi.dialog({
        text = string.format([[
%s
---

%s...

---

Score: %s

Highscore: %s
%s]],
        self.timeout and "You took too long..." or "You picked the wrong action.",
        getValue(texts.lost),
        self.score,
        toybox.getData("loop").highest, doneChallenge and "YOU COMPLETED A CHALLENGE!!" or ""),
        okText = getValue(texts.again)
        ,cancelText = getValue(texts.cancel),
        big=true,
        group=gooi.currentGroup,
        ok = function()
            local r = Board:new({})
            game:add_room(r,true)
            game:set_room(r.name)
        end,
        cancel = function()
            game:set_room(Home)--love.event.quit()
        end
    })
    
    local g = gooi.panelDialog
    self.gameOverPanel = g
    for x = 1, #g.sons+1 do
        local k = g.sons[x] and g.sons[x].ref or g
        k.onlyImage = true
        k.showBorder = false
        k.bgColor = {0,0,0,0}
        k.drawRect = false
        k.draw = null
    end
    
    -- error(gooi.panelDialog.w..","..gooi.panelDialog.h)
end

function Board:gameover(time)
    self.nextDeck = gameoverDeck
    self.failing = true

    self.camera:fade(.9,colors.black,
    function()
        self.camera:fade((time or .9)-.1,{0,0,0,0})
    end
    )
end

function Board:addDeck(deck, after, pos)
    self.toAdd[#self.toAdd+1] = {deck,after,pos}
end

function Board:checkNewDecks()
    for x = 1,(#self.toAdd) do
    
        local decks = self.toAdd[x]
        if decks then  
            decks[2] = decks[2]-1
            if decks[2]<=0 then
                self:placeDeck(decks[1],decks[3])
                table.remove(self.toAdd,x)
            end
        end
    end
end


function Board:placeDeck(deck, pos)
    -- glitch
    
    local pos = lume.min(pos,#self.loops)

    local n = lume.copy(self.loops)
    self.loops[pos] = { lume.copy(deck)
    ,true}
    self.maxCards = self.maxCards+1
    for x = pos, #self.loops do
        self.loops[x+1] = n[x]
    end 
    
end

function Board:reverseBlip(time)
    self.shader = reverseShader
    local function norm()
        self.shader = nil
    end
    self:after(time or .5, norm)
end

function Board:repeatLoop()
    self.nextDeck = loopDeck
    if not game.data.loopText then
        gooi.alert({
            big = true,
            text = [[When you loop pick the same
            actions as before;
            do it before time runs out!]]
        })
        game.data.loopText = true
        game:saveData()
    end
end

function Board:repeatt()
    self.time = self.startTime or 1
    self.currentL = 0

    self:checkNewDecks()
    self.nextDeck = nil
    self.camera:fade(.2,{1,1,1,1},--colors.white,
    function()
        self.camera:fade(.5,{0,0,0,0})
    end
    )
    self.maxCards = self.maxCards+(self.lloops<3 and getValue({1,1,2,2}) or getValue({1,2,2,3,3}))
    self.lloops = self.lloops+1
end

function Board:extraDetail(vc)
    self:flinch(1.5)
    if not toybox.getData('loop').extra then
        gooi.closeDialog()
        toybox.getData("loop").extra = true
        toybox.saveData("loop")
        gooi.alert({
            text = extra,
            big = true
        })
    end
    self.extra:setText("Extra Detail")
end

function Board:flinch(time,vc)
    local c = {0,0,0}
    local c2 = {1,1,1}
    local t = .1
    local l = "linear"
    
    if time <= 0 and self.description.fgColor[1]==1 then
    
        self.extra:setText("")
        return
    end
    
    time = time-t
    
    self:tween(t,self.description,{fgColor=vc and c2 or c},l,
    function()
        self:flinch(time,not vc)
    end)
end

function Board:getDeck(n)
    local deck = self.nextDeck or self.loops[n] and self.loops[n][1]
    if self.loops[n] and self.loops[n][1].loop then
        self.loops[n] = nil
        deck = nil
    end
    
    self.drawTime = not self. nextDeck
    if not deck then 
        while not deck or ((self.deckAmount[tostring(deck)] or 0)>(deck.max or math.huge)) do
            deck = self:getRandomDeck()
        end
        
    end
    
    if deck and deck.presound then 
    --assert(media.sfx[deck.presound],inspect(media.sfx)..","..deck.presound)
        local d = getValue(deck.presound)
        assert(media.sfx[d],d)
        media.sfx[d]:play()
    end
    
    self.deckAmount[tostring(deck)] = (self.deckAmount[tostring(deck)] or 0)+1
    self.lastDeck = deck
    
    self.loops[n] = self.loops[n] or {deck}

    if self.loops[n][2] then
        self.loops[n][2] = nil
        if not self.failing then
            self:extraDetail()
        end
        self.drawTime = nil
        self.time = self.startTime
        
    end
    
    if not self.choices[tostring(self.loops[n])] and not self.nextDeck then
        self.drawTime = false
        self.extra:setText("New Event")
        self.timer:after(2,function()
            self.extra:setText("")
        end)
    end
    
    self.choices[tostring(self.loops[n])] = self.choices[tostring(self.loops[n])] or nil
    
    self.description:setText(getValue(deck.text))
    self.current = n

    local new = self:getCards(deck)
    
    self:fixCards(new)
    
end

function Board:fixCards(new, time)
local nnn = getValue({
            "out-quart",
            "out-circ",
            "in-bounce",
            "out-back"
        })
    
    local time = (time or 1)+(self.weird and not self.doneWeird and 5 or self.weird and .5 or 0)
    
    if self.doneWeird then
        self.insideWeird = true
    end
    
    if self.weird then
        self.doneWeird = true
    end
    
    for x = 1, self.num do
        local card = self.cards[x]
        local ccard = self.cardsUI[x]
        card.color = nil
        
        card:setData(new[x])
        
        if self.nextDeck and self.nextDeck.eldritch and new[x].properties.eldritch then
            card.source = self.cards[1].source
        elseif self.nextDeck and self.nextDeck.isStrangeIntro and new[x].properties.eldritch then
            card.source = getValue(self.cards).source
            time = lume.max(time, 3)
        end
        
        self.time = (self.startTime or 3)+(time-1)
        
        local ui = self.cardsUI[x]
        card.ui = ui
        ui.fgColor = nil
        
        card.w = ui.w
        card.h = ui.h
        
        card.x, card.y = 0,0
        
        local n = 2
        local n2 = 3
        
        local ca = true--math.floor(card. angle)==0
        --assert(ca,card.angle)
        card.angle = 360*math.random(1,3)
        ui.block = true
        
        --self.noTouch =  1
        local allowC = function()
            assert(ui.block)
            --self.noTouch=nil
            --ui.block = false
            --assert(self.current<4,self.current)
        end
        
        local r1,r2 = -6,-4
        if ca then 
        self:tween(time+0*math.random(r1,r2)/100,card, {
            x = ui.x+ui.w/2,
            y = ui.y+ui.h/2,
            angle = 0
        }, nnn,allowC)
         
        end
        --self.timer:after(.7,allowC)
    end
end

function Board:getRandomDeck()

    local deck = nil--lume.randomchoice(decks)--{decks.shoe,decks.clothe})
    local count = 150
    while not deck or deck == self.lastDeck do
        count = count - 1
        deck = lume.randomchoice(decks)
        if deck.needs then
            local yes = true
            for x, i in ipairs(deck.needs) do
                if type(i) == "table" then
                    if type(i[2])=="number" then
                        if (self.env[i[1]] or 0)<=i[2] then
                            yes = false
                            break
                        end
                    else
                        for xx, ii in ipairs(i) do
                            if self.env[ii] then
                                yes = true
                                break
                            end
                        end
                    end
                end
            end
            
            if count <= 0 then
                break
            end
            
            if not yes or deck.mustDerive then
                deck = nil
            end
        end
        
        if deck and deck.mustDerive then
            deck = nil
        end
        
        if deck and deck.isWeird and not self.weird then
            deck = nil
        end
        
        if deck and deck.isStrangeIntro then
            deck = nil
        end
    end
    
    
    return lume.copy(deck)
end


function getAllCardsForDeck(deck)
    local can = {}
    local allCards = {}
    
    for x, card in pairs(cards) do
        local yes = true
        card._true = true
        for x, i in ipairs(deck.cards) do
            if not card.properties[i] then
                yes = false
                card._true = false
                break
            end
        end
        
        
        if card.properties.strange and deck.cards[1] ~= "strange" then
            yes = nil
        end
        
        if card.properties.eldritch and (not deck.eldritch and not deck.isStrangeIntro) then
            yes = nil
        end
        
        if deck.isStrangeIntro and not card.properties.strange then
            yes = nil
        end
        
        if (card.properties.prayer or card.properties.weird) and not card.properties.change then
            yes = nil
        end
        
        
        if yes then
            if card.properties.eldritch and not deck.eldritch then
                card = lume.copy(card)
                card.properties = lume.copy(card.properties)
                card.properties.glitch = true
            end
            
            can[tostring(card)] = card
            allCards[#allCards+1] = card
        end
    end
    
    return allCards, can
end


function Board:getCards(deck,nn)
    if math.random()<0.12 and self.lloops>0 and not self.you then
        self.you = true  
        media.sfx.you:play()
    end
    self.deckTimes[tostring(deck)] = (self.deckTimes[tostring(deck)] or self.num+1)-1
    local maxReq =    deck.eldritch and 3 or lume.max(self.deckTimes[tostring(deck)],1)
    local can = {}
    for x, card in pairs(cards) do
        local yes = true
        card._true = true
        for x, i in ipairs(deck.cards) do
            if not card.properties[i] then
                yes = false
                card._true = false
                break
            end
        end
        
        if not deck.eldritch and math.random(100)<25*(self.num-lume.max(self.deckTimes[tostring(deck)],0)) then
            yes = true
        end
        
        if card.properties.strange and deck.cards[1] ~= "strange" then
            yes = nil
        end
        
        if card.properties.eldritch and (self.weird or self.lloops < 3) and (not deck.eldritch and not deck.isStrangeIntro) then
            yes = nil
        end
        
        if deck.isStrangeIntro and not card.properties.strange then
            yes = nil
        end
        
        if (card.properties.prayer or card.properties.weird) and (not self.weird) and not card.properties.change then
            yes = nil
        end
        
        if card.isWeird and not self.weird then
            yes = nil
        end
        
        if yes then
            if card.properties.eldritch and not deck.eldritch then
                card = lume.copy(card)
                card.properties = lume.copy(card.properties)
                card.properties.glitch = true
            end
            
            can[tostring(card)] = card
        end
    end
    
    local new = {}
    local keys = lume.keys(can)
    local done = {}
    local count = maxReq+40
    while maxReq > 0 do
        local cc,n = lume.randomchoice(keys,true)
        local c  = can[cc]
        assert(c, inspect(deck.cards))
        if c._true then
            new[#new+1] = c
            table.remove(keys, n)
            done[c] = true
            maxReq = maxReq - 1
        end
        count = count - 1
        if count <= 0 then
            break
        end
    end
    hgg=(#new .. ","..self.num..inspect(keys)) 
    
    for x = 1, self.num - #new do
        
        local cc,n = lume.randomchoice(keys,true)
        local c  = can[cc]
        done[c] = true

        assert(c,cc)
        new[#new+1] = c
        table.remove(keys, n)
        hgg=cc..#new
    end
    assert(#new>=self.num,hgg..inspect(new,2).."")
    
    
    local c = self.choices[tostring(self.loops[self.current])] 
    if c and not done[c] and not deck.eldritch then
        new[math.random(#new)] = c
    end
    

    if deck.eldritch then
        for  x = 1 , self.num do
            new[x] = new[1]
        end
    end
    
    return new
end
    

function Board:draw_before()
    res.endRendering()
    local board = game:getAsset("board_new.png")
    
    local sh = lg.getShader()
   -- if self.shader then lg.setShader(self.shader) end
    
    love.graphics.draw(board, 0, 0,0,resizeImage(board,love.graphics._getWidth(),love.graphics._getHeight()))
    
    local r,g,b,a = set_color(1,1,1,game.scratches1Alpha)
    local board = game:getAsset("scratches1.png")
    love.graphics.draw(board, 0, 0,0,resizeImage(board,love.graphics._getWidth(),love.graphics._getHeight()))
    
    set_color(1,1,1,game.scratches2Alpha)
    local board = game:getAsset("scratches2.png")
    love.graphics.draw(board, 0, 0,0,resizeImage(board,love.graphics._getWidth(),love.graphics._getHeight()))
    
    set_color(1,1,1,game.scratches3Alpha)
    local board = game:getAsset("scratches3.png")
    love.graphics.draw(board, 0, 0,0,resizeImage(board,love.graphics._getWidth(),love.graphics._getHeight()))
    
   -- lg.setShader(sh)
    
    set_color(r,g,b,a)

    res.beginRendering()
    self.camera:attach()
    if not self.over then
    gooi.draw(gooi.currentGroup)
    
    for x = 1, gooi.showingDialog and 0 or self.num do
        self.cards[x]:__draw()
    end
    end
    self.camera:detach()
end

function Board:addScore( v,c)
    if self.scoreText then return end
    
    self.scoreText = {
        x = c.x+c.w/2,y=c.y,6+c.h/4*0,
        val = v
    }
    
    self.timer:tween(.6, self.scoreText,{x=self.sx+love.graphics.getFont():getWidth("score: "),y=self.sy},"out-quad",
    function()
        self.scoreText = nil
        self.score = self.score+v
        self.camera:shake(25,.2,25)
    end
    )
end

function Board:draw()
    if self.over then
        gooi.draw(gooi.currentGroup)--,
    end
    
    local text = string.format("Score: %s",self.score)
    local ss = 1.5
    local w = love.graphics.getFont():getWidth(text)*ss
    local h = love.graphics.getFont():getHeight()*ss
    
    self.sx, self.sy = W()-w-10,H()-h-10
    self.sw = w
    love.graphics.print(text, self.sx,self.sy,0,ss,ss)
    
    if self.scoreText then
        local st = self.scoreText
        local t ="+".. st.val
        local ss = 2
        

        local sst = ss*1.2
        local h = love.graphics.getFont():getHeight()
        local w = love.graphics.getFont():getWidth(t)*1
        local sc = .1
        love.graphics.setColor(0,0,0)
        love.graphics.print(t,st.x-w*sc,st.y-h*sc,0,sst,sst)
        love.graphics.setColor(1,1,1)
        
        love.graphics.print(t,st.x,st.y,0,ss,ss)
    end

     if gooi.showingDialog then
         gooi:draw(gooi.currentGroup)
     end
    
    if self.gameOverPanel or (gooi.panelDialog and gooi.panelDialog.big and gooi.yesButton) then
        if gooi.panelDialog then
            gooi.panelDialog.opaque = nil
        end
        if gooi.yesButton and gooi.noButton then
            gooi.yesButton.opaque = nil
            gooi.noButton.opaque = nil
        end
        
        love.graphics.draw(game:getAsset("panel.png"))
    end
    
    if not self.drawTime then
        return
    end
    
    local tt = (self.time/self.startTime)*(self.startTime*60)*1
    local vv = math.floor((tt/60)+1)

    if self.oldvv ~= vv then
        if vv < 3 then
            media.sfx.wood:play()
        end
        
        if vv <= 3 then
            self.camera:shake(25,.1,25)
        end
    end
    local text = "Time: "..vv
    local ss = 5-vv--2.5--4-((tt/60)+1)
    if self.timeout then
        text = "Timeout"
    end
    
    local w = love.graphics.getFont():getWidth(text)*ss
    local h = love.graphics.getFont():getHeight()*ss
    
    love.graphics.print(text, 0+0*w+10,H()-h-10,0,ss,ss)
      

    self.oldvv = vv
    
    
end

function Board:update(dt)
    self.time = self.time - dt
    if self.time <= 0 and self.doTime and not self.nn then--.nn then
        local n = self.current
        if self.choices[tostring(self.loops[n])] then
            local nn = self.choices[tostring(self.loops[n])]
            for x, d in pairs(self.cards) do
                 self.cards[x].angle = 0
                if nn ~= d.data and not d.data.properties.eldritch then
                     
                    self.selectCard(self.cardsUI[x])
                    self.noTouch=2.5
                    self.timer:after(1.5+.5, function()
                        self.noTouch = nil
                    end)
                    
                    
                    self.timeout=true
                    self.nn = true
                end
            end
        else
            self.time = self.startTime
        end
    end
end

return Board