mokyu
=====

[![Build Status](https://travis-ci.org/oniietzschan/mokyu.svg?branch=master)](https://travis-ci.org/oniietzschan/mokyu)
[![Codecov](https://codecov.io/gh/oniietzschan/mokyu/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/mokyu)

A library to handle sprite manipulation and animation in Love2D. Usuable, but unpolished.

Example
-------

```lua
local Mokyu = require 'mokyu'

local entity = {x = 0, y = 0}
local sprite

function love.load(arg)
  local image = love.graphics.newImage('image.png')

  sprite = Mokyu.sprite(
    image,
    16, -- quad width
    16 --  quad height
  )
    :setOriginRect(1, 1, 14, 14)
    :addAnimation('walk', {
        frequency = 2, -- two full animation cycles per second
        1, 2, 3, 4, 5, 6, -- array portion of table stores the frames
    })

  entity.sprite = sprite:newInstance()
end

function love.update(dt)
  entity.sprite:animate(dt)
end

function love.draw(dt)
  entity.sprite:draw(entity.x, entity.y)
end

function love.keypressed(key)
  if key == 'left' then
    entity.sprite:setMirrored(false)
  elseif key == 'right' then
    entity.sprite:setMirrored(true)
  end
end
```

Todo
----

* Remove `SpriteInstance:setRandomAnimationPosition()`.
* Reevaluate `SpriteInstance:getViewport()` and `SpriteInstance:getDrawRect()`.
