local sh      = require 'user.lua.adapters.shell'
local alert   = require 'user.lua.interface.alert'
local option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local webview = require 'user.lua.ui.webview'
local logr    = require 'user.lua.util.logger'
local json    = require 'user.lua.util.json'

local log = logr.new('yabai-cmd', 'debug')

local yabai = KittySupreme.services.yabai


local YabaiCmds = {}

---@type CommandConfig[]
YabaiCmds.cmds = {
  {
    id = 'yabai.service.restart',
    title = 'Restart Yabai',
    exec = function()
      local code = yabai and yabai:restart()
      return code == 0 and 'Restarted yabai' or ("Yabai:restart exit code %q"):format(code)
    end,
  },
  {
    id = 'yabai.manage.add',
    title = "Manage app's windows",
    exec = function()
      local active = hs.window.focusedWindow()
      local app = option.ofNil(active:application()):orElse({ title = function() return 'idk' end })

      local appName = app:title()

      return strings.fmt('Managing windows for app %s with yabai...', appName)
    end,
  },
  {
    id = 'yabai.manage.remove',
    title = "Ignore app's windows",
    exec = function() end,
  },
  {
    id = 'yabai.manage.list',
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
    title = "Show info for active app",
    exec = function()
      local vm = {
        title = 'Yabai - active window',
        data = yabai:getWindow(''),
      }

      webview.file('json.view', vm, vm.title)
    end,
  },
  {
    id = 'yabai.info.space',
    title = "Show info current space",
    exec = function()
      local vm = {
        title = 'Yabai - current space',
        data = yabai:getSpace('mouse'),
      }

      webview.file('json.view', vm, vm.title)
    end,
  },
}

return YabaiCmds