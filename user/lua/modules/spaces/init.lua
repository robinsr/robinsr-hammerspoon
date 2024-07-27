local desktop    = require 'user.lua.interface.desktop'
local alert      = require 'user.lua.interface.alert'
local lists      = require 'user.lua.lib.list'
local params     = require 'user.lua.lib.params'
local strings    = require 'user.lua.lib.string'
local types      = require 'user.lua.lib.typecheck'
local icons      = require 'user.lua.ui.icons'
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
---@param ctx ks.command.context The event context
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


--
--
--
function Spaces.onSpaceCreated(ctx, params)
  log.inspect("space created:", params)

  sketchybar:update()
end


--
--
--
function Spaces.onSpaceDestroyed(ctx, params)
  log.inspect("space destroyed:", params)

  sketchybar:update()
end


-- 
-- Cycles current space's Yabai layout from BSP to Float, to Stack and back again
--
---@return string
function Spaces.cycleLayout()
  local layouts = { "bsp", "float", "stack" }

  local space = yabai:getSpace()
  local layout = space.type or 'stack'

  local nextlayout
  for i, nl in ipairs(layouts) do
    if nl == layout then
      nextlayout = layouts[i % #layouts + 1]
    end
  end

  yabai:setLayout(space.index, nextlayout)
  sketchybar:onSpaceEnvChange(space)

  return nextlayout
end


---@type ks.command.config[]
Spaces.cmds = {
  -- {
  --   id = 'spaces.evt.onSpaceChange',
  --   exec = Spaces.onSpaceChange,
  --   url = "spaces.changed",
  -- },
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
}

return Spaces