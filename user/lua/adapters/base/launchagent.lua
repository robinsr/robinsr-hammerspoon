local shell   = require 'user.lua.adapters.shell'
local Service = require 'user.lua.adapters.base.service'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local logr    = require 'user.lua.util.logger'
local data    = require 'pl.data'

local log = logr.new('LaunchAgent', 'info')

local PROC_UID = nil

---@class LaunchAgent: Service
local LaunchAgent = {}



function LaunchAgent.getUID()
  return shell.run('id -u')
end


--
-- Query the list of active launch agents
--
-- - Select row          - seq.copy(launchd:select_row('* where label == "com.koekeishiya.yabai"'))[1]
-- - Select row as table - launchd:copy_select('* where label == "com.koekeishiya.yabai"')
--
function LaunchAgent.list()
  local dataconfig = {
    delimg = '\t',
    fieldnames = { 'pid', 'exit', 'label' }
  }

  local services, err = data.read(io.popen('launchctl list'), dataconfig)

  if err ~= nil then error(err) end

  return services
end


--
-- Creates a new LaunchAgent instance for a service
--
---@param name string A user-friendly name for the serivce
---@param servicename string The name the services uses within launchctl
---@return LaunchAgent
function LaunchAgent:new(name, servicename)

  ---@class LaunchAgent
  local this = Service.new(self == LaunchAgent and {} or self, name)

  this.service_name = servicename

  local uid = LaunchAgent:getUID()

  this.domain_target = strings.fmt('gui/%s', uid)
  this.service_target = strings.fmt('gui/%s/%s', uid, this.service_name)

  local ok, launchinfo = pcall(function()
    return shell.run('launchctl print %s', this.service_target)
  end)

  if (ok) then
    this.plistfile = launchinfo:match("path%s=%s([^%s]*)")
    this.pid = launchinfo:match("pid%s=%s([^%s]*)")
  end

  return proto.setProtoOf(this, LaunchAgent)
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


---@return ServiceStatus
function LaunchAgent:status(name)
  local ok, services = pcall(function()
    return LaunchAgent.list()
  end)

  if not ok then
    error("Failed to get status of "..self.service_name)
  end

  if services ~= nil then
    local proc = services:copy_select(strings.fmt('* where label == "%s"'))

    if (proc ~= nil and proc.pid) then
      return Service.STATUS.running
    end
  end

  return Service.STATUS.not_running
end


return LaunchAgent