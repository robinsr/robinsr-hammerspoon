local desk   = require 'user.lua.interface.desktop'
local Option = require 'user.lua.lib.optional' 
local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local logr    = require 'user.lua.util.logger'
local log = logr.new('--TEMP--', 'debug')

local mod = {}

mod.module = "Column Layout"

---@type ks.command.config[]
mod.cmds = {
  {
    id     = 'window.grid.col_first3rd',
    title  = "Move window: 1st ⅓",
    icon   = '@/resources/images/left-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.BANG,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=3, h=3}, {w=1, h=3}, {x=0, y=0}),
      hgrid = spaces.createGridFn({w=3, h=3}, {w=1, h=3}, {x=0, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.col_second3rd',
    title  = "Move window: 2nd ⅓",
    icon   = '@/resources/images/middle-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.AT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=3, h=3}, {w=1, h=3}, {x=1, y=0}),
      hgrid = spaces.createGridFn({w=3, h=3}, {w=1, h=3}, {x=1, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.col_third3rd',
    title  = "Move window: 3rd ⅓",
    icon   = '@/resources/images/right-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.HASH,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=3, h=3}, {w=1, h=3}, {x=2, y=0}),
      hgrid = spaces.createGridFn({w=3, h=3}, {w=1, h=3}, {x=2, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.col_firstTwo3rds',
    title  = "Move window: 1st ⅔",
    mods   = keys.preset.peace,
    key    = keys.code.DOLLAR,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=3, h=3}, {w=2, h=3}, {x=0, y=0}),
      hgrid = spaces.createGridFn({w=3, h=3}, {w=2, h=3}, {x=0, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.col_secondTwo3rds',
    title  = "Move window: 2nd ⅔",
    mods   = keys.preset.peace,
    key    = keys.code.PERCENT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=3, h=3}, {w=2, h=3}, {x=1, y=0}),
      hgrid = spaces.createGridFn({w=3, h=3}, {w=2, h=3}, {x=1, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.top_left',
    title  = "Move Top Left",
    mods   = keys.preset.peace,
    key    = keys.code.AMP,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=16, h=10}, {w=5, h=4}, {x=0, y=0}),
      hgrid = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=0, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.bottom_left',
    title  = "Move Bottom Left",
    mods   = keys.preset.peace,
    key    = keys.code.ASTERISK,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=16, h=10}, {w=5, h=4}, {x=0, y=6}),
      hgrid = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=0, y=6}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.top_right',
    title  = "Move Top Right",
    mods   = keys.preset.peace,
    key    = keys.code.OPEN_PAREN,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=16, h=10}, {w=5, h=4}, {x=11, y=0}),
      hgrid = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=11, y=0}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.bottom_right',
    title  = "Move Bottom Right",
    mods   = keys.preset.peace,
    key    = keys.code.CLOSE_PAREN,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    setup  = { 
      ygrid = spaces.createYGridFn({w=16, h=10}, {w=5, h=4}, {x=11, y=6}),
      hgrid = spaces.createGridFn({w=16, h=10}, {w=5, h=4}, {x=11, y=6}),
    },
    exec = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end,
  },
  {
    id     = 'window.grid.center',
    title  = "Center Window",
    mods   = keys.preset.peace,
    key    = keys.code.C,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec = function(cmd, ctx)
      Option:ofNil(ctx.activeWindow):map(function(win)
        ---@cast win hs.window
        local frame = win:centerOnScreen()
        return cmd.title
      end)
      :orElse('No active window')
    end
  },
  {
    id    = 'window.shift.near_fullscreen',
    title = 'Maximize active window',
    mods  = keys.preset.peace,
    key   = keys.code.M,
    flags = spaces.NO_ALERT,
    setup = {
      hgrid = spaces.createGridFn({w=1, h=1}, {w=1, h=1}, {x=0, y=0}),
    },
    exec  = function(cmd, ctx)
      return ctx.hgrid(cmd, ctx)
    end
  },
  {
    id    = "spaces.space.float_active_window",
    title = "Float active window",
    icon  = "float",
    exec  = function(cmd, ctx)
      Option:ofNil(ctx.activeWindow):ifPresent(function(win)
        KittySupreme:getService('Yabai'):floatActiveWindow(win:id())
      end)
    end
  },
}

return mod