local sh      = require 'user.lua.adapters.shell'
local alert   = require 'user.lua.interface.alert'
local option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local logr    = require 'user.lua.util.logger'
local json    = require 'user.lua.util.json'

local webview = require 'user.lua.ui.webview.webview'

local log = logr.new('yabai-cmd', 'debug')

local yabai = KittySupreme.services.yabai


local YabaiCmds = {}

---@type CommandConfig[]
YabaiCmds.cmds = {
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
    mods = "bar",
    key = "/",
    exec = function(cmd, ctx)
      local rules = yabai:getRules()

      local vm = {
        title = 'Yabai Rules!',
        data = rules,
      }

      webview.page('data', vm, vm.title)
      
      return nil
    end,
  },
  {
    id = 'yabai.info.window',
    title = "Show info for active app",
    exec = function() end,
  },
  {
    id = 'yabai.info.space',
    title = "Show info current space",
    exec = function() end,
  },
}

return YabaiCmds