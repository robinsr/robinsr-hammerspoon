--
--
-- TODO REMOVE 
-- local logr    = require 'user.lua.util.logger'
-- local deletemelog = logr.new('TABLE', 'debug')
--
--
--


local tc = require 'user.lua.lib.typecheck'
local params = require 'user.lua.lib.params'

local isTable = tc.isTable
local isString = tc.isString
local isNil = tc.isNil
local notNil = tc.notNil

local function errMsg(num, param)
  return 'Parameter #' .. tostring(num) .. ' is not a table, rather ' .. type(param)
end


---@class TablProto
local TablProto = {}

--
-- Returns a list keys found in `tabl`
--
---@param tabl table
---@param strict? boolean Throw error if table is nil
---@return string[] List of table's keys
function TablProto.keys(tabl, strict)
  -- deletemelog.d('TablProto#keys called on:', hs.inspect(tabl))

  local keys = {}

  if isTable(tabl) then
    for key, _ in pairs(tabl) do
      table.insert(keys, key)
    end
  else
    if strict == true then error(errMsg(1, tabl)) end
  end

  return keys
end

--
-- Returns a list of values found in `tabl`
--
---@param tabl table
---@param strict? boolean Throw error if table is nil
---@return any[] list of keys
function TablProto.vals(tabl, strict)
  local vals = {}

  if isTable(tabl) then
    for _, val in pairs(tabl) do
      table.insert(vals, val)
    end
  end

  return vals
end


--
-- Returns a single table composed of the combined key-values of all table parameters
--
---@param ... table[] Tables to merge
---@return table The merged table
function TablProto.merge(...)
  local merged = {}
  local tables = {...}

  for i, tabl in ipairs(tables) do
    if isTable(tabl) then
      for k, v in pairs(tabl) do
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
function TablProto.concat(...)
  local merged = {}
  local tables = {...}

  for i, tabl in ipairs(tables) do
    if isTable(tabl) then
      for k, v in pairs(tabl) do
        table.insert(merged, v)
      end
    end
  end

  return merged
end


--
-- Like `table.insert`, but inserts all items
--
---@param tabl table Table to insert items into
---@param ... any[] Elements to insert
---@return table
function TablProto.insert(tabl, ...)
  local toAdd = {...}

  if (not isTable(tabl)) then
    error(errMsg(table))
  end

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
function TablProto.contains(tabl, elem)
  return hs.fnutils.contains(tabl, elem)
end


--
-- Returns the value at a given path in an object. Path is given as a vararg list of keys.
--
---@param tabl table an object
---@param ... string A vararg list of keys
---@return any Either a value if found or nil
function TablProto.get(tabl, ...)
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
function TablProto.haspath(tabl, path, nilMsg)
  if tc.isTable(tabl) then
    local pathdefined = TablProto.get(tabl, path)

    if (tc.notNil(pathdefined)) then
      return true
    end

    if isString(nilMsg) then error(nilMsg) end
  end

  return false
end


--
-- Returns true if `tabl` is contains a non-nil value for key `key`
--
---@param tabl table Table to check
---@param key string String-key to check for nill-ness
---@param strict? boolean Throw error if table is nil
---@return boolean
function TablProto.has(tabl, key, strict)
  if (not isTable(tabl)) then
    if strict then error(errMsg(1, tabl)) end
  end

  return notNil(TablProto.get(tabl, key))
end


--
-- Maps an array of string keys to associated values in a table
--
---@param tabl table Table to pick values from
---@param keys string[] List of keys to pick from table
---@return table
function TablProto.pick(tabl, keys)
  local picked = {}

  for i, key in ipairs(keys) do
    table.insert(picked, params.default(TablProto.get(tabl, key), ""))
  end

  return picked
end


--
-- Returns true if `tabl` is a lua table with zero string keys
--
---@param tabl table Table to check for emptiness
---@return boolean
function TablProto.isEmpty(tabl)
  if tc.isTable(tabl) then
    local keys = TablProto.keys(tabl)

    if #keys > 0 then
      return false
    end
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
-- function table.clone(org)
--   return {table.unpack(org)}
-- end


local TablMeta = {}

TablMeta.__index = TablProto

--
-- Returns 
--
---@return TablProto A new Table instance 
TablMeta.__call = function(t, init)
  return setmetatable(init or {}, TablMeta)
end

return setmetatable({}, TablMeta)