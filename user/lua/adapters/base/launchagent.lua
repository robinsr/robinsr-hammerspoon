local shell   = require 'user.lua.adapters.shell'
local Service = require 'user.lua.adapters.base.service'
local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local logr    = require 'user.lua.util.logger'
local data    = require 'pl.data'

local log = logr.new('LaunchAgent', 'info')


---@class LaunchAgent: ks.service
local LaunchAgent = {}


local UID

function LaunchAgent.getUID()
  if (UID == nil) then
    local uid = shell.result({ 'id', '-u' })

    if uid:ok() then
      UID = uid.output
    end
  end

  return UID
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

  local list = io.popen('launchctl list')

  if list == nil then
    return error('Could not open "launchctl list"')
  end

  local services, err = data.read(list, dataconfig)

  if err ~= nil then error(err) end

  return services
end


---@return ServiceStatus
function LaunchAgent.queryStatus(label)
  local qs = strings.fmt('pid where label == "%s"', label)

  local proc = LaunchAgent.list():copy_select(qs)

  if (proc ~= nil and proc.pid) then
    return Service.STATUS.running
  else
    return Service.STATUS.not_running
  end
end


---@class LaunchctlListItem
---@field pid integer
---@field exit integer
---@field label string


---@return LaunchctlListItem?
function LaunchAgent.query(label)
  local qs = strings.fmt('* where label == "%s"', label)
  return LaunchAgent.list():copy_select(qs) --[[@as LaunchctlListItem]]
end


--
-- Creates a new LaunchAgent instance for a service
--
---@param name string A user-friendly name for the serivce
---@param servicename string The name the services uses within launchctl
---@return LaunchAgent
function LaunchAgent:new(name, servicename)
  local uid = LaunchAgent:getUID()

  ---@class LaunchAgent
  local this = Service.new(self == LaunchAgent and {} or self, name)

  this.service_name = servicename
  this.domain_target = strings.fmt('gui/%s', uid)
  this.service_target = strings.fmt('gui/%s/%s', uid, this.service_name)

  local status = LaunchAgent.query(servicename)
  
  if (status and status.pid) then
    this.pid = status.pid
  end

  return proto.setProtoOf(this, LaunchAgent)
end


function LaunchAgent:restart()
  local result = shell.result({ 'launchctl', 'kickstart', '-kp', self.service_target })

  if result:ok() then

    local pid = result.output:match("(%d+)")

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
  local proc = LaunchAgent.query(self.service_name)
  
  if (proc and proc.pid) then
    self.pid = proc.pid

    return Service.STATUS.running
  end

  return Service.STATUS.not_running
end


return proto.setProtoOf(LaunchAgent, Service)