local desktop    = require 'user.lua.interface.desktop'
local alert      = require 'user.lua.interface.alert'
local cmd        = require 'user.lua.model.command'
local list       = require 'user.lua.lib.list'
local params     = require 'user.lua.lib.params'
local strings    = require 'user.lua.lib.string'
local types      = require 'user.lua.lib.typecheck'
local ui         = require 'user.lua.ui'
local text       = require 'user.lua.ui.text'
local logr       = require 'user.lua.util.logger'


local icons = ui.icons
local tNorm, tFast = table.unpack{ ui.alert.ts.normal, ui.alert.ts.fast }

local log = logr.new('ModSpaces', 'debug')

local yabai      = KittySupreme.services.yabai
local sketchybar = KittySupreme.services.sketchybar


local Spaces = {}

---
-- Gets text input via a HS TextInput and applies the resulting
-- name to the current space as a yabai "label"
---
function Spaces.rename()
  local space = yabai:getSpace()
  local index = tostring(space.index)
  local label = params.default(space.label, strings.fmt("Space #%s", index))

  local title = "Rename Space"
  local info = "Input a name for current space"
  local clicked, input = hs.dialog.textPrompt(title, info, label, ui.btn.confirm, ui.btn.cancel)

  log.f("RenameSpace - Clicked %s; Value: %s", clicked, input)

  if (clicked == ui.btn.confirm) then
    yabai:setSpaceLabel(index, params.default(input, index))
    sketchybar.trigger.onNewLabel(index, input)
  end
end


---@class SpaceChangeParams
---@field to number
---@field from number

--
-- Handles space change events
-- Currently responds after Yabai has already changed the active space
--
---@param ctx CommandCtx The event context
---@param params SpaceChangeParams to/from index of change
function Spaces.onSpaceChange(ctx, params)
  local disp = { 'Irratic space change...', tNorm, icons.tornado }

  local screen = desktop.getScreen('active')
  local submsg = strings.fmt("(%s - %s)", screen:id(), screen:name())
  local movement = { params.from, params.to }

  if (list.every(movement, types.isString)) then
    message = strings.fmt("Moved to space %s", movement[1])

    local from, to = tonumber(movement[1]), tonumber(movement[2])

    if (from - to > 0) then 
      disp = { 'Moved space left', tFast, icons.spaceLeft }
    elseif (from - to < 0) then
      disp = { 'Moved space right', tFast, icons.spaceRight }
    else
      disp = { 'Moved space', tNorm, icons.tornado }
    end
  end

  local text, timing, icon = table.unpack(disp)

  return alert.imageAlert(text, icon, nil, screen, timing)
end

function Spaces.onSpaceCreated(ctx, params)
  log.d("space created:", hs.inspect(params))
end

function Spaces.onSpaceDestroyed(ctx, params)
  log.d("space destroyed:", hs.inspect(params))
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
  sketchybar.trigger.onLayoutChange(space.index, nextlayout)

  return nextlayout
end


Spaces.cmds = {
  {
    id = 'Spaces.CycleLayout',
    title = "Space → Cycle Layout",
    hotkey = cmd.hotkey("modA", "space"),
    menubar = cmd.menubar{ "desktop", "y", ui.icons.code },
    fn = function(ctx)
      local layout = Spaces.cycleLayout()
      return strings.fmt("Changed layout to %s", layout)
    end,
  },
   {
    id = 'Spaces.RenameSpace',
    title = "Label current space",
    menubar = cmd.menubar{ "desktop", "L", ui.icons.tag },
    hotkey = cmd.hotkey("bar", "L"),
    fn = function(ctx)
      Spaces.rename()

      if (ctx.trigger == 'hotkey') then
        return strings.fmt('%s: %s', ctx.hotkey, ctx.title)
      end
    end,
  },
  { 
    id = "Spaces.floatActiveWindow",
    title = "Float active window",
    menubar = cmd.menubar{ "desktop", nil, ui.icons.float },
    fn = function (ctx)
      yabai:floatActiveWindow()

      if ctx.hotkey then return ctx.title end
    end
  },
  {
    id = 'Spaces.OnSpaceChange',
    fn = Spaces.onSpaceChange,
    url = "spaces.changed",
  },
  {
    id = 'Spaces.OnSpaceCreated',
    fn = Spaces.onSpaceCreated,
    url = "spaces.created",
  },
  {
    id = 'Spaces.OnSpaceDestroyed',
    fn = Spaces.onSpaceDestroyed,
    url = "spaces.destroyed",
  },
  {
    id = 'Spaces.OnDisplayChange',
    fn = function() end,
    url = "display.changed",
  },
}

return Spaces