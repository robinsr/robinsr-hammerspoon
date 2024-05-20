local class = require 'middleclass'
local strings = require 'user.lua.lib.string'
local logr = require 'user.lua.util.logger' 

local log = logr.new('service', 'warning')

---@class Service : MidClassObject
---@field new fun(): Service
local Service = class('Service')

function Service:initialize(name)
  log.f("New service [%s]", name)
  self.name = name or "unknown"
  self.pid = nil
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