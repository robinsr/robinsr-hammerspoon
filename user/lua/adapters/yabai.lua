local apps        = require 'hs.application'
local win         = require 'hs.window'
local winf        = require 'hs.window.filter'
local sysevnt     = require 'hs.caffeinate.watcher'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local desktop     = require 'user.lua.interface.desktop'
local sh          = require 'user.lua.interface.shell'
local params      = require 'user.lua.lib.params'
local proto       = require 'user.lua.lib.proto'
local strings     = require 'user.lua.lib.string'
local types       = require 'user.lua.lib.typecheck'
local logr        = require 'user.lua.util.logger'


local log = logr.new('Yabai', 'debug')


---@class Yabai: LaunchAgent
---@field syswatcher hs.caffeinate.watcher
local Yabai = {}


--
-- Yabai constructor
--
---@return Yabai
function Yabai:new()
  local this = self == Yabai and {} or self

  LaunchAgent.new(this, 'Yabai', 'com.koekeishiya.yabai')

  this.syswatcher = sysevnt.new(function(evt) this:onEnvChange(evt) end):start()
  
  return proto.setProtoOf(this, Yabai)
end

function Yabai:onEnvChange(evt)
  log.f('Yabai event callback; event: %s', tostring(evt))
  if (evt == sysevnt.screensDidUnlock) then
      
  end
end


--
-- Gets yabai rules
--
---@return Yabai.Rule[]
function Yabai:getRules()
  local rules, err = sh.runt('yabai -m rule --list')

  if types.notNil(err) then
    log.e(err)
    return {}
  end

  ---@cast rules Yabai.Rule[]
  return rules
end

function Yabai:addRule()
  error('not implemented')
end

function Yabai:removeRule()
  error('not implemented')
end

function Yabai:setConfig(propname, propval)
  sh.run('yabai -m config %s %s', propname, sh.argEsc(propval))
end

--
-- Shifts windows around on a grid
--
---@param windowId string|number Window ID, index or other window selector
---@param start { x: number, y: number } Grid coornidates to position window to (the top-left)
---@param span { x: number, y: number } number of grid units the window will span
---@param gridrows? number Optionally define number of grid rows; defaults 1
---@param gridcols? number Optionally define number of grid columns; default 3
function Yabai:shiftWindow(windowId, start, span, gridrows, gridcols)

  local window = self:getWindow(windowId)

  if window == nil then
    error('Cannot get Yabai window: ' .. tostring(windowId))
  end

  local space = self:getSpace(window.space)

  if (space.type ~= 'float') then
    self:setLayout('float', space.id)
  end

  local gridargs = { gridrows or 1, gridcols or 3, start.x, start.y, span.x, span.y }

  local cmd = strings.fmt('yabai -m window %s --grid %s', windowId, strings.join(gridargs, ':'))

  log.f('Yabai#shiftWindow: %s', cmd)

  sh.run(cmd)
end


--
-- Returns the yabai window object for a windowId
--
---@param windowId string|number
---@return Yabai.Window
function Yabai:getWindow(windowId)
  if types.isString(windowId) or types.isNum(windowId) then
    return sh.runt('yabai -m query --windows --window %s', tostring(windowId)) --[[@as Yabai.Window]]
  end

  error('Invalid window id: ' .. tostring(windowId))
end


--
-- Removes value to window.scratchpad for the given window
-- thus re-adding it to normal management by Yabai
--
---@param windowId? string
function Yabai:scratchWindow(windowId)
  local windowId = params.default(windowId, desktop.activeWindow)

  if windowId ~= nil then
    sh.run('yabai -m window %s --scratchpad %s', windowId, 'hs-scratch')
  end
end

--
-- Adds a value to window.scratchpad for the given window
-- thus removing it from normal management by Yabai
--
---@param id string
function Yabai:descratchWindow(id)
  local windowId = params.default(id, desktop.activeWindow)

  if windowId ~= nil then
    sh.run('yabai -m window %s --scratchpad', windowId)
  end
end


function Yabai:floatActiveWindow()
  local rules = sh.runt('yabai -m rule --list')

  log.inspect{ 'Yabai Rules:', rules }

  local active = hs.window.focusedWindow()

  -- if (active ~= nil) then
  --   active:title()
  -- end

  -- local app = option.ofNil(active:application())
  
  -- local title
  -- if (app:ispresent()) then
  --   title = app:get():title()
  -- end

  local title = active:title()
  local id = active:id()

  local label = strings.fmt('hsfloat-%s', title:gsub("%s", ""):lower())

  log.df('Active window: "%s" "%s" "%s";', id, title)
  log.df('Created label: "%s"', label) 
end

--
-- Returns a yabai space
--
---@param selector? Yabai.Selector.Space Yabai space selector
---@return Yabai.Space
function Yabai:getSpace(selector)
  local space = params.default(selector, 'mouse')
  return sh.runt("yabai -m query --spaces --space %s", tostring(space))
end


-- Sets the label of a Yabai space
---@param space Yabai.Selector.Space
---@param label string Label to apply to space
---@return string
function Yabai:setSpaceLabel(space, label)
  log.df("Setting label for space [%s] to [ %s ]", tostring(space), label)
  return sh.run("yabai -m space %s --label %s", tostring(space), label)
end


--
-- Returns the layout value for a specific Yabai space; Deprecated, use Yabai:getSpace(...).type
--
---@deprecated
---@return string
function Yabai:getLayout(num)
  local space = params.default(num, 'mouse')
  local layout = sh.run("yabai -m config --space %s layout", tostring(space))
  log.df("Current yabai layout: [%s]", layout)

  return layout
end


--
-- Sets the layout value for a specific Yabai space
--
---@param layout string
---@param selector? Yabai.Selector.Space
---@return string
function Yabai:setLayout(layout, selector)
  local space = params.default(selector, 'mouse')
  local layout = sh.run("yabai -m space %s --layout %s", tostring(space), layout)
  log.df("Setting layout for space [%s] to [%s]", tostring(space), layout)

  return layout
end


return proto.setProtoOf(Yabai, LaunchAgent, { locked = true })