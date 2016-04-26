local Mokyu = require 'mokyu'

local entity = {x = 0, y = 0}
local spriteBody
local spriteTail

function love.load(arg)
  spriteTail = Mokyu.sprite()

  spriteBody = Mokyu.sprite(
    16, -- quad width
    16, -- quad height
    3, -- number of quads per row
    2 -- number of rows
  )
    :setOriginRect(1, 1, 15, 15)
    :addAnimation('walk', {
        frequency = 2, -- two full animation cycles per second
        1, 2, 3, 4, 5, 6, -- array portion of table stores the frames
    })
    :addBelow(spriteTail)

  entity.sprite = spriteBody:newInstance()
end

function love.update(dt)
  if input:pressed('left') then
      entity.sprite:setMirrored(true)
  end

  entity.sprite:animate(dt)
end

function love.draw(dt)
  local x, y = entity:getPosition()
  entity.sprite:draw(x, y)
  entity.sprite:drawMirrored(x, y)
end

