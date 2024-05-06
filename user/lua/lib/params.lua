local tc = require "user.lua.lib.typecheck"

local notNil, is = tc.notNill, tc.is

local Params = {}

--
-- Will null-check first param returning second param if nil
--
---@generic V
---@param val V | nil Possible nil value
---@param default V | fun():V The default value to return
---@param allowEmpty? boolean Set true to allow empty strings
---@return V
function Params.default(val, default, allowEmpty)
  local useDefault = is.nill(val)

  if (allowEmpty and is.strng(val)) then
    useDefault = val ~= ""
  end

  if useDefault then
    if is.func(default) then 
      return default()
    else 
      return default
     end
  end

  return val
end

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