local screen  = require 'hs.screen' --[[@as hs.screen]]
local mouse   = require 'hs.mouse' --[[@as hs.mouse]]
local win     = require 'hs.window' --[@as hs.window]
local logr    = require 'user.lua.util.logger'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local tables  = require 'user.lua.lib.table'

local log = logr.new('Desktop', 'debug')


-- local SysEvents = hs.application

--
-- Desktop/environment utilities
--

---@class KS.Desktop
local desktop = {}


---@alias ScreenSelector
---| 'main' # Screen containing the currently focused window / foremost app (the app receiving text input)
---| 'active' # Alias for the 'main' screen
---| 'mouse' # The screen containing the pointer
---| 'primary' # The primary screen contains the menubar and dock

---@type { [ScreenSelector]: fun(): hs.screen }
local selectors = {
  main = screen.mainScreen,
  mouse = mouse.getCurrentScreen,
  active = screen.mainScreen,
  primary = screen.primaryScreen,
}

--
-- Gets the relevant hs.screen object from HS
--
---@param sel ScreenSelector
---@return hs.screen
function desktop.getScreen(sel)
  ---@type hs.screen
  local default = screen.allScreens()[1] 

  if (types.isString(sel) and tables.has(selectors, sel)) then
    return selectors[sel]() or default
  else
    error(strings.fmt("Invalid screen selector [%q]", sel), 2)
  end
end


function desktop.screens()
  return screen.allScreens()
end


--
-- Returns the numerical ID of the currently active window, or nil if none exists
--
---@return integer windowId
function desktop.activeWindow()
  return win.focusedWindow():id()
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


--
-- Returns the current state of dark mode
--
---@return boolean
function desktop.darkMode()
  local ok, darkModeState = hs.osascript.javascript(
    'Application("System Events").appearancePreferences.darkMode()'
  )

  if not ok then
    error('Error executing osascript (js):' .. darkModeState)
  end

  return types.tobool(darkModeState)
end


return desktop