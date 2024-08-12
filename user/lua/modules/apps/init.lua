local ksalert  = require 'user.lua.interface.alert'
local desktop  = require 'user.lua.interface.desktop'
local appmodel = require 'user.lua.model.application'
local Option   = require 'user.lua.lib.optional'
local json     = require 'user.lua.util.json'
local logr     = require 'user.lua.util.logger'

local log = logr.new('apps', 'debug')


local Apps = {}

function Apps.onLoad()
  log.df('Pre-loading hs.application; returned %s', hs.application.find('hammerspoon'))
end



---@type ks.command.config[]
Apps.cmds = {
  {
    id = 'apps.current.window',
    title = 'Copy JSON for current window',
    icon = '@/resources/images/icons/json-download.tmpl.png',
    module = 'Apps',
    exec = function(cmd, ctx, params)
      local result = Option:ofNil(ctx.activeApp)
        :map(function(app) return app:focusedWindow() end)
        :map(function(win) return desktop.windowInfo(win) end)
        :map(function(info)
          desktop.setPasteBoard(json.tostring(info))
          return ('Copying JSON for window "%s"'):format(info.title)
        end)
        :orElse('No focused window')

      ksalert:new(result):show(ksalert.timing.LONG)
    end,
  },
  {
    id = 'apps.current.app',
    title = 'Copy JSON for current app',
    icon = '@/resources/images/icons/json-download.tmpl.png',
    module = 'Apps',
    exec = function(cmd, ctx, params)
      local result = Option:ofNil(ctx.activeApp)
        :map(function(app) return desktop.appInfo(app) end)
        :map(function(info)
          desktop.setPasteBoard(json.tostring(info))
          return ('Copying JSON for app "%s"'):format(info.title)
        end)
        :orElse('No active app')

      ksalert:new(result):show(ksalert.timing.LONG)
    end,
  },
}


return Apps