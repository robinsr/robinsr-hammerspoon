local desktop    = require 'user.lua.interface.desktop'
local alert      = require 'user.lua.interface.alert'
local cmd        = require 'user.lua.model.command'
local lists      = require 'user.lua.lib.list'
local params     = require 'user.lua.lib.params'
local strings    = require 'user.lua.lib.string'
local types      = require 'user.lua.lib.typecheck'
local icons      = require 'user.lua.ui.icons'
local text       = require 'user.lua.ui.text'
local logr       = require 'user.lua.util.logger'


local log = logr.new('ModSpaces', 'debug')

---@type Yabai
local yabai      = KittySupreme.services.yabai
local sketchybar = KittySupreme.services.sketchybar


local Spaces = {}

---
-- Gets text input via a HS TextInput and applies the resulting
-- name to the current space as a yabai "label"
---
function Spaces.rename()
  local space = yabai:getSpace()
  local label = params.default(space.label, strings.fmt("Space #%d", space.index))

  local title = "Rename Space"
  local info = "Input a name for current space"
  local clicked, input = hs.dialog.textPrompt(title, info, label, "OK", "Cancel")

  log.f("RenameSpace - Clicked %s; Value: %s", clicked, input)

  if (clicked == "OK") then
    ---@cast input string
    space.label = input

    yabai:setSpaceLabel(space.index, input or '""')
    sketchybar:onSpaceEnvChange(space)
  end
end


---@class SpaceChangeParams
---@field to number
---@field from number

--
-- Handles space change events
-- Currently responds after Yabai has already changed the active space
--
---@param cmd Command
---@param ctx CommandCtx The event context
---@param params SpaceChangeParams to/from index of change
function Spaces.onSpaceChange(cmd, ctx, params)
  local disp = { 'Irratic space change...', alert.timing.NORMAL, icons.tornado }

  local screen = desktop.getScreen('active')
  local submsg = strings.fmt("(%s - %s)", screen:id(), screen:name())
  local movement = { params.from, params.to }

  if (lists(movement):every(types.isString)) then
    message = strings.fmt("Moved to space %s", movement[1])

    local from, to = tonumber(movement[1]), tonumber(movement[2])

    if (from - to > 0) then 
      disp = { 'Moved space left', alert.timing.FAST, icons.spaceLeft }
    elseif (from - to < 0) then
      disp = { 'Moved space right', alert.timing.FAST, icons.spaceRight }
    else
      disp = { 'Moved space', alert.timing.NORMAL, icons.tornado }
    end
  end

  local text, timing, icon = table.unpack(disp)

  return alert:new(text):icon(icon):show(timing)
end

function Spaces.onSpaceCreated(ctx, params)
  log.inspect("space created:", params)

  sketchybar:update()
end

function Spaces.onSpaceDestroyed(ctx, params)
  log.inspect("space destroyed:", params)

  sketchybar:update()
end


-- 
-- Cycles current space's Yabai layout from BSP to Float, to Stack and back again
--
---@return string
function Spaces.cycleLayout()
  local nextlayout
  local layouts = { "bsp", "float", "stack" }

  local space = yabai:getSpace()
  local layout = params.default(space.type, 'stack')

  for i, nl in ipairs(layouts) do
    if nl == layout then
      nextlayout = layouts[i % #layouts + 1]
    end
  end

  log.i('next yabai layout:', nextlayout)

  yabai:setLayout(nextlayout)

  print(tostring(#space.windows), hs.inspect(space))

  sketchybar:onSpaceEnvChange(space)

  return nextlayout
end


---@type CommandConfig[]
Spaces.cmds = {
  {
    id = 'spaces.space.cycle',
    title = "Space → Cycle Layout",
    icon = "tag",
    mods = "modA",
    key = "space",
    exec = function(cmd)
      local layout = Spaces.cycleLayout()
      return strings.fmt("Changed layout to %s", layout)
    end,
  },
   {
    id = 'spaces.space.rename',
    title = "Label current space",
    icon = "tag",
    mods = "bar",
    key = "L",
    exec = function(cmd, ctx)
      Spaces.rename()

      if (ctx.trigger == 'hotkey') then
        return strings.fmt('%s: %s', cmd:getHotkey().label, cmd.title)
      end
    end,
  },
  { 
    id = "spaces.space.floatActiveWindow",
    title = "Float active window",
    icon = "float",
    exec = function (cmd, ctx)
      yabai:floatActiveWindow()

      if (ctx.trigger == 'hotkey') then
        return strings.fmt('%s: %s', cmd:getHotkey().label, cmd.title)
      end
    end
  },
  {
    id = 'spaces.evt.onSpaceChange',
    exec = Spaces.onSpaceChange,
    url = "spaces.changed",
  },
  {
    id = 'spaces.evt.onSpaceCreated',
    exec = Spaces.onSpaceCreated,
    url = "spaces.created",
  },
  {
    id = 'spaces.evt.onSpaceDestroyed',
    exec = Spaces.onSpaceDestroyed,
    url = "spaces.destroyed",
  },
  {
    id = 'spaces.evt.onDisplayChange',
    exec = function() end,
    url = "display.changed",
  },
  {
    id = 'yabai.window.first3rd',
    title = "Move window: 1st ⅓",
    mods = 'modB',
    key = '1',
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindow(), { x = 0, y = 0 }, { x = 1, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'yabai.window.second3rd',
    title = "Move window: 2nd ⅓",
    mods = 'modB',
    key = '2',
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindow(), { x = 1, y = 0 }, { x = 1, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'yabai.window.third3rd',
    title = "Move window: 3rd ⅓",
    mods = 'modB',
    key = '3',
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindow(), { x = 2, y = 0 }, { x = 1, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'yabai.window.firstTwo3rds',
    title = "Move window: 1st ⅔",
    mods = 'modB',
    key = '4',
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindow(), { x = 0, y = 0 }, { x = 2, y = 1 })
      return cmd.title
    end,
  },
  {
    id = 'yabai.window.secondTwo3rds',
    title = "Move window: 2nd ⅔",
    mods = 'modB',
    key = '5',
    exec = function(cmd)
      yabai:shiftWindow(desktop.activeWindow(), { x = 1, y = 0 }, { x = 2, y = 1 })
      return cmd.title
    end,
  },
}

return Spaces