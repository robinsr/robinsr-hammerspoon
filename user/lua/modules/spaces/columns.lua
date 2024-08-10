local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local mod = {}

mod.module = "Window Grid Layout"

---@type ks.command.config<any>[]
mod.cmds = {
  {
    id     = 'window.grid.col_first3rd',
    title  = 'Move window: 1st ⅓',
    icon   = '@/resources/images/left-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.BANG,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=3, h=3}, {w=1, h=3}, {x=0, y=0}),
  },

  {
    id     = 'window.grid.col_second3rd',
    title  = 'Move window: 2nd ⅓',
    icon   = '@/resources/images/middle-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.AT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=3, h=3}, {w=1, h=3}, {x=1, y=0}),
  },

  {
    id     = 'window.grid.col_third3rd',
    title  = 'Move window: 3rd ⅓',
    icon   = '@/resources/images/right-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.HASH,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=3, h=3}, {w=1, h=3}, {x=2, y=0}),
  },

  {
    id     = 'window.grid.col_firstTwo3rds',
    title  = 'Move window: 1st ⅔',
    icon   = 'rectangle.split.3x1.fill',
    mods   = keys.preset.peace,
    key    = keys.code.DOLLAR,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=3, h=3}, {w=2, h=3}, {x=0, y=0}),
  },

  {
    id     = 'window.grid.col_secondTwo3rds',
    title  = 'Move window: 2nd ⅔',
    icon   = 'rectangle.split.3x1.fill',
    mods   = keys.preset.peace,
    key    = keys.code.PERCENT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=3, h=3}, {w=2, h=3}, {x=1, y=0}),
  },

  {
    id     = 'window.grid.top_left',
    title  = 'Move Top Left',
    icon  = 'rectangle.inset.topleft.filled',
    mods   = keys.preset.peace,
    key    = keys.code.AMP,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=0, y=0}),
  },

  {
    id     = 'window.grid.bottom_left',
    title  = 'Move Bottom Left',
    icon  = 'rectangle.inset.bottomleft.filled',
    mods   = keys.preset.peace,
    key    = keys.code.ASTERISK,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=0, y=6}),
  },

  {
    id     = 'window.grid.top_right',
    title  = 'Move Top Right',
    icon  = 'rectangle.inset.topright.filled',
    mods   = keys.preset.peace,
    key    = keys.code.OPEN_PAREN,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=11, y=0}),
  },

  {
    id     = 'window.grid.bottom_right',
    title  = 'Move Bottom Right',
    icon  = 'rectangle.inset.bottomright.filled',
    mods   = keys.preset.peace,
    key    = keys.code.CLOSE_PAREN,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=11, y=6}),
  },
}

return mod