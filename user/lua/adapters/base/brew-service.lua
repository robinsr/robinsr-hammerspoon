local Service = require 'user.lua.adapters.base.service'
local sh      = require 'user.lua.adapters.shell'
local chan    = require 'user.lua.lib.channels'
local func    = require 'user.lua.lib.func'
local params  = require 'user.lua.lib.params'
local proto   = require 'user.lua.lib.proto'
local tables  = require 'user.lua.lib.table'
local logr    = require 'user.lua.util.logger'

local log = logr.new('brew-servive', 'info')



---@alias BrewCLI.List Array<BrewCLI.Listing>

---@alias BrewCLI.status "started"|"none"


---@class BrewCLI.Listing
---@field name       string
---@field status     BrewCLI.status
---@field user       string
---@field file       string
---@field exit_code  integer


---@class BrewCLI.Service
---@field name            string
---@field service_name    string
---@field running         true,
---@field loaded          true,
---@field schedulable     boolean
---@field pid             integer
---@field exit_code       integer
---@field user            string
---@field status          BrewCLI.status
---@field file            string           The plist file for this brew service
---@field command         string
---@field working_dir?    string
---@field root_dir?       string
---@field log_path?       string
---@field error_log_path? string
---@field interval?       integer
---@field cron?           string


---@class ks.brewservice : ks.service


---@class ks.brewservice
local BrewService = {}


---@return ks.brewservice
function BrewService:new(name)

  ---@class ks.brewservice
  local this = Service.new(self == BrewService and {} or self, name)

  this = proto.setProtoOf(this, BrewService)
  
  this:refreshInfo()

  func.interval({ 90, 105 }, function()
    this:refreshInfo()
  end)

  return this
end


-- Refreshes stored process information by calling `brew services info...`
--
---@return ks.brewservice
function BrewService:refreshInfo()
  local info = sh.result({ 'brew', 'services', 'info', self.name, '--json' })

  if not info:ok() then
    error(info:error_msg())
  end

  local brewinfo = info:jq('.[0]'):json() --[[@as BrewCLI.Service]]

  self.service_name = brewinfo.service_name or 'unknown'
  self.running = brewinfo.running or false
  self.brewstatus = brewinfo.status or 'none'
  self.pid = brewinfo.pid
  self.plist = brewinfo.file

  return self
end


--
--
---@return BrewCLI.List
function BrewService.list()
  local result = sh.result({ 'brew', 'services', 'list', '--json' })
  
  if result:ok() then
    return result:json() --[[@as BrewCLI.List]]
  end
  
  error(result:error_msg())
end


--
--
---@return ks.brewservice
function BrewService:start()
  if not sh.result({ 'brew', 'services', 'start', self.name }):ok() then
    error(result:error_msg())
  end

  chan.publish(('ks:%s:start'):format(self.name), {})
  
  self:refreshInfo()

  return self
end


--
--
---@return ks.brewservice
function BrewService:stop()
  if not sh.result({ 'brew', 'services', 'stop', self.name }):ok() then
    error(result:error_msg())
  end
  
  chan.publish(('ks:%s:stop'):format(self.name), {})

  self:refreshInfo()

  return self
end


--
--
---@return ks.brewservice
function BrewService:restart()
  if not sh.result({ 'brew', 'services', 'restart', self.name }):ok() then
    error(result:error_msg())
  end

  return self
end


return proto.setProtoOf(BrewService, Service)