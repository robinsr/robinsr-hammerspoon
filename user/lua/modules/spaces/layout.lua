local Option = require 'user.lua.lib.optional'
local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local mod = {}

mod.module = "Window Layout"

---@type ks.command.config[]
mod.cmds = {
  {
    id    = 'spaces.layout.rotate',
    title = 'Rotate layout clockwise',
    mods  = keys.preset.peace,
    key   = keys.code.R,
    flags = spaces.NO_ALERT,
    exec  = spaces.createMessageFn('space --rotate 90'),
  },
  
  {
    id    = 'spaces.layout.rebalance',
    title = 'Rebalance windows in space',
    mods  = keys.preset.peace,
    key   = keys.code.E,
    flags = spaces.NO_ALERT,
    exec  = spaces.createMessageFn('space --balance', 'Rebalanced windows'),
  },
  
  {
    id    = 'spaces.layout.cycle',
    title = "Cycle current space layout (bsp, float, stack)",
    icon  = "tag",
    mods  = keys.preset.peace,
    key   = keys.code.SPACE,
    flags = spaces.NO_ALERT,
    exec  = spaces.cycleLayout,
  },
  
  {
    id    = 'spaces.space.rename',
    title = "Label current space",
    icon  = "tag",
    mods  = keys.preset.btms,
    key   = keys.code.L,
    flags = spaces.NO_ALERT,
    exec  = spaces.rename,
  },

  {
    id    = "spaces.space.float_active_window",
    title = "Float Active Window",
    icon  = "float",
    verify = spaces.YABAI_MANAGED_SPACE,
    exec  = function(cmd, ctx)
      Option:ofNil(ctx.activeWindow):ifPresent(function(win)
        KittySupreme:getService('Yabai'):floatActiveWindow(win:id())
      end)
    end
  },
}

return mod