--[[
  Copyright (c) 2012 Roland Yonaba

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local pi = math.pi
local Vec = require 'src.core.vector'
local Integrator = require 'src.core.integrator'

local Agent = {
  pos = Vec(), vel = Vec(), acc = Vec(), maxVel = Vec(100,100),
  forceAccum = Vec(), maxForceAccum = Vec(),
  mass = 1, invMass = 1,
  maxAngRot = pi, integrate = Integrator.verlet
}

Agent.__index = Agent

function Agent:new(x,y)
  local newAgent = {pos=Vec(x,y)}
  return setmetatable(newAgent,Agent)
end

function Agent:update(dt) end

return setmetatable(Agent, 
  {__call = function(self,...) 
    return Agent:new(...) 
end})

