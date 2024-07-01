local space_util = require 'user.lua.modules.spaces.util'
local logr       = require 'user.lua.util.logger'

local send_message = space_util.send_message
local dir_keys     = space_util.dir_keys

local log = logr.new('ModSpaces/warp', 'debug')


local shift = {}

shift.cmds = {
  {
    id = 'spaces.space.move_next',
    title = "Swap current space neighbor to right",
    mods = "btms",
    key = "left",
    exec = send_message('space --move next', 'Moved space to the right'),
  },
  {
    id = 'spaces.space.move_prev',
    title = "Swap current space neighbor to left",
    mods = "btms",
    key = "right",
    exec = send_message('space --move prev', 'Moved space to the left'),
  },
  {
    id = 'spaces.shift.swap_north',
    title = 'Swap with window above',
    mods = 'claw',
    key = 'up',
    exec = send_message('window --swap north'),
  },
  {
    id = 'spaces.shift.swap_south',
    title = 'Swap with window below',
    mods = 'claw',
    key = 'down',
    exec = send_message('window --swap south'),
  },
  {
    id = 'spaces.shift.swap_east',
    title = 'Swap with window right',
    mods = 'claw',
    key = 'right',
    exec = send_message('window --swap east'),
  },
  {
    id = 'spaces.shift.swap_west',
    title = 'Swap with window left',
    mods = 'claw',
    key = 'left',
    exec = send_message('window --swap west'),
  },
    {
    id = 'spaces.shift.warp_north',
    title = 'Warp to window above',
    mods = 'lil',
    key = 'up',
    exec = send_message('window --warp north'),
  },
  {
    id = 'spaces.shift.warp_south',
    title = 'Warp to window below',
    mods = 'lil',
    key = 'down',
    exec = send_message('window --warp south'),
  },
  {
    id = 'spaces.shift.warp_east',
    title = 'Warp to window right',
    mods = 'lil',
    key = 'right',
    exec = send_message('window --warp east'),
  },
  {
    id = 'spaces.shift.warp_west',
    title = 'Warp to window left',
    mods = 'lil',
    key = 'left',
    exec = send_message('window --warp west'),
  },
}


return shift