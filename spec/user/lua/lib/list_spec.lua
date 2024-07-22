local assert = require 'luassert'
local pretty   = require 'pl.pretty'
local seq      = require 'pl.seq'
local testutil = require 'spec.util'

local eq = assert.are.equal
local same = assert.are.same

local msg = testutil.msg
local msgf = testutil.msgf
local hl = testutil.hl
local group = testutil.group

-- local assert = luassert


local function alpha(len)
  len = len or 4
  
  local alphas = "abcdefghijklmnopqrstuvwxyz"
  
  local chars = {}

  for i=1,len do
    table.insert(chars, alphas:sub(i, i))
  end

  return table.pack(table.unpack(chars))
end

local methods = { "push", "pop", "forEach", "filter", "map", "reduce" }

local function verify_methods(tabl)
  for i, m in ipairs(methods) do
    eq("function", type(tabl[m]), msg("Expected func", hl(m), "to be defined on list{}"))
  end
end

local function verify_list(ls, items)
  verify_methods(ls)

  group('should allow item access via index', function()
    for i,v in ipairs(items) do
      same(v, ls[i], msgf('expected item at index [%d] to be %q', i, tostring(v)))
    end
  end)

  group('should allow item access via `at()`', function()
    for i,v in ipairs(items) do
      same(v, ls:at(i), msgf('expected item at index [%d] to be %q', i, tostring(v)))
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
      same(alpha(), alpha())
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


  describe("List#tostring", function()
    it("should return string version of list (for tostring operation)", function()
      local list = lists.new({ "z", "y", "x" })

      eq(pretty.write(list:values()), tostring(list))
    end)
  end)

  describe("List.shift", function()
    it("Adds new items to front of list", function()
      local l = lists({ 'd','e','f','g' })
      l:shift('a','b','c')

      same({'a','b','c','d','e','f','g'}, l:values())
    end)
  end)

  describe("List#at", function()
    local list_at = lists(alpha(10))

    it("should return item at index", function()
      same("a", list_at:at(1), "expected list_at[1] to be 'a'")
      same("b", list_at:at(2), "expected list_at[1] to be 'b'")
      same("c", list_at:at(3), "expected list_at[1] to be 'c'")
      same("j", list_at:at(10), "expected list_at[10] to be 'j'")
    end)

    it("should handle overflow indexes", function()
      same("i", list_at:at(9), "expected list_at[9] to be 'i'")
      same("j", list_at:at(10), "expected list_at[10] to be 'j'")
      same("a", list_at:at(11), "expected list_at[11] to be 'a'")
      same("b", list_at:at(12), "expected list_at[12] to be 'b'")
      same("j", list_at:at(20), "expected list_at[20] to be 'j'")
      same("a", list_at:at(21), "expected list_at[21] to be 'a'")
    end)

    it("should handle negaive indexes", function()
      same("j", list_at:at(0), "expected list_at[0] to be 'j'")
      same("i", list_at:at(-1), "expected list_at[-1] to be 'i'")
    end)
  end)

  describe("List#forEach", function()
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

  describe("List#filter", function()
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

  describe("List#map", function()
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

  describe("List#flatten", function()
    it("should flatten a 2d list", function()
      local ls = lists({
        { { item = '1' }, { item = '2' } },
        { { item = '3' } },
        { { { item = 'deep_item' } } },
        { { item = '5' }, { item = '6' } }
      })

      assert.are.same(4, ls:len())
      assert.are.same({ { item = '1' }, { item = '2' } }, ls:at(1))
      assert.are.same({ { item = '3' }, }, ls:at(2))
      assert.are.same({ { { item = 'deep_item' } } }, ls:at(3))
      assert.are.same({ { item = '5' }, { item = '6' } }, ls:at(4))

      local flatls = ls:flatten()
      
      assert.are.same(6, flatls:len())

      for i,v in ipairs({ 1, 2, 3, 5, 6 }) do
        assert.are.same({ item = tostring(v) }, flatls:at(v))
      end

      assert.are.same({ { item = 'deep_item' } }, flatls:at(4))
    end)

    it("should not affect non-iterable items (tables)", function()
      local ls = lists({
        { name = 'foo', city = 'oof' },
        { name = 'bar', city = 'rab' },
        { name = 'baz', city = 'zab' },
      })

      local flatls = ls:flatten()

      assert.are.same(3, ls:len())
      assert.are.same(3, flatls:len())
    end)

    it("should not affect non-iterable items (strings)", function()
      local ls = lists({
        "foo", "bar", { "baz" }
      })

      local flatls = ls:flatten()

      assert.are.same("foo", flatls[1])
      assert.are.same("bar", flatls[2])
      assert.are.same("baz", flatls[3])
    end)
  end)


end)