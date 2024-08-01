local Option = require 'user.lua.lib.optional' 
local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local yabai  = KittySupreme.services.yabai

local mod = {}

mod.module = "Arrange Windows"


---@type ks.command.config[]
mod.cmds = {
  {
    id    = 'spaces.space.swap_with_next',
    title = "Swap current space neighbor to right",
    flags = spaces.NO_ALERT,
    exec  = spaces.createMessageFn('space --move next', 'Moved space to the right'),
  },
  {
    id    = 'spaces.space.swap_with_prev',
    title = "Swap current space neighbor to left",
    flags = spaces.NO_ALERT,
    exec  = spaces.createMessageFn('space --move prev', 'Moved space to the left'),
  },
  {
    id    = 'windows.arrange.move_to_next_space',
    title = "Send window to next space",
    icon  = "@/resources/images/next-space.template.png",
    mods  = keys.preset.btms,
    key   = keys.code.RIGHT,
    flags = spaces.NO_ALERT,
    exec = function(cmd, ctx)
      return Option:ofNil(ctx.activeWindow):map(function(win)
        yabai.message('window --space next')
        yabai.message('space mouse --focus next')
        win:focus()

        return 'Moved window to right one space'
      end)
      :orElse('No active window')
    end
  },
  {
    id    = 'windows.shift.to_prev_space',
    title = "Send window to previous space",
    -- icon = "@/resources/images/prev-space.template.png",
    mods  = keys.preset.btms,
    key   = keys.code.LEFT,
    flags = spaces.NO_ALERT,
    exec  = function(cmd, ctx)
      return Option:ofNil(ctx.activeWindow):map(function(win)
        yabai.message('window --space prev')
        yabai.message('space mouse --focus prev')
        win:focus()

        return 'Moved window to left one space'
      end)
      :orElse('No active window')
    end,
  },
  {
    id    = 'windows.shift.to_next_display',
    title = "Send window to next display",
    mods  = keys.preset.btms,
    key   = keys.code.CLOSE_BRACKET,
    flags = spaces.NO_ALERT,
    exec  = function(cmd, ctx)
      return Option:ofNil(ctx.activeWindow):map(function(win)
        yabai.message('window --display prev')
        yabai.message('window --focus recent')

        return 'Moved window to "previous" display'
      end)
      :orElse('No active window')
    end,
  },
  {
    id    = 'windows.shift.to_prev_display',
    title = "Send window to previous display",
    mods  = keys.preset.btms,
    key   = keys.code.OPEN_BRACKET,
    flags = spaces.NO_ALERT,
    exec  = function(cmd, ctx)
      return Option:ofNil(ctx.activeWindow):map(function(win)
        yabai.message('window --display next')
        yabai.message('window --focus recent')

        return 'Moved window to "next" display'
      end)
      :orElse('No active window')
    end,
  },
  {
    id    = 'windows.swap.to_north',
    title = 'Swap with window above',
    mods  = keys.preset.claw,
    key   = keys.code.UP,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap north', 'Swapped window north'),
  },
  {
    id    = 'windows.swap.to_south',
    title = 'Swap with window below',
    mods  = keys.preset.claw,
    key   = keys.code.DOWN,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap south', 'Swapped window south'),
  },
  {
    id    = 'windows.swap.to_east',
    title = 'Swap with window right',
    mods  = keys.preset.claw,
    key   = keys.code.RIGHT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap east', 'Swapped window east'),
  },
  {
    id    = 'windows.swap.to_west',
    title = 'Swap with window left',
    mods  = keys.preset.claw,
    key   = keys.code.LEFT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap west', 'Swapped window west'),
  },
    {
    id    = 'windows.warp.to_north',
    title = 'Warp to window above',
    mods  = keys.preset.peace,
    key   = keys.code.UP,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp north', 'Warp to window above'),
  },
  {
    id    = 'windows.warp.to_south',
    title = 'Warp to window below',
    mods  = keys.preset.peace,
    key   = keys.code.DOWN,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp south', 'Warp to window below'),
  },
  {
    id    = 'windows.warp.to_east',
    title = 'Warp to window right',
    mods  = keys.preset.peace,
    key   = keys.code.RIGHT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp east', 'Warp to window right'),
  },
  {
    id    = 'windows.warp.to_west',
    title = 'Warp to window left',
    mods  = keys.preset.peace,
    key   = keys.code.LEFT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp west', 'Warp to window left'),
  },
}


return mod