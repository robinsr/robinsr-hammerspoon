local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local desktop     = require 'user.lua.interface.desktop'
local watch       = require 'user.lua.interface.watchable'
local sh          = require 'user.lua.adapters.shell'
local system      = require 'user.lua.interface.system'
local chan        = require 'user.lua.lib.channels'
local lists       = require 'user.lua.lib.list'
local Option      = require 'user.lua.lib.optional'
local paths       = require 'user.lua.lib.path'
local params      = require 'user.lua.lib.params'
local proto       = require 'user.lua.lib.proto'
local regex       = require 'user.lua.lib.regex'
local strings     = require 'user.lua.lib.string'
local types       = require 'user.lua.lib.typecheck'
local tables      = require 'user.lua.lib.table'
local layouts     = require 'user.lua.model.layout'
local logr        = require 'user.lua.util.logger'
local unpk        = table.unpack
local pk          = table.pack


local log = logr.new('Yabai', 'info')



local function assertWindowId(id, pos)
  if not types.either(types.isNum, types.isString)(id) then
    error(params.errs.CUSTOM:format('window ID', pos, type(id)))
  end
end


---@class Yabai: LaunchAgent
local Yabai = {}


--
-- Yabai constructor
--
---@return Yabai
function Yabai:new()
  local this = self == Yabai and {} or self

  LaunchAgent.new(this, 'yabai', 'com.koekeishiya.yabai')

  local config_path = paths.expand("~/.config/yabai/")
  local config_watcher = hs.pathwatcher.new(config_path, function() this:restart() end):start()


  chan.subscribe('ks:space:rename', function(data)
    this:setSpaceLabel(data.space, data.label)
  end)

  chan.subscribe('ks:space:layout-changed', function(data)
    this:setLayout(data.space, data.layout)
  end)

  watch.listen.onPathChange('root.screenCount', function(update)
    ---@cast update hs.watch.update<integer>
    log.f('onPathChange screenCount: %s', update.value)

    local pad, gap = '2','2'

    if update.value > 1 then
      pad, gap = '10', '12'
    
    elseif KittySupreme:getService('borders').running then
      pad, gap = '4','8'
    end

    self:setConfig({
      top_padding = pad, bottom_padding = pad, left_padding = pad, right_padding = pad, window_gap = gap,
    })
  end)


  chan.subscribe('ks:sketchybar:start', function()
    self:setConfig({ external_bar = 'all:0:40' })
  end)

  chan.subscribe('ks:sketchybar:stop', function()
    self:setConfig( { external_bar = 'all:0:0' })
  end)


  return proto.setProtoOf(this, Yabai)
end


--
--
function Yabai:start()
  local result = sh.result({ 'yabai', '--start-service' })

  if result:ok() then
    chan.publish('ks:yabai:start', {})
  end

  return result.code
end


--
--
function Yabai:stop()
  local result = sh.result({ 'yabai', '--stop-service' })

  if result:ok() then
    chan.publish('ks:yabai:stop', {})
  end

  return result.code
end


--
--
function Yabai:restart()
  return sh.result({ 'yabai', '--restart-service' }).code
end

--
--
--
---@param props { [string]: string|number }
function Yabai:setConfig(props)

  local qts = {
    number = '   ',
    string = ' ""'
  }

  local args = lists(tables.list(props)):map(function(prop)
    return sh.kv(prop[1], prop[2], qts[type(prop[2])])
  end)

  local result = sh.result({ 'yabai','-m','config', unpk(args)})

  if not result:ok() then
    error(('Failed to set config %s to value %s'):format(props, args:join(' ')))
  end
end



local action = 'action="hs -c \\"fire(\'%s\', { %s })\\" "'

---@param label string
---@param event string
---@param vars { [string]: string }
function Yabai:addSignal(label, event, vars)
  params.assert.string(label, 1)
  params.assert.string(event, 2)

  vars = vars or {}

  local string_vars = lists(tables.list(vars))
    :map(function(v)
      return ("%s = '\\$%s'"):format(v[1], v[2])
    end)
    :join(', ')

  local args = lists({
    'yabai', '-m', 'signal', '--add',
    sh.kv('event', event),
    sh.kv('label', label),
    action:format(label, string_vars)
  }):join(' ')

  log.f("add signal args: %s", args)

  sh.run(args)
end


--
-- Runs `yabai -m` with supplied args
--
---@param ... any  args to use on each invoke of fn
---@return ShellResult
function Yabai.message(...)
  return sh.result({ 'yabai', '-m', table.unpack({...}) })
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

  args:push(sh.kv('app', regex.topattern(rule.app), '""'))
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
-- Shifts windows around on a grid
--
-- `--grid <rows>:<cols>:<start-x>:<start-y>:<width>:<height>`
--
---@param windowId string|number   Window ID, index or other window selector
---@param grid     Dimensions      Dimensions defining the grid's columns (w) and rows (h)
---@param span     Dimensions      Dimensions defining the number of grid units the window will span
---@param start    Coord           Coordinates within the grid that define the window's top-left start position
function Yabai.setGrid(windowId, grid, span, start)
  assertWindowId(windowId, 1)

  local getWindow = sh.result({ 'yabai', '-m', 'query', '--windows', '--window', windowId })

  if getWindow:ok() then
    local window = getWindow:json() --[[@as Yabai.Window]]

    if not window['is-floating'] then
      -- return 'Cannot reposition non-floating windows'
    end

    local space = Yabai:getSpace(window.space)

    local gridargs = { grid.h, grid.w, start.x, start.y, span.w, span.h }

    local yargs = { 'yabai', '-m', 'window', window.id, '--grid', strings.join(gridargs, ':') }

    log.f('Yabai#setGrid: %s', sh.join(yargs))

    sh.result(yargs)
  else
    return 'Cannot reposition unmanaged windows'
  end
end


--
-- Returns the yabai window object for a windowId
--
---@param selector? Yabai.Selector.Window
---@return Yabai.Window
function Yabai.getWindow(selector)
  selector = selector or ''

  local result = sh.result({ 'yabai', '-m', 'query', '--windows', '--window', selector })

  if result:ok() then
    return result:json()--[[@as Yabai.Window]]
  else
    error(result:error_msg())
  end
end


--
-- Returns the yabai window object for a windowId
--
---@param selector? Yabai.Selector.Window
---@return boolean
function Yabai.isManaged(selector)
  if selector == nil then
    return false
  end

  return sh.result({ 'yabai', '-m', 'query', '--windows', '--window', selector }):ok()
end


--
-- Returns the yabai window object for a windowId
--
---@param space? integer
---@return Yabai.Window|nil
function Yabai.getActiveWindow(space)
  local result = sh.result({ 'yabai', '-m', 'query', '--windows' })

  if result:ok() then
    local windows = result:json()--[[@as Yabai.Window[] ]]

    return lists(windows)
      :filter(function(win)
        return space == nil or win.space == space
      end)
      :first(function(win)
        return win['has-focus']
      end)
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
  selector = selector or desktop.activeWindow():id()

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
  selector = selector or desktop.activeWindow():id()

  if selector ~= nil then
    sh.result({ 'yabai', '-m', 'window', selector, '--scratchpad' })
  end
end


--
--
--
---@param windowId string
function Yabai:floatActiveWindow(windowId)
  local rules = self:getRules()

  log.inspect{ 'Yabai Rules:', rules }

  Option:ofNil(windowId)
    :map(Yabai.getWindow)
    :ifPresent(function(win)
      ---@cast win Yabai.Window
      local title = win.title
      local id = win.id

      local label = strings.fmt('hsfloat-%s', title:gsub("%s", ""):lower())

      log.f('Active window: "%s" "%s" "%s";', id, title)
      log.f('Created label: "%s"', label)
  end)
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
---@param layout    ks.layout.type
function Yabai:setLayout(selector, layout)
  selector = selector or 'mouse'

  log.f("Setting layout for space [%q] to [%s]", selector, layout)

  local result = sh.result({ 'yabai', '-m', 'space', selector, '--layout', layout })

  if not result:ok() then
    error(result:error_msg())
  end

  -- if layout=="float", set sub-layer="normal" for windows in the space
  local windows = self:getSpace(selector).windows
  local win_layer = layout == 'float' and 'normal' or 'auto'

  log.critical('Windows to set to normal: %s', hs.inspect(windows))

  lists(windows)
    :map(function(id)
      log.f("Setting 'sub-layer' to '%s' for window [%q]", win_layer, id)

      return sh.result({ 'yabai', '-m', 'window', id, '--sub-layer', win_layer })
    end)
    :filter(function(r) return not r:ok() end)
    :forEach(function(r)
      ---@cast r ShellResult
      log.e(r:error_msg())
    end)
end


return proto.setProtoOf(Yabai, LaunchAgent, { locked = true })