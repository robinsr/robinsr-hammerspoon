local tc = require "user.lua.lib.typecheck"

local Params = {}

--
-- Will null-check first param returning second param if nil
--
---@param t any|nil Possible nil value
---@param default any The default value to return
---@param accept_empty_string? boolean Set true to allow empty strings
function Params.default(t, default, accept_empty_string)
  if accept_empty_string then
    return t ~= nil and t or default
  end

  return (t ~= nil and tc.isString(t) and t ~= "") and t or default
end

--
-- Does a spread operation
--
---@param ... any[]
---@return ... any
function Params.spread(...)
  return table.unpack{...}
end

return Params