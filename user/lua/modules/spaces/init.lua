-- local yabai      = require 'user.lua.adapters.yabai'
-- local sketchybar = require 'user.lua.adapters.sketchybar'
local desktop    = require 'user.lua.interface.desktop'
local alert      = require 'user.lua.interface.alert'
local ui         = require 'user.lua.ui'
local text       = require 'user.lua.ui.text'
local U          = require 'user.lua.util'
local M          = require 'moses'
local icons      = ui.icons

local log = U.log('mods:spaces', 'info')

---@type Yabai
local yabai      = KittySupreme.services.yabai
local sketchybar = KittySupreme.services.sketchybar


local Spaces = {
  cmds = {
    
  }
}

---
-- Gets text input via a HS TextInput and applies the resulting
-- name to the current space as a yabai "label"
---
function Spaces.rename()
  local space = yabai:getSpace()
  local index = tostring(space.index)
  local label = U.default(space.label, U.fmt("Space #%s", index))

  local title = "Rename Space"
  local info = "Input a name for current space"
  local clicked, input = hs.dialog.textPrompt(title, info, label, ui.btn.confirm, ui.btn.cancel)

  log.f("RenameSpace - Clicked %s; Value: %s", clicked, input)

  if (clicked == ui.btn.confirm) then
    yabai:setSpaceLabel(index, U.default(input, index))
    sketchybar.trigger.onNewLabel(index, input)
  end
end

function Spaces.onSpaceChange(params)
  local message = "Moved space"
  local image = icons.tornado
  local alert_duration = ui.alert.ts.normal
  local screen = desktop.get_screen('active')

  local submsg = U.fmt("(%s - %s)", screen:id(), screen:name())


  if (
    type(params.to_index) == "string" and
    type(params.from_index == "string")) then
      message = U.fmt("Moved to space %s", params.to_index)

      local toInd = tonumber(params.to_index)
      local frInd = tonumber(params.from_index)

      if (frInd - toInd == 1) then
        message = "Moved space left"
        image = icons.spaceLeft
        local alert_duration = ui.alert.ts.fast
      end
      
      if (frInd - toInd == -1) then
        message = "Moved space right"
        image = icons.spaceRight
        local alert_duration = ui.alert.ts.fast
      end
  end

  local styledmessage = text.styleText(message, 24)..text.styleText("\n\n"..submsg, 12)

  return alert.imageAlert(
    styledmessage, 
    image, 
    ui.alert.window,
    screen, 
    alert_duration)
end

function Spaces.onSpaceCreated(params)
  log.d("space created:", hs.inspect(params))
end

function Spaces.onSpaceDestroyed(params)
  log.d("space destroyed:", hs.inspect(params))
end


-- 
-- Cycles current space's Yabai layout from BSP to Float, to Stack and back again
--
---@return string
function Spaces.cycleLayout()
  local nextlayout
  local layouts = { "bsp", "float", "stack" }

  local space = yabai:getSpace() --[[@as string]]

  log.i('yabai space:', hs.inspect(space))

  local layout = U.default(space.type, 'stack')

  for i, nl in ipairs(layouts) do
    if nl == layout then
      nextlayout = layouts[i % #layouts + 1]
    end
  end

  log.i('next yabai space:', nextlayout)

  yabai:setLayout(nextlayout)
  sketchybar.trigger.onLayoutChange(space.index, nextlayout)

  return nextlayout
end

return Spaces