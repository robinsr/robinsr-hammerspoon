local shell       = require 'user.lua.adapters.shell'
-- local shell       = require 'shell-games'
local BrewService = require 'user.lua.adapters.base.brew-service'
local proto       = require 'user.lua.lib.proto'
local strings     = require 'user.lua.lib.string'
local tables      = require 'user.lua.lib.table'
local types       = require 'user.lua.lib.typecheck'
local symbols     = require 'user.lua.ui.symbols'
local logr        = require 'user.lua.util.logger'

local log = logr.new('SketchyBar', 'debug')


---@class SketchyBar: BrewService
local SketchyBar = {}


SketchyBar.events = tables{
  -- onNewLabel = "new-label space=%d value='%s'",
  -- onLayoutChange = "layout-change space=%d value=%s",
}


---@return SketchyBar
function SketchyBar:new()
  local this = self == SketchyBar and {} or self
  
  BrewService.new(this, 'sketchybar')

  return proto.setProtoOf(this, SketchyBar, { locked = true })
end


function SketchyBar:update()
  return shell.result({ 'sketchybar', '--update' }).code
end


function SketchyBar:restart()
  return shell.result({ 'sketchybar', '--reload' }).code
end


function SketchyBar:reload()
  return shell.result({ 'sketchybar', '--reload' }).code
end

---@param event string The event name
---@param ... (string|number|nil) Command parameter variables
function SketchyBar:trigger(event, ...)
  if (types.isNil(event)) then
    error('Missing parameter #1 (event name)')
  end
  
  if SketchyBar.events:has(event) then
    return shell.result({ 'sketchybar', '--trigger', SketchyBar.events[event] }).code
  else
    log.ef("Event not found: %s", event)
  end
end


function SketchyBar:setFrontApp(app)
  if (not types.isString(app)) then
    error('Invalid app name: ' .. tostring(app))
  end

  local setresult = shell.result({ 'sketchybar', '--set', 'front_app', 'label='..app })

  log.d(hs.inspect(setresult))
end

--
-- Applys a new label value to a sketchybar space component
--
---@param space number space's index
---@param label? string label's value (defaults to index value)
---@return string
function SketchyBar:setSpaceLabel(space, label)
  if (not types.isNum(space)) then
    error('Missing parameter #1 (space index)')
  end

  local space_str = tostring(space)

  local space_arg = shell.fmt('space.%d', { space })
  local icon_arg = shell.kv('icon', strings.ifEmpty(label, space_str))

  local result = shell.run({ 'sketchybar', '--set', space_arg, icon_arg }) --[[@as string]]

  return result
end


function SketchyBar:setSpaceIcon(space, text)
end


local layout_icons = tables{
  float = "macwindow.on.rectangle",
  stack = "rectangle.stack",
  bsp   = "rectangle.split.2x2.fill",
  cols  = "rectangle.split.3x1.fill",
}


---@param space Yabai.Space
function SketchyBar:onSpaceEnvChange(space)
  local count, sym, label, icon

  if (types.isNil(space)) then
    error('Missing parameter #1 (Yabai space table)')
  end

  count = #space.windows or 0

  if (layout_icons:has(space.type)) then
    sym = symbols.toText(layout_icons:get(space.type))
  else
    sym = symbols.toText(layout_icons:get('cols'))
  end

  local space_str = tostring(space.index)

  local space_arg = shell.fmt('space.%d', { space.index })
  local icon_arg  = shell.kv('icon', strings.ifEmpty(space.label, space.index))
  local label_arg = shell.fmt('%s %d', { sym, count })

  local args = { 'sketchybar', '--set', space_arg, 'label='..label_arg, icon_arg }

  print(shell.join(args))

  shell.run(args)
end



return proto.setProtoOf(SketchyBar, BrewService, { locked = true })