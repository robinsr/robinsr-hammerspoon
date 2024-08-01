local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local mod = {}

mod.module = "Window Focus"

---@type ks.command.config[]
mod.cmds = {
  {
    id     = 'window.focus.north',
    title  = 'Focus window above',
    mods   = keys.preset.lil,
    key    = keys.code.UP,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowNorth() end,
  },
  {
    id     = 'window.focus.south',
    title  = 'Focus window below',
    mods   = keys.preset.lil,
    key    = keys.code.DOWN,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowSouth() end,
  },
  {
    id     = 'window.focus.east',
    title  = 'Focus window right',
    mods   = keys.preset.lil,
    key    = keys.code.RIGHT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowEast() end,
  },
  {
    id     = 'window.focus.west',
    title  = 'Focus window left',
    mods   = keys.preset.lil,
    key    = keys.code.LEFT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowWest() end,
  },
  {
    id     = 'spaces.focus.next',
    title  = 'Go to next space (right)',
    mods   = keys.preset.ctrl,
    key    = keys.code.RIGHT,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('space --focus next'),
    },
  {
    id     = 'spaces.focus.prev',
    title  = 'Go to previous space (left)',
    mods   = keys.preset.ctrl,
    key    = keys.code.LEFT,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('space --focus prev'),
    },
  {
    id     = 'displays.focus.next',
    title  = 'Go to next display (right)',
    mods   = keys.preset.ctrl,
    key    = keys.code.OPEN_BRACKET,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('display --focus west'),
    },
  {
    id     = 'displays.focus.prev',
    title  = 'Go to previous display (left)',
    mods   = keys.preset.ctrl,
    key    = keys.code.CLOSE_BRACKET,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('display --focus east'),
  },
}

return mod