local space_util = require 'user.lua.modules.spaces.util'
local logr       = require 'user.lua.util.logger'
local desk = require 'user.lua.interface.desktop'

local yabai = KittySupreme.services.yabai

local send_message = space_util.send_message
local dir_keys     = space_util.dir_keys

local log = logr.new('ModSpaces/warp', 'debug')


local arrange = {}

arrange.cmds = {
  {
    id = 'spaces.space.swap_with_next',
    title = "Swap current space neighbor to right",
    -- mods = "btms",
    -- key = "left",
    exec = send_message('space --move next', 'Moved space to the right'),
  },
  {
    id = 'spaces.space.swap_with_prev',
    title = "Swap current space neighbor to left",
    -- mods = "btms",
    -- key = "right",
    exec = send_message('space --move prev', 'Moved space to the left'),
  },
  {
    id = 'spaces.arrange.move_next',
    title = "Send window to next space",
    mods = "btms",
    key = "right",
    setup = {
      move_window = send_message('window --space next', true),
      goto_window = send_message('space mouse --focus next', 'Moved space to the right'),
    },
    exec = function(cmd, ctx)
      local win = desk.activeWindowId()
      ctx.move_window()
      ctx.goto_window()
      hs.window.get(win):focus()
    end,
  },
  {
    id = 'spaces.arrange.move_prev',
    title = "Send window to previous space",
    mods = "btms",
    key = "left",
    setup = {
      move_window = send_message('window --space prev', true),
      goto_window = send_message('space mouse --focus prev', 'Moved space to the left'),
    },
    exec = function(cmd, ctx)
      local win = desk.activeWindowId()
      ctx.move_window()
      ctx.goto_window()
      hs.window.get(win):focus()
    end,
  },
  {
    id = 'spaces.arrange.swap_north',
    title = 'Swap with window above',
    mods = 'claw',
    key = 'up',
    exec = send_message('window --swap north'),
  },
  {
    id = 'spaces.arrange.swap_south',
    title = 'Swap with window below',
    mods = 'claw',
    key = 'down',
    exec = send_message('window --swap south'),
  },
  {
    id = 'spaces.arrange.swap_east',
    title = 'Swap with window right',
    mods = 'claw',
    key = 'right',
    exec = send_message('window --swap east'),
  },
  {
    id = 'spaces.arrange.swap_west',
    title = 'Swap with window left',
    mods = 'claw',
    key = 'left',
    exec = send_message('window --swap west'),
  },
    {
    id = 'spaces.arrange.warp_north',
    title = 'Warp to window above',
    mods = 'lil',
    key = 'up',
    exec = send_message('window --warp north'),
  },
  {
    id = 'spaces.arrange.warp_south',
    title = 'Warp to window below',
    mods = 'lil',
    key = 'down',
    exec = send_message('window --warp south'),
  },
  {
    id = 'spaces.arrange.warp_east',
    title = 'Warp to window right',
    mods = 'lil',
    key = 'right',
    exec = send_message('window --warp east'),
  },
  {
    id = 'spaces.arrange.warp_west',
    title = 'Warp to window left',
    mods = 'lil',
    key = 'left',
    exec = send_message('window --warp west'),
  },
}


return arrange