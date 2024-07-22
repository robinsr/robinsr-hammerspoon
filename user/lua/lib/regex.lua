local rexpcre = require 'rex_pcre'
local rfc6570 = require 'silva.template'
local plpath  = require 'pl.path'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'



---@class GlobThing
---@operator call:fun(str: string): boolean
---@field orig string
---@field length integer
---@field negated boolean
---@field pattern string
---@field compiled table
---@field info table

---@class GlobThings
---@field patterns string[]
---@field regexes GlobThing[]
---@field length number

---@alias GlobMatchFn fun(str: string): boolean



local Regex = {}


--
-- Maps a Lua-style pattern string to a PCRE pattern string
--
---@param pattern string
---@return string
function Regex.to_pcre_regex(pattern)
  params.assert.string(pattern)

  pattern = pattern:gsub('!', '')
  pattern = plpath.normcase(pattern)
  -- escape any Lua 'magic' characters in a string
  pattern = pattern:gsub('[%+%[%]%$%^%%%?%*]','%%%1')

  -- replace lua's dot literal, with PCRE dot literal
  pattern = pattern:gsub('[%.]', '\\.')

  -- replace lua's * with PCRE greedy dot-star
  pattern = pattern:gsub('%%%*','.*')

  -- replace lua's ?, with PCRE single dot-star
  pattern = pattern:gsub('%%%?','.')

  -- Adds start/end anchors
  pattern = '^'..pattern..'$'

  return pattern
end


--
-- Returns a single GlobThing (compiled PCRE regex and metadata) for a pattern
--
---@param pattern string
---@return GlobThing
function Regex.glob(pattern)
  params.assert.string(pattern)
  
  local pcre_pattern = Regex.to_pcre_regex(pattern)
  local pcre_regex = rexpcre.new(pcre_pattern, 'i')

  return setmetatable({
    orig = pattern,
    length = string.len(pattern),
    negated = string.match(pattern, '^!.*') ~= nil,
    pattern = pcre_pattern,
    compiled = pcre_regex,
    info = pcre_regex:fullinfo(),
  }, {
    __call = function(reg, filename)
      filename = plpath.normcase(filename)
      
      local match = reg.compiled:find(filename) ~= nil
      
      if match and not reg.negated then
        return true
      end

      if not match and reg.negated then
        return true
      end

      return false
    end
  })
end


--
-- Returns a multi-GlobThing (a GlobThings) that uses multiple patterns
--
---@param patterns string|string[]
---@return GlobThings
function Regex.globs(patterns)
  local flattened = lists({ patterns }):flatten()

  local globs = flattened:map(Regex.glob):values()
  local total_length = lists(globs):reduce(0, function(len, glob) return len + glob.length end)

  local glob_thing = setmetatable({
    patterns = flattened:values(),
    regexes = globs,
    length = total_length,
  }, {
    __call = function(glbs, input)
      return lists(glbs.regexes):every(function(matcher) return matcher(input) end)
    end
  })

  return glob_thing
end


--
-- Returns true if `str` matches `pattern`, using PCRE regex
--
---@param pattern string
---@param str string
---@return boolean
function Regex.regex_match(pattern, str)
  local match, err = rexpcre.new(pattern, 'i'):match(str)

  if err ~= nil then
    error(err)
  end

  return match ~= nil
end


--
-- Implements an URI Template (RFC 6570 - level 3) matching engine with capture.
-- 
-- All operator defined in the RFC 6570 are supported:
--  * {var} simple string expansion
--  * {+var} reserved character string expansion
--  * {#var} fragment expansion, crosshatch-prefixed
--  * {.var} label expansion, dot-prefixed
--  * {/var} path segments, slash-prefixed
--  * {;var} path-style parameters, semicolon-prefixed
--  * {?var} form-style query, ampersand-separated
--  * {&var} form-style query continuation
-- --
function Regex.uri(pattern)
  return rfc6570(pattern)
end



--
-- WIP - currently just addes start/end anchors and escapes spaces
--
function Regex.topattern(str)
  return ('^%s$'):format(strings.replace(str, '%s', '\\ '))
end


return Regex