local class   = require('middleclass')
local Service = require('user.lua.adapters.base.service')
local shell   = require('user.lua.interface.shell')
local default = require('user.lua.lib.params').default
local log = require('user.lua.util.logger').new('brew-servive','debug')


local cmd = {
  list = "brew services list --json",
  info = "brew services info %s --json | jq -M '.[]'",
  start = "brew services start %s",
  stop = "brew services stop %s",
  restart = "brew services restart %s",
  status = "ps -p %s -o command",
}


local BrewService = class('BrewService', Service)


function BrewService.static:list()
  return shell.runt(cmd.list)
end


function BrewService:initialize(name)
  Service.initialize(self, name)

  ---@type table
  local brewinfo = shell.runt(cmd.info, name)

  if (brewinfo == nil) then
    log.ef("Error retrieving brew service [%s]", name)
  end

  ---@cast brewinfo -nil
  self.service_name = default(brewinfo['service_name'], 'unknown') --[[@as string]]
  self.running = default(brewinfo['running'], false) --[[@as boolean]]
  self._status = default(brewinfo['status'], nil) --[[@as string?]]
  self.pid = default(brewinfo['pid'], nil) --[[@as number?]]
  self.plist = default(brewinfo['file'], nil) --[[@as string?]]
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