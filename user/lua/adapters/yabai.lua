local class       = require 'middleclass'
local apps        = require 'hs.application'
local win         = require 'hs.window'
local winf        = require 'hs.window.filter'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local isCli       = require 'user.lua.adapters.base.cli-utility'
local desktop     = require 'user.lua.interface.desktop'
local sh          = require 'user.lua.interface.shell'
local option      = require 'user.lua.lib.optional'
local params      = require 'user.lua.lib.params'
local strings     = require 'user.lua.lib.string'
local types       = require 'user.lua.lib.typecheck'
local cmd         = require 'user.lua.model.command'
local logr        = require 'user.lua.util.logger'


local log = logr.new('Yabai', 'debug')

-- Format for grid command:  `<rows>:<cols>:<start-x>:<start-y>:<width>:<height>`
local GRID_PATTERN = strings.tmpl('{{grid.rows}}:{{grid.cols}}:{{start.x}}:{{start.y}}:{{span.x}}:{{span.y}}')


---@class Yabai : LaunchAgent
---@field new fun(): Yabai
local Yabai = class('Yabai', LaunchAgent)


function Yabai:initialize()
  LaunchAgent.initialize(self, 'yabai', 'com.koekeishiya.yabai')
end

function Yabai:getRules()

end

--
-- Shifts windows around on a grid
--
function Yabai:shiftWindow(windowId, start, span, gridrows, gridcols)

  local window = self:getWindow(windowId)

  if window == nil then
    error('Cannot get Yabai window: ' .. tostring(windowId))
  end

  local space = self:getSpace(window.space)

  if (space.type ~= 'float') then
    self:setLayout('float', space.id)
  end

  local gridargs = {
    grid = {
      rows = gridrows or 1,
      cols = gridcols or 3,
    },
    start = {
      x = start.x or 0,
      y = start.y or 0,
    },
    span = {
      x = span.x or 2,
      y = span.y or 1,
    }
  }

  local cmd = strings.fmt('yabai -m window %s --grid %s', windowId, GRID_PATTERN(gridargs))

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
  log.df("Setting label for space [%s] to [%s]", tostring(space), label)
  return sh.run("yabai -m space %s --label %q", tostring(space), label)
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


local yabai = Yabai:new()


Yabai.cmds = {
  {
    id = 'Yabai.RestartYabai',
    title = "Restart Yabai",
    menubar = nil,
    hotkey = cmd.hotkey("bar", "Y"),
    fn = function (ctx)
      Yabai:restart()
      
      if (ctx.trigger == 'hotkey') then
        return strings.fmt('%s: %s', ctx.hotkey, ctx.title)
      end
    end,
  },
  {
    id = 'Yabai.ManagedApps.Add',
    title = "Manage app's windows",
    menubar = cmd.menubar{ "yabai" },
    fn = function()
      local active = hs.window.focusedWindow()
      local app = option.ofNil(active:application()):orElse({ title = function() return 'idk' end })

      local appName = app:title()

      return strings.fmt('Managing windows for app %s with yabai...', appName)
    end,
  },
  {
    id = 'Yabai.ManagedApps.Remove',
    title = "Ignore app's windows",
    menubar = cmd.menubar{ "yabai" },
    fn = function() end,
  },
  {
    id = 'Yabai.ManagedApps.List',
    title = "Show ignore list",
    menubar = cmd.menubar{ "yabai" },
    fn = function() end,
  },
  {
    id = 'Yabai.Info.Window',
    title = "Show info for active app",
    menubar = cmd.menubar{ "yabai" },
    fn = function() end,
  },
  {
    id = 'Yabai.Info.Space',
    title = "Show info current space",
    menubar = cmd.menubar{ "yabai" },
    fn = function() end,
  },
  {
    id = 'Yabai.Window.First3rd',
    title = "Move window: 1st ⅓",
    menubar = cmd.menubar{ "yabai" },
    hotkey = cmd.hotkey('modB', '1'),
    fn = function(ctx)
      yabai:shiftWindow(desktop.activeWindow(), { x = 0, y = 0 }, { x = 1, y = 1 })
      return ctx.title
    end,
  },
  {
    id = 'Yabai.Window.Second3rd',
    title = "Move window: 2nd ⅓",
    menubar = cmd.menubar{ "yabai" },
    hotkey = cmd.hotkey('modB', '2'),
    fn = function(ctx)
      yabai:shiftWindow(desktop.activeWindow(), { x = 1, y = 0 }, { x = 1, y = 1 })
      return ctx.title
    end,
  },
  {
    id = 'Yabai.Window.Third3rd',
    title = "Move window: 3rd ⅓",
    menubar = cmd.menubar{ "yabai" },
    hotkey = cmd.hotkey('modB', '3'),
    fn = function(ctx)
      yabai:shiftWindow(desktop.activeWindow(), { x = 2, y = 0 }, { x = 1, y = 1 })
      return ctx.title
    end,
  },
  {
    id = 'Yabai.Window.FirstTwo3rds',
    title = "Move window: 1st ⅔",
    menubar = cmd.menubar{ "yabai" },
    hotkey = cmd.hotkey('modB', '4'),
    fn = function(ctx)
      yabai:shiftWindow(desktop.activeWindow(), { x = 0, y = 0 }, { x = 2, y = 1 })
      return ctx.title
    end,
  },
  {
    id = 'Yabai.Window.SecondTwo3rds',
    title = "Move window: 2nd ⅔",
    menubar = cmd.menubar{ "yabai" },
    hotkey = cmd.hotkey('modB', '5'),
    fn = function(ctx)
      yabai:shiftWindow(desktop.activeWindow(), { x = 1, y = 0 }, { x = 2, y = 1 })
      return ctx.title
    end,
  },
}

log.df('Yabai status: "%s"', yabai:status()) 

return yabai
