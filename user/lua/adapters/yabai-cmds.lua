local shell   = require 'user.lua.interface.shell'
local option  = require 'user.lua.lib.optional'
local strings = require 'user.lua.lib.string'
local logr    = require 'user.lua.util.logger'

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
    id = 'Yabai.RestartYabai',
    title = "Restart Yabai",
    mods = "bar",
    key = "Y",
    exec = function (cmd, ctx)
      yabai:restart()
      
      if (ctx.trigger == 'hotkey') then
        return strings.fmt('%s: %s', cmd:getHotkey():tostring(), cmd.title)
      end
    end,
  },
  {
    id = 'Yabai.ManagedApps.Add',
    title = "Manage app's windows",
    exec = function()
      local active = hs.window.focusedWindow()
      local app = option.ofNil(active:application()):orElse({ title = function() return 'idk' end })

      local appName = app:title()

      return strings.fmt('Managing windows for app %s with yabai...', appName)
    end,
  },
  {
    id = 'Yabai.ManagedApps.Remove',
    title = "Ignore app's windows",
    exec = function() end,
  },
  {
    id = 'Yabai.ManagedApps.List',
    title = "Show ignore list",
    exec = function(cmd, ctx)
      local rules = yabai:getRules()
      log.inspect(rules)
    end,
  },
  {
    id = 'Yabai.Info.Window',
    title = "Show info for active app",
    exec = function() end,
  },
  {
    id = 'Yabai.Info.Space',
    title = "Show info current space",
    exec = function() end,
  },

  {
    id = 'Yabai.Focus.North',
    mods = 'modB',
    key = 'up',
    exec = runAndReturn('yabai -m window --focus north'),
  },
  {
    id = 'Yabai.Focus.South',
    mods = 'modB',
    key = 'down',
    exec = runAndReturn('yabai -m window --focus south'),
  },
  {
    id = 'Yabai.Focus.East',
    mods = 'modB',
    key = 'right',
    exec = runAndReturn('yabai -m window --focus east'),
  },
  {
    id = 'Yabai.Focus.West',
    mods = 'modB',
    key = 'left',
    exec = runAndReturn('yabai -m window --focus west'),
  },
  {
    id = 'Yabai.Space.Next',
    mods = 'ctrl',
    key = 'right',
    exec = runAndReturn('yabai -m space mouse --focus next', ''),
  },
  {
    id = 'Yabai.Space.Prev',
    mods = 'ctrl',
    key = 'left',
    exec = runAndReturn('yabai -m space mouse --focus prev', ''),
  },
  {
    id = 'Yabai.Space.RotateWindows',
    title = 'Rotate layout clockwise',
    mods = 'modA',
    key = 'r',
    exec = runAndReturn('yabai -m space --rotate 90'),
  },
  {
    id = 'Yabai.Space.Rebalance',
    title = 'Rotate layout clockwise',
    mods = 'modA',
    key = 'e',
    exec = runAndReturn('yabai -m space --balance'),
  },
  {
    id = 'Yabai.Active.ToggleFullscreen',
    title = 'Maximize active window',
    mods = 'modA',
    key = 'm',
    exec = runAndReturn('yabai -m window --toggle zoom-fullscreen'),
  },
}

return YabaiCmds