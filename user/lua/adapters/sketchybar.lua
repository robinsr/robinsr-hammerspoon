local shell       = require 'user.lua.adapters.shell'
local BrewService = require 'user.lua.adapters.base.brew-service'
local params      = require 'user.lua.lib.params'
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
  params.assert.string(event)
  
  if SketchyBar.events:has(event) then
    return shell.result({ 'sketchybar', '--trigger', SketchyBar.events[event] }).code
  else
    log.ef("Event not found: %s", event)
  end
end


function SketchyBar:setFrontApp(app)
  params.assert.string(app)
  shell.result({ 'sketchybar', '--set', 'front_app', shell.kv('label', app) })
end

--
-- Applys a new label value to a sketchybar space component
--
---@param space number space's index
---@param label? string label's value (defaults to index value)
---@return string
function SketchyBar:setSpaceLabel(space, label)
  params.assert.number(space, 1)
  params.assert.string(label, 2)

  local space_arg = ('space.%d'):format(space)
  local icon_arg = shell.kv('icon', strings.ifEmpty(label, tostring(space)))

  return shell.result({ 'sketchybar', '--set', space_arg, icon_arg }).output
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
  params.assert.tabl(space)

  local count, sym, label, icon

  count = #space.windows or 0

  if (layout_icons:has(space.type)) then
    sym = symbols.toText(layout_icons:get(space.type))
  else
    sym = symbols.toText(layout_icons:get('cols'))
  end

  local space_arg = ('space.%d'):format(space.index)
  local icon_arg  = shell.kv('icon', strings.ifEmpty(space.label, tostring(space.index)))
  local label_arg = shell.kv('label', ('%s %d').format(sym, count))

  return shell.result({ 'sketchybar', '--set', space_arg, label_arg, icon_arg })
end



SketchyBar.cmds = {
  {
    id = 'sketch.service.restart',
    title = 'Restart SketchyBar',
    icon = 'info',
    exec = function()
      if KittySupreme.services.sketchybar ~= nil then
        KittySupreme.services.sketchybar:restart()
      end
    end,
  },
  {
    id = 'sketch.service.refresh',
    title = 'Refresh SketchyBar (force update)',
    icon = 'info',
    exec = function()
      if KittySupreme.services.sketchybar ~= nil then
        KittySupreme.services.sketchybar:update()
      end
    end,
  },
}


return proto.setProtoOf(SketchyBar, BrewService, { locked = true })