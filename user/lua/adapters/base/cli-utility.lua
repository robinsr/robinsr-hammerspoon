local shell   = require 'user.lua.interface.shell'
local strings = require 'user.lua.lib.string'
local util    = require 'user.lua.util'


local isCli = {}

function isCli:included(clss)
  local pattern = strings.fmt('^\\/.*\\/%s$', clss.path)
  local found = shell.run('which %s', clss.path):gmatch(pattern)
  
  if not found then
    util.errorf('No path executable found for cli [%s]', clss.path)
  end
end

function isCli:run(args, ...)
  return shell.run(args, ...)
end

return isCli
