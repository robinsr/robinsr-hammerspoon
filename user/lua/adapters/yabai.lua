local class       = require 'middleclass'
local LaunchAgent = require 'user.lua.adapters.base.launchagent'
local isCli       = require 'user.lua.adapters.base.cli-utility'
local shell       = require 'user.lua.interface.shell'
local util        = require 'user.lua.util'

local wrap = shell.wrap


local log = util.log('yabai.lua', 'debug')

local yabai_api = {
  service = {
    start   = wrap("yabai --restart-service"),
    stop    = wrap("yabai --restart-service"),
    restart = wrap("yabai --restart-service"),
  },
  space = {
    get_space = wrap("yabai -m query --spaces --space %d"),
    set_label = wrap("yabai -m space %d --label '%s'"),
    balance   = wrap("yabai -m space --balance"),
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


function Yabai:descratchWindow(windowId)
  if (windowId == nil) then
    windowId = hs.window.focusedWindow():id()
  end


  if (windowId ~= nil) then
    local window = util.json(yabai_api.window.get(windowId))

    log.d(hs.inspect(window))

    if (window and window["scratchpad"] ~= '') then
      yabai_api.window.descratch(windowId)
    end
  end
end


function Yabai:floatActiveWindow()
  local rules = util.json(yabai_api.rule.list())

  log.d('Yabai Rules:', hs.inspect(rules))

  local active = hs.window.focusedWindow()
  local app = active:application():title()
  local title = active:title()
  local id = active:id()

  local label = app..title:gsub("%s", "")

  log.df('Active window: "%s" "%s" "%s";', id, title, app)
  log.df('Created label: "%s"', label) 
end

function Yabai:getSpace(num)
  return shell.runt("yabai -m query --spaces --space %d", num)
end

function Yabai:setSpaceLabel(space, label)
  return shell.run("yabai -m space %d --label '%s'", space, label)
end


local yabai = Yabai:new()

log.df('Yabai status: "%s"', yabai:status()) 

return yabai
