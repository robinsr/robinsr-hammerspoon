local penstr   = require 'pl.stringx'
local lustache = require 'lustache'
local types    = require 'user.lua.lib.typecheck'
local P        = require 'user.lua.lib.params'

local inspect = require('inspect')

local strings = {}


--
-- Trims whitespace from a string
--
---@param str string Untrimmed input string
---@return string The trimmed string
function strings.trim(str)
  return penstr.strip(str)
end

function strings.truncate(str, len)
  return penstr.shorten(str, len)
end


function strings.ifEmpty(str, replace)
  if (types.isNil(str) or not types.isString(str)) then
    return tostring(replace or '')
  end

  if (str == '') then
    return tostring(replace)
  end

  return str
end

--
-- Builds out a format string with parameters
--
---@param msg string The format string
---@param ... any Format string variables
---@return string The final string
function strings.fmt(msg, ...)
  return string.format(msg, table.unpack{...})
end


--
-- Compiles a template string
--
function strings.tmpl(tmplstr)
  if not types.isString(tmplstr) then
    error(strings.fmt('Invalid template string: %s', tmplstr or 'nil'))
  end

  local render = lustache:compile(tmplstr)

  if render == nil then
    error(strings.fmt('Error compiling lustache template: %q', tmplstr))
  else
    return function(args) return render(args) end
  end
end


--
-- Creates a string of joined list elements
--
---@param tabl table List to join
---@param sep string? Separator string
function strings.join(tabl, sep)
  local separator = P.default(sep, '')
  if types.isTable(tabl) then
    return table.concat(tabl, separator)
  else
    return ''
  end
end


--
-- Returns a list-like table of strings, split on
--
---@param line string String to split
---@param char? string Optional split character
---@return string[]
function strings.split(line, char)
  local pattern = strings.fmt("[^%s]+", char or "%s")

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
function strings.pad(str, count)
  if (types.isNil(str) or not types.isString(str)) then
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
function strings.replace(str, old, new)
  return penstr.replace(str, old, new)
end

return strings