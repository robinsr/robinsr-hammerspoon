local class   = require 'middleclass'
local Service = require 'user.lua.adapters.base.service'
local shell   = require 'user.lua.interface.shell'
local util    = require 'user.lua.util'

local log = util.log('adpt:launchagent', 'info')

local LaunchAgent = class('LaunchAgent', Service)

function LaunchAgent.static:getUID()
  local uid = shell.run('id -u')
  log.i("User Id from id: ", uid)
  return uid
end


function LaunchAgent:initialize(name, servicename)
  Service.initialize(self, name)

  self.service_name = servicename

  local uid = LaunchAgent:getUID()

  self.domain_target = util.fmt('gui/%s', uid)
  self.service_target = util.fmt('gui/%s/%s', uid, self.service_name)

  local launchinfo = shell.run('launchctl print %s', self.service_target)
  
  self.plistfile = launchinfo:match("path%s=%s([^%s]*)")
  self.pid = launchinfo:match("pid%s=%s([^%s]*)")
end


function LaunchAgent:restart()
  local ok, msg = pcall(function()
    return shell.run('launchctl kickstart -kp %s', self.service_target)
  end)

  if (ok and msg ~= nil) then
    local pid = msg:match("(%d+)")

    log.df("Restarted service [%s] (pid: %s)", self.name, pid)

    self.pid = pid
  else
    error("Failed to start service "..self.service_name)
  end
end

--- More to do here. Needs to "bootout" to keep process from restarting
-- See: https://github.com/koekeishiya/yabai/blob/0bfaa2da53907ea99fdd8c4fde184c15e6a8e39c/src/misc/service.h#L264
-- function LaunchAgent:stop()
--   local ok = pcall(function()
--     return shell.run('launchctl stop %s', self.service_target):match(util.fmt('^.*%s$', self.service_name))
--   end)

--   if (ok) then
--     self.pid = nil
--   else
--     error("Failed to get stop service "..self.service_name)
--   end
-- end


function LaunchAgent:status(name)
  local ok, msg = pcall(function()
    return shell.run('launchctl kickstart -p %s', self.service_target)
  end)

  if (ok and msg ~= nil) then
    local pid = msg:match("(%d+)")

    log.df("Started service [%s] (pid: %s)", self.name, pid)

    self.pid = pid

    return 'running '..self.pid
  else
    error("Failed to get status of "..self.service_name)
  end

  return 'not running'
end


return LaunchAgent