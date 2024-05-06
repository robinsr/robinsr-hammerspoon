local class       = require 'middleclass'
local apps        = require 'hs.application'
local win         = require 'hs.window'
local winf        = require 'hs.window.filter'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local isCli       = require 'user.lua.adapters.base.cli-utility'
local desktop     = require 'user.lua.interface.desktop'
local sh          = require 'user.lua.interface.shell'
local option      = require 'user.lua.lib.optional'
local cmd         = require 'user.lua.model.command'
local U           = require 'user.lua.util'

local log = U.log('yabai.lua', 'debug')


---@class Yabai : LaunchAgent
---@field new fun(): Yabai
local Yabai = class('Yabai', LaunchAgent)


function Yabai:initialize()
  LaunchAgent.initialize(self, 'yabai', 'com.koekeishiya.yabai')
end


--
-- Removes value to window.scratchpad for the given window
-- thus re-adding it to normal management by Yabai
--
---@param windowId? string
function Yabai:scratchWindow(windowId)
  local windowId = U.default(id, desktop.activeWindow)

  if U.notNil(windowId) then
    sh.run('yabai -m window %s --scratchpad %s', windowId, 'hs-scratch')
  end
end

--
-- Adds a value to window.scratchpad for the given window
-- thus removing it from normal management by Yabai
--
---@param id string
function Yabai:descratchWindow(id)
  local windowId = U.default(id, desktop.activeWindow)

  if U.notNil(windowId) then
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

  local label = U.fmt('hsfloat-%s', title:gsub("%s", ""):lower())

  log.df('Active window: "%s" "%s" "%s";', id, title)
  log.df('Created label: "%s"', label) 
end

--
-- Returns a yabai space
--
---@param selector? Yabai.Selector.Space Yabai space selector
---@return Yabai.Space
function Yabai:getSpace(selector)
  local space = U.default(selector, 'mouse')
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
  local space = U.default(num, 'mouse')
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
  local space = U.default(selector, 'mouse')
  local layout = sh.run("yabai -m space %s --layout %s", tostring(space), layout)
  log.df("Setting layout for space [%s] to [%s]", tostring(space), layout)

  return layout
end


Yabai.cmds = {
  {
    id = 'Yabai.RestartYabai',
    title = "Restart Yabai",
    menubar = nil,
    hotkey = cmd.hotkey{ "bar", "Y" },
    fn = function (ctx)
      Yabai:restart()
      
      if (ctx.trigger == 'hotkey') then
        return U.fmt('%s: %s', ctx.hotkey, ctx.title)
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

      return U.fmt('Managing windows for app %s with yabai...', appName)
    end,
  },
  {
    id = 'Yabai.ManagedApps.Remove',
    title = "Ignore app's windows",
    menubar = cmd.menubar{ "yabai" },
    fn = U.noop,
  },
  {
    id = 'Yabai.ManagedApps.List',
    title = "Show ignore list",
    menubar = cmd.menubar{ "yabai" },
    fn = U.noop,
  },
  {
    id = 'Yabai.Info.Window',
    title = "Show info for active app",
    menubar = cmd.menubar{ "yabai" },
    fn = U.noop,
  },
  {
    id = 'Yabai.Info.Space',
    title = "Show info current space",
    menubar = cmd.menubar{ "yabai" },
    fn = U.noop,
  },
}


local yabai = Yabai:new()

log.df('Yabai status: "%s"', yabai:status()) 

return yabai
