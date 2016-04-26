local Mokyu = {}



local Sprite = {}
local SpriteMetaTable = {__index = Sprite}

function Mokyu.newSprite(...)
  return setmetatable({}, SpriteMetaTable)
    :initialize(...)
end

function Sprite:initialize(image, width, height, cols, rows)
  self.image = image
  self.animations = {}

  return self
    :setImage(image)
    :initializeQuads(width, height, cols, rows)
    :setOrigin(0, 0)
    :addAnimation('default', {frequency = 1, 1})
end

function Sprite:setImage(image)
  self.image = image

  return self
end

function Sprite:initializeQuads(width, height, cols, rows)
  cols = cols or 1
  rows = rows or 1

  self.quads = {}
  for y = 0, (rows - 1) do
    for x = 0, (cols - 1) do
      local quad = love.graphics.newQuad(x * width, y * height, width, height, self.image:getDimensions())
      table.insert(self.quads, quad)
    end
  end

  return self
end

function Sprite:setOrigin(x, y)
  self.originX = x
  self.originY = y

  return self
end

function Sprite:addAnimation(name, data)
  self.animations[name] = data

  return self
end



local SpriteInstance = {}
local SpriteInstanceMetaTable = {__index = SpriteInstance}

function Sprite:newInstance()
  return setmetatable({}, SpriteInstanceMetaTable)
    :initialize(self)
end

function SpriteInstance:initialize(sprite)
  self.sprite = sprite

  return self
    :setAnimation('default')
end

function SpriteInstance:setAnimation(animation)
  if self.sprite.animations[animation] == nil then
    error('Sprite has no animation named "' .. animation .. '".')
  end

  self.animation = self.sprite.animations[animation]
  self.animationPosition = 0
  self:animate(0) -- Set the quad.

  return self
end

function SpriteInstance:animate(dt)
  self.animationPosition = (self.animationPosition + (self.animation.frequency * dt)) % 1
  local frame = math.floor(self.animationPosition * #self.animation) + 1
  self.quad = self.sprite.quads[self.animation[frame]]

  return self
end

function SpriteInstance:draw(x, y)
  local offsetX = self.sprite.originX
  local offsetY = self.sprite.originY
  local scaleX = 1
  -- local offsetX = self.img_offset_x
  -- local offsetY = self.img_offset_y

  -- if self.img_mirror then
  --   offsetX = w - offsetX
  --   scaleX = -1
  -- end

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

return Mokyu
