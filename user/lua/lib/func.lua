---@class lib.function
local func = {}

--
-- Delays the execution of function fn by msec
--
---@param msec integer delay in MS
---@param fn function function to run after delay
---@returns nil
function func.delay(msec, fn)
  hs.timer.doAfter(msec, fn)
end


--
-- Memoizes a function, caching the return value for all future calls
--
---@generic A
---@generic T
---@param fn fun(...: A): T   The function to memoize
---@param ...? A              Optional args to pass to function
---@return fun(...: A): T
function func.singleton(fn, ...)
  local fn_args = {...}
  local memo = nil

  return function()
    
    if (memo == nil) then
      memo = fn(table.unpack(fn_args))
    end

    return memo
  end
end


--
-- Memoizes a function, caching the return value for a set number of seconds
--
---@generic A
---@generic T
---@param sec integer         Seconds to keep the memoized value
---@param fn fun(...: A): T   The function to memoize
---@param ...? A              Optional args to pass to function
---@return fun(...: A): T
function func.cooldown(sec, fn, ...)
  local fn_args = {...}
  local prev = os.time()
  local memo = nil

  return function()
    local now = os.time()
    
    if (memo == nil) or (now > prev + sec) then
      prev = now
      memo = fn(table.unpack(fn_args))
    end

    return memo
  end
end

return setmetatable({}, { __index = func }) --[[@as lib.function]]