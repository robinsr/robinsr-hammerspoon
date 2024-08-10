local desktop = require 'user.lua.interface.desktop'
local lists   = require 'user.lua.lib.list'
local Option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local appls   = require 'user.lua.model.application'
local hotkey  = require 'user.lua.model.hotkey'
local keys    = require 'user.lua.model.keys'
local webview = require 'user.lua.ui.webview.webview'
local logr    = require 'user.lua.util.logger'
local json    = require 'user.lua.util.json'

local log = logr.new('mod/cheatsheet', 'debug')


---@type ks.command.execfn<{}>
local showKsHotkeys = function(cmd)
  local khgroups = KittySupreme.commands:getHotkeyGroups()
  local title = "KittySupreme Hotkeys"

  local model = {
    title = title,
    mods = keys.preset,
    symbols = keys.symbols,
    groups = khgroups,
  }

  local jsonmodel = {
    title = title,
    data = {
      mods = keys.preset,
      symbols = keys.symbols,
      groups = khgroups,
    }
  }

  -- webview.mainWindow(('json.view', jsonmodel)
  webview.mainWindow('cheatsheet.view', model)
end


---@type ks.command.execfn<{}>
local showAppsHotkeys = function(cmd, ctx)

  return Option:ofNil(ctx.activeApp):map(function(app)
    log.inspect(app)
    
    local title = ("Hotkeys for app %s"):format(app:title())

    local menus = lists(desktop.getMenuItems(app))
      :filter(function(item)
        return item.hotkey ~= nil
        -- return true
      end)
      :groupBy('parent')
      -- :groupBy(function(item, i) return item.parent end)
      -- :values()

    local vm = {
      title = title,
      mods = keys.preset,
      symbols = keys.symbols,
      groups = menus,
      data = {
        mods = keys.preset,
        symbols = keys.symbols,
        groups = menus,
      }
    }

    webview.mainWindow('json.view', vm)

    return title
  end)
  :orElse('No active app')
end


---@type ks.command.config[]
local cmds = {
  {
    id    = "cheatsheet.show.kittysupreme",
    title = "Show hotkeys for KittySupreme",
    icon  = "kitty",
    key   = keys.code.BACKSLASH,
    mods  = keys.preset.btms,
    exec  = showKsHotkeys,
  },
  {
    id    = "cheatsheet.show.active",
    title = "Show Hotkeys for current app",
    key   = keys.code.K,
    mods  = keys.preset.btms,
    flags = { 'no-alert' },
    exec  = showAppsHotkeys,
  }
}

return {
  module = 'Cheatsheet',
  cmds   = cmds,
}