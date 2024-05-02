local BrewService = require 'user.lua.adapters.base.brew-service'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local util        = require 'user.lua.util'

local log = util.log('user:state','info')

ScreenAlert = nil
SpaceLocations = {}

-- todo; come back to this--could work
-- SpaceLabels = hs.watchable.new('app.spaces.labels', true)


---@class KittySupremeGlobal
---@field boundkeys hs.hotkey[]
---@field urlhanders table[]
---@field services (Service)[]

---@type KittySupremeGlobal
KittySupreme = {
  boundkeys = {},
  urlhanders = {},
  menbar = nil,
  services = {},
}


KittySupreme.services = {
  yabai      = require 'user.lua.adapters.yabai',
  sketchybar = require 'user.lua.adapters.sketchybar',
  skhd       = LaunchAgent:new('skhd', 'com.koekeishiya.skhd'),
}

for i,v in ipairs(BrewService:list()) do
  if (KittySupreme.services[v.name] == nil) then
    KittySupreme.services[v.name] = BrewService:new(v.name)
  end
end

log.inspect(KittySupreme.services, { depth = 2 })

return KittySupreme