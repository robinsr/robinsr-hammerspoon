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
  return shell.run({ 'sketchybar', '--update' })
end


function SketchyBar:restart()
  return shell.run({ 'sketchybar', '--reload' })
end


function SketchyBar:reload()
  return shell.run({ 'sketchybar', '--reload' })
end

---@param event string The event name
---@param ... (string|number|nil) Command parameter variables
function SketchyBar:trigger(event, ...)
  if (types.isNil(event)) then
    error('Missing parameter #1 (event name)')
  end
  
  if SketchyBar.events:has(event) then
    return shell.run({ 'sketchybar', '--trigger', SketchyBar.events[event] })
  else
    log.ef("Event not found: %s", event)
  end
end


function SketchyBar:setFrontApp(app)
  if (not types.isString(app)) then
    error('Invalid app name: ' .. tostring(app))
  end

  shell.run({ 'sketchybar', '--set', 'front_app', 'label='..app })
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

  local space_arg = shell.fmt('space.%d', space)
  local icon_arg = shell.kv('icon', strings.ifEmpty(label, space_str))

  return shell.run({ 'sketchybar', '--set', space_arg, icon_arg }) --[[@as string]]
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
    sym = symbols.toText(layout_icons[space.type])
  else
    sym = symbols.toText(layout_icons.cols)
  end

  local space_str = tostring(space)

  local space_arg = shell.fmt('space.%d', space)
  local icon_arg  = shell.kv('icon', strings.ifEmpty(label, space_str))
  local label_arg = shell.kv('label', shell.fmt('"%s %d"', { sym, count }))

  shell.run({ 'sketchybar', '--set', space_arg, label_arg, icon_arg })
end



return proto.setProtoOf(SketchyBar, BrewService, { locked = true })