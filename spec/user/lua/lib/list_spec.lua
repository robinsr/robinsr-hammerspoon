local assert = require 'luassert'
local pretty = require 'pl.pretty'
local seq = require 'pl.seq'
local testutil = require 'spec.util'

local eq = assert.equals
local same = assert.are.same

local msg = testutil.msg
local hl = testutil.hl


local function alpha()
  return table.pack("a", "b", "c", "d")
end

local methods = { "push", "pop", "forEach", "filter", "map", "reduce" }

local function isList(tabl)
  for i, m in ipairs(methods) do
    eq(type(tabl[m]), "function", 
      msg("Expected func", hl(m), "to be defined on list{}"))
  end
end


describe("lib/list.lua", function()
  local lists = require('user.lua.lib.list')

  describe("(meta)", function()
    it("test tables are not same object", function()
      -- New table is made on each call to alpha()
      assert.are_not.equal(alpha(), alpha())
      assert.is_true(alpha() ~= alpha())

      -- The tables have identical contents
      assert.are.same(alpha(), alpha())

    end)
  end)

  describe("Lua-LSP Type", function()
    it("can understand type annotations", function()

      ---@class TestFoo
      ---@field name string


      ---@type TestFoo[]
      local typedarray = {
        { name = 'foo' },
        { name = 'bar' },
        { name = 'baz' },
      }


      local typedlist = lists:create(typedarray)

      typedlist:filter(function(whatAmI, num)

      end)
      
    end)
  end)

  describe("static", function()
    describe("pack", function()
      it("should pack args into list instance", function()
        local ls = lists.pack("z", "y", "x")

        isList(ls)
        eq(ls[1], "z")
        eq(ls[2], "y")
        eq(ls[3], "x")
      end)
    end)

    describe("create", function()
      it("should create a new list with the create method", function()
        local ls = lists:create({ "x", "y", "z" })
        
        local matches = function(pattern)
          return function(l)
            return string.match(pattern, l)
          end
        end

        isList(ls)
        eq(ls:first(matches('xyz')), "x")
        eq(ls[2], "y")
        eq(ls[3], "z")

        eq(3, ls:filter(matches('xyz')):len())

      end)
    end)
  end)


  describe("instance", function()
    describe("__call", function()

      it("should make a new list instance from nil", function()
        local ls = lists()

        isList(ls)
        eq(#ls, 0)
      end)
      
      it("should make a new list instance from a list", function()
        local ls = lists(alpha())

        isList(ls)
        eq(#ls, 4)
      end)

      it("should accept another list instance", function()
        local lsA = lists(alpha())
        local lsB = lists(lsA)

        eq(#lsA, 4)
        eq(#lsB, 4)
        
        isList(lsB)
      end)
    end)

    describe("forEach", function()
      it("should iterate over all items", function()
        local result = ""

        lists(alpha()):forEach(function(char)
          result = result..char
        end)

        eq('abcd', result)
      end)
    end)


  end)
end)