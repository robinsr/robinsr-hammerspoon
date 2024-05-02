local M      = require 'moses' -- 1.6.1 only
local fmt    = require 'user.lua.util.fmt'
local json   = require 'user.lua.util.json'
local tc     = require 'user.lua.util.typecheck'

-- local log = logger.new('util', 'debug')

local U = {}

U.log = require('user.lua.util.logger').log
U.fmt = fmt
U.json = json
U.notNil = tc.notNil
U.isString = tc.isString
U.isTable = tc.isTable

U.d1 = { depth = 1 }
U.d2 = { depth = 2 }
U.d3 = { depth = 3 }

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


--
-- Will null-check first param returning second param if nil
--
---@param t any|nil Possible nil value
---@param default any The default value to return
---@alias pick function
function U.default(t, default)
  return t ~= nil and t or default
end

function U.pick(tabl, keys)
  local picked = {}

  for i, key in ipairs(keys) do
    table.insert(picked, U.default(U.path(tabl, key), ""))
  end

  return picked
end


--
-- Returns a list of table's keys
--
---@param tabl table
---@return table # list of keys
function U.keys(tabl)
  local keys = {}
  for key, _ in pairs(tabl) do
    table.insert(keys, key)
  end
  return keys
end


--
-- Merges two tables together
--
---@deprecated
function U.merge_tables(first_table, second_table)
  for k, v in pairs(second_table) do
    first_table[k] = v
  end

  return first_table
end


--
-- Adds all values in listB to listA
--
---@param listA table
---@param listB table
---@returns table # listA with all of listB's entries
function U.concat(listA, listB)
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
function U.contains(tabl, elem)
  return hs.fnutils.contains(tabl, elem)
end


--
-- Returns a list-like table of strings, split on
--
---@param line string String to split
---@param char? string Optional split character
function U.split(line, char)
  local pattern = fmt("[^%s]+", char or "%s")

  local items = {}
  for token in string.gmatch(line, pattern) do
     table.insert(items, token)
  end

  return items
end


--
-- Returns the value at a given path in an object. Path is given as a vararg list of keys.
--
---@param tabl table an object
---@param ... string A vararg list of keys
---@return any # a value or nil
function U.path(tabl, ...)
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
function U.haspath(obj, path, msg)
  local pathdefined = U.path(obj, path)

  if (U.notNil(pathdefined)) then
    return true
  end

  if (U.notNil(msg)) then
    error(msg)
  end

  return false
end

--
-- Delay execution of function fn by msec
--
---@param msec integer delay in MS
---@param fn function function to run after delay
---@returns nil
function U.delay(msec, fn)
  hs.timer.doAfter(msec, fn)
end

return U
