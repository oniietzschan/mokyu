require 'busted'

local Mokyu = require 'mokyu'

local NINETY_DEGREES              = math.pi * 0.5
local ONE_HUNDRED_EIGHTY_DEGREES  = math.pi * 1.0
local TWO_HUNDRED_SEVENTY_DEGREES = math.pi * 1.5
local THREE_HUNDRED_SIXTY_DEGREES = math.pi * 2.0
local FOUR_HUNDRED_FIFTY_DEGREES  = math.pi * 2.5

describe('Mokyu:', function()
  local width = 16
  local height = 24
  local halfWidth = 8
  local halfHeight = 12

  local image = {
    getDimensions = function()
      return 64, 48
    end,
  }

  before_each(function()
    _G.love = {
      graphics = {
        draw = spy.new(function()
        end),
        newQuad = spy.new(function(x1, y1, x2, y2, iw, ih)
          return {x1, y1, x2, y2, iw, ih, quad = true}
        end),
      },
    }
  end)

  describe('When creating a new sprite:', function()
    local sprite

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height, 4, 2)
    end)

    it('It should set image', function()
      assert.are.equals(image, sprite:getImage())
    end)

    it('It should initialize quads', function ()
      assert.spy(_G.love.graphics.newQuad).was.called(8)
      assert.spy(_G.love.graphics.newQuad).was.called_with( 0,  0, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with(16,  0, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with(32,  0, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with(48,  0, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with( 0, 24, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with(16, 24, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with(32, 24, 16, 24, 64, 48)
      assert.spy(_G.love.graphics.newQuad).was.called_with(48, 24, 16, 24, 64, 48)

      assert.are.same(8, #sprite._quads)
    end)

    it('It should set correct originRect', function ()
      assert.are.same(width, sprite.width)
      assert.are.same(height, sprite.height)
      assert.are.same({0, 0, width, height}, {sprite:getOriginRect()})
    end)

    it('It should create default animation', function()
      local expected = {
        default = {frequency = 1, 1},
      }
      assert.are.same(expected, sprite._animations)
    end)
  end)

  describe('When calling Sprite methods:', function()
    local sprite

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
    end)

    it('getWidth should return width', function()
      assert.are.same(width, sprite:getWidth())
    end)

    it('getHeight should return height', function()
      assert.are.same(height, sprite:getHeight())
    end)

    it('getDimensions should return width and height', function()
      assert.are.same({width, height}, {sprite:getDimensions()})
    end)

    it('getOriginRect should return correct values', function()
      local originX, originY, originW, originH = sprite:getOriginRect()
      assert.are.same(0, originX)
      assert.are.same(0, originY)
      assert.are.same(width,  originW)
      assert.are.same(height, originH)
    end)
  end)

  describe('When creating animations', function()
    local sprite

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
    end)

    it('should be able to add an animation with number frames', function()
      sprite:addAnimation('test', {1, 2, 3, 4})
      local animations = sprite:getAnimations()
      local animation = animations['test']
      assert.is_not_nil(animation)
      assert.are.same(1, animation.frequency)
      assert.are.same(1, animation[1])
      assert.are.same(2, animation[2])
      assert.are.same(3, animation[3])
      assert.are.same(4, animation[4])
    end)

    it('should be able to add an animation with interval string frames', function()
      sprite:addAnimation('test', {'1-4'})
      local animations = sprite:getAnimations()
      local animation = animations['test']
      assert.is_not_nil(animation)
      assert.are.same(1, animation.frequency)
      assert.are.same(1, animation[1])
      assert.are.same(2, animation[2])
      assert.are.same(3, animation[3])
      assert.are.same(4, animation[4])
    end)

    it('should be able to add an animation with mix of numbers and string intervals', function()
      sprite:addAnimation('test', {'1-3', 4, '3-1'})
      local animations = sprite:getAnimations()
      local animation = animations['test']
      assert.is_not_nil(animation)
      assert.are.same(1, animation.frequency)
      assert.are.same(1, animation[1])
      assert.are.same(2, animation[2])
      assert.are.same(3, animation[3])
      assert.are.same(4, animation[4])
      assert.are.same(3, animation[5])
      assert.are.same(2, animation[6])
      assert.are.same(1, animation[7])
    end)
  end)

  describe('When creating a new SpriteInstance:', function()
    local sprite, spriteInstance

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
      spriteInstance = sprite:newInstance()
    end)

    it('should set animation to correct defaults', function()
      local defaultAnimation = {frequency = 1, 1}
      local firstQuad = {0, 0, 16, 24, 64, 48, quad = true}

      assert.are.equals(sprite, spriteInstance:getSprite())
      assert.are.same(false, spriteInstance:isMirrored())

      assert.are.same(defaultAnimation, spriteInstance._animation)
      assert.are.same('default', spriteInstance:getAnimation())
      assert.are.same(0, spriteInstance:getAnimationPosition())
      assert.are.same(firstQuad, spriteInstance:getQuad())
    end)
  end)

  describe('When calling SpriteInstance methods:', function()
    local sprite, spriteInstance

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
      spriteInstance = sprite:newInstance()
    end)

    it('getAnimation should return name of current animation', function()
      assert.are.same('default', spriteInstance:getAnimation())
    end)

    it('setAnimationPosition should set specified animation position', function()
      spriteInstance:setAnimationPosition(0.75)
      assert.are.same(0.75, spriteInstance:getAnimationPosition())
    end)

    it('setAnimationPosition should only allow range between 0 and 0.9999...', function()
      spriteInstance:setAnimationPosition(0)
      assert.are.same(0, spriteInstance:getAnimationPosition())

      spriteInstance:setAnimationPosition(0.5)
      assert.are.same(0.5, spriteInstance:getAnimationPosition())

      spriteInstance:setAnimationPosition(0.9999)
      assert.are.same(0.9999, spriteInstance:getAnimationPosition())

      assert.error(function() spriteInstance:setAnimationPosition(-1) end)
      assert.error(function() spriteInstance:setAnimationPosition(1) end)
      assert.error(function() spriteInstance:setAnimationPosition(256) end)
    end)

    it('setAnimationPosition should only allow number', function()
      assert.error(function() spriteInstance:setAnimationPosition(false) end)
    end)

    it('setMirrored should update mirrored attribute', function()
      spriteInstance:setMirrored(true)
      assert.are.same(true, spriteInstance:isMirrored())

      spriteInstance:setMirrored(false)
      assert.are.same(false, spriteInstance:isMirrored())
    end)

    it('setMirrored should error on non-boolean value', function()
      assert.error(function() spriteInstance:setMirrored(1) end)
    end)

    it('setRotation should set the rotation', function()
      spriteInstance:setRotation(0)
      assert.are.same(0, spriteInstance:getRotation())

      spriteInstance:setRotation(NINETY_DEGREES)
      assert.are.same(NINETY_DEGREES, spriteInstance:getRotation())

      spriteInstance:setRotation(ONE_HUNDRED_EIGHTY_DEGREES)
      assert.are.same(ONE_HUNDRED_EIGHTY_DEGREES, spriteInstance:getRotation())

      spriteInstance:setRotation(TWO_HUNDRED_SEVENTY_DEGREES)
      assert.are.same(TWO_HUNDRED_SEVENTY_DEGREES, spriteInstance:getRotation())
    end)

    it('setRotation should error on non-numeric value', function()
      assert.error(function() spriteInstance:setRotation(false) end)
    end)

    it('setRotation should set the rotato modulo Tau', function()
      spriteInstance:setRotation(THREE_HUNDRED_SIXTY_DEGREES)
      assert.are.same(0, spriteInstance:getRotation())

      spriteInstance:setRotation(FOUR_HUNDRED_FIFTY_DEGREES)
      assert.are.same(NINETY_DEGREES, spriteInstance:getRotation())
    end)

    it('getWidth should return width of parent Sprite', function()
      assert.are.same(sprite:getWidth(), spriteInstance:getWidth())
    end)

    it('getHeight should return height of parent Sprite', function()
      assert.are.same(sprite:getHeight(), spriteInstance:getHeight())
    end)

    it('getDimensions should return width and height of parent Sprite', function()
      assert.are.same({sprite:getDimensions()}, {spriteInstance:getDimensions()})
    end)
  end)

  describe('When calling SpriteInstance:draw()', function()
    local sprite, spriteInstance, quad
    local x, y = 1000, 2000

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
      spriteInstance = sprite:newInstance()
      quad = spriteInstance:getQuad()
    end)

    do
      local expX = x + halfWidth
      local expY = y + halfHeight

      it('should call love.graphics.draw with expected arguments', function()
        spriteInstance:draw(x, y)
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, 1, 1, 8, 12)
      end)

      it('should call love.graphics.draw with expected arguments when mirrored', function()
        spriteInstance
          :setMirrored(true)
          :draw(x, y)
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, -1, 1, 8, 12)
      end)
    end

    describe('When Sprite has custom originrect', function()
      local oL, oT, oW, oH = 2, 4, 10, 20
      local expOriginX = oL + (oW * 0.5)
      local expOriginY = oT + (oH * 0.5)
      local expX = x + (oW * 0.5)
      local expY = y + (oH * 0.5)

      before_each(function()
        sprite:setOriginRect(oL, oT, oW, oH)
      end)

      it('should call love.graphics.draw with expected arguments', function()
        spriteInstance:draw(x, y)
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, 1, 1, expOriginX, expOriginY)
      end)

      it('should call love.graphics.draw with expected arguments when mirrored', function()
        spriteInstance
          :setMirrored(true)
          :draw(x, y)
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, -1, 1, expOriginX, expOriginY)
      end)
    end)

    describe('When Sprite has custom originrect with width which is not a divisible by 2', function()
      local oL, oT, oW, oH = 3, 6, 5, 15
      local expX = math.floor(x + (oW / 2) + 0.5)
      local expY = math.floor(y + (oH / 2) + 0.5)
      local expOriginY = math.floor(oT + (oH / 2) + 0.5)

      before_each(function()
        sprite:setOriginRect(oL, oT, oW, oH)
      end)

      it('should call love.graphics.draw, rounding originX up from .5', function()
        spriteInstance:draw(x, y)
        local expOriginX = math.floor(oL + (oW / 2) + 0.5)
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, 1, 1, expOriginX, expOriginY)
      end)

      it('should call love.graphics.draw when mirrored, rounding originX down from .5', function()
        spriteInstance
          :setMirrored(true)
          :draw(x, y)
        local expOriginX = math.ceil(oL + (oW / 2) - 0.5)
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, -1, 1, expOriginX, expOriginY)
      end)
    end)

    describe('When rotating sprite', function()
      local helpTestFn = function(spriteInstanceRotation, expectedDrawRotation)
        spriteInstance
          :setRotation(spriteInstanceRotation)
          :draw(x, y)
        local expX = x + halfWidth
        local expY = y + halfHeight
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, expectedDrawRotation, 1, 1, 8, 12)
      end

      it('should call love.graphics.draw with expected arguments when rotated 90 degrees', function()
        helpTestFn(NINETY_DEGREES, NINETY_DEGREES)
      end)

      it('should call love.graphics.draw with expected arguments when rotated 180 degrees', function()
        helpTestFn(ONE_HUNDRED_EIGHTY_DEGREES, ONE_HUNDRED_EIGHTY_DEGREES)
      end)

      it('should call love.graphics.draw with expected arguments when rotated 270 degrees', function()
        helpTestFn(TWO_HUNDRED_SEVENTY_DEGREES, TWO_HUNDRED_SEVENTY_DEGREES)
      end)
    end)
  end)
end)
