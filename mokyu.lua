local Mokyu = {
  _VERSION     = 'mokyu v0.8.0',
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



local NO_QUAD = 'NO_QUAD'

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

function Sprite:initialize(image, width, height, cols, cells, left, top)
  assertType(width, 'number', 'width')
  assertType(height, 'number', 'height')
  assert(width > 0 and height > 0, 'width and height must be greater than 0.')

  if cols or cells then
    cols = cols or 1
    cells = cells or cols
  elseif cols == nil and cells == nil and left == nil and top == nil  then
    local iw, ih = image:getDimensions()
    cols = math.floor(iw / width)
    cells = cols * math.floor(ih / height)
  end
  assertType(cols, 'number', 'cols')
  assertType(cells, 'number', 'cells')

  left = left or 0
  top = top or 0
  assertType(left, 'number', 'left')
  assertType(top, 'number', 'top')

  self._animations = {}
  self.width  = width
  self.height = height

  return self
    :setImage(image)
    :_initializeQuads(width, height, cols, cells, left, top)
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

function Sprite:_initializeQuads(width, height, cols, cells, left, top)
  local imageWidth, imageHeight = self._image:getDimensions()
  self._quads = {}
  local x, y = 0, 0
  for _ = 1, cells do
    local quad = love.graphics.newQuad(
      x * width  + left,
      y * height + top,
      width,
      height,
      imageWidth,
      imageHeight
    )
    table.insert(self._quads, quad)

    if x < cols - 1 then
      -- Next quad within same row.
      x = x + 1
    else
      -- First quad on next row.
      x = 0
      y = y + 1
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
  self._originY2 = y + h
  return self
end

function Sprite:getAnimations()
  return self._animations
end

do
  local FORMAT_RANGE  = '^(%d+)-(%d+)$'
  local FORMAT_REPEAT = '^(%d+)x(%d+)$'

  function Sprite:addAnimation(name, data)
    local animation = {}
    local loopFrame = 0

    for _, val in ipairs(data) do repeat
      -- BASIC: single frame index; ex: 1
      if type(val) == 'number' then
        table.insert(animation, val)
        break -- continue

      elseif val == 'LOOP' then
        -- LOOP: set loop point
        loopFrame = #animation
        break -- continue
      end

      -- RANGE: Range of frames; ex: "1-5"
      do
        local min, max = val:match(FORMAT_RANGE)
        if min and max then
          min, max = tonumber(min), tonumber(max)
          local step = (min <= max) and 1 or -1
          for i = min, max, step do
            table.insert(animation, i)
          end
          break -- continue
        end
      end

      -- REPEAT: index and number of times; ex: "1x3"
      do
        local index, times = val:match(FORMAT_REPEAT)
        if index and times then
          index, times = tonumber(index), tonumber(times)
          for _ = 1, times do
            table.insert(animation, index)
          end
          break -- continue
        end
      end

      error('Could not parse interval from: ' .. tostring(val))
    until true end

    animation.length = #animation

    -- loopAt must be less than 1.
    loopFrame = math.min(loopFrame, animation.length - 1)
    animation.loopAt = loopFrame / animation.length

    -- Validate that all quads references in animation actually exist.
    local quadCount = #self._quads
    for i = 1, animation.length do
      local quadId = animation[i]
      if quadId % 1 ~= 0 or quadId < 0 or quadId > quadCount then
        error('Sprite:addAnimation() - Invalid quad ID: ' .. tostring(quadId))
      end
    end

    if data.frequency then
      animation.frequency = data.frequency
    elseif data.period then
      animation.frequency = 1 / data.period
    elseif data.frameTime then
      animation.frequency = 1 / (animation.length * data.frameTime)
    else
      animation.frequency = 1
    end

    self._animations[name] = animation

    return self
  end
end

function Sprite:hasAnimation(name)
  assertType(name, 'string', 'animation name')
  return self._animations[name] ~= nil
end

function Sprite:getAnimationDuration(name)
  if self:hasAnimation(name) == false then
    error('No animation with name: ' .. name, 2)
  end
  return 1 / self._animations[name].frequency
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
  self.flipped = false

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
  if self:hasAnimation(animation) == false then
    error('Sprite has no animation named: ' .. animation)
  end

  if self._sprite._animations[animation] == self._animation then
    return self -- SpriteInstances is already using this animation
  end

  self._animation = self._sprite._animations[animation]
  self._animationName = animation

  return self
    :setAnimationPosition(0)
    :resume()
end

function SpriteInstance:getAnimationDuration(name)
  return self._sprite:getAnimationDuration(name)
end

function SpriteInstance:animate(dt)
  if self._status ~= 'playing' then
    return self
  end

  local newPosition = self._animationPosition + (self._animation.frequency * dt)
  if newPosition < 1 then
    self:setAnimationPosition(newPosition)
  else
    local loopAt = self._animation.loopAt
    local pos = ((newPosition - loopAt) % (1 - loopAt)) % 1 + loopAt
    self:setAnimationPosition(pos)
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
    local frame = math.floor(self._animationPosition * self._animation.length) + 1
    local quadNumber = self._animation[frame]
    if quadNumber == 0 then
      self._quad = NO_QUAD
    else
      self._quad = self._sprite._quads[quadNumber]
    end
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

do
  local TAU = math.pi * 2

  function SpriteInstance:setRotation(rotation)
    assertType(rotation, 'number', 'rotation')
    self._rotation = rotation % TAU
    return self
  end
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
  local quad = self:getQuad()
  if quad == NO_QUAD then
    return self
  end

  local sprite = self._sprite
  local scaleX = (self._mirrored == true) and -1 or 1
  local scaleY = (self.flipped == true) and -1 or 1

  -- Round origin differently depending on whether sprite is mirrored or not.
  -- This makes it so that non-integer origins still cause the sprite to have their top, left corner pinned at (x, y).
  local roundedOriginX = self._mirrored
    and (math.ceil(sprite._originX - 0.5) + sprite._originHalfW)
    or (math.floor(sprite._originX + 0.5) + sprite._originHalfW)
  local roundedOriginY = self.flipped
    and (math.ceil(sprite._originY - 0.5) + sprite._originHalfH)
    or (math.floor(sprite._originY + 0.5) + sprite._originHalfH)

  love.graphics.draw(
    sprite._image,
    quad,
    math.floor(x + 0.5) + sprite._originHalfW,
    math.floor(y + 0.5) + sprite._originHalfH,
    self._rotation,
    scaleX,
    scaleY,
    roundedOriginX,
    roundedOriginY
  )

  return self
end

function SpriteInstance:getDrawRect()
  local w, h = self:getDimensions()
  local x = (self._mirrored == true)
    and (self._sprite._originX2 - w)
    or (self._sprite._originX * -1)
  local y = (self.flipped == true)
    and (self._sprite._originY2 - h)
    or (self._sprite._originY * -1)
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
