local penstr = require 'pl.stringx'
local tc     = require 'user.lua.lib.typecheck'
local P      = require 'user.lua.lib.params'

local Str = {}


--
-- Trims whitespace from a string
--
---@param str string Untrimmed input string
---@return string The trimmed string
function Str.trim(str)
  return penstr.strip(str)
end

--
-- Builds out a format string with parameters
--
---@param msg string The format string
---@param ... any Format string variables
---@return string The final string
function Str.fmt(msg, ...)
  return string.format(msg, table.unpack{...})
end

--
-- Creates a string of joined list elements
--
---@param tabl table List to join
---@param sep string? Separator string
function Str.join(tabl, sep)
  local separator = P.default(sep, '')
  return table.concat(tabl, separator)
end


--
-- Returns a list-like table of strings, split on
--
---@param line string String to split
---@param char? string Optional split character
---@return string[]
function Str.split(line, char)
  local pattern = Str.fmt("[^%s]+", char or "%s")

  local items = {}
  for token in string.gmatch(line, pattern) do
     table.insert(items, token)
  end

  return items
end


--
-- Produces a string of certain length
--
---@param str string The input string to pad or truncate
---@param count integer The desired resulting string length
---@return string
function Str.pad(str, count)
  if (tc.isNil(str) or not tc.isString(str)) then
    return ""
  end

  while string.len(str) < count do
    str = str.." "
  end

  return string.sub(str, 1, count)
end


--
-- Replace matching parts of a string
--
---@param str string Input string
---@param old string String to remove
---@param new string String to 
function Str.replace(str, old, new)
  return penstr.replace(str, old, new)
end

return Str