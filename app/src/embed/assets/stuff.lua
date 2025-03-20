--[[consider the folowing problem
maxZ = 10x + 15y
subject to
    5x + 4y <= 200
    3x + 5y <= 150
    8x  + 4y <= 80
    x, y  >= 0]]
    
GRAV = 14
NTrail = req "trail"

dirs8 = {{-1,0},{1,0},{0,1},{0,-1},
{1,1},{1,-1},{-1,-1},{-1,1}
}
dirs4 = {{-1,0},{1,0},{0,1},{0,-1}}

function lendir_x(spd, ang)
    return spd*math.cos(ang)
end

function lendir_y(spd, ang)
    return spd*-math.sin(ang)
end


function multiply_colors(t, color, ...)
    if not color then return t end
    for i = 1, #color do
        t[i] = math.floor((t[i] * 255) * (color[i]*255) / 255 + 0.5)/255
    end
    return multiply_colors(t, ...)
end

VelocityController = LGML.Controller("VelocityController")

local oi = VelocityController.__init__
function VelocityController:__init__(k, ...)
    local k = k or {}
    k.noRjoystick = true
    k.noLjoystick = not toybox.getData("rem").joystick and true or false
    if not toybox.getData("rem").leftJoy then
        self.buttonw = W()*0.0781*(not k.noLjoystick and 1 or 2)
        self.buttonh = W()*0.0781*(not k.noLjoystick and 1 or 2)
    
    
        k. ly = love.graphics.getHeight()-self.buttonw*3/2-20 
        k.   lx = love.graphics.getWidth()-self.buttonw*3/2-20
    end
    
    oi(self, k, ...)
    self.paddy.dpad.buttons = {}
    self.paddy.draw = DESKTOP and null or self.paddy.draw
    local joy = self.paddy. Ljoystick or self.paddy.Rjoystick
    self.joy = self.Ljoystick
    if joy then
        joy:setDigital(false)
        self.joystick = true
        local b = self.paddy.buttons.buttons
        for x, i in ipairs(lume.copy(b)) do
            if i ~= joy then
                lume.remove(b,i)
            end
        end
        self.joy = joy
   end
   
   local j = love.joystick.getJoysticks()
   j =  j and j[1]
   
   if (j and j:isGamepad()) or DESKTOP then
  
    self.baton = baton.new({
        controls = {
            left = {'sc:a', 'key:left', 'axis:leftx-'},--, 'button:dpleft'},
            right = {'sc:d', 'key:right', 'axis:leftx+'},--, 'button:dpright'},
            up = {'sc:w', 'key:up', 'key:space', 'axis:lefty-'},--, 'button:dpup'},
            down = {'sc:s', 'key:down', 'axis:lefty+'},--, 'button:dpdown'},
            --action = {'key:x', 'button:a'},
            action = {"button:a","button:x","key:return"},--{'axis:triggerleft+','axis:triggerright+'},
            ui_left = {'button:dpleft'},--, 'button:x'},
            ui_right = {'button:dpright'},--, 'button:b'},
            ui_up = {'button:dpup'},--, 'button:y'},
            ui_down = {'button:dpdown'},--, 'button:a'},
            pause = {'button:back', 'key:space'},
            back = {'key:escape', 'button:start', 'button:b', 'button:back'},
            
        },
        pairs = {
            move = {'left', 'right', 'up', 'down'},
            ui_move = {'ui_left', 'ui_right', 'ui_up', 'ui_down'}
        },
        
        joystick = love.joystick.getJoysticks()[1],
    })
    
    end


end

function VelocityController:mousepressed(x,y)

    if DESKTOP then
        local x,y = self.room.camera:toWorldCoords( res.getMousePosition(x,y))
        

   
   end
end

function VelocityController:mousereleased(x,y)
    local x,y = self.room.camera:toWorldCoords( res.getMousePosition(x,y))
    
   -- self.Rjoystick.anglee = nil



end

function VelocityController:keypressed(s)
  
end


function VelocityController:keyreleased(s) 
    --if s == "quit" then love.event.quit() end
    
    local v = tonumber(s)
    if v then
        local am = self.room.availableMoves
        if am and am[v] then
            am[v].events.r(am[v])
        end
    end

end
local cam = {x=W()/2,y=H()/2}

local g_deadzone = .5
local function fixV(vx, vy, deadzone)
    
    deadzone = deadzone or g_deadzone
    
    local abx = math.abs(vx)
    local aby = math.abs(vy)
    
    if aby < 1 and aby >= deadzone then
        vy = getDir(vy)
    elseif aby < 1 then
        vy = 0
    end
    
    if abx < 1 and abx >= deadzone then
        vx = getDir(vx)
    elseif abx < 1 then
        vx = 0
    end
    
    return vx, vy
end

function VelocityController:step(dt)
    --love.keyboard.setTextInput(true)
    local vx = self.joy:getXDir()
    local vy = self.joy:getYDir()
    
    local abx = math.abs(vx)
    local aby = math.abs(vy)
    
    local deadzone = .6
    
    if aby < 1 and aby >= deadzone then
        vy = getDir(vy)
    elseif aby < 1 then
        vy = 0
    end
    
    if abx < 1 and abx >= deadzone then
        vx = getDir(vx)
    elseif abx < 1 then
        vx = 0
    end
    
    
    if self.baton and self.baton:down("action") then
        return self.object:slash()--:confirm_ui()
    end
    
    if self.baton then
        local uvx, uvy = self.baton:get("move")
        vx, vy = fixV(uvx, uvy, deadzone)
        -- self.room:move_ui(uvx,uvy)
    end
    
    --self.room:move_ui(vx,vy)
    if self.baton and self.baton:released("back") then
        return (self.room.keypressed or self.room.keyreleased)(self.room, "escape")
    end
    
    local obj = self.object
    local sp = tw*2*.5--(40*(40/16))/1.5
    
    if obj.noControl then
        return
    end
    
    if obj.thrown or obj.died then
        return
    end
    
    --obj.name_tag = vx..","..vy
    local spp = obj.speed or 1
    obj.max_v = math.abs(tw*15)*3--sp*1*(obj.makxVx or 1.5)*100
    local mm = tw*5*spp
    obj.max_vx = tw*5*10*spp*.08
    
    local maxv = obj.max_v
    obj.friction = tw*25
    obj.friction_y = 0
    
    self.lastPressed = (self.lastPressed or 0)+dt
    
    if obj and not obj:isParalyzed() then-- and (vx~=0 or vy~=0) and obj.playing then
        obj.vx, obj.vty = lume.min(lume.max(mm,math.abs(obj.vx)),math.abs(obj.vx+vx*sp*spp))*obj:getDir(obj.vx+vx*sp*spp)*(obj:isConfused() and obj.confusedVx or 1), obj.vy+vy*sp--self.room:moveObject(obj, vx, vy)
        if vx ~= 0 and self.lastPressed>.05 and self.lastPressed<.15 then
            obj:dash()
            self.noMoved = nil
        end
        if vx ~= 0 then
            self.lastPressed = 0
            obj.flipX = vx
        end
        
        self.moved = vx~=0
    end
    
    if vx == 0 then self.noMoved = true end
    
    
    if vy == -1 then
        obj.isDragon = 1
        obj:jump()--.vy = -tw*1
    elseif vy == 1 then
        -- obj:slash()
    end
    
end



TmpMenuTouchController = LGML.Controller("TmpMenuTouchController")

function TmpMenuTouchController:__init__(k, ...)
    local k = k or {}
    k.noRjoystick = true 
    k.noLjoystick = true--toybox.getData("rem").joystick and true or false
    if true then--not toybox.getData("rem").leftJoy then
        self.buttonw = W()*0.0781*(not k.noLjoystick and 1 or 2)
        self.buttonh = W()*0.0781*(not k.noLjoystick and 1 or 2)
    
    
        k. ly = love.graphics.getHeight()-self.buttonw*3/2-20 
        k.   lx = love.graphics.getWidth()-self.buttonw*3/2-20
    end
    
    oi(self, k, ...)
  ---  self.paddy.dpad.buttons = {}
    local joy = self.paddy. Ljoystick or self.paddy.Rjoystick
    self.joy = self.Ljoystick
    if joy then
        joy:setDigital(false)
        self.joystick = true
        local b = self.paddy.buttons.buttons
        for x, i in ipairs(lume.copy(b)) do
            if i ~= joy then
                lume.remove(b,i)
            end
        end
        self.joy = joy
   end
   
   if love.joystick.getJoysticks()[1] or DESKTOP then
   
    self.batoyn = baton.new({
        controls = {
            left = {'sc:a', 'key:left', 'key:a', 'axis:leftx-'},--, 'button:dpleft'},
            right = {'sc:d', 'key:right', 'key:d', 'axis:leftx+'},--, 'button:dpright'},
            up = {'sc:w', 'key:up', 'key:w', 'axis:lefty-'},--, 'button:dpup'},
            down = {'sc:s', 'key:down', 'key:s', 'axis:lefty+'},--, 'button:dpdown'},
            --action = {'key:x', 'button:a'},
            action = {'axis:triggerleft+','axis:triggerright+'},
            ui_left = {'button:dpleft', 'button:x'},
            ui_right = {'button:dpright', 'button:b'},
            ui_up = {'button:dpup', 'button:y'},
            ui_down = {'button:dpdown', 'button:a'},
            pause = {'button:back', 'key:space'},
            
        },
        pairs = {
            move = {'left', 'right', 'up', 'down'},
            ui_move = {'ui_left', 'ui_right', 'ui_up', 'ui_down'}
        },
        
        joystick = love.joystick.getJoysticks()[1],
    })
    
    end

    self.confirm = null
    self.lastPressed = 0

end

function TmpMenuTouchController:onConfirm(f)
    self.confirm = f
    return self
end

function TmpMenuTouchController:keypressed(k)  end

function TmpMenuTouchController:mousepressed(x,y)
    if x<100 and self.lastPressed <= 0 then
        self.lastPressed = .1
        self.confirm()
    end
end

function TmpMenuTouchController:step(dt)
    self.lastPressed = self.lastPressed - dt
    
    local vx = self.joy:getXDir()
    local vy = self.joy:getYDir()
    
    local abx = math.abs(vx)
    local aby = math.abs(vy)
    
    local deadzone = .6
    
    if aby < 1 and aby >= deadzone then
        vy = getDir(vy)
    elseif aby < 1 then
        vy = 0
    end
    
    if abx < 1 and abx >= deadzone then
        vx = getDir(vx)
    elseif abx < 1 then
        vx = 0
    end

    
    self.room:move_ui(vx,vy)

   -- if self.Rjoystick:getXDir()~=0 then self.confirm() end
end


TmpMenuController = LGML.BaseController("TmpMenuController")

function TmpMenuController:__init__(k, ...)
    local k = k or {}
    k.noRjoystick = true 
    k.noLjoystick = true--toybox.getData("rem").joystick and true or false
    if true then--not toybox.getData("rem").leftJoy then
        self.buttonw = W()*0.0781*(not k.noLjoystick and 1 or 2)
        self.buttonh = W()*0.0781*(not k.noLjoystick and 1 or 2)
    
    
        k. ly = love.graphics.getHeight()-self.buttonw*3/2-20 
        k.   lx = love.graphics.getWidth()-self.buttonw*3/2-20
    end
    
    oi(self, k, ...)
  ---  self.paddy.dpad.buttons = {}
    local joy = self.paddy. Ljoystick or self.paddy.Rjoystick
    self.joy = self.Ljoystick
    if joy then
        joy:setDigital(false)
        self.joystick = true
        local b = self.paddy.buttons.buttons
        for x, i in ipairs(lume.copy(b)) do
            if i ~= joy then
                lume.remove(b,i)
            end
        end
        self.joy = joy
   end
   
   
    self.baton = baton.new({
        controls = {
            left = {"sc:a", "key:left",'button:dpleft', 'axis:leftx-','axis:rightx-'},--'sc:a', 'key:left', 'key:a', 'axis:leftx-','},--, 'button:dpleft'},
            right = {"sc:d", "key:right",'button:dpright', 'axis:leftx-',"axis:rightx+"},--'sc:d', 'key:right', 'key:d', 'axis:leftx+',"axis:rightx+"},--, 'button:dpright'},
            up = {"sc:w", "key:up",'button:dpup', 'axis:lefty-',"axis:righty-"},--'sc:w', 'key:up', 'key:w', },--, 'button:dpup'},
            down = {"sc:s", "key:down",'button:dpdown', 'axis:lefty+',"axis:righty+"},--, 'sc:s', 'key:down', 'key:s'},--, 'button:dpdown'},
            confirm = {'button:x', 'button:a'},
            --confirm = {'button:a', 'axis:triggerleft+','axis:triggerright+'},---,'key:enter','key:space'},
            back = {'button:start', 'button:b'},
            pause = {'button:back'},
        },
        pairs = {
            move = {'left', 'right', 'up', 'down'},
            --ui_move = {'ui_left', 'ui_right', 'ui_up', 'ui_down'}
        },
        
        joystick = love.joystick.getJoysticks()[1],
    })

    self.confirm = null
    self.lastPressed = 0

end

function TmpMenuController:onConfirm(f)
    self.confirm = f
    return self
end

function TmpMenuController:keypressed(k)  end

function TmpMenuController:doConfirm(x,y)
    if self.lastPressed <= 0 then
        self.lastPressed = .1
        self.confirm()
    end
end

function TmpMenuController:step(dt)
    self.lastPressed = self.lastPressed - dt
    
    local baton = self.baton
    
    if self.baton and self.baton:down("pause") then
        return self.room.showingAttacks and self.room:removeAttacksDisplay() or
        self.room:showAttacks()
    end
     
    if baton:released("confirm") then
        return self:doConfirm()
    elseif baton:released("back") then
        return (self.room.keypressed or self.room.keyreleased)(self.room, "escape")
    end
    
    local vx, vy = baton:get("move")
   


    
    local abx = math.abs(vx)
    local aby = math.abs(vy)
    
    local deadzone = .6
    
    if aby < 1 and aby >= deadzone then
        vy = getDir(vy)
    elseif aby < 1 then
        vy = 0
    end
    
    if abx < 1 and abx >= deadzone then
        vx = getDir(vx)
    elseif abx < 1 then
        vx = 0
    end

    
    self.room:move_ui(vx,vy)

   -- if self.Rjoystick:getXDir()~=0 then self.confirm() end
end

function nExplode(item,s,c,o)
    Explode(item.x, item.y, s, c, o)
end

local function exp_coll(self, item)
    return "cross"
end

local function exp_on_coll(self, c)
    local obj = c.other
    if (obj.isCreature or obj.isItem or (obj.isTile and obj.solid)) and obj.getAttacked then
        if not self.attackedObj[obj] then
            obj:getAttacked(self)
            self.attackedObj[obj] = true
            if obj.knockback then
                obj:knockback(self:getDir(obj.x-self.x), self:getDir(obj.y-self.y), 4)
            end
        end
    end
end

function Explode(x,y,scale,color,old)
    if type(x) == 'number' then
        local nt = getValue(scale or 1.2)
        local exp = toybox.NewBaseObject({solid=false, static=false, w=tw*nt,h=tw*nt, x =x,y=y})
        exp.depth = DEPTHS.EFFECTS
        local badcol = color == nil or color == "orange" or color == colors.orange or color == "red"
            or color == colors.red
        
        exp.room.exploding = (exp.room.exploding or 0)+1
        exp.light = exp.room:addLight(exp.room:getTileP(x,y),6,color or "yellow")
        exp.attackedObj = {}
        exp.attack = 3
        
        local hh = .7
        exp:set_box(exp.x-exp.w/2, exp.y-exp.h/2, exp.w*hh, exp.h*hh)
        exp:center()
        exp:play_sound("explosion")
        
        exp.sprite = toybox.new_sprite(exp, {
            source = "effects/explosion",--badcol and "explosion2" or not oyld and "explosion" or "effects/explosion",
            delay = .1,
            mode = "once",
            onAnimEnd = function()
                exp:destroy()
                exp.room.exploding = exp.room.exploding - 1
                exp.room:removeLight(exp.light)
                exp.deadd = true
            end
        })
        
        
        exp.color = not badcol and (color or dcolors.fire)
        --exp:play_sound(getRetroDie(),
        --getValue(toybox.room and toybox.room.player and toybox.room.player.pitches))
        
        exp.__check_collision = exp_coll
        exp.on_collide = exp_on_coll
        
        local ending = function()
            exp.on_collide = nil
        end
        
        exp.room:must_draw(exp)
        
        exp.room.timer:after(.6, ending)
        
    else
        local function ex()
            local xx = math.random(x.x, x.x+x.w)
            local xy = math.random(x.y, x.y+x.h)
            Explode(xx, xy,scale,color,old)
        end
        
        local timer = (toybox.room.player or toybox.room).timer
        local t = timer:every(.2,ex)
        
        local can = function()
            timer:cancel(t)
        end
        
        timer:after(y or math.max(x.w,x.h)/tw, can)
    end
end

local function _doSwirl(x,y,c,inc)
    Debris.spawn(x-tw/2 ,y-tw/2, getValue(c or "white"), nil, 30*(inc or 1),nil,nil,nil,nil,nil,3)
end

local function doSwirl(c,inc)
    DEBRIS_ANIM = "setpieces/big_debris"
    for xx = 1,math.random(1,2) do
        _doSwirl(math.random(50,W()-50), math.random(50,H()-50), c, (inc or 1)+30)
    end
    DEBRIS_ANIM = nil
end

function Swirl(color, duration, inc)
    local tag = toybox.room.timer:every(.3, function()
        doSwirl(color, inc)
    end)
    
    toybox.room.timer:after(duration or 3, function()
        toybox.room.timer:cancel(tag)
    end)
end

function lerp(a, b, t)
    return t <.5 and a+(b-a)*t or b-(b-a)*(1-t)
end

function parabola(a, b, t)
    return lerp(a, b, 1-(t*2-1)^2)
end

local light_colors = {"cyan","white","pink","purple"}
function flashLight(time)
    local user = toybox.room
    local timer = user.player and user.player.timer or user.timer
    local l_colors = lume.copy(light_colors)
    toybox.room.background_color = lume.copy(getColor(lume.eliminate(l_colors)))
    timer:tween(time or .2,toybox.room.background_color, getColor(lume.eliminate(l_colors)), "linear",
    function()
        toybox.room.background_color = toybox.room.ogBackgroundColor
    end)
end
    

function lstrike(user, obj, att, color, time)
    local nnn = 4
    local l = Lightning:new({
        x=user.x+0*user.w/nnn,
        y=user.y,user=user,
        gx=obj.offset_x+obj.x+obj.w/nnn,
        gy=obj.y+obj.offset_y+obj.h/nnn+0*tw*.5,
        thickness = LIGHTNING_THICKNESS or 7,
        color=color or type(att) == "string" and att or "yellow"})
    
    l.depth = (user.depth or obj.depth or  DEPTHS.EFFECTS) - .1
    toybox.room:smallShake()
    obj.canMove = false
    obj:play_sound("zap")
    local timer = toybox.room.player and toybox.room.player.timer or toybox.room.timer
    flashLight()
    
    toybox.room:after(time or .3 or .7, function()
        l:destroy()
        obj.canMove = true
        if type(att) == "number" then
            obj:takeDamage(att, user)
        elseif type(att) == "function" then
            att(user, obj)
        end
        toybox.room:smallShake()
    end)    
    
end

function Party(self,t,colorText, pcolors)
    if self.partyColor then
        return
    end
    
    self.partyColor = pcolors and lume.copy(getValue(pcolors)) or lume.copy(colors.purple)

    self.partyTime = t or .5
    
    local old
    if colorText then
        old = self[colorText]
    end
    local room = self.room or toybox.room
    room.timer:every(self.partyTime,function()
        local col = getValue(pcolors or dcolors)
        local count = 5
        while col == self._oldcol_p and count > 0 do
            col = getValue(pcolors or dcolors)
            count = count - 1
        end
        self._oldcol_p = col
        room.timer:tween(self.partyTime,self.partyColor,col)
        if self.party then
            self[colorText or "color"] = self.partyColor
        else
            self.color = old or nil
        end    
    end)
end

Gas = class:extend("Gas")

function Gas:__init__(kwargs)
    self.min_vx = kwargs.min_vx or kwargs.vx or 1
    self.max_vx = kwargs.max_vx or kwargs.vx or -1
    self.min_vy = kwargs.min_vy or kwargs.vy or -30--75
    self.max_vy = kwargs.max_vy or kwargs.vy or -10--75
    
    self.amount = kwargs.amount or 4
    self.on_collide = kwargs.on_collide
    
    self.room = kwargs.room or toybox.room
    
    self.color = kwargs.color
    self.colors = kwargs.colors
    
    self.x = kwargs.x or 0
    self.y = kwargs.y or 0
    self.w = kwargs.w or 8
    self.h = kwargs.h or 1
    
    self.reach = kwargs.reach or 1
    
    self.source = kwargs.source
    
    self.time = 0
    self.sprayInterval = kwargs.sprayInterval or .5
    


    self.room = toybox.room

    self.depth = DEPTHS.EFFECTS
    
    self.id = lume.uuid()
    toybox.room:store_instance(self)
    self.room:must_update(self)
    
end

function Gas:__draw()
end

local bb = function(self, i)
            if i.isDebris or not i.solid then--(i.isEntity or i.isTile) and i.solid then
                return --"cross"
            end
            return "cross"
        end

    sgetVx = function(self,vx) return math.cos(self.time_alive)*vx end
    sgetVy = function(self,vx) return math.sin(self.time_alive)*vx end
function Gas:spray() if self.creature and self.creature.isDead then return end
    local x,y = math.random(self.x,self.w+self.x), self.y--math.random(self.y,self.h+self.y)
    r = self.room--:get_room("level")--currentLevel.name)
    for xx = 1, math.random(self.amount/2,self.amount) do
        local vx = math.random(self.min_vx, self.max_vx)
        local vy = math.random(self.min_vy, self.max_vy)
        local color = getValue(self.colors) or self.color
        local d = Debris:new({noSpin=true,room=r,color=color,life=self.reach ,w=self.w,vx=vx,vy=vy})
        d.ll = self.reach
        d.source = self.source or d.source
        --d.__check_collision = bb
        d.solid=fasle
        --d.bounce = 1.1
       -- d.getVx = sgetVx
        --d.getVy = sgetVy
        d.debujg=1--destroy=function(e) error(e.maxL) end
        r:place_instance(d, x, y)
    end
end

function Gas:destroy()
    self.room.instances[self.id] = nil
    self.room:must_draw(self,true)
end

function Gas:__step(dt)
    self.time = self.time - dt
    if self.time <= 0 then
        self.time = self.sprayInterval
        self:spray()
    end
end

Text = class:extend("Text")

function Text:__init__(x,y,text,color,scale,vy,life,font,angle,alpha,background,backgroundColor)
    
    if type(x) == "table" then
        text = x.text
        y = x.y
        color = x.color
        scale = x.scale
        self.b = x.b
        life = x.life
        vy = x.vy
        font = x.font
        angle = x.angle
        
        alpha = x.alpha
        background = x.background
        backgroundColor = x.backgroundColor
        
        self.center = x.center
        self.font = x.font
        
        x = x.x
        
    end
    
    self.x = x or 0
    self.y = y or 0
    
    self.time_made = love.timer.getTime()
    
    self.text = text or "???"
    self.color = color
    
    self.life = life or 1.4
    self.room = toybox.room
    
    self.vy = vy or -70
    self.vx = 0
    self.depth = DEPTHS.EFFECTS+self.time_made/10000
    
    self.angle = angle or 0
    
    self.dead = .3
    
    self.shake_x = 0
    self.shake_y = 0
    self.horizontal_shakes = {}
    self.vertical_shakes = {}
    self.last_horizontal_shake_amount = 0
    self.last_vertical_shake_amount = 0
    self.id = lume.uuid()
    toybox.room:store_instance(self)
    self.room:must_draw(self)
    self.room:must_update(self)
    self.scale = scale or 1
    self.font = font or nil
    
    self.alpha = alpha or 1
    
    self.background = background
    self.backgroundColor = backgroundColor
    
    self:setText(self.text)
end


function Text:setText(t)
    self.text = t
    self.textParts = {t}--split(self.text, "\n")
    self.datas = {}
    self.offset_x, self.offset_y = 0, 0
    for i, x in ipairs(self.textParts) do
        self.datas[i] = Sentence:new({instant=true,x=self.x-self.offset_x,y=self.y-self.offset_y,w=W(),color=self.color, font=self.font})
        self.datas[i].scale = self.scale*2
        self.datas[i]:newText(x)
        self.text = self.datas[i].shortText
        if self.center then
            self.datas[i].centered = true
        end
    end
end

function Text:draw()
    if self.noDraw then return end

    local s = self.scale
    local fo = love.graphics.getFont()
    local f = self.font or fo
    love.graphics.setFont(f)
    local fw = f:getWidth(self.text)*s
    local fh = f:getHeight( )*s
    
    self.w, self.h =f:getWidth(self.text)*s
    self.h = fh
    
    local x = self.x+(self.w/2-fw/2)*0+self.offset_x*-1*0+self.shake_x
    local y = self.y--+(self.h/2-0/2)+self.offset_y*-1-fh*#self.textParts/2+self.shake_y
    
    for tx = 1, #self.textParts do
        local t = self.textParts[tx]
        local fw = f:getWidth(t)*s
        x = self.x+(self.centerText and (self.w/2-fw/2) or 1)-self.offset_x
        --[[love.graphics.print(t,
        --self.text
         x, y, 0, s, s)]]
        
        local d = self.datas[tx]
        local pd = self.datas[tx-1]
        local s2 = 10*1*(self.w/tw)
        if d and (not pd or pd.done) then d.centered = false
            d.alpha = self.alpha
            d.color = self.color
            
            d.x = self.x--(self.w/2-fw/2)--4*s--self.offset_x+s2*s
            d.y = y-self.offset_y+s*1--fh/2
            d:update(love.timer.getDelta())
            
            d:draw()
            
            if not self.datas[tx+1] then
                self.textDone = true
            end
        end
        
        y = y+fh
    end
    
    
    love.graphics.setFont(fo)
end

function Text:__step(dt)
    
    self.life = self.life-dt
    if self.life <= 0 and not self.noDie then
        self.dead = self.dead-dt
        if self.dead <= 0 then
            self:destroy()
        end
        return
    end
    
    self.y = self.y+self.vy*dt
    self.x = self.x+self.vx*dt
    
    self:check_shake(dt)
end

function Text:destroy()
    self.room.instances[self.id] = nil
    self.room:must_draw(self,true)
end

all = function(t) self:alert(t or "And &colors.green Hey bro #bro ~ what?") end

function Text:__draw()
    local r,g,b,a = love.graphics.getColor()
    local oldFont = love.graphics.getFont()
    
    if self.font then
        love.graphics.setFont(self.font)
    end
    
    
    local ss = self.scale
    local w = love.graphics.getFont():getWidth(string.format("%s%s",self.text,self.b or ""))* ss
    
    local h = love.graphics.getFont():getHeight()*ss
    
    if self.background then
    
        love.graphics.setColor(getColor(self.backgroundColor or self.color or "white",(self.background+self.alpha)/2))
        local nn = 1.2
        draw_rect("fill", self.x-(w*nn-w)*.5, self.y+(h*nn-h)*1, w*nn, h*nn)
        set_color(1,1,1)
        --draw_rect("line", self.x, self.y, w, h)
        
    end
        
    love.graphics.setColor(getColor(self.color or "white",self.alpha))
    
    
    
    
    local rx, ry = self.x+w/2, self.y
    lg.push()
    lg.translate(rx,ry)
    lg.rotate(math.rad(self.angle))
    lg.translate(-rx, -ry)
    
    self:draw()--love.graphics.print(self.text, self.x+self.shake_x, self.y+self.shake_y,0,self.scale,self.scale)
    local ss = self.scale*2
    local n = love.graphics.getFont():getWidth(self.b or "")* ss
    local nn = love.graphics.getFont():getHeight(self.b or "")/2
    love.graphics.print(self.b or "",self.x-n+self.shake_x,self.y-nn+self.shake_y,0,ss,ss)
    
    lg.pop()
    love.graphics.setFont(oldFont)
    love.graphics.setColor(r,g,b,a)
    
end

    
local function newShake(amplitude, duration, frequency)
    local self = {
        amplitude = amplitude or 0,
        duration = duration or 0,
        frequency = frequency or 60,
        samples = {},
        start_time = love.timer.getTime()*1000,
        t = 0,
        shaking = true,
    }

    local sample_count = (self.duration/1000)*self.frequency
    for i = 1, sample_count do self.samples[i] = 2*love.math.random()-1 end

    return self
end

function Text:shake(intensity, duration, frequency, axes)
    if not axes then axes = 'XY' end
    axes = string.upper(axes)

    if string.find(axes, 'X') then table.insert(self.horizontal_shakes, newShake(intensity, duration*1000, frequency)) end
    if string.find(axes, 'Y') then table.insert(self.vertical_shakes, newShake(intensity, duration*1000, frequency)) end

    return self
end

local function updateShake(self, dt)
    self.t = love.timer.getTime()*1000 - self.start_time
    if self.t > self.duration then self.shaking = false end
end

local function shakeNoise(self, s)
    if s >= #self.samples then return 0 end
    return self.samples[s] or 0
end

local function shakeDecay(self, t)
    if t > self.duration then return 0 end
    return (self.duration - t)/self.duration
end

local function move_shake(self, dx, dy)
    self.shake_x = self.shake_x + dx
    self.shake_y = self.shake_y + dy
end

local function getShakeAmplitude(self, t)
    if not t then
        if not self.shaking then return 0 end
        t = self.t
    end

    local s = (t/1000)*self.frequency
    local s0 = math.floor(s)
    local s1 = s0 + 1
    local k = shakeDecay(self, t)
    return self.amplitude*(shakeNoise(self, s0) + (s - s0)*(shakeNoise(self, s1) - shakeNoise(self, s0)))*k
end

local function check_shake(self, dt)
   -- Shake --
    local horizontal_shake_amount, vertical_shake_amount = 0, 0
    for i = #self.horizontal_shakes, 1, -1 do
        updateShake(self.horizontal_shakes[i], dt)
        horizontal_shake_amount = horizontal_shake_amount + getShakeAmplitude(self.horizontal_shakes[i])
        if not self.horizontal_shakes[i].shaking then table.remove(self.horizontal_shakes, i) end
    end
    for i = #self.vertical_shakes, 1, -1 do
        updateShake(self.vertical_shakes[i], dt)
        vertical_shake_amount = vertical_shake_amount + getShakeAmplitude(self.vertical_shakes[i])
        if not self.vertical_shakes[i].shaking then table.remove(self.vertical_shakes, i) end
    end
    self.shake_x, self.shake_y = self.shake_x - self.last_horizontal_shake_amount, self.shake_y - self.last_vertical_shake_amount
    move_shake(self, horizontal_shake_amount, vertical_shake_amount)
    self.last_horizontal_shake_amount, self.last_vertical_shake_amount = horizontal_shake_amount, vertical_shake_amount
    
end

Text.update_shake = updateShake
Text.check_shake = check_shake

--media.load(sfx_data)

do
    local crt = "c"--"comic.ttf"--"cabinsketch.otf"
    cfont = love.graphics.newFont(crt)
    font20 = love.graphics.newFont(crt,H(40))
    font13 = love.graphics.newFont(crt,H(30))
    font8 = love.graphics.newFont(crt,H(20))
    love.graphics.setFont(font8)
    gooi.font = font20
    local style = {
        bgColor = {0,0,0,.5},colors.black,--{176/255,122/255,14/255},-- colors.darkbrown,
        borderColor = colors.white,
        showBorder = true,
        fgColor = colors.white,
        font = font13
    }
    


    gooi.desktopMode()
    gooi.setStyle(style)

    --self:activate_gooi()
end

local langles = {360, -360, 180, -180}
local popFrame = {7,7,6,7,8,9,10,9,9,8,8,8,7,7,7,7,6,5}
local popPitches = {.8, 1.2, 1}

Debris = toybox.Object("Debris")

Debris.create = function(self, p)
    self.va = getValue(p.va) or 300
    local s = 75--p.v or 150
    self.vx = getValue(p.vx or math.random(-s,s))
    self.vy = getValue(p.vy or math.random(-s,s))
    self.isLeaf = p.isLeaf or LEAF_DEBRIS
    self.isDrop = p.isDrop or DROP_DEBRIS
    self.isSmoke = p.isSmoke or SMOKE_DEBRIS
    self.isBubble = p.isBubble or BUBBLE_DEBRIS or BUBBLE_DEBRIS_NORM
    self.normalBubbleV = BUBBLE_DEBRIS_NORM
    
    local time = 
    (self.isLeaf and 7 or self.isSmoke and 4 or self.isDrop and 6 or self.isBubble and 11 or 5)
    +(self.isLeaf and 7 or self.isSmoke and 7 or 2)
    
    self.ll = p.life or .15*time--p.l or 1.
    self.ssource = (self.isSplash and "setpieces/splash" 
    or self.isLeaf and "setpieces/leaf" or self.isSmoke and "setpieces/smoke" or
    self.isDrop and "setpieces/drop" or self.isBubble and "setpieces/bubble" or p.source) --or "debris.png"
    self.sprite = p.sprite ~= false and toybox.new_sprite(self, {
        animations = {
            idle = {
                source = DEBRIS_ANIM or self.ssource or "setpieces/debris",
                delay = self.isSmoke and getValue(20,40)/100 or .15,-- self.ll/time,--.15,
                mode = DEBRIS_MODE or "once",
                onAnimEnd = nil
                    
            }
        }
    })
    
    if  DEBRIS_SOURCE then
        self.source = DEBRIS_SOURCE
        self.sprite.image_alpha = 0
        self.sprite.alpha = 0
    end
    if self.isBubble then
        self.popFrame = getValue(popFrame)
    end
    
    --self.debug = self.isBubble
    self.splashFunc = self.isBubble and function()
                    local obj = toybox.NewBaseObject({
                        solid = false, depth = self.depth,
                        w = self.w, h = self.h, x = self.x, y = self.y
                    })
                    obj.color = self.color
                    obj.__check_collision = null
                    obj.image_alpha = .7
                    obj.sprite = toybox.new_sprite(obj, {
                        source = "setpieces/splash",
                        onAnimEnd = function() obj:destroy() end,
                        delay = .15,
                        mode = "once"
                    })
                    local cv = 3
                    self.x, self.y = self:getRect()
                    self.vx = self.vx/cv
                    self.vy = self.vy/cv
                    obj.vx, obj.vy = self.vx, self.vy
                    obj:offset(self.offset_x, self.offset_y)
                    --obj.debug=1
                    self:play_sound(
                        string.format(
                            "%s%s",math.random()>.4 and "water_step" or "splash",
                            math.random(1,2)
                        ), getValue(popPitches), .7)
                end
                
    self.color = p.color or "white"--red"
    self.w, self.h = getValue(p.w or 10/(40/150))--p.w or 10
    self.h = self.w
    self:set_box()
    self:center()
    self.solid = false
    --self.gravity = 0
    self.depth = DEPTHS.EFFECTS
    self.ll = p.life or .15*time--p.l or 1.2
    self.maxL = self.ll
    if self.isLeaf then
        self.angle = getValue(langles)
        self.flipX = self:getDir(self.angle)
        self.va = 0
    elseif self.isDrop then
        self.va = 0
        self.vx = self.vx*2
        self.vy = self.vy*2
        self.face_direction = true
        self.gravity = 10
    elseif self.isSmoke then
        self.w, self.h = self.w*2, self.h*2
        self.va =0* getValue(langles)
        self.image_alpha = .7
        self.ogw, self.ogh = self.w, self.h
    elseif self.isSplash then
        self.va = 0
        self.vx = 0
        self.vy = 0
    elseif self.isBubble then
        if not self.normalBubbleV then
            self.vy = math.random(-200,-50)
        end
        
        self.va = 0
        self.face_direction = true
        self:play_sound(string.format("bubble%s", math.random(1,2)==1 and "" or "2"), getValue(popPitches), .7)
    end
    self.w = self.w*(p.scale or 1)
    self.h = self.h*(p.scale or 1)
    self.image_alpha = DEBRIS_ALPHA or self.image_alpha
    self.baseA = self.image_alpha
    
    self.vx = self.vx/2 self.vy = self.vy/2
    
    if DEBRIS_IN then
        self.image_alpha = 0
        self.doneIn = 1
        self.doneInVal = 0
        self.room.timer:tween(lume.min(.4,self.ll/10)+.2, self, {image_alpha=DEBRIS_IN,doneIn = 0, doneInVal = DEBRIS_IN})
        
    end
    WALL_T = WALL_T or self.room:getRandomWallTile()
    self.depth = WALL_T.depth-.01
    
    if STORE_DEBRIS then
        STORE_DEBRIS[#STORE_DEBRIS+1] = self
        --self.room:must_draw(self)
    end
    
    self.getVx = p.noSpin and self.getX or function(self,vx) return math.cos(self.time_alive)*5+vx end
    self.getVy = p.noSpin and self.getY or function(self,vx) return math.sin(self.time_alive)*5+vx end
end

function Debris:draw_before()
    if self.room.obj and not self.b then
        local c = self.room.obj
        local w, h = 5, 5
        if ((self.x)<c.x) or (self.x>(c.x+c.w)) or ((self.y)<c.y) or (self.y>(c.y+c.h)) then
           --self.w=self.w*5 self.h=self.h*3 --self:destroy() self.__draw = null
           self.b=1
           self.source = nil
           self.__draw = function(self)
          --     draw_rect("fill",self.x,self.y,self.w,self.h)
            end
        end
        
        local x = self.x + self.vx*(1/15)
        local y = self.y + self.vy*(1/15)
        
        if ((x)<c.x) or (x>(c.x+c.w)) or ((y)<c.y) or (y>(c.y+c.h)) then
           --self.w=self.w*5 self.h=self.h*3 --self:destroy() self.__draw = null
           self.b=1
           self.source = nil
           self.__draw = function(self)
          --     draw_rect("fill",self.x,self.y,self.w,self.h)
            end
        end
    end
end

function Debris:update(dt)
    self.ll = self.ll - dt
    
    if self.doneIn == 0 or not self.doneIn then
        self.image_alpha = (self.isBubble and 1 or (self.ll/self.maxL)<1.5 and (self.ll/self.maxL) or 1)*self.baseA
    end
    self.depth = WALL_T.depth-.01
    
    if self.ogw then
      --  self.w, self.h = self.ogw*(self.ll/self.maxL), self.ogh*(self.ll/self.maxL)
    end
    
    
    if self.room and self.room.obj and self.room.obj.canvas and math.random()>.5 then
        local c = lg.getCanvas()
        lg.setCanvas(self.room.obj.canvas)
        local r,g,b,a = set_color(getColor("crimson",.6))
        local w = math.random(5,7)/(math.random(150,250)/100)
        lg.circle("fill",self.x-w,self.y-w,w)
        set_color(r,g,b,a)
        lg.setCanvas(c)
    end
    
    if self.room.obj and not self.b then
        local c = self.room.obj
        local w, h = 5, 5
        if ((self.x)<c.x) or (self.x>(c.x+c.w)) or ((self.y)<c.y) or (self.y>(c.y+c.h)) then
           --self.w=self.w*5 self.h=self.h*3 --self:destroy() self.__draw = null
           self.b=1
           self.__draw = function(self)
          --     draw_rect("fill",self.x,self.y,self.w,self.h)
            end
        end
        
        local x = self.x + self.vx*(1/15)
        local y = self.y + self.vy*(1/15)
        
        if ((x)<c.x) or (x>(c.x+c.w)) or ((y)<c.y) or (y>(c.y+c.h)) then
           --self.w=self.w*5 self.h=self.h*3 --self:destroy() self.__draw = null
           self.b=1
           self.__draw = function(self)
          --     draw_rect("fill",self.x,self.y,self.w,self.h)
            end
        end
    end
 --   self.debug=1
    if self.ll <= 0 and self.ll < 1000 then
        self:destroy()
    elseif self.ll >= 1000 then
        -- live forever!!! ... kind of
        self.ll = self.ll+dt
        self.image_alpha = self.doneInVal or 1
    end
    
    if self.splashFunc and self.sprite:getCurrentFrame() >=self.popFrame and math.random()>.9 then
     --   self.vx, self.vy = 0,0
        self.splashFunc()
        self.splashFunc = nil
    end
end

Debris.spawn = function(x,y,color,source,n,w,h,vx,vy,life,sc,va)
    r = game.room--:get_room("level")--currentLevel.name)
    for xx = 1, n or DROP_DEBRIS and 10 or SMOKE_DEBRIS and 10 or SPLASH_DEBRIS and 1 or math.random(2,5) do
        local d = Debris:new({
            room=r,
            color = type(color)=="table" and type(color[1])=="string" and getValue(color)
                    or color,
            life=life or nil ,w=w,vx=vx,vy=vy,scale=getValue(sc),va=va
        })
        d.source = source or d.source
        
        r:place_instance(d, getValue(x), getValue(y))
    end
end

spawnDebris = Debris.spawn

function debrisDestroy(self, color)
    spawnDebris(self.x, self.y, color or self.debrisColor or self.color,nil,TW/5,(TH or TW)/5)
end


local effectSize = {.5,.5,1,.7,.8}

local function poisonUpdate(self, dt)
    self.life = (self.life or self.totalLife)-dt
    self.image_alpha = self.life/(self.totalLife/2)
    
    if self.life <= 0 then
        self:destroy()
    end
end

function spawnPoison(obj, scale)
    local x,y,w,h = obj:getRect()
    local size = 160/nn
    local sc2 = getValue(effectSize)
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y+h/2,
        w = size*scale*sc2,
        h = size*scale*sc2,
        solid = false
    })
    
    
    effect.sprite = toybox.new_sprite(effect, {
        animations = {
            idle = {
                source = "setpieces/poison",
                mode = "loop",
                delay = .15
            }
        }
    })
    
    effect.depth = obj.depth+1--DEPTHS.EFFECTS
    effect.vy = -80
    effect.__check_collis5ion = null-- = 0
    
    effect.update = poisonUpdate
    effect.totalLife = 1.2*obj.poisoned*.5
    effect.room:must_update(effect)
    
    return effect
end


local wiggle = function(self, x)
    return math.sin(self.time_alive*100)*10+x
end

function spawnStunStar(obj, scale)
    local x,y,w,h = obj:getRect()
    local size = 160/nn
    local sc2 = getValue(effectSize)
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y+h/2,
        w = size*scale*sc2*.2,
        h = size*scale*sc2*.2,
        solid = false
    })
    
    effect.__check_collision = null
    
    effect.source = math.random()>.3 and "setpieces/star_bright.png" or "setpieces/star_gold.png"
    
    effect.depth = obj.depth+1--DEPTHS.EFFECTS
    effect.vy = -80
    effect.getVx = wiggle
    effect.solid = false
    effect.update = poisonUpdate
    effect.totalLife = 1.2*obj.stunned
    
    return effect
end


function spawnArrow(obj, scale, down, color, source)
    local x,y,w,h = obj:getRect()
    local size = 80/nn
    local sc2 = lume.min(getValue(effectSize),1.2)
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y+h/2,
        w = size*scale*sc2,
        h = size*scale*sc2,
        solid = false,
        source = source or "setpieces/arrow.png"
    })
    
    --effect.face_direction = -180
    effect.__check_collision = null
    
    effect.depth = lume.max(obj.depth+2, DEPTHS.EFFECTS)
    effect.vy = down and 50 or -80
    effect.angle = down and 90 or -90
    effect.color = color
    
    effect.update = poisonUpdate
    effect.totalLife = 1*math.random(8,1)/10
    
    return effect
end

local ogReactions = {"love","rage","kiss","laugh","cry","like","dislike","heart"}
local noFace = {like=true, dislike=true, heart=true}
local scales = {1,1,1,1,.5,.7,.7}
local scales2 = {.1, .1, .2, .3, -.1, -.3, -.2}
local randomVy = {-30,-40}
local randomVx = {-3,-2,0,1,0,0,2,3}

local lives = {1,1.2,.7,1.1}
local times = {1,.3,.2,.5,.4,.1,.7,.5}

local function reactionUpdate(self, dt)
    self.lifeTime = self.lifeTime - dt
    self.image_alpha = self.lifeTime
    if self.lifeTime <= 0 then
        self:destroy()
        return
    end
    
    return (Entity.update or tostring)(self, dt)
end

local function socialReaction(reactions)
    local ep = toybox.room.eProfile
    local x = math.random(ep.x,ep.x+ep.w/1.4)
    local y = ep.y + ep.h/2
    local sc = (getValue(scales)+getValue(scales2))*1.3
    local ww, hh = tw/2, tw/2
    local obj = Entity({
        x = x, y = y,
        w = ww*sc, h = hh*sc,
        solid = false
    })
    
    obj.vy = getValue(randomVy)*1.8
    obj.vx = getValue(randomVx)*3
    
    local source = getValue(reactions or ogReactions)
    if not noFace[source] then
        obj.emo_face = obj:add_image("setpieces/emoji/face.png")
    end
    
    obj.emoji = obj:add_image(string.format("setpieces/emoji/%s.png",source))
    obj.lifeTime = getValue(lives)*5
    
    obj:grow(.6,obj.lifeTime*1.2,"in-quad")
    
    
    obj.update = reactionUpdate
    obj.spawnDebris = null
    obj.__check_collision = null
    
    obj.depth = DEPTHS.EFFECTS+2+obj.time_made/100000
    toybox.room:must_draw(obj)
    toybox.room:must_update(obj)

end

function doReactions(time, reactions, ttimes)
    local r = toybox.room
    local timer = r.player and r.player.timer or r.timer
    
    local function spR()
        return socialReaction(reactions)
    end
    
    return r:every(ttimes or times, spR)
end


local effectSize = {1,.5,2,.5,1,.7,.8}

local function effectUpdate(self, dt)
    self.life = (self.life or self.totalLife)-dt
    self.image_alpha = self.life/(self.totalLife/2)
    --self.y = self.h
    
    if self.life <= 0 then
        self:destroy()
    end
end




local wiggle = function(self, x)
    return math.sin(self.time_alive*100)*5+x
end

function spawnEffect(obj, source, scale)
    local x,y,w,h = obj:getRect()
    local size = tw/1
    local sc2 = getValue(effectSize)
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y,
        w = size*scale*sc2*.2,
        h = size*scale*sc2*.2,
        solid = false
    })
    
    effect.__check_collision = null
    
    effect.source = math.random()>.3 and "setpieces/star_bright.png" or "setpieces/star_gold.png"
    effect.static = false
    effect.depth = obj.depth+1--DEPTHS.EFFECTS
    effect.vy = -th/1.5
    effect.getX = wiggle
    --effect.__step=error
    effect.solid = false
    effect.update = effectUpdate
    effect.totalLife = 1.2*1*.7
    obj.room:must_update(effect)
    obj.room:store_instance(effect)
    return effect
end


local util = {}

util.drawFilledRectangle = function(l,t,w,h, r,g,b,a)
  a = a or 1
  love.graphics.setColor(r,g,b,a-(1-100/255))
  love.graphics.rectangle('fill', l,t,w,h)
  love.graphics.setColor(r,g,b,a)
  love.graphics.rectangle('line', l,t,w,h)
end


util.drawFilledCircle = function(l,t,w,h, r,g,b,a)
  l = l+w/2
  t = t+w/2
  w = w/2
  h = nil
  a = a or 1
  love.graphics.setColor(r,g,b,a-(1-100/255))
  love.graphics.circle('fill', l,t,w,h)
  love.graphics.setColor(r,g,b,a)
  love.graphics.circle('line', l,t,w,h)
end

Puff = toybox.Object('Puff')

local defaultVx      = 0
local defaultVy      = -10
local defaultMinSize = 2
local defaultMaxSize = 10

function Puff:create(k)
  vx, vy = k.vx or defaultVx, k.vy or defaultVy
  minSize = k.minSize or defaultMinSize
  maxSize = k.maxSize or defaultMaxSize
  self.depth = 100
  self.solid = false
  
  local scale = tw/5
  
  self.lifeTime = 0.1 + math.random()
  self.lived = 0
  self.vx, self.vy = vx, vy
  
  if LEAF_DEBRIS then
  self.w, self.h = getValue(minSize, maxSize)*scale
  self.h = self.w

  
    local p = k
    self:center()
    self.isLeaf = p.isLeaf or LEAF_DEBRIS
    self.isDrop = p.isDrop or DROP_DEBRIS
    self.isSmoke = p.isSmoke or SMOKE_DEBRIS
    self.isBubble = p.isBubble or BUBBLE_DEBRIS or BUBBLE_DEBRIS_NORM
    self.normalBubbleV = BUBBLE_DEBRIS_NORM
  
    self.ssource = (self.isSplash and "setpieces/splash" 
    or self.isLeaf and "setpieces/leaf" or self.isSmoke and "setpieces/smoke" or
    self.isDrop and "setpieces/drop" or self.isBubble and "setpieces/bubble" or p.source) --or "debris.png"
    self.sprite = p.sprite ~= false and toybox.new_sprite(self, {
        animations = {
            idle = {
                source = DEBRIS_ANIM or self.ssource or "setpieces/debris",
                delay = self.isSmoke and getValue(20,40)/100 or .15,-- self.ll/time,--.15,
                mode = DEBRIS_MODE or "once",
                onAnimEnd = nil
                    
            }
        }
    })
    else
        self.draw = self.drarw
    end
end

function Puff:expand(dt)
  local cx,cy = self:get_center()
  local percent = self.lived / self.lifeTime
  if percent < 0.2 then
    self.w = self.w + (200 + percent) * dt
    self.h = self.h + (200 + percent) * dt
  else
    self.w = self.w + (20 + percent) * dt
  end

  self.jx = cx - self.w / 2
  self.jy = cy - self.h / 2
  self:set_box()
end

function Puff:update(dt)
  self.lived = self.lived + dt

  if self.lived >= self.lifeTime  then
    self:destroy()
  else
    self:expand(dt)
  end
end

function Puff:getColor()
  local percent = math.min(1, (self.lived / self.lifeTime) * 1.8)
  local c = getColor(self.color or "darkgrey")
  local r,g,b = c[1], c[2], c[3]

  return r,g,b, r - math.floor(155*percent)/355,
         g - math.floor(155*percent)/355,
         b - math.floor(155*percent)/355
end

function Puff:drarw()
  local r,g,b = self:getColor()
  local nn = .8
  util.drawFilledCircle(self.x, self.y, self.w, self.h, r,g,b,lume.min((self.lifeTime/(self.lived*2)),nn))
end


local effectSize = {1,.5,2,.5,1,.7,.8}

local function effectUpdate(self, dt)
    self.life = (self.life or self.totalLife)-dt
    self.image_alpha = self.life/(self.totalLife/2)
    --self.y = self.h
    
    if self.life <= 0 then
        self:destroy()
    end
end




local wiggle = function(self, x)
    return math.sin(self.time_alive*100)*5+x
end

function spawnEffect(obj, source, scale, color, ang, speed, face_dir, noWiggle)
    local x,y,w,h = obj:getRect()
    local size = tw/1
    local sc2 = getValue(effectSize)
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y,
        w = size*scale*sc2*.2,
        h = size*scale*sc2*.2,
        solid = false
    })
    
    effect.__check_collision = null
    
    effect.source = source or math.random()>.3 and "setpieces/star_bright.png" or "setpieces/star_gold.png"
    effect.static = false
    effect.depth = obj.depth+1--DEPTHS.EFFECTS
    effect.vy = speed or -th/1.5
    effect.getX = not noWiggle and wiggle or nil
    
    if face_dir then
        effect.face_direction = true
    end
    
    if ang then
        effect.angle = ang
    end
    
    if color then
        effect.color = color
    end
    
    --effect.__step=error
    
    effect.update = effectUpdate
    effect.totalLife = 1.2*1*.7
    obj.room:must_update(effect)
    obj.room:store_instance(effect)
    return effect
end

function spawnPoison(obj, scale)
    local x,y,w,h = obj:getRect()
    local size = tw
    local sc2 = getValue(effectSize)*lume.min(4,lume.max(2,obj.poisoned^2))/6
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y,--+h/2,
        w = size*scale*sc2,
        h = size*scale*sc2,
        solid = false
    })
    
    effect.__check_collision = null
    
    effect.sprite = toybox.new_sprite(effect, {
        animations = {
            idle = {
                source = "setpieces/poison",
                mode = "loop",
                delay = .15
            }
        }
    })
    
    effect.depth = obj.depth+1--DEPTHS.EFFECTS
    effect.vy = -th/2.5
    
    effect.update = poisonUpdate
    effect.totalLife = 1.2*1.4
    effect.static = false
    
    obj.room:must_update(effect)
    obj.room:store_instance(effect)
    
    return effect
end



function spawnFrost(obj, scale)
    local x,y,w,h = obj:getRect()
    local size = tw
    local sc2 = getValue(effectSize)--*lume.min(4,lume.max(2,obj.poisoned^2))/6
    local scale = scale or obj.isBoss and 2 or 1
    local effect = toybox.NewBaseObject({
        x = math.random(x,x+w),
        y = y,--+h/2,
        w = size*scale*sc2,
        h = size*scale*sc2,
        solid = false
    })
    
    effect.__check_collision = null
    
    effect.source = "snowflake.png"
    
    effect.depth = obj.depth+1--DEPTHS.EFFECTS
    effect.vy = th/2.5
    
    effect.update = poisonUpdate
    effect.totalLife = 1.2*1.4
    effect.static = false
    
    obj.room:must_update(effect)
    obj.room:store_instance(effect)
    
    return effect
end

function spawnTrail(x, y, gx, gy, color, speed)
    local obj = toybox.NewBaseObject({
        x = x,
        y = y,
        w = tw, h = tw,
        solid = false
    })
    
    obj.__check_collision = null
    
    --obj.static = true
    obj.depth = 1000
    
    Trail(obj)
    obj.trailColor = color
    obj.alwaysTrail = true
    obj.trailW = obj.w/2
    
    obj.room:must_update(obj)
    obj.room:must_draw(obj)
    obj.room:store_instance(obj)

    -- obj.debug = 1
    
    
    local function dest2()
        obj:destroy()
    end
    
    
    local function dest()
        obj.room:tween(.7, obj, {trailW=.4,image_alpha=0}, "in-quad", dest2)
    end
    
    obj.room:tween(speed or .5, obj, {x=gx or obj.x, y=gy or obj.y},"in-quad", dest)
    
    return obj
end

return Text