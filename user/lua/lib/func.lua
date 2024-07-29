---@class lib.function
local func = {}


--
-- A do-nothing function
--
function func.noop()
end



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


--
-- Returns a function that runs each function in sequence, passing return values to the next
--
---@generic F1, R1, F2, R2, F3, R3, F4, R4, F5, R5, F6, R6
---@param fn1 fun(arg: F1): R1
---@param fn2 fun(arg: F2): R2
---@param fn3? fun(arg: F3): R3
---@param fn4? fun(arg: F4): R4
---@param fn5? fun(arg: F5): R5
---@param fn6? fun(arg: F6): R6
---@return fun(F1):R1
function func.sequence(fn1, fn2, fn3, fn4, fn5, fn6)
  return function(...)
    local args = {...}

    for i,fn in ipairs({ fn1, fn2, fn3, fn4, fn5, fn6 }) do
      args = table.pack(fn(table.unpack(args)))
    end

    return args
  end
end


return setmetatable({}, { __index = func }) --[[@as lib.function]]