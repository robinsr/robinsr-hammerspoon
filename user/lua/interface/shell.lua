local U     = require 'user.lua.util'
local run   = require 'user.lua.interface.runnable'

local log = U.log('Shell', 'warning')


local Shell = {}


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

  if (status) then
    local trimmed = U.trim(output)
    log.df("Command [%s] completed with result:\n%s", cmd, trimmed)
    return trimmed
  end

  error(U.fmt([[
    Command '%s' exited with error:
      - code: %s %s
      - stderr: %s
    ]], cmd, tostring(type), rc, output))
end

-- Parses output of Shell.run to a table
---@param cmd_str string Shell command string
---@param ... string? command string format args
---@return table
function Shell.runt(cmd_str, ...)
  local params = {...}
  local ok, output = pcall(function() 
    return Shell.run(cmd_str, table.unpack(params))
  end)

  if (ok) then
    return U.json(output)
  end

  error(output)
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
    return U.path(output, key) or nil
  end
  
  error(output)
end


function Shell.wrap(cmd)
  return function(...)
    
    if (#{...} == 0) then
      log.d('No-args invocation of command: ', cmd)
      return Shell.run(cmd)
    end

    local args = {...}
    if (type(args[0]) == "boolean" and args[0]) then
      log.d('Unwrapping command string: ', cmd)
      return cmd;
    end

    return Shell.run(cmd, table.unpack{...})
  end
end


function Shell.pipe(...)
  return run:new(table.unpack{...})
end


function Shell.trim(str)
  return U.trim(str)
end

return Shell