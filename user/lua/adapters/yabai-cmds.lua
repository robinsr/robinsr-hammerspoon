local shell   = require 'user.lua.adapters.shell'
local alert   = require 'user.lua.interface.alert'
local lists   = require 'user.lua.lib.list'
local option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local logr    = require 'user.lua.util.logger'
local json    = require 'user.lua.util.json'

local log = logr.new('yabai-cmd', 'debug')

local yabai = KittySupreme.services.yabai

local function runAndReturn(cmd, msg)
  return function(ctx)
    shell.run(cmd .. ' ' .. shell.IGNORE)
    return msg or ctx.title or ctx.id
  end
end


local YabaiCmds = {}

YabaiCmds.cmds = {
  {
    id = 'yabai.service.restart',
    title = "Restart Yabai",
    mods = "bar",
    key = "Y",
    exec = function (cmd, ctx)
      yabai:restart()
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
    exec = function(cmd, ctx)
      local rules = yabai:getRules()

      alert:new(json.tostring(rules)):show(alert.timing.LONG)
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

  {
    id = 'yabai.focus.north',
    title = 'Focus window above',
    mods = 'modB',
    key = 'up',
    exec = runAndReturn('yabai -m window --focus north'),
  },
  {
    id = 'yabai.focus.south',
    title = 'Focus window below',
    mods = 'modB',
    key = 'down',
    exec = runAndReturn('yabai -m window --focus south'),
  },
  {
    id = 'yabai.focus.east',
    title = 'Focus window right',
    mods = 'modB',
    key = 'right',
    exec = runAndReturn('yabai -m window --focus east'),
  },
  {
    id = 'yabai.focus.west',
    title = 'Focus window left',
    mods = 'modB',
    key = 'left',
    exec = runAndReturn('yabai -m window --focus west'),
  },
  {
    id = 'yabai.space.next',
    title = 'Go to next space (right)',
    mods = 'ctrl',
    key = 'right',
    exec = runAndReturn('yabai -m space mouse --focus next', ''),
  },
  {
    id = 'yabai.space.prev',
    title = 'Go to previous space (left)',
    mods = 'ctrl',
    key = 'left',
    exec = runAndReturn('yabai -m space mouse --focus prev', ''),
  },
  {
    id = 'yabai.space.rotateWindows',
    title = 'Rotate layout clockwise',
    mods = 'modA',
    key = 'r',
    exec = runAndReturn('yabai -m space --rotate 90'),
  },
  {
    id = 'yabai.space.rebalance',
    title = 'Rebalance windows in space',
    mods = 'modA',
    key = 'e',
    exec = runAndReturn('yabai -m space --balance'),
  },
  {
    id = 'yabai.Active.toggleFullscreen',
    title = 'Maximize active window',
    mods = 'modA',
    key = 'm',
    exec = runAndReturn('yabai -m window --toggle zoom-fullscreen'),
  },
}

return YabaiCmds