local pltable = require 'pl.tablex'
local plseq   = require 'pl.seq'
local plmap   = require 'pl.Map'
local types   = require 'user.lua.lib.typecheck'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'


---@class Table
---@operator call:Table


---@class Table
local Table = {}

local TablMeta = {}

TablMeta.__index = Table


--
-- Returns a new table instance
--
---@return Table
 local function create(t, init)
  return setmetatable(init or {}, TablMeta)
end

TablMeta.__call = function(tabl, init) return create(tabl, init) end

--
-- Returns a list keys found in `tabl`
--
---@param tabl table
---@return string[] List of table's keys
function Table.keys(tabl)
  params.assert.tabl(tabl)

  local keys = {}

  for key, _ in pairs(tabl) do
    table.insert(keys, key)
  end

  return keys
end


--
-- Returns a interator of key/value pairs in table
--
---@generic K,V
---@param tabl table<K,V>
---@return fun():K,V
function Table.entries(tabl)
  return plmap(tabl):iter()
end


--
-- Returns the table as a list of key/value tuples
--
---@param tabl table
---@return any[] list of keys
function Table.list(tabl)
  params.assert.tabl(tabl)

  local tups = {}

  for key, val in pairs(tabl) do
    table.insert(tups, { key, val })
  end

  return tups
end


--
-- Returns a list of values found in `tabl`
--
---@param tabl table
---@return any[] list of keys
function Table.values(tabl)
  params.assert.tabl(tabl)

  local vals = {}

  for _, val in pairs(tabl) do
    table.insert(vals, val)
  end

  return vals
end

-- Alias for Table:values
Table.vals = Table.values


--
-- Returns a single table composed of the combined key-values of all table parameters
--
---@param ... table[] Tables to merge
---@return table The merged table
function Table.merge(...)
  local tables = table.pack(...)
  params.assert.tabl(tables)

  local merged = {}

  for i, tabl in ipairs(tables) do
    params.assert.tabl(tabl, i)

    for k, v in pairs(tabl) do

      if types.isTable(v) and types.isTable(merged[k]) then
        merged[k] = Table.merge(merged[k], v)
      else
        merged[k] = v
      end
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
  params.assert.tabl(tables)

  local merged = {}

  for i, tabl in ipairs(tables) do
    params.assert.tabl(tabl, i)
    
    for k, v in pairs(tabl) do
      table.insert(merged, v)
    end
  end

  return merged
end


--
-- Determine if a table contains a given object
--
---@param tabl table  - A table containing some sort of data
---@param elem any    - An object to search the table for
---@return boolean    - True if the element could be f
function Table.contains(tabl, elem)
  for k, el in pairs(tabl) do
    if el == elem then
      return true
    end
  end

  return false
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
-- Basically just nil checks the arguments
--
---@param tabl table
---@param key string
---@param value any
---@return table
function Table.set(tabl, key, value)
  params.assert.tabl(tabl, 1)
  params.assert.string(key, 2)
  params.assert.notNil(value, 3)

  tabl[key] = value

  return tabl
end


--
-- Assert not nil on a deep nested value in a table, using a dot-path string
--
---@param tabl table
---@param path string Dot-path string key
---@param nilMsg? string Optional error message when value is nil
---@return boolean 
function Table.haspath(tabl, path, nilMsg)
  params.assert.tabl(tabl, 1)

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
  params.assert.tabl(tabl)
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
  params.assert.tabl(tabl)

  local keys = Table.keys(tabl)

  if #keys > 0 then
    return false
  end

  return true
end


--
-- Returns a serializable copy of the table. Optionally
-- pass a string array of allowed getters to copy
--
---@param tabl table
---@param getters? string[]
function Table.toplain(tabl, getters)
  getters = getters or {}

  local copy = pltable.copy(tabl)

  for key, val in pairs(copy) do
    if strings.startswith(key, '__') then
      copy[key] = nil

    elseif type(val) == 'table' then
      copy[key] = Table.toplain(val)

    elseif type(val) == 'userdata' then
      copy[key] = nil

    elseif type(val) == 'function' then
      if Table.contains(getters, key) then
        copy[key] = tabl[val]()
      else
        copy[key] = nil
      end
    end
  end

  return setmetatable(copy, table)
end


return setmetatable({}, TablMeta)