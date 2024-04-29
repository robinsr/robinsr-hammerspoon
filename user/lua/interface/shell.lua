local util  = require 'user.lua.util'
local trim  = require 'string.trim'
local class = require 'middleclass'

local log   = util.log('shell.lua', 'info')

local Runnable = class('Runnable')

function Runnable:initialize(cmd)
  self.cmds = {}
  table.insert(self.cmds, cmd)
end

function Runnable:pipe(cmd)
  table.insert(self.cmds, cmd)
end

function Runnable:run()
  local pipedCmd = ""
  -- todo
end


local Shell = {}

function Shell.run(cmd_str, ...)
  local params = {...}

  if (type(cmd_str) == nil) then
    log.e('No command passed to utils#run')
  end

  log.f("Running shell command [%s] (%s)", cmd_str, hs.inspect(params))
  local cmd = string.format(cmd_str, table.unpack(params))
  log.f("Running shell command [%s]", cmd)
  local output, status, type, rc = hs.execute(cmd, true)

  if (status) then
    local trimmed = trim(output)
    log.df("Command [%s] completed with result:\n%s", cmd, trimmed)
    return trimmed
  end

  error(string.format([[
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
    return util.json(output)
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
    return util.path(output, key) or nil
  end
  
  error(output)
end


function Shell.wrap(cmd)
  return function(...)
    
    if (#{...} == 0) then
      log.d('No-args invocation of command: '..cmd)
      return Shell.run(cmd)
    end

    local args = {...}
    if (type(args[0]) == "boolean" and args[0]) then
      log.d('Unwrapping command string: '..cmd)
      return cmd;
    end

    log.d('Invocating command: '..cmd.." with args ", args)
    return Shell.run(cmd, table.unpack({...}))
  end
end


-- WIP
function Shell.pipe(cmdfn)
  local cmdstr = cmdfn(true)
  return {
    to = function (next)
      return {
        exec = function ()
        end
      }    
    end
  }
end


function Shell.trim(str)
  return trim(str)
end

return Shell