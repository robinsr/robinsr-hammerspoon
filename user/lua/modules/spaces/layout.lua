local strings    = require 'user.lua.lib.string'
local spaces     = require 'user.lua.modules.spaces'
local space_util = require 'user.lua.modules.spaces.util'
local logr       = require 'user.lua.util.logger'

local send_message = space_util.send_message
local dir_keys     = space_util.dir_keys

---@type Yabai
local yabai      = KittySupreme.services.yabai


local shift = {}

shift.cmds = {
  {
    id = 'spaces.layout.rotate_windows',
    title = 'Rotate layout clockwise',
    mods = 'modA',
    key = 'r',
    exec = send_message('space --rotate 90'),
  },
  {
    id = 'spaces.layout.rebalance',
    title = 'Rebalance windows in space',
    mods = 'modA',
    key = 'e',
    exec = send_message('space --balance', 'Rebalanced windows'),
  },
  {
    id = 'spaces.layout.toggle_fullscreen',
    title = 'Maximize active window',
    mods = 'modA',
    key = 'm',
    exec = send_message('window --toggle zoom-fullscreen'),
  },
  {
    id = 'spaces.space.cycle',
    title = "Cycle current space layout (bsp, float, stack)",
    icon = "tag",
    mods = "modA",
    key = "space",
    exec = function(cmd)
      local layout = spaces.cycleLayout()
      return strings.fmt("Changed layout to %s", layout)
    end,
  },
   {
    id = 'spaces.space.rename',
    title = "Label current space",
    icon = "tag",
    mods = "bar",
    key = "L",
    exec = function(cmd, ctx)
      spaces.rename()
      return ctx.trigger == 'hotkey' and 'default' or nil
    end,
  },
  { 
    id = "spaces.space.float_active_window",
    title = "Float active window",
    icon = "float",
    exec = function (cmd, ctx)
      yabai:floatActiveWindow()
      return ctx.trigger == 'hotkey' and 'default' or nil
    end
  },

}


return shift