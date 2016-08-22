local Mokyu = {}



local rng = love.math.newRandomGenerator()



local Sprite = {}
local SpriteMetaTable = {__index = Sprite}

function Mokyu.newSprite(...)
  return setmetatable({}, SpriteMetaTable)
    :initialize(...)
end

function Sprite:initialize(image, width, height)
  self.image = image
  self.animations = {}
  self.width  = width
  self.height = height

  return self
    :setImage(image)
    :initializeQuads(width, height)
    :setOriginRect(0, 0, width, height)
    :addAnimation('default', {frequency = 1, 1})
end

function Sprite:setImage(image)
  self.image = image

  return self
end

function Sprite:initializeQuads(width, height)
  local imageWidth, imageHeight = self.image:getDimensions()
  local cols = imageWidth / width
  local rows = imageHeight / height

  self.quads = {}
  for y = 0, (rows - 1) do
    for x = 0, (cols - 1) do
      local quad = love.graphics.newQuad(x * width, y * height, width, height, imageWidth, imageHeight)
      table.insert(self.quads, quad)
    end
  end

  return self
end

function Sprite:setOriginRect(x, y, w, h)
  self.originX = x
  self.originY = y
  self.originX2 = x + w
  self.originY2 = y + h

  return self
end

function Sprite:addAnimation(name, data)
  data.frequency = data.frequency or 1

  self.animations[name] = data

  return self
end

function Sprite:getWidth()
  return self.width
end

function Sprite:getHeight()
  return self.height
end



local SpriteInstance = {}
local SpriteInstanceMetaTable = {__index = SpriteInstance}

function Sprite:newInstance()
  return setmetatable({}, SpriteInstanceMetaTable)
    :initialize(self)
end

function SpriteInstance:initialize(sprite)
  self.sprite = sprite
  self.mirrored = false

  return self
    :setAnimation('default')
end

function SpriteInstance:setAnimation(animation)
  if self.sprite.animations[animation] == self.animation then
    return self -- SpriteInstances is already using this animation
  end

  if self.sprite.animations[animation] == nil then
    error('Sprite has no animation named "' .. animation .. '".')
  end

  self.animation = self.sprite.animations[animation]
  self.animationPosition = 0
  self:animate(0) -- Set the quad.
  self.animationName = animation

  return self
end

function SpriteInstance:animate(dt)
  self.animationPosition = (self.animationPosition + (self.animation.frequency * dt)) % 1
  local frame = math.floor(self.animationPosition * #self.animation) + 1
  self.quad = self.sprite.quads[self.animation[frame]]

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

function SpriteInstance:setMirrored(mirrored)
  self.mirrored = mirrored

  return self
end

function SpriteInstance:draw(x, y)
  local offsetX = self.sprite.originX * -1
  local offsetY = self.sprite.originY * -1
  local scaleX = 1

  if self.mirrored then
    offsetX = self.sprite.originX2
    scaleX = -1
  end

  love.graphics.draw(
    self.sprite.image,
    self.quad,
    math.floor(x + offsetX + 0.5),
    math.floor(y + offsetY + 0.5),
    0,
    scaleX,
    1
  )

  return self
end

function SpriteInstance:getViewport()
  return self.quad:getViewport()
end

function SpriteInstance:getWidth()
  return self.sprite:getWidth()
end

function SpriteInstance:getHeight()
  return self.sprite:getHeight()
end



return Mokyu
