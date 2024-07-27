-- local screen  = require 'hs.screen' --[[@as hs.screen]]
-- local mouse   = require 'hs.mouse' --[[@as hs.mouse]]
-- local win     = require 'hs.window' --[@as hs.window]
local logr    = require 'user.lua.util.logger'
local fns     = require 'user.lua.lib.func'
local lists   = require 'user.lua.lib.list'
local params  = require 'user.lua.lib.params'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local tables  = require 'user.lua.lib.table'

local log = logr.new('Desktop', 'debug')

---@class ks.desktop.app
---@field name string
---@field path string
---@field title string
---@field bundle_id string


---@class ks.desktop.window
---@field app string
---@field id string
---@field role string
---@field subrole string
---@field title string

---@class KS.Desktop
local desktop = {}


---@alias ScreenSelector
---| 'main' # Screen containing the currently focused window / foremost app (the app receiving text input)
---| 'active' # Alias for the 'main' screen
---| 'mouse' # The screen containing the pointer
---| 'primary' # The primary screen contains the menubar and dock

---@type { [ScreenSelector]: fun(): hs.screen }
local selectors = {
  main = hs.screen.mainScreen,
  mouse = hs.mouse.getCurrentScreen,
  active = hs.screen.mainScreen,
  primary = hs.screen.primaryScreen,
}

--
-- Gets the relevant hs.screen object from HS
--
---@param sel ScreenSelector
---@return hs.screen
function desktop.getScreen(sel)
  ---@type hs.screen
  local default = hs.screen.allScreens()[1] 

  if (types.isString(sel) and tables.has(selectors, sel)) then
    return selectors[sel]() or default
  else
    error(strings.fmt("Invalid screen selector [%q]", sel), 2)
  end
end


function desktop.screens()
  return hs.screen.allScreens()
end


--
-- Returns the numerical ID of the currently active window, or nil if none exists
--
---@return integer
function desktop.activeWindowId()
  return hs.window.focusedWindow():id() or 0
end


--
-- Returns the currently active window, or nil if none exists
--
---@return hs.window|nil
function desktop.activeWindow()
  return hs.window.focusedWindow()
end


--
-- Returns the currently active app, or nil if none exists
--
---@return hs.application|nil
function desktop.activeApp()
  local focused = desktop.activeWindow()
  return focused and focused:application()
end


--
-- Returns all the displayable properties of a `hs.application` object
--
---@param app hs.application
---@param noWindows? boolean
---@return ks.desktop.app
function desktop.appInfo(app, noWindows)
  noWindows = noWindows or false

  local appInfo = {
    name = app:name(),
    title = app:title(),
    path = app:path(),
    pid = app:pid(),
    bundleID = app:bundleID(),
  }

  if not noWindows then
    appInfo.windows = lists(app:allWindows()):map(function(w)
      return w and desktop.windowInfo(w, true)
    end):values()
  end
  
  return appInfo
end


--
-- Returns all the displayable properties of a `hs.window` object
--
---@param window hs.window
---@param noApp? boolean
---@return ks.desktop.window
function desktop.windowInfo(window, noApp)
  noApp = noApp or false

  local winInfo = {
    id = window:id(),
    role = window:role(),
    subrole = window:subrole(),
    title = window:title(),
    frame = window:frame(),
    isFullScreen = window:isFullScreen(),
    isMaximizable = window:isMaximizable(),
    isMinimized = window:isMinimized(),
    isStandard = window:isStandard(),
    isVisible = window:isVisible(),
  }

  if not noApp then
    local app = window:application()

    if app then
      winInfo.app = desktop.appInfo(app, true)
    end
  end

  return winInfo
end


--
-- Not sure what this was supposed to do
--
function desktop.bundleIDs()
  local apps = hs.application.runningApplications()

  local bundles = {}

  for i, app in ipairs(apps) do
    local no_key = strings.join{'unknown_', i}
    local app_bid = app:bundleID() or no_key
    local app_name = app:name() or no_key

    bundles[app_bid] = app_name
    bundles[app_name] = app_bid
  end

  return bundles
end


local query_dark_mode = fns.cooldown(10, function()
  log.d('Querying "System Events" for current dark mode')

  local ok, darkModeState = hs.osascript.javascript(
    'Application("System Events").appearancePreferences.darkMode()'
  )

  if not ok then
    error('Error executing osascript (js):' .. darkModeState)
  end

  return types.tobool(darkModeState) --[[@as boolean]]
end)


--
-- Returns the current state of dark mode
--
---@return boolean
function desktop.darkMode()
  return query_dark_mode()
end


--
--
--
function desktop.mouse_position()
  return hs.mouse.absolutePosition()
end


--
-- Sets the pasteboard contents
--
function desktop.setPasteBoard(val)
  hs.pasteboard.setContents(val)
end

return desktop