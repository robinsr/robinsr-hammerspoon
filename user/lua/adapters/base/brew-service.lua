local Service = require 'user.lua.adapters.base.service'
local sh      = require 'user.lua.adapters.shell'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('brew-servive','debug')



---@alias BrewCLI.List Array<BrewCLI.Listing>

---@class BrewCLI.Listing
---@field name string
---@field status "started"|"none"
---@field user string
---@field file string
---@field exit_code integer


---@class BrewCLI.Service
---@field name string
---@field service_name string
---@field running  true,
---@field loaded  true,
---@field schedulable boolean
---@field pid integer
---@field exit_code integer
---@field user string
---@field status "started"|"none"
---@field file string - The plist file for this brew service
---@field command string
---@field working_dir? string
---@field root_dir? string
---@field log_path? string
---@field error_log_path? string
---@field interval? integer
---@field cron? string




local cmd = {
  list = sh.split("brew services list --json"),
  info = "brew services info %s --json",
  start = "brew services start %s",
  stop = "brew services stop %s",
  restart = "brew services restart %s",
  status = "ps -p %s -o command",
}


---@class BrewService: Service
local BrewService = {}


---@return BrewCLI.List
function BrewService.list()
  local tabl = sh.get(cmd.list, { json = true }) --[@as table]]
  return tabl --[[@as BrewCLI.List]]
end


---@return BrewService
function BrewService:new(name)

  ---@class BrewService
  local this = Service.new(self == BrewService and {} or self, name)

  local exec = sh.run({ 'brew', 'services', 'info', name, '--json' }, { json = true })

  if (exec == nil) then
    log.ef("Error retrieving brew service [%s]", name)
  end

  ---@cast exec BrewCLI.Service[]
  local brewinfo = exec[1] 

  ---@cast brewinfo -nil
  this.service_name = brewinfo.service_name or 'unknown'
  this.running = brewinfo.running or false
  this._status = brewinfo.status or 'none'
  this.pid = brewinfo.pid
  this.plist = brewinfo.file

  return proto.setProtoOf(this, BrewService, { locked = true })
end

function BrewService:start()
  return sh.run({ 'brew', 'service', 'start', self.name })
end

function BrewService:stop()
  return sh.run({ 'brew', 'services', 'stop', self.name })
end

function BrewService:restart()
  return sh.run({ 'brew', 'services', 'restart', self.name })
end


function BrewService:status()
  return sh.run({ 'brew', 'services', 'info', self.name, '--json' })
end

return BrewService