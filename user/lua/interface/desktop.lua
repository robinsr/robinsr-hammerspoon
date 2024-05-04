local M    = require 'moses'
local U = require 'user.lua.util'

local log = U.log('iface:desktop', 'debug')


-- Desktop/environment utilities
---@class desktop
local desktop = {}


function desktop.get_screen(case)
  function mouse_screen()
    return hs.mouse.getCurrentScreen()
  end

  function main_screen()
    return hs.screen.mainScreen()
  end

  local screen_selectors = {
    main = main_screen,
    mouse = mouse_screen,
    -- todo; screen with frontmost app (app receiving text input)
    active = main_screen,
    largest = main_screen,           -- todo; needed?
  }

  local kscreen_selectors = U.keys(screen_selectors)

  if (type(case) ~= "string") then
    error("No screen selector passed to get_screen_id", 2)
  end

  if (not U.contains(kscreen_selectors, case)) then
    error("Invalid screen selector: "..case, 2)
  end

  return screen_selectors[case]();
end


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
