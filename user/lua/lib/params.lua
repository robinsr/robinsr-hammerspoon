local types = require "user.lua.lib.typecheck"

local Params = {}

Params.assert = {}


--
-- Check a function parameter against the isTable typecheck function
--
---@param tabl any
---@param num? integer Parameter position
function Params.assert.tabl(tabl, num)
  if (not types.isTable(tabl)) then
    error(string.format('Parameter #%d is not a table, rather %s', num or 1, type(tabl)))
  end
end

--
-- Check a function parameter against the isTable typecheck function
--
---@param arg any
---@param num? integer Parameter position
function Params.assert.string(arg, num)
  if (not types.isString(arg)) then
    error(string.format('Parameter #%d is not a string, rather %s', num or 1, type(arg)))
  end
end


--
-- Check a function parameter against any typecheck function
--
---@param typefn TypeCheckFn
---@param obj any
---@param num? integer Parameter position
function Params.assert.any(typefn, obj, num)
  if (not types[typefn](obj)) then
    error(string.format('Parameter #%d failed check "%s". found type %s', num or 1, typefn))
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

return Params