
local levels_config = {
  -- ['init.lua'] = 'error',
  ['shell.lua'] = 'error',
  ['menu.lua'] = 'debug',
}


---@class ProxyLogger : hs.logger
---@field inspect fun(...): nil prints a thing nice


local ProxyLogger = {}

function ProxyLogger:new(log_name, level)

  local o = hs.logger.new(log_name, level)

  setmetatable(o, self)
  self.__index = self



  ---@cast o ProxyLogger
  o.inspect = function (...)
    o.i(hs.inspect(table.unpack({...})))
  end

  return o
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