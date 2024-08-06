local plpath = require "pl.path"
local regex  = require 'rex_pcre'
local types  = require "user.lua.lib.typecheck"


local url_matcher = regex.new("^https?:\\/\\/(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&\\\\/=]*)$", 'i')


---@epos ks.param.err_msg
local errs = {
  TYPE   = 'Parameter #%d is not a %s, rather a %s',
  NIL    = 'Parameter #%d is required to be non-nil',
  MATCH  = 'Parameter #%d is not a %s: %s',
  CUSTOM = 'Invalid %s - parameter #%d is not a string or number, rather a %s'
}

local Params = {}

Params.errs = errs

Params.assert = {}

--
-- Throws invalid parameter error if `val` is nil
--
---@param val any
---@param pos? integer Parameter position
function Params.assert.notNil(val, pos)
  if types.isNil(val) then
    error(errs.NIL:format(pos or 1), 2)
  end
end


--
-- Throws invalid parameter error if `val` is not of type "table"
--
---@param tabl any
---@param pos? integer Parameter position
function Params.assert.tabl(tabl, pos)
  if (not types.isTable(tabl)) then
    error(errs.TYPE:format(pos or 1, 'table', type(tabl)), 2)
  end
end


--
-- Throws invalid parameter error if `val` is not of type "string"
--
---@param val any
---@param pos? integer Parameter position
function Params.assert.string(val, pos)
  if (not types.isString(val)) then
    error(errs.TYPE:format(pos or 1, 'string', type(val)), 2)
  end
end


--
-- Throws invalid parameter error if `val` is not of type "number"
--
---@param val any
---@param pos? integer Parameter position
function Params.assert.number(val, pos)
  if (not types.isNum(val)) then
    error(errs.TYPE:format(pos or 1, 'number', type(val)), 2)
  end
end


--
-- Throws invalid parameter error if `val` is not of type "function"
--
---@param val any
---@param pos? integer Parameter position
function Params.assert.func(val, pos)
  if (not types.isFunc(val)) then
    error(errs.TYPE:format(pos or 1, 'function', type(val)), 2)
  end
end


--
-- Asserts that `val` is a valid filesystem path
--
---@param val any
---@param pos? integer Parameter position
function Params.assert.path(val, pos)
  if (not types.isString(val)) then
    error(errs.TYPE:format(pos or 1, type(val)), 2)
  end

  local isDir = plpath.isdir(val)
  local isFile = plpath.isfile(val)

  if not isDir and not isFile then
    error(errs.MATCH:format(pos or 1, 'file or directory', val), 2)
  end
end


--
-- Asserts that `checkurl` is a valid URL
--
---@param val  any
---@param pos? integer Parameter position
function Params.assert.url(val, pos)
  if (not types.isString(val)) then
    error(errs.TYPE:format(pos or 1, 'string', type(val)), 2)
  end
  
  local match, err = url_matcher:match(val)

  if err ~= nil then
    error(err)
  end

  if match == nil then
    error(errs.MATCH:format(pos or 1, 'URL', val), 2)
  end
end


--
-- -- Throws invalid parameter error if `val` does not validate with `typefn`
--
---@param typefn  TypeCheckFn   - function to invoke with checked value
---@param val     any           - value to check
---@param pos?    integer       - (optional) Parameter position
---@param name    string        - (otpional) Print name of expected type
function Params.assert.any(typefn, val, pos, name)
  Params.assert.func(typefn, 999)
  
  if (not typefn(val)) then
    error(errs.TYPE:format(pos or 1, name or 'unknown', type(val)), 2)
  end
end


--
-- Will null-check first param returning second param if nil
--
---@generic V
---@param val V|nil           - Possible nil value
---@param default V|fun():V   - The default or a default supplier function
---@param allowEmpty? boolean - Set true to accept empty strings as valid
---@return V
function Params.default(val, default, allowEmpty)
  local useDefault = types.is.Nil(val)

  if (allowEmpty and types.is.strng(val)) then
    useDefault = val ~= ""
  end

  if useDefault then
    if types.is.func(default) then 
      return default()
    else 
      return default
     end
  end

  return val
end

Params.fallback = Params.default
Params.orUse = Params.default

--
-- Does a spread operation
--
---@param ... any[]
---@return ... any
function Params.spread(...)
  return table.unpack{...}
end


--
-- No-op function
--
---@param ... any
---@return nil
function Params.noop(...)
  -- Doing great!
end


--
-- substitures first N parameters to function `fn`
--
-- -@param fn fun(...):any
-- -@return fun(...):any
-- function Params.sub(fn, ...)
--   local statics = {...}
--   return function(...)
--     local rest_vals = select(#statics)
--     fn(table.unpack(statics), table.unpack(rest_vals))
--   end
-- end

return Params