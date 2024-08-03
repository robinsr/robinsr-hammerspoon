local sh      = require 'user.lua.adapters.shell'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local Option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local webview = require 'user.lua.ui.webview'
local logr    = require 'user.lua.util.logger'
local json    = require 'user.lua.util.json'
local desktop = require 'user.lua.interface.desktop'
local image   = require 'user.lua.ui.image'

local log = logr.new('yabai-cmd', 'debug')

local yabai = KittySupreme.services.yabai


local YabaiCmds = {}

YabaiCmds.module = "Yabai Commands"

---@type ks.command.config[]
YabaiCmds.cmds = {
  {
    id = 'yabai.service.restart',
    icon = "@/resources/images/yabai-logo.png",
    title = 'Restart Yabai',
    exec = function()
      local code = yabai and yabai:restart()
      return code == 0 and 'Restarted yabai' or ("Yabai:restart exit code %q"):format(code)
    end,
  },
  {
    id = 'yabai.manage.add',
    icon = "@/resources/images/yabai-logo.png",
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
    icon = "@/resources/images/yabai-logo.png",
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
  {
    id = 'yabai.manage.list',
    icon = "@/resources/images/yabai-logo.png",
    title = "Show ignore list",
    mods = "btms",
    key = "/",
    exec = function(cmd, ctx)
      local vm = {
        title = 'Yabai Rules!',
        data = yabai:getRules(),
      }

      webview.file('json.view', vm, vm.title)
    end,
  },
  {
    id = 'yabai.info.window',
    icon = "@/resources/images/yabai-logo.png",
    title = "Show info for focused window",
    exec = function()
      local ok, info = pcall(yabai.getWindow, '')

      local vm = {
        title = 'Yabai - active window',
        data = ok and info or { err = info },
      }

      webview.file('json.view', vm, vm.title)
    end,
  },
  {
    id = 'yabai.info.space',
    icon = "@/resources/images/yabai-logo.png",
    title = "Show info current space",
    exec = function(cmd, ctx)
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

      webview.file('json.view', vm, vm.title)
    end,
  },
}

return YabaiCmds