require 'busted'

local Mokyu = require 'mokyu'

_G.love = {
  graphics = {
    newQuad = spy.new(function(x1, y1, x2, y2, iw, ih)
      return {x1, y1, x2, y2, iw, ih}
    end),
  },
}

describe('Mokyu', function()
  describe('When creating a new sprite', function()
    local width = 16
    local height = 24
    local cols = 4
    local rows = 2

    local image = {
      getDimensions = function()
        return 64, 48
      end,
    }

    spy.on(love.graphics, 'newQuad')

    local sprite = Mokyu.newSprite(image, width, height, cols, rows)

    it('It should set image', function()
      assert.are.equals(image, sprite.image)
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
      assert.are.same(0, sprite.originX)
      assert.are.same(0, sprite.originY)
      assert.are.same(width,  sprite.originX2)
      assert.are.same(height, sprite.originY2)
    end)

    it('It should create default animation', function()
      local expected = {
        default = {frequency = 1, 1},
      }
      assert.are.same(expected, sprite.animations)
    end)
  end)
end)