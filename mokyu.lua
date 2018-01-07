local Mokyu = {
  _VERSION     = 'mokyu v0.3.0',
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



local Sprite = {}
local SpriteMetaTable = {__index = Sprite}

function Mokyu.newSprite(...)
  return setmetatable({}, SpriteMetaTable)
    :initialize(...)
end

function Sprite:initialize(image, width, height, top, left)
  top = top or 0
  left = left or 0
  assert(type(width) == 'number', 'width must be a number')
  assert(type(height) == 'number', 'height must be a number')
  assert(type(top) == 'number', 'top must be a number')
  assert(type(left) == 'number', 'left must be a number')

  self._image = image
  self._animations = {}
  self.width  = width
  self.height = height

  return self
    :setImage(image)
    :_initializeQuads(width, height, top, left)
    :setOriginRect(0, 0, width, height)
    :addAnimation('default', {frequency = 1, 1})
end

function Sprite:getImage(image)
  return self._image
end

function Sprite:setImage(image)
  self._image = image
  return self
end

function Sprite:_initializeQuads(width, height, top, left)
  local imageWidth, imageHeight = self._image:getDimensions()
  local cols = imageWidth / width
  local rows = imageHeight / height

  self.quads = {}
  for y = 0, (rows - 1) do
    for x = 0, (cols - 1) do
      local quad = love.graphics.newQuad(
        x * width  + top,
        y * height + left,
        width,
        height,
        imageWidth,
        imageHeight
      )
      table.insert(self.quads, quad)
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
  data.frequency = data.frequency or 1

  self._animations[name] = data

  return self
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
  self._animationPosition = 0
  self:animate(0) -- Set the quad.
  self._animationName = animation

  return self
end

function SpriteInstance:animate(dt)
  local newPosition = self._animationPosition + (self._animation.frequency * dt)
  if newPosition >= 1 then
    if self._animation.onLoop == 'pauseAtEnd' then
      newPosition = 0.99999
    elseif self._animation.onLoop == 'pauseAtStart' then
      newPosition = 0
    end
  end
  self._animationPosition = newPosition % 1
  local frame = math.floor(self._animationPosition * #self._animation) + 1
  self._quad = self._sprite.quads[self._animation[frame]]

  return self
end

function SpriteInstance:getAnimationPosition()
  return self._animationPosition
end

function SpriteInstance:setAnimationPosition(pos)
  assert(type(pos) == 'number' and pos >= 0 and pos < 1, 'animation position must be a number and >= 0 and < 1.')
  self._animationPosition = pos
  return self
end

function SpriteInstance:getQuad()
  return self._quad
end

function SpriteInstance:isMirrored()
  return self._mirrored
end

function SpriteInstance:setMirrored(mirrored)
  assert(type(mirrored) == 'boolean', 'Mirrored value must be a boolean')
  self._mirrored = mirrored
  return self
end

function SpriteInstance:getRotation(rot)
  return self._rotation
end

local TAU = math.pi * 2

function SpriteInstance:setRotation(rot)
  assert(type(rot) == 'number', 'Rotation value must be a number')
  self._rotation = rot % TAU
  return self
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
    self._quad,
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
