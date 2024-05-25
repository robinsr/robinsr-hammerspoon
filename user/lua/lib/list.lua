local proto = require 'user.lua.lib.proto'


-- -@generic T: any
-- -@alias TableType T[]


---@class List<T>: { [integer]: T }
local List = {}


---@operator call:List
local ListMeta = {}
ListMeta.__index = List
ListMeta.__call = function(l, items)
  return setmetatable(items or {}, ListMeta)
end


---@return integer
function List.len(items)
  return #items
end


---@generic T
---@param t self
---@param items T[]
---@return List<T>
function List.create(t, items)
  return setmetatable(items or {}, ListMeta)
end


---@return List
function List.pack(...)
  local items = table.pack(...)
  return setmetatable(items or {}, ListMeta)
end


---@param items List|any[]
---@return List
function List.clone(items)
  local newitems = table.pack(table.unpack(items))
  return setmetatable(newitems, ListMeta)
end


---@param items List|any[]
---@param separator? string
---@return string
function List.join(items, separator)
  separator = separator or ''
  return table.concat(items, separator)
end


---@param itemsB any[]
---@return List
function List:concat(itemsB)
  local items = self

  for i, newitem in ipairs(itemsB) do
    table.insert(items, newitem)
  end

  return items
end


--
-- WIP! - Adds an item to the end of a list-like table
--
---@generic T
---@param items T[] list-like table
---@param ... T The item to add
---@return List List with new items appended
function List.push(items, ...)
  for i, add in ipairs({...}) do
    table.insert(items, add)
  end

  return List.create(nil, items)
end


--
-- WIP! - Removes and returns last item from a list-like table
--
---@generic T
---@param items T[] list-like table
---@retrun List
function List.pop(items)
  local last = items[#items]
  -- local remain = table.pack(select(#items - 1, table.unpack(items)))
  items[#items] = nil
  
  return last
end


--
-- Iterates over item in a list
--
---@generic T : any
---@param items T[] list-like table
---@param fn IteratorFn The iteration function
---@return List
function List.forEach(items, fn)
  for k, v in ipairs(items) do
    fn(v, k)
  end

  return List.create(nil, items)
end


--
-- Maps item in a list
--
---@generic T : any
---@param items T[] list-like table
---@param fn MappingFn Mapping function
---@return List<T>
function List.map(items, fn)
  local mapped = {}

  for i, v in ipairs(items) do
    table.insert(mapped, i, fn(v, i))
  end

  return List.create(nil, mapped)
end


--
-- Filters items in a list to just those that pass predicate
--
---@generic T
---@param items T[] list-like table
---@param fn PredicateFn<T> The filter function
---@return List<T> The filtered list
function List.filter(items, fn)
  local filtered = {}

  for k, v in ipairs(items) do
    if (fn(v, k)) then
      table.insert(filtered, v)
    end
  end

  return List.create(nil, filtered)
end


--
-- Finds the first item in a list that passes a predicate
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The filter function
---@return T|nil The matching item or nil
function List.first(items, fn)
  for k, v in ipairs(items) do
    if (fn(v, k)) then
      return v
    end
  end
end


--
-- Reduces items to a single value
--
---@generic T : any
---@generic R : any
---@param items T[] list-like table
---@param init R Initial value of reduction
---@param reducerFn ReducerFn The reducer function
---@return R The filtered list
function List.reduce(items, init, reducerFn)
  List.forEach(items, function(item, i)
    initial = reducerFn(init, item, i)
  end)

  return initial
end


--
-- Tests every item in a list-like table; all must pass
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The test function
---@return boolean
function List.every(items, fn)
  for k, v in ipairs(items) do
    if (fn(v, k) ~= true) then return false end
  end

  return true
end


--
-- Tests every item in a list-like table; at least one must pass
--
---@generic T : any
---@param items T[] list-like table
---@param fn PredicateFn The test function
---@return boolean
function List.any(items, fn)
  for k, v in ipairs(items) do
    if (fn(v, k)) then return true end
  end

  return false
end


--
-- Returns true if list contains an item that is equal to t
--
---@generic T : any
---@param items T[] list-like table
---@param elem any The test item
---@return boolean
function List.includes(items, elem)
  for k, v in ipairs(items) do
    if (v == elem) then return true end
  end

  return false
end


--
-- Returns a plain list of the items
--
---@return table
function List.items(items)
  return table.pack(table.unpack(items))
end



return setmetatable({}, ListMeta)