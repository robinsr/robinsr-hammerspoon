local inspect = require 'inspect'
local shell       = require 'user.lua.adapters.shell'
local BrewService = require 'user.lua.adapters.base.brew-service'
local channels    = require 'user.lua.lib.channels'
local lists       = require 'user.lua.lib.list' 
local params      = require 'user.lua.lib.params'
local proto       = require 'user.lua.lib.proto'
local strings     = require 'user.lua.lib.string'
local tables      = require 'user.lua.lib.table'
local types       = require 'user.lua.lib.typecheck'
local icons       = require 'user.lua.ui.icons'
local symbols     = require 'user.lua.ui.symbols'
local logr        = require 'user.lua.util.logger'
local unpk        = table.unpack
local pk          = table.pack

local log = logr.new('SketchyBar', 'info')


local LAYOUT_ICONS = tables(icons.layout)

local SH_QUOTE = '""'

local function getLayoutIcon(layout)
  if (LAYOUT_ICONS:has(layout)) then
    return symbols.toText(LAYOUT_ICONS:get(layout))
  else
    return symbols.toText(LAYOUT_ICONS:get('cols'))
  end
end

local function getSpaceId(index)
  return strings('space.%s'):fmt(tostring(index))
end

local function getSpaceIcon(layoutType, windowCount)
  return strings('%s %d'):fmt(getLayoutIcon(layoutType), windowCount or 0)
end

local function getSpaceLabel(label, index)
  return strings.new(label, index)
end



---@class SketchyBar : ks.brewservice
local SketchyBar = {}


SketchyBar.events = tables{
  -- onNewLabel = "new-label space=%d value='%s'",
  -- onLayoutChange = "layout-change space=%d value=%s",
}


---@return SketchyBar
function SketchyBar:new()
  local this = self == SketchyBar and {} or self
  
  BrewService.new(this, 'sketchybar')

  channels.subscribe('ext:click:sketchybar', function(data)
    log.df("'ext:click:sketchybar' triggered! %s", inspect(data))
  end)

  channels.subscribe('ks:space:rename', function(data)
    log.df("'ks.spaces.renamed' triggered! %s", inspect(data))
    self:setSpaceLabel(data.space, data.label)
  end)

  return proto.setProtoOf(this, SketchyBar)
end


function SketchyBar:update()
  return shell.result({ 'sketchybar', '--update' }).code
end


function SketchyBar:restart()
  return shell.result({ 'sketchybar', '--restart' }).code
end


function SketchyBar:reload()
  return shell.result({ 'sketchybar', '--reload' }).code
end


--
-- Updates a sketchybar component by calling 'sketchtbar --set <args>'
--
---@param ... (string|string[])
---@return ShellResult
function SketchyBar.set(...)
  local args = lists({...})
    :map(function(arg)
      if types.isTable(arg) then
        return shell.kv(arg[1], arg[2], SH_QUOTE)
      end
      
      return arg
    end)
    :values()

    log.df("SketchyBar Set: %s", hs.inspect({ 'sketchybar', '--set', unpk(args) }))

  return shell.result({ 'sketchybar', '--set', unpk(args) })
end


--
-- Triggers some event in sketchybar by calling 'sketchtbar --trigger <args>'
--
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

  return self.set('front_app', { 'label', app })
end

--
-- Applys a new label value to a sketchybar space component
--
---@param space number space's index
---@param label? string label's value (defaults to index value)
---@return string
function SketchyBar:setSpaceLabel(space, label)
  log.f("Setting label for space [%s] to [ %s ]", tostring(space), label)
  
  -- params.assert.number(space, 1)
  -- params.assert.string(label, 2)

  local bar_params = {
    { 'label', getSpaceLabel(label, space) }
  }

  return self.set(getSpaceId(space), unpk(bar_params)).output
end


--
-- Creates and applies a new icon to a sketchybar space component
--
---@param space number space's index
---@param layout string
---@param windows integer
---@return string
function SketchyBar:setSpaceIcon(space, layout, windows)
  params.assert.number(space, 1)
  params.assert.string(layout, 2)
  params.assert.number(windows, 3)

  local bar_params = {
    { 'icon', getSpaceIcon(layout, windows) },
  }

  return self.set(getSpaceId(space), unpk(bar_params)).output
end



SketchyBar.cmds = {
  {
    id = 'sketch.service.stop',
    title = 'Stop SketchyBar',
    icon = 'info',
    exec = function()
      if KittySupreme.services.sketchybar ~= nil then
        KittySupreme.services.sketchybar:stop()
      end
    end,
  },
  {
    id = 'sketch.service.start',
    title = 'Start SketchyBar',
    icon = 'info',
    exec = function()
      if KittySupreme.services.sketchybar ~= nil then
        KittySupreme.services.sketchybar:start()
      end
    end,
  },
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