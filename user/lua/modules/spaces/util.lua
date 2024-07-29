local sh   = require 'user.lua.adapters.shell'
local logr = require 'user.lua.util.logger'

local log = logr.new('ModSpaces/util', 'info')


local space_util = {}

function space_util.send_message(args, msg)
  local args = { 'yabai', '-m', table.unpack(sh.split(args)) }
  
  return function(cmd, ctx)
    local result = sh.result(args)
    log.df('cmd "%s" exited with code %q', result.command, result.status or 'none')
    return msg
  end
end

return space_util