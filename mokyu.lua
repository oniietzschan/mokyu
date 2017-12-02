local Mokyu = {}



local rng = love.math.newRandomGenerator()



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
  self.animations = {}
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

function Sprite:setOriginRect(x, y, w, h)
  self._originX = x
  self._originY = y
  self._originX2 = x + w
  self._originY2 = y + h
  return self
end

function Sprite:addAnimation(name, data)
  data.frequency = data.frequency or 1

  self.animations[name] = data

  return self
end

function Sprite:hasAnimation(animation)
  return self.animations[animation] ~= nil
end

function Sprite:getWidth()
  return self.width
end

function Sprite:getHeight()
  return self.height
end

function Sprite:getOriginRect()
  return self._originX,
         self._originY,
         self._originX2 - self._originX,
         self._originY2 - self._originY
end



local SpriteInstance = {}
local SpriteInstanceMetaTable = {__index = SpriteInstance}

function Sprite:newInstance()
  return setmetatable({}, SpriteInstanceMetaTable)
    :initialize(self)
end

function SpriteInstance:initialize(sprite)
  self._sprite = sprite
  self.mirrored = false

  return self
    :setAnimation('default')
end

function SpriteInstance:hasAnimation(animation)
  return self._sprite:hasAnimation(animation)
end

function SpriteInstance:setAnimation(animation)
  assert(self:hasAnimation(animation) == true, 'Sprite has no animation named: ' .. animation)

  if self._sprite.animations[animation] == self.animation then
    return self -- SpriteInstances is already using this animation
  end

  self.animation = self._sprite.animations[animation]
  self.animationPosition = 0
  self:animate(0) -- Set the quad.
  self.animationName = animation

  return self
end

function SpriteInstance:animate(dt)
  local newPosition = self.animationPosition + (self.animation.frequency * dt)
  if newPosition >= 1 then
    if self.animation.onLoop == 'pauseAtEnd' then
      newPosition = 0.99999
    elseif self.animation.onLoop == 'pauseAtStart' then
      newPosition = 0
    end
  end
  self.animationPosition = newPosition % 1
  local frame = math.floor(self.animationPosition * #self.animation) + 1
  self.quad = self._sprite.quads[self.animation[frame]]

  return self
end

function SpriteInstance:getAnimationName()
  return self.animationName
end

function SpriteInstance:setRandomAnimationPosition(pos)
  self:setAnimationPosition(rng:random())
  return self
end

function SpriteInstance:setAnimationPosition(pos)
  self.animationPosition = pos % 1
  return self
end

function SpriteInstance:isMirrored()
  return self.mirrored
end

function SpriteInstance:setMirrored(mirrored)
  self.mirrored = mirrored
  return self
end

function SpriteInstance:draw(x, y)
  local offsetX = self._sprite._originX * -1
  local offsetY = self._sprite._originY * -1
  local scaleX = 1

  if self.mirrored then
    offsetX = self._sprite._originX2
    scaleX = -1
  end

  love.graphics.draw(
    self._sprite._image,
    self.quad,
    math.floor(x + offsetX + 0.5),
    math.floor(y + offsetY + 0.5),
    0,
    scaleX,
    1
  )

  return self
end

function SpriteInstance:getDrawRect()
  local _, _, w, h = self:getViewport()
  local x
  if self.mirrored then
    x = self._sprite._originX2 - w
  else
    x = self._sprite._originX * -1
  end
  local y = self._sprite._originY * -1

  return x, y, w, h
end

function SpriteInstance:getViewport()
  return self.quad:getViewport()
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



return Mokyu
