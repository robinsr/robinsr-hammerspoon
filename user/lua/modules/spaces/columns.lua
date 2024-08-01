local keys    = require 'user.lua.model.keys'
local spaces  = require 'user.lua.modules.spaces'

local mod = {}

mod.module = "Column Layout"

---@type ks.command.config[]
mod.cmds = {
  {
    id     = 'spaces.layout.col_first3rd',
    title  = "Move window: 1st ⅓",
    icon   = '@/resources/images/left-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.BANG,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = spaces.createGridFn({ x = 0, y = 0 }, { x = 1, y = 1 })
  },
  {
    id     = 'spaces.layout.col_second3rd',
    title  = "Move window: 2nd ⅓",
    icon   = '@/resources/images/middle-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.AT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = spaces.createGridFn({ x = 1, y = 0 }, { x = 1, y = 1 })
  },
  {
    id     = 'spaces.layout.col_third3rd',
    title  = "Move window: 3rd ⅓",
    icon   = '@/resources/images/right-column.ios17outlined.template.png',
    mods   = keys.preset.peace,
    key    = keys.code.HASH,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = spaces.createGridFn({ x = 2, y = 0 }, { x = 1, y = 1 })
  },
  {
    id      = 'spaces.layout.col_firstTwo3rds',
    title   = "Move window: 1st ⅔",
    mods    = keys.preset.peace,
    key     = keys.code.DOLLAR,
    flags   = spaces.NO_ALERT,
    verify  = spaces.HAS_ACTIVE,
    exec    = spaces.createGridFn({ x = 0, y = 0 }, { x = 2, y = 1 })
  },
  {
    id     = 'spaces.layout.col_secondTwo3rds',
    title  = "Move window: 2nd ⅔",
    mods   = keys.preset.peace,
    key    = keys.code.PERCENT,
    flags  = spaces.NO_ALERT,
    verify = spaces.HAS_ACTIVE,
    exec   = spaces.createGridFn({ x = 1, y = 0 }, { x = 2, y = 1 })
  },
}

return mod