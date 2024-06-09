local tbx    = require 'pl.tablex'
local types  = require 'user.lua.lib.typecheck'
local params = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'



local function assert_tabl(tabl, num)
  if (not types.isTable(tabl)) then
    error(string.format('Parameter #%d is not a table, rather %s', num or 1, type(tabl)))
  end
end

local function assert_any(typefn, obj, num)
  if (not types[typefn](obj)) then
    error(string.format('Parameter #%d failed check "%s". found type %s', num or 1, typefn))
  end
end


---@class Table
local Table = {}


local TablMeta = {}
TablMeta.__index = Table

--
-- Returns a new table instance
--
---@operator call:Table
---@return Table
TablMeta.__call = function(t, init)
  return setmetatable(init or {}, TablMeta)
end

--
-- Returns a list keys found in `tabl`
--
---@param tabl table
---@param strict? boolean Throw error if table is nil
---@return string[] List of table's keys
function Table.keys(tabl, strict)
  assert_tabl(tabl)

  local keys = {}

  for key, _ in pairs(tabl) do
    table.insert(keys, key)
  end

  return keys
end

--
-- Returns a list of values found in `tabl`
--
---@param tabl table
---@param strict? boolean Throw error if table is nil
---@return any[] list of keys
function Table.vals(tabl, strict)
  assert_tabl(tabl)

  local vals = {}

  for _, val in pairs(tabl) do
    table.insert(vals, val)
  end

  return vals
end


--
-- Returns a single table composed of the combined key-values of all table parameters
--
---@param ... table[] Tables to merge
---@return table The merged table
function Table.merge(...)
  local tables = table.pack(...)
  assert_tabl(tables)

  local merged = {}

  for i, tabl in ipairs(tables) do
    assert_tabl(tabl, i)
    
    for k, v in pairs(tabl) do
      merged[k] = v
    end
  end

  return merged
end


--
-- Returns a single list-like table from the entries of all list-like table parameters
--
---@param ... table[] Lists to concatenate
---@returns table 
function Table.concat(...)
  local tables = table.pack(...)
  assert_tabl(tables)

  local merged = {}

  for i, tabl in ipairs(tables) do
    assert_tabl(tabl, i)
    
    for k, v in pairs(tabl) do
      table.insert(merged, v)
    end
  end

  return merged
end


--
-- Like `table.insert`, but inserts all items
--
-- -@param tabl table Table to insert items into
-- -@param ... any[] Elements to insert
---@return table
-- function Table.insert(tabl, ...)
--   local toAdd = {...}

--   if (not isTable(tabl)) then
--     error(errMsg(table))
--   end

--   for k, v in ipairs(toAdd) do
--     table.insert(tabl, v)
--   end

--   return tabl
-- end


--
-- Determine if a table contains a given object
--
---@param tabl table A table containing some sort of data
---@param elem any An object to search the table for
---@return boolean # true if the element could be f
function Table.contains(tabl, elem)
  return hs.fnutils.contains(tabl, elem)
end


--
-- Returns the value at a given path in an object. Path is given as a vararg list of keys.
--
---@param tabl table an object
---@param ... string A vararg list of keys
---@return any Either a value if found or nil
function Table.get(tabl, ...)
  local value = tabl
  local found = false
  local path = {...}

  for i, p in ipairs(path) do
    if (value[p] == nil) then return end
    value = value[p]
    found = true
  end

  if (not found) then
    return nil
  end

  return value
end


--
-- Assert not nil on a deep nested value in a table, using a dot-path string
--
---@param tabl table
---@param path string Dot-path string key
---@param nilMsg? string Optional error message when value is nil
---@return boolean 
function Table.haspath(tabl, path, nilMsg)
  assert_tabl(tabl, 1)

  local val = Table.get(tabl, table.unpack(strings.split(path, '.')))

  if (types.notNil(val)) then
    return true
  end

  if types.isString(nilMsg) then error(nilMsg) end

  return false
end


--
-- Returns true if `tabl` is contains a non-nil value for key `key`
--
---@param tabl table Table to check
---@param key string String-key to check for nill-ness
---@param strict? boolean Throw error if table is nil
---@return boolean
function Table.has(tabl, key, strict)
  assert_tabl(tabl)
  return types.is_not.Nil(Table.get(tabl, key))
end


--
-- Returns the values for specific keys from a table
--
---@param tabl table Table to pick values from
---@param keys string[] List of keys to pick from table
---@return table
function Table.extract(tabl, keys)
  local picked = {}

  for i, key in ipairs(keys) do
    table.insert(picked, params.default(Table.get(tabl, key), ""))
  end

  return table.unpack(picked)
end


--
-- Returns a subset of a larger table
--
---@param tabl table Table to pick values from
---@param keys string[] List of keys to pick from table
---@return table
function Table.pick(tabl, keys)
  local picked = {}

  for i, key in ipairs(keys) do
    picked[key] = Table.get(tabl, key)
  end

  return picked
end


--
-- Returns true if `tabl` is a lua table with zero string keys
--
---@param tabl table Table to check for emptiness
---@return boolean
function Table.isEmpty(tabl)
  assert_tabl(tabl)

  local keys = Table.keys(tabl)

  if #keys > 0 then
    return false
  end

  return true
end


--
-- Wait, I can just add methods to lua's table object?
--
-- Yes, but its not like a class with instance methods
--
-- Eg NOT 
-- tab1 = { this = 'that' }
-- tab2 = tab1:clone()
--
-- its just on the table
--
-- tab2 = table.clone(tab1)
--
-- And this implementation is naive, only copies array-like tables
--
function Table.clone(tabl)
  return setmetatable(tabl, table)
end


return setmetatable({}, TablMeta)