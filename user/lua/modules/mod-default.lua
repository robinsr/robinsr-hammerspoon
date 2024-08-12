local inspect = require 'hs.inspect'
local console = require 'user.lua.interface.console'
local desk    = require 'user.lua.interface.desktop'
local chan    = require 'user.lua.lib.channels'
local func    = require 'user.lua.lib.func'
local Option  = require 'user.lua.lib.optional'
local paths   = require 'user.lua.lib.path'
local strings = require 'user.lua.lib.string'
local keys    = require 'user.lua.model.keys'
local rdir    = require 'user.lua.ui.resource-dir'
local logr    = require 'user.lua.util.logger'

local log = logr.new('mod-default', 'info')

local icon_manifest = '@/resources/images/_manifest.hjson'

local defmod = {}

defmod.module = "default"

---@type ks.command.config[]
defmod.cmds = {
  {
    id = 'ks.evt.onLoad',
    exec = function()
      log.i('Running KittySupreme onLoad...')

      local image_watcher = rdir:new(icon_manifest):watch()

      chan.publish('ks:frontapp:changed', { name = 'Hammerspoon Loaded!' })
    end,
  },
  {
    id    = 'ks.commands.showHSConsole',
    title = 'Show console',
    icon  = '@/resources/images/icons/console.tmpl.png',
    key   = keys.code.I,
    mods  = keys.preset.btms,
    flags = { 'no-alert' },
    exec  = function()
      hs.toggleConsole()
      -- hs.openConsole(true)
    end,
  },

  {
    id    = 'ks.commands.toggle_darkmode',
    title = 'Toggle dark mode',
    icon  = '@/resources/images/icons/day-night.tmpl.png',
    flags = { 'no-alert' },
    exec  = function()
      console.setDarkMode(desk.darkMode())
    end,
  },

  {
    id    = 'ks.commands.reloadConfig',
    title = 'Reload Config',
    icon  = '@/resources/images/icons/sync-settings.tmpl.png',
    key   = keys.code.W,
    mods  = keys.preset.btms,
    flags = { 'no-alert' },
    exec  = function(cmd)
      func.delay(0.75, hs.reload)
      return { ok = cmd.hotkey:getLabel('full') }
    end,
  },

  {
    id    = 'ks.commands.restartHS',
    title = "Relaunch Hammerspoon",
    icon  = "reload",
    key   = keys.code.X,
    mods  = keys.preset.btms,
    flags = { 'no-alert' },
    exec  = function(cmd)
      func.delay(0.75, hs.relaunch)
      return { ok = cmd.hotkey:getLabel('full') }
    end,
  },

  {
    id    = 'ks.commands.sync_icon_files',
    title = 'Sync Icon Files',
    icon  = 'info',
    flags = { 'no-alert' },
    exec  = function(cmd, ctx, params)
      rdir:new(icon_manifest, true)
    end,
  },

  {
    id    = 'ks.commands.show_icons',
    title = 'Show All Command Icons',
    icon  = 'info',
    flags = { 'no-alert' },
    exec  = function(cmd, ctx, params)
      local cmd_table = KittySupreme.commands
        :map(function(cmd)
          ---@cast cmd ks.command
          return {cmd=cmd.id, mod=cmd.module, icon=cmd.icon}
        end)
        :values()

        log.f('Command Icons: %s', inspect(cmd_table, { depth = 2 }))
    end,
  }
}

return defmod