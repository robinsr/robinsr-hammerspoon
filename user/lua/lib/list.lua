local pretty   = require 'pl.pretty'
local inspect  = require 'hs.inspect'
local params   = require 'user.lua.lib.params'
local proto    = require 'user.lua.lib.proto'
local types    = require 'user.lua.lib.typecheck'


---@class ClassifiedList
---@field store table
local ClassifiedList = {}


---@return ClassifiedList
function ClassifiedList:new()
  ---@class ClassifiedList
  local this = {
    store = {}
  }
  return setmetatable(this, { __index = ClassifiedList })
end

function ClassifiedList:add(key, item)
  params.assert.notNil(key, 1)
  params.assert.notNil(item, 2)

  if self.store[key] == nil then
    self.store[key] = { item }
  else
    table.insert(self.store[key], item)
  end
end

function ClassifiedList:value()
  return self.store
end



---@class List
---@field items any[]
---@operator call:List
local List = {}
local ListMeta = {}

ListMeta.__index = function(list, arg)
  if types.isNum(arg) then
    return list.items[arg]
  else
    return List[arg]
  end
end


---@return List
local function create(ctx, init)
  if ListMeta.ident(ctx) then
    error('You meant to call this as a function, not a method')
  end

  local this = { items = {} }
  
  if types.isTable(init) then
    if init.__index == List then
      return init
    end

    if types.isTable(init.items) then
      this = { items = init.items }
    end

    this = { items = init }
  end

  return setmetatable(this, ListMeta)
end

ListMeta.__call = function(list, init) return create({}, init) end

ListMeta.__len = function(list) return #list.items end

-- ListMeta.__tostring = function(list) return pretty.write(list.items) end
ListMeta.__tostring = function(list) return inspect(list.items) end

ListMeta.ident = function(list)
  return getmetatable(list) == ListMeta
end



---@generic T
---@param ... T[]
---@return List
function List.new(...)
  local args = table.pack(...)
  return create(args[1], args[1])
end


---@return List
function List.pack(...)
  local args = table.pack(...)
  return create(args[1], args)
end


---@return List
---@param iter fun():any
---@param ... any
function List.collect(iter, ...)
  local elems = {}
  for index, value in iter do
    table.insert(elems, value)
  end
  return create({}, elems)
end


---@return List
function List:clone()
  local newitems = table.pack(table.unpack(self.items))
  return create(newitems)
end


---@return integer
function List:len()
  return #self.items
end


--
-- Returns the item `T` at index position `num`
--
---@generic T
---@param num integer
---@return T
function List:at(num)
  local len = #self.items
  local index = (num-1)%len+1

  return self.items[index]
end


--
---@param elem any
---@return integer
function List:indexOf(elem)
  for i, v in ipairs(self.items) do
    if (v == elem) then return i end
  end

  return -1
end


---@param separator? string
---@return string
function List:join(separator)
  separator = separator or ''
  return table.concat(self.items, separator)
end


---@param newitems any[]
---@return List
function List:concat(newitems)
  for i, newitem in ipairs(newitems) do
    table.insert(self.items, newitem)
  end

  return self
end


--
-- WIP! - Adds an item to the end of a list-like table
--
---@generic T
---@param ... T The item to add
---@return List List with new items appended
function List:push(...)
  for i, add in ipairs({...}) do
    table.insert(self.items, add)
  end

  return self
end


--
--
--
---@generic T
---@param ... T The item to add
---@return List List with new items appended
function List:shift(...)
  local additems = {...}

  for i = #self.items, 1, -1 do
    self.items[#additems+i] = self.items[i]
  end

  for j, add in ipairs(additems) do
    self.items[j] = add
  end

  return self
end


--
-- WIP! - Removes and returns last item from a list-like table
--
---@generic T
---@retrun T
function List:pop()
  local len = #self.items
  return table.remove(self.items, len)
end


--
-- Iterates over item in a list
--
---@generic T : any
---@param fn IteratorFn The iteration function
---@return List
function List:forEach(fn)
  for k, v in ipairs(self.items) do
    fn(v, k)
  end

  return self
end

-- Alias for foreach
List.each = List.forEach


--
-- Maps item in a list
--
---@generic O : any
---@param fn MappingFn<any, O> Mapping function
---@return List : O[]
function List:map(fn)
  local mapped = {}

  for i, v in ipairs(self.items) do
    table.insert(mapped, i, fn(v, i))
  end

  return create({}, mapped)
end


--
-- Maps items in a list to a property `prop` of each item
--
---@generic T 
---@param prop string
---@return List : T[]
function List:mapProp(prop)
  local mapped = {}

  for i, v in ipairs(self.items) do
    table.insert(mapped, i, v[prop])
  end

  return create({}, mapped)
end


--
-- Filters items in a list to just those that pass predicate
--
---@generic T : any
---@param self { items: T[] }
---@param fn PredicateFn<T> The filter function
---@return List : T[]
function List:filter(fn)
  local filtered = {}

  for k, v in ipairs(self.items) do
    if (fn(v, k)) then
      table.insert(filtered, v)
    end
  end

  return create({}, filtered)
end


--
-- Finds the first item in a list that passes a predicate
--
---@generic T : any
---@param fn PredicateFn The filter function
---@return T|nil The matching item or nil
function List:first(fn)
  for k, v in ipairs(self.items) do
    if (fn(v, k)) then
      return v
    end
  end
end


--
-- Reduces items to a single value
--
---@generic R : any
---@param init R Initial value of reduction
---@param reducerFn ReducerFn The reducer function
---@return R The filtered list
function List:reduce(init, reducerFn)
  for i, v in ipairs(self.items) do
    init = reducerFn(init, v, i)
  end

  return init
end


--
-- Tests every item in a list-like table; all must pass
--
---@generic T : any
---@param fn PredicateFn The test function
---@return boolean
function List:every(fn)
  for k, v in ipairs(self.items) do
    if (fn(v, k) ~= true) then return false end
  end

  return true
end


--
-- Tests every item in a list-like table; at least one must pass
--
---@generic T : any
---@param fn PredicateFn The test function
---@return boolean
function List:any(fn)
  for k, v in ipairs(self.items) do
    if (fn(v, k)) then return true end
  end

  return false
end


--
-- Returns true if list contains an item that is equal to t
--
---@param elem any The test item
---@return boolean
function List:includes(elem)
  for k, v in ipairs(self.items) do
    if (v == elem) then return true end
  end

  return false
end


--
-- Returns a plain list of the items
--
---@return table
function List:values()
  local vals = {}
  for i, v in ipairs(self.items) do
    table.insert(vals, i, v)
  end
  return vals
end


--
-- Returns the list items flattened one degree
--
---@return List
function List:flatten()
  local flatd = {}

  for i, v1 in ipairs(self.items) do
    if (types.isTable(v1) and  #v1 > 0) then
      for i2, v2 in ipairs(v1) do
        table.insert(flatd, v2)
      end
    else
      table.insert(flatd, v1)
    end
  end

  return create({}, flatd)
end


--
-- Sorts the list by default `table.sort` method or by invoking optional compare
-- function `comp`
--
-- If comp is given, then it must be a function that receives two list elements and
-- returns true when the first element must come *before* the second in the final order
--
---@generic T
---@param comp? CompareFn<T>
---@return List
function List:sort(comp)
  local sorted = table.pack(table.unpack(self.items))
  table.sort(sorted, comp)

  return create({}, sorted)
end


--
-- Returns the list items flattened one degree
--
---@generic T
---@generic G
---@param classifier string|ClassifierFn<T,G> - A string which is a key on every item in the list, or a function to return a string key
---@param ...? any                            - if `classifier` is a function property of i, these args are passed to `fn` 
---@return { [G]: T[] }
function List:groupBy(classifier, ...)
  local cls_args = {...}

  local classifyItem = function(item, index)
    if types.isFunc(classifier) then
      return classifier(item, index)
    end

    if types.isFunc(item[classifier]) then
      return item[classifier](item, table.unpack(cls_args))
    end

    if types.notNil(item[classifier]) then
      return item[classifier]
    end

    return ''
  end

  local sorted = ClassifiedList:new()

  for i, item in ipairs(self.items) do
    local key = classifyItem(item, i)

    if key ~= nil then
      sorted:add(key, item)
    end
  end

  return sorted:value()
end


---
-- Returns the elements of the list as arguments
--
function List:unpack()
  return table.unpack(self.items)
end



return setmetatable({}, ListMeta) --[[@as List]]