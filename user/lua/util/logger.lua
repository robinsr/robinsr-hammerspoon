local inspect = require 'inspect'
local console = require 'user.lua.interface.console'
local types   = require 'user.lua.lib.typecheck'
local lists   = require 'user.lua.lib.list'
local colors  = require 'user.lua.ui.theme.mariana'

local VIOLET = { color = colors.violet }
local RED    = { color = colors.red }
local ORANGE = { color = colors.orange }
local BLUE   = { color = colors.blue }
local GREEN  = { color = colors.green }

local is, notNil = types.is, types.notNil


---@class ks.log.logger : hs.logger
---@field inspect    ks.log.logfn     - Prints the result oh hs.inspect
---@field critical   ks.log.logfn     - Logs important messages at a higher level than info
---@field trace      ks.log.errfn          - Prints stack strace
---@field logIf      ks.log.logfn     - Logs conditionally (prevent unnecessary calls to inspect)


---@alias ks.log.level
---|'off'
---|'error'
---|'warning'
---|'info'
---|'debug'
---|'verbose'


---@alias ks.log.logfn fun(...: any): nil

---@alias ks.log.errfn fun(err: any, pattern: string, ...: any): nil


local levels_config = {
  -- ['init.lua'] = 'error',
  -- ['shell.lua'] = 'warning',
  -- ['menu.lua'] = 'debug',
}


---@type { [integer|ks.log.level]: integer|ks.log.level }
local levels = {
  "error", "warning", "info", "debug", "verbose",
  error = 1,
  warning = 2,
  info = 3,
  debug = 4,
  verbose = 5,
}

---@class ks.log.logger
local ProxyLogger = {}


--
-- Creates a new logger instance with its own namespace
--
---@param log_name string
---@param level    ks.log.level
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
        local statements = lists({...}):map(tostring):join(' ')

        console.print(level_prefix .. name_prefix .. statements, styles)
      end
    end
  end

  local lf = function(this_level, level_prefix, styles)

    ---@param pattern string
    ---@param ... any
    return function(pattern, ...)
      local logvars = {...}
      
      -- while #(pattern:match('(%%[sdq])') or '') < #logvars do
      --   pattern = pattern .. ' %q'
      -- end

      local ok, formatted  = xpcall(string.format, debug.traceback, pattern, table.unpack(logvars))

      if not ok then
        console.print(('LoggerError - Error formatting pattern [%s] - %s'):format(pattern, inspect(logvars)), RED)
        console.print(formatted, RED)
        return
      end

      if (_log:getLogLevel() >= this_level) then
        console.print(level_prefix .. name_prefix .. formatted, styles)
      end
    end
  end

  log.d  = l(levels.debug,    "[debug] ",   VIOLET)
  log.df = lf(levels.debug,   "[debug] ",   VIOLET)
  log.e  = l(levels.error,    "[ERROR] ",   RED)
  log.ef = lf(levels.error,   "[ERROR] ",   RED)
  log.w  = l(levels.warning,  "[warn] ",    ORANGE)
  log.wf = lf(levels.warning, "[warn] ",    ORANGE)
  log.i  = l(levels.info,     "[info] ",    BLUE)
  log.f  = lf(levels.info,    "[info] ",    BLUE)
  log.v  = l(levels.verbose,  "[verbose] ", GREEN)
  log.vf = lf(levels.verbose, "[verbose] ", GREEN)

  log.critical = lf(levels.warning, "[critical] ", ORANGE)

  log.trace = function(err, pattern, ...)
    local msg = string.format(pattern, table.unpack({...}))
    local trace = debug.traceback(err, 2)

    console.print("[trace] "..msg, { color = colors.red })
    console.print(trace, { color = colors.red })
  end

  log.inspect = function(...)
    ---@cast log ks.log.logger

    if (log:getLogLevel() < levels.debug) then
      return
    end

    local inspect_conf = { depth = 4 }
    local args = {...}
    local lastarg = args[#args]
    local depth = types.isTable(lastarg) and lastarg.depth
    local metas = types.isTable(lastarg) and lastarg.metatables

    if depth ~= nil or metas ~= nil then
      -- The last parameter to log.inspect can be a config object for inspect/hs.inspect
      -- If so, use that, otherwise us reasonable defaults
      inspect_conf = lastarg
      -- Remove the config parameter the other, printable parameters
      table.remove(args, #args)
    end

    local post_inspect = lists(args)
      :map(function(bit)
        return types.isString(bit) and bit or inspect(bit, inspect_conf)
      end)
      :join(' ')

      log.d(post_inspect)
  end

  log.logIf = function(level, fn)
    if (log:getLogLevel() >= levels[level]) then fn() end
  end

  return log
end


-- Creates a new logger with default level
---@param log_name string
---@param level?   ks.log.level
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