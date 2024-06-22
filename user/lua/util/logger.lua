local console = require 'user.lua.interface.console'
local types   = require 'user.lua.lib.typecheck'
local lists   = require 'user.lua.lib.list'
local ansi    = require 'user.lua.util.ansicolors'

local is, notNil = types.is, types.notNil

---@class ProxyLogger : hs.logger
---@field inspect fun(...): nil prints a thing nice
---@field logIf fun(...): nil logs conditionally (prevent unnecessary calls to inspect)


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

  local lname = '(' .. log_name .. ') '


  setmetatable(log, self)
  self.__index = self

  log.log_instance = _log

  local l = function(ansi_str)
    return function(...)
      console.print(ansi(ansi_str..lname..table.concat({...})))
    end
  end

  local lf = function(ansi_str)
    return function(pattern, ...)
      console.print(ansi(ansi_str..lname..string.format(pattern, table.unpack({...}))))
    end
  end

  log.d = l("%{blue}[debug] ")
  log.df = lf("%{blue}[debug] ")
  log.e = l("%{red}[ERROR] ")
  log.ef = lf("%{red}[ERROR] ")
  log.i = l("%{black}[info] ")
  log.f = lf("%{black}[info] ")
  log.v = l("%{green}[verbose] ")
  log.vf = lf("%{green}[verbose] ")
  log.w = l("%{yellow}[warn] ")
  log.wf = lf("%{yellow}[warn] ")

  log.getLogLevel = _log.getLogLevel

  ---@cast log ProxyLogger
  log.inspect = function (...)
    if (log:getLogLevel() > levels.info) then
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
          return hs.inspect(bit, lastarg)
        end
      end)

      console.print(
        ansi('%{blue}'..DEBUG_WARNING),
        ansi('%{blue}'..table.concat(bits:values()))
      )
    end
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