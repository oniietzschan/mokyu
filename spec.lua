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
      spy.on(love.graphics, 'newQuad')

      sprite = Mokyu.newSprite(image, width, height)
    end)

    it('It should set image', function()
      assert.are.equals(image, sprite:getImage())
    end)

    it('It should initialize quads', function ()
      assert.spy(love.graphics.newQuad).was.called(8)
      assert.spy(love.graphics.newQuad).was.called_with( 0,  0, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with(16,  0, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with(32,  0, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with(48,  0, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with( 0, 24, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with(16, 24, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with(32, 24, 16, 24, 64, 48)
      assert.spy(love.graphics.newQuad).was.called_with(48, 24, 16, 24, 64, 48)

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

    it('setMirrored should update mirrored attribute', function()
      spriteInstance:setMirrored(true)
      assert.are.same(true, spriteInstance.mirrored)

      spriteInstance:setMirrored(false)
      assert.are.same(false, spriteInstance.mirrored)
    end)
  end)

  describe('When drawing a SpriteInstance', function()
    local sprite, spriteInstance, quad
    local x, y = 1000, 2000

    before_each(function()
      sprite = Mokyu.newSprite(image, width, height)
      spriteInstance = sprite:newInstance()
      quad = spriteInstance:getQuad()
    end)

    it('draw should call love.graphics.draw with the expected arguments', function()
      spriteInstance:draw(x, y)

      assert.spy(love.graphics.draw).was.called(1)
      assert.spy(love.graphics.draw).was.called_with(image, quad, x, y, 0, 1, 1)
    end)

    it('draw should call love.graphics.draw with the expected arguments when mirrored', function()
      spriteInstance
        :setMirrored(true)
        :draw(x, y)

      assert.spy(love.graphics.draw).was.called(1)
      assert.spy(love.graphics.draw).was.called_with(image, quad, x + 16, y, 0, -1, 1)
    end)

    describe('When Sprite has custom originrect', function()
      before_each(function()
        sprite:setOriginRect(2, 4, 10, 20)
      end)

      it('draw should call love.graphics.draw with the expected arguments', function()
        spriteInstance:draw(x, y)

        assert.spy(love.graphics.draw).was.called(1)
        assert.spy(love.graphics.draw).was.called_with(image, quad, x - 2, y - 4, 0, 1, 1)
      end)

      it('draw should call love.graphics.draw with the expected arguments when mirrored', function()
        spriteInstance
          :setMirrored(true)
          :draw(x, y)

        assert.spy(love.graphics.draw).was.called(1)
        assert.spy(love.graphics.draw).was.called_with(image, quad, x + 12, y - 4, 0, -1, 1)
      end)
    end)
  end)
end)
