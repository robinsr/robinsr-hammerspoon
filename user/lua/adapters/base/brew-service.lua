local Service = require 'user.lua.adapters.base.service'
local sh      = require 'user.lua.adapters.shell'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('brew-servive', 'info')



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


---@class ks.service.brew: ks.service
local BrewService = {}


---@return BrewCLI.List
function BrewService.list()
  local tabl = sh.get(cmd.list, { json = true }) --[@as table]]
  return tabl --[[@as BrewCLI.List]]
end


---@return ks.service.brew
function BrewService:new(name)

  ---@class ks.service.brew
  local this = Service.new(self == BrewService and {} or self, name)

  local exec = sh.result({ 'brew', 'services', 'info', name, '--json' })

  if (exec == nil or exec.code ~= 0) then
    error("Error retrieving brew service [" .. name .. "]")
  end

  local brewinfo = exec:jq('.[0]'):json() --[[@as BrewCLI.Service]]

  ---@cast brewinfo -nil
  this.service_name = brewinfo.service_name or 'unknown'
  this.running = brewinfo.running or false
  this._status = brewinfo.status or 'none'
  this.pid = brewinfo.pid
  this.plist = brewinfo.file

  return proto.setProtoOf(this, BrewService, { locked = true })
end

function BrewService:start()
  return sh.result({ 'brew', 'services', 'start', self.name }).code
end

function BrewService:stop()
  return sh.result({ 'brew', 'services', 'stop', self.name }).code
end

function BrewService:restart()
  return sh.result({ 'brew', 'services', 'restart', self.name }).code
end

function BrewService:status()
  return sh.result({ 'brew', 'services', 'info', self.name, '--json' }):jq('.[0]'):table():get('pid')
end

return proto.setProtoOf(BrewService, Service)