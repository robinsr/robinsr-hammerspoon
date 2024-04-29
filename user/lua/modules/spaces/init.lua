local yabai      = require 'user.lua.adapters.yabai'
local sketchybar = require 'user.lua.adapters.sketchybar'
local desktop    = require 'user.lua.interface.desktop'
local alert      = require 'user.lua.interface.alert'
local ui         = require 'user.lua.ui'
local text       = require 'user.lua.ui.text'
local util       = require 'user.lua.util'
local M          = require 'moses'
local icons      = ui.icons

local log = util.log('mods:spaces', 'info')


local Spaces = {}

---
-- Gets text input via a HS TextInput and applies the resulting
-- name to the current space as a yabai "label"
---
function Spaces.rename()
  -- Returns the 'main' screen, i.e. the one containing the currently focused window
  local screen = desktop.get_screen("mouse"):getUUID()
  local spaces = {
    all = hs.spaces.spacesForScreen(screen),
    active = hs.spaces.activeSpaceOnScreen(screen),
  }

  -- is there a reason not to just use Yabai for this?
  local index = hs.fnutils.indexOf(spaces.all, spaces.active)
  local label = util.path(yabai:getSpace(index), 'label') or util.fmt("Space no %s", tostring(index))

  local title = "Rename Space"
  local info = "Input a name for current space"
  local clicked, input = hs.dialog.textPrompt(title, info, label, ui.btn.confirm, ui.btn.cancel)

  log.f("RenameSpace - Clicked %s; Value: %s", clicked, input)

  if (clicked == ui.btn.confirm) then
    yabai:setSpaceLabel(index, input)
    sketchybar.trigger.on_new_label(index, input)
  end
end

function Spaces.onSpaceChange(params)
  local message = "Moved space"
  local image = icons.tornado
  local alert_duration = ui.alert.ts.normal
  local screen = desktop.get_screen('active')

  local submsg = util.fmt("(%s - %s)", screen:id(), screen:name())


  if (
    type(params.to_index) == "string" and
    type(params.from_index == "string")) then
      message = util.fmt("Moved to space %s", params.to_index)

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


return Spaces