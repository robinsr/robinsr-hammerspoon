local apps        = require 'hs.application'
local win         = require 'hs.window'
local winf        = require 'hs.window.filter'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local desktop     = require 'user.lua.interface.desktop'
local sh          = require 'user.lua.adapters.shell'
local system      = require 'user.lua.interface.system'
local lists       = require 'user.lua.lib.list'
local paths       = require 'user.lua.lib.path'
local params      = require 'user.lua.lib.params'
local proto       = require 'user.lua.lib.proto'
local strings     = require 'user.lua.lib.string'
local types       = require 'user.lua.lib.typecheck'
local tables      = require 'user.lua.lib.table'
local logr        = require 'user.lua.util.logger'
local stringio = require('pl.stringio')


local qt = sh.quote

local log = logr.new('Yabai', 'debug')



--- TODO - where should custom yabai config live?

---@alias YabaiRulePartial {} | Yabai.Rule 

---@type YabaiRulePartial[]
local my_yabai_rules = {
  { app = 'Glance', manage = 'off' }
}


---@class Yabai.Config.Writer
---@field asCliArgs string[]
---@field asConfig type














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

  local config_path = paths.expand("~/.config/yabai/")
  local config_watcher = hs.pathwatcher.new(config_path, function() this:restart() end):start()

  system.registerGlobal('yabaiconfig', function(args)
    return 'yabai -m config focus_follows_mouse autoraise'
  end)

  
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
  local result = sh.result('yabai -m rule --list')
  
  if not result:ok() then
    error(result:error_msg())
  end

  return result:json() --[[@as Yabai.Rule[] ]]
end


--
-- TODO - WIP
--
---@param rule Yabai.Rule
function Yabai:addRule(rule)
  local args = lists({ 'yabai', '-m', 'rule', '--add' })

  args:push(sh.kv('app', strings.topattern(rule.app), '""'))
  args:push(sh.kv('manage', rule.manage))
  
  local add_reuslt = sh.result(args:values())

  log.f('yabai add rule: [%s]', args:join(' '))

  if not add_reuslt:ok() then
    error(('failed to add rule %s\n%s'):format(hs.inspect(rule), add_reuslt:error_msg()))
  end
end


--
--
--
function Yabai:removeRule()
  error('not implemented')
end


--
---@param propname string
---@param propval string
function Yabai:setConfig(propname, propval)
  local result = sh.result({ 'yabai','-m','config', propname, qt(propval) })

  if not result:ok() then
    error(('Failed to set config %s to value %s'):format(propname, propval))
  end
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
    self:setLayout(space.id, 'float')
  end

  local gridargs = { gridrows or 1, gridcols or 3, start.x, start.y, span.x, span.y }

  local yargs = { 'yabai', '-m', 'window', windowId, '--grid', strings.join(gridargs, ':') }

  log.f('Yabai#shiftWindow: %s', sh.join(yargs))

  sh.result(yargs)
end


--
-- Returns the yabai window object for a windowId
--
---@param selector Yabai.Selector.Window
---@return Yabai.Window
function Yabai:getWindow(selector)
  selector = selector or ''

  local result = sh.result({ 'yabai', '-m', 'query', '--windows', '--window', selector })

  if result:ok() then
    return result:json()--[[@as Yabai.Window]]
  else
    error(result:error_msg())
  end
end


--
-- Removes value to window.scratchpad for the given window
-- thus re-adding it to normal management by Yabai
--
---@param selector? Yabai.Selector.Window
function Yabai:scratchWindow(selector)
  selector = selector or desktop.activeWindowId()

  if selector ~= nil then
    sh.result({ 'yabai', '-m', 'window', selector, '--scratchpad', 'hs-scratch' })
  end
end

--
-- Adds a value to window.scratchpad for the given window
-- thus removing it from normal management by Yabai
--
---@param selector? Yabai.Selector.Window
function Yabai:descratchWindow(selector)
  selector = selector or desktop.activeWindowId()

  if selector ~= nil then
    sh.result({ 'yabai', '-m', 'window', selector, '--scratchpad' })
  end
end


function Yabai:floatActiveWindow()
  local rules = self:getRules()

  log.inspect{ 'Yabai Rules:', rules }

  local active = desktop:activeWindow()
  local title = active:title()
  local id = active:id()

  local label = strings.fmt('hsfloat-%s', title:gsub("%s", ""):lower())

  log.f('Active window: "%s" "%s" "%s";', id, title)
  log.f('Created label: "%s"', label) 
end

--
-- Returns a yabai space
--
---@param selector? Yabai.Selector.Space
---@return Yabai.Space
function Yabai:getSpace(selector)
  selector = selector or 'mouse'

  local space = sh.result({ 'yabai', '-m', 'query', '--spaces', '--space', selector })

  if (space ~= nil and space.code == 0) then
    return space:json() --[[@as Yabai.Space]]
  end
  
  error(strings.fmt('Error getting yabai space [%s] - %s', selector, hs.inspect(space)))
end


-- Sets the label of a Yabai space
---@param space Yabai.Selector.Space
---@param label string Label to apply to space
function Yabai:setSpaceLabel(space, label)
  log.f("Setting label for space [%s] to [ %s ]", tostring(space), label)

  if types.notNil(space) then
    local result = sh.result({ 'yabai', '-m', 'space', space, '--label', label })

    if not result:ok() then
      error(result:error_msg())
    end
  end
end


--
-- Returns the layout value for a specific Yabai space; Deprecated, use Yabai:getSpace(...).type
--
---@param selector? Yabai.Selector.Space
---@return string
function Yabai:getLayout(selector)
  selector = selector or 'mouse'
  
  local result = sh.result({ 'yabai', '-m', 'config', '--space', selector, 'layout' })
  
  if (result:ok()) then
    log.f("Current yabai layout: [%s]", result.output)
    return result.output
  else
    error(result:error_msg())
  end
end


--
-- Sets the layout value for a specific Yabai space
--
---@param selector? Yabai.Selector.Space
---@param layout string
function Yabai:setLayout(selector, layout)
  selector = selector or 'mouse'
  
  log.f("Setting layout for space [%q] to [%s]", selector, layout)
  
  local result = sh.result({ 'yabai', '-m', 'space', selector, '--layout', layout })

  if not result:ok() then
    error(result:error_msg())
  end
end


return proto.setProtoOf(Yabai, LaunchAgent, { locked = true })