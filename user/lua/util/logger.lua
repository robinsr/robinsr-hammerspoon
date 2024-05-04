local tc = require 'user.lua.lib.typecheck'
local L  = require 'user.lua.lib.list'

local isNil, isTable, isString = tc.isNil, tc.isTable, tc.isString

---@class ProxyLogger : hs.logger
---@field inspect fun(...): nil prints a thing nice
---@field logIf fun(...): nil logs conditionally (prevent unnecessary calls to inspect)


local levels_config = {
  -- ['init.lua'] = 'error',
  -- ['shell.lua'] = 'warning',
  -- ['menu.lua'] = 'debug',
}

local levels = {
  "error", "warning", "info", "debug", "verbose"
}

local DEBUG_WARNING = '>>> DEBUG >>>  (warning! hs.inspect is slow)  '

local ProxyLogger = {}

function ProxyLogger:new(log_name, level)

  local log = hs.logger.new(log_name, level)

  setmetatable(log, self)
  self.__index = self

  function getEntryFromEnd(tabl, pos)
    local count = tabl and #tabl or false

    if (count and (count - pos > 0)) then
        return tabl[count - pos];
    end

    return false;
  end

  ---@cast log ProxyLogger
  log.inspect = function (...)
    if (log:getLogLevel() > 3) then
      local args = table.pack(...)
      local lastarg = getEntryFromEnd(args, 0)

      -- Prevents unintentionally bogging down HS with huge objects
      -- Add { depth = N } as last argument to override
      if (lastarg and isTable(lastarg) and isNil(lastarg.depth)) then
        table.insert(args, { depth = 1 })
      end

      local bits = L.map(args, function(bit)
        if isString(bit) then
          return bit
        else
          return hs.inspect(bit)
        end
      end)

      log.d(DEBUG_WARNING, table.unpack(bits))
    end
  end

  log.logIf = function(level, fn)
    if (log:getLogLevel() or 0 >= levels[level]) then fn() end
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