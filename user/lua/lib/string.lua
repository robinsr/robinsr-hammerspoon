local regex      = require 'rex_pcre'
local lustache   = require 'lustache'
local plstring   = require 'pl.stringx'
local plstrio    = require 'pl.stringio'
local pretty     = require 'pl.pretty'
local pldir      = require 'pl.dir'
local plpath     = require 'pl.path'
local plseq      = require 'pl.seq'
local plutils    = require 'pl.utils'
local pltypes    = require 'pl.types'
local types      = require 'user.lua.lib.typecheck'
local lists      = require 'user.lua.lib.list'


--
-- DO NOT extend Lua's native `string`. Breakage includes:
--  - Aspect templates
--
-- string.replace = strings.replace
-- string.startswith = strings.startswith
-- string.endswith = strings.endswith

local function assert_string(str, num)
  if not types.isString(str) then
    error('Need string, arg #'..tostring(num or 1))
  end
end


local CHAR = {
  newline = utf8.char(0x000A),
}



---@class String
local strings = {}

strings.char = CHAR

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


function strings.contains(str, sub)
    return string.find(str, sub, 1, true) ~= nil
end

function strings.startswith(str, start)
    return string.sub(str, 1, #start) == start
end

function strings.endswith(str, ending)
    return ending == "" or string.sub(str, -#ending) == ending
end


--
-- Builds out a format string with parameters
--
---@param msg string The format string
---@param ... any Format string variables
---@return string
function strings.fmt(msg, ...)
  return string.format(msg, table.unpack{...})
end

--
-- Gonna try something here
--
-- -@param ... any Format string variables
-- -@return string
-- function string:fmt(...)
--   local msg = self --[[@as string]]
--   return string.format(msg, table.unpack{...})
-- end


--
-- Applies title case to a string
--
---@param str string
---@return string
function strings.title(str, ...)
  return plstring.title(str)
end


--
-- Builds out a format string with parameters and applies title casing
--
---@param msg string
---@return string
function strings.titlefmt(msg, ...)
  return plstring.title(string.format(msg, table.unpack{...}))
end


--
-- Compiles a template string
--
---@param tmplstr string
---@param vars? table Fallback table of template variables
function strings.tmpl(tmplstr, vars)
  assert_string(tmplstr)
  vars = vars or {}

  local repl_pat = '((%s*)%{([%-%+]?)([%.%w]+)([%-%+]?)%}(%s*))'

  local function searchtable(target, key)
    local path = strings.split(key, '.')
    local current = target

    for key in plseq.list(strings.split(key, '.')) do
      if types.isTable(current[key]) then
        current = current[key]
      end

      if current[key] then
        return current[key]
      end
    end
  end

  return function(tabl)
    return tmplstr:gsub(repl_pat, function(match, pre, preop, var, postop, tail)
      -- require('zzz_dump')({ match, pre, preop, var, postop, tail, tabl })

      local repl = ''

      if pltypes.is_callable(tabl) then
        repl = tabl(var) or ''
      else
        repl = searchtable(tabl, var) or searchtable(vars, var) or ''
      end

      if repl == '' and preop == '-' then pre = '' end
      if repl == '' and postop == '-' then tail = '' end
      if repl ~= '' and preop == '+' then pre = ' ' end
      if repl ~= '' and postop == '+' then tail = ' ' end

      return pre..repl..tail
    end)
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
-- WIP
-- Given a non-wildcard pattern, returns a list of matching strings
--
function strings.expand(pattern)
  local matches = {}
end


--
-- Returns an interface for building multi-line strings
--
function strings.linewriter()
  local NEWLINE = CHAR.newline
  local output = plstrio:create()

  ---@class lib.string.linewriter
  local LineWriter = {}

  local next = ''

  function LineWriter:add(line)
    assert_string(line)
    output:write(next..line)
    next = CHAR.newline
    return self
  end

  function LineWriter:addf(pat, ...)
    assert_string(pat)
    output:writef((next..pat):format(table.unpack({...})))
    next = CHAR.newline
    return self
  end

  function LineWriter:write(part)
    assert_string(part)
    output:write(next..part)
    next = ''
    return self
  end

  function LineWriter:writef(pat, ...)
    assert_string(pat)
    output:writef((next..pat):format(table.unpack({...})))
    next = ''
    return self
  end

  function LineWriter:cr()
    output:write(CHAR.newline)
    return self
  end
  
  function LineWriter:value()
    return output:value()
  end
  
  return setmetatable({}, { __index = LineWriter })
end



string._replace = strings.replace
string._startswith = strings.startswith
string._endswith = strings.endswith
string._trim = strings.trim
string._truncate = strings.truncate
string._ifEmpty = strings.ifEmpty
string._contains = strings.contains
string._startswith = strings.startswith
string._endswith = strings.endswith
string._fmt = strings.fmt
string._title = strings.title
string._titlefmt = strings.titlefmt
string._tmpl = strings.tmpl
string._fmt = strings.fmt
string._fmt = strings.fmt
string._join = strings.join
string._split = strings.split
string._fmt = strings.fmt
string._padStart = strings.padStart
string._padEnd = strings.padEnd
string._padMid = strings.padMid
string._replace = strings.replace
string._expand = strings.expand


return strings