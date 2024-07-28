local space_util = require 'user.lua.modules.spaces.util'
local logr       = require 'user.lua.util.logger'

local yabai = KittySupreme.services.yabai

local send_message = space_util.send_message
local dir_keys     = space_util.dir_keys

local log = logr.new('ModSpaces/warp', 'debug')


local arrange = {}

---@type ks.command.config[]
local cmds = {
  {
    id = 'spaces.space.swap_with_next',
    title = "Swap current space neighbor to right",
    -- mods = "btms",
    -- key = "left",
    flags = { 'no-alert' },
    exec = send_message('space --move next', 'Moved space to the right'),
  },
  {
    id = 'spaces.space.swap_with_prev',
    title = "Swap current space neighbor to left",
    -- mods = "btms",
    -- key = "right",
    flags = { 'no-alert' },
    exec = send_message('space --move prev', 'Moved space to the left'),
  },
  {
    id = 'spaces.arrange.move_to_next_space',
    title = "Send window to next space",
    mods = "btms",
    key = "right",
    flags = { 'no-alert' },
    exec = function(cmd, ctx)
      send_message('window --space next')()
      send_message('space mouse --focus next')()
      ctx.activeWindow:focus()
      return 'Moved space to the right'
    end,
  },
  {
    id = 'spaces.arrange.move_to_prev_space',
    title = "Send window to previous space",
    mods = "btms",
    key = "left",
    flags = { 'no-alert' },
    exec = function(cmd, ctx)
      send_message('window --space prev')()
      send_message('space mouse --focus prev')()
      ctx.activeWindow:focus()
      return 'Moved space to the left'
    end,
  },
  {
    id = 'spaces.arrange.toggle_maximize',
    title = 'Toggle maximize',
    icon = 'info',
    mods = 'claw',
    key = 'm',
    exec = send_message('window --toggle zoom-fullscreen'),
  },
  {
    id = 'spaces.arrange.swap_north',
    title = 'Swap with window above',
    mods = 'claw',
    key = 'up',
    flags = { 'no-chooser' },
    exec = send_message('window --swap north'),
  },
  {
    id = 'spaces.arrange.swap_south',
    title = 'Swap with window below',
    mods = 'claw',
    key = 'down',
    flags = { 'no-chooser' },
    exec = send_message('window --swap south'),
  },
  {
    id = 'spaces.arrange.swap_east',
    title = 'Swap with window right',
    mods = 'claw',
    key = 'right',
    flags = { 'no-chooser' },
    exec = send_message('window --swap east'),
  },
  {
    id = 'spaces.arrange.swap_west',
    title = 'Swap with window left',
    mods = 'claw',
    key = 'left',
    flags = { 'no-chooser' },
    exec = send_message('window --swap west'),
  },
    {
    id = 'spaces.arrange.warp_north',
    title = 'Warp to window above',
    mods = 'peace',
    key = 'up',
    flags = { 'no-chooser' },
    exec = send_message('window --warp north', 'Warp to window above'),
  },
  {
    id = 'spaces.arrange.warp_south',
    title = 'Warp to window below',
    mods = 'peace',
    key = 'down',
    flags = { 'no-chooser' },
    exec = send_message('window --warp south', 'Warp to window below'),
  },
  {
    id = 'spaces.arrange.warp_east',
    title = 'Warp to window right',
    mods = 'peace',
    key = 'right',
    flags = { 'no-chooser' },
    exec = send_message('window --warp east', 'Warp to window right'),
  },
  {
    id = 'spaces.arrange.warp_west',
    title = 'Warp to window left',
    mods = 'peace',
    key = 'left',
    flags = { 'no-chooser' },
    exec = send_message('window --warp west', 'Warp to window left'),
  },
}


return {
  module = "Arrange Windows",
  cmds = cmds,
}