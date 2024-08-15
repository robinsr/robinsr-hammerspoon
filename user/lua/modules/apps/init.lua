local desk    = require 'user.lua.interface.desktop'
local json    = require 'user.lua.lib.json'
local Option  = require 'user.lua.lib.optional'
local webview = require 'user.lua.ui.webview'
local logr    = require 'user.lua.util.logger'

local log = logr.new('apps', 'debug')

local download_iocn = '@/resources/images/icon/json-download.tmpl.png'

local function onLoad()
  log.df('Pre-loading hs.application; returned %s', hs.application.find('hammerspoon'))
end

---@type ks.module
local Apps = {
  module = 'Apps init',
  cmds = {
    {
      id     = 'apps.info.window',
      title  = 'Show Info for Active Window',
      icon   = download_iocn,
      verify = {},
      exec   = function(cmd, ctx, params)
        return Option:ofNil(ctx.activeApp)
          :map(function(app) return app:focusedWindow() end)
          :map(function(win) return desk.windowInfo(win) end)
          :map(function(info)
            webview.mainWindow('json.view', {
              title = ('Info for window "%s"'):format(info.title),
              data = info,
            })

            return { ok = true }
          end)
          :orElse({ err = 'No focused window' })
      end,
    },

    {
      id    = 'apps.info.app',
      title = 'Show Info for Active App',
      icon  = download_iocn,
      exec  = function(cmd, ctx, params)
        return Option:ofNil(ctx.activeApp)
          :map(function(app) return desk.appInfo(app) end)
          :map(function(info)
            webview.mainWindow('json.view', {
              title = ('Info for app "%s"'):format(info.title),
              data = info,
            })

            return { ok = true }
          end)
          :orElse({ err = 'No active app' })
      end,
    },
  }
}

return Apps