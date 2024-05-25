local run     = require 'user.lua.interface.runnable'
local logr    = require 'user.lua.util.logger'
local strings = require 'user.lua.lib.string'
local tables  = require 'user.lua.lib.table'
local types   = require 'user.lua.lib.typecheck'
local errorf  = require 'user.lua.util'.errorf
local json    = require 'user.lua.util.json'

local log = logr.new('Shell', 'warning')

local Shell = {}

Shell.IGNORE = '&> /dev/null'

--
-- Shell execution with some QOL bits
--
---@param cmd string The shell command to run; can be a format string pattern
---@param ... string|number Parameters format with the command string (if any)
---@return string Shell output
function Shell.run(cmd, ...)
  local params = {...}

  if (type(cmd) == nil) then
    log.e('No command passed to utils#run')
  end

  log.logIf('info', function()
    log.f("Running shell command [%s] (%s)", cmd, hs.inspect(params))
  end)

  local cmd = string.format(cmd, table.unpack(params))
  log.f("Running shell command [%s]", cmd)
  local output, status, type, rc = hs.execute(cmd, true)

  if (status and output ~= nil) then
    local trimmed = strings.trim(output)
    log.df("Command [%s] completed with result:\n%s", cmd, trimmed)
    return trimmed
  end

  errorf([[
    Command '%s' exited with error:
      - code: %s %s
      - stderr: %s
    ]], cmd, tostring(type), rc, output)

  return ''
end

-- Parses output of Shell.run to a table
---@param cmd_str string Shell command string
---@param ... string? command string format args
---@return table?, string?
function Shell.runt(cmd_str, ...)
  local params = {...}
  local ok, output = pcall(function() 
    return Shell.run(cmd_str, table.unpack(params))
  end)

  if (ok) then
    return json.parse(output), nil
  else
    return nil, output
  end
end

-- Runs formatted command string in a shell, parses JSON output, and returns value at key
---@param cmd_str string Shell command string
---@param key string JSON key
---@param ... string? command string format args
---@return any|nil
function Shell.runtv(cmd_str, key, ...)
  local args = {...}
  local ok, output = pcall(function() 
    return Shell.runt(cmd_str, table.unpack(args))
  end)

  if (ok) then
    return tables.get(output, key) or nil
  end
  
  error(output)
end


---@alias CmdFunc fun(...: any[]): string

--
-- Returns a function that when called formats the command string and runs the command
--
---@param pattern string The command string pattern
---@return CmdFunc A function to run later to execute the command
function Shell.wrap(pattern)
  return function(...)
    local vars = table.pack(...)
    
    if (#vars == 0) then
      log.d('No-args invocation of command: ', pattern)
      return Shell.run(pattern)
    end

    --- Returns the original pattern when first argument is True
    if (types.isTrue(vars[0])) then
      log.d('Unwrapping command string: ', pattern)
      return pattern;
    end

    return Shell.run(pattern, table.unpack(vars))
  end
end

--
-- Returns command-line safe string representations of lua objects
--
---@param val any
---@return string
function Shell.argEsc(val)
  if types.isString(val) then
    return strings.fmt('"%s"', val)
  end

  if types.isTable(val) then
    return json.tostring(val)
  end

  return tostring(val)
end


return Shell