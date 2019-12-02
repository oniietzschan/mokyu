local Mokyu = {
  _VERSION     = 'mokyu v0.6.0',
  _URL         = 'https://github.com/oniietzschan/mokyu',
  _DESCRIPTION = 'A library to handle sprite manipulation and animation in Love2D.',
  _LICENSE     = [[
    Massachusecchu... あれっ！ Massachu... chu... chu... License!

    Copyright (c) 1789 shru

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 【AS IZ】, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. PLEASE HAVE A FUN AND BE GENTLE WITH THIS SOFTWARE.
  ]]
}



local function assertType(obj, expectedType, name)
  assert(type(expectedType) == 'string' and type(name) == 'string')
  if type(obj) ~= expectedType then
    error(name .. ' must be a ' .. expectedType .. ', got: ' .. tostring(obj), 2)
  end
end



local Sprite = {}
local SpriteMetaTable = {__index = Sprite}

function Mokyu.newSprite(...)
  return setmetatable({}, SpriteMetaTable)
    :initialize(...)
end

function Sprite:initialize(image, width, height, cols, rows, left, top)
  assertType(width, 'number', 'width')
  assertType(height, 'number', 'height')
  assert(width > 0 and height > 0, 'width and height must be greater than 0.')

  if cols or rows then
    cols = cols or 1
    rows = rows or 1
  elseif cols == nil and rows == nil and top == nil and left == nil then
    local iw, ih = image:getDimensions()
    cols = math.floor(iw / width)
    rows = math.floor(ih / height)
  end
  assertType(cols, 'number', 'cols')
  assertType(rows, 'number', 'rows')

  top = top or 0
  left = left or 0
  assertType(left, 'number', 'left')
  assertType(top, 'number', 'top')

  self._image = image
  self._animations = {}
  self.width  = width
  self.height = height

  return self
    :setImage(image)
    :_initializeQuads(width, height, cols, rows, left, top)
    :setOriginRect(0, 0, width, height)
    :addAnimation('default', {frequency = 1, 1})
end

function Sprite:getImage()
  return self._image
end

function Sprite:setImage(image)
  self._image = image
  return self
end

function Sprite:_initializeQuads(width, height, cols, rows, left, top)
  local imageWidth, imageHeight = self._image:getDimensions()
  self._quads = {}
  for y = 0, (rows - 1) do
    for x = 0, (cols - 1) do
      local quad = love.graphics.newQuad(
        x * width  + left,
        y * height + top,
        width,
        height,
        imageWidth,
        imageHeight
      )
      table.insert(self._quads, quad)
    end
  end

  return self
end

function Sprite:getOriginRect()
  return self._originX,
         self._originY,
         self._originW,
         self._originH
end

function Sprite:setOriginRect(x, y, w, h)
  self._originX = x
  self._originY = y
  self._originW = w
  self._originH = h
  self._originHalfW = self._originW / 2
  self._originHalfH = self._originH / 2
  self._originX2 = x + w
  return self
end

function Sprite:getAnimations()
  return self._animations
end

function Sprite:addAnimation(name, data)
  local animation = {
    frequency = data.frequency or 1,
    onLoop = data.onLoop,
  }

  for _, interval in ipairs(data) do
    local min, max, step = self:_parseInterval(interval)
    for i = min, max, step do
      table.insert(animation, i)
    end
  end

  self._animations[name] = animation

  return self
end

function Sprite:_parseInterval(val)
  if type(val) == 'number' then
    return val, val, 1
  end
  val = val:gsub(' ', '')
  local min, max = val:match('^(%d+)-(%d+)$')
  assert(min and max, 'Could not parse interval from: ' .. tostring(val))
  min, max = tonumber(min), tonumber(max)
  local step = (min <= max) and 1 or -1
  return min, max, step
end

function Sprite:hasAnimation(animation)
  return self._animations[animation] ~= nil
end

function Sprite:getWidth()
  return self.width
end

function Sprite:getHeight()
  return self.height
end

function Sprite:getDimensions()
  return self.width, self.height
end



local SpriteInstance = {}
local SpriteInstanceMetaTable = {__index = SpriteInstance}

function Sprite:newInstance()
  return setmetatable({}, SpriteInstanceMetaTable)
    :initialize(self)
end

function SpriteInstance:initialize(sprite)
  self._sprite = sprite
  self._mirrored = false

  return self
    :setAnimation('default')
    :setRotation(0)
end

function SpriteInstance:getAnimations()
  return self._sprite:getAnimations()
end

function SpriteInstance:getAnimation()
  return self._animationName
end

function SpriteInstance:hasAnimation(animation)
  return self._sprite:hasAnimation(animation)
end

function SpriteInstance:setAnimation(animation)
  assert(self:hasAnimation(animation) == true, 'Sprite has no animation named: ' .. animation)

  if self._sprite._animations[animation] == self._animation then
    return self -- SpriteInstances is already using this animation
  end

  self._animation = self._sprite._animations[animation]
  self._animationName = animation

  return self
    :setAnimationPosition(0)
    :resume()
end

function SpriteInstance:animate(dt)
  if self._status ~= 'playing' then
    return
  end

  local newPosition = self._animationPosition + (self._animation.frequency * dt)
  self:setAnimationPosition(newPosition % 1)

  local onLoop = self._animation.onLoop
  if newPosition >= 1 and onLoop then
    local fn = (type(onLoop) == 'function') and onLoop or self[onLoop]
    fn(self)
  end

  return self
end

function SpriteInstance:getAnimationPosition()
  return self._animationPosition
end

function SpriteInstance:setAnimationPosition(pos)
  assert(type(pos) == 'number' and pos >= 0 and pos < 1, 'animation position must be a number and >= 0 and < 1.')
  self._animationPosition = pos
  self._quad = nil
  return self
end

function SpriteInstance:getQuad()
  if self._quad == nil then
    local frame = math.floor(self._animationPosition * #self._animation) + 1
    self._quad = self._sprite._quads[self._animation[frame]]
  end
  return self._quad
end

function SpriteInstance:isMirrored()
  return self._mirrored
end

function SpriteInstance:setMirrored(mirrored)
  assertType(mirrored, 'boolean', 'mirrored')
  self._mirrored = mirrored
  return self
end

function SpriteInstance:getRotation()
  return self._rotation
end

local TAU = math.pi * 2

function SpriteInstance:setRotation(rotation)
  assertType(rotation, 'number', 'rotation')
  self._rotation = rotation % TAU
  return self
end

function SpriteInstance:resume()
  self._status = 'playing'
  return self
end

function SpriteInstance:pause()
  self._status = 'paused'
  return self
end

function SpriteInstance:pauseAtStart()
  self._animationPosition = 0
  return self:pause()
end

function SpriteInstance:pauseAtEnd()
  self._animationPosition = 0.99999
  return self:pause()
end

function SpriteInstance:draw(x, y)
  local sprite = self._sprite
  local scaleX = (self._mirrored == true) and -1 or 1

  -- Round origin differently depending on whether sprite is mirrored or not.
  -- This makes it so that non-integer origins still cause the sprite to have their top, left corner pinned at (x, y).
  local roundedOriginX
  if self._mirrored then
    roundedOriginX = math.ceil(sprite._originX + sprite._originHalfW - 0.5)
  else
    roundedOriginX = math.floor(sprite._originX + sprite._originHalfW + 0.5)
  end
  local roundedOriginY = math.floor(sprite._originY + sprite._originHalfH + 0.5)

  love.graphics.draw(
    sprite._image,
    self:getQuad(),
    math.floor(x + sprite._originHalfW + 0.5),
    math.floor(y + sprite._originHalfH + 0.5),
    self._rotation,
    scaleX,
    1,
    roundedOriginX,
    roundedOriginY
  )

  return self
end

function SpriteInstance:getDrawRect()
  local w, h = self:getDimensions()
  local x
  if self._mirrored then
    x = self._sprite._originX2 - w
  else
    x = self._sprite._originX * -1
  end
  local y = self._sprite._originY * -1
  return x, y, w, h
end

function SpriteInstance:getSprite()
  return self._sprite
end

function SpriteInstance:getWidth()
  return self._sprite:getWidth()
end

function SpriteInstance:getHeight()
  return self._sprite:getHeight()
end

function SpriteInstance:getDimensions()
  return self._sprite:getDimensions()
end



return Mokyu
