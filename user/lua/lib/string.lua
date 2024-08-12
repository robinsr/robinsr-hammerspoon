local plstring   = require 'pl.stringx'
local plstrio    = require 'pl.stringio'
local plseq      = require 'pl.seq'
local func       = require 'user.lua.lib.func'
local params     = require 'user.lua.lib.params'
local types      = require 'user.lua.lib.typecheck'

local isNil = types.isNil
local notNil = types.notNil
local isString = types.is.strng
local notString = types.is_not.strng

local CHAR = {
  newline = utf8.char(0x000A),
}


---@class String : string
---@operator call:String
local strings = {
  char = CHAR
}

local strings_meta = debug.getmetatable('')

strings_meta.__index = function(str, key)
  if string[key] ~= nil then
    return string[key]
  end

  if strings[key] ~= nil then
    return strings[key]
  end

  return nil
end

strings_meta.__call = function(str, val, repl)
  return strings.new(val, repl)
end


--
-- Returns a string from any input type; Defaults to empty string
--
---@param str? any
---@param repl? any
---@return String
function strings.new(str, repl)
  local value = str

  if isNil(str) or notString(str) or str == '' then
    value = tostring(repl or '')
  end

  return debug.setmetatable(value, strings_meta) --[[@as String]]
end


--
-- Trims whitespace from a string
--
---@param str string Untrimmed input string
---@return String
function strings.trim(str)
  return strings.new(plstring.strip(str))
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
-- Returns true if string `str` matches pattern `patt`
--
---@param str   string
---@param patt  string
---@return boolean
function strings.contains(str, patt)
  return string.find(str, patt, 1, true) ~= nil
end


--
-- Returns true if the first N characters of string `str` are identical to `part`
--
---@param str   string
---@param part  string
---@return boolean
function strings.startswith(str, part)
  return string.sub(str, 1, #part) == part
end


--
-- Returns true if the last N characters of string `str` are identical to `part`
--
---@param str   string
---@param part  string
---@return boolean
function strings.endswith(str, part)
  return part == "" or string.sub(str, -#part) == part
end


--
-- Returns true if string `str` is a 0-character, empty string
--
---@param str   string
---@return boolean
function strings.empty(str)
  return (str or ""):len() == 0
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
---@return String
function strings.replace(str, old, new)
  return strings.new(plstring.replace(str, old, new))
end


--
-- WIP
-- Given a non-wildcard pattern, returns a list of matching strings
--
function strings.expand(pattern)
  local matches = {}
end


--
-- Compiles a template string
--
---@param tmplstr string
---@param vars? table Fallback table of template variables
function strings.tmpl(tmplstr, vars)
  params.assert.string(tmplstr)

  vars = vars or {}

  local repl_pat = '((%s*)[$]?%{([%-%+]?)([%w%d%.%-%_]+)([%-%+]?)%}(%s*))'

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

      if types.isCallable(tabl) then
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
-- Returns an interface for building multi-line strings
--
function strings.linewriter()
  local NEWLINE = CHAR.newline
  local output = plstrio:create()

  ---@class lib.string.linewriter
  local LineWriter = {}

  local next = ''

  function LineWriter:add(line)
    params.assert.string(line)

    output:write(next..line)
    next = CHAR.newline
    return self
  end

  function LineWriter:addf(pat, ...)
    params.assert.string(pat)

    output:writef((next..pat):format(table.unpack({...})))
    next = CHAR.newline
    return self
  end

  function LineWriter:write(part)
    params.assert.string(part)

    output:write(next..part)
    next = ''
    return self
  end

  function LineWriter:writef(pat, ...)
    params.assert.string(pat)

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


return setmetatable({}, strings_meta) --[[@as String]]