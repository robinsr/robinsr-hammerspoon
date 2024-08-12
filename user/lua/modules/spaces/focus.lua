local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local mod = {}

mod.module = "Window Focus"

---@type ks.command.config[]
mod.cmds = {
  {
    id     = 'window.focus.north',
    title  = 'Focus window above',
    icon   = '@/resources/images/win/arrange-up.tmpl.png',
    mods   = keys.preset.lil,
    key    = keys.code.UP,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowNorth() end,
  },
  
  {
    id     = 'window.focus.south',
    title  = 'Focus window below',
    icon   = '@/resources/images/win/arrange-down.tmpl.png',
    mods   = keys.preset.lil,
    key    = keys.code.DOWN,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowSouth() end,
  },
  
  {
    id     = 'window.focus.east',
    title  = 'Focus window right',
    icon   = '@/resources/images/win/arrange-right.tmpl.png',
    mods   = keys.preset.lil,
    key    = keys.code.RIGHT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowEast() end,
  },
  
  {
    id     = 'window.focus.west',
    title  = 'Focus window left',
    icon   = '@/resources/images/win/arrange-left.tmpl.png',
    mods   = keys.preset.lil,
    key    = keys.code.LEFT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = function(cmd, ctx) ctx.activeWindow:focusWindowWest() end,
  },
  
  {
    id     = 'spaces.focus.next',
    title  = 'Go to next space (→)',
    icon   = '@/resources/images/win/space-right.tmpl.png',
    mods   = keys.preset.ctrl,
    key    = keys.code.RIGHT,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('space --focus next'),
  },

  {
    id     = 'spaces.focus.prev',
    title  = 'Go to previous space (←)',
    icon   = '@/resources/images/win/space-left.tmpl.png',
    mods   = keys.preset.ctrl,
    key    = keys.code.LEFT,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('space --focus prev'),
  },

  {
    id     = 'displays.focus.prev',
    title  = 'Go to previous display (←)',
    icon   = '@/resources/images/win/screen-left.tmpl.png',
    mods   = keys.preset.ctrl,
    key    = keys.code.OPEN_BRACKET,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('display --focus west'),
  },
  
  {
    id     = 'displays.focus.next',
    title  = 'Go to next display (→)',
    icon   = '@/resources/images/win/screen-right.tmpl.png',
    mods   = keys.preset.ctrl,
    key    = keys.code.CLOSE_BRACKET,
    flags  = spaces.NO_ALERT,
    exec   = spaces.createMessageFn('display --focus east'),
  },
}

return mod