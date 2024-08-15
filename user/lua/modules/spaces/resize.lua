local desk   = require 'user.lua.interface.desktop'
local Option = require 'user.lua.lib.optional'
local keys   = require 'user.lua.model.keys'
local spaces = require 'user.lua.modules.spaces'

local function file_icon(name)
  return '@/resources/images/'..name..'.tmpl.png'
end

local function positive_log_scale(pct)
  assert(pct < 1 and pct > 0, 'Window percentage must be between 0 and 1, found: '..tostring(pct))
  return 2.01 - math.log(pct * 100, 100)
end

---@type ks.command.execfn
local function reasonable(cmd, ctx)
  return Option:ofNil(ctx.activeWindow):map(function(win)
    ---@cast win hs.window
    local screen = desk.getScreen('active')
    local area   = desk.getReasonableSpace('active')

    win:move(area, screen, spaces.INBOUNDS.YES, spaces.RESIZE_SPEED)

    return { ok = cmd.hotkey:getLabel('full') }
  end)
  :orElse('No active window')
end

---@type ks.command.execfn
local function center(cmd, ctx)
  return Option:ofNil(ctx.activeWindow):map(function(win)
    ---@cast win hs.window
    local frame = win:centerOnScreen()
    return { ok = cmd.hotkey:getLabel('full') }
  end)
  :orElse('No active window')
end

local mod = {}

mod.module = "Resize Windows"


---@type ks.command.config<any>[]
mod.cmds = {
  {
    id     = 'window.resize.largest',
    title  = 'XLarge-sized Window',
    icon   = file_icon 'win/maximize',
    mods   = keys.preset.peace,
    key    = keys.code.M,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=100, h=100}, {w=100, h=100}, {x=0, y=0}),
  },

  {
    id     = 'window.resize.larger',
    title  = 'Large-sized Window',
    icon   = 'rectangle.expand.vertical',
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=100, h=100}, {w=80, h=100}, {x=10, y=0}),
  },

  {
    id     = 'window.resize.medium',
    title  = 'Medium-sized Window',
    icon   = 'rectangle.expand.vertical',
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createGridFn({w=100, h=100}, {w=80, h=80}, {x=10, y=10}),
  },

  {
    id     = 'window.resize.reasonable',
    title  = 'Reasonable Size',
    mods   = keys.preset.peace,
    key    = keys.code.G,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = reasonable,
  },

  {
    id     = 'window.resize.recenter',
    title  = "Re-center Window",
    mods   = keys.preset.peace,
    key    = keys.code.C,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = center,
  },

  {
    id     = 'window.resize.larger',
    title  = 'Make Larger',
    icon   = file_icon 'win/expand',
    mods   = keys.preset.peace,
    key    = keys.code.PLUS,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createScaleFn(function(pct)
      return { y = positive_log_scale(pct.h), x = positive_log_scale(pct.w) }
    end),
  },

  {
    id     = 'window.resize.smaller',
    title  = 'Make Smaller',
    icon   = file_icon 'win/shrink',
    mods   = keys.preset.peace,
    key    = keys.code.MINUS,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createScaleFn(function()
      return { x = 0.92, y = 0.92 }
    end),
  },

  {
    id     = 'window.resize.wider',
    title  = 'Make Wider',
    icon   = file_icon 'win/expand-x',
    mods   = keys.preset.lil,
    key    = keys.code.PLUS,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createScaleFn(function(pct)
      return { x = positive_log_scale(pct.w), y = 1 }
    end),
  },

  {
    id     = 'window.resize.narrower',
    title  = 'Make Narrower',
    icon   = file_icon 'win/shrink-x',
    mods   = keys.preset.lil,
    key    = keys.code.MINUS,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createScaleFn(function(pct)
      return { x = 0.92, y = 1 }
    end),
  },

  {
    id     = 'window.resize.taller',
    title  = 'Make Taller',
    icon   = file_icon 'win/expand-y',
    mods   = keys.preset.shift_ctrl,
    key    = keys.code.PLUS,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createScaleFn(function(pct)
      return { x = 1, y = positive_log_scale(pct.h) }
    end),
  },

  {
    id     = 'window.resize.shorter',
    title  = 'Make Shorter',
    icon   = file_icon 'win/shrink-y',
    mods   = keys.preset.shift_ctrl,
    key    = keys.code.MINUS,
    flags  = spaces.NO_ALERT,
    verify = spaces.HS_MANAGED_WINDOW,
    exec   = spaces.createScaleFn(function(pct)
      return { x = 1, y = 0.92 }
    end),
  },
}

return mod