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

local require = old_require or require

if (...) then
  local _PATH = (...):gsub('[^%.]+$','')
  local Matrix = require(_PATH .. 'matrix')
  local random = math.random
  function math.localToAbsoluteReference(point, heading, perp, position)
    return Matrix()
      :rotateFrom(heading, perp)
      :translate(position.x, position.y)
      :transformVec(point)
  end
  
  function math.randomSign()
    return random()>0.5 and 1 or -1
  end
  
  math.tau = 2 * math.pi
  
end