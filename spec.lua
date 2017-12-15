require 'busted'

_G.love = {
  math = {
    newRandomGenerator = spy.new(function()
      return {
        random = function()
          return 0.5
        end,
      }
    end),
  }
}

local Mokyu = require 'mokyu'

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
    _G.love.graphics = {
      draw = spy.new(function()
      end),
      newQuad = spy.new(function(x1, y1, x2, y2, iw, ih)
        return {x1, y1, x2, y2, iw, ih, quad = true}
      end),
    }
  end)

  describe('When creating a new sprite:', function()
    local sprite

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
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

      assert.are.same(8, #sprite.quads)
    end)

    it('It should set correct originRect', function ()
      assert.are.same(width, sprite.width)
      assert.are.same(height, sprite.height)
      assert.are.same(0, sprite._originX)
      assert.are.same(0, sprite._originY)
      assert.are.same(width,  sprite._originX2)
      assert.are.same(height, sprite._originY2)
      assert.are.same({0, 0, width, height}, {sprite:getOriginRect()})
    end)

    it('It should create default animation', function()
      local expected = {
        default = {frequency = 1, 1},
      }
      assert.are.same(expected, sprite.animations)
    end)
  end)

  describe('When calling Sprite methods:', function()
    local sprite

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
    end)

    it('getWidth should return width', function()
      assert.are.same(16, sprite:getWidth())
    end)

    it('getHeight should return height', function()
      assert.are.same(24, sprite:getHeight())
    end)

    it('getOriginRect should return correct values', function()
      local originX, originY, originW, originH = sprite:getOriginRect()
      assert.are.same(0, originX)
      assert.are.same(0, originY)
      assert.are.same(width,  originW)
      assert.are.same(height, originH)
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
      assert.are.same(false, spriteInstance.mirrored)

      assert.are.same(defaultAnimation, spriteInstance.animation)
      assert.are.same('default', spriteInstance.animationName)
      assert.are.same(0, spriteInstance.animationPosition)
      assert.are.same(firstQuad, spriteInstance:getQuad())
    end)
  end)

  describe('When calling SpriteInstance methods:', function()
    local sprite, spriteInstance

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
      spriteInstance = sprite:newInstance()
    end)

    it('getAnimationName should return name of current animation', function()
      assert.are.same('default', spriteInstance:getAnimationName())
    end)

    it('setRandomAnimationPosition should seek to a random position in animation', function()
      spriteInstance:setRandomAnimationPosition()
      assert.are.same(0.5, spriteInstance.animationPosition)
    end)

    it('setAnimationPosition should set specified animation position', function()
      spriteInstance:setAnimationPosition(0.75)
      assert.are.same(0.75, spriteInstance.animationPosition)
    end)

    it('setAnimationPosition should only allow range between 0 and 0.9999...', function()
      spriteInstance:setAnimationPosition(0)
      assert.are.same(0, spriteInstance.animationPosition)

      spriteInstance:setAnimationPosition(0.5)
      assert.are.same(0.5, spriteInstance.animationPosition)

      spriteInstance:setAnimationPosition(0.9999)
      assert.are.same(0.9999, spriteInstance.animationPosition)

      assert.error(function() spriteInstance:setAnimationPosition(-1) end)
      assert.error(function() spriteInstance:setAnimationPosition(1) end)
      assert.error(function() spriteInstance:setAnimationPosition(256) end)
    end)

    it('setMirrored should update mirrored attribute', function()
      spriteInstance:setMirrored(true)
      assert.are.same(true, spriteInstance:isMirrored())

      spriteInstance:setMirrored(false)
      assert.are.same(false, spriteInstance:isMirrored())
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

    it('should call love.graphics.draw with expected arguments', function()
      spriteInstance:draw(x, y)

      local expX = x - halfWidth
      local expY = y - halfHeight
      assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, 1, 1, 8, 12)
    end)

    it('should call love.graphics.draw with expected arguments when mirrored', function()
      spriteInstance
        :setMirrored(true)
        :draw(x, y)

      local expX = x - halfWidth + width
      local expY = y - halfHeight
      assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, -1, 1, 8, 12)
    end)

    describe('When Sprite has custom originrect', function()
      local oX, oY, oW, oH = 2, 4, 10, 20
      local expY = y - halfHeight - oY

      before_each(function()
        sprite:setOriginRect(oX, oY, oW, oH)
      end)

      it('should call love.graphics.draw with expected arguments', function()
        spriteInstance:draw(x, y)

        local expX = x - halfWidth - oX
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, 1, 1, 8, 12)
      end)

      it('should call love.graphics.draw with expected arguments when mirrored', function()
        spriteInstance
          :setMirrored(true)
          :draw(x, y)

        local expX = x - halfWidth + oX + oW
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, 0, -1, 1, 8, 12)
      end)
    end)

    describe('When rotating sprite', function()
      local helpTestFn = function(spriteInstanceRotation, expectedDrawRotation)
        spriteInstance
          :setRotation(spriteInstanceRotation)
          :draw(x, y)
        local expX = x - halfWidth
        local expY = y - halfHeight
        assert.spy(_G.love.graphics.draw).was.called_with(image, quad, expX, expY, expectedDrawRotation, 1, 1, 8, 12)
      end

      it('should call love.graphics.draw with expected arguments when rotated 90 degrees', function()
        local NINETY_DEGREES = math.pi * 0.5
        helpTestFn(NINETY_DEGREES, NINETY_DEGREES)
      end)

      it('should call love.graphics.draw with expected arguments when rotated 180 degrees', function()
        local ONE_HUNDRED_EIGHTY_DEGREES  = math.pi * 1.0
        helpTestFn(ONE_HUNDRED_EIGHTY_DEGREES, ONE_HUNDRED_EIGHTY_DEGREES)
      end)

      it('should call love.graphics.draw with expected arguments when rotated 270 degrees', function()
        local TWO_HUNDRED_SEVENTY_DEGREES  = math.pi * 1.5
        helpTestFn(TWO_HUNDRED_SEVENTY_DEGREES, TWO_HUNDRED_SEVENTY_DEGREES)
      end)

      it('should call love.graphics.draw with expected arguments when rotated 360 degrees', function()
        local THREE_HUNDRED_SIXTY_DEGREES  = math.pi * 2
        helpTestFn(THREE_HUNDRED_SIXTY_DEGREES, 0)
      end)
    end)
  end)
end)
