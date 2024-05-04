local apps        = require 'hs.application'
local win         = require 'hs.window'
local winf        = require 'hs.window.filter'
local class       = require 'middleclass'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local isCli       = require 'user.lua.adapters.base.cli-utility'
local shell       = require 'user.lua.interface.shell'
local U           = require 'user.lua.util'

local wrap = shell.wrap


local log = U.log('yabai.lua', 'debug')

---@class yabai_api
---@deprecated
local yabai_api = {
  service = {
    start   = wrap("yabai --restart-service"),
    stop    = wrap("yabai --restart-service"),
    restart = wrap("yabai --restart-service"),
  },
  space = {
    get_space  = wrap("yabai -m query --spaces --space %d"),
    set_label  = wrap("yabai -m space %d --label '%s'"),
    get_layout = wrap("yabai -m config --space %d layout"),
    balance    = wrap("yabai -m space --balance"),
  },
  window = {
    get                = wrap("yabai -m query --windows --window %s"),
    scratch            = wrap("yabai -m window %s --scratchpad %s"),
    descratch          = wrap("yabai -m window %s --scratchpad"),
    setOpacity         = wrap("yabai -m window %s --opacity %f"),
    toggle = {
      maximize         = wrap("yabai -m window %s --toggle zoom-fullscreen"),
      float            = wrap("yabai -m window %s --toggle float"),
      sticky           = wrap("yabai -m window %s --toggle sticky"),
      pip              = wrap("yabai -m window %s --toggle pip"),
      shadow           = wrap("yabai -m window %s --toggle shadow"),
      split            = wrap("yabai -m window %s --toggle split"),
      zoomParent       = wrap("yabai -m window %s --toggle zoom-parent"),
      zoomFullscreen   = wrap("yabai -m window %s --toggle zoom-fullscreen"),
      nativeFullscreen = wrap("yabai -m window %s --toggle native-fullscreen"),
      expose           = wrap("yabai -m window %s --toggle expose"),
      label            = wrap("yabai -m window %s --toggle %s"),
      any              = wrap("yabai -m window %s --toggle %s"),
    },
  },
  focus = {
    window = {
      next    = wrap("yabai -m space --focus next"),
      prev    = wrap("yabai -m space --focus prev"),
      north   = wrap("yabai -m window --focus north"),
      south   = wrap("yabai -m window --focus south"),
      east    = wrap("yabai -m window --focus east"),
      west    = wrap("yabai -m window --focus west"),
    },
    display = {
      east    = wrap("yabai -m display --focus east"),
      west    = wrap("yabai -m display --focus west"),
    }
  },
  rule = {
    list = wrap("yabai -m rule --list"),
    add = {
      floatWindow = wrap("yabai -m rule --add app='%s' title='%s' label='%s' %s"),
    },
  }
}


---@class Yabai : LaunchAgent
---@field new fun(): Yabai
local Yabai = class('Yabai', LaunchAgent)

Yabai.static.cmds = yabai_api

-- Yabai.static.path = "yabai"
-- Yabai:include(isCli)

function Yabai:initialize()
  LaunchAgent.initialize(self, 'yabai', 'com.koekeishiya.yabai')
end

function Yabai:scratchWindow(windowId)
  if (windowId == nil) then
    windowId = hs.window.focusedWindow():id()
  end

  if (windowId ~= nil) then
    yabai_api.window.scratch(windowId, 'hs-scratch')
  end
end

--
-- 
--
function Yabai:descratchWindow(windowId)
  if (windowId == nil) then
    windowId = hs.window.focusedWindow():id()
  end

  if (windowId ~= nil) then
    local window = U.json(yabai_api.window.get(windowId))

    log.d(hs.inspect(window))

    if (window and window["scratchpad"] ~= '') then
      yabai_api.window.descratch(windowId)
    end
  end
end


function Yabai:floatActiveWindow()
  local rules = U.json(yabai_api.rule.list())

  log.d('Yabai Rules:', hs.inspect(rules))

  local active = hs.window.focusedWindow()
  local app = active:application():title()
  local title = active:title()
  local id = active:id()

  local label = app..title:gsub("%s", "")

  log.df('Active window: "%s" "%s" "%s";', id, title, app)
  log.df('Created label: "%s"', label) 
end

---@class YabaiSpace
---@field display number
---@field first-window number
---@field has-focus boolean
---@field id number
---@field index number
---@field is-native-fullscreen boolean
---@field is-visible boolean
---@field label string
---@field last-window number
---@field type string The layout type
---@field uuid string
---@field windows number[]

---@alias YSpaceSelector 'prev' | 'next' | 'first' | 'last' | 'recent' | 'mouse' | string | number

--
-- Returns a yabai space
--
---@param selector? YSpaceSelector Yabai space selector
---@return YabaiSpace
function Yabai:getSpace(selector)
  local space = U.default(selector, 'mouse')
  return shell.runt("yabai -m query --spaces --space %s", tostring(space))
end


-- Sets the label of a Yabai space
---@param space YSpaceSelector
---@param label string Label to apply to space
---@return string
function Yabai:setSpaceLabel(space, label)
  log.df("Setting label for space [%s] to [%s]", tostring(space), label)
  return shell.run("yabai -m space %s --label %q", tostring(space), label)
end


--
-- Returns the layout value for a specific Yabai space; Deprecated, use Yabai:getSpace(...).type
--
---@deprecated
---@return string
function Yabai:getLayout(num)
  local space = U.default(num, 'mouse')
  local layout = shell.run("yabai -m config --space %s layout", tostring(space))
  log.df("Current yabai layout: [%s]", layout)
  return layout
end


--
-- Sets the layout value for a specific Yabai space
--
---@param layout string
---@param selector? YSpaceSelector
---@return string
function Yabai:setLayout(layout, selector)
  local space = U.default(selector, 'mouse')
  
  log.df("Setting layout for space [%s] to [%s]", tostring(space), layout)
  local layout = shell.run("yabai -m space %s --layout %s", tostring(space), layout)

  return layout
end


local yabai = Yabai:new()

log.df('Yabai status: "%s"', yabai:status()) 

return yabai
