---@diagnostic disable: redundant-parameter
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump

insulate("user.lua.lib.optional", function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy)
  -- package.loaded['inspect'] = tutil.dump

  local Opt = require('user.lua.lib.optional')

  describe("Optional:of", function()
    it("should return the value when passed a non-nil value", function()
      local maybe = Opt:of({ name = 'foo' })

      assert.same({ name = 'foo' }, maybe:get())
    end)

    it("should thrown an error when passed a nil value", function()
      assert.error(function()
        local maybe = Opt:of(nil)
      end, Opt.msg)
    end)

    it("should thrown an error with customer message when passed a nil value", function()
      assert.error(function()
        local maybe = Opt:of(nil, 'maybe cant be nil')
      end, 'maybe cant be nil')
    end)
  end)


  describe("Optional:ofNil", function()
    it("should return the value when passed a non-nil value", function()
      local maybe = Opt:ofNil({ name = 'bar' })

      assert.same({ name = 'bar' }, maybe:get())
    end)

    it("should thrown an error when passed a nil value", function()
      local maybe = Opt:ofNil(nil)

      assert.error(function()
        local val = maybe:get()
      end, 'get called on nil optional')
    end)
  end)


  describe("Optional:isPresent", function()
    it("should return true when value is non-nil", function()
      local maybe = Opt:ofNil({ name = 'bar' })

      assert.is.True(maybe:isPresent())
    end)

    it("should return false when value is nil", function()
      local maybe = Opt:ofNil(nil)

      assert.is.False(maybe:isPresent())
    end)
  end)


  describe("Optional:isEmpty", function()
    it("should return false when value is non-nil", function()
      local maybe = Opt:ofNil({ name = 'bar' })

      assert.is.False(maybe:isEmpty())
    end)

    it("should return true when value is nil", function()
      local maybe = Opt:ofNil(nil)

      assert.is.True(maybe:isEmpty())
    end)
  end)


  describe("Optional:ifPresent", function()
    it("should call the consumer when value is non-nil", function()
      local consumer = spy.new(function() end)

      ---@diagnostic disable-next-line
      Opt:ofNil({ name = 'bar' }):ifPresent(consumer)

      assert.spy(consumer).called(1)
    end)

    it("should not call the consumer when value is nil", function()
      local consumer = spy.new(function() end)

      ---@diagnostic disable-next-line
      Opt:ofNil(nil):ifPresent(consumer)

      assert.spy(consumer).called(0)
    end)
  end)


  describe("Optional:orElse", function()
    it("should return the non-nil value", function()
      local maybe = Opt:ofNil({ name = 'bar' }):orElse('foobar')

      assert.same({ name = 'bar' }, maybe)
    end)

    it("should return the fallback value", function()
      local maybe = Opt:ofNil(nil):orElse('foobar')

      assert.same('foobar', maybe)
    end)
  end)


  describe("Optional:orElseGet", function()
    it("should return the non-nil value", function()
      local maybe = Opt:ofNil({ name = 'bar' }):orElseGet(function() return 'got foobar' end)

      assert.same({ name = 'bar' }, maybe)
    end)

    it("should return the fallback value", function()
      local maybe = Opt:ofNil(nil):orElseGet(function() return 'got foobar' end)

      assert.same('got foobar', maybe)
    end)
  end)


  describe("Optional:map", function()
    local function get_price(item)
      return Opt:ofNil(item)
        :map(function(val) return val.price end)
    end

    it("should return false when val is nil", function()
      local price = get_price(nil)

      assert.is.False(price:isPresent())
      assert.is.True(price:isEmpty())
    end)

    it("should return true when val passes all filters", function()
      local price = get_price({ price = 12 })

      assert.is.True(price:isPresent())
      assert.are.same(12, price:get())
    end)
  end)


  describe("Optional:mapMethod", function()
    local Item = {}

    function Item:new(prefs)
      return setmetatable({ prefs = prefs }, { __index = Item })
    end

    function Item:getPrefs(pref)
      return self.prefs[pref]
    end

    it("should return false when val is nil", function()
      local dessert = Opt:ofNil(nil):mapMethod('getPrefs', 'ice_cream')

      assert.is.False(dessert:isPresent())
      assert.is.True(dessert:isEmpty())
    end)


    it("should return false when val is nil", function()
      local ice = Item:new({ sport = 'boxing' })

      local dessert = Opt:ofNil(ice):mapMethod('getPrefs', 'ice_cream')

      assert.is.False(dessert:isPresent())
      assert.is.True(dessert:isEmpty())
    end)

    it("should return true when val passes all filters", function()
      local ice = Item:new({ ice_cream = 'vanilla' })
      
      assert.are.same('vanilla', ice:getPrefs('ice_cream'))

      local dessert = Opt:ofNil(ice):mapMethod('getPrefs', 'ice_cream')

      assert.is.True(dessert:isPresent())
      assert.are.same('vanilla', dessert:get())
    end)
  end)


  describe("Optional:map", function()
    local function price_in_range(item)
      return Opt:ofNil(item)
        :map(function(val) return val.price end)
        :filter(function(p) return p >= 10 end)
        :filter(function(p) return p <= 15 end)
        :isPresent()
    end

    it("should return false when val is nil", function()
      assert.is.False(price_in_range(nil))
    end)

    it("should return true when val passes all filters", function()
      assert.is.True(price_in_range({ price = 12 }))
    end)

    it("should return false cos price is too high", function()
      assert.is.False(price_in_range({ price = 50 }))
    end)

    it("should return false cos price is too low", function()
      assert.is.False(price_in_range({ price = 5 }))
    end)
  end)
end)


