local watchable   = require "hs.watchable"
local timer       = require "hs.timer"
local BrewService = require 'user.lua.adapters.base.brew-service'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local util        = require 'user.lua.util'

local log = util.log('user:state','info')

ScreenAlert = nil


---@class KittySupremeGlobal
---@field boundkeys hs.hotkey[]
---@field urlhanders table[]
---@field menubar hs.menubar|nil
---@field services Dict<Service>

---@type KittySupremeGlobal
KittySupreme = {
  boundkeys = {},
  urlhanders = {},
  menubar = nil,
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

-- -- Works! Most of the time
-- KittySupreme.spacelabels = watchable.new('spacelabels', true)

-- KittySupreme.spacelabels.L1 = timer.localTime()

-- KittySupreme.spacelabelswatcher = watchable.watch('spacelabels.L1', function(watcher, path, key, old, new)
--   log.f('%s.%s Updated from [%q] to [%q]', path, key, old, new)
-- end)

-- local doEvery3 = hs.timer.doEvery(2, function()
--   KittySupreme.spacelabelswatcher:change(timer.localTime())
-- end)

-- local doEvery2 = hs.timer.doEvery(5, function()
--   log.i('5 second check:', KittySupreme.spacelabelswatcher:value())
-- end)

-- log.i("isRunning: ", doEvery2:running(), doEvery3:running())

return KittySupreme