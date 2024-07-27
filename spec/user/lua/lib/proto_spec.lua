---@diagnostic disable: redundant-parameter
local testutil = require 'spec.util'

---@class Food
local Food = {
  _name = 'BaseFood'
}

function Food:ident()
  return 'Edible'
end

function Food:digest()
  return "rumble rumble rumble"
end

describe('user.lua.lib.proto', function()

  local proto = require 'user.lua.lib.proto'
  local setProtoOf = proto.setProtoOf

  describe('setProtoOf', function()
    it('Uses setProtoOf to create a prototype chain', function()

      ---@class Apple: Food
      ---@field variety string
      local Apple = setProtoOf({}, Food)

      function Apple:getVariety()
        return self.variety
      end

      ---@type Apple
      local apple = setProtoOf({ variety = 'red' }, Apple)

      assert.equal(apple:ident(), 'Edible')
      assert.equal(apple:getVariety(), 'red')
    end)

    it('Derived class provides its own constructor', function()

      ---@class Apple
      local Apple = setProtoOf({}, Food)

      ---@return Apple
      function Apple.newApple(v)
        return setProtoOf({ variety = v }, Apple)
      end

      function Apple:getVariety()
        return self.variety
      end


      local apple = Apple.newApple("Green")

      assert.equal(apple:ident(), 'Edible')
      assert.equal(apple:getVariety(), 'Green')
    end)


    it('can be written a different way', function ()

      ---@class Orange: Food
      ---@field squeeze fun(): string


      ---@class OrangeProto
      local OrangeProto = {}

      function OrangeProto:squeeze()
        return "Orange Juice"
      end

      ---@type OrangeProto
      local Orange = setProtoOf(OrangeProto, Food)

      ---@type Orange
      local orange = setProtoOf({}, Orange)

      -- print("Orange Class:", pretty.write(Orange))
      -- print("orange instance:", pretty.write(orange))

      assert.equal(orange:squeeze(), 'Orange Juice')
    end)


    it("can override base class's functions", function ()

      ---@class Battery: Food
      local Battery = setProtoOf({}, Food)

      ---@return Battery
      function Battery.newBattery()
        return setProtoOf({}, Battery)
      end

      function Battery:ident()
        return 'Nope'
      end

      local myBat = Battery.newBattery()
      
      assert.equal(myBat:ident(), 'Nope')
    end)


    it("'can also lock down the base class'", function()

      ---@class Battery: Food
      local Battery = setProtoOf({}, Food, { locked = true })

      local ok, batt = pcall(function()
        ---@return Battery
        function Battery.newBattery()
          return setProtoOf({}, Battery)
        end

        function Battery:ident()
          return 'Nope'
        end

        return Battery.newBattery()
      end)

      assert.equal(ok, false)
      assert.matches('^.*Object is locked! Attempt to assign "function: [%da-fx]+" to key "newBattery"$', batt)
    end)


    it('can merge properties', function()

      --
      -- Banana constructor adds `isRipe` to self
      --
      local Banana = { _name = 'Banana' } 
      function Banana:new(_isRipe)
        local this = self == Banana and {} or self
        
        this.isRipe = _isRipe or false

        return setProtoOf(this, Banana)
      end

      setProtoOf(Banana, Food, { locked = true })


      --
      -- BananaSplit constructors adds 'hasSprinkes' to self
      --
      local BananaSplit = { _name = 'BananaSplit' }
      function BananaSplit:new(sprinks)
        local this = self == BananaSplit and {} or self
        
        this._name = 'bs-instance-'..tostring(math.random())
        this.hasSprinkles = sprinks

        -- I want to set what 'self' is in Banana:new()...
        Banana.new(this, sprinks)
        
        return proto.setProtoOf(this, BananaSplit)
      end
      
      --
      -- Redefine `ident` function (originally in Food prototype) to use
      -- the properties on self defined at different levels of inheritence
      --
      function BananaSplit:ident()
        local ripe = self.isRipe and 'ripe' or 'unrippened'
        local sprink = self.hasSprinkles and 'with' or 'without'

        return 'A banana split '..sprink..' sprinkles and made with '..ripe..' bananas'
      end
      
      setProtoOf(BananaSplit, Banana, { locked = true })
      

      -- Can call this way (:new() will create an empty object)...
      local goodNanaSplit = BananaSplit:new(true)

      -- ...or this way (supply own object)
      local badNanaSplit = BananaSplit.new({}, false)

      assert.equal('A banana split with sprinkles and made with ripe bananas', goodNanaSplit:ident())
      assert.equal('A banana split without sprinkles and made with unrippened bananas', badNanaSplit:ident())

      -- testutil.dump("Good nana: ", goodNanaSplit)
      -- testutil.dump("Bad nana: ", badNanaSplit)

      assert.are_not.same(goodNanaSplit, badNanaSplit, "Class instances should be different objects")
      assert.are.same(goodNanaSplit.__index, badNanaSplit.__index, "Class instances should all have the same __index table")

      goodNanaSplit.isYum = true
      assert.is.True(goodNanaSplit.isYum, "Should be able to set properties on this class instance")


      local ok = pcall(function()
        goodNanaSplit.__index['thing'] = true
      end)

      assert.is_not.True(ok, "Should NOT be able to set properties on this class instance")

      assert.is_function(goodNanaSplit.digest, "Special foods should still digest")
      assert.are.same(goodNanaSplit:digest(), "rumble rumble rumble")
    end)
  end)
end)