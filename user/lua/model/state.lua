local inspect     = require "inspect"
local desk        = require 'user.lua.interface.desktop'
local watch       = require 'user.lua.interface.watchable'
local BrewService = require 'user.lua.adapters.base.brew-service'
local channels    = require 'user.lua.lib.channels'
local lists       = require 'user.lua.lib.list'
local Option      = require 'user.lua.lib.optional'
local params      = require 'user.lua.lib.params'
local tables      = require 'user.lua.lib.table'
local logr        = require 'user.lua.util.logger'

local log = logr.new('-- STATE --', 'info')


---@class Services
---@field yabai      Yabai
---@field sketchybar SketchyBar
---@field borders    ks.brewservice


---@class borders : ks.brewservice


---@class ks.state
---@field commands ks.commandlist
---@field menubar  hs.menubar|nil
---@field services { [string]: ks.service }


---@class ks.model
---@field activeSpace   integer
---@field screens       integer


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
    params.assert.string(evtName, 1)
    params.assert.tabl(data, 2)

    channels.publish(evtName, data)
  end


  this.post_init = hs.timer.doAfter(2, function()

    local root = watch.create('root', true, {
      activeSpace = desk.activeSpace(),
      screenCount = #desk.screens()
    })

    channels.subscribe('ks:screen:*', function(data)
      root['screenCount'] = #desk.screens()
    end)

    channels.subscribe('ks:space:changed', function(data, channel)
      log.df('KS subscriber: %s - %s', channel, inspect(data))
      root['activeSpace'] = tonumber(data.index, 10)
    end)
  end)
  
  
  return setmetatable(this, { __index = State })
end



--
-- Returns a service class instance by string name
--
---@generic T : ks.service
---@param class `T` - Name of the service 
---@return T
function State:getService(class)
  params.assert.string(class)

  local services = tables(self.services)
  
  local variants = { class, string.upper(class), string.lower(class) }

  for i,var in ipairs(variants) do
    if services:has(var) then
      return services:get(var)
    end
  end

  error(('Could not find service [%s]'):format(class))
end

--
-- Returns a Brew Service class instance by string name
--
---@generic T : ks.brewservice
---@param class `T` - Name of the service 
---@return T
function State:getBrewService(class)
  params.assert.string(class)

  return self:getService(class) --[[@as ks.brewservice]]
end


return State