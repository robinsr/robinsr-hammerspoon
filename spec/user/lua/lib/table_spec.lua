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
end)