local tc = require 'user.lua.lib.typecheck'
local params = require 'user.lua.lib.params'


local Tabl = {}

--
-- Returns a list of table's keys
--
---@param tabl table
---@return table # list of keys
function Tabl.keys(tabl)
  local keys = {}
  for key, _ in pairs(tabl) do
    table.insert(keys, key)
  end
  return keys
end

--
-- Returns a list of table's vales
--
---@param tabl table
---@return table # list of keys
function Tabl.vals(tabl)
  local vals = {}
  for _, val in pairs(tabl) do
    table.insert(vals, val)
  end
  return vals
end


--
-- Merges two tables together
--
---@param ... table[] Tables to merge
---@return table The merged table
function Tabl.merge(...)
  local merged = {}

  for i, tbl in ipairs({...}) do
    for k, v in pairs(tbl) do
      merged[k] = v
    end
  end

  return merged
end


--
-- Concatenate list-like tables
--
---@param ... table[] Lists to concatenate
---@returns table 
function Tabl.concat(...)
  local merged = {}

  for i, tbl in ipairs({...}) do
    for k, v in pairs(tbl) do
      table.insert(merged, v)
    end
  end

  return merged
end


--
-- Like `table.insert`, but inserts all items
--
---@param tabl table Table to insert items into
function Tabl.insert(tabl, ...)
  local toAdd = {...}

  for k, v in ipairs(toAdd) do
    table.insert(tabl, v)
  end

  return tabl
end


--
-- Determine if a table contains a given object
--
---@param tabl table A table containing some sort of data
---@param elem any An object to search the table for
---@return boolean # true if the element could be f
function Tabl.contains(tabl, elem)
  return hs.fnutils.contains(tabl, elem)
end


--
-- Returns the value at a given path in an object. Path is given as a vararg list of keys.
--
---@param tabl table an object
---@param ... string A vararg list of keys
---@return any # a value or nil
function Tabl.path(tabl, ...)
  local value, found, path = tabl, false, {...}
  -- local value, path = nil, {...}
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
---@param obj table
---@param path string Dot-path string key
---@param msg? string Optional error message when value is nil
---@returns nil
function Tabl.haspath(obj, path, msg)
  local pathdefined = Tabl.path(obj, path)

  if (tc.notNil(pathdefined)) then
    return true
  end

  if (tc.notNil(msg)) then
    error(msg)
  end

  return false
end


--
-- Maps an array of string keys to associated values in a table
--
---@param tabl table Table to pick values from
---@param keys string[] List of keys to pick from table
function Tabl.pick(tabl, keys)
  local picked = {}

  for i, key in ipairs(keys) do
    table.insert(picked, params.default(Tabl.path(tabl, key), ""))
  end

  return picked
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
function table.clone(org)
  return {table.unpack(org)}
end


return Tabl