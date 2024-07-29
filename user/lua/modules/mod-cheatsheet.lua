local desktop = require 'user.lua.interface.desktop'
local lists   = require 'user.lua.lib.list'
local Option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local appls   = require 'user.lua.model.application'
local hotkey  = require 'user.lua.model.hotkey'
local keys    = require 'user.lua.model.keys'
local webview = require 'user.lua.ui.webview.webview'
local icons   = require 'user.lua.ui.icons'
local logr    = require 'user.lua.util.logger'

local log = logr.new('mod/cheatsheet', 'debug')

local cheat = {}


cheat.module = 'Cheatsheet'

---@type ks.command.config[]
cheat.cmds = {
  {
    id = 'ks.commands.show_ks_hotkeys',
    title = "Show hotkeys for KittySupreme",
    icon = "kitty",
    key = "\\",
    mods = "btms",
    exec = function(cmd)
      local model = {
        title = "KittySupreme Hotkeys",
        mods = keys.presets,
        symbols = keys.symbols,
        groups = KittySupreme.commands:getHotkeyGroups(),
      }

      webview.file("cheatsheet.view", model, model.title)
    end,
  },
  {
    title = "Show Hotkeys for current app",
    id = "cheatsheet.show.active",
    key = "K",
    mods = "btms",
    flags = { 'no-alert' },
    exec = function(cmd, ctx)

      local model = Option:ofNil(ctx.activeApp)
        :map(function(app)
          log.inspect(app)
          local title = app:title()
          local menus = desktop.getMenuItems(app)

          print(hs.inspect(menus))

          return {
            title = ("Hotkeys for app %s"):format(title),
            mods = keys.presets,
            symbols = keys.symbols,
            groups = menus,
          }
      end)

      if model:isPresent() then
        local model = model:get()
        webview.page("json.view", model, model.title)
      else
        return "No active app"
      end
    end
  }
}

return cheat