---@diagnostic disable: redundant-parameter
local pretty = require 'pl.pretty'
local tutil  = require 'spec.util'
local say = require 'say'

local fmt = tutil.fmt
local dump = tutil.dump

local function system_sleep(n)
  os.execute("sleep " .. tonumber(n))
end


local function counter_fn(spy)
  local counter = 0
  return spy.new(function()
    counter = counter + 1
    return counter
  end)
end

print()


insulate("user.lua.lib.func", function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy)

  local fns = require('user.lua.lib.func')

  describe("fns.cooldown", function()
    it("should only call the memoized function once", function()
      local expensive_fn = counter_fn(spy)
      assert.same(1, expensive_fn())
      assert.same(2, expensive_fn())
      assert.same(3, expensive_fn())
      assert.spy(expensive_fn).called(3)

      expensive_fn = counter_fn(spy)
      
      ---@diagnostic disable-next-line: param-type-mismatch
      local memod_fn = fns.cooldown(10, expensive_fn)
      assert.same(1, memod_fn())
      assert.same(1, memod_fn())
      assert.same(1, memod_fn())
      assert.spy(expensive_fn).called(1)
    end)

    it("should call the memoized function again after 1 second", function()
      local expensive_fn = counter_fn(spy)
      ---@diagnostic disable-next-line: param-type-mismatch
      local memod_fn = fns.cooldown(0.5, expensive_fn)
      
      assert.same(1, memod_fn())
      assert.same(1, memod_fn())

      system_sleep(1)

      assert.same(2, memod_fn())
      assert.same(2, memod_fn())
    end)

    it("should pass arguments", function()
      local expensive_fn = spy.new(function(a, b)
        return {a, b}
      end)
      
      ---@diagnostic disable-next-line: param-type-mismatch
      local memod_fn = fns.cooldown(3, expensive_fn, 'x', 'y')
      assert.same({'x','y'}, memod_fn())
      assert.same({'x','y'}, memod_fn())
      assert.same({'x','y'}, memod_fn())
      assert.spy(expensive_fn).called(1)
      assert.spy(expensive_fn).called_with('x', 'y')
    end)
  end)


end)