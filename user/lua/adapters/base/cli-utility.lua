local class = require 'middleclass'
local shell = require 'user.lua.interface.shell'
local util  = require 'user.lua.util'


local isCli = {}

function isCli:included(clss)
  local pattern = util.fmt('^\\/.*\\/%s$', clss.path)
  local checked = shell.run('which %s', clss.path):gmatch(pattern)
  
  if (not checked) then
    error("No path executable found for cli [%s]", clss.path)
  end
end

function isCli:run(args, ...)
  return shell.run(args, ...)
end

return isCli
