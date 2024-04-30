local class = require 'middleclass'
local util  = require 'user.lua.util'

local log = util.log('adpt:service', 'warning')

local Service = class('Service')

---@class Service
function Service:initialize(name)
  log.f("New service [%s]", name)
  self.name = name or "unknown"
  self.pid = nil
end

function Service:start()
  error(util.fmt('Service:start not implemented on service [%s]', self.name))
end

function Service:stop()
  error(util.fmt('Service:stop not implemented on service [%s]', self.name))
end

function Service:restart()
  error(util.fmt('Service:restart not implemented on service [%s]', self.name))
end

function Service:status()
  error(util.fmt('Service:status not implemented on service [%s]', self.name))
end

return Service