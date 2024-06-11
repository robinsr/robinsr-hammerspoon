local pretty   = require 'pl.pretty'
local proto    = require 'user.lua.lib.proto'
local types    = require 'user.lua.lib.typecheck'



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

  local o = { items = {} }
  
  if types.isTable(init) then
    if init.__index == List then
      return init
    end

    if types.isTable(init.items) then
      o = { items = init.items }
    end

    o = { items = init }
  end

  return setmetatable(o, ListMeta)
end

ListMeta.__call = function(list, init) return create({}, init) end

ListMeta.__len = function(list) return #list.items end

ListMeta.__tostring = function(list) return pretty.write(list.items) end

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
function List:clone()
  local newitems = table.pack(table.unpack(self.items))
  return create(newitems)
end


---@return integer
function List:len()
  return #self.items
end


---@param num integer
---@return string
function List:at(num)
  return self.items[num]
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
-- Filters items in a list to just those that pass predicate
--
---@generic T
---@param fn PredicateFn<T> The filter function
---@return List The filtered list
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

  -- print(pretty.write({ self.items, flatd }))

  return create({}, flatd)
end


--
-- Returns the list items flattened one degree
--
---@param fn string|CategoryFn - A string which is a key on every item in the list, or a function to return a string key
---@param ... any - if `fn` is a function property of i, these args are passed to `fn` 
---@return table
function List:groupBy(fn, ...)
  local org = {}

  for i, v in ipairs(self.items) do

    local key

    if type(fn) == 'function' then
      key = fn(v, i)
    elseif type(v[fn]) == 'function' then
      key = v[fn](v, table.unpack({...}))
    else
      key = v[fn]
    end

    if key ~= nil then
      if org[key] == nil then
        org[key] = { v }
      else
        table.insert(org[key], v)
      end
    end
  end

  return org
end



return setmetatable({}, ListMeta) --[[@as List]]