local screen  = require 'hs.screen'
local mouse   = require 'hs.mouse'
local win     = require 'hs.window'
local logr    = require 'user.lua.util.logger'
local strings = require 'user.lua.lib.string'
local types   = require 'user.lua.lib.typecheck'
local tables  = require 'user.lua.lib.table'

local log = logr.new('Desktop', 'debug')


-- Desktop/environment utilities
---@class desktop
local desktop = {}


---@alias ScreenSelector
---| 'main' # Screen containing the currently focused window / foremost app (the app receiving text input)
---| 'active' # Alias for the 'main' screen
---| 'mouse' # The screen containing the pointer
---| 'primary' # The primary screen contains the menubar and dock

---@type Dict<ScreenSelector, fun(...: any):hs.screen>
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
  if (types.isString(sel) and tables.has(selectors, sel)) then
    return selectors[sel]();
  else
    error(strings.fmt("Invalid screen selector [%q]", sel), 2)
  end
end


---@return number windowId The numerical ID of the currently active window, or nil if none exists
function desktop.activeWindow()
  return win.focusedWindow():id()
end


--
-- Not sure what this was supposed to do
--
function desktop.bundleIDs()
  local apps = hs.application.runningApplications()

  local bundles = {}

  for i,v in pairs(apps) do
    local b = v:bundleID() or v:name()

    if (b and not bundles[b]) then
      if (bundles[b]) then
        table.insert(bundles[b], v)  
      else
        bundles[b] = { v }
      end
    else
      log.w("No bundle for app:", v)
    end

  end

  log.d(hs.inspect(bundles))

  return bundles
end

function desktop.allWindows()
  -- local winfilter = hs.window.filter
  -- local windows = winfilter.new(false):setFilters{}
  -- local windowList = hs.window.list(windows)


  -- local windowChain = M.chain(windowList)

  -- local L0windows = windowChain:filter(function(winId, ...)
  --   log.d(winId, table.unpack{...})
  --   hsWin = hs.window.get(winId)

  --   if (hsWin ~= nil) then
  --     log.d(hs.inspect(hsWin:application()))
  --   end

  --   return false
  -- end)
  -- :value()

  -- M.each(L0windows, function(hswin)
  --   log.d("A window:", hswin)
  -- end)

  -- return windows
  return {}
end


return desktop
