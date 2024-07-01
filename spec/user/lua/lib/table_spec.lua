local assert = require 'luassert'
local pretty = require 'pl.pretty'


local function indexOf(arr, item)
  for i, v in ipairs(arr) do
    if v == item then
      return i
    end
  end

  return -1
end 


describe('lib/table.lua', function()
  local Tabl = require('user.lua.lib.table')

  describe('static methods', function()
    it("Tabl.keys(t)", function()

      local coolt = { 
        foo = 'bar',
        baz = 'qux'
      }

      local coolkeys = Tabl.keys(coolt)

      assert.equal(2, #coolkeys, 'There should be 2 keys in `coolt`')
      assert.True(indexOf(coolkeys, 'foo') > 0, 'Could not find item `foo` in ' .. pretty.write(coolkeys))
      assert.True(indexOf(coolkeys, 'baz') > 0, 'Could not find item `baz` in ' .. pretty.write(coolkeys))
    end)
  end)

  describe('instance methods', function()
    it("t:keys()", function()

      local Coolt = Tabl{ 
        foo = 'bar',
        baz = 'qux'
      }

      local coolkeys = Coolt:keys()

      assert.equal(2, #coolkeys, 'There should be 2 keys in `coolt`')
      assert.True(indexOf(coolkeys, 'foo') > 0, 'Could not find item `foo` in ' .. pretty.write(coolkeys))
      assert.True(indexOf(coolkeys, 'baz') > 0, 'Could not find item `baz` in ' .. pretty.write(coolkeys))
    end)
  end)


  describe("merged", function()
    it("simple merge", function()

      local ta = {
        variables = 'are'
      }

      local tb = {
        very = 'cool'
      }

      local result = Tabl.merge({}, ta, tb)

      assert.are.same('are', result.variables)
      assert.are.same('cool', result.very)
    end)

    it("depth merge", function()
      local tA = {
        foo = 'foo',
        bar = {
          baz = 'baz@tA',
          tA_only = 'only on tA'
        },
        tA_only = 'tA rules!'
      }

      local tB = {
        foo = 'foo@tB',
        bar = {
          baz = 'baz@tB',
          tB_only = 'only on tB',
        },
        tB_only = 'tA stinks!'
      }

      local result = Tabl.merge({}, tA, tB)

      assert.are.same('foo@tB', result.foo)
      assert.are.same('tA rules!', result.tA_only)
      assert.are.same('tA stinks!', result.tB_only)
      assert.are.same('baz@tB', result.bar.baz)
      assert.are.same('only on tA', result.bar.tA_only)
      assert.are.same('only on tB', result.bar.tB_only)
    end)
  end)
end)