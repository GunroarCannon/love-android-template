local Entity = toybox.Object("Entity")

whiteShader = love.graphics.newShader([[    uniform vec3 col;
    
    vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc) {
        return vec4(col.r,col.g,col.b,color.a * Texel(img, tc).a);
    }]]) --flashc

petrifiedShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total != 3.0) {
    float diff = .5;
	vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
	return vec4(gc, Texel(img, tc).a);
	} else
	return Texel(img, tc);
}
]])--??

monoShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total < 2.0) {
    float diff = 0.0;
	vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
	return vec4(gc, (color.a*Texel(img, tc).a));
	} else
	return vec4(vec3(1.0,1.0,1.0),(color.a*Texel(img, tc).a));
}
]])

redOutlineShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total < 2.0) {
    float diff = 0.0;
	vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
	return vec4(gc, (color.a*Texel(img, tc).a));
	} else
	return vec4(vec3(0.8,0.05,0.05),(color.a*Texel(img, tc).a));
}
]])

goldOutlineShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total < 2.0) {
    float diff = 0.0;
	vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
	return vec4(gc, (color.a*Texel(img, tc).a));
	} else
	return vec4(1,0.843,0,color.a * Texel(img, tc).a);
}
]])


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
    
    
goldShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc) {
        return vec4(1,0.843,0,color.a * Texel(img, tc).a);
    }]])

function reflectAngle(angle)
    local ar = math.rad(angle)
    local x = math.cos(ar)
    local y = math.sin(ar)*-1
    return math.deg(-math.atan2(-y, -x))
end

local absmax = function(n,n2)
    return math.abs(n) > math.abs(n2) and n or n2
end

function Entity:spawnDebris(color, inc)

    local x,y,w,h = self.x, self.y, self.w, self.h
    if self.world:hasItem(self) then
        x,y,w,h = self.world:getRect(self)
    end
    local x,y = self:get_center()
    Debris.spawn(x-tw/2 ,y-tw/2, color or "white", nil, 30*(inc or 1))
end
    
Trail = function(obj,source)
    local tt = 1/10
    
    obj._trail = tt
    
    if nil then
        return
    end
     
    local t = NTrail.new(obj.trailW or obj.w/(obj.isProjectile and 2.5 or 5))
    local s = obj.__step
    function obj:__step(dt)

        if obj.alwaysTrail or self.vx~=0 or self.vy~=0 or self.x-self.old_x+self.y-self.old_y>0 then
            local ww = self.offset_x
            local hh = self.offset_y
            t:trail(ww+self.x ,self.y+hh)
           -- media.sfx.swish2:play()
        end
        s(self,dt)
        t.color = self.trailColor or self.color or t.color
        t:update(dt)
    end
    
    local d = obj.draw_before or null
    obj.draw_before = function(self)
          
        t:draw()
        d(self)
    end
    
    return t
end
   
SmokeTrail = function(obj,source)
    local tt = 1/10
    
    obj._trail = tt
    
    if nil then
        return
    end
     
    local s = obj.__step
    function obj:__step(dt)

        if (obj or self.vx~=0 or self.vy~=0 or self.x-self.old_x+self.y-self.old_y>0) and math.random()>.3
        and not obj.noTrail or obj.alwaysTrail then
            local ww = self.offset_x
            local hh = self.offset_y
            local ww = 90/200*40
        
            _G[obj.trailType or source or 'SMOKE_DEBRIS'] = true
            local i = Debris:new({liyfe=.15*3,sprdite=false,wy=90/nn*1,hh=90/nn*1,source=nol,vx=0,vy=0,noSpin = true,
            color=self.trailColor,
            h = self.smokeH, w = (self.smokeW or tw/5) * math.random(50,150)/100,
            x = self.old_x+obj.w/4-(100/(nn*2))-0/2+math.random(10,10)/10,
            y = self.old_y+0*obj.h/2-(100/(nn*.5*4))+obj.h/4-0+math.random(10,10)/10
            })
            
            
            i.angle = obj.angle
            i.source = nil
            i.debudg=1
            i.va = 0
            
            i.offset_x,i.offset_y =obj.offset_x,obj .offset_y, 0,0
            i.depth = obj.depth-.1
            if obj.postTrail then
                obj.postTrail(i,obj)
            end
            
            _G[obj.trailType or source or 'SMOKE_DEBRIS'] = false
            --[[i.sprite = toybox.new_sprite(i, {
                animations = {
                    idle = {
                        source = "bullets/smoke",
                        delay = .15,
                        mode = "once",
                        useImages = true,
                        onAnimEnd = function()
                            i:destroy()
                        end
                    }
                }
            })]]
            
           -- media.sfx.swish2:play()
        end
        s(self,dt)
    end
end



local shoot = function(self,projectile, delay, wield)
    if type(projectile) == "string" or not projectile.x then
        projectile = self:getBullet(projectile)
    end
    
    if type(delay) == "string" then
        wield = delay
        delay = nil
    end
    
    delay = delay or projectile.delay
    
    if self.LAST_SHOT > 0 then
        projectile.on_destroy = nil
        projectile:destroy()
        return
    end
    
    if projectile.postMake then
        projectile:postMake(self)
    end
    
    local xx,yy,w,h = self.x, self.y, self.w, self.h
    if self.world:hasItem(self) then
        xx,yy,w,h = self.world:getRect(self)
    end
    
    
    if wield then
        local x = 0
        local y = self.h/4
        local px,py,pw,ph = self.x, self,y, self.w, self.h
        
        local we = self.wielding[wield]
        if (self.wielding[wield].doneSquash or 0)<=0.05 then
            local d = lume.max(.2,projectile.delay)
            self.room:squashW(self.wielding[wield], .7, (d/5)*2, nil, {1,(d/5)*3,"out-bounce"})
        end
        log((we.doneSquash or "").."sqq")
        if self.world:hasItem(projectile) then
            px,py,pw,ph = self.world:getRect(projectile)
        end
    
        local ww = self.wielding[wield]
        local x = ww.x or 0
        local y = ww.y or 0
        local obj = toybox.NewBaseObject({x=x, y=y, w = self.ow, h=self.oh})
        obj.solid = false
        obj.flipX = self.flipX
        obj.sprite = toybox.new_sprite(obj, {
            animations = {
                idle = {
                     source = "guns/muzzle_flash",
                     delay = 0.05,
                     mode = "once",
                     useImages = true,
                     onAnimOver = function()
                         obj:destroy()
                     end
                }
            }
        })
        obj.angle = ww.angle or 0--!!!!
        obj.offset_x=0 obj.offset_y=0
        --obj:center()
        if wield == "right" then
            x = projectile.x-self.x+self.flipX*self.w/4+self.w/8+lendir_x(math.rad(projectile.angle),w)--self.w/)
            projectile.flipX = self.flipX
            y = projectile.y-ph/2-yy+h/2+5+lendir_y(math.rad(projectile.angle),h)
            local obj
        elseif wield == "left" then
            x = -self.w/4
        end
        
        projectile:move_to(projectile.x+x, projectile.y+y)
    end
    
    --self.spawnDebris(projectile)
    projectile.team = self.team
    self.LAST_SHOT = delay or .4
    
    if self.gun and self.gun.on_shoot then
        self.gun:on_shoot(self, projectile)
    end
    
    for x = 1, #self.on_shoots do
        self.on_shoots[x](self, projectile)
    end
    
    return true
end


Entity.shoot = shoot

Entity.makeShooter = function(obj)
    --obj.shoot = shoot
    obj.LAST_SHOT = 0
    local o = obj.__step
    function obj:__step(dt) if not self.LAST_SHOT then error(inspect(self,1)) end
        self.LAST_SHOT = self.LAST_SHOT - dt
        o(self,dt)
    end
end

local function bulUpdate(self,dt)
    self.vvx = self.vvx or self.vx
    self.vvy = self.vvy or self.vy
    
    self.vvy = self.vvy
    self.vvx = self.vvx
end

local bulCol = "cross"
local function bulletCollision(bullet, item)
    if item.takeDamage and bullet.time_alive < .07 then return end
    if item.isProjectile then return end
    
    local bulCol = bullet.collisionType or "slide"
    
    if bullet.ignores[item.id] then
        return
    end
    
    if item.solid then return bulCol end
    
    return (item.isCreature or item.isObstacle) and bulCol
end

function Entity.getBullet(parent, source, angle, ac, life, att, w, h, delay, frameDelay, trail, hits, grtAngle)

    local source = bullets[source] or source
    local color, alpha, postMake, bounce, va, shadow
    local attack, mode, smoke, noTrail, bdata, smokeW
    if type(source) == "table" then
        bdata = source
        
        ac = ac or source.ac or 100
        life = life or source.life or 1
        att = att or source.att or 1
        w = w or source.w or source.size or 40
        h = h or source.h or source.size or w
        delay = delay or source.delay
        frameDelay = source.frameDelay or frameDelay
        trail = source.trail or trail
        color = source.color
        alpha = source.alpha or source.image_alpha
        hits = hits or source.hits
        postMake = source.postMake
        bounce = source.bounce
        va = source.va
        getAngle = source.getAngle
        attack = source.attack
        mode = source.mode
        smoke = source.smoke
        smokeW = source.smokeW or tw/3
        noTrail = source.noTrail
        shadow = source.shadow
        
        source = source.anim or source.source
        
    end
    
    getAngle = nil --getAngle or (parent.gun and parent.gun.getAngle)
    
    local noAnim = source:sub(-4, -1) == ".png"
    
    trail = trail or parent.trailBullets
    
    frameDelay = frameDelay or .15
    local self = parent
    
    if type(angle) == "table" then
        angle = self:getAngle(angle)
    elseif not angle and self.target then
        angle = self:getAngle(self.target)
    end
    
    if getAngle then
        angle = getAngle(angle,bul)
    end
    --life=200
    life = (life or 2)+.3
    local bul = toybox.NewProjectile({
        angle = angle,
        ac = getValue(ac),w=w,h=h, x =parent.x, y = parent.y,
        life = life,hits = hits
        
    })
    --bul:ignore(parent)
    
    
    if bdata then
        bul.deflection = bdata.deflection or nil
        bul.attackAllOnBounce = bdata.attackAllOnBounce or nil
        bul.bounceOffset = bdata.bounceOffset or 50
        bul.bounceOn = bdata.bounceOn or nil
        bul.maxBounce = bdata.maxBounce or bul.onBounce and -1 or 0
        bul.hitAmount = bdata.hitAmount or -1
        bul.noCheckBounce = bdata.noCheckBounce
        bul.checkForMaxVelocity = bdata.checkForMaxVelocity
        bul.checkForMinVelocity = bdata.checkForMinVelocity == nil and true or bdata.checkForMinVelocity
    end
    
    bul.noTrail = noTrail
    bul.smoke = smoke
    
    if not bul.noTrail then
        SmokeTrail(bul,bul.smoke)
        bul.smokeW = smokeW
    end
    
    bul.attack = attack or bul.attack
    bul.postMake = postMake or bul.postMake
    bul.bounce = bounce or bul.bounce
    bul.va = va or bul.va
    
    bul.color = color
    bul.image_alpha = alpha or bul.image_alpha
    
    bul.delay = delay or bul.delay
    
   -- Trail(bul)
    bul:set_box(bul.x,bul.y,bul.w/3,bul.h/3)
    bul.offset_y = (bul.h-bul.h/3)/4
    bul.offset_x = (bul.w-bul.w/3)/4

    bul.flipX = parent:get_dir(bul.vx)
    
    -- bul:ignore("wall")
    bul.team = parent.team or parent.isEnemy and "enemy" or parent.uuid
    -- bul.solid=false
    -- bul.debug=true
    bul._on_collide = bul.on_collide
    function bul:on_collide(...)
        local t = {...}
        local o = t[1].other
        t=t[1].touch
        --log("hitt "..(o.name or o.class.name))
        local pow = o.isLiving and not o.invincible
        local vv = 1.1
        local obj = toybox.NewBaseObject({x=t.x, y=t.y, w = self.w*vv, h=self.h*vv})
        obj.solid = false
        obj.sprite = toybox.new_sprite(obj, {
            animations = {
                idle = {
                     source = pow and "effects/pow" or "effects/hit2",
                     delay = (pow and .04 or 0.05)/1.5,
                     mode = "once",
                     useImages = true,
                     onAnimOver = function()
                         obj:destroy()
                     end
                }
            }
        }) assert(self.attack)
        obj.offset_x=0 obj.offset_y=0
        return self._on_collide(self, ...)
    end
    bul.__check_collision = bulletCollision
    
    --bul.life=100
    bul.on_destroy = function()
        --self.spawnDebris(bul)--Explosion(self,true)
    end
    bul.update = bulUpdate
    
    if not noAnim then
        bul.sprite = toybox.new_sprite(bul, {
    
            name = "idle",
            delay = frameDelay,
            source = source,
            useImages = true,
            mode = mode or "loop"
        
        })
    else
        bul.source = source
    end
    
    if trail then
        local t = Trail(bul)
        t.color = type(trail) == "string" and trail or type(trail) == "table" and trail
    end
    --SmokeTrail(bul)
    bul.angle = math.deg(angle)
    bul.attack = att or 1
    bul.att = att or 1
    --bul:set_collision_type("Enemy","cross")
    --bul:set_collision_type("enemy","cross")
    bul.team = parent.team or parent.id
    bul.collision_type = "cross"
    bul:ignore(bul.team)
    bul:ignore("Projectile")
    bul:ignore(parent)
    bul.parent = parent
    bul.depth = DEPTHS.BULLETS or 1
    
    return bul
end


Entity.shootGun = function(self, gun, bullet, angle, ...)
    local gun = guns[gun] or gun
    local obj = self
    if gun then-- (obj.gun._cooldown)<=0 then
        local sa = getValue(gun.shootAmount or 1)
        local a = getValue(gun.shootAngle or 30)
        local angle = gun.angle or type(angle) == "table" and self:getAngle(angle) or angle or 0
        local d_angle = angle
        
        
        
        local shootFrom = nil--"right"--getValue(self.shootFrom)
        
        --if self:ableToShoot(self.target) and self:canShoot() and self.LAST_SHOT <= 0 then
        local bullet = getValue(gun.bullet) or bullet---self:getBulletToShoot()
        
        self:cry(angle.."!! ang")
        if sa>1 then
            for x = 1, math.floor(sa/2) do
                angle = angle - a
            end
        end
        
        --self:spawnDebris()
        local ac = 1-((gun.accuracy or 0.7)*(obj.accuracy or obj.stats.accuracy or 1))
        local deg = 45
        local ang = math.random(-deg*ac,deg*ac)
        for x = 1, sa do
           -- self.timer:after(.1*(x-1)*0,function()
            local bullet = obj:getBullet(bullet, math.rad(angle))--+ang))
            if gun.on_shoot then
                --obj.gun:on_shoot(obj, bullet)
            end
            
            obj:shoot(bullet, shootFrom)
            obj.shotDelay = obj.LAST_SHOT
            if x ~= sa then
                obj.LAST_SHOT = 0
            else
                --self.LAST_SHOT = getValue(self.shootingInterval) or self.LAST_SHOT
            end
            
            angle = angle + a
            --end)
        end
        gun._shots = (gun._shots or 0)+1
        gun._totalShots = (gun._totalShots or 0)+1
        
        if gun.max_shots and gun._shots >= (gun.max_shots) and nil then
            gun._shots = 0
            gun._cooldown = (obj.gun.cooldown or 0)
            gun._shotsLeft = nil
        elseif gun.max_shots then
            gun._shotsLeft = ((gun.max_shots-gun._shots)/gun.max_shots)*100
        end
            

        if shootFrom then
            local w = obj.wielding[shootFrom]
            if w then
                w.angle = d_angle+ang
            end
        end
    end
end

Entity.cry = function(self, text, col, scale, b)
    self.lastCryed, self.cryCooldown = self.lastCryed or 1, self.cryCooldown or .1
    self.toCry = self.toCry or {}
    if self.lastCryed <= self.cryCooldown and (not self.forceCry) then
        if (scale~=true and col~=true) then
            self.toCry[#self.toCry+1] = {text, col, scale, b}
            return
        end
    end
    
    if scale == true then
        scale = nil
    end
    
    if col == true then
        col = nil
    end
    
    self.lastCryed = 0
    local x = self.tiiiile and self.tile.x or self.x
    local y = self.tiiiile and self.tile.y or self.y
    local t = Text:new({
        x = x+self.w/4,
        y = y,
        text = Sentence:new():newText(text).shortText or error(text),
        color = col or self.color,
        scale = (scale or 1)*math.random(90,120)/100,
        b = b or "",
        angle = math.random(-15,15)
    }) t.vy=-50
    return t
end




Entity.speak = function(self, text, col, scale, b)
        
    local t = Text:new({
        x = self.x-self.w/4,
        y = self.y,
        text = text,
        color = col or self.color,
        scale = scale or 2,
        b = b or ""
    })
    return t
end
Entity.getRealRect = function(self)

    
    local x,y,w,h = self.x, self.y, self.w, self.h
    if self.world:hasItem(self) then
        x,y,w,h = self.world:getRect(self)
    end
    
    return x, y, w, h
end

Entity.takeDamage = function(self, dmg, parent, noSkip)
    if self.invincible then return end
    --if self.doneSquash and self.doneSquash>0 then return end
    
    parent.attack = dmg
    dmg = parent
    if not noSkip then
    if true then-- ((self.isProjectile and self.hitProjectiles) or (not self.isPeojectile)) and dmg.team ~= self.team then
            if self then
                --self.room.freeze = .1
            end
            self.life = self.life-(dmg.attack or 1)
            --Text:new(self.x+40, self.y, "Ow")
            
            for x = 1, #self.on_damaged do
                self.on_damaged[x](self, dmg, dmg.attack or 1)
            end
            
            if dmg.on_attack then
                dmg:on_attack(self, dmg.attack or 1)
            end
            
            for x = 1, #(dmg.on_attacks or {}) do
                self.on_attacks[x](dmg, self, dmg.attack or 1)
            end
            
            if not self.isLiving then
                self.spawnDebris(dmg.w and dmg.y and dmg or self)
            end
            
            if self.lifebar then
                self.lifebar.flash = "white"
                self.timer:after(.1,function()
                    self.lifebar.flash = nil
                end)
                
                if self.isPlayer then
                    self.room:smallShake()
                end
            end
            self:apply_impulse(dmg.vx, dmg.vy, true)
            self.ignore_velocity = .1
            dmg.noExplode = true
            self:flash()
            --self.room.camera:shake(25,.2,obj.isPlayer and 40 or 25)
    end
    
    
    
    local x,y,w,h = self.x, self.y, self.w, self.h
    if self.world:hasItem(self) then
        x,y,w,h = self.world:getRect(self)
    end
    
    local function n()
        self.room:squashW(self, 1, .05)
        self:takeDamage(dmg, true)
    end
    
    if self.ow == self.w and (not self.doneSquash or self.doneSquash<=0) then
        self.room:squashW(self, .75, .05, "out-quad", n)
    else
        self:takeDamage(dmg, true)
    end
    
    --Debris.spawn(x+w/2, y+h/2,"white",nil,30)
    
    
    
    else
    if self.life<=0 then
            if dmg.parent == self.room.player and dmg.parent then
                if dmg.parent.soullust and math.random()>.8 then
                    dmg.parent.life = dmg.parent.life+1
                     local self = dmg.parent
                     Debris.spawn(
                     self.x+self.w/2, self.y+self.h/2,"red",nil,30)
                     
                     self:cry(getValue(soullustText))
                end
            end
            self:spawnDebris()
            self.max_vx = 100
            self.max_vy = 100
            --self:apply_impulse(dmg.vx*10, dmg.vy*10)
            self.update = Entity.update
            self.step = null
            self.takeDamage = null
            self.__step = Entity.__step
            self.color="green"
            self.bounce=.5
            self.room.timer:after(0,function()
                self:die(dmg)
            end)
            
            
    end
    end
end
    

local whiteC = {1,1,1}
Entity.checkFlash = function(self,dt)
    if self._flash > 0 then--and not self.dead then
        self._flash = self._flash - (self.dt or 0)
        love.graphics._setBlendMode = love.graphics.setBlendMode
        love.graphics.setBliendMode = null

        if self.flashColor and self.flashColor~="red" then--.flashColor then 
            --love.graphics.setColor(getColor("red" or self.flashColor))
            whiteShader:send("col",getColor(self.flashColor))
        else
            whiteShader:send("col",whiteC)
        end
         
        love.graphics.setShader((self.flashColor=="red" or self.flashRed) and redShader or whiteShader)
         
    end
end

Entity.flash = function(self, t)
    if self._flash<0 then
        self._flash = 0
    end
    self._flash = self._flash + (t or .1)
    
end

function Entity:wield(data, align)
    -- data
    ---- source
    ---- angle
    ---- color
    
    self:unwield(data)
    self:unwield(align or "right")
    
    self.wielding[align or "right"] = data
    self.wieldingItem[data] = align or "right"
    data.w = data.w or self.w
    data.h = data.h or self.h
end

function Entity:unwield(data)
    if type(data) == "string" then
        return self.wielding[data] and self:unwield(self.wielding[data])
    end
    
    if self.wieldingItem[data] then
        self.wielding[self.wieldingItem[data]] = nil
        self.wieldingItem[data] = nil
        
        return data
    end
end

function Entity:draw_before(...)
    local r,g,b,a = love.graphics.getColor()
    self.oldSh = love.graphics.getShader()
    
    self:checkFlash()
    love.graphics.setColor(r,g,b,a)
    
end

Entity._wield = {"right","left","center"}

function Entity:drawWield(wield, align)
    local wieldAngle = math.rad(wield and wield.angle or self.wieldAngle or 0)
    local wieldColor = wield and wield.color or self.wieldColor
    local wieldAlpha = wield and wield.alpha
    
    local source = wield and wield.source
    
    if not source then
        return
    end
    

    local img = game:getAsset(source)
    
    local r,g,b,a = love.graphics.getColor()
    
    love.graphics.setColor(
        getColor(
            wieldColor or self.color or "white",
            ((wieldAlpha or self.image_alpha)+(self.image_alpha))/2
        )
    )
    
    local flipX = self.flipX
    local f= math.abs(math.deg(wieldAngle))
    
    if f>90 and f<270 and wield.flip then
        if (wieldAngle~=0)  then
            -- flipX = -1
        end
    end
    
    local ang = wieldAngle
    
    local obj = self
    
    if (wieldAngle~=0) and wield.fl88ip then
        self.oldF = flipX
        obj.flipX = obj.vx==0 and obj.flipX or obj:getDir(obj.vx)
        if obj.flipX == 0 then
            obj.flipX = 1
        end
        self.flipX = flipX or self.flipX
    end
    
    local source = game:getAsset(self.sprite and self.sprite.source or self.source)
    flipX = self.flipX--self.oldF or flipX
    
    if flipX == -1 then
        ang = math.rad(180-math.deg(ang))*-1
    end
    --self.debug, wield.debug=1,1
    self._w, self._h = resizeImage(source, self.w, self.h)
    local _w, _h = resizeImage(source, wield.w, wield.h)
    local dd = self.draw
    self.draw = null
    if align == "right" then
        --[[love.graphics.draw(img,
            self.x+self.offset_x+(self.flipX == -1 and -self.w*0 or 0)+flipX*self.w/4+self.flipX*(self.wield_x or 0),
            self.y+self.offset_y+(self.flipY == -1 and self.h*0 or 0)+(self.wield_y or 0) ,
            -ang*self.flipX,
            _w*flipX, _h*self.flipY
            ,img:getWidth()/2,--*self.flipX,
            img:getHeight()/2
        )]]
        
        wield.x = self.x+self.offset_x+(self.flipX == -1 and -self.w*0 or 0)
            +flipX*self.w/4+(self.flipX*(self.wield_x or 0))
        wield.y = self.y+self.offset_y+(self.flipY == -1 and self.h*0 or 0)
            +(self.wield_y or 0)
        --wield:redraw()
    
        --self:__draw()
        
    elseif align == "center" then
    
        --[[love.graphics.draw(img,
            self.x+self.offset_x+(self.flipX == -1 and -self.w*0 or 0),
            self.y+self.offset_y+(self.flipY == -1 and self.h*0 or 0) ,
            -ang,
            _w+0*self.flipX, _h*self.flipY
            ,img:getWidth()/2,--*self.flipX,
            img:getHeight()/2
        )]]
        local bx,by,bw,bh = self.room.world:getRect(self)
        
        --wield.angle = wieldAngle
        wield.flipX = self.flipX
        wield.x = not (self.x+self.offset_x+(self.flipX == -1 and -self.w*0 or 0)-wield.offset_x+self.flipX*(wield.wield_x or 0)) or self.flipX==-1 and (self.x+wield.offset_x*self.flipX)--self.flipX*(self.w/2-wield.w/2))
        or (self.x)
        wield.axis_y = wield.h-2
        wield.axis_x = wield.w/2
        wield.y = self.y-self.offset_y--+(self.flipY == -1 and self.h*0 or 0)-wield.offset_y+(wield.wield_y or 0)--+self.flipY*(self.h/2-wield.h/2)
        wield:redraw()
    elseif align == "left" then
        love.graphics.draw(img,
            self.x+self.offset_x+(self.flipX == -1 and -self.w*0 or 0)-flipX*self.w/4,
            self.y+self.offset_y+(self.flipY == -1 and self.h*0 or 0) ,
            -ang,
            _w*flipX, _h*self.flipY
            ,img:getWidth()/2,--*self.flipX,
            img:getHeight()/2
        )
    
        wield.x = self.x+self.offset_x+(self.flipX == -1 and -self.w*0 or 0)-flipX*self.w/4
        wield.y = self.y+self.offset_y+(self.flipY == -1 and self.h*0 or 0)
        self:__draw()
    end
    self.draw = dd
    love.graphics.setColor(r,g,b,a)

end

function Entity:draw(...)
    for x = 1, 3 do
        local wield = Entity._wield[x]
        self:drawWield(self.wielding[wield], wield)
    end
    love.graphics.setShader(self.oldSh)
end

function Entity:create(kwargs)
    self.life = kwargs.life or 0
    self._flash = 0
    
    self.wielding = {}
    self.wieldingItem = {}
    
    self.timer = Chrono()
    self.touched = {}
    
    Entity.makeShooter(self)
    
    local anim = kwargs.animation or kwargs.idle or kwargs.anim
    local anims = kwargs.anims
    
    self.name = kwargs.name or "entity"
    self._name = kwargs._name
    
    self.type = kwargs.type
    self.team = kwargs.team
    
    self.depth = kwargs.depth or (self.static and DEPTHS.STATIC_OBJECTS) or DEPTHS.OBJECTS or 1
    
    self.source = kwargs.source
    
    self.dw = kwargs.dw or 2
    self.dh = kwargs.dh or self.dw or 2
    
    self.ow, self.oh = self.w, self.h
    
    self:set_box(self.x,self.y,self.w/self.dw,self.h/self.dh)
    self:center()
    
    self.toCry = {}
    self.lastCryed = 0
    self.cryCooldown = .2
    self.ignoreProjectiles = kwargs.ignoreProjectiles
    self.invincible = kwargs.invincible
    
    self.rebound = kwargs.rebound or 1
    
    self.inventory = {}
    self.maxInventory = kwargs.maxInventory or 5
    
    self.on_shoots = {}
    self.on_destroys = {}
    self.on_damaged = {}
    self.on_attacks = {}
    self.on_attack = kwargs.on_attack
    self.damageVel = kwargs.damageVel
    self.damageAttack = kwargs.damageAttack
    self.noDamage = kwargs.noDamage or {}
    
    self.attack = kwargs.attack or self.attack or 1
    
    self.trailBullets = kwargs.trailBullets
    
    
    self._on_collide  = kwargs.on_collide or self.checkCollision
    self.step = kwargs.step
    self.__check_collision = kwargs.__check_collision or kwargs.check_collision
    self.corpse = kwargs.corpse
    
    if anim or anims then
        local i = kwargs
        self.sprite = toybox.new_sprite(self,{
            animations = anims or {
                {
                    name = "idle",
                    source = anim,
                    useImages = not kwargs.spritesheet and true or false,
                    delay = kwargs.frameDelay or .15,
                    imageW = kwargs.imageW, imageH = kwargs.imageH,
                    mode = kwargs.mode or "loop",
                    noOfFrames = kwargs.noOfFrames or kwargs.images,
                    qw = i.qw,
                    qh = i.qh,
                    sw = i.imageW or i.imgWidth or i.sw,
                    sh = i.imageH or i.imgHeight or i.sh,
                    frames= i.frames,
                    spritesPerRow = i.spr or i.spritesPerRow,
                },
            
            },
            useImages = not kwargs.spritesheet and true or false
        }):switch("idle")
        
        if NO_ANIMATIONS then
            self.source = game:getAssetName(self.sprite.source)
            self.sprite=nil
        end
    end
    
    local shadow = kwargs.shadow
    
    if shadow then
    
        self.shadowSprite = toybox.new_sprite(self,{
            animations = {
                {
                    name = "idle",
                    source = shadow,
                    useImages = true,
                    delay = kwargs.frameDelay or .15,
                    mode = "loop"
                },
            
            }
        }):switch("idle")
        self:add_sprite(self.shadowSprite)
    end
    
    
    if kwargs.postMake then
        kwargs.postMake(self)
    end
end

function Entity:grow(ratio, time, func)
    self.ow = self.w
    self.oh = self.h
    self.w, self.h = self.ow*ratio, self.oh*ratio
    local oc = self.__check_collision
    local os = self.solid
    local ss = self.static
    local oss = self.step
    self.solid = false
    --self.static = true
    local timer = self.timer or self.room.timer
    
    if os then
    
    local items, len = self.world:queryRect(self:getRect())
    for i = 1, len do if items[i].solid then
        self:ignore_for_now(items[i])
        end

        --log("ignoring for now "..(items[i]._name or items[i].class.name))
    end
    self.step = function()
        for i = 1, len do if items[i].solid then
            --self:ignore_for_now(items[i])
            self._to_ignore[items[i]] = self.time_alive+self.dt
            end
        end
    end
    
    end
    
    timer:tween(time, self, {w=self.ow, h=self.oh}, func or "out-elastic",function()
        self.solid = os
        --self.static = ss
        self.step = oss
        --self.__check_collision = oc
      --  assert(math.floor(self.w)==math.floor(self.ow),self.w..","..self.ow)
    end)
end

local function corpse_check_collision(item, other)
    if not other.solid or other.isProjectile or other.isLiving then
        return
    end
    
    if other.isCorpse then
        return
    end
    
    return "slide"
end

local function corpse_update(self, dt)
  
    local obj = self
    
    local f = (self.friction or 50)*dt
    local fx = lume.absmin(obj:getDir(obj.vx)*f,obj.vx)
    local fy = 0--lume.absmin(obj:getDir(obj.vy)*(self.friction_y or self.friction or 50)*dt,obj.vy)
    
    obj.vx = obj.vx-fx
    obj.vy = obj.vy-fy
    
    if math.abs(obj.vx)<.03 then
        obj.vx = 0
    end
    
    if math.abs(obj.vy)<.03 then
        obj.vy = 0
    end
    
    if self.time_alive > 3 then
      --  self.vy, self.vx =0,0
    end
    
    if lume.max(math.abs(self.vx),math.abs(self.vy))<20 then
        --self.image_alpha = .8
        self._flash = 0
    end
    
    if (self.vy+self.vx) == 0 then
        self.solid = false
        self.static = true
    end
end

local function corpse_collide(self,col)
    if col.other.isTile then
     --   self.vx, self.vy = 0,0
    end
end

function Entity:die(dmg)
    local x, y, w, h = self:getRect()
    local vx, vy = dmg.vx or 0, dmg.vy or 0
    
    if self.corpse then
        local corpse = toybox.NewBaseObject({
            source = self.sprite and game:getImageSource(self.sprite:getCurrentImage()) or self.source or corpse,
            --image_alpha = .8,
            w = self.ow,
            h = self.oh,
            x = self.x,
            y = self.y,
            max_v = 250,
            friction = 25,
            depth = DEPTHS.CORPSES or 1
        })
        corpse.offset_y = corpse.offset_y+Room.o--corpse:set_box(corpse.x, corpse.y, corpse.w, corpse.h)
        
        local sp =0
        local spx = getValue({70,65,30,50})
        local spy = getValue({65,70,30,50})
        corpse:center()
        corpse:set_box(corpse.x, corpse.y, corpse.w/2, corpse.h/2)--corpse.w, corpse.h/1.5)
        corpse:center()
        corpse.isCorpse = true
        corpse:ignore("Entity")--.collision_type = "cross"
        corpse:set_collision_type("Tile","slide")
        --corpse:set_box(x,y,w,h)
        --corpse.solid = false
        corpse.bounce = .2
        corpse.__check_collision = corpse_check_collision
        corpse.on_collide = corpse_collide
        corpse.update = corpse_update
        --corpse.static = true
        --corpse.solid = false
        corpse.vx, corpse.vy = 0,0--self.vx, self.vy--
        corpse:apply_impulse(self:getDir(vx)*spx, self:getDir(vy)*spy)
        corpse.checkFlash = Entity.checkFlash
        corpse.draw_before = Entity.draw_before
        corpse.draw = function() love.graphics.setShader() end
        
        corpse._flash = 1
        corpse.on_bounce=function(self) self.friction = 50 end
    
        local function n()
            self.room:after(.5,function()
            self.room:squashW(corpse, 1, .05)
            --corpse._flash = 0
            end)
        end
        
        self.room.timer:after(.2, function()
            corpse.source = self.corpse
        end)
        
        self.room.timer:tween(.5,corpse, {image_alpha=.8})
    
        self.room:squashW(corpse, .75, .05, "out-quad", n)
    end
    
    
    if self.on_die then
        self:on_die(dmg)
    end
    
    self:destroy()
end

function Entity:addOnDestroy(func)
    self.on_destroys[#self.on_destroys+1] = func
end

function Entity:addOnShoot(func)
    self.on_shoots[#self.on_shoots+1] = func
end

function Entity:addOnAttack(func)
    self.on_attacks[#self.on_attacks+1] = func
end

function Entity:addOnDamaged(func)
    self.on_damaged[#self.on_damaged+1] = func
end

function Entity.col_ignore(n)
    return not n.static and n.solid and not n.isTile
end
    
function Entity:getTarget(except, targeyTypes)
    local targetTypes = targetTypes or self.targetTypes or {}
    
    local tile = self.room:getTileP(self.x,self.y)
    local room = tile and tile.parent
    if tile then
        local objects, len = self.world:queryRect(
            room.x, room.y,
            room:getW(), room:getH(),
            self.col_ignore
        )
        local closest, obj
        for x = 1, len do
            local ent = objects[x]
            local targ
            
            for i, x in pairs(targetTypes) do
                if ent[i] and x and not targ then
                    targ = true
                elseif ent[i] and not x then
                    targ = false
                    break
                elseif x and not ent[i] then
                    targ = false
                    break
                end
            end
            
            targ = (targ == nil and true) or targ
            
            if ent ~= self and ent ~= except and ent.isEntity and targ and ent.team~=self.team then
                local dis = lume.distance(self.x, self.y, ent.x, ent.y)
                if not obj or dis<closest then
                    obj = ent
                    closest = dis
                end
            end
        end
            
        if obj then
            return obj
        end
    end
end

function Entity:addItem(item)
    if #self.inventory >= self.maxInventory then
        return false
    end
    
    self.inventory[#self.inventory+1] = item
    self.currentItemIndex = #self.inventory
    item.parent = self
    item:destroy()
    
    self:carryItem()
    
    return true
end

function Entity:carryItem(index)
    local index = index or self.currentItemIndex
    self.currentItemIndex = index
    
    local item = self.inventory[index]
    local w = {
        source = item.source
    }
    self:wield(w, "left")
end

local function checkMelee(item)
    return item.isEntity
end

function Entity:doMeleeDamage(x,y,w,h,val,check)
    if w <= 0 then
        w = 45
    end
    if h <= 0 then
        h = 45
    end
    
    if not self.world:hasItem(self) then
        return false
    end
    
    local items, len = self.world:queryRect(x,y,w,h,check or checkMelee)
    local val = val or self.attack or self.att
    local att = self.attack
    self.attack = val
    
    for i = 1, len do
        local item = items[len]
        if item == self then
            len = len-1
        else
            item:apply_impulse(
                self:getDir(item.x-self.x)*400,
                self:getDir(item.y-self.y)*400
            )
            item:takeDamage(self)
        end
    end
    
    self.attack = att
    
    return len>0
        
end

function Entity:on_collide(o)
    local other = o.other
    local doit = not self.touched[o.other.id]
    
    if o.type ~= "cross" then
        if doit then--or (math.abs(other.vx))<math.abs(self.vy) then
            other:apply_impulse_y(self.vy*self.rebound)
        end
    
        if doit then-- (math.abs(other.vy))<(math.abs(self.vx)) then--+math.abs(self.vy)) then
            other:apply_impulse_x(self.vx*self.rebound)--, self.vy)
        end
    end
    
    if other.takeDamage and self.damageVel and (math.abs(self.vx)+math.abs(self.vy))>=self.damageVel and not self.noDamage[other.class.name] and not self.noDamage[other._name] and
    not self.noDamage[other.id] and not self.noDamage[other.team] and not self.noDamage[other.type] then
        local a = self.attack
        self.attack = self.damageAttack or a or 1
        other:takeDamage(self)
        self.attack = a
    end
    
    self.touched[o.other.id] = .05
    
    if self._on_collide then
        self:_on_collide(o, o.other)
    end
end

local olde = Entity.destroy
function Entity:destroy(att)
    if self.firstTile then
        lume.remove(self.firstTile.parent.enemies, self)
    end
    
    if self.debrisType then
        _G[self.debrisType] = true
    end
    
    --self.spawnDebris(self.tile or self.target or self)
    
    if self.debrisType then
        _G[self.debrisType] = nil
    end
    
    local source = string.format("effects/scorch_%d.png",math.random(1,2))
    if self.tile or self.scorch then
        local t = self.tile or self.target or self.room:getTileP(self.x,self.y)
        if t then
        local i = t:add_image(source)
        i.color = {1,1,1,.8}
        self.room.timer:tween(45,i.color,{[4]=.01})
        end
    elseif nil then
    
    local x, y, w, h = self:getRect()
    local ent = toybox.NewBaseObject({
        x = x+w/2,
        y = y+h/2,
        w = 54/1.8,--80/200*Room.t*1.5,
        h = 54/1.8,--80/200*Room.t*1.5,
        static = true,
        depth = DEPTHS.SCRATCHES,
        source = source,
        
        image_alpha = .8
    })
    --ent:center()
    --self.room.scorches[#self.room.scorches+1] = ent
    
    self.room.timer:tween(60, ent, {image_alpha = .3})
    end
    
    if self.on_destroy then
        self:on_destroy(att)
    end
    
    for x = 1, #self.on_destroys do
        self.on_destroys[x](self, att)
    end
    
    if self.fire then
        self.fire:destroy()
    end
    
    self.isDead = 1
    
    olde(self)
end

function Entity:update(dt)
    for x, i in pairs(self.touched) do
        self.touched[x] = i-dt
        if self.touched[x] <= 0 then
            self.touched[x] = nil
        end
    end
    
    self.lastCryed = self.lastCryed + dt 
    
    if self.lastCryed > self.cryCooldown and #self.toCry > 0 then
        local vals = table.remove(self.toCry, 1)
        self:cry(vals[1], vals[2], vals[3], vals[4], vals[5])
    end
    
    local obj = self
    
    local f = (self.friction or 50)*dt
    local fx = lume.absmin(obj:getDir(obj.vx)*f,obj.vx)
    local fy = lume.absmin(obj:getDir(obj.vy)*f,obj.vy)
    
    obj.vx = obj.vx-fx
    obj.vy = obj.vy-fy
    
    if math.abs(obj.vx)<.03 then
        obj.vx = 0
    end
    
    if math.abs(obj.vy)<.03 then
        obj.vy = 0
    end
    
    if obj.attached then
        obj.vx = 0
        obj.vy = 0
        
        local a = obj.attached
        --obj:move_to
        self.x, self.y = self.__move(self,a.x+self.ax, a.y+self.ay,dt)--obj.y+a.y-a.old_y)
    end
end

local os = Entity.__step
function Entity:__step(...)
    os(self, ...)
    if self.rotating then
    
        local e = self.rotating
        self.x= self.x+(e.x-e.old_x)--e.x--*dt
        if self.world:hasItem(self) then
            self:move_to(self.x,self.y+(e.y-e.old_y))
        end
        if self.agent then
            self:updateAgentPos()
        end
    end
end


function Entity:rotateAround(other, speed, radius)
    self.rotating = other
    radius = radius or other.w
    speed = speed or 30
    self.ge5tVx = function(self,v)
        local dir = math.cos(self.time_alive)*radius
        local vel = dir+v-other.vx/5--+math.cos(self.time_alive)*radius+other.vx
        if other.vx~=0 and other:getDir(other.vx)~=self:getDir(vel) and math.abs(other.vx) > math.abs(vel) then
            ivel = vel-(vel+other.vx)
        end
        
        return dir
    end
    
    self.getV_y = function(self, v)
        local dir = math.sin(self.time_alive)*radius
        local vel = dir+v-other.vy/5--+math.sin(self.time_alive)*radius+other.vy
        if other.vy~=0 and other:getDir(other.vy)~=self:getDir(vel) and math.abs(other.vy)>math.abs(vel) then
            veil = vel-(vel+other.vy)
        end
        
        return dir
    end
    dir = 0
    self.step = function(self, dt)
        dir= dir + speed*dt
        self:move_to(other.x+lendir_x(math.rad(dir), 40), other.y+lendir_y(math.rad(dir), 40))
    end
    self:ignore("Tile")
    self:ignore(other)
    self.solid = false
    self.collision_type = "cross"
end

function Entity:attachTo(obj)
    if self.attached then
        self:detach()
    end
    self.attached = obj
    --self.move = function(x,u) return x, u end
    obj:ignore(self)
    self:ignore(obj)
    self._ogSolid = self.solid
    self.solid = false

    local x,y,w,h = self.world:getRect(obj)
    local xx,yy,ww,hh = self.world:getRect(self)
    obj._oww, obj._ohh, obj._offx, obj._offy = w,h,obj.offset_x, obj.offset_y
    
    local nw = w+math.abs(x+w-(xx+ww))
    local nh = h+math.abs(y+h-(yy+hh))
    obj:set_box(x-(self.x<obj.x and (nw-w) or 0),y-(self.y>obj.y and 0*(nh-h) or 0),nw,nh)
    self.x = xx+(self.x>obj.x and (0) or (x+w-(xx+ww)))
    self.y = yy+(self.y>obj.y and 0 or hh*(h/nh))-- or (0))
    self:set_box(self.x, self.y, ww, hh)
    
    self.ax, self.ay = self.x-obj.x, self.y-obj.y
    --toybox.debug=4
    local xt = (x+w-(xx+ww))
    if self.x<obj.x then
    obj.offset_x = obj.offset_x+(x+w-(xx+ww))
    end
    if self.y<obj.y then
        obj.offset_y = obj.offset_y+h*(h/nh)--0*(y+h-(yy-hh))
    end
    --obj.debug=4

    self.__move=function(s,x,y) return x,y,self.x, self.y end
    self.sjet_box = nil
    
    return obj
end

function Entity:detach(noSolid)
    if not self.attached then
        return
    end
    if type(noSolid) == "number" then
        self.attachTo = tostring
        local func = function()
            self.solid = self._ogSolid
            self.attachTo = nil
        end
        
        self.room:after(noSolid, func)
    else
            
        self.solid = not noSolid
    end
    self.solid=true
    local obj = self.attached
    
    local x,y,w,h = self.world:getRect(obj)
    local xx,yy,ww,hh = self.world:getRect(self)
    obj:set_box(x,y,obj._oww, obj._ohh)
    --toybox.debug=4
    obj.offset_x = obj._offx
    obj.offset_y = obj._offy
    obj._oww, obj._ohh, obj._offx, obj._offy = nil
    
    self.attached:no_ignore(self)
    self:no_ignore(self.attached)
    self.attached = nil
    self.__move = nil
    

end

function Entity:wieldGun(gun, noBullets)
    local gun = lume.copy(gData.guns[gun] or gun)
    self.gun = gun
    self.gun.flip = true
    self:wield(gun, gun.wield or "right")
    
    if not noBullets then
        self.bullet = self.gun.bullet
    end
end

function Entity:shootLaser(dir)
  --[[local l = laser:new({angle = dir,x=self.x,y=self.y})
    self.room:must_update(l)
    l:attach_parent(self)
    --self.room:tween(10,l,{ho=0})
    self._l = l
    ]]
end

    
return Entity