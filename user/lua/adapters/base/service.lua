local proto   = require 'user.lua.lib.proto'
local strings = require 'user.lua.lib.string'
local logr    = require 'user.lua.util.logger' 

local log = logr.new('service', 'warning')


---@enum ServiceStatus
local STATUS = {
  running = 0,
  not_running = 1,
}


---@class ks.service
---@field name string
---@field pid integer
local Service = {}

Service.STATUS = STATUS


---@return ks.service
function Service:new(name)
  local this = self == Service and {} or self
  
  this.name = name or "unknown"
  this.pid = nil
  
  log.f("New service [%s]", this.name)

  return proto.setProtoOf(this, Service)
end

function Service:start()
  error(strings.fmt('Service:start not implemented on service [%s]', self.name))
end

function Service:stop()
  error(strings.fmt('Service:stop not implemented on service [%s]', self.name))
end

function Service:restart()
  error(strings.fmt('Service:restart not implemented on service [%s]', self.name))
end

function Service:status()
  error(strings.fmt('Service:status not implemented on service [%s]', self.name))
end

return Service