local U = {}

local fmt = string.format
local pack = table.pack
local upack = table.unpack

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
  error(fmt(fmtstr, ...), 2)
end


--
-- Returns a error function
--
function U.errorft(tmpl, ...)
  local tmplvars = pack(...)
  return function(fmtstr, ...)
    local submsg = fmt(fmtstr, ...)
    local msg = fmt(tmpl, { upack(tmplvars), submsg })
    
    error(msg, 3)
  end
end


function U.noop() 
  -- do nothing
end


return U
