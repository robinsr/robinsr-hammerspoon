local sh      = require 'user.lua.adapters.shell'
local alert   = require 'user.lua.interface.alert'
local desktop = require 'user.lua.interface.desktop'
local json    = require 'user.lua.lib.json'
local lists   = require 'user.lua.lib.list'
local Option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local keys    = require 'user.lua.model.keys'
local image   = require 'user.lua.ui.image'
local webview = require 'user.lua.ui.webview'
local logr    = require 'user.lua.util.logger'

local log = logr.new('yabai-cmd', 'debug')

local yabai_logo = '@/resources/images/logos/yabai-logo.png'


local YabaiCmds = {}

YabaiCmds.module = "Yabai Commands"

---@type ks.command.config[]
YabaiCmds.cmds = {
  {
    id    = 'yabai.service.restart',
    title = 'Restart Yabai',
    icon  = yabai_logo,
    exec  = function()
      local yabai = KittySupreme:getService('Yabai')
      local code = yabai:restart()

      return code == 0 and 'Restarted yabai' or ("Yabai:restart exit code %q"):format(code)
    end,
  },

  {
    id    = 'yabai.manage.list',
    title = 'Show ignore list',
    icon  = yabai_logo,
    mods  = keys.preset.btms,
    key   = keys.code.SLASH,
    exec  = function(cmd, ctx)
      local yabai = KittySupreme:getService('Yabai')
      local vm = {
        title = 'Yabai Rules!',
        data = yabai:getRules(),
      }

      webview.mainWindow('json.view', vm)
    end,
  },

  {
    id    = 'yabai.info.window',
    title = 'Show info for focused window',
    icon  = yabai_logo,
    exec  = function()
      local yabai = KittySupreme:getService('Yabai')
      local ok, info = pcall(yabai.getWindow, '')

      local vm = {
        title = 'Yabai - active window',
        data = ok and info or { err = info },
      }

      webview.mainWindow('json.view', vm)
    end,
  },

  {
    id    = 'yabai.info.space',
    title = 'Show info current space',
    icon  = yabai_logo,
    exec  = function(cmd, ctx)
      local yabai = KittySupreme:getService('Yabai')
      local spaceinfo = yabai:getSpace('mouse')

      spaceinfo.windows = lists(spaceinfo.windows)
        :map(function(win)
          local ok, info = pcall(yabai.getWindow, win)
          return ok and info or { id = win, err = info }
        end)
        :values()

      local vm = {
        title = 'Yabai - current space',
        data = spaceinfo,
      }

      webview.mainWindow('json.view', vm)
    end,
  },
}

return YabaiCmds

--[[
  {
    id = 'yabai.manage.add',
    icon = yabai_logo,
    title = "Manage app's windows",
    exec = function(cmd, ctx)
      return Option:ofNil(ctx.activeApp)
        :map(function(app) return app:title() end)
        :map(function(appName)
          -- yabai:addRule({ app = appName, manage = 'off' })

          return strings.fmt('Managing windows for app %s with yabai...', appName)
        end)
        :orElse('No active app')
    end,
  },

  {
    id = 'yabai.manage.remove',
    icon = yabai_logo,
    title = "Ignore app's windows",
    exec = function(cmd, ctx)
      return Option:ofNil(ctx.activeApp)
        :map(function(app) return app:title() end)
        :map(function(appName)
          -- yabai:removeRule()
          -- yabai:addRule({ app = appName, manage = 'off' })
          return strings.fmt('Ignore windows for app %s with yabai...', appName)
        end)
        :orElse('No active app')
    end,
  },
]]