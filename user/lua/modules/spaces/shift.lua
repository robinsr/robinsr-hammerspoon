local desktop  = require 'user.lua.interface.desktop'
local Option = require 'user.lua.lib.optional' 
local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local inspect = require 'inspect'
local logr    = require 'user.lua.util.logger'
local log = logr.new('--TEMP-- ModSpaces/Shift', 'debug')

local yabai  = KittySupreme:getService('Yabai')

local mod = {}

mod.module = "Arrange Windows"

local JUMP_DISTANCE = "80"

local function file_icon(name)
  return '@/resources/images/'..name..'.tmpl.png'
end




---@type ks.command.config[]
mod.cmds = {
  {
    id    = 'spaces.space.swapWithNext',
    title = "Swap current space neighbor to right",
    flags = spaces.NO_ALERT,
    exec  = spaces.createMessageFn('space --move next', 'Moved space to the right'),
  },
  {
    id    = 'spaces.space.swapWithPrev',
    title = "Swap current space neighbor to left",
    flags = spaces.NO_ALERT,
    exec  = spaces.createMessageFn('space --move prev', 'Moved space to the left'),
  },
  {
    id    = 'windows.arrange.toNextSpace',
    title = "Send window to next space",
    icon  = file_icon 'win/space-right',
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
    id    = 'windows.shift.toPrevSpace',
    title = "Send window to previous space",
    icon  = file_icon 'win/space-left',
    mods  = keys.preset.btms,
    key   = keys.code.LEFT,
    flags = spaces.NO_ALERT,
    exec  = function(cmd, ctx)
      return Option:ofNil(ctx.activeWindow):map(function(win)
        local result = yabai.message('yabai -m query --spaces --space prev | jq ".type"')

        log.df('yabai -m query --spaces --space prev | jq ".type"', inspect(result))

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
    icon  = file_icon 'win/screen-right',
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
    icon  = file_icon 'win/screen-left',
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
    icon  = file_icon 'win/win-up',
    mods  = keys.preset.claw,
    key   = keys.code.UP,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap north', 'Swapped window north'),
  },
  {
    id    = 'windows.swap.to_south',
    title = 'Swap with window below',
    icon  = file_icon 'win/win-down',
    mods  = keys.preset.claw,
    key   = keys.code.DOWN,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap south', 'Swapped window south'),
  },
  {
    id    = 'windows.swap.to_east',
    title = 'Swap with window right',
    icon  = file_icon 'win/win-right',
    mods  = keys.preset.claw,
    key   = keys.code.RIGHT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap east', 'Swapped window east'),
  },
  {
    id    = 'windows.swap.to_west',
    title = 'Swap with window left',
    icon  = file_icon 'win/win-left',
    mods  = keys.preset.claw,
    key   = keys.code.LEFT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --swap west', 'Swapped window west'),
  },
    {
    id    = 'windows.warp.to_north',
    title = 'Warp to window above',
    icon  = file_icon 'win/win-up',
    mods  = keys.preset.peace,
    key   = keys.code.UP,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp north', 'Warp to window above'),
  },
  {
    id    = 'windows.warp.to_south',
    title = 'Warp to window below',
    icon  = file_icon 'win/win-down',
    mods  = keys.preset.peace,
    key   = keys.code.DOWN,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp south', 'Warp to window below'),
  },
  {
    id    = 'windows.warp.to_east',
    title = 'Warp to window right',
    icon  = file_icon 'win/win-right',
    mods  = keys.preset.peace,
    key   = keys.code.RIGHT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp east', 'Warp to window right'),
  },
  {
    id    = 'windows.warp.to_west',
    title = 'Warp to window left',
    icon  = file_icon 'win/win-left',
    mods  = keys.preset.peace,
    key   = keys.code.LEFT,
    flags = { 'no-chooser', 'no-alert' },
    exec  = spaces.createMessageFn('window --warp west', 'Warp to window left'),
  },
  {
    id    = 'windows.move.up',
    title = 'Move window up',
    mods  = keys.preset.peace,
    key   = keys.cardinal.north,
    flags = { 'no-chooser', 'no-alert' },
    -- UP yabai -m window --move rel:0:-30
    exec  = spaces.createMessageFn('window --move rel:0:-'..JUMP_DISTANCE),
  },
  {
    id    = 'windows.move.down',
    title = 'Move window down',
    mods  = keys.preset.peace,
    key   = keys.cardinal.south,
    flags = { 'no-chooser', 'no-alert' },
    -- DOWN yabai -m window --move rel:0:30
    exec  = spaces.createMessageFn('window --move rel:0:'..JUMP_DISTANCE),
  },
  {
    id    = 'windows.move.left',
    title = 'Move window left',
    mods  = keys.preset.peace,
    key   = keys.cardinal.west,
    flags = { 'no-chooser', 'no-alert' },
    -- LEFT yabai -m window --move rel:-30:0
    exec  = spaces.createMessageFn('window --move rel:-'..JUMP_DISTANCE..':0'),
  },
  {
    id    = 'windows.move.right',
    title = 'Move window right',
    mods  = keys.preset.peace,
    key   = keys.cardinal.east,
    flags = { 'no-chooser', 'no-alert' },
    -- RIGHT yabai -m window --move rel:30:0
    exec  = spaces.createMessageFn('window --move rel:'..JUMP_DISTANCE..':0'),
  },

}


return mod