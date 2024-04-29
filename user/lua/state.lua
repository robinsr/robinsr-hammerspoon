local BrewService = require 'user.lua.adapters.base.brew-service'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'

local log = hs.logger.new('state.lua','info')

ScreenAlert = nil
SpaceLocations = {}

-- todo; come back to this--could work
SpaceLabels = hs.watchable.new('app.spaces.labels', true)


-- global state?
KittySupreme = {}
KittySupreme.services = {
  yabai = require 'user.lua.adapters.yabai',
  skhd = LaunchAgent:new('skhd', 'com.koekeishiya.skhd'),
}

for i,v in ipairs(BrewService:list()) do
  KittySupreme.services[v.name] = BrewService:new(v.name)
end

log.d(hs.inspect(KittySupreme.services))

return KittySupreme