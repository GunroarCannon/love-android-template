local Laser = toybox.Object("Laser")

local function lendir_x(ang, spd)
    return spd*math.cos(ang)
end

local function lendir_y(ang, spd)
    return spd*-math.sin(ang)
end

function Laser:create(k)
        local Dragon = Dragon
        
        self.angle = k.angle or 0
        self.image = "bullets/laserb.png"
        self.maxLength = k.len or 1000
        self.length = self.maxLength
        self.w = k.w or (80/200)*40
        self.h = k.h or (100/200)*40
        self.solid = false
        self.depth=DEPTHS.CREATURES+1000
        --self.debug=4
        self.offset_x = self.w/2
        self.offset_y = self.h/2
        self:center()
        self.ho = 1
        self.ex, self.ey = 0,0
        self.growth = 0
        
        self.target = k.target
        
        self.offsuet_x = self.offset_x - self.w/2
        self.oofy = self.offset_y
        self.offset_y = self.oofy + (self.h/2)*math.sin(self.angle)
        
        self.timer = Chrono()
        self.timer:every({.1,.4,.5,.4},function()
       --      Dragon.spawnPuff(self, self.x, self.y, "white", nil, 30)
            -- Dragon.spawnPuff(self, self.ex, self.ey, "white", nil, 30)
        end)
        self.timer:tween(k.time or 1.3,self,{growth=1},"in-quad")
        
        self.sprite1 = toybox.new_sprite(self, {
            animations = {
                idle = {
                    source = "bullets/laser",
                    useImages = true,
                    delay = .15,
                    mode = "loop"
                }
            }
        })
        
        
        self.sprite2 = toybox.new_sprite(self, {
            animations = {
                idle = {
                    source = "bullets/laser_end",
                    useImages = true,
                    delay = .15,
                    mode = "loop"
                }
            }
        })
        
        
        self.sprite3 = toybox.new_sprite(self, {
            animations = {
                idle = {
                    source = "bullets/laser_end2",
                    useImages = true,
                    delay = .15,
                    mode = "loop"
                }
            }
        })
        
        self._on_collide = k.on_collide
        self.attack = k.attack or 1
        self.noDamage = k.noDamage or {}
        
        self.count = 0
        
        self.debug=1
        self.solid = false
        self.room:must_update(self)
        --self.room:store_instance(self)
end

function Laser:collide(other) log("hey")
    if self.growth>=.9 and self.attack>0 and not self.noDamage[other.id] and (other.isDragon or other.isMan) then
        --other:die()--(self)
    end
    
    if self._on_collide then
        self:_on_collide(other)
    end
    
end

-- function Laser:__check_collision(self,i) return "cross" end

local get = function(i)
    return i.isCreature --i.solid and not i.isProjectile
end

function Laser:update(dt)
        self.sprite1:update(dt)
        --self.sprite2:update(dt)
        self.sprite3:update(dt)
        
        self.doCheck = (self.doCheck or 0)-dt
        
        if self.doCheck <= 0 then
           --  self:play_sound("zzzt",math.random(95,110)/100,.6)
        
        if self.target then
            self.length = lume.distance(self.x, self.y, self.target.x, self.target.y)
            return
        end
        
        self.doCheck = 1/2
        local www = tw*2
        local rad = math.rad(self.angle)
        local llen = self.maxLength*self.growth
        local x,y,w,h = self.world:getRect(self)
        
        local i = 1
        
        local xx = x+w/2 + lendir_x(rad, llen)--self.maxLength)
        local yy = y+h/2 + lendir_y(rad, llen)--self.maxLength)
        
        
        local px, py, pw, ph = self.x,(self.y+self.h/2),self.w or (xx+www),lume.max(math.abs((self.y+self.h/2)-yy),5)
        local items, len, c, k = self.world:queryRect(px, py, pw, ph,get)
        if false then
        local b = toybox.NewBaseObject({solid=false, static=true,w=pw, h=ph,x=px, y=py})
        b.debug = 1
        self.room:after(.1,function() b:destroy() end)
        end
        
        local s

        for x = 1, len do
            local item = items[x]
            if item ~= self and item ~= self.parent_object then
                -- llen = i--lume.distance(self.x+self.w/2, self.y+self.h/2, item.x, item.y)
                self.ex = xx
                self.ey = yy
                self:collide(item)
                s = true
                --break
            end
        end
        if s then
           -- break
        end
        
        local llen2 = 0
        --self.debug=1
        
        self.length = llen--lume.distance(self.x,self.y,self.ex,self.ey)--max(llen2,llen)
        end
end
    
function Laser:draw()
    --if self.time_alive <= 0 then return end
    
    local tw = tw
    local tww = (tw/2)*self.count
    --self.offset_x,
    self.offset_y=self.oofy + (self.h/2)*math.sin((math.rad(self.angle)))
    --self.name_tag = self.angle..","..math.sin((math.rad(self.angle)))
    if self then
        local rad = math.rad(self.angle)
        local xx = self.w
        local iimg = self.sprite1.source-- game:getAsset(self.image)
        local len = math.floor(lume.max(1,math.floor(self.length/self.w)*self.growth))
        
        local v =len~=1 and (math.floor(self.length/self.w)*self.growth)-len or 0 assert(v>=0 and v<1)
        
        len = self.growth ~= 1 and v~= 0 and len + 1 or len
        local xx2 = 0
        for x = 1, len do
            local flicker = 1--math.random(90,110)/100
            local ooy = x and tww or (self.down and tw/2 or 0) or 0
            local oox = 0
            local xx = xx
            
            local img = (x==1 and self.sprite3 or x==len and self.sprite2 or self.sprite1):getCurrentImage()
            local _w, _h = resizeImage(iimg, xx, self.h)
            
            local last_h = x~=len and self.growth~= 1 and v~=0 and _w*v
            local pxx2 = 0
            
            -- if second to the last section then size won't be 100%
            if x == len-1 and last_h then
                -- reposition section
                xx2 = xx*(v)/2-xx/2
                _w = last_h or _w
            elseif x == len - 1 and self.growth ~= 1 and last_h then
                --xx2 = xx2+xx
            end
            
            if x>(len-1) and self.growth~=1 and v then xx2 = xx2-xx*(1-v)/2-0*xx+0*(last_h or 0) end
            
            if x ~= 1 and x~=len then
                love.graphics.draw(game:getAsset("bullets/laserb.png"), self.x+lendir_x(rad, x*xx+xx2)+self.offset_x+oox, 
                self.y+lendir_y(rad, x*xx+xx2)+self.offset_y+ooy, -rad,
                1*_w*(x==1 and -1 or 1), flicker*_h*self.ho,img:getWidth()/2,img:getHeight()/2)
            
            end
            love.graphics.draw(img, self.x+lendir_x(rad, x*xx+xx2)+self.offset_x+oox, ooy+self.y+lendir_y(rad, x*xx+xx2)+self.offset_y, -rad,
            1*_w*(x==1 and -1 or 1), flicker*_h*self.ho,img:getWidth()/2,img:getHeight()/2)
            lg.print(tostring(v).."??", self.room.player.x, self.room.player.y-10)
            end
        if len<2 then
            local x = 1
            local len = 1
            local flicker = math.random(90,110)/100
            local ooy = x and tww --(self.down and t or 0) or 0
            
            local img = (x==len and self.sprite2 or x==1 and self.sprite3 or self.sprite1):getCurrentImage()
            local _w, _h = resizeImage(iimg, xx, self.h)
            
            love.graphics.draw(img, self.x+lendir_x(rad, x*xx)+self.offset_x, 
            self.y+lendir_y(rad, x*xx)+self.offset_y+ooy,
            -rad,
            1*_w*(x==1 and 1 or 1), flicker*_h*self.ho,img:getWidth()/2,img:getHeight()/2)
        end
        --love.graphics.line(self.x+self.w/2,self.y+self.h/2+self.offset_y-self.h/2,self.x+self.w/2+lendir_x(rad, self.length),self.y+self.h/2+lendir_y(rad, self.length))
        
        --love.graphics.line(self.x+self.w/2,self.y+self.h/2,self.ex,self.ey)
    end
end

return Laser