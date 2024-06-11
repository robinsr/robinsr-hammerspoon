local regex      = require 'rex_pcre'
local lustache   = require 'lustache'
local plstring   = require 'pl.stringx'
local pretty     = require 'pl.pretty'
local pldir      = require 'pl.dir'
local plpath     = require 'pl.path'
local plutils    = require 'pl.utils'
local types      = require 'user.lua.lib.typecheck'
local lists      = require 'user.lua.lib.list'

---@module 'lib.string'
local strings = {}

local function assert_string(str, num)
  if not types.isString(str) then
    error('Need string, arg #'..tostring(num or 1))
  end
end


--
-- Trims whitespace from a string
--
---@param str string Untrimmed input string
---@return string The trimmed string
function strings.trim(str)
  return plstring.strip(str)
end


--
-- Shorten a string to a specified length
--
---@param str string
---@param len integer 
---@return string
function strings.truncate(str, len)
  return plstring.shorten(str, len)
end


--
-- Guaranteed string returned
--
---@param str string|nil
---@param replace string
---@return string
function strings.ifEmpty(str, replace)
  if (types.isNil(str) or not types.isString(str)) then
    return tostring(replace or '')
  end

  if (str == '') then
    return tostring(replace)
  end

  return str --[[@as string]]
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
---@param separator string? Separator string
function strings.join(tabl, separator)
  local separator = separator or ''
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
-- Produces a string of certain length, padding at beginning of string
--
---@param str string The input string to pad or truncate
---@param length integer The desired resulting string length
---@param padchar? string (optional) The character to pad with
---@return string
function strings.padStart(str, length, padchar)
  if (types.isNil(str) or not types.isString(str)) then
    return ""
  end

  local insert = 0

  while string.len(str) < length do
    insert = insert + 1
    str = string.rep(padchar or ' ', insert)..str
  end

  return string.sub(str, 1, length)
end



--
-- Produces a string of certain length, padding at end of string
--
---@param str string The input string to pad or truncate
---@param length integer The desired resulting string length
---@return string
function strings.padEnd(str, length)
  if (types.isNil(str) or not types.isString(str)) then
    return ""
  end

  while string.len(str) < length do
    str = str.." "
  end

  return string.sub(str, 1, length)
end



-- Would like to make this a format function, with the pattern "%%@80" standing in for pad area
---
-- `padMid("This thing%%@30%s", 'abc.123')` 
--     --> "This thing             abc.123"   (length = 30)

--
-- Combines two strings, padding in middle to reach desired string length
--
---@param str1 string Pre-padding input string
---@param str2 string Post-padding input string
---@param length integer The desired resulting string length
---@return string
function strings.padMid(str1, str2, length)
  if (types.isNil(str1) or not types.isString(str1)) then
    str1 = ""
  end

  if (types.isNil(str2) or not types.isString(str2)) then
    str2 = ""
  end

  length = length or 1

  local combo = str1..str2
  local insert = 0

  while string.len(combo) < length do
    insert = insert + 1
    combo = str1..string.rep(' ', insert)..str2
  end

  return string.sub(combo, 1, length)
end


--
-- Replace matching parts of a string
--
---@param str string Input string
---@param old string String to remove
---@param new string String to 
function strings.replace(str, old, new)
  return plstring.replace(str, old, new)
end

--
-- Pattern Matcher
--
--


--- escape any Lua 'magic' characters in a string
-- @param s The input string
function escape(s)
  assert_string(s, 1)
  return (s:gsub('[%-%+%[%]%$%^%%%?%*]','%%%1'):gsub('[%.]', '\\.'))
end

local function filemask(mask)
  mask = escape(plpath.normcase(mask))
  return '^'..mask:gsub('%%%*','.*'):gsub('%%%?','.')..'$'
end


local function fnmatch(filename, pattern)
  local fpattern = filemask(pattern)
  local match = regex.new(fpattern, 'i'):find(plpath.normcase(filename)) ~= nil
  
  -- print(string.format('%s → %s ... %s=%q ', pattern, fpattern, filename, match))

  return match
end


---@alias GlobMatchFn fun(str: string): boolean

--
-- Returns a glob matching function
--
---@param patterns string|string[]
---@return GlobMatchFn
function strings.glob(patterns)

  local map_pattern = function(p)
    local is_negation = string.match(p, '^!.*')
    local pattern = p:gsub('!', '')

    return function(filename)
      local match = fnmatch(filename, pattern)
      
      if match and not is_negation then
        return true
      end

      if not match and is_negation then
        return true
      end

      return false
    end
  end

  local mapped = lists.new({ patterns }):flatten():map(map_pattern)

  return function(str)
    return mapped:every(function(matcher)
      return matcher(str)
    end)
	end
end

return strings