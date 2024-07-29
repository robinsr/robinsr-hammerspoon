local Option = require 'user.lua.lib.optional' 
local func   = require 'user.lua.lib.func'
local logr   = require 'user.lua.util.logger'

local yabai = KittySupreme.services.yabai

local log = logr.new('ModSpaces/warp', 'debug')

local ensure_window = function(fn)
  return function(cmd, ctx)
    return Option:ofNil(ctx.activeWindow):map(fn):orElse('No active window')
  end
end


local arrange = {}

---@type ks.command.config[]
local cmds = {
  {
    id = 'spaces.space.swap_with_next',
    title = "Swap current space neighbor to right",
    flags = { 'no-alert' },
    exec = yabai.createMessageFn('space --move next', 'Moved space to the right'),
  },
  {
    id = 'spaces.space.swap_with_prev',
    title = "Swap current space neighbor to left",
    flags = { 'no-alert' },
    exec = yabai.createMessageFn('space --move prev', 'Moved space to the left'),
  },
  {
    id = 'spaces.arrange.move_to_next_space',
    title = "Send window to next space",
    mods = "btms",
    key = "right",
    flags = { 'no-alert' },
    exec = ensure_window(function(win)
      yabai.message('window --space next')
      yabai.message('space mouse --focus next')
      win:focus()

      return 'Moved window to right one space'
    end),
  },
  {
    id = 'spaces.arrange.move_to_prev_space',
    title = "Send window to previous space",
    mods = "btms",
    key = "left",
    flags = { 'no-alert' },
    exec = ensure_window(function(win)
      yabai.message('window --space prev')
      yabai.message('space mouse --focus prev')
      win:focus()

      return 'Moved window to left one space'
    end),
  },
  {
    id = 'spaces.arrange.move_to_next_display',
    title = "Send window to next display",
    mods = "btms",
    key = ']',
    flags = { 'no-alert' },
    exec = ensure_window(function(win)
      yabai.message('window --display prev')
      yabai.message('window --focus recent')

      return 'Moved window to "previous" display'
    end)
  },
  {
    id = 'spaces.arrange.move_to_prev_display',
    title = "Send window to previous display",
    mods = "btms",
    key = '[',
    flags = { 'no-alert' },
    exec = ensure_window(function(win)
      yabai.message('window --display next')
      yabai.message('window --focus recent')

      return 'Moved window to "next" display'
    end),
  },
  {
    id = 'spaces.arrange.swap_north',
    title = 'Swap with window above',
    mods = 'claw',
    key = 'up',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --swap north', 'Swapped window north'),
  },
  {
    id = 'spaces.arrange.swap_south',
    title = 'Swap with window below',
    mods = 'claw',
    key = 'down',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --swap south', 'Swapped window south'),
  },
  {
    id = 'spaces.arrange.swap_east',
    title = 'Swap with window right',
    mods = 'claw',
    key = 'right',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --swap east', 'Swapped window east'),
  },
  {
    id = 'spaces.arrange.swap_west',
    title = 'Swap with window left',
    mods = 'claw',
    key = 'left',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --swap west', 'Swapped window west'),
  },
    {
    id = 'spaces.arrange.warp_north',
    title = 'Warp to window above',
    mods = 'peace',
    key = 'up',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --warp north', 'Warp to window above'),
  },
  {
    id = 'spaces.arrange.warp_south',
    title = 'Warp to window below',
    mods = 'peace',
    key = 'down',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --warp south', 'Warp to window below'),
  },
  {
    id = 'spaces.arrange.warp_east',
    title = 'Warp to window right',
    mods = 'peace',
    key = 'right',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --warp east', 'Warp to window right'),
  },
  {
    id = 'spaces.arrange.warp_west',
    title = 'Warp to window left',
    mods = 'peace',
    key = 'left',
    flags = { 'no-chooser', 'no-alert' },
    exec = yabai.createMessageFn('window --warp west', 'Warp to window left'),
  },
}


return {
  module = "Arrange Windows",
  cmds = cmds,
}