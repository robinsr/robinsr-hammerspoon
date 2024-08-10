---@diagnostic disable: redundant-parameter
local tutil = require 'spec.util'


local function indexOf(arr, item)
  for i, v in ipairs(arr) do
    if v == item then
      return i
    end
  end

  return -1
end 


insulate('user.lua.lib.table', function()

  package.loaded[tutil.logger_mod] = tutil.mock_logger(spy, "inspect")

  local Tabl = require('user.lua.lib.table')

  describe("Table.keys", function()

    local test_table = { 
      foo = 'bar',
      baz = 'qux'
    }

    local expected_keys = { 'foo', 'baz' }

    local verify_keys = function(keylist)
      assert.is_not.Nil(keylist)
      assert.are.same(2, #keylist)
      assert.is.True(indexOf(keylist, 'foo') > 0, 'Could not find item `foo` in ' .. tutil.pretty(keylist))
      assert.is.True(indexOf(keylist, 'baz') > 0, 'Could not find item `baz` in ' .. tutil.pretty(keylist))
    end

    describe('(as function)', function()
      it("returns a list of keys in the table", function()
        verify_keys(Tabl.keys(test_table))
      end)
    end)

    describe('(as method of Table)', function()
      it("returns a list of keys in the table", function()
        verify_keys(Tabl(test_table):keys())
      end)
    end)
  end)


  describe("Table.merge", function()
    it("should merge top-level table properties into a single table", function()

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

    it("should merge deep table properties into a single table", function()
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

  describe("Table.entries", function()
    it("should return an iterator of entires in table", function()
      
      local tabl = Tabl(tutil.ttable())

      local eachfn = spy.new(function() end)

      for k,v in tabl:entries() do
        eachfn(tutil.msgf("{%s=%q}",k,v))
      end

      assert.spy(eachfn).called(5)

      assert.spy(eachfn).called_with('{bar="rab"}')
      assert.spy(eachfn).called_with('{quuz="zuuq"}')
      assert.spy(eachfn).called_with('{foo="oof"}')
      assert.spy(eachfn).called_with('{baz="zab"}')
      assert.spy(eachfn).called_with('{quz="zuq"}')

    end)
  end)

  describe("Table.invert", function()
    it("should create a new table with keys and values flipepd", function()
      
      local orig = {
        alpha = 'foo',
        beta = 'bar',
        gamma = 'baz',
      }

      local flipped = Tabl.invert(orig)

      assert.are.same(orig.alpha, 'foo')
      assert.are.same(orig.beta, 'bar')
      assert.are.same(orig.gamma, 'baz')

      assert.are.same(flipped.foo, 'alpha')
      assert.are.same(flipped.bar, 'beta')
      assert.are.same(flipped.baz, 'gamma')


    end)
  end)
end)