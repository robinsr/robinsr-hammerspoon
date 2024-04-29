local M      = require 'moses' -- 1.6.1 only
local fmt    = require 'user.lua.util.fmt'
local json   = require 'user.lua.util.json'
local logger = require 'user.lua.util.logger'

local log = logger.new('util', 'debug')

local utils = {}

utils.log = logger.log
utils.fmt = fmt
utils.json = json

--[[
  LuaLSP types:

  nil
  any
  boolean
  string
  number
  integer
  function
  table
  thread
  userdata
  lightuserdata
]]


-- Nullchecks first param returning second param if nil
---@param t any|nil Possible nil value
---@param default any The default value to return
---@alias pick function
function utils.default(t, default)
  return t ~= nil and t or default
end
utils.pick = utils.default


-- A very explicit null check
---@param i any|nil Possibly a nil value
---@return boolean # true when param nil
function utils.notNil(i)
  if (type(i) ~= 'nil') then return true else return false end
end

-- Type-check is string
---@param i any|nil Possibly a nil value
---@return boolean # true when param is a string
function utils.isString(i)
  if (type(i) == 'string') then return true else return false end
end

-- Type-check is table
---@param i any|nil Possibly a nil value
---@return boolean # true when param is a table
function utils.isTable(i)
  if (type(i) == 'table') then return true else return false end
end



-- Returns a list of table's keys
---@param tabl table
---@return table # list of keys
function utils.keys(tabl)
  local keys = {}
  for key, _ in pairs(tabl) do
    table.insert(keys, key)
  end
  return keys
end


-- Logs result of hs.inspect()
---@deprecated
function utils.inspect_item(item)
  log.d(hs.inspect.inspect(item))
end


-- Merges two tables together
---@deprecated
function utils.merge_tables(first_table, second_table)
  for k, v in pairs(second_table) do
    first_table[k] = v
  end

  return first_table
end


-- Adds all values in listB to listA
---@param listA table
---@param listB table
---@returns table # listA with all of listB's entries
function utils.concat(listA, listB)
  for k, v in pairs(listB) do
    table.insert(listA, v)
  end

  return listA
end


--
-- Determine if a table contains a given object
--
---@param tabl table A table containing some sort of data
---@param elem any An object to search the table for
--
---@return boolean # true if the element could be f
function utils.contains(tabl, elem)
  return hs.fnutils.contains(tabl, elem)
end


-- Returns a list-like table of strings, split on
---@param line string String to split
---@param char? string Optional split character
function utils.split(line, char)
  local pattern = fmt("[^%s]+", char or "%s")

  local items = {}
  for token in string.gmatch(line, pattern) do
     table.insert(items, token)
  end

  return items
end


-- Returns the value at a given path in an object. Path is given as a vararg list of keys.
---@param tabl table an object
---@param ... string A vararg list of keys
---@return any # a value or nil
function utils.path(tabl, ...)
  local value, path = tabl, {...}
  for i, p in ipairs(path) do
    if (value[p] == nil) then return end
    value = value[p]
  end
  return value
end

-- Assert not nil on a deep nested value in a table, using a dot-path string
---@param obj table
---@param path string Dot-path string key
---@param msg? string Optional error message when value is nil
---@returns nil
function utils.haspath(obj, path, msg)
  local pathdefined = utils.path(obj, path)

  if (utils.notNil(pathdefined)) then
    return true
  end

  if (utils.notNil(msg)) then
    error(msg)
  end

  return false
end

-- Delay execution of function fn by msec
---@param msec integer delay in MS
---@param fn function function to run after delay
---@returns nil
function utils.delay(msec, fn)
  hs.timer.doAfter(msec, fn)
end


return utils
