local inspect     = require "inspect"
local BrewService = require 'user.lua.adapters.base.brew-service'
local channels    = require 'user.lua.lib.channels'
local lists       = require 'user.lua.lib.list'
local Option      = require 'user.lua.lib.optional'
local tables      = require 'user.lua.lib.table'
local logr        = require 'user.lua.util.logger'

local log = logr.log('core.state', 'info')


---@class Services
---@field yabai Yabai
---@field sketchybar SketchyBar


---@class ks.state
---@field commands ks.commandlist
---@field menubar hs.menubar|nil
---@field services Services


---@class ks.state
local State = {}


function State:new()
  ---@class ks.state
  local this = self ~= State and self or {}

  this.commands = {}

  this.menubar = nil

  this.services = {
    yabai      = require('user.lua.adapters.yabai'):new(),
    sketchybar = require('user.lua.adapters.sketchybar'):new(),
    skhd       = require('user.lua.adapters.skhd'):new(),
  }

  for i,v in ipairs(BrewService.list()) do
    if (this.services[v.name] == nil) then
      this.services[v.name] = BrewService:new(v.name)
    end
  end

  log.inspect('Services loaded:', this.services, { depth = 2 })


  _G.fire = function(evtName, data)
    channels.publish(evtName, data)
  end

  channels.subscribe({ 'ks' }, function(channel, data)
    log.f('KS Event: %s - %s', channel, inspect(data))
  end)
  
  return setmetatable(this, { __index = State })
end



--
-- Returns a service class instance by string name
--
---@generic T
---@param class `T` - Name of the service 
---@return T
function State:getService(class)
  if tables(self.services):has(class) then
    return tables(self.services):get(class)
  end

  error('Could not find service')
end


return State