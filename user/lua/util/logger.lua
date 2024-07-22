local inspect = require 'inspect'
local console = require 'user.lua.interface.console'
local types   = require 'user.lua.lib.typecheck'
local lists   = require 'user.lua.lib.list'
local colors  = require 'user.lua.ui.color'

local is, notNil = types.is, types.notNil

---@alias LogFn fun(...): nil
---@alias TraceFn fun(err: any, pattern: string, ...: any): nil 

---@class ProxyLogger : hs.logger
---@field inspect LogFn    - Prints the result oh hs.inspect
---@field trace TraceFn    - Prints stack strace
---@field logIf LogFn      - Logs conditionally (prevent unnecessary calls to inspect)


local levels_config = {
  -- ['init.lua'] = 'error',
  -- ['shell.lua'] = 'warning',
  -- ['menu.lua'] = 'debug',
}

local levels = {
  "error", "warning", "info", "debug", "verbose",
  error = 1,
  warning = 2,
  info = 3,
  debug = 4,
  verbose = 5,
}


local ProxyLogger = {}

function ProxyLogger:new(log_name, level)

  level = level or 'error'
  
  local DEBUG_WARNING = string.format('>>> DEBUG (%s) >>> ', log_name)

  local _log = hs.logger.new(log_name, level)

  local log = {}

  local name_prefix = '(' .. log_name .. ') '


  setmetatable(log, self)
  self.__index = self

  log.log_instance = _log
  log.getLogLevel = _log.getLogLevel

  local l = function(this_level, level_prefix, styles)
    return function(...)
      if (_log:getLogLevel() >= this_level) then
        console.print(level_prefix..name_prefix..table.concat({...}), styles)
      end
    end
  end

  local lf = function(this_level, level_prefix, styles)
    return function(pattern, ...)
      if (_log:getLogLevel() >= this_level) then
        console.print(level_prefix..name_prefix..string.format(pattern, table.unpack({...})), styles)
      end
    end
  end

  log.d = l(levels.debug, "[debug] ", { color = colors.violet })
  log.df = lf(levels.debug, "[debug] ", { color = colors.violet })
  log.e = l(levels.error, "[ERROR] ", { color = colors.red })
  log.ef = lf(levels.error, "[ERROR] ", { color = colors.red })
  log.w = l(levels.warning, "[warn] ", { color = colors.orange })
  log.wf = lf(levels.warning, "[warn] ", { color = colors.orange })
  log.i = l(levels.info, "[info] ", { color = colors.blue })
  log.f = lf(levels.info, "[info] ", { color = colors.blue })
  log.v = l(levels.verbose, "[verbose] ", { color = colors.violet })
  log.vf = lf(levels.verbose, "[verbose] ", { color = colors.violet })

  log.trace = function(err, pattern, ...)
    local msg = string.format(pattern, table.unpack({...}))
    local trace = debug.traceback(err, 2)

    console.print("%{red}[trace] "..msg)
    console.print("%{red}"..trace)
  end


  ---@cast log ProxyLogger
  log.inspect = function (...)
    if (log:getLogLevel() < levels.debug) then
      return
    end

    local args = lists.pack(...)
    local lastarg = args[#args]

    -- Prevents unintentionally bogging down HS with huge objects
    -- Add { depth = N } as last argument to override
    if (is.tabl(lastarg) and notNil(lastarg.depth)) then
      args:pop()
    else
      lastarg = { depth = 1 }
    end

    local bits = args:map(function(bit)
      if is.strng(bit) then
        return bit
      else
        return inspect(bit, lastarg)
      end
    end)

    console.print(DEBUG_WARNING)
    console.print(table.concat(bits:values()))
  end

  log.logIf = function(level, fn)
    if (log:getLogLevel() >= levels[level]) then fn() end
  end

  return log
end

local function newLogger(log_name, level)
  local levelactual = levels_config[log_name] or level or 'warning'
  return ProxyLogger:new(log_name, levelactual)
end


return {
  log = newLogger,
  new = newLogger,
  META = { metatables = true },
  d1 = { depth = 1 },
  d2 = { depth = 2 },
  d3 = { depth = 3 },
}


-- Ref hs.inspect - https://www.hammerspoon.org/docs/hs.inspect.html#inspect
-- Final arg is:
-- options - An optional table which can be used to influence the inspector. Valid keys are as follows:
--        depth - A number representing the maximum depth to recurse into variable.
--                Below that depth, data will be displayed as {...}
--      newline - A string to use for line breaks. Defaults to \n
--       indent - A string to use for indentation. Defaults to  (two spaces)
--      process - A function that will be called for each item. It should accept two
--                arguments, item (the current item being processed) and path (the item's
--                position in the variable being inspected. The function should either return
--                a processed form of the variable, the original variable itself if it requires
--                no processing, or nil to remove the item from the inspected output.
--   metatables - If true, include (and traverse) metatables