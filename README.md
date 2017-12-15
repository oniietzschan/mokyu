mokyu
=====

[![Build Status](https://travis-ci.org/oniietzschan/mokyu.svg?branch=master)](https://travis-ci.org/oniietzschan/mokyu)
[![Codecov](https://codecov.io/gh/oniietzschan/mokyu/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/mokyu)

A library to handle sprite manipulation and animation in Love2D. Usable, but unpolished.

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

Sprite Methods
--------------

```lua
-- Sets the image which is used for drawing. Quads are left untouched.
image = love.graphics.newImage('spritesheet.png')
sprite:setImage(image)

-- Gets the image.
image = sprite:getImage(image)

-- Adds a new animation.
sprite:addAnimation('jump', {2, 3, 4, 4, 3, 6})

-- Checks whether a named animation exists.
hasJumpAnimation = sprite:hasAnimation('jump')

-- Sets origin rectangle.
sprite:setOriginRect(x, y, w, h)

-- Gets origin rectangle.
x, y, w, h = sprite:getOriginRect()

-- Methods for getting sprite (ie. individual quad) dimensions
w = sprite:getWidth()
h = sprite:getHeight()
w, h = sprite:getDimensions()
```

SpriteInstance Methods
----------------------

```lua
-- Draws at (x, y).
spriteInstance:draw(x, y)

-- Advances the animation forward by dt.
spriteInstance:animate(dt)

-- Sets the current animation by name.
spriteInstance:setAnimation('attack')

-- Gets the name of the current animation.
currentAnimation = spriteInstance:getAnimation()

-- Checks whether parent sprite has named animation.
hasJumpAnimation = spriteInstance:hasAnimation('attack')

-- Sets the animation position. Position should be a number >= 0 and < 1.
spriteInstance:setAnimationPosition(0.5)

-- Get the current animation position.
position = spriteInstance:getAnimationPosition()

-- Sets whether the sprite instance should be draw mirrored horizontally.
spriteInstance:setMirrored(true)

-- Gets mirrored value.
spriteInstance:isMirrored()

-- Sets the rotation of the sprite instance in radians.
spriteInstance:setRotation(math.pi * 1.5)

-- Gets the rotation of the sprite instance.
rotation = spriteInstance:getRotation()

-- Gets the current quad of the animation.
quad = spriteInstance:getQuad()

-- Gets the parent sprite.
sprite = spriteInstance:getSprite()

-- Methods for getting dimensions of parent sprite.
w = spriteInstance:getWidth()
h = spriteInstance:getHeight()
w, h = spriteInstance:getDimensions()

-- MAYBE DEPRECIATED????
x, y, w, h = spriteInstance:getDrawRect()
```

Todo
----

* Reevaluate `SpriteInstance:getDrawRect()`.
