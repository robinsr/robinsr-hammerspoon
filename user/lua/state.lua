-- local watchable   = require "hs.watchable"
local BrewService = require 'user.lua.adapters.base.brew-service'
local lists       = require 'user.lua.lib.list'
local logr        = require 'user.lua.util.logger'

local log = logr.log('core.state', 'info')


---@class Services
---@field yabai Yabai
---@field sketchybar SketchyBar


---@class KittySupremeGlobal
---@field commands ks.commandlist
---@field menubar hs.menubar|nil
---@field services Services

---@type KittySupremeGlobal
KittySupreme = {
  commands = {},
  menubar = nil,
  services = {
    yabai      = require('user.lua.adapters.yabai'):new(),
    sketchybar = require('user.lua.adapters.sketchybar'):new(),
    skhd       = require('user.lua.adapters.skhd'):new(),
  },
}


for i,v in ipairs(BrewService.list()) do
  if (KittySupreme.services[v.name] == nil) then
    KittySupreme.services[v.name] = BrewService:new(v.name)
  end
end

log.inspect('Services loaded:', KittySupreme.services, { depth = 2 })

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