local desktop    = require 'user.lua.interface.desktop'
local strings    = require 'user.lua.lib.string'

---@type Yabai
local yabai      = KittySupreme.services.yabai


local cols = {}

cols.cmds = {
  {
    id = 'spaces.layout.col_first3rd',
    title = "Move window: 1st ⅓",
    icon = '@/resources/images/left-column.ios17outlined.template.png',
    mods = 'peace',
    key = '1',
    flags = { 'no-alert' },
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindowId(), { x = 0, y = 0 }, { x = 1, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'spaces.layout.col_second3rd',
    title = "Move window: 2nd ⅓",
    icon = '@/resources/images/middle-column.ios17outlined.template.png',
    mods = 'peace',
    key = '2',
    flags = { 'no-alert' },
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindowId(), { x = 1, y = 0 }, { x = 1, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'spaces.layout.col_third3rd',
    title = "Move window: 3rd ⅓",
    icon = '@/resources/images/right-column.ios17outlined.template.png',
    mods = 'peace',
    key = '3',
    flags = { 'no-alert' },
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindowId(), { x = 2, y = 0 }, { x = 1, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'spaces.layout.col_firstTwo3rds',
    title = "Move window: 1st ⅔",
    mods = 'peace',
    key = '4',
    flags = { 'no-alert' },
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindowId(), { x = 0, y = 0 }, { x = 2, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'spaces.layout.col_secondTwo3rds',
    title = "Move window: 2nd ⅔",
    mods = 'peace',
    key = '5',
    flags = { 'no-alert' },
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindowId(), { x = 1, y = 0 }, { x = 2, y = 1 })
      return cmd.title
    end,
  },
}


return cols