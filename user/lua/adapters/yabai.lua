local apps        = require 'hs.application'
local win         = require 'hs.window'
local winf        = require 'hs.window.filter'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local desktop     = require 'user.lua.interface.desktop'
local sh          = require 'user.lua.adapters.shell'
local system      = require 'user.lua.interface.system'
local lists       = require 'user.lua.lib.list'
local params      = require 'user.lua.lib.params'
local proto       = require 'user.lua.lib.proto'
local strings     = require 'user.lua.lib.string'
local types       = require 'user.lua.lib.typecheck'
local tables      = require 'user.lua.lib.table'
local logr        = require 'user.lua.util.logger'

local qt = sh.quote

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
  
  LaunchAgent.new(this, 'yabai', 'com.koekeishiya.yabai')

  local watcher = system.onEvent(function(evt) this:onEnvChange(evt) end)
  
  return proto.setProtoOf(this, Yabai)
end


function Yabai:start()
  return sh.result({ 'yabai', '--start-service' }).code
end

function Yabai:stop()
  return sh.result({ 'yabai', '--stop-service' }).code
end

function Yabai:restart()
  return sh.result({ 'yabai', '--restart-service' }).code
end


---@param evt HS.SystemEvent
function Yabai:onEnvChange(evt)
  -- lists(tables.vals(hs.caffeinate.watcher)):filter(types.isNum)
  -- if (evt == system.sysevents[evt]) then
  -- end
end


function Yabai:message(args, msg)
  local args = { 'yabai', '-m', table.unpack(sh.split(args)) }
  
  return function(cmd, ctx)
    local result = sh.result(args)
    log.df('Yabai cmd "%s" exited with code %q', result.command, result.status or 'none')
    return msg
  end
end


--
-- TODO - WIP
--
function Yabai:suggest()

  local screens = lists(desktop.screens())

  local has_external   = screens:any(function(screen) return screen:frame().w > 2000 end)
  local has_laptop     = screens:any(function(screen) return screen:frame().w < 2000 end)
  local borders_active = LaunchAgent.query('homebrew.mxcl.borders') ~= nil

  
  if has_external then
    return { layout = 'bsp' }
  end

end


--
-- Gets yabai rules
--
---@return Yabai.Rule[]
function Yabai:getRules()
  local rules = sh.result('yabai -m rule --list'):json()
  
  ---@cast rules Yabai.Rule[]
  return rules
end


--
-- TODO - WIP
--
function Yabai:addRule()
  error('not implemented')
  
  local rule_args = { 'yabai', '-m', 'rule', '--add', 'app="^Calculator$"', 'manage=off' }
  local rule_tmpl = 'yabai -m rule --add app="<%= app %>" manage=<%= off %>'

  local rule_tmpl_vars = {
    app = '^Calculator$',
    manage = 'off'
  }

end

function Yabai:removeRule()
  error('not implemented')
end

function Yabai:setConfig(propname, propval)
  sh.run({ 'yabai','-m','config', propname, qt(propval) })
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

  local yargs = { 'yabai', '-m', 'window', windowId, '--grid', strings.join(gridargs, ':') }

  log.f('Yabai#shiftWindow: %s', sh.join(yargs))

  sh.run(yargs)
end


--
-- Returns the yabai window object for a windowId
--
---@param windowId string|number
---@return Yabai.Window
function Yabai:getWindow(windowId)
  if types.isString(windowId) or types.isNum(windowId) then
    local result = sh.run({ 'yabai', '-m', 'query', '--windows', '--window', windowId }, sh.JSON)
    
    return result--[[@as Yabai.Window]]
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
    sh.run({ 'yabai', '-m', 'window', windowId, '--scratchpad', 'hs-scratch' })
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
    sh.run({ 'yabai', '-m', 'window', windowId, '--scratchpad' })
  end
end


function Yabai:floatActiveWindow()
  local rules = sh.runt('yabai -m rule --list')

  log.inspect{ 'Yabai Rules:', rules }

  local active = hs.window.focusedWindow()
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
  local tbl, err = sh.run({ 'yabai', '-m', 'query', '--spaces', '--space', space }, sh.JSON)

  if (tbl ~= nil) then
    return tbl --[[@as Yabai.Space]]
  end
  
  error(strings.fmt('Error getting yabai space [%s] - %s', space, err))
end


-- Sets the label of a Yabai space
---@param space Yabai.Selector.Space
---@param label string Label to apply to space
---@return string
function Yabai:setSpaceLabel(space, label)
  log.df("Setting label for space [%s] to [ %s ]", tostring(space), label)
  local out, result = sh.run({ 'yabai', '-m', 'space', space, '--label', label })

  return out --[[@as string]]
end


--
-- Returns the layout value for a specific Yabai space; Deprecated, use Yabai:getSpace(...).type
--
---@deprecated
---@return string
function Yabai:getLayout(num)
  local space = params.default(num, 'mouse')
  local layout = sh.run({ 'yabai', '-m', 'config', '--space', space, 'layout' })
  log.df("Current yabai layout: [%s]", layout)

  return layout --[[@as string]]
end


--
-- Sets the layout value for a specific Yabai space
--
---@param layout string
---@param selector? Yabai.Selector.Space
---@return string
function Yabai:setLayout(layout, selector)
  local space = params.default(selector, 'mouse')
  
  log.df("Setting layout for space [%q] to [%s]", space, layout)
  
  local layout = sh.run({ 'yabai', '-m', 'space', space, '--layout', layout })

  return layout --[[@as string]]
end


return proto.setProtoOf(Yabai, LaunchAgent, { locked = true })