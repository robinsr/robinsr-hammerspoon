local U = {}

U.log = require('user.lua.util.logger').log

U.d1 = { depth = 1 }
U.d2 = { depth = 2 }
U.d3 = { depth = 3 }


--
-- Delays the execution of function fn by msec
--
---@param msec integer delay in MS
---@param fn function function to run after delay
---@returns nil
function U.delay(msec, fn)
  hs.timer.doAfter(msec, fn)
end


--
-- Lua `error` with string formatting
--
---@param fmtstr string Format string pattern
---@param ... string|number|boolean Format string parameters
function U.errorf(fmtstr, ...)
  error(string.format(fmtstr, ...), 2)
end


return U
