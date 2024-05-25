local types = require 'user.lua.lib.typecheck'
local lists = require 'user.lua.lib.list'

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

local DEBUG_WARNING = '>>> DEBUG >>>  (warning! hs.inspect is slow)\n'

local ProxyLogger = {}

function ProxyLogger:new(log_name, level)

  level = level or 'error'

  local log = hs.logger.new(log_name, level)

  setmetatable(log, self)
  self.__index = self

  ---@cast log ProxyLogger
  log.inspect = function (...)
    if (log:getLogLevel() > 3) then
      local args = lists.pack(...)
      local lastarg = args[#args]

      -- Prevents unintentionally bogging down HS with huge objects
      -- Add { depth = N } as last argument to override
      if (is.tabl(lastarg) and notNil(lastarg.depth)) then
        lists.pop(args)
      else
        lastarg = { depth = 1 }
      end

      local bits = lists.map(args, function(bit)
        if is.strng(bit) then
          return bit
        else
          return hs.inspect(bit, lastarg)
        end
      end)

      log.d(DEBUG_WARNING, table.unpack(bits))
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