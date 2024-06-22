local space_util = require 'user.lua.modules.spaces.util'
local logr       = require 'user.lua.util.logger'

local send_message = space_util.send_message
local dir_keys     = space_util.dir_keys

local log = logr.new('ModSpaces/warp', 'debug')


local shift = {}

shift.cmds = {
  {
    id = 'spaces.space.move_next',
    title = "Move current space right",
    mods = "ctcmd",
    key = "]",
    exec = send_message('space --move next', 'Moved space to the right'),
  },
  {
    id = 'spaces.space.move_prev',
    title = "Move current space left",
    mods = "ctcmd",
    key = "[",
    exec = send_message('space --move prev', 'Moved space to the left'),
  },
  {
    id = 'spaces.shift.swap_north',
    title = 'Swap with window above',
    mods = 'modA',
    key = 'up',
    exec = send_message('window --swap north'),
  },
  {
    id = 'spaces.shift.swap_south',
    title = 'Swap with window below',
    mods = 'modA',
    key = 'down',
    exec = send_message('window --swap south'),
  },
  {
    id = 'spaces.shift.swap_east',
    title = 'Swap with window right',
    mods = 'modA',
    key = 'right',
    exec = send_message('window --swap east'),
  },
  {
    id = 'spaces.shift.swap_west',
    title = 'Swap with window left',
    mods = 'modA',
    key = 'left',
    exec = send_message('window --swap west'),
  },
    {
    id = 'spaces.shift.warp_north',
    title = 'Warp to window above',
    mods = 'modB',
    key = 'up',
    exec = send_message('window --warp north'),
  },
  {
    id = 'spaces.shift.warp_south',
    title = 'Warp to window below',
    mods = 'modB',
    key = 'down',
    exec = send_message('window --warp south'),
  },
  {
    id = 'spaces.shift.warp_east',
    title = 'Warp to window right',
    mods = 'modB',
    key = 'right',
    exec = send_message('window --warp east'),
  },
  {
    id = 'spaces.shift.warp_west',
    title = 'Warp to window left',
    mods = 'modB',
    key = 'left',
    exec = send_message('window --warp west'),
  },
}


return shift