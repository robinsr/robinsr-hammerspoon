local shell   = require 'user.lua.adapters.shell'
local Service = require 'user.lua.adapters.base.service'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local def = params.default
local log = logr.new('brew-servive','debug')


local cmd = {
  list = "brew services list --json",
  info = "brew services info %s --json | jq -M '.[]'",
  start = "brew services start %s",
  stop = "brew services stop %s",
  restart = "brew services restart %s",
  status = "ps -p %s -o command",
}


---@class BrewService: Service
local BrewService = {}


function BrewService.list()
  return shell.runt(cmd.list)
end


---@return BrewService
function BrewService:new(name)

  ---@class BrewService
  local this = Service.new(self == BrewService and {} or self, name)

  ---@type table
  local brewinfo = shell.runt(cmd.info, name)

  if (brewinfo == nil) then
    log.ef("Error retrieving brew service [%s]", name)
  end

  ---@cast brewinfo -nil
  this.service_name = def(brewinfo['service_name'], 'unknown') --[[@as string]]
  this.running = def(brewinfo['running'], false) --[[@as boolean]]
  this._status = def(brewinfo['status'], nil) --[[@as string?]]
  this.pid = def(brewinfo['pid'], nil) --[[@as number?]]
  this.plist = def(brewinfo['file'], nil) --[[@as string?]]

  return proto.setProtoOf(this, BrewService, { locked = true })
end

function BrewService:start()
  return shell.run(cmd.start, self.name)
end

function BrewService:stop()
  return shell.run(cmd.stop, self.name)
end

function BrewService:restart()
  return shell.run(cmd.restart, self.name)
end


function BrewService:status()
  return shell.run(cmd.info, 'running', self.name)
end

return BrewService