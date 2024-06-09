local shell   = require 'user.lua.adapters.shell'
local strings = require 'user.lua.lib.string'
local util    = require 'user.lua.util'

---@class CliUtility
local isCli = {}

function isCli:included()
  local pattern = strings.fmt('^\\/.*\\/%s$', self.path)
  local found = shell.run('which %s', self.path):gmatch(pattern)
  
  if not found then
    util.errorf('No path executable found for cli [%s]', self.path)
  end
end

function isCli:run(args, ...)
  return shell.run(args, ...)
end

return isCli
