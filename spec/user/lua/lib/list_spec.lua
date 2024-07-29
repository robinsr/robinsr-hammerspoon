---@diagnostic disable: redundant-parameter
local seq      = require 'pl.seq'
local testutil = require 'spec.util'

local eq     = assert.are.equal
local same   = assert.are.same
local msg    = testutil.msg
local msgf   = testutil.msgf
local hl     = testutil.hl
local group  = testutil.group
local alpha  = testutil.alphalist
local pretty = testutil.pretty


local methods = { "push", "pop", "forEach", "filter", "map", "reduce" }

local function verify_methods(tabl)
  for i, m in ipairs(methods) do
    eq("function", type(tabl[m]), msg("Expected func", hl(m), "to be defined on list{}"))
  end
end

local function verify_list(ls, expect)
  verify_methods(ls)

  group('should allow item access via index', function()
    for i,expected in ipairs(expect) do
      same(expected, ls[i], msgf('expected item at index [%d] to be %q', i, tostring(expected)))
    end
  end)

  group('should allow item access via `at()`', function()
    for i,expected in ipairs(expect) do
      same(expected, ls:at(i), msgf('expected item at index [%d] to be %q', i, tostring(expected)))
    end
  end)
end


insulate("user.lua.lib.list", function()


  local lists = require('user.lua.lib.list')
  _G.print = testutil.dump

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

  describe("List creation", function()
    describe("call metamethod", function()
      it("should create a new list with nil", function()
        verify_list(lists(), {})
      end)

      it("should create a new list with initial array", function()
        verify_list(lists{"z", "y", "x"}, { "z", "y", "x" })
      end)
    end)

    describe("List.new", function()
      it("(called as function) should create a new list", function()
        verify_list(lists.new({ "z", "y", "x" }), { "z", "y", "x" })
      end)

      it("(called as method) should error", function()
        assert.has.error(function()
          lists:new({ "z", "y", "x" })
        end)
      end)
    end)

    describe("List.pack", function()
      it("(called as function) should pack args into list instance", function()
        verify_list(lists.pack("z", "y", "x"), { "z", "y", "x" })
      end)

      it("(called as method) should error", function()
        assert.has.error(function()
          lists:pack("z", "y", "x")
        end)
      end)
    end)

    describe("List.collect #wip", function()
      local alist = testutil.alphalist(6)
      local iter, tabl, ind = ipairs(alist)
      testutil.dump(ipairs(alist))

      it("should collection items from an iterator into list instance", function()
        verify_list(lists.collect(ipairs(alist)), alist)
      end)

      it("(called as method) should error", function()
        assert.has.error(function()
          lists.collect(ipairs(alist))
        end)
      end)
    end)
  end)

  describe('List methods', function()

    describe("List.tostring", function()
      it("should return string version of list (for tostring operation)", function()
        local list = lists.new({ "z", "y", "x" })

        eq(pretty(list:values()), tostring(list))
      end)
    end)

    describe("List.shift", function()
      it("Adds new items to front of list", function()
        local l = lists({ 'd','e','f','g' })
        l:shift('a','b','c')

        same({'a','b','c','d','e','f','g'}, l:values())
      end)
    end)

    describe("List.at", function()
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

    describe("List.forEach", function()
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

      ---@diagnostic disable-next-line: param-type-mismatch
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

    describe("List.filter", function()
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

    describe("List.map", function()
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

      ---@diagnostic disable-next-line: param-type-mismatch
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

    describe("List.flatten", function()
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

    describe("List.groupBy", function()
      it("should categorize items using classifier function", function()
        ---@class TestPerson
        ---@field name string

        local people = lists({
          { name = 'Adam' },
          { name = 'Beth' },
          { name = 'Charlie' },
          { name = 'Dylan' },
          { name = 'Bob' },
          { name = 'Amy' },
        })

        ---@type ClassifierFn<TestPerson, string>
        local classifier = function(item) 
          return string.sub(item.name, 1, 1)
        end

        local firstLetter = people:groupBy(classifier)

        same({ { name = 'Adam' }, { name = 'Amy' } }, firstLetter['A'])
        same({ { name = 'Beth' }, { name = 'Bob' } }, firstLetter['B'])
        same({ { name = 'Charlie' } }, firstLetter['C'])
        same({ { name = 'Dylan' } }, firstLetter['D'])
      end)

      it("should categorize items using a property of item", function()
        local fruits = lists({
          { price = 1, name = 'Apple' },
          { price = 2, name = 'Banana' },
          { price = 1, name = 'Grapes' },
          { price = 6, name = 'Mango' },
          { price = 7, name = 'Orange' },
          { price = 6, name = 'Kiwi' },
        })

        local fruitByPrice = fruits:groupBy('price')

        same({ { price = 1, name = 'Apple' }, { price = 1, name = 'Grapes' } }, fruitByPrice[1])
        same({ { price = 2, name = 'Banana' } }, fruitByPrice[2])
        same({ { price = 6, name = 'Mango' }, { price = 6, name = 'Kiwi' } }, fruitByPrice[6])
        same({ { price = 7, name = 'Orange' } }, fruitByPrice[7])
      end)

      it("should categorize items by calling a function on item", function()
        
        ---@class TestFruit
        ---@field name string
        ---@field price number
        local Fruit = {}

        function Fruit:new(name, price)
          return setmetatable({ name = name, price = price }, { __index = Fruit })
        end

        function Fruit:getPrice(multiplier)
          return self.price * multiplier
        end

        local tFruitA = Fruit:new('Apple', 1)
        local tFruitB = Fruit:new('Banana', 2)
        local tFruitG = Fruit:new('Grapes', 1)
        local tFruitM = Fruit:new('Mango', 6)
        local tFruitO = Fruit:new('Orange', 7)
        local tFruitK = Fruit:new('Kiwi', 6)

        local fruits = lists({ tFruitA, tFruitB, tFruitG, tFruitM, tFruitO, tFruitK })

        local fruitByPrice = fruits:groupBy('getPrice', 4)

        same({ tFruitA, tFruitG }, fruitByPrice[4])
        same({ tFruitB }, fruitByPrice[8])
        same({ tFruitM, tFruitK }, fruitByPrice[24])
        same({ tFruitO }, fruitByPrice[28])
      end)
    end)
  end)

  describe("Sub-classing List", function()
    
    describe("using Proto.setProtoOf", function()
      
      it("should be able to subclass List", function()

        local proto = require('user.lua.lib.proto')

        local item1 = {
          dazzle = function() return 'boom!' end
        }

        local item2 = {
          dazzle = function() return 'bang!' end
        }
        

        ---@class test.SpecialList : List
        local SpecialList = proto.setProtoOf({}, lists)

        ---@return test.SpecialList
        function SpecialList:new(items)
          local this = {
            items = items
          }
          return proto.setProtoOf(this, SpecialList)
        end

        ---@return string
        function SpecialList:dazzle_items()
          return lists(self.items):map(function(i) return i.dazzle() end):join(' ')
        end

        local sublist = SpecialList:new({ item1, item2 })

        same({ item1, item2 }, sublist:values())
        same('boom! bang!', sublist:dazzle_items())
      end)
    end)
end)
end)