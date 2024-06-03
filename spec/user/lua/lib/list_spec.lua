local assert = require 'luassert'
local pretty   = require 'pl.pretty'
local seq      = require 'pl.seq'
local testutil = require 'spec.util'

local eq = assert.equals
local same = assert.are.same

local msg = testutil.msg
local msgf = testutil.msgf
local hl = testutil.hl
local group = testutil.group

-- local assert = luassert


local function alpha()
  return table.pack("a", "b", "c", "d")
end

local methods = { "push", "pop", "forEach", "filter", "map", "reduce" }

local function verify_methods(tabl)
  for i, m in ipairs(methods) do
    eq(type(tabl[m]), "function", msg("Expected func", hl(m), "to be defined on list{}"))
  end
end

local function verify_list(ls, items)
  verify_methods(ls)

  group('should allow item access via index', function()
    for i,v in ipairs(items) do
      assert.are.same(v, ls[i], msgf('expected item at index [%d] to be %q', i, tostring(v)))
    end
  end)

  group('should allow item access via `at()`', function()
    for i,v in ipairs(items) do
      assert.are.same(v, ls:at(i), msgf('expected item at index [%d] to be %q', i, tostring(v)))
    end
  end)


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

      local typedlist

      typedlist = lists.new(typedarray)
      -- typedlist = lists(typedarray)
      -- typedlist = lists.pack(table.unpack(typedarray))

      typedlist:map(function (i)
        return i.name
      end)      
    end)
  end)

  describe("Create with", function()
    describe("__call", function()
      it("should create a new list with nil", function()
        verify_list(lists(), {})
      end)

      it("should create a new list with initial array", function()
        verify_list(lists{"z", "y", "x"}, { "z", "y", "x" })
      end)
    end)

    describe("new()", function()
      it("(called as function) should create a new list", function()
        verify_list(lists.new({ "z", "y", "x" }), { "z", "y", "x" })
      end)

      it("(called as method) should error", function()
        assert.has.errors(function()
          verify_list(lists:new({ "z", "y", "x" }), { "z", "y", "x" })
        end)
      end)
    end)

    describe("pack()", function()
      it("(called as function) should pack args into list instance", function()
        verify_list(lists.pack("z", "y", "x"), { "z", "y", "x" })
      end)

      it("(called as method) should error", function()
        assert.has.errors(function()
          verify_list(lists:pack("z", "y", "x"), { "z", "y", "x" })
        end)
      end)
    end)
  end)


  describe("tostring", function()
    it("should return string version of list (for tostring operation)", function()
      local list = lists.new({ "z", "y", "x" })

      eq(pretty.write(list:values()), tostring(list))
    end)
  end)

  describe("forEach", function()
    local result = ""

    local eachfn = spy.new(function(item)
      result = result .. item.name
    end)

    local items = {
      { name = "A" },
      { name = "B" },
      { name = "C" },
      { name = "D" },
    }

    local list = lists(items):forEach(eachfn)

    it("should return a list after running forEach", function()
      verify_list(list, items)
    end)

    it("should iterate over all items", function()
      eq('ABCD', result)
      assert.spy(eachfn).was.called(4)
      assert.spy(eachfn).was.called_with(items[1], 1)
      assert.spy(eachfn).was.called_with(items[2], 2)
      assert.spy(eachfn).was.called_with(items[3], 3)
      assert.spy(eachfn).was.called_with(items[4], 4)
    end)
  end)

  describe("filter", function()
    local filterfn = spy.new(function(item, i)
      return item.amt % 2 == 0
    end)

    local items = {
      { amt = 11 },
      { amt = 22 },
      { amt = 33 },
      { amt = 44 },
    }

    local list = lists(items)
    local filtered = list:filter(filterfn)

    it("should not affect the original list", function()
      verify_list(list, items)
    end)

    it("should return a list of mapped items", function()
      local expected = {
        { amt = 22 },
        { amt = 44 },
      }

      verify_list(filtered, expected)
    end)

    it("should iterate over all items", function()
      assert.spy(filterfn).was.called(4)
      assert.spy(filterfn).was.called_with(items[1], 1)
      assert.spy(filterfn).was.called_with(items[2], 2)
      assert.spy(filterfn).was.called_with(items[3], 3)
      assert.spy(filterfn).was.called_with(items[4], 4)
    end)
  end)

  describe("map", function()
    local mapfn = spy.new(function(item, i)
      return { amt = item.amt * 10 }
    end)

    local items = {
      { amt = 10 },
      { amt = 20 },
      { amt = 30 },
      { amt = 40 },
    }

    local list = lists(items)
    local mapped = list:map(mapfn)

    it("should not affect the original list", function()
      verify_list(list, items)
    end)

    it("should return a list of mapped items", function()
      local expect = {
        { amt = 100 },
        { amt = 200 },
        { amt = 300 },
        { amt = 400 },
      }

      verify_list(mapped, expect)
    end)

    it("should iterate over all items", function()
      assert.spy(mapfn).was.called(4)
      assert.spy(mapfn).was.called_with(items[1], 1)
      assert.spy(mapfn).was.called_with(items[2], 2)
      assert.spy(mapfn).was.called_with(items[3], 3)
      assert.spy(mapfn).was.called_with(items[4], 4)
    end)
  end)


end)